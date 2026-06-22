# Phase 2 Architecture Review

Date: 2026-04-18
Reviewer: Claude (wip-claude)

This is a foundation review. I am treating this as architecture, not code.
I will be opinionated.

## 1. Overall Verdict

The Phase 2 decomposition is **conceptually sound but missing one critical
layer.** The three-layer model (memory_object / IOMemoryDescriptor-like /
IODMACommand-like) is the right skeleton. But the proposal as stated
conflates two separate problems that must be designed independently:

1. **The backing store problem** — what is the kernel-canonical object
   that holds pages, tracks residency, and mediates VM faults?
2. **The device attachment problem** — how does a GPU (or other DMA
   device) bind to a region of that backing store, with its own address
   space, its own mapping lifetime, and its own cache/coherency policy?

XNU separates these cleanly. Linux conflates them (the `dma-buf` is
simultaneously the sharing handle, the backing store reference, and the
attachment point). Your proposal names the right XNU concepts but does
not yet have an explicit design for the **attachment** object — the thing
that sits between a memory descriptor and a DMA mapping and represents
"this device is using this memory right now."

The other structural risk is that the proposal says "memory_object becomes
the VM/shared-memory substrate" without specifying which `memory_object`
semantics you actually need. XNU's `memory_object` is a full external
pager protocol with 12+ upcalls. You almost certainly do not want the
full protocol. You want a much thinner pager contract that implements
maybe 4-5 of those operations. Getting this wrong will either lock you
into an over-complicated pager lifecycle or force you to redesign the
pager integration later.

The sequencing (native substrate first, Linux replacement second) and the
vendor strategy (AMD-first, vendor-neutral core) are both correct.

## 2. What the Current Evidence Actually Proves / Does Not Prove

### Proves

1. **The Mach IPC substrate is real.** Phase 1 has moved from "can the
   module load" to "can same-process complex messages with body-carried
   port rights and OOL data round-trip cleanly under WITNESS." This is
   genuine control-plane evidence.

2. **The fd bridge model works for IPC.** The fd-backed port name design
   has survived lifecycle, contention, message copyin/copyout, and body
   descriptor paths without a structural failure. The bugs found were all
   fixable lock-order issues, not design failures.

3. **The project's characterization methodology works.** Clean committed
   HEAD, MACHDEBUGDEBUG, provenance-safe harness, per-port observability,
   baseline-return verification — this is a mature evidence pipeline.

### Does Not Prove

1. **That the Mach VM substrate is usable.** No `vm_map` operation, no
   `mach_vm_*` trap, no `memory_object` pager interaction has been tested.
   The entire VM side of the donor import is uncharacterized.

2. **That the fd bridge model extends to VM objects.** IPC port names as
   fds is proven. But `memory_object` ports as fds, or `vm_map` handles
   as fds, are structurally different problems. The bridge may need
   different integration for VM-typed objects.

3. **That the FreeBSD `vm_object` / `pagerops` interface can host a
   Mach-style external pager.** FreeBSD's `struct pagerops` has a
   different shape than XNU's `memory_object_pager_ops`. FreeBSD pagers
   are synchronous (getpages/putpages return page arrays). XNU pagers
   are asynchronous (data_request/data_return are upcalls via Mach
   messages). This is a fundamental design tension that Phase 2 must
   resolve.

4. **That cross-task IPC works.** This is relevant because the
   memory_object pager protocol is inherently cross-task — the pager is a
   separate Mach task that receives data requests via messages. If cross-
   task messaging doesn't work, the external pager model cannot work.

5. **Anything about DMA, IOMMU, or device memory integration.** This is
   expected — Phase 1 is IPC, not VM. But it means Phase 2 starts from
   zero on the hardest problems.

## 3. Is Phase 2 Conceptually Sound, or Is There a Better Formulation?

### The decomposition needs one more layer

Your current layers:

```
1. memory_object          (VM/pager)
2. IOMemoryDescriptor     (driver memory)
3. IODMACommand           (DMA mapping)
4. dma-buf adapters       (Linux compat)
```

The missing layer:

