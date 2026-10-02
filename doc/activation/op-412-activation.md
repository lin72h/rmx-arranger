---
id: op-412
state: draft
agent: implementer
repo: rmx-implementer
idq: id-046
gate: self
authority: build: mach.ko from mach-fixes-1; restage the fixed + tests image with rmx-stage-image; no guest runs; no push
updated: 2026-10-02T03:03Z
---
# op-412 — Implementer: fix 6 follow-up — balance the port-set lock in filt_machport, rebuild, restage the fixed image

## Outcome

Context: ordinary bug fixing in our own open-source OS (rmxOS: FreeBSD 15 with Apple's
open-source Mach IPC).

validator2's review of op-395 (op-407, rmx-validator2 `17ba614`) found one regression from fix 6
(`10b9c426`). Fix 6 made `ipc_object_translate` always lock the object, and moved
`filt_machportattach` to `ipc_object_translate_known`. But `filt_machport` still calls the plain
form (`sys/compat/mach/ipc/ipc_pset.c:623` at `5fa02fb5`). Its existing guard
`if (pset != (ipc_pset_t)entry->ie_object) ips_unlock(pset);` (line 637) skips the unlock in the
normal case, and `ips_lock(pset)` at line 667 then takes the same mutex a second time.

Fix it as one commit on `mach-fixes-1` (after `acfc34cd`): at line 623 call
`ipc_object_translate_known(current_space(), name, MACH_PORT_RIGHT_PORT_SET,
(ipc_object_t)entry->ie_object, (ipc_object_t *)&pset)`, so the translate call and the guarded
unlock pair up again. Check every other caller of `ipc_object_translate` for the same pattern (a
pre-seeded output pointer followed by a conditional unlock), and fix any you find in the same way,
in the same commit.

`mach_short_kevent_test:short_buffer` exercises this path on the fixed image; no new test is
needed. Rebuild `mach.ko` and restage only the fixed + tests image, as op-409 did. Evidence: the
commit, the caller check, the new image hash, and the BOM and inventories (by path).

## Limits

- Change only `filt_machport` and any caller with the same pattern. No push of `wip-rmxos`.

Re-read OPS.md first: defaults and the REPORT block.
