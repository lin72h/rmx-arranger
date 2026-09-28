---
id: op-372
state: issued
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-042
needs: op-364
gate: both
authority: guest attempts: 2 on the op-364 image; doas: load vmm.ko if absent, and the runner's bhyve calls; push rmx-gatekeeper1 main
updated: 2026-09-28T03:23Z
---
# op-372 — Gatekeeper 1: contained boot of the op-364 image

## Outcome

The op-364 image boots in a contained guest on this host (`bdw-fx15-x64z`). The result is
recorded from raw serial and host logs, with a disposition: `mach.ko` loads and initializes,
`task_self_trap` works, and the small regression slice runs. Prepare first; spend an attempt only
after every preparation step passes.

1. Configuration: reproduce op360's passing third attempt
   (`build/op360/runtime/rmx-op360-alpha2-20260925T044634Z-24151`) exactly as its host log records
   it, and change only the image-side pins. The log names the Expect driver
   `build/op360/boot-op360-r2.expect`, the plan `build/op360/runtime-plan/guest-sequence-alignment-r1.tsv`,
   the Mach probe `build/op360/alignment-r1/bin/mach_probe_diag`, and the dispatch probe
   `build/op355/bin/dispatch_probe`. The launcher on disk, `build/op360/run-op360-r2.sh`, pins a
   different Mach probe (`build/op360/bin/mach_probe_diag`, `0830f1a0…`) and plan; do not use
   those. Parameterize the maintained launcher rather than copying its logic into a new one, and
   use canonical paths (`rmx-implementer/`, `rmx-gatekeeper1/`), not `wip-gpt` or `rmx-gatekeeper`.
   If the plan embeds image-side hashes, regenerate it from the same basis for the Inputs below.
2. Host checks before any attempt, through the real generated shell and PTY path with harmless
   children: every pinned input verifies, the host is `bdw-fx15-x64z`, `vmm` is loaded, `doas -n`
   works for the runner's commands, and the generated bhyve command line has exactly the
   containment in Limits.
3. Containment: record a containment disposition (accepted or not-accepted, with its basis)
   before attempt 1. If it is not accepted, stop BLOCKED.
4. Run: boot a fresh verified copy of the image and record:
   - `mach.ko` in `kldstat`, the "mach services loaded" line, and `sysctl
     debug.link_elf_leak_locals`; if the module fails to load, the exact error (the known risk is
     `symbol knote_enqueue undefined`);
   - each Mach probe case (4) and dispatch case (4) as PASS or FAIL, continuing past a failed
     case; TWQ attribution stays UNTESTED unless the existing probes show it;
   - boot to login with root mounted, then a clean power-off, with the VM absent afterwards.
5. Record a disposition for the run evidence, commit by explicit path, and push `main` to
   origin (`lin72h/rmx-gatekeeper1`, private).

## Inputs

- Image: `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/images/op364-alpha2-gpt.raw`,
  8,589,968,896 bytes, sha256 `8f546a930859ce537d1cb8f462dbf391171fd02c2bd004d2d10b1c8b498c7140`.
- Its evidence and staged tree: `/Users/me/wip-mach/rmx-implementer/build/op364-20260928T001637Z/evidence`
  and `…/staging/destdir`, with `boot/RMXOS-RELEASE/kernel` sha256
  `b4608699ae1f93f1568053174b9c2197d497781f2653abba86eec34396a2ece8` and
  `boot/RMXOS-RELEASE/mach.ko` sha256 `53e5a8cfc1b5e18801d62501312b3cc031e682cf7480b4aac16d0eb55ae2fcdb`.
- Source: alpha2 `2884304b67fc454ee60187ce4731fca01cbefe6a` (on origin), worktree
  `/Users/me/wip-mach/build/alpha2-stable15-sync-20260921`.
- op360's passing basis (sha256): Expect driver `7bcd0682098f430d39ef7ca48cc2838f81d80af7ebc3572591df4b92346bfbd9`,
  plan `cc93815ac8ddea9552ae744e69e882cdabedfe395e2a9a935d011378bfe0e99a`, Mach probe
  `72be4d2c65bbbdd167ccbda5ac96233012640bd8de3a0bdd6e6597e482207b7a`, dispatch probe
  `f6c5201576963e1936def228bd37de13f5362e1622b4abf7da6dd4ee96666019`.

## Limits

- Guest attempts: at most 2. Stop after the first attempt that completes the plan. Use attempt 2
  only after a HARNESS-FAIL, and only after a host-side fix and its host check. A component
  failure (a probe FAIL, or `mach.ko` not loading) is a result, not a reason to retry.
- Containment: 2 vCPUs, 4 GiB, one virtio disk from the fresh copy, serial console only; no
  network, shares, or passthrough; the runner's time bound and targeted teardown.
- Privilege: load `vmm.ko` with `doas` if it is absent, and leave it loaded; the runner's
  `doas -n` calls to bhyve, bhyveload, and bhyvectl. Nothing else needs root.
- Do not change the image, the staged tree, or other repos, and author no new probes.

Defaults and the REPORT block: OPS.md in your repo.