```
1. memory_object          (VM/pager — backing store)
2. device_attachment      (device's claim on a memory region)
3. memory_descriptor      (driver-facing scatter/gather description)
4. dma_mapping            (bus-address mapping via IOMMU)
5. dma-buf / fence        (Linux compat export surface)
```

Why `device_attachment` is load-bearing:

In Linux, `dma_buf_attachment` serves this role but it's welded to
`dma-buf`. In XNU, `IOMemoryDescriptor::prepare()` implicitly creates a
device attachment. In your system, this needs to be an explicit first-class
object because:

- A single memory object may be attached to multiple devices simultaneously
  (GPU + display controller, GPU + GPU for peer-to-peer)
- Each attachment has its own lifetime, its own mapping requirements, and
  its own coherency policy
- Attachment creation is where you enforce access policy, IOMMU mapping,
  and cache mode
- Attachment teardown is where you revoke device access — critical for
  GPU preemption, fault recovery, and VM bind invalidation
- The `dma-resv` / reservation object is per-memory-object, but the
  fence state is per-attachment-direction (shared read vs exclusive write)

If you collapse attachment into the descriptor, you lose the ability to
have multiple devices with independent mapping lifetimes on the same
backing store. If you collapse it into the memory object, you lose the
ability to have device-specific cache/mapping policy.

### The pager model needs to be explicitly limited

XNU's `memory_object_pager_ops` has these operations:

```
reference, deallocate, init, terminate,
data_request, data_return, data_initialize, data_unlock,
synchronize, map, last_unmap, data_reclaim
```

For GPU memory, you need at most:

- `data_request` — supply pages when the VM faults in
- `data_return` — accept pages being evicted
- `synchronize` — flush dirty state
- `map` / `last_unmap` — track mapping state for coherency

You do NOT need:
- `data_initialize` (obsolete)
- `data_unlock` (XNU-specific lock negotiation)
- `data_reclaim` (Apple memory compression)

And critically: you should NOT use the XNU model where the pager is a
separate Mach task communicating via messages. That model is elegant in
theory but creates catastrophic latency for GPU page faults. The pager
must be an in-kernel callback interface, like FreeBSD's `struct pagerops`,
but with the Mach-style asynchronous data_request/data_return semantics
instead of FreeBSD's synchronous getpages/putpages.

### Proposed reformulation

**Phase 2: Native GPU Memory Substrate**

Core object model:
1. `nxmem_object` — kernel backing store with pager callbacks
2. `nxmem_attachment` — per-device claim on a memory object
3. `nxmem_descriptor` — scatter/gather page list for a memory region
4. `nxmem_mapping` — bus-address mapping via IOMMU
5. `nxmem_reservation` — shared/exclusive fence tracking per object

Export surfaces:
- `dma-buf` adapter (wraps nxmem_object for Linux DRM export/import)
- `dma-resv` adapter (wraps nxmem_reservation)
- `dma-fence` adapter (wraps native fence objects)

The "nx" prefix is a placeholder. The point is: these are new kernel
objects, not wrappers around XNU objects and not wrappers around Linux
objects. They are informed by both but owned by neither.

## 4. Most Important Changes to the Phase 2 Design Now

### Change 1: Add the attachment layer explicitly

Without it, you will rediscover the need for it when implementing
multi-device sharing, and then retrofit it painfully. Every real GPU
memory system has this concept:

- Linux: `dma_buf_attachment`
- XNU: `IOMemoryDescriptor::prepare()` (implicit)
- Vulkan: `VkDeviceMemory` bind to a `VkBuffer`/`VkImage`
- AMD: `amdgpu_bo_va` (GPU virtual address mapping of a BO)

### Change 2: Do NOT use message-based pager protocol

The XNU `memory_object` protocol routes page faults through Mach messages
to an external pager task. This is architecturally beautiful but operationally
wrong for GPU:

- GPU page faults need microsecond-scale response
- Cross-task message delivery adds scheduling latency
- The GPU fault handler runs in interrupt context on some hardware
- The FreeBSD VM's fault path (`vm_fault`) is synchronous — it expects
  the pager to return pages, not to send a message and wait

Use an in-kernel pager ops table, like FreeBSD's `struct pagerops`, but:
- Add an async data_request variant for prefetch/speculative population
- Add explicit dirty tracking for GPU-modified pages
- Add a `revoke` callback for device-initiated invalidation

