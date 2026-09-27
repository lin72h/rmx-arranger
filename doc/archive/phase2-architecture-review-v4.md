# Phase 2 Architecture Review v4 — DMO/DMI Foundation Review

Date: 2026-04-18
Reviewer: Claude (wip-claude)

## 1. Overall Verdict

The DMO/DMI vocabulary is an improvement over the previous formulations.
Naming the two layers explicitly forces the right separation between
the kernel-internal memory model (DMO) and the driver-facing API (DMI).
The instinct to model this after Apple's `memory_object` →
`IOMemoryDescriptor` → `IODMACommand` split is correct.

But the current formulation is still underspecified in ways that matter.
Three problems:

**First**, DMO is trying to be both the kernel-internal memory_object
wrapper AND the resource-identity concept. Those are related but not
the same thing. A memory_object is how the VM sees backing store. A GPU
resource identity is how the driver and userspace see a buffer. Apple
solves this with three objects (memory_object, IOMemoryDescriptor,
IOMemoryMap), not two. The current DMO/DMI split risks collapsing the
first two into one, which will hurt when you need DMI to describe
memory that isn't backed by a GPU pager (e.g., a user-space buffer
being passed to the GPU for DMA).

**Second**, the donor lane's `mach_vm_map` implementation is hollow.
The `object` parameter is marked `__unused` and passed as NULL to
`vm_map_find()` (mach_vm.c:130-168). This means the single most
important Phase 2 primitive — "map a memory_object port into a task's
address space" — does not work. Without this, the entire sharing model
(port transfer → mach_vm_map → shared mapping) has no kernel path.
This is not a minor gap. It is a load-bearing absence.

**Third**, FreeBSD's pager interface is synchronous (`getpages` must
return pages), while XNU's `data_request` is an asynchronous upcall
(the pager responds later via `memory_object_data_supply`). GPU page
faults often require VRAM-to-RAM migration or PCIe DMA, which can
take microseconds to milliseconds. Building a GPU pager on FreeBSD's
synchronous pager model is feasible (the faulting thread blocks until
pages are ready, which is what devicepagerops already does), but it
means you won't get the concurrency benefits of XNU's asynchronous
pager model. This is a design constraint to accept, not a blocker.

With those caveats: the direction is right. The architecture should be
a three-layer model built from the kernel outward, with Mach primitives
at the center and Linux compatibility at the edge.

## 2. What the Current Evidence Proves and Does Not Prove

### Proved (from Phase 1 characterization + source reading)

1. **Mach IPC works for same-process paths.** Ports, rights, spaces,
   `mach_msg` send-to-self and reply roundtrip pass under
   WITNESS/INVARIANTS. The control plane is real.

2. **mach_vm_allocate and mach_vm_protect are wired up** and likely
   functional (they delegate to `vm_map_find` and `vm_map_protect`
   — standard FreeBSD VM operations).

3. **XNU's device_pager IS a GPU memory template.** The `device_vm.c`
   source proves that a memory_object pager for device memory is
   remarkably simple (~260 lines): create named object, populate with
   physical pages, handle data_request/data_return/map/last_unmap/
   terminate. The `is_mapped` reference-counting pattern (extra ref
   while mapped, released on last_unmap) is clean.

4. **IOMemoryDescriptor and IODMACommand are cleanly separated.**
   IOMemoryDescriptor is a universal memory description
   (virtual/physical/UPL, any task, prepare/complete, map-into-task).
   IODMACommand is strictly DMA address translation (physical →
   bus address scatter/gather). These are different concerns.

5. **FreeBSD already has custom device pager support.** The
   `cdev_pager_ops` structure (vm_pager.h:287-297) provides
   `cdev_pg_fault`, `cdev_pg_populate`, `cdev_pg_ctor`,
   `cdev_pg_dtor`. The `mgtdevicepagerops` variant adds managed
   page lifecycle. `cdev_pager_allocate()` creates a vm_object with
   custom ops. This is the FreeBSD analog of XNU's device_pager.

6. **AMD GPUVM is a full per-VMID MMU** with interval-tree VA tracking,
   multi-level page tables, and tight coupling to dma_resv for
   synchronization. Queue resources (process context BO, gang context
   BO, wptr BO) are all standard BOs with TTM backing.

7. **AMD user-queue fences use GPU-written seq64** — the GPU writes a
   monotonically increasing sequence number to a known memory location,
   and the CPU polls it. This is fundamentally simple despite the Linux
   plumbing around it.

### Not proved

1. **mach_vm_map with a memory_object port does NOT work.** The donor
   implementation ignores the `object` parameter entirely
   (mach_vm.c:130: `mem_entry_name_port_t object __unused`). The
   function only does anonymous allocation via `vm_map_find(map, NULL,
   ...)`. The entire Phase 2 sharing model depends on this working.

2. **Cross-task mach_msg has never been tested.** Only same-process
   send-to-self and reply roundtrip have passed. Port rights transfer
   between different tasks is untested. This is required for buffer
   sharing.

