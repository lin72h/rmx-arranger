---
id: op-246
state: closed
updated: 2026-09-27T22:54Z
legacy-state: Done
reset: j-20260927-004
---
# op-246 — Validator (GLM): kernel-semantics gate on the op-242 MACH_RECV flag-collision fix (ipc_pset.c filt_machport_direct_receive) — confirm it fixes the panic path AND does not regress internal direct-receive

op-246 | role: **Validator (GLM)** (falsification-primary, kernel-semantics) | EXU: **GLM validator seat — reads wip-gpt/wip-rmxos @ d70062591073 (source, read-only) + op-242 trace artifacts (rmx build/op242-mach-recv/)** | state: **[Done — SPINE PASSES, confidence 9/10; op-242 fix confirmed REGRESSION-SAFE + semantically correct first-hand (Q2 verified by Arranger); op-247 RELEASED. Q1 "flag collision is the SOLE corruption vector" is OVER-BROAD — refuted by op-244 R1 (GLM lacked op-244); sufficiency remains UNPROVEN → op-247 A/B settles it. 2026-07-02]** | parent: op-242 (the L/XL fix delegation) / id-036 (defect) | L1i: li-1002 (IPC substrate) / li-1001 (invariant) / li-1007 (exposure) | cost: 0 (GLM, free) | authored 2026-07-02 (Arranger seat, model Opus 4)

## OUTCOME (Arranger adjudication, 2026-07-02, Q2 verified first-hand)

**Gate: PASSES at 9/10. op-247 released.** Per Rule 11 (confidence ≥9) I do not override — but I verified the load-bearing claim first-hand and I am correcting one sub-claim.

- **Q2 (no-regression) — ACCEPTED, verified first-hand.** This is what carries the ≥9 and it holds. source.c:2440 `_dispatch_source_type_mach_recv_direct .fflags = DISPATCH_MACH_RECV_MESSAGE_DIRECT` (0x10); `0x10 & 0x2 = 0` and DIRECT_ONCE (0x20) likewise → the DIRECT variants never took the `MACH_RCV_MSG` filter gate, before OR after the fix, so the fix cannot regress them. The internal recv kevent (source.c:2432 `.fflags = DISPATCH_MACH_RCV_OPTIONS`) includes `MACH_RCV_MSG` (source.c:2392) AND gets ext[0]/ext[1] populated (`_dispatch_mach_recv_msg_buf_init`) → new gate passes → legit direct receive preserved. The gate blocks exactly one case: `MACH_RCV_MSG` present + buffer absent = the bug case. GLM's "over-narrow the gate?" check is a genuine primary-artifact result. **The fix is regression-safe and semantically correct.**
- **Q1 (fix removes THIS panic) — OVER-BROAD, corrected.** GLM concluded "the flag collision is the SOLE corruption vector; no distinct syscall-path panic could survive." That is REFUTED by op-244's R1 (Arranger-verified first-hand): the probe's own undersized userland `mach_msg(MACH_RCV_MSG, no LARGE)` hits `rcv_size+min-trailer > max → MACH_RCV_TOO_LARGE → dequeue-anyway (LARGE-only keep) → msg_receive_error → copyout_dest` panic **with no filter involvement**. GLM lacked op-244, so it built a filter-only causal chain — but op-246's own SCOPE Q1 pre-registered this exact failure mode ("could a distinct syscall-path panic survive?"). It can. So op-242's fix is **regression-safe but NOT proven sufficient** — the necessary-but-not-sufficient posture op-244 established STANDS; GLM's Q1 does not overturn it.
- **Q3 (cross-evidence) — reconciled, but note op-244 gives the cleaner reconciliation.** GLM's "cert buffered vs alpha readiness-only" story is plausible; op-244's R1 gives the simpler, version-hypothesis-free answer (li-1002 passed because its buffers were adequately sized, never hit TOO_LARGE). Prefer op-244's reconciliation.

**NET:** the gate did its job — it caught the load-bearing regression question with a first-hand smoking gun (Q2 PASS) and released op-247. The one correction (Q1 sole-vector is over-broad) is not a gate failure; it flows into op-247 as the mandatory R1 A/B. **This vindicates the relay concern:** had op-244 been in GLM's seat, Q1 would not have claimed sole-vector. op-247 MUST carry: fix is regression-safe; sufficiency UNPROVEN; original undersized probe A/B is the discriminator.