### Change 3: Design the reservation/fence model before the memory model

This is counterintuitive but critical. The fence/reservation model
constrains the memory model, not the other way around:

- Whether a memory object can be moved (evicted) depends on what fences
  are outstanding
- Whether a mapping can be torn down depends on what submissions reference it
- Whether a CPU mapping can be established depends on GPU cache flush state
- User-queue fences (AMD MES signaling, Intel GuC completion) need to be
  representable as native fence objects

If you design the memory object and descriptor first, you will discover
that the fence model forces changes to their lifetimes. Design the fence
model first, at least at the interface level, so the memory objects know
what lifetime constraints they must honor.

### Change 4: Decide the `vm_object` relationship early

FreeBSD GPU memory currently works like this:

```
amdgpu_bo → ttm_buffer_object → (ttm_tt → vm_object for swap)
                                  (ttm_resource → VRAM placement)
```

Your native model needs to decide: is `nxmem_object` a *wrapper around*
`vm_object`, a *replacement for* `vm_object` in the GPU path, or a
*peer* that holds its own page storage and interfaces with `vm_object`
only for CPU mapping?

I recommend **peer with interface**: `nxmem_object` owns page tracking
and residency state. When CPU mapping is needed, it creates or associates
a FreeBSD `vm_object` with appropriate pager ops. When only GPU mapping is
needed, no `vm_object` exists. This avoids polluting the FreeBSD VM with
GPU-specific semantics while still allowing CPU access when needed.

### Change 5: Define the IOMMU abstraction boundary

FreeBSD has `bus_dma(9)` and the newer IOMMU infrastructure (`iommu.h`).
AMD GPU uses both GART (GPU-side address translation) and system IOMMU
(if present). Intel uses GGTT/PPGTT plus system IOMMU.

Your `nxmem_mapping` must abstract over:
- No IOMMU (direct physical address, bus_dma bounce buffers)
- System IOMMU (DMAR/AMD-Vi page tables)
- GPU-private page tables (GART, PPGTT, AMD GPUVM)

The mapping object should express "this memory is accessible at these
bus addresses with these permissions and this cache policy." It should
NOT express which translation mechanism produced those addresses.

## 5. How Phase 2 Should Change Current Phase 1 Priorities

### Still worth doing

1. **Cross-task `mach_msg`.** The memory_object pager protocol, even in
   its simplified form, requires cross-task port transfer. If cross-task
   messaging can't work, the pager integration model changes
   fundamentally. This is the single highest-value remaining Phase 1
   task for Phase 2 readiness.

