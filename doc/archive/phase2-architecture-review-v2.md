# Phase 2 Architecture Review v2

Date: 2026-04-18
Reviewer: Claude (wip-claude)

This is a foundation review of a revised Phase 2 proposal. I am treating
it as architecture, not code, and I will be direct about where I think
the formulation is still wrong.

## 1. Overall Verdict

This revision is a significant improvement over the earlier formulations.
The seven-pillar decomposition (memory_object, EMMI, GPU VM, native sync,
queue resources, doorbells, Linux adapters) is much closer to correct
than the previous memory_object-centric or buffer-object-centric
framings. You have correctly identified that GPU VM, sync, and queue
resources must be first-class peers, not afterthoughts.

But the formulation still has three problems:

**Problem 1: The center of gravity is wrong.** You are still putting
`memory_object` at the conceptual center. It should not be the center.
The correct center of gravity is **GPU VM** — the per-process GPU address
space. Here's why: every real operation in both AMD and Intel user-queue
models starts from a GPU virtual address, not from a memory object.
Submissions reference GPU VAs. Page faults arrive as GPU VAs. Eviction
invalidates GPU VA ranges. Doorbells are mapped at GPU VAs (or MMIO
offsets that the GPU VM manages). `memory_object` is the thing that
*backs* a GPU VA range, but the VA range is what the hardware and the
driver actually operate on.

Making `memory_object` the center will produce a system where every GPU
operation requires a lookup from memory object to GPU VA binding — the
inverse of what the hardware does. Making GPU VM the center produces a
system where you look up the backing memory from the faulting VA — which
is exactly what page fault handlers, eviction, and binding operations
actually do.

**Problem 2: EMMI is not a useful abstraction boundary.** The term
"EMMI" (External Memory Management Interface) comes from the original
Mach design where an external pager communicates with the kernel via
messages. You are trying to repurpose it as "the verb layer" for
populate/migrate/evict/synchronize/revoke. But these operations don't
form a coherent single interface:

- `populate` and `evict` are pager operations (supply/reclaim pages)
- `migrate` is a data-movement operation (copy pages between memory
  domains — system RAM, VRAM, peer VRAM)
