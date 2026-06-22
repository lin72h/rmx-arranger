# Phase 2 Architecture Review v3 — Correction

Date: 2026-04-18
Reviewer: Claude (wip-claude)

## Correction to Previous Reviews

My previous two architecture reviews were wrong in a fundamental way. I
was reasoning from the Linux GPU driver stack inward — treating dma-buf,
GEM, TTM, dma-fence, and drm_gpuvm as the canonical design and asking
how Mach primitives could fit around them. That's backwards.

The correct question is: **if you were an Apple engineer building GPU
drivers for AMD RDNA3+ and Intel Arc hardware, and the Linux GPU stack
didn't exist, what would you build on top of Mach and IOKit?**

The answer is not "GPU VM at the center with memory_object as backing."
The answer is: **memory_object IS the GPU buffer. mach_vm IS the address
space manager. Mach IPC IS the sharing and lifecycle mechanism. The GPU
driver uses these kernel primitives directly, and Linux's GPU memory
abstractions are compatibility shims for the transition period.**

I was wrong to say "center on GPU VM, not memory_object." The hardware
doesn't care what your center of gravity is. What matters is which
model produces cleaner lifetimes, simpler sharing, and fewer redundant
abstractions. The Mach model wins on all three.

## 1. Why the Mach Model Is Actually Better

### What Linux reinvented because it lacks Mach primitives

Every major piece of the Linux GPU memory stack exists because Linux
lacks something that Mach provides:

| Linux concept | Why it exists | Mach equivalent |
|---|---|---|
| **dma-buf** | Linux has no cross-process shared memory with lifecycle | `memory_object` + Mach port transfer |
| **GEM handle** | Linux needs per-process buffer naming | Mach port name (already fd-backed in your bridge) |
| **TTM** | Linux has no pageable backing store with driver callbacks | `memory_object` with pager ops (data_request/data_return) |
| **dma-fence** | Linux has no kernel-wide completion primitive | Native fence (could be port-based notification) |
| **syncobj** | Linux needs a user-visible timeline fence handle | Mach port representing a fence timeline |
| **dma-resv** | Linux needs per-buffer fence tracking | Reservation state on the memory_object |
| **drm_gpuvm** | Linux has no unified VM-range tracking | `mach_vm` / `vm_map` already tracks ranges |
| **drm_gpusvm** | Linux has no cross-domain page migration with notifiers | `memory_object` pager with migrate callback |

Linux built seven subsystems to get what Mach provides with two
primitives (`memory_object` + `mach_vm`) plus IPC.

### How macOS GPU drivers actually work (inferred from XNU source)

From `device_vm.c` in the local XNU tree:

1. A GPU buffer is a `device_pager` — a `memory_object` with
   `device_pager_ops` that handles `data_request` (fault-in),
   `data_return` (eviction), and `synchronize` (cache flush).

2. `device_pager_setup()` creates the pager, gets a
   `memory_object_control_t` handle, and marks it `true_share`
   with `MEMORY_OBJECT_COPY_DELAY` — meaning copies are deferred and
   multiple tasks can share the same backing.

3. `device_pager_populate_object()` fills the backing vm_object with
   physical pages via `vm_object_populate_with_private()`.

4. Sharing a GPU buffer between processes = transferring the
   memory_object's Mach port via `mach_msg`, then the receiver calls
   `mach_vm_map()` with that port to map it into their address space.

5. The GPU driver's memory manager IS the pager. When the kernel needs
   pages (fault), it calls `data_request`. When it wants pages back
   (eviction/pressure), it calls `data_return`. The driver decides
   where pages live (VRAM, system RAM, swap).

This is the model your project should build. Not "GPU VM at the center
with memory_object as backing." Not "keep TTM and adapt it." The model
is: **memory_object with a GPU pager IS the GPU buffer, and the
existing Mach/VM infrastructure handles everything else.**

### What this means concretely

**Buffer creation:**
- Linux: `amdgpu_gem_create` → `amdgpu_bo_create` → `ttm_bo_init` →
  GEM handle → export as dma-buf fd
- Mach: create `gpu_memory_object` with `gpu_pager_ops` → get Mach
  port name (already an fd in your bridge)

**Buffer sharing:**
- Linux: `dma-buf export` → fd → `dma-buf import` in other process →
  create new GEM handle → create new TTM BO pointing to same pages