3. **The donor has no memory_object → vm_object integration.** There
   is no `memory_object_create_named`, no `convert_port_to_memory_
   object`, no `memory_object_control_to_vm_object` in the donor's
   compat/mach tree. These XNU functions are how a pager creates a
   named memory_object and gets access to the backing vm_object. The
   donor lane has none of this infrastructure.

4. **FreeBSD's cdev_pager can handle GPU-grade memory.** The existing
   `cdev_pager_ops` supports fault callbacks, but it's unclear whether
   it supports: large page sizes (2MB for GPU page tables), VRAM
   placement hints, cache mode control (WC/UC), or the lifecycle
   semantics that GPU memory needs (migrate, revoke, IOMMU mapping).

5. **mach_msg body descriptors have never been called.** The
   `ipc_kmsg_copyin_body` / `ipc_kmsg_copyout_body` paths are
   untested. Port descriptor transfer in message bodies is how
   memory_object ports would actually be shared.

6. **Nothing about GPU hardware integration has been tested.** No
   IOMMU/ATS, no PASID, no VRAM allocation, no GPU page tables, no
   DMA mapping. All of Phase 2's hardware integration is hypothesis.

## 3. Is the DMO/DMI Formulation Now Correct?

### DMO: mostly right, but needs tighter definition

DMO as "the memory-object-centered GPU resource model" is the right
concept. But "memory-object-centered" can mean several things, and the
wrong reading leads to bad design.

The right reading, informed by XNU's actual architecture:

**DMO should be a GPU-specific object that OWNS a memory_object facet.**

Not raw `memory_object`. Not a wrapper around `memory_object`. An
object that has-a memory_object among its facets.

