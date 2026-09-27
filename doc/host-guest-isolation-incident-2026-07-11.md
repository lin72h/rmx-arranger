# Host/guest isolation incident — 2026-07-11

Status: **CONFIRMED — COORDINATOR-RESOLVED 2026-07-11**

Authority: Arranger2 first-hand incident adjudication; Coordinator disposition 2026-07-11:
`"forget about op-006m, it's solved, let's move on"` closes the process-control follow-on and
lifts the incident-wide scheduling hold. Individual op gates and host-runtime prohibitions remain
where recorded in their activation cards.

Host: bdw-fx15-x64z

Primary affected sessions:

- Gatekeeper: d8a8cfa4-7056-40f6-a655-79c1ce56cb3c
- historical Explorer: 019e1abd-4337-7773-bb96-72662b9f4425

## Historical immediate containment — lifted by Coordinator disposition

The following containment applied until the Coordinator's resolution above:

1. Pause the current Gatekeeper session for all privileged or host-runtime execution.
2. Do not run doas, sudo, privileged shells/redirections/heredocs/tee, mdconfig, mount, umount,
   bhyve, bhyveload, kldload, shutdown, host dlopen, target-linked executable probes, or any
   constructor-bearing rmxOS binary/library on the physical host.
3. Do not dispatch op-289, op-305, op-308, or any other Gatekeeper execution op.
4. Preserve the Gatekeeper transcript and untracked op-306 artifacts byte-for-byte. Do not clean,
   rebuild, overwrite, stage, commit, or delete them.
5. Static read-only hashing, stat, readelf, nm, source/log reading, and Git inspection remain
   allowed where commissioned. They confer no runtime authority.
6. Do not silently substitute bhyve. A disposable premise cell requires a separately scoped op,
   exact image/BOM, attempt accounting, and Coordinator release.
7. Require a fresh agent context before any later privileged work, after incident recording and
   approved containment controls.

The exact Git-only Implementer publication for op-304 may finish. Read-only Validator work may
continue subject to the op-310 override below.

## op-310 incident override

Validator-DS4P must not execute op306_type_token_premise, op306_xpc_lifecycle_probe_v2,
op306_mach_stubs.so, the staged libxpc through dlopen, or any target-linked binary/library.
The earlier activation permission to execute an existing host premise binary is superseded.
DS4P may inspect frozen raw output and static ELF/nm/source evidence. It must label the existing
dlsym record as physical-host constructor execution, not a contained host-safe probe.

## First-hand facts currently reproduced

### op-306 physical-host execution

- Gatekeeper transcript:
  /Users/me/Local/config/claude-config/glm/projects/-Users-me-wip-mach-rmx-gatekeeper/
  d8a8cfa4-7056-40f6-a655-79c1ce56cb3c.jsonl
- capture identity: 18,633,430 bytes; SHA-256
  f93dbf898192e18d105fff411124cc78961e9ccb2542ae32937534647f3221d8
- transcript records direct runs at 2026-07-11T06:27:57Z and 06:28:40Z, including the
  LD_PRELOAD Mach-stub execution and frozen-output execution.
- the dispatch itself commissioned a zero-cell host-only `dlopen`/`dlsym` premise. That was a
  containment error: `dlopen` executed dependency constructors even though the probe did not call
  a Mach API directly.
- /var/log/messages records:
  - 18:27:57, PID 24843, get_special_port failed - mach_task_self_: 0
  - 18:28:40, PID 24855, the same message
- /etc/syslog.conf contains *.emerg → *.

Static ELF/source inspection confirms the path without re-executing it: the staged libxpc needs
`libmach.so.5`; libmach registers `mach_init` in `.init_array`; the preloaded `task_self_trap`
stub returns zero; `mach_init` then fails its special-port lookup and calls `syslog(LOG_EMERG, ...)`.
The physical-host dynamic run is quarantined as methodologically unsafe evidence. Static
readelf/nm/source evidence is independent and remains usable. A bounded scan of the op-306
transcript segment found no privileged or persistent host-configuration write.

### op-235 host rc.local execution

- /var/log/messages capture SHA-256:
  1e867016af8e31ad4f9a02f187c4a76de43c7d7beb358bf1b32b0b1d43020b63
- /etc/rc.local.disabled-rmxOS:
  - 754 bytes
  - SHA-256 9de2beb03ad3df5559b05d8bc61cece8ff788c5fd03c182c9330a47563914fbf
  - contains OP235_cell3_START, target probes, sync, and shutdown -p now
- /var/log/messages directly records OP235_cell3_START followed by root power-down on five host
  boots: lines 2998–3000, 3404–3406, 3821–3823, 4650–4652, and 5478–5480.
- Gatekeeper transcript line 5269 contains a privileged redirection using G before its later
  assignment, resolving the destination to /etc/rc.local.