- Mach: transfer memory_object port via `mach_msg` → receiver calls
  `mach_vm_map` with the port → done. Same backing, same pager, same
  lifecycle.

**Buffer eviction/migration:**
- Linux: TTM calls `bo->bdev->funcs->evict()` → driver moves pages →
  `ttm_resource` updated → all GEM importers notified via dma-resv
- Mach: kernel calls pager `data_return` → driver moves pages to
  swap/VRAM → kernel calls `data_request` when pages needed again.
  One pager, one notification path.

**Buffer CPU mapping:**
- Linux: `mmap` the GEM handle → fault → GEM fault handler → TTM fault
  handler → get pages → install PTE
- Mach: `mach_vm_map` the memory_object → fault → kernel calls pager
  `data_request` → pager supplies pages → kernel installs PTE. Same
  mechanism for local and cross-process mapping.

**Buffer destruction:**
- Linux: close GEM handle → if last ref, close dma-buf → release TTM
  BO → free pages. Multiple reference chains (GEM, dma-buf, TTM), each
  with different cleanup paths.
- Mach: last port reference dropped → port destroyed → pager
  `terminate` called → driver frees pages. One reference chain.

The Mach model is simpler at every step because the primitives are
unified where Linux has to bolt things together.

## 2. What memory_object Actually Gives You for GPU Memory

Let me be precise about what the pager interface provides:

**`data_request`** (page fault): the kernel needs pages at offset X of
this memory_object. The GPU pager responds by providing pages — from
VRAM (via `device_pager_populate_object`-style physical page insertion),
from system RAM allocation, or by migrating from another domain. This
IS TTM's fault handler, but integrated into the VM instead of bolted on.

**`data_return`** (eviction): the kernel wants to reclaim pages at
offset X. The GPU pager saves the data (to VRAM, to swap, to another
location) and releases the pages. This IS TTM's eviction, but as a
native VM callback instead of a separate subsystem.

**`synchronize`**: flush pending changes. For GPU memory, this means
flush GPU caches, wait for outstanding DMA, ensure coherency. This IS
what `dma-resv` + `dma-fence` tracking tries to provide.

**`map` / `last_unmap`**: notification that a new mapping has been
established or the last mapping has been removed. For GPU memory, this
is where you manage IOMMU/GART mappings and coherency mode. This IS
what `dma_buf_attachment` does.

**`terminate`**: the memory_object is being destroyed. Clean up all
device resources. This IS GEM's `free_object` callback.

**Lifecycle via port refcounting**: the memory_object exists as long
as any Mach port reference exists. Cross-process sharing is a port
send right. This IS `dma-buf` lifetime management, but unified with
VM lifecycle.

One pager interface replaces five Linux subsystems. Not because it's
magic, but because Mach's VM was designed with external memory managers
as a first-class concept, while Linux's VM was designed only for
anonymous and file-backed memory and GPU support was bolted on later.

## 3. What This Means for Phase 2 Design

### The correct formulation

Phase 2 is not "a GPU memory subsystem with seven pillars."
Phase 2 is: **make GPU drivers use Mach memory_object as their
buffer primitive, the way macOS GPU drivers use IOKit + memory_object.**

The pillars collapse:

1. **memory_object with GPU pager** replaces: dma-buf, GEM, TTM
   backing, dma-resv
2. **mach_vm** replaces: drm_gpuvm range tracking, GEM mmap, cross-
   process buffer mapping
3. **Mach IPC port transfer** replaces: dma-buf export/import,
   GEM flink/prime
4. **native fence** (needed regardless): replaces dma-fence, syncobj
5. **queue/doorbell resources** (correctly identified as non-memory):
   stay as distinct objects
6. **Linux compat layer** (transitional): thin adapters so existing
   DRM code keeps working during migration

### EMMI revisited

I was wrong to say "kill EMMI." The user's instinct was correct: EMMI
(the pager protocol) IS the verb layer. It's not a god-interface —
it's the actual `memory_object_pager_ops` callback table:

