---
id: op-627u
state: closed
cast: unicast
answers: op-626
agent: implementer
repo: rmx-implementer
idq: id-063
issued-at: 2026-10-11T05:22Z
updated: 2026-10-11T05:24Z
---
# op-627u — reply to op-626

```text
reply to op-626
agent: implementer
outcome: PARTIAL — dead-name fix and both overlays committed; RELEASE stopped on a product-path failure.
selfcheck: RELEASE 104 passed, 1 failed, 818 unrun; corrected dispatch death-registration tests pass; five MIG modes exit 0; normal power-off; no assertion/fatal trap; 2/6 boots used.
evidence: docs/op617-round3.md § op-626
build/ci/3745c74b35c9bd8fa029e88719fdb3be1409fdde/overlays/rmxos-release-op626/overlay.ufs sha256:d96bc2e29630922d4cdec8e702a9ea8bae3f8dd7e871d5ab6af2302a0ba3194d
build/ci/3745c74b35c9bd8fa029e88719fdb3be1409fdde/overlays/rmxos-kasan-op626/overlay.ufs sha256:0fe616946abf8178794e3a33713fe50d517e4497e99ab921716c23ffccc4cc2f
build/op626/runs/rmx-selfcheck-op626-fixed-release-r1-1791695677/install/serial.txt sha256:208d37e7cb71f954f322716fb4028394a89456c7c37f5b1d2e99fa7ae3f595dc
build/op626/runs/rmx-selfcheck-op626-fixed-release-r1-1791695677/tests/serial.txt sha256:5e796c1f9bb1b4a38f3e53e0f50c5b5825e6041096ffe08e9042ddaa85a0576b
Cleanup freed 2.07 GiB; final overlays and logs retained.
commits: wip-rmxos 3745c74b35c9bd8fa029e88719fdb3be1409fdde on-origin:no
rmx-implementer ee549dacc6bdbb03a76cf414597120d1a4bc1b84 on-origin:no
rmx-implementer 0bcf8ca1633147f7e4a6d3f92f48e98c2eacc3c0 on-origin:no
untested: New already_dead case, remaining notification cases, 400-case repeat and KASAN.
blockers: mach_send_possible_test:full receives MIG_BAD_ARGUMENTS (-304) for valid queue-limit setup. Client/server message-size calculations require investigation; brief mandates stopping on product failure.
```