- /var/log/auth.log exists at 461,792 bytes but is mode 0600 and was not read by Arranger2.
  No privilege was used. Oracle2's cited auth-log line needs an authorized read-only route.

The disabled file byte-matches the transcript heredoc and ends in `shutdown -p now`. The five
physical-host harness executions and induced shutdowns are first-hand confirmed. No
`OP235_cell3_DONE` marker exists, so this does **not** prove every intermediate workload command
completed on the host. Scope the correction to the host write, harness execution, and five power
offs; do not blanket-invalidate unrelated guest evidence.

### Historical Explorer rc.conf and current host state

- Explorer transcript:
  /Users/me/.codex/sessions/2026/05/12/
  rollout-2026-05-12T17-51-11-019e1abd-4337-7773-bb96-72662b9f4425.jsonl
- capture identity: 56,098,448 bytes; SHA-256
  22264d3b5dfa9b598eb00e7c85dbbbb304475eb469ee72e3ddc93e74be1a47ba
- /etc/rc.conf: 813 bytes; SHA-256
  275cb2337feb7014c0ca740d7d034c9f9d9b389aec263830919fffff352cce1e
- lines 12–26 contain two commented rx parity staging blocks.
- transcript lines 26114 and 26147 contain the two privileged appends. Each crosses an outer
  single-quote boundary before `$guest_root`, so the parent shell expands the then-empty variable
  and resolves the destination to host `/etc/rc.conf`. Command-line SHA-256 identities are
  `9c2508c1ac4a8e47b2d8d71757a580625b2ec4cca3691c9ecceec27a12716344` and
  `100ec12a4aa661fbf98516e7d76ed33dadc0a68c47e0d19517c28c438343a29e`.
- the current host file contains both heredoc bodies exactly. This confirms the historical
  Explorer host-isolation breach even though the root-only rotated auth log was not re-read.

Current read-only checks:

- no active /etc/rc.local;
- disabled rc.local present;
- rc.conf additions commented;
- /boot/loader.conf: 244 bytes, SHA-256
  80893e7cf6734b9d0b0222af5c08cd5bdbf72aae1488f24869b2427d23a0d0da, with no incident entry;
- `/etc/rc.d` and the April ZFS snapshot each contain 171 regular files and no symlinks; filename,
  path/content, and full logical inventory digests match exactly (`78afd9b8...bded4`,
  `75ac1c3...619a`, and `4eab607b...b3e`), and `diff -qr` is empty. Calling that baseline "stock"
  still depends on the April snapshot being trusted;
- no op306, op235, bhyve, or bhyveload process found;
- no Mach/rmxOS module loaded.

`/boot/loader.conf` is free of incident-related Mach/rmx entries. It is not byte-identical to the
earlier April snapshot: only `vmm_load` and `pptdevs` were later commented. That is not attributed
to this incident.

## Evidence preservation

No system or EXU write is authorized by this record. The hashes above preserve current identities
without copying sensitive full logs into a repository. An owner-authorized preservation route
must capture the minimum source-cited auth/messages excerpts, disabled rc.local, transcript command
records, and host-integrity inventory before rotation. Do not commit full authentication logs or
unrelated transcript content.

## Closure / retained record

1. The op-306 dynamic/dlsym record remains quarantined as physical-host execution. Retired op-310
   consumed the type-token premise from independent static ELF/source evidence only.
2. The scoped op-235, block-071, and op-306 corrections remain authoritative historical records.
3. op-005m correctly stopped `WRONG-CONTEXT`; op-006m was canceled before dispatch by the
   Coordinator. Neither op is claimed to have produced a helper or doctrine commit.
4. The incident-wide scheduling hold is closed. Future Gatekeeper work still requires its normal
   activation, evidence, safety, and Coordinator dispatch gates.

## Proposed controls — Coordinator decision required

- Ban agent-authored arbitrary privileged shells, heredocs, tee, and redirection.
- Require a narrow reviewed staging helper with explicit source/destination arguments.
- Reject unset, empty, root, /etc, stale, unmounted, and wrong-device guest roots before privilege.
- Require canonical path, approved workspace, active mountpoint, expected md partition, different
  host device/filesystem, image identity, and staging sentinel.
- Build/hash content unprivileged, then install atomically by explicit path.
- Inventory /etc/rc.conf, /etc/rc.local, /etc/rc.d, /boot/loader.conf, and /boot/modules before
  and after staging; any host delta is a hard stop.
- Treat dlopen, target-linked executables, and constructor-bearing libraries as runtime execution.
- Use a fresh privileged agent session after any isolation incident.

These proposals remain useful banked controls, but op-005m/op-006m did not land them. No
implementation claim is made by this incident closure.