```c
struct gpu_pager_ops {
    /* supply pages on fault */
    kern_return_t (*data_request)(gpu_memory_object_t, offset, length, desired_access);
    
    /* reclaim pages under memory pressure */
    kern_return_t (*data_return)(gpu_memory_object_t, offset, length, dirty, ...);
    
    /* flush device caches, wait for DMA completion */
    kern_return_t (*synchronize)(gpu_memory_object_t, offset, length, sync_flags);
    
    /* a new mapping was established */
    kern_return_t (*map)(gpu_memory_object_t, protection);
    
    /* last mapping was removed */
    void (*last_unmap)(gpu_memory_object_t);
    
    /* object is being destroyed */
    void (*terminate)(gpu_memory_object_t);
    
    /* === GPU-specific extensions below === */
    
    /* migrate pages between memory domains (system RAM, VRAM) */
    kern_return_t (*migrate)(gpu_memory_object_t, offset, length, target_domain);
    
    /* revoke device access (for preemption, reset, power) */
    kern_return_t (*revoke)(gpu_memory_object_t, device, reason);
};
```

This is not a god-interface. It's a pager. Every memory_object has one.
Different pager implementations handle different backing:
- Anonymous pager: system RAM + swap
- VRAM pager: GPU VRAM with system RAM fallback
- Device register pager: MMIO (for doorbells)
- Imported pager: wraps a foreign dma-buf for compatibility

The "verb" is the pager's response to kernel requests. The "noun" is
the memory_object. This split is correct and has been correct since
the original Mach design. I should not have argued against it.

### GPU VM's actual role

GPU VM is real and necessary, but it's not the center. It's a
**consumer** of memory_objects:

- The GPU VM tracks which memory_objects are bound at which GPU virtual
  addresses
- When a GPU page fault occurs, the GPU VM identifies the memory_object
  and offset, then the kernel's existing `data_request` path handles it
- When eviction happens, the pager moves pages and the GPU VM is
  notified to invalidate page table entries

This is exactly how CPU VM works in Mach: `vm_map` tracks ranges,
`memory_object` provides backing, the pager handles faults. The GPU
VM is the GPU-side analog of `vm_map`, not the center of the universe.

The driver implements:
- GPU page table management (vendor-specific format)
- GPU TLB invalidation (vendor-specific mechanism)
- GPU VA allocation policy
- The mapping between memory_object offsets and GPU VAs

The native subsystem provides:
- Range tracking (like `vm_map_entry` but for GPU VAs)
- Fault dispatch (look up memory_object from faulting GPU VA)
- Invalidation notification (tell all GPU VMs when a memory_object's
  pages move)

### How `mach_vm` helps GPU drivers specifically

`mach_vm_map` in the donor lane already takes a target task and maps
memory into it. For GPU drivers, this enables:

1. **User-mapped submission rings** (Xe direct submission): the driver
   creates a memory_object for the ring buffer, then uses `mach_vm_map`
   to map it into the user process. The user writes commands directly.
   No ioctl per submission.

2. **Cross-process buffer sharing**: transfer the memory_object port
   via `mach_msg`, receiver calls `mach_vm_map`. One mechanism for both
   CPU and GPU sharing.

3. **GPU context memory**: queue BOs, wptr BOs, context state BOs can
   all be memory_objects with appropriate pagers. The driver maps them
   into GART via the pager's device-mapping path.

4. **Doorbell mapping**: a special memory_object backed by a
   `device_pager`-like MMIO pager that maps BAR space. `mach_vm_map`
   maps it into the user process with appropriate protections.

## 4. How GPU Drivers Should Adapt

### AMD amdgpu

Current Linux model:
```
amdgpu_bo → ttm_buffer_object → ttm_resource (placement)
                               → ttm_tt (pages)
                               → dma-resv (fences)
```

Target Mach model:
```
gpu_memory_object (with amdgpu_vram_pager)
    → data_request: allocate from VRAM pool or system RAM
    → data_return: move to swap or discard
    → migrate: VRAM ↔ system RAM copy (using SDMA engine)
    → synchronize: GPU cache flush via PM4 packets
    → revoke: invalidate GPUVM page table entries
```

The `amdgpu_bo` becomes a thin wrapper around `gpu_memory_object`.
TTM's placement logic (VRAM vs system RAM vs GTT) moves into the
pager's `data_request`/`migrate` implementation. TTM's eviction logic
moves into the pager's `data_return` implementation.

### AMD user queues

Current Linux model:
```
amdgpu_usermode_queue
    → amdgpu_bo for ring, wptr, context (TTM-managed)
    → amdgpu_userq_fence_driver (seq64 in GPU-visible memory)
    → MES API calls for queue add/remove
```

