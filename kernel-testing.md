# Kernel testing: making the loop faster

Status: proposal, 2026-10-03. Asked by the Coordinator ("is bhyve the right way for this rapid
kernel work? it seems very slow"). Nothing here is in force until the Coordinator decides; the
role change in § 4.2 needs that decision explicitly. Related: [instrumentation-strategy.md](instrumentation-strategy.md)
(what we run), [test-pillar-partition.md](test-pillar-partition.md) (which tests),
[doc/host-guest-isolation-incident-2026-07-11.md](doc/host-guest-isolation-incident-2026-07-11.md)
(why guests are contained).

## 1. Answer in short

bhyve is the right tool. It is FreeBSD's own hypervisor, a guest boots in seconds, and every run
is disposable. The slowness is the work around each run: full world builds, a full image per
change, and the Implementer finding its own test mistakes a whole relay round later. Keep bhyve
and containment; change the pipeline around them.

## 2. Where the time goes today

Measured on recent ops:

| Cost | Example | Size |
|---|---|---|
| Full world builds for kernel or small userland changes | op-436: about 10 of its 12 hours were world builds (with failures from an inherited build environment), then two more world builds; composing both images took about 6 minutes | hours per op |
| A full 8 GB image per change, with a BOM and a full readback | every Implementer staging op (op-416, op-420, op-430) | tens of minutes per image, plus harness work for each new filesystem |
| Test mistakes found one relay round late | op-434: 4 of 8 new cases failed during setup, before their checks; one quick boot by the Implementer would have caught it | one full round: Implementer → Gatekeeper → Arranger → Implementer |
| Harness faults found during guest runs | op-391, op-405 and op-438 used boots on collector faults | boots and ops |
| The guest run itself | op-434: two boots, each within its 5-minute cap | minutes |

The guest run is the smallest item. The relay is deliberate, but it multiplies every late
finding.

## 3. Principles

1. **Two loops with different jobs.** A fast, cheap loop catches our own mistakes. A slow,
   evidenced loop proves a batch. Today only the slow loop exists, so it also does the fast loop's job.
2. **Build only what changed.** Kernel work rebuilds the kernel, `mach.ko` and the tests, not world.
3. **Images are stable; payloads change.** A base image is built and verified once per line of
   work. What changes per iteration rides on a small, separately hashed payload.
4. **Containment stays as it is.** No network, no shared folders, and no passthrough, in both loops,
   using the same runner.
5. **Evidence where it decides something.** Hashes, BOMs and before/after tables belong to the proof
   of a batch, not to every iteration.

## 4. Proposal

### 4.1 Fixed base image plus a payload disk

- One base image per line of work (for example: the Mach line on the current candidate; the PID-1
  line on op-436's ZFS image). It is verified once, by hash and BOM.
- Per iteration, a **payload disk**: a small filesystem image built with `makefs` in seconds,
  holding the kernel, `mach.ko`, test binaries and a manifest of their hashes. bhyve attaches it as
  a second virtio disk.
- The guest uses the payload without network or shares. Two ways, to be settled in the runner op:
  (a) the loader reads the kernel and modules from the payload disk (bhyveload accepts more than
  one disk); or (b) a one-time rc hook in the base image installs the payload and reboots once.
  `bhyveload -h` (the loader reading a host directory) would be simplest, but it is a host share at
  boot time, so it needs a containment review first. Do not adopt it by default.
- The serial log records the payload manifest's hash, so each run is tied to exactly what it ran.

Effect: a new kernel iteration costs a kernel build (minutes, incremental) plus a payload (seconds),
not a world build and an 8 GB image.

### 4.2 An inner loop for the Implementer (needs a Coordinator decision)

- The Implementer may boot its own disposable guests through the same contained runner, on
  copies of the line's base image with its own payload, and run the regression suite (or the cases
  it touched) before returning an op.
- These runs carry no evidence duty: no hashing, ledger or disposition. They exist to catch
  our own mistakes before handoff. The REPORT says what was run and the pass/fail count, as a
  claim, not as proof.
- Limits: a cap on boot time and number of boots per op, the same `doas` scope as the Gatekeeper's
  runner, never the shared golden images, and cleanup at op end (the cleanup rule).
- This changes the role boundary in [roles.md](roles.md): today only the Gatekeeper runs guests.
  The Gatekeeper still owns every result that decides acceptance.

### 4.3 The Gatekeeper's proof, once per batch

Unchanged in rigour: contained boots, raw serial hashes, the before/after table, and every
mismatch listed. With 4.1, the base and fixed runs differ only in their payload disks over one
verified base, so the comparison is cleaner. With 4.2, the proof should fail far less often on
broken tests.

### 4.4 Build reuse

- Kernel batches: reuse the line's built world, and rebuild only the kernel, the module and the tests
  (`KERNFAST`/`NO_CLEAN` where safe; a clean build only when the configuration changes).
- Userland changes: build only the touched directories with `make -C dir install DESTDIR=`
  into a payload, unless the change needs a world build.
- Briefs say which artifacts may be reused.

### 4.5 Harness checks before boots

Already a rule (Gatekeeper OPS): check every guest command against the image, and compile scripts
on the host. With payloads, add a host-side dry run of the payload manifest and the guest driver.

## 5. Later options (not proposed now)

- **In-kernel unit tests.** FreeBSD's `ktest` framework (`sys/tests/ktest`) runs kernel test
  functions inside a running kernel. That suits Mach internals such as entry, right and queue
  invariants; it still needs a guest, but needs no user-space fixtures.
- **A long-lived test guest** that loads new `mach.ko` builds without rebooting. This is limited:
  batch 3 makes `mach.ko` refuse to unload (EBUSY), and hook changes need a new kernel anyway.
- **Parallel runs.** Several contained guests at once on this host (2 vCPU, 4 GiB each) for
  independent cases.
- **Sanitizer profiles in the fast loop.** KASAN as a payload kernel (instrumentation 1.0) once 4.1
  exists.

## 6. Rollout

1. **Coordinator decision:** 4.2 (Implementer guest runs), with its limits.
2. **Runner op (gatekeeper1, one op):** payload-disk support in the maintained runner. Settle
   option (a) or (b) from 4.1, with one test boot each, and document how to use it for the
   Implementer.
3. **Pilot:** Mach step 4, the largest kernel batch yet, on the new loop.
4. **Measure:**
   - hours from brief to proof per batch;
   - the number of Gatekeeper FAILED results caused by test or harness faults (target: near zero);
   - world builds per kernel batch (target: zero).
5. Fold what works into the Implementer and Gatekeeper templates, the rulebook (Rule 16) and
   `roles.md`.

## 7. Risks

- **Two loops can drift.** The Implementer's guests must use the same runner and base images as
  the Gatekeeper's, or a pass in the fast loop means nothing.
- **Containment creep.** Payload disks are the only new host-to-guest path. No shares or network
  for convenience.
- **Evidence confusion.** Inner-loop results are claims. Only the Gatekeeper's proof closes a batch.