In XNU, `struct device_pager` EMBEDS `struct memory_object` as its
first member (device_vm.c:91: `struct memory_object dev_pgr_hdr`). The
device_pager IS-A memory_object (for the VM's purposes) but also
HAS device-specific state (device_handle, size, flags, is_mapped).

A GPU DMO should follow the same pattern:

```c
struct dmo {
    /* memory_object facet — how the FreeBSD VM sees this resource */
    struct vm_object       *vm_obj;       /* backing vm_object */
    const struct dmo_pager_ops *pager;    /* pager callbacks */

    /* identity facet — how the kernel and drivers name this resource */
    /* (on FreeBSD: cdev_pager handle; eventually: Mach port) */

    /* GPU-specific state */
    enum dmo_domain         domain;       /* VRAM, system, both */
    enum dmo_domain         preferred;    /* placement preference */
    size_t                  size;
    uint32_t                flags;        /* coherent, WC, UC, ... */

    /* lifecycle */
    refcount_t              refcount;
    bool                    is_mapped;    /* any CPU mapping exists */
    bool                    is_gpu_bound; /* any GPU VA binding exists */

    /* reservation / synchronization (replaces dma-resv) */
    /* ... native fence tracking goes here ... */
};
```

The memory_object facet is provided by the backing `vm_object` +
custom pager ops. The identity facet will eventually be a Mach port
(so it can be transferred via `mach_msg`). The GPU-specific state is
what makes this more than a raw memory_object.

### DMI: correct concept, but should be TWO interfaces, not one

Looking at Apple's actual split:

- `IOMemoryDescriptor` = "describe this memory for I/O" (direction,
  ranges, task association, prepare/complete, map-into-task)
- `IODMACommand` = "translate this description to bus addresses"
  (scatter/gather, IOMMU mapping, segment generation)

These are separate concerns:

1. **Memory description** (DMI proper): given a DMO, describe it as a
   set of physical pages that can be wired, mapped into a task, and
   used for I/O. This is what drivers call to get CPU access or to
   prepare memory for DMA.

2. **DMA mapping** (DMI-DMA or a sub-interface of DMI): given a
   described memory range, translate it to bus addresses suitable for a
   specific device's DMA engine. This handles IOMMU, GART, scatter/
   gather list generation.

Collapsing these into one "DMI" layer is tempting but wrong. A driver
sometimes needs to describe memory without DMA-mapping it (e.g., for
CPU-only access). A driver sometimes needs to DMA-map memory that
isn't a DMO (e.g., a user-space buffer for a compute shader argument).

**Recommendation:** keep the term "DMI" for the full driver-facing
interface, but internally it should have two sub-concerns:
- DMI description: prepare, complete, map-into-task, get-physical-
  segments
- DMI DMA: map-for-device, unmap-from-device, scatter/gather

On FreeBSD, the DMA sub-concern maps directly to `bus_dma(9)` /
`busdma_tag` / `busdma_map`. The description sub-concern is new.

### Name evaluation

**DMO** (Descriptor Memory Objects): the name is slightly misleading
because the object is not a descriptor — it's the memory itself. The
"Descriptor" prefix confusingly echoes `IOMemoryDescriptor`, which is
the driver-facing API, not the backing object. A name like "GMO" (GPU
Memory Object) or just "MO" would be cleaner. But naming is the user's
call, and the concept is sound regardless of what it's called.

**DMI** (Descriptor Memory Interface): this name works. It says "the
interface for working with Descriptor Memory Objects." The Apple
parallel would be: DMI ≈ IOMemoryDescriptor + IODMACommand as a
combined driver-facing surface.

## 4. What the True Center of Gravity Should Be

The center is **DMO**, specifically its memory_object / vm_object facet.

Not raw `memory_object` — DMO adds GPU-specific state that raw
memory_object doesn't have (domain, placement, GPU-side lifecycle).

Not GPU VM — GPU VM is a consumer of DMOs, the same way CPU
`vm_map` is a consumer of `vm_object`s.

Not DMI — DMI is the driver-facing surface over DMO, the way
`IOMemoryDescriptor` is the driver surface over `memory_object`.

Not fences — fences coordinate access to DMOs, they don't define them.

The architectural invariant should be: **every GPU-accessible memory
resource that has a shareable identity is a DMO. Everything else —
mapping, synchronization, DMA translation, GPU page tables — operates
on DMOs.**

Here's why this is correct, not just aesthetically pleasing:

1. **Lifecycle is unified.** A DMO's refcount determines when the
   resource is freed. Whether it's referenced by a CPU mapping, a GPU
   VA binding, a fence, or a port name in another process, they all
   hold references on the same DMO. One lifecycle, not the
   GEM+dma-buf+TTM multi-chain of Linux.

2. **Sharing is unified.** Transferring a DMO between processes =
   transferring the Mach port that names it (eventually). The receiver
   can map it (CPU or GPU) without the sender's cooperation. No
   export/import dance.

3. **Eviction/migration is unified.** The pager's data_return handles
   all eviction. Whether the kernel needs pages back for memory
   pressure or the driver needs to move pages for defragmentation, the
   same callback does the work.

4. **Faults are unified.** Whether a CPU fault or a GPU fault hits a
   DMO-backed range, the resolution path is the same: look up the DMO,
   call the pager to supply pages, install the PTE (CPU or GPU).

## 5. How memory_object, mach_vm, and Mach IPC Should Each Contribute

### memory_object (via DMO's pager facet)

**Role: backing store identity, lifecycle, fault/eviction/migration**

What it provides to Phase 2:
- A named kernel object tied to a `vm_object` that represents GPU
  memory
- Pager callbacks that the driver implements:
  - `fault` (supply pages when a mapping is accessed)
  - `evict` (reclaim pages under pressure or for migration)
  - `migrate` (move pages between VRAM and system RAM)
  - `terminate` (clean up when last reference drops)
  - `map` / `last_unmap` (track CPU mapping state)
- Copy semantics via `MEMORY_OBJECT_COPY_DELAY` (deferred copy, shared
  by default — correct for GPU buffers)

What it does NOT provide (and shouldn't be asked to):
- GPU page table management (vendor-specific)
- DMA address translation (that's DMI-DMA / bus_dma)
- Fence/synchronization state (that's native fence)
- Queue/doorbell resources (those are separate resource types)

### mach_vm

**Role: CPU-side mapping of DMO into task address spaces**

What it provides to Phase 2:
- `mach_vm_map(task, port, offset, size, protection)`: map a DMO into a
  specific task. This is how userspace gets CPU access to GPU buffers.
  It's also how user-mapped submission rings (Xe direct submission,
  AMD userqueue wptr) are exposed to userspace.
- `mach_vm_allocate`: anonymous memory for non-GPU-specific use
- `mach_vm_protect`: change protection on mapped regions

GPU VM analogy:
- GPU VM bind/unbind is semantically similar to `mach_vm_map` /
  `mach_vm_deallocate`, but operates on GPU page tables instead of CPU
  page tables. The API design should be inspired by mach_vm (explicit
  bind with protection and offset), but the implementation is separate
  because GPU page table formats are vendor-specific.
- The analogy should NOT be taken further than API shape. Do not try to
  reuse `vm_map` code for GPU VA tracking — the locking, fault handling,
  and page table manipulation are fundamentally different.

**Critical gap: mach_vm_map must be extended.** The current
implementation (mach_vm.c:128-177) ignores the memory_object port.
Before Phase 2 can start, this must map a named memory_object (via
its port) into the target task's address space using the FreeBSD VM's
existing `vm_map_find` or `vm_mmap` with the DMO's backing vm_object.

### Mach IPC

**Role: cross-process DMO sharing via port rights transfer**

What it provides to Phase 2:
- A DMO has a Mach port. Sending a send right to that port via
  `mach_msg` transfers the ability to map the DMO. The receiver calls
  `mach_vm_map` with the received port to get a mapping.
- Port-based refcounting means the DMO stays alive as long as any
  process holds a right. When the last right is dropped, the port is
  destroyed, and the DMO's terminate callback is called.

What requires verification:
- Cross-task `mach_msg` with port descriptors in the body
  (`MACH_MSGH_BITS_COMPLEX`) must work
- The fd bridge must correctly handle memory_object port rights
  (receive a port right → get an fd → use the fd to call mach_vm_map)
- Port lifetime must correctly track DMO lifetime across processes

## 6. How This Should Simplify AMDGPU and Xe

### AMD RDNA3+ / MES / Userqueue

**What stays vendor-specific** (untouched by DMO/DMI):
- MES firmware protocol (mes_add_queue_input, mes_remove_queue_input)
- GPU page table format (multi-level, VMID-based, vendor encoding)
- PM4/SDMA command encoding
- Doorbell register layout
- MMHUB/GMC register programming
- MQD (micro-queue descriptor) format

**What moves into DMO/DMI:**

| Current Linux object | DMO/DMI replacement | What changes |
|---|---|---|
| `amdgpu_bo` (TTM-backed) | DMO with `amdgpu_pager` | Pager handles VRAM/GTT/sysmem placement instead of TTM resource manager |
| `amdgpu_bo_va` (VA mapping) | GPU VM bind of DMO at VA range | The driver tells GPU VM to bind a DMO at a GPU VA; GPU VM tracks it |
| Root page table BO | DMO with `amdgpu_pt_pager` (always-resident pager) | Page table memory is a DMO that is never evicted |
| `dma_resv` on BO | Reservation state on DMO | Fence tracking moves to the DMO itself |
| GEM handle | Mach port name (fd-backed) | Userspace names buffers via port names, not GEM ioctls |
| `dma-buf` export | Port transfer via mach_msg | Share buffers by sending the port right |

**What moves into DMO/DMI for user queues:**

| Current Linux object | DMO/DMI replacement |
|---|---|
| Process context BO (`AMDGPU_USERQ_PROC_CTX_SZ`) | DMO with system-RAM pager, GART-mapped via DMI-DMA |
| Gang context BO (`AMDGPU_USERQ_GANG_CTX_SZ`) | DMO with system-RAM pager, GART-mapped |
| wptr BO (GART-pinned) | DMO with system-RAM pager, pinned, GART-mapped |
| seq64 fence memory | DMO or reserved memory region for GPU-written fence values |
| Doorbell | NOT a DMO — separate MMIO resource mapped via `mach_vm_map` of a BAR-backed device pager |

**How fences simplify:**
- `amdgpu_userq_fence_driver` currently wraps `dma_fence` with seq64
  read/write and a fence list. A native fence driver would do the same
  thing without the `dma_fence` layer: read the GPU-written sequence
  number, signal fences whose seqno ≤ read value.
- `dma-fence` adapter wraps the native fence for existing DRM code
  that expects `dma_fence *`.

### Intel Xe

**What stays vendor-specific:**
- GuC submission protocol
- PPGTT format (4-level page tables, PDE/PTE encoding)
- Blitter/copy engine command encoding
- TLB invalidation protocol
- Tile/GT topology

**What moves into DMO/DMI:**

| Current Linux object | DMO/DMI replacement |
|---|---|
| `xe_bo` (TTM-backed) | DMO with `xe_pager` |
| `xe_vma` (VM bind entry) | GPU VM bind of DMO at VA range |
| `drm_gpusvm_range` | Phase 3 (SVM requires MMU notifier infra) |
| `xe_svm_range.tile_present/invalidated` | Phase 3 |

**How Xe specifically benefits from mach_vm:**

Xe's VM_BIND model is already semantically `mach_vm_map` for the GPU:
"map this buffer object at this GPU virtual address with these
permissions." If GPU VM bind adopts `mach_vm_map`-like semantics, the
Xe driver's VM_BIND ioctl implementation becomes almost a direct
translation.

Xe's direct submission with user-mapped rings maps naturally:
1. Create DMO for ring buffer (system RAM pager, GART-mapped)
2. `mach_vm_map` the DMO into user task → user writes commands directly
3. Create DMO for doorbell (BAR pager) → `mach_vm_map` into user task
4. User writes to ring, writes to doorbell → GPU starts executing

This is exactly what `mes_userqueue.c` does for AMD, but the Mach model
makes it explicit rather than hiding it behind TTM+GEM+VM layers.

## 7. The Biggest Mistakes Still to Avoid

Ranked by architectural damage if we get them wrong:

### 1. Assuming mach_vm_map works for memory_object mapping

**Risk: critical.**
The donor lane's `mach_vm_map` passes NULL for the memory_object port
(mach_vm.c:130: `object __unused`, line 168: `vm_map_find(map, NULL,
...)`). This means Phase 2's core operation has NO kernel path today.
This must be fixed before any DMO work begins. The fix requires wiring
the `mem_entry_name_port_t object` parameter to `vm_map_find(map,
dmo->vm_obj, ...)` so that mapping a named DMO into a task actually
maps the DMO's backing vm_object.

### 2. Conflating DMO with raw memory_object

**Risk: high.**
If DMO is just `memory_object`, then VRAM-only resources are awkward
(VRAM pages aren't CPU-pageable in the normal sense), queue resources
are awkward (they need pinned, GART-mapped memory, not pageable
backing), and driver-specific metadata has nowhere to live. DMO must
be a GPU-specific object that HAS a vm_object facet, not IS a
vm_object.

### 3. Under-designing GPU VM

**Risk: high.**
GPU VM is NOT just "mach_vm for the GPU." GPU page table formats are
vendor-specific (AMD has up to 5-level page tables with VMID, Intel has
4-level PPGTT). GPU TLB invalidation is vendor-specific. GPU page
faults are handled by the hardware scheduler (MES/GuC), not the CPU
MMU. The GPU VM layer must provide range tracking and fault dispatch
as a common service, but the page table management must be driver
callbacks. Do not try to reuse `vm_map` code directly.

### 4. Treating doorbells as DMOs

**Risk: medium.**
Doorbells are MMIO register space, not memory. They should be mapped
into userspace via `mach_vm_map` of a BAR-region device pager (like
XNU's device_pager for MMIO), but they are NOT DMOs. They don't have
pages, they can't be evicted, they can't be shared cross-process in
the normal way (each process gets its own doorbell region). Model them
as a separate MMIO resource type.

### 5. Replacing TTM before DMO is proven

**Risk: medium.**
TTM is deeply embedded in both amdgpu and Xe. It manages placement
(VRAM vs system RAM vs GTT), eviction, swap, and LRU. Replacing it
requires that DMO's pager can handle all of these cases correctly.
The safe path: build DMO alongside TTM, have DMO's pager delegate to
TTM initially, then gradually move placement/eviction logic into the
pager. A cold-turkey TTM removal will break everything.

### 6. Over-literalizing the Apple analogy

**Risk: medium.**
Apple's IOKit is a C++ class hierarchy with IORegistry, matching,
probe/attach lifecycle, and deep integration with the XNU personality
system. None of that is needed here. What we need from Apple is:
- The three-layer split (memory_object → descriptor → DMA command)
- The pager-as-backing-store model
- The task-mapping model (mach_vm_map with port)
- The port-based sharing model

What we do NOT need:
- IOKit's class hierarchy
- IOKit's property matching
- IOKit's power management integration
- IOKit's registry tree

### 7. Assuming Mach port lifetime "just works" for GPU resources

**Risk: medium.**
Port-based lifetime works cleanly for XNU's device_pager because the
pager has simple lifecycle: create → map → use → last_unmap → destroy.
GPU resources have more complex lifecycle: create → map CPU → bind GPU
→ submit commands → wait for GPU completion → unbind GPU → unmap CPU →
destroy. If the last port right is dropped while the GPU is still
accessing the resource, the terminate callback must wait for GPU
completion before freeing the backing memory. This requires fence
integration in the DMO lifecycle.

### 8. Designing for SVM in Phase 2

**Risk: low but tempting.**
SVM (Shared Virtual Memory, transparent CPU/GPU address sharing) needs
MMU notifier infrastructure that FreeBSD doesn't have. Xe's
`drm_gpusvm` is built entirely on `mmu_interval_notifier`. Phase 2
should use explicit binding (`mach_vm_map`-style) and defer SVM to
Phase 3. The DMO/mach_vm model is actually well-suited for SVM later
(memory_object pagers already handle "pages moved, need to re-fault"),
but the infrastructure isn't there yet.

## 8. Recommended Milestone Sequence

Built from the kernel outward. Each milestone must pass before the next
starts.

### M0: Verify the Kernel Floor

**What:** Prove that the Mach primitives Phase 2 depends on actually
work in the donor lane.

**Tasks:**
1. Cross-task `mach_msg` with inline data (different processes,
   not just same-process)
2. `mach_msg` with body port descriptors (`MACH_MSGH_BITS_COMPLEX`,
   `ipc_kmsg_copyin_body` / `ipc_kmsg_copyout_body` paths)
3. `mach_vm_allocate` characterization (does it work? page-aligned?)
4. `mach_vm_map` with NULL object (anonymous mapping, current
   behavior — verify it actually works in the guest)
5. Donor `memory_object` source study: what code exists for
   `memory_object_create_named`, `convert_port_to_memory_object`,
   memory_object → vm_object conversion? If none, document the gap.

**Exit criterion:** cross-task port transfer works, mach_vm_allocate
works, and the memory_object gap is precisely documented.

**Why first:** everything after this is hypothesis until these pass.

### M1: mach_vm_map + memory_object Integration

**What:** Make `mach_vm_map` actually map a named vm_object into a
task.

**Tasks:**
1. Extend donor `mach_vm_map` to accept a vm_object reference (not
   just NULL) and pass it to `vm_map_find`
2. Create a test: allocate a vm_object, populate it with pages, call
   `mach_vm_map` with the object, read the data from the mapped address
3. Create a cross-process test: process A creates a vm_object and
   shares it (via Mach port or other mechanism) to process B, which
   maps it and reads the data
4. Verify that the mapping tracks the vm_object's lifecycle (unmap
   when the last reference drops)

**Exit criterion:** a vm_object can be mapped into a different task's
address space and accessed.

**Why second:** this is THE Phase 2 primitive. Without it, nothing
else works.

### M2: DMO Prototype with System-Memory Pager

**What:** Implement the DMO object model with the simplest possible
pager (system RAM only, no VRAM).

**Tasks:**
1. Define `struct dmo` and `struct dmo_pager_ops`
2. Implement system-memory pager (fault → allocate page, evict →
   free page, terminate → free all)
3. Register as a FreeBSD `cdev_pager` (or custom pager type) so that
   faults on DMO-backed vm_objects call the pager
4. Create DMO, map via `mach_vm_map`, write data, read back, unmap,
   verify cleanup
5. Cross-process test: share DMO via Mach port transfer, map in
   receiving process, verify shared data

**Exit criterion:** a DMO backed by system RAM can be created, mapped
into one or more tasks, shared cross-process, and cleanly destroyed.

### M3: DMI — Driver-Facing Memory Interface

**What:** Build the driver-facing API over DMO.

**Tasks:**
1. Define `struct dmi_descriptor` (analogous to IOMemoryDescriptor):
   direction, ranges, prepare/complete, map-into-task
2. Define `struct dmi_dma_mapping` (analogous to IODMACommand):
   translate DMO pages to bus addresses via `bus_dma(9)`
3. Implement `dmi_prepare()` (wire pages) / `dmi_complete()` (unwire)
4. Implement `dmi_map_task()` (map DMO into specified task via
   mach_vm_map)
5. Implement `dmi_map_device()` (create scatter/gather list for DMA)
6. Test: DMO → prepare → DMA map → verify bus addresses → DMA unmap →
   complete

**Exit criterion:** a driver can describe a DMO for I/O, prepare it,
get bus addresses, and complete — the full prepare/complete lifecycle.

### M4: Native Fence Substrate

**What:** Build a fence/timeline mechanism that is simpler than
dma-fence but interoperable with it.

**Tasks:**
1. Define native fence object: signal, wait, status, refcount
2. Timeline fence: monotonic seqno per context (like AMD's
   seq64 model)
3. GPU-written completion: allocate DMO for fence memory, GPU writes
   seqno, CPU polls
4. Software signal/wait (for testing without hardware)
5. `dma-fence` bidirectional adapter: native ↔ dma-fence conversion
6. Test: create timeline, emit fence, signal (software), wait,
   verify. Then: create dma-fence adapter, verify interop with
   existing DRM code.

**Exit criterion:** native fences work, GPU-written fences can be
polled, and the dma-fence adapter passes basic interop tests.

### M5: GPU VM Range Manager

**What:** Common GPU address space tracking and fault dispatch.

**Tasks:**
1. Per-device GPU address space object with VA range tracking
2. Bind: "this DMO is at GPU VA range [start, end) with protection P"
3. Unbind: remove a binding
4. Fault dispatch: GPU fault → lookup DMO → pager fault callback
5. Invalidation: pager notifies GPU VM when DMO pages move → GPU VM
   calls driver to invalidate GPU PTEs
6. Driver callbacks: page table format, TLB invalidation, PTE install

**Exit criterion:** range tracking works, bind/unbind works, fault
dispatch calls the correct pager, invalidation propagates to driver.

### M6: VRAM Pager

**What:** Extend DMO pager to handle VRAM placement and migration.

**Tasks:**
1. VRAM pool allocator (per-device, per-heap)
2. VRAM pager: fault → allocate from VRAM pool, populate physical
   pages
3. Eviction: VRAM pressure → pager data_return → copy VRAM to system
   RAM (via SDMA/blitter) → release VRAM pages
4. Migration: system RAM ↔ VRAM page copy with fence protection
5. LRU tracking for eviction candidate selection
6. Test: allocate VRAM DMO, populate, evict to RAM, fault back in,
   verify data integrity

**Exit criterion:** VRAM-backed DMOs work, eviction/migration is
correct, fence protection prevents data loss.

### M7: Queue and Doorbell Resources

**What:** Model queue submission resources using DMO/DMI.

**Tasks:**
1. Queue ring buffer: DMO with system-RAM pager, GART-mapped via
   DMI-DMA
2. Queue wptr buffer: DMO with system-RAM pager, pinned, GART-mapped
3. Queue context state: DMO with system-RAM pager, GART-mapped
4. Doorbell: BAR-region device pager (NOT a DMO), mapped into user
   task via `mach_vm_map`
5. Fence memory: DMO for GPU-written seq64 values
6. Test: allocate all queue resources, map into user task, verify
   accessibility, tear down

**Exit criterion:** queue resources can be allocated, mapped, and
accessed by userspace.

### M8: Linux Compatibility Adapters

**What:** Thin wrappers so existing DRM/drm-kmod code can use DMO/DMI.

**Tasks:**
1. `dma-buf` import adapter: wrap foreign dma-buf as a DMO with
   import pager (delegate page management to the foreign dma-buf)
2. `dma-buf` export adapter: present a DMO as a dma-buf for
   consumers (display controller, video codec)
3. GEM → DMO adapter: GEM ioctls create DMOs instead of (or alongside)
   TTM BOs
4. TTM → DMO adapter: TTM BOs delegate to DMO pager for placement
5. `dma-fence` adapter: already built in M4, formalize for production

**Exit criterion:** existing DRM code that uses dma-buf, GEM, TTM,
and dma-fence can interoperate with DMO/DMI without modification.

### M9: First Driver Consumer (AMD)

**What:** Wire amdgpu to use DMO/DMI for basic operations.

**Tasks:**
1. `amdgpu_bo` creation path: create DMO instead of (or alongside)
   TTM BO
2. GPUVM bind: bind DMO at GPU VA through native GPU VM
3. User queue: allocate queue resources as DMOs, map doorbells
4. Display scan-out: present DMO-backed buffer to display controller
5. Test: modeset, basic rendering (via Mesa), userqueue submission,
   teardown

**Exit criterion:** AMD GPU can render a frame using DMO-backed
buffers through the native GPU VM and queue path.

## 9. Challenging Prior Wrong Turns

### 1. "Buffer object should be the center, not memory_object."

**Still wrong.** A "buffer object" without a kernel memory identity is
just a driver-internal struct. The power of DMO is that it IS a kernel
memory object — the VM knows about it, the pager manages its pages,
port refcounting manages its lifetime. Making a BO the center means
you're back to GEM+TTM with no VM integration.

### 2. "GPU VM should be the center, not memory_object."

**Still wrong.** GPU VM is a consumer of DMOs, not the center. The
same DMO can be bound into multiple GPU VMs (cross-device sharing) and
into multiple CPU address spaces (cross-process sharing). If GPU VM
were the center, sharing requires extracting the "center" from one GPU
VM and inserting it into another — which is exactly the dma-buf problem
Linux has.

### 3. "Kill the pager verb layer / kill EMMI completely."

**Wrong. Now understood why.** The pager IS the driver's memory manager.
data_request/data_return/migrate/terminate are the verbs by which the
kernel communicates memory events to the driver. This is not a god-
interface — it's a callback table. Different DMOs have different pagers
(system-RAM pager, VRAM pager, import pager, BAR pager). The verb set
is fixed and small; the implementations are per-driver.

### 4. "Fence first, GPU VM second, memory objects third."

**Partially wrong, now nuanced.** The corrected order is:
memory_object integration (M1-M2) → DMI (M3) → fence (M4) → GPU VM
(M5) → VRAM pager (M6). Fences must come before GPU VM because GPU VM
fault handling needs to wait for outstanding fences before migrating
pages. But memory_object must come first because fences need something
to protect, and GPU VM needs something to bind.

### 5. "Build Linux compat adapters over native primitives" as primary framing.

**Wrong as primary framing, right as a secondary activity.** The
primary framing is "build DMO/DMI as a native kernel subsystem." Linux
compat adapters (M8) are built AFTER the native substrate works, not
as the first deliverable. The adapter mindset leads to designing the
native layer around Linux's needs rather than around correct
primitives.

### 6. "TTM should stay central for a long time."

**Partially right in practice, wrong as a design goal.** TTM will be
present during the transition period (M8-M9+) because existing DRM code
uses it. But it should progressively become a thin delegation layer
over DMO's pager, not the other way around. The design goal is to make
TTM's placement/eviction logic live in the DMO pager, so that TTM
becomes an adapter, then disappears. How long this takes depends on
how quickly the DMO pager matures.

### 7. "DMO should just be raw memory_object."

**Wrong.** DMO must be a GPU-specific object that HAS a memory_object
facet (vm_object + pager). Raw memory_object lacks: domain tracking
(VRAM vs system RAM), placement preferences, GPU-specific metadata,
fence integration, and the layered pager model (system-RAM pager vs
VRAM pager vs import pager). DMO wraps memory_object the way XNU's
device_pager wraps it: embed the VM identity, add device-specific
state.

### 8. "DMI should be unnecessary if we already have memory_object."

**Wrong.** memory_object is a kernel-internal interface between the VM
and the pager. Drivers should not call memory_object operations
directly. They need a driver-facing API that handles: preparation
(wire pages for I/O), DMA address translation (physical → bus),
task mapping (map into userspace), cache management, and lifecycle
(prepare → use → complete). This is what IOMemoryDescriptor +
IODMACommand provide in Apple's world, and what DMI provides here.

## 10. Phase 1 → Phase 2 Transition Plan

### What Phase 1 should do NOW (ranked by Phase 2 risk reduction)

| Priority | Task | Why it reduces Phase 2 risk |
|---|---|---|
| **1** | Cross-task `mach_msg` with port descriptors | Buffer sharing = port transfer. If this doesn't work, the entire DMO sharing model is blocked. |
| **2** | `mach_vm_allocate` / `mach_vm_map` characterization | These ARE the Phase 2 primitives. Verify they actually work in the guest. |
| **3** | Donor `memory_object` / `mach_vm_map(object)` source audit | Document exactly what's missing for memory_object → vm_object integration. The `__unused` object parameter in mach_vm_map is the #1 gap. |
| **4** | FreeBSD `vm_object` + `cdev_pager_ops` + `mgtdevicepagerops` study | Can FreeBSD's pager handle GPU-grade memory? Large pages? Cache control? Custom eviction? This determines whether DMO can use FreeBSD's existing pager infra or needs a new pager type. |
| **5** | FreeBSD `bus_dma(9)` / IOMMU / GART study | DMI-DMA needs to translate DMO pages to bus addresses. bus_dma is the FreeBSD interface. Understand its capabilities and limitations for GPU memory. |
| **6** | More same-process Mach IPC work | Diminishing returns — already proven. |
| **7** | Supported-lane governance widening | Doesn't reduce Phase 2 risk. |

### Transition Architecture

The transition from Phase 1 (Linux drm-kmod baseline) to Phase 2
(DMO/DMI) should NOT be a flag-day replacement. It should be a
progressive narrowing:

```
Phase 1: GPU driver → GEM → TTM → dma-buf → dma-fence → Linux VM
                              ↓
Phase 2a: GPU driver → GEM → [TTM → DMO pager] → dma-fence → FreeBSD VM
                              ↓
Phase 2b: GPU driver → DMI → DMO → [dma-fence adapter] → FreeBSD VM
                              ↓
Phase 2c: GPU driver → DMI → DMO → native fence → FreeBSD VM
```

At each step, one Linux layer is replaced by a native layer, and
compatibility adapters handle the remaining Linux code that hasn't
been migrated yet.

The key invariant during transition: **existing DRM functionality
must not regress.** At every intermediate step, the existing drm-kmod
display and rendering paths must continue to work. The DMO/DMI path
is built alongside, tested independently, and grafted in when ready.

## 11. Open Assumptions That Must Be Verified

1. **mach_vm_map with a vm_object is implementable on FreeBSD.**
   `vm_map_find` accepts a `vm_object_t` parameter. The question is
   whether the donor's `mach_vm_map` can be extended to pass a
   DMO's vm_object to `vm_map_find` and get a working, fault-handling
   mapping. This should be straightforward but has never been tested.

2. **FreeBSD's cdev_pager_ops is sufficient for GPU memory.** The
   `cdev_pg_fault` callback returns a `vm_page_t *mres`. This requires
   the pager to provide a page synchronously. For system RAM, this is
   fine. For VRAM, the pager must either pre-populate pages (like
   XNU's `device_pager_populate_object`) or do a synchronous
   VRAM-to-RAM copy in the fault path. The latter may be too slow
   for GPU page faults. Pre-population (like device_pager) is likely
   the right model for VRAM.

3. **Cross-task mach_msg with body port descriptors works.** The
   `ipc_kmsg_copyin_body` / `ipc_kmsg_copyout_body` paths have never
   been called. If they crash or mishandle rights, the sharing model
   breaks.

4. **The fd bridge handles memory_object ports correctly.** When a
   memory_object port right arrives via mach_msg, the receiving
   process gets it as an fd (DTYPE_MACH_IPC). The question is whether
   this fd can then be used as the `mem_entry_name_port_t` argument
   to mach_vm_map. This requires the bridge to convert fd → port →
   vm_object correctly.

5. **AMD MES firmware loads and initializes on FreeBSD.** MES is
   required for user queues. If the firmware loading path has
   Linux-specific dependencies, AMD user queues are blocked regardless
   of DMO/DMI.

6. **bus_dma(9) can handle GPU memory's scatter/gather requirements.**
   GPU memory may require 256-byte alignment, large segments (2MB
   pages), and IOMMU bypass for VRAM. bus_dma(9) may need extensions
   or a parallel path for GPU DMA.

7. **Port refcounting correctly handles GPU resource lifecycle.** The
   concern: if the last port right is dropped while a GPU command
   using the resource is still in flight, the terminate callback must
   wait for GPU completion (via fence) before freeing pages. This
   requires DMO's terminate to check outstanding fences, which means
   fences must be integrated into DMO before the sharing model is
   fully safe.

8. **Performance of synchronous pager fault path is adequate.** XNU's
   asynchronous data_request lets the kernel serve other faults while
   waiting for the pager. FreeBSD's synchronous model blocks the
   faulting thread. For CPU faults on GPU memory, this means the
   thread stalls during VRAM-to-RAM copy. This is acceptable for
   occasional CPU access but would be a bottleneck if CPU faults are
   frequent. The mitigation is to pre-populate pages when possible and
   minimize CPU faults on VRAM-backed memory.