Target Mach model:
```
gpu_queue_descriptor
    → gpu_memory_object for ring (VRAM pager, GART-mapped)
    → gpu_memory_object for wptr (system RAM pager, GART-mapped)
    → gpu_memory_object for context (VRAM pager)
    → native fence timeline (backed by GPU-written seq64)
    → MES API calls (unchanged — hardware protocol, not OS choice)
```

The queue resources are still memory_objects, but with pagers
configured for their specific residency requirements (e.g., the wptr BO
must always be GART-accessible, so its pager never evicts it).

### Intel Xe

Xe's direct submission model maps even more naturally:

Current Linux model:
```
xe_bo → ttm_buffer_object → ...
xe_vm → drm_gpuvm → drm_gpuva (VA tracking)
xe_svm → drm_gpusvm → mmu_interval_notifier (page migration)
xe_exec_queue → GuC submission
```

Target Mach model:
```
gpu_memory_object (with xe_pager)
    → data_request: allocate system RAM or VRAM
    → migrate: VRAM ↔ system RAM via blitter engine
    → revoke: invalidate PPGTT entries

mach_vm for GPU VM:
    → vm_map_entry tracks GPU VA ranges
    → each entry references a gpu_memory_object
    → fault dispatch calls data_request

mach_vm_map for user-mapped rings:
    → map ring buffer memory_object into user address space
    → map doorbell memory_object into user address space
    → user writes directly to ring and rings doorbell
```

The `mach_vm` API is particularly powerful for Xe because Xe's
VM_BIND model is semantically identical to `mach_vm_map`: "map this
memory_object at this virtual address with these permissions."

## 5. What Linux Subsystems Should Be Replaced vs Kept

### Should be replaced by native primitives (Phase 2 target)

| Linux subsystem | Replacement | Reason |
|---|---|---|
| **dma-buf** (export/import) | memory_object port transfer | Mach IPC is the sharing mechanism |
| **GEM** (handle management) | Mach port names | Port names ARE handles |
| **TTM** (backing/eviction) | memory_object pager | Pager IS the backing store manager |
| **dma-resv** (per-buffer fences) | Reservation on memory_object | Belongs on the object, not a separate subsystem |
| **drm_gpuvm** (VA tracking) | GPU-side vm_map | Same range-tracking problem, native solution |

### Should become thin adapters (long transitional period)

| Linux subsystem | Adapter shape | Reason |
|---|---|---|
| **dma-fence** | Native fence ↔ dma-fence bidirectional wrapper | Existing DRM code uses dma-fence pervasively; cold-turkey replacement is impractical |
| **syncobj** | Wraps native fence timeline | Userspace ABI; Mesa/Vulkan drivers use syncobj ioctls |

### Should remain largely intact (driver-internal)

| Linux subsystem | Reason stays |
|---|---|
| **AMD MES protocol** | Hardware interface, not an OS choice |
| **Intel GuC protocol** | Hardware interface, not an OS choice |
| **Vendor PM4/MI command encoding** | Hardware packet format |
| **Vendor register programming** | Hardware interface |
| **Vendor IRQ handling** | Hardware interface |

## 6. What Phase 1 Should Prioritize Now

Given this corrected Phase 2 vision, Phase 1 priorities change:

### Critical (directly enables Phase 2)

1. **Cross-task `mach_msg`.** Buffer sharing = port transfer. If
   cross-task messaging doesn't work, the entire sharing model breaks.
   This is the single highest priority.

2. **`mach_vm_allocate` / `mach_vm_map` characterization.** These ARE
   the Phase 2 primitives. `mach_vm_map` with a memory_object port is
   exactly how GPU buffers get mapped into processes. Test whether
   these traps work in the donor lane.

3. **Donor `memory_object` integration study.** The donor lane has
   `vm_map.defs` with `mach_vm_map` that takes a `mem_entry_name_port`.
   Study whether the donor's `memory_object` → `vm_object` integration
   is functional. This determines whether Phase 2 can build on the
   donor's VM code or must start from scratch.

### Important (reduces Phase 2 risk)

4. **FreeBSD `vm_object` + `device_pager_ops` study.** FreeBSD already
   has `devicepagerops` and `mgtdevicepagerops`. Understanding how to
   register a custom pager that handles GPU memory is essential.