2. **`mach_vm_allocate` / `mach_vm_deallocate` characterization.** These
   are the first VM-touching traps. Even if Phase 2 doesn't use the full
   Mach VM model, understanding whether these traps work (and how they
   interact with FreeBSD's `vm_map`) is essential.

3. **Port-right lifetime through process exit.** GPU drivers must survive
   client process crashes. If port cleanup during exit is broken, GPU
   resource cleanup will be broken. The `mach_port_close` /
   `ipc_entry_list_close` path matters.

4. **OOL transfer correctness.** OOL `mach_msg` is the closest IPC
   analog to shared-memory semantics. Its `vm_map_copyin` /
   `vm_map_copyout` path is directly relevant to Phase 2's memory
   transfer model.

### Should stop or deprioritize

1. **More same-process message variants.** The same-process message path
   is proven. Additional header dispositions, descriptor combinations,
   or payload sizes add diminishing returns. Shift to cross-task.

2. **`swtch` investigation.** Still orthogonal. The scheduler-lock bug
   does not affect VM or memory object design.

3. **Supported-lane widening (R14-R15).** Promoting identity traps and
   port/right/space operations to the supported lane is governance work
   that doesn't reduce Phase 2 risk. It can happen in parallel but
   shouldn't consume the primary implementer's time.

### Should add now

1. **`vm_map` characterization probe.** Test whether `mach_vm_allocate`,
   `mach_vm_deallocate`, and `mach_vm_protect` work at all in the donor
   lane. This is the minimum viable VM probe. If these panic, Phase 2's
   pager integration has a much harder starting point.

2. **FreeBSD `vm_object` / pager audit.** Read and document the FreeBSD
   15 `struct pagerops` interface thoroughly. Identify which pager types
   exist, how they interact with fault handling, and where a new
   GPU-oriented pager would need to plug in. This is research, not code
   — but it's the most important Phase 2 preparation task.

3. **Cross-task message probe.** This is already on the roadmap but should
   be prioritized above further same-process message work. The Phase 2
   pager model depends on cross-task communication working.

## 6. The Biggest Mistakes to Avoid

### Ranked by severity

1. **Building the pager protocol around Mach messages.** This is the
   most attractive mistake because it's the most architecturally pure.
   XNU does it. It's elegant. It's also 100x too slow for GPU page faults.
   The pager must be an in-kernel callback interface. Use Mach IPC for
   control plane (allocate, configure, tear down) but never for the
   fault-response data plane.

2. **Exposing `vm_object` as the driver API.** FreeBSD's `vm_object` is
   deeply intertwined with the VM fault path, the page daemon, swap, and
   the buffer cache. GPU drivers should never hold a `vm_object` directly
   — they should hold a `nxmem_descriptor` that can produce a `vm_object`
   for CPU mapping when needed but does not require one for GPU-only
   memory.

3. **Designing around AMD's current GPUVM model as if it were
   universal.** AMD's current model is: TTM manages placement, GPUVM
   manages GPU page tables, `amdgpu_bo_va` tracks per-VM bindings. This
   is AMD-specific. Intel Xe has a different model (VM_BIND ioctl,
   persistent bindings, no implicit sync). The native substrate must
   support both "map on demand" (AMD current) and "map explicitly, use
   persistently" (Xe/Vulkan) models.

4. **Underestimating fence lifecycle.** Fences are the hardest part of
   the GPU memory model, not memory objects. A fence must be:
   - Signalable from GPU interrupt context
   - Waitable from CPU context (blocking and polling)
   - Composable (fence arrays, fence chains)
   - Convertible between native and Linux `dma-fence`
   - Usable as a dependency for GPU-side waits (user fences)
   - Reclaimable when no longer referenced

   If you get fence lifecycle wrong, everything built on top (eviction,
   preemption, implicit sync, user queues) will be broken in subtle ways
   that only manifest under load.

5. **Overfitting to XNU pager semantics.** The XNU `memory_object`
   protocol assumes a single default pager, control ports, memory_object
   ports, and a message-based lifecycle. FreeBSD has none of this
   infrastructure and building it all is not worth it. Take the
   *conceptual separation* (backing store vs. pager vs. control) but
   implement it as a C callback interface, not as a Mach port protocol.

6. **Trying to make TTM disappear immediately.** TTM is deeply embedded
   in amdgpu (every `amdgpu_bo` IS a `ttm_buffer_object`). The native
   substrate should be designed so TTM can be adapted to use it as its
   backing, not so TTM is ripped out. TTM → native adapter is the
   correct transitional shape. TTM may eventually disappear, but not in
   Phase 2.

7. **Mixing VM ownership and DMA mapping ownership.** A memory object
   may be mapped into a CPU address space AND a GPU address space AND a
   display controller's scan-out mapping simultaneously. These three
   mappings have independent lifetimes. If the CPU mapping is torn down,
   the GPU mapping must survive (and vice versa). The memory object
   outlives all of its mappings. If you collapse any of these lifetimes
   together, you will break multi-device sharing.

8. **Ignoring the revocation problem.** GPU preemption, VT-d live
   migration, and GPU fault recovery all require the ability to revoke a
   device's access to memory. This means: invalidate IOMMU mappings,
   flush GPU caches, ensure no in-flight DMA, then release the pages.
   If the memory object / attachment / mapping model doesn't support
   revocation as a first-class operation, you'll be unable to implement
   GPU reset recovery.

## 7. Recommended Milestone Sequence

### Phase 2 Milestone Plan

**M1: Object Model Specification** (architecture only, no code)

Deliverables:
- `nxmem_object` lifecycle and interface definition
- `nxmem_attachment` lifecycle and interface definition
- `nxmem_descriptor` interface definition
- `nxmem_mapping` interface definition
- `nxmem_reservation` / fence interface definition
- Explicit lifetime rules: what outlives what, who holds refs to whom
- Explicit decision: in-kernel pager ops (not message-based)

Exit gate: a design document that two reviewers agree is internally
consistent and does not collapse lifetimes that must be independent.

**M2: Fence Substrate**

Deliverables:
- Native fence object (`nxmem_fence`)
- Signal from interrupt context
- Wait from thread context (with timeout)
- Fence array / fence chain support
- `dma-fence` adapter (bidirectional conversion)
- Fence test harness (not GPU-dependent — use software signal)

Exit gate: native fences can be created, signaled, waited on, and
converted to/from `dma-fence` without involving any GPU hardware.

Why fences first: everything else depends on them. Eviction needs fences.
Mapping teardown needs fences. Preemption needs fences. If you build
memory objects first, you'll immediately need fences to make them useful,
and you'll design them under pressure.

**M3: Memory Object Core**

Deliverables:
- `nxmem_object` implementation (page tracking, residency state)
- In-kernel pager ops table
- Trivial anonymous pager (swap-backed, analogous to `default_pager`)
- Integration with FreeBSD `vm_object` for CPU mapping
- Test harness: allocate, fault, populate, evict, destroy

Exit gate: a memory object can be created, populated with pages, mapped
into a CPU address space via `vm_object`, and torn down — all with
correct refcounting and no leaks under WITNESS.

**M4: Reservation / Implicit Sync**

Deliverables:
- `nxmem_reservation` implementation (shared/exclusive fence tracking)
- `dma-resv` adapter
- Test harness: concurrent readers, exclusive writer, fence wait

Exit gate: reservation objects correctly serialize access and the
`dma-resv` adapter passes the existing DRM reservation tests.

**M5: Attachment and Descriptor**

Deliverables:
- `nxmem_attachment` implementation
- `nxmem_descriptor` implementation (scatter/gather list generation)
- Per-attachment cache policy
- Per-attachment mapping lifetime independent of object lifetime

Exit gate: a memory object can have multiple simultaneous attachments
with independent lifetimes.

**M6: DMA Mapping**

Deliverables:
- `nxmem_mapping` implementation
- Integration with FreeBSD `bus_dma(9)` / IOMMU
- GART/GPUVM-style mapping support
- Revocation support

Exit gate: a mapping can be created, used for DMA, and revoked without
leaking IOMMU entries.

**M7: dma-buf Export/Import Bridge**

Deliverables:
- `dma-buf` → `nxmem_object` import adapter
- `nxmem_object` → `dma-buf` export adapter
- GEM handle integration

Exit gate: a `dma-buf` exported by the Linux DRM layer can be imported
as a native memory object, and vice versa.

**M8: TTM Adapter**

Deliverables:
- TTM backend that uses `nxmem_object` for page storage instead of
  direct `vm_object` manipulation
- TTM resource placement still managed by TTM
- amdgpu_bo continues to work through TTM, but TTM's backing is native

Exit gate: amdgpu basic buffer allocation and mapping works through the
native substrate via TTM.

**M9: First Real Consumer**

Deliverables:
- amdgpu buffer allocation through native path
- Basic GPUVM mapping through native path
- Display scan-out through native path

Exit gate: a basic amdgpu modeset works with the native memory substrate.

### Why this order

- M1 before everything: catch design errors before code
- M2 (fences) before M3 (memory): fences constrain memory lifetimes
- M3 (memory) before M5 (attachment): the thing must exist before devices
  can claim it
- M4 (reservation) before M5: attachment creation needs reservation
  integration
- M6 (mapping) after M5: mapping is an operation on an attachment
- M7 (dma-buf bridge) after M6: export/import needs the full stack
- M8 (TTM adapter) after M7: TTM is the practical integration point
- M9 last: the consumer validates the whole stack

## 8. Open Assumptions That Need Explicit Verification

1. **Can a FreeBSD `vm_object` have a custom pager that handles GPU
   memory?** FreeBSD has `devicepagerops`, `mgtdevicepagerops`, and
   `sgpagerops` for device memory. The `cdev_pager_ops` interface in
   FreeBSD allows custom pagers. Verify that a custom pager can:
   - Allocate pages from a non-swap source (GPU VRAM or pinned system RAM)
   - Handle fault-in with device-specific cache policy
   - Handle eviction with GPU cache flush
   - Coexist with the page daemon's reclamation

2. **Does FreeBSD's IOMMU infrastructure support the needed operations?**
   FreeBSD has `sys/iommu.h` and the `iommu_map_page` / `iommu_unmap_page`
   interface. Verify that:
   - AMD-Vi / Intel VT-d page table management works for GPU
   - Mapping granularity supports GPU page sizes (4K, 64K, 2M)
   - Mapping updates can be batched (GPU drivers update thousands of
     mappings per frame)
   - TLB invalidation is available and efficient

3. **What is the actual fence signaling path in FreeBSD DRM?** The Linux
   `dma-fence` uses `dma_fence_signal()` callable from interrupt context
   via `tasklet`. FreeBSD's DRM linuxkpi provides `tasklet` emulation.
   Verify that the native fence substrate can signal from the same
   contexts without deadlock.

4. **Does AMD MES on FreeBSD actually work yet?** The MES code exists in
   the tree (`mes_v11_0.c`, `mes_v12_0.c`) but that doesn't mean it's
   functional. If MES doesn't work on FreeBSD, the user-queue path
   requires more bring-up work than anticipated. Verify MES firmware
   loading and basic scheduling.

5. **Can Mach `vm_map` operations coexist with FreeBSD `vm_map`?** The
   donor import has `mach_vm_allocate` and related traps. These
   presumably call into FreeBSD's `vm_map` underneath. Verify that the
   Mach VM trap → FreeBSD VM path doesn't have structural conflicts
   (different locking, different `vm_object` expectations, different
   page size assumptions).

6. **What is the Intel GPU situation on FreeBSD 15?** Your local tree has
   `i915` but not `xe`. Upstream FreeBSD drm-kmod has been tracking Linux
   kernel DRM. Determine:
   - Whether `xe` is expected in drm-kmod soon
   - Whether to plan for `i915` as the Intel baseline or wait for `xe`
   - Whether Intel Arc GPUs work at all under FreeBSD `i915`

7. **Is the `memory_object` port protocol even needed?** If you go with
   in-kernel pager callbacks (which I strongly recommend), the
   `memory_object` port-based protocol is only useful for userspace
   pagers (like a userspace GPU memory manager). Decide now whether
   userspace pagers are a goal. If not, the `memory_object` Mach port
   infrastructure is unnecessary for Phase 2 and the naming is
   misleading.

8. **What are the actual latency requirements for GPU page faults?** AMD
   RDNA3+ supports recoverable page faults (`amdgpu_vm_handle_fault`).
   Intel Xe also supports recoverable faults. The fault-to-resolution
   latency budget is typically 10-100 microseconds for foreground faults.
   Verify that your pager callback model can meet this budget. If the
   pager callback needs to allocate memory, do disk I/O, or take
   contended locks, it won't.

9. **Does the project need to support both AMD GFX10+ and GFX11+ or
   can it target GFX11+ only?** GFX10 (RDNA1/2) has a different MES
   and VM model than GFX11 (RDNA3). Narrowing to GFX11+ significantly
   simplifies the design (MES v11+, unified GPUVM, recoverable faults).
   The doc says "RDNA3+" which implies GFX11+, but verify this is
   intentional.

## Summary of Opinions

1. The three-layer model is right but needs a fourth layer (attachment).
2. Do NOT use message-based pager protocol. Use in-kernel callbacks.
3. Design fences before memory objects.
4. TTM should be adapted, not replaced.
5. AMD-first is correct. Intel can wait for `xe`.
6. The `vm_map` characterization probe should be added to Phase 1 now.
7. Cross-task `mach_msg` is the highest-value remaining Phase 1 work
   for Phase 2 readiness.
8. The biggest risk is not the memory model — it's the fence model.
   Fences are harder than memory objects, and if you get fences wrong
   everything built on top breaks in ways that only manifest under
   concurrent GPU workloads.