- `synchronize` is a cache coherency operation
- `revoke` is an access-control operation (remove a device's mapping)

Bundling these under "EMMI" will create a god-interface that every
memory object implementation must provide. In practice, a system-RAM-
backed buffer doesn't migrate. A VRAM-only buffer doesn't get populated
from a pager. A display scan-out buffer needs synchronize but not
migrate. The correct design is to have these as separate optional
capabilities on the memory object, not a single protocol.

**Problem 3: The noun/verb split hides a lifetime dependency.**
You say `memory_object` = noun, EMMI = verb. But the real lifetime
dependency is: **GPU VA binding → memory object → physical pages →
device mapping**. The verbs (populate, evict, migrate) operate on
different edges of this chain:

- `populate`: pages → memory object (pager supplies pages)
- `evict`: memory object → pages (pager reclaims pages)
- `migrate`: pages → pages (cross-domain copy)
- `bind`: memory object → GPU VA (create GPU page table entry)
- `revoke`: GPU VA → memory object (tear down GPU page table entry)

These verbs belong to different objects. `populate`/`evict` belong to
the pager. `migrate` belongs to the memory domain manager. `bind`/
`revoke` belong to the GPU VM. Putting them all in one "EMMI" interface
forces every memory object to implement operations that belong to other
objects.

## 2. What the Current Evidence Proves / Does Not Prove

### Proves (from Phase 1)

1. The Mach IPC substrate works for control-plane messaging, including
   complex body descriptors and OOL data, under WITNESS.
2. The fd-bridge model is viable for IPC port names.
3. The characterization methodology (provenance-safe, debug-kernel,
   baseline-return) produces reliable evidence.

### Does Not Prove

1. Any Mach VM trap works (`mach_vm_allocate`, `mach_vm_map`, etc.)
2. Any `memory_object` or pager interface works.
3. Cross-task IPC works (still same-process only).
4. The fd bridge extends to VM-typed objects.
5. FreeBSD's `vm_object` / `pagerops` can host GPU memory.
6. Any DMA/IOMMU/bus_dma integration works.
7. Any fence or synchronization primitive works.
8. Any GPU hardware interaction works through native paths.

The gap between "IPC works" and "GPU memory subsystem works" is
enormous. Phase 1 evidence reduces risk for the control plane, but
Phase 2 starts essentially from zero on the data plane.

## 3. Is the Revised Phase 2 Formulation Actually Correct?

### The seven pillars are the right pillars

Yes, these are the right things to build:

1. Memory objects — yes, you need a shareable backing store
2. Pager/migration operations — yes, but not as "EMMI"
3. GPU VM — yes, and this should be the center
4. Native sync — yes, this is load-bearing
5. Queue resources — yes, these are not ordinary memory
6. Doorbells — yes, these are not ordinary memory
7. Linux adapters — yes, at the edge

### The center of gravity should be GPU VM, not memory_object

Here is the real object dependency graph for both AMD and Intel:

```
GPU VM (per-process address space)
  ├── VA range bindings
  │     ├── memory_object (backing store)
  │     │     ├── pages (resident in system RAM or VRAM)
  │     │     └── pager (supplies/reclaims pages)
  │     ├── device mapping (IOMMU/GART/GPUVM page table entry)
  │     └── reservation (fence tracking for this binding)
  ├── queue resources (special VA ranges with queue semantics)
  │     ├── ring buffer BO
  │     ├── wptr BO
  │     └── context state BO
  └── doorbell mappings (MMIO BAR, not ordinary memory)
```

The GPU VM is the root. Everything else hangs off it. When AMD MES
schedules a user queue, it looks up the queue's context via GPU VA.
When Xe handles a page fault, it looks up the faulting GPU VA in the
VM's range tree. When eviction happens, it walks the GPU VM's bindings
to invalidate page table entries.

If you make `memory_object` the center, you invert this tree and force
every GPU VA lookup to go through the memory object. That's backwards.

### The correct reformulation

**Phase 2: Native GPU Subsystem**

Center: GPU VM (per-process GPU address space)

Pillars:
1. **GPU VM** — per-process address space, VA ranges, bind/unbind,
   fault handling, invalidation
2. **memory_object** — shareable backing store with pluggable pager
3. **native fence** — signal, wait, compose, convert; timeline and
   one-shot variants
4. **reservation** — per-object shared/exclusive fence tracking
5. **queue descriptor** — queue BO, ring state, wptr, scheduling
   metadata (NOT ordinary memory)
6. **doorbell** — MMIO/BAR resource with its own lifecycle
7. **Linux adapters** — dma-buf, dma-resv, dma-fence, syncobj, GEM/TTM
   transition layers

Pager operations (populate, evict) are methods on the memory_object's
pager, not a separate subsystem. Migration is a service that operates
on memory objects. Revocation and invalidation are operations on GPU VM
bindings.

## 4. The Most Important Changes to Make Now

### Change 1: Redefine the center as GPU VM

The GPU VM object should be the first thing designed and the first thing
implemented. It defines:
- How VA ranges are tracked (interval tree, like `drm_gpuvm`)
- How bindings reference memory objects
- How page faults are resolved
- How eviction-driven invalidation propagates
- How queue and doorbell resources are mapped

Memory objects are *bound into* the GPU VM. They do not contain the
GPU VM. This is the same relationship as FreeBSD `vm_object` to `vm_map`
— the map manages address ranges, the objects provide backing.

### Change 2: Kill "EMMI" as a named subsystem

Replace it with:
- **Pager ops** on the memory object (populate, evict, synchronize)
- **Migration service** as a standalone module (copy pages between
  memory domains, with fence dependencies)
- **Invalidation callbacks** on GPU VM bindings (revoke device access
  when pages move)

These three things have different callers, different locking, and
different lifetime constraints. Bundling them under one name will
create a confused interface.

### Change 3: Design the fence model with user queues as the primary consumer

The fence model from the previous review was correct (fence before
memory objects), but now I want to be more specific about what the
fence substrate must support, based on the actual consumer code:

From `amdgpu_userq_fence.h`:
- A `fence_driver` per queue with a GPU-visible `u64 *cpu_addr`
  (mapped into GART for MES to write)
- Fence completion is detected by reading the GPU-written sequence
  number (`le64_to_cpu(*fence_drv->cpu_addr)`)
- Each fence has a timeline context (`fence_drv->context`)

From Xe SVM:
- Fences are used as migration dependencies
- TLB invalidation is fence-protected
- Page fault resolution creates implicit fences

The native fence substrate must support:
1. **GPU-written completion** — a fence whose signal is detected by
   polling a GPU-written memory location (not an IRQ)
2. **Timeline semantics** — monotonically increasing sequence number
   per queue, with "wait for sequence N" as the primitive
3. **CPU-waitable** — blocking wait with timeout
4. **Composable** — fence arrays (wait for all) and fence chains
   (dependency chains)
5. **dma-fence convertible** — bidirectional adapter to Linux dma-fence
6. **IRQ-context signalable** — for hardware interrupt completion paths

### Change 4: Treat queue descriptors as a distinct resource type from day one

Looking at `mes_userqueue.c`:
- A user queue needs: process context BO, gang context BO, wptr BO,
  ring buffer BO — all mapped into GART for MES access
- The wptr BO is looked up via GPU VA (`amdgpu_vm_bo_lookup_mapping`)
- These BOs have special lifetime rules (they must outlive the queue,
  they must be GART-mapped even if the process's regular memory isn't)

If you model these as ordinary memory objects, you lose the ability to
enforce their special lifetime and mapping rules. A queue descriptor
should be a first-class object that *contains* memory objects for its
backing, not a memory object with queue metadata attached.

### Change 5: Decide the SVM strategy explicitly

Xe SVM (`drm_gpusvm`) represents a different paradigm than explicit
buffer management:
- CPU virtual addresses are GPU-accessible via shared page tables
- MMU notifiers track CPU page table changes
- Migration moves pages between system RAM and VRAM transparently
- `drm_pagemap` manages device-private pages

Your native GPU VM must decide: does it support SVM (transparent
CPU/GPU address sharing), or only explicit bind/unbind (Vulkan
VM_BIND style), or both?

I recommend **explicit bind first, SVM later**:
- Explicit bind is simpler and covers the common case
- SVM requires MMU notifier integration (Linux-specific, needs FreeBSD
  equivalent)
- SVM requires device_private pages (Linux `ZONE_DEVICE`, no FreeBSD
  equivalent yet)
- AMD user queues work with explicit VM bind, not SVM
- Xe direct submission also uses explicit VM_BIND

SVM support should be a Phase 3 concern, not Phase 2.

## 5. How This Should Change Phase 1 Priorities

### Highest priority (directly reduces Phase 2 risk)

1. **Cross-task `mach_msg`.** Still the single most important remaining
   Phase 1 task. GPU memory management requires cross-process
   communication (at minimum for buffer sharing). If cross-task IPC
   doesn't work, the native subsystem's sharing model changes
   fundamentally.

2. **`mach_vm_allocate` / `mach_vm_deallocate` probe.** Test whether
   the donor lane's Mach VM traps work at all. If they panic, Phase 2's
   VM integration starts from a much harder position. This is a few
   hours of probe work with massive risk-reduction value.

3. **FreeBSD `vm_object` / `pagerops` / `cdev_pager_ops` study.** This
   is research, not code. Read and document how FreeBSD's custom pager
   interface works, how `mgtdevicepagerops` differs from
   `devicepagerops`, and where a GPU-oriented pager would plug in.
   This directly informs the memory_object design.

### Medium priority (useful context)

4. **FreeBSD IOMMU / `bus_dma(9)` study.** Understand the current
   FreeBSD DMA mapping infrastructure. This informs the device mapping
   layer but doesn't block early Phase 2 milestones.

5. **FreeBSD DRM `drm_gpuvm` integration study.** The local `drm-kmod`
   tree has `drm_gpuvm.c`. Understanding how it currently integrates
   with FreeBSD VM informs the GPU VM design.

### Should stop or deprioritize

6. **More same-process `mach_msg` variants.** Proven. Move on.

7. **Supported-lane governance widening (R14-R15).** Not risk-reducing
   for Phase 2. Can happen in parallel if someone else does it.

8. **`swtch` investigation.** Still orthogonal.

9. **R3 commit normalization.** Useful for hygiene but doesn't reduce
   Phase 2 technical risk.

## 6. The Biggest Mistakes to Avoid

### Ranked

1. **Making `memory_object` the center instead of GPU VM.** This is
   the most important thing in this review. The hardware thinks in GPU
   virtual addresses. The drivers think in GPU virtual addresses. The
   submissions reference GPU virtual addresses. If your subsystem is
   centered on memory objects and requires a lookup to find the GPU VA,
   every fast path is backwards. Center on GPU VM.

2. **Building "EMMI" as a single protocol.** The operations you want
   (populate, evict, migrate, synchronize, revoke) belong to different
   objects with different callers and different locking. A unified EMMI
   interface will become a god-object that every memory object must
   implement even when half the operations are inapplicable.

3. **Designing the fence model after the memory model.** Fences
   constrain everything. Eviction depends on fences. Binding depends on
   fences. Queue scheduling depends on fences. Migration depends on
   fences. If you design memory objects first, you'll discover fence-
   driven lifetime requirements and have to redesign. Design fences
   first.

4. **Trying to abstract AMD and Intel GPU VM differences too early.**
   AMD GPUVM uses multi-level page tables managed by the driver with
   VMID assignment. Intel Xe uses PPGTT with GuC-managed GGTT and
   different invalidation. The native GPU VM should define the
   *interface* (bind, unbind, fault, invalidate) and let each driver
   provide the page-table-management *implementation*. Do not try to
   share page table code between AMD and Intel — only share the binding/
   range-tracking/fault-dispatch layer.

5. **Treating doorbells as ordinary MMIO mappings.** Doorbells have
   special properties: they are per-queue, they have security
   implications (a process should only ring its own doorbells), they
   need to survive process address space changes, and they interact
   with power management (doorbell ring may wake a sleeping engine).
   If you model them as ordinary memory mappings, you lose the ability
   to enforce per-queue access control and power-management integration.

6. **Trying to retire TTM in Phase 2.** TTM is load-bearing for amdgpu.
   Every `amdgpu_bo` is a `ttm_buffer_object`. TTM manages VRAM
   placement, eviction ordering, and swap. The native subsystem should
   sit *under* TTM as its backing/mapping layer, not replace TTM. TTM
   retirement is Phase 4+ at the earliest.

7. **Over-centralizing vendor-specific scheduling.** AMD MES and Intel
   GuC have fundamentally different scheduling models. MES uses a
   microcontroller that directly schedules user queues. GuC uses
   firmware-mediated scheduling with different queue priority models.
   The native subsystem should own queue *resource management* (allocate
   queue BOs, map doorbells, track queue lifetime) but not queue
   *scheduling policy* (which engine, what priority, preemption
   decisions). Scheduling policy stays in the driver.

8. **Not modeling the binding object explicitly.** A GPU VA binding
   (the association of a VA range with a memory object in a specific
   GPU VM) is a first-class object with its own lifetime, its own fence
   dependencies, and its own invalidation state. If you don't model it
   explicitly, you'll discover the need for it when implementing
   eviction (which must walk all bindings of a memory object to
   invalidate page table entries) and fault recovery (which must rebind
   a VA range after pages are re-populated).

9. **Using message-based pager protocol for fault handling.** Still the
   same advice as the previous review. In-kernel callbacks, not Mach
   messages, for the data plane. Mach IPC is for control plane only.

10. **Designing for SVM before explicit bind works.** SVM requires
    MMU notifiers, device_private pages, and transparent migration —
    none of which have FreeBSD equivalents yet. Explicit bind (Vulkan
    VM_BIND style) covers both AMD user queues and Xe direct submission
    and should be the Phase 2 target.

## 7. Recommended Milestone Sequence

**M0: Object Model and Interface Specification** (design only)

- GPU VM interface: bind, unbind, fault, invalidate
- Memory object interface: create, destroy, pager ops (populate/evict)
- Binding object: VA range + memory object ref + fence deps
- Fence interface: create, signal, wait, compose, convert
- Reservation interface: shared/exclusive tracking
- Queue descriptor interface: allocate, map, destroy
- Doorbell interface: allocate, map, destroy
- Lifetime rules: what outlives what, who refs whom
- Decision record: in-kernel pager callbacks, no message-based pager
- Decision record: explicit bind first, SVM deferred
- Decision record: GPU VM is the center, not memory_object

Exit gate: a design document that is internally consistent and has been
reviewed against both AMD userq and Xe direct-submission consumer shapes.

**M1: Native Fence Substrate**

- Fence object: one-shot and timeline variants
- Signal from IRQ and thread context
- Wait from thread context with timeout
- Fence arrays and fence chains
- GPU-written completion detection (poll GPU-visible memory location)
- `dma-fence` bidirectional adapter
- Software-only test harness (no GPU hardware needed)

Exit gate: fences can be created, signaled, waited on, composed, and
round-tripped through `dma-fence` conversion.

**M2: GPU VM Core**

- Per-process GPU address space object
- VA range tracking (interval tree)
- Bind/unbind operations (associate VA range with backing)
- Invalidation callbacks (notify bindings when backing changes)
- Fault dispatch (lookup VA, call pager, install mapping)
- No hardware page tables yet — this is the abstract binding layer
- Test harness: bind, unbind, fault, invalidate sequences

Exit gate: GPU VM can track bindings, dispatch faults, and propagate
invalidation, all without hardware.

**M3: Memory Object and Pager**

- Memory object: page tracking, residency state, refcounting
- Pager callback interface: populate, evict, synchronize
- Anonymous pager (swap-backed system RAM)
- VRAM pager (device-local memory, initially stub)
- FreeBSD `vm_object` integration for CPU mapping
- Test harness: allocate, populate, evict, map CPU, destroy

Exit gate: memory objects work with pager callbacks, integrate with
FreeBSD `vm_object` for CPU access, and survive WITNESS.

**M4: Reservation and Implicit Sync**

- Reservation object: per-memory-object fence tracking
- Shared (read) and exclusive (write) fence slots
- Integration with bindings (eviction waits on reservation fences)
- `dma-resv` adapter
- Test harness: concurrent readers, exclusive writer, eviction wait

Exit gate: reservations correctly serialize access and the `dma-resv`
adapter is functional.

**M5: Device Mapping**

- Integration with FreeBSD `bus_dma(9)` / IOMMU
- Scatter/gather list generation from memory object pages
- GART-style and IOMMU-style mapping support
- Mapping revocation (invalidate + flush + release)
- Test harness: map, DMA, revoke, verify no stale entries

Exit gate: pages from a memory object can be mapped for device DMA
and revoked cleanly.

**M6: Queue and Doorbell Resources**

- Queue descriptor object (owns ring BO, wptr BO, context BO)
- Queue resource lifetime rules (outlives submissions, cleaned on
  process exit)
- GART mapping for queue BOs (MES/GuC need kernel-accessible addresses)
- Doorbell object (MMIO BAR allocation, per-process access control)
- Test harness: allocate queue, map doorbells, tear down

Exit gate: queue and doorbell resources can be allocated, mapped, and
torn down with correct lifetime.

**M7: Linux Adapter Layer**

- `dma-buf` export/import (memory_object ↔ dma-buf)
- `syncobj` adapter (native timeline fence ↔ syncobj)
- GEM handle integration
- Test harness: export native, import as dma-buf, and vice versa

Exit gate: cross-subsystem sharing works through adapters.

**M8: TTM Integration**

- TTM backend using native memory objects for page storage
- TTM resource placement still managed by TTM
- TTM eviction triggers native invalidation callbacks
- amdgpu_bo works through TTM backed by native substrate

Exit gate: basic amdgpu buffer allocation works through the native
stack via TTM.

**M9: Migration Service**

- Cross-domain page copy (system RAM ↔ VRAM)
- Fence-protected migration (wait for outstanding access before move)
- Post-migration rebind (update GPU page tables after move)
- Not SVM — explicit migration only

Exit gate: a memory object's pages can be migrated between system RAM
and VRAM with correct fence synchronization and GPU page table updates.

**M10: First Real Consumer**

- amdgpu modeset through native memory path
- Basic GPU submission with native queue/doorbell resources
- Display scan-out with native memory objects

Exit gate: a basic amdgpu desktop works with the native substrate.

### Why this order

- M0 first: catch design errors before any code
- M1 (fences) before M2 (GPU VM): bindings need fences for eviction
- M2 (GPU VM) before M3 (memory objects): the center must exist before
  what hangs off it
- M3 (memory objects) after M2: memory objects are bound *into* the
  GPU VM
- M4 (reservation) after M3: reservation is per-memory-object
- M5 (device mapping) after M3: mapping operates on memory object pages
- M6 (queue/doorbell) after M2+M5: queues need GPU VM bindings and
  device mappings
- M7 (adapters) after M3+M4: adapters wrap native objects
- M8 (TTM integration) after M7: TTM is the practical bridge
- M9 (migration) after M5+M8: migration needs device mapping and TTM
- M10 (consumer) last: validates the whole stack

## 8. Open Assumptions That Must Be Verified

1. **Can FreeBSD support GPU-private page tables without ZONE_DEVICE?**
   Linux uses `ZONE_DEVICE` with `dev_pagemap` for VRAM-resident pages.
   FreeBSD has no equivalent. The native subsystem must either:
   (a) implement a FreeBSD equivalent of device-private pages, or
   (b) manage VRAM pages without integrating them into the FreeBSD VM
   page tracking. Option (b) is simpler but means VRAM-resident memory
   can't be CPU-faulted transparently.

2. **Does FreeBSD have MMU notifier equivalents?** SVM requires
   notification when CPU page tables change. Linux has
   `mmu_interval_notifier`. FreeBSD has no direct equivalent. This is
   one reason SVM should be deferred to Phase 3+. For Phase 2, explicit
   bind/unbind is sufficient.

3. **Can AMD MES actually run on FreeBSD?** MES firmware loading,
   ring buffer setup, and scheduling API may have Linux-specific
   dependencies. Verify that MES brings up on FreeBSD before designing
   the queue resource model around it.

4. **What is the FreeBSD IOMMU capability for GPU?** FreeBSD has
   AMD-Vi and Intel VT-d support in `sys/x86/iommu/`. Verify:
   - GPU devices can be mapped through the system IOMMU
   - Mapping granularity supports GPU page sizes
   - TLB invalidation is available per-device
   - Multiple IOMMU domains (for per-process GPU address spaces) work

5. **Does `mach_vm_allocate` work in the donor lane?** This has never
   been tested. A panic here means the Mach VM → FreeBSD VM integration
   is broken and Phase 2's pager story starts from a harder position.

6. **What FreeBSD GPU memory infrastructure already exists?** The
   `drm-kmod` port already has some FreeBSD-specific adaptations for
   `vm_object`, `bus_dma`, and possibly `cdev_pager_ops`. Understanding
   what exists avoids re-inventing it.

7. **Is the "IOKit-like system integration" goal realistic without
   IOKit?** IOKit provides object lifecycle, registry, matching, power
   management, and interrupt dispatch in a single framework. Your native
   subsystem provides *memory and sync* primitives, not a full driver
   framework. The IOKit analogy is useful for motivation but misleading
   for scope. The native subsystem should be more like a "GPU memory
   services library" that drivers call into, not a framework that
   drivers derive from.

8. **Does the project need to support multi-GPU?** Multi-GPU (peer-to-
   peer DMA, cross-device buffer sharing) significantly complicates the
   memory object and device mapping model. If single-GPU is sufficient
   for Phase 2, say so explicitly and defer multi-GPU to Phase 3.

9. **What is the actual GFX IP version target?** "RDNA3+" means GFX11+.
   GFX11 (RDNA3) and GFX12 (RDNA4) have different MES versions,
   different fault models, and different GPUVM capabilities. Pin the
   minimum GFX IP version explicitly.

10. **Is Xe on FreeBSD realistic for Phase 2?** FreeBSD Foundation issue
    #111 was opened March 2026. Xe is a large driver. It may not be
    functional on FreeBSD within Phase 2's timeframe. If so, Intel
    support is Phase 3, and AMD is the only Phase 2 consumer. That's
    fine — but it should be an explicit decision, not a surprise.

## Summary of Key Opinions

1. **Center on GPU VM, not memory_object.** This is the single most
   important architectural decision. The hardware and drivers think in
   GPU virtual addresses. The native subsystem should too.

2. **Kill EMMI as a named subsystem.** Distribute its operations to the
   objects that own them: pager ops on memory objects, migration as a
   service, invalidation on GPU VM bindings.

3. **Design fences first, then GPU VM, then memory objects.** This is
   counterintuitive but correct. Fences constrain lifetimes. GPU VM
   defines the center. Memory objects fill it.

4. **Queue descriptors and doorbells are correctly identified as
   non-memory resources.** Keep them as first-class objects. Don't let
   them collapse back into "just another BO."

5. **Explicit bind first, SVM deferred.** Both target hardware
   (AMD RDNA3+ user queues, Intel Xe direct submission) work with
   explicit bind. SVM needs FreeBSD infrastructure that doesn't exist
   yet.

6. **TTM stays.** It's the practical integration point for amdgpu. The
   native substrate sits under it, not in place of it.

7. **The "IOKit-like" aspiration is correct in spirit but should not
   produce a framework.** Produce a services library, not a driver
   framework. Drivers call into your memory/sync/mapping services.
   They don't derive from your base classes.

8. **AMD-only for Phase 2 is probably the honest answer.** Intel Xe
   on FreeBSD is aspirational for Phase 2. Design the interfaces to
   be vendor-neutral, but only validate with AMD hardware.

9. **For Phase 1 right now: cross-task `mach_msg`, then
   `mach_vm_allocate` probe, then FreeBSD pager study.** Everything
   else is lower priority.