5. **FreeBSD DRM `vm_object` usage study.** The existing drm-kmod uses
   `vm_object` in `ttm_tt.c`, `i915_gem_shmem.c`, etc. Understanding
   the current integration informs how to replace it.

### Deprioritize

6. More same-process `mach_msg` variants — proven.
7. `swtch` — orthogonal.
8. Supported-lane governance widening — doesn't reduce Phase 2 risk.

## 7. Biggest Mistakes to Avoid

1. **Treating the Linux GPU memory stack as the canonical design.**
   This was my mistake in the previous reviews. Linux's stack (dma-buf +
   GEM + TTM + dma-fence + dma-resv + drm_gpuvm) is one implementation
   that exists because Linux lacks Mach primitives. It is not the only
   way or the best way. Your kernel has better primitives. Use them.

2. **"Adapting" native primitives to fit around Linux abstractions.**
   The right direction is the opposite: make the GPU drivers adapt to
   native primitives, and provide Linux compat adapters at the edge for
   the transition period.

3. **Building GPU VM as a separate subsystem from `mach_vm`.** If
   `mach_vm_map` can map a memory_object into a task's address space,
   then a GPU VM is conceptually the same thing but for the GPU's
   address space. The GPU VM should reuse the same range-tracking and
   fault-dispatch concepts as `vm_map`, not reinvent them. The GPU
   driver provides the GPU-specific page table format.

4. **Overcomplicating the pager interface.** The XNU `device_pager`
   in `device_vm.c` is remarkably simple — under 260 lines for the
   entire implementation. A GPU pager adds migration and revocation,
   but the core is still just data_request/data_return/terminate. Do
   not over-engineer this.

5. **Designing around SVM as a Phase 2 requirement.** SVM (transparent
   CPU/GPU address sharing via mmu_notifiers) needs FreeBSD
   infrastructure that doesn't exist yet. Phase 2 should use explicit
   binding (`mach_vm_map`-style). SVM is Phase 3+. But note that the
   Mach model is actually well-suited for SVM later, because
   `memory_object` pagers already handle the "pages moved, need to
   re-fault" case.

6. **Treating doorbells as ordinary memory.** Doorbells are MMIO
   register space, not pageable memory. They need a `device_pager`
   variant that maps BAR regions directly. But they ARE still
   memory_objects — just ones with a pager that provides physical
   device addresses instead of RAM pages. XNU's `device_pager` handles
   exactly this case.

## 8. Recommended Milestone Sequence

This sequence is now centered on the Mach model, not on wrapping Linux.

**M0: Design Specification**

- `gpu_memory_object`: lifecycle, pager ops, sharing via port transfer
- `gpu_pager_ops`: data_request, data_return, migrate, synchronize,
  revoke, terminate
- GPU VM: range tracking, fault dispatch, invalidation, relationship
  to `mach_vm` concepts
- Native fence: signal, wait, compose, GPU-written completion,
  dma-fence adapter
- Queue/doorbell resource model
- Explicit lifetime rules
- Decision records: in-kernel pager callbacks, explicit bind (no SVM),
  AMD-first

**M1: memory_object GPU Pager Prototype**

- Implement `gpu_memory_object` with pager ops
- Anonymous GPU pager (system RAM pages, no VRAM yet)
- CPU mapping via `vm_object` integration
- Port-based lifecycle (create → share → destroy via port refcount)
- Test: allocate, fault-populate, map CPU, share cross-process via
  port transfer + `mach_vm_map`, destroy

Why first: this is the foundation. Everything else depends on a working
shareable memory_object.

**M2: Native Fence Substrate**

- Fence object with signal/wait/compose
- GPU-written completion (poll shared memory location)
- Timeline fence (monotonic sequence per queue)
- `dma-fence` bidirectional adapter
- Software-only test harness

Why second: fences are needed before anything touches real hardware.

**M3: GPU VM Range Manager**

- Per-device GPU address space object
- VA range tracking (bind memory_object at GPU VA range)
- Fault dispatch (GPU fault → lookup memory_object → pager
  data_request)
- Invalidation (pager notifies GPU VM when pages move)
- Driver callback for GPU page table format
- Test: bind, fault, unbind, invalidation sequences

Why third: GPU VM is the consumer of memory_objects. The memory_object
must exist before the consumer.