## CONTEXT (read first)
Open-source OS engineering — a source-level kernel-semantics gate on OUR OWN compat-Mach receive filter. Not security work, no external target. op-242 fixed a kernel null-`io_lock` panic; this gate confirms the fix is semantically correct and regression-free BEFORE the Gatekeeper acceptance rerun (op-247). Rule 11: this is an L/XL kernel IPC receive/lock path → attach a confidence 1-10; Arranger steps in if <9.

## WHY (one line)
op-242's root cause (flag collision `DISPATCH_MACH_RECV_MESSAGE 0x2 == MACH_RCV_MSG 0x2`) is Arranger-verified first-hand and credible, but the fix is UNPROVEN at runtime and the reproduced panic backtrace enters via the `mach_msg_overwrite_trap` syscall, NOT `filt_machport` — so the "filter's bad receive → syscall-path panic" causal link is reasoned, not traced (`code_reasoned_verdict_is_hypothesis`). Confirm the semantics before spending the Gatekeeper boot.

## SCOPE — three questions, source-read + the op-242 trace artifacts (falsify, don't confirm)
1. **Does the fix actually remove THIS panic?** The reproduced backtrace is `mach_msg_overwrite_trap → mach_msg_receive → msg_receive_error → ipc_kmsg_copyout_dest` (null io_lock, ipc_kmsg.c:2844). The fix is in `filt_machport` (ipc_pset.c). Reconcile: does removing the filter's no-buffer receive eliminate the state corruption the syscall-path receive then trips over — or could a distinct syscall-path panic survive the fix? Name the mechanism that connects the filter change to the observed backtrace; if you cannot, that is a sub-threshold finding.
2. **Regression: internal direct-receive.** The new gate `filt_machport_direct_receive` requires `MACH_RCV_MSG && ext[0] && ext[1]`. Confirm first-hand that the INTERNAL direct-receive sources (`DISPATCH_MACH_RECV_MESSAGE_DIRECT` / `_DIRECT_ONCE`, source.c:2440) actually populate `ext[0]/ext[1]` with a real buffer — else the fix silently disables internal direct receive (a functional regression). This is the load-bearing "did we over-narrow the gate" check.
3. **Reconcile the cross-evidence.** (a) op-098 proved the filt_machport success path — did that path carry a buffer (legit direct receive), consistent with the fix? (b) id-036 cross-op clue: li-1002 `source-MACH_RECV` PASSED on the cert image (mach.ko 9c7706a3) while the alpha panics — is that a version-specific mach.ko difference or a test-config difference (li-1002's case buffered vs the probe's readiness-only)? The answer reshapes C6 severity.

## DELIVERABLE
A verdict with **confidence 1-10** + status: (i) fix is semantically correct and connects to the observed panic (Q1); (ii) no internal-direct-receive regression (Q2); (iii) cross-evidence reconciled (Q3). At **≥9** the kernel-semantics spine passes on your word (Arranger light provenance check only) → releases op-247 (Gatekeeper acceptance rerun). At **<9** Arranger steps in on the decisive evidence (Rule 6). Cite exact lines; a high-confidence source-only verdict is still a hypothesis for the *runtime* claim — your gate is semantics, op-247 is the runtime proof.

## BOUNDARIES
- **Validator falsifies at source; does not fix, does not build, does not run the reproducer** (that is op-247, Gatekeeper).
- **Read-only** on wip-gpt/wip-rmxos and the op-242 trace artifacts; stage the verdict in the Validator's own space (`agent_host_isolation`).
- **Does NOT decide C6 preview-severity** (Coordinator, li-1013) — supplies the reconciliation (Q3) that informs it.
- **fbt_traces_kernel_only** if you cite any trace bar; but this is primarily a source-semantics read.

## RELATIONS
op-242 (fix under gate) / id-036 (defect) / op-241 (panic premise) / op-098 (success-path baseline, Q3a) / li-1002 op-226 cross-op clue (Q3b) / op-247 (Gatekeeper acceptance rerun, released on ≥9). feedback: code_reasoned_verdict_is_hypothesis, arranger_gate_sizing_delegation (Rule 11, L/XL → GLM validator, confidence 1-10), no_conflate_gating_with_readiness, artifact_identity_needs_content_check, agent_host_isolation.