**M4: Device Mapping and IOMMU**

- Scatter/gather list from memory_object pages
- FreeBSD `bus_dma(9)` / IOMMU integration
- GART-style mapping for queue resources
- Mapping revocation
- Test: map for DMA, access, revoke, verify clean

**M5: VRAM Pager**

- VRAM allocation pool management
- `data_request`: allocate from VRAM, populate
- `data_return`: move to system RAM or discard
- `migrate`: VRAM ↔ system RAM page copy (CPU-based initially)
- Fence-protected migration (wait before moving)
- Test: allocate VRAM-backed object, populate, evict to RAM, fault
  back in

Why after M4: VRAM access requires device mapping to work.

**M6: Queue and Doorbell Resources**

- Queue descriptor: ring BO, wptr BO, context state as memory_objects
  with appropriate pagers
- Doorbell: MMIO BAR pager (device_pager variant)
- GART mapping for queue BOs
- `mach_vm_map` for user-visible ring and doorbell mappings
- Test: allocate queue resources, map into user process, tear down

**M7: dma-fence / dma-buf Compatibility Layer**

- `dma-buf` import: wrap foreign dma-buf as gpu_memory_object with
  import pager
- `dma-buf` export: present gpu_memory_object as dma-buf
  (for display controller, video codec interop)
- `dma-fence` adapter: already done in M2, formalize
- `syncobj` adapter if needed

Why late: this is compatibility, not core. Build native first, adapt
for Linux compat after.

**M8: First AMD Consumer**

- `amdgpu_bo` backed by `gpu_memory_object` instead of TTM
- Basic GPUVM mapping through native GPU VM
- MES user queue with native queue resources
- Display scan-out with native memory_object
- Test: modeset, basic rendering, teardown

**M9: First Intel Consumer** (Phase 2 or Phase 3 depending on timing)

- `xe_bo` backed by `gpu_memory_object`
- PPGTT management through native GPU VM
- GuC submission with native queue resources
- Direct submission with `mach_vm_map`-ed user rings

## 9. Open Assumptions

1. **The donor lane's `mach_vm_map` actually works.** It's wired up in
   `mach_traps.c` but never tested. If it doesn't work, the entire
   sharing and mapping model needs a different first step.

2. **FreeBSD's `vm_object` can accept custom pagers for GPU memory.**
   The `devicepagerops` and `mgtdevicepagerops` exist, suggesting it
   can. But GPU memory has requirements (large pages, VRAM placement,
   cache control) that may not be supported by the current pager
   interface.

3. **AMD MES works on FreeBSD.** MES firmware loading and ring setup
   may have Linux-specific dependencies. If MES doesn't work, AMD user
   queues are blocked.

4. **Port-based memory_object lifecycle works in the fd bridge.** The
   fd bridge represents port names as fds. A memory_object port shared
   via `mach_msg` would need to work as an fd in the receiving process.
   This has not been tested.

5. **Performance of in-kernel pager callbacks is adequate for GPU
   faults.** GPU recoverable page faults need 10-100 microsecond
   response. The pager `data_request` path must be fast enough.

6. **Single-GPU is sufficient for Phase 2.** Multi-GPU (peer-to-peer)
   significantly complicates the memory_object sharing model. Defer
   to Phase 3 unless explicitly needed.

7. **Xe on FreeBSD is realistic for Phase 2.** If not, AMD is the
   only consumer and Intel is deferred. The architecture should still
   be vendor-neutral.

## Summary

The user's instinct was right from the beginning: Phase 2 should be
centered on `memory_object`, not on GPU VM, and not on wrapping Linux
abstractions. The Mach kernel has better primitives for GPU memory
management than Linux does. The correct strategy is:

1. Make GPU drivers adapt to Mach primitives
2. Not adapt Mach primitives to fit around Linux GPU abstractions
3. Provide Linux compat adapters at the edge for the transition
4. Use `mach_vm_map` + port transfer for sharing (replaces dma-buf)
5. Use pager ops for populate/evict/migrate (replaces TTM)
6. Use port names for handles (replaces GEM)
7. Build native fences (needed regardless)
8. Keep Linux compat layer for transition period

Phase 1's most important remaining work: cross-task `mach_msg` and
`mach_vm_map` characterization. These ARE the Phase 2 primitives.
