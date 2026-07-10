# id-037 — MACHDEBUG engine-cell dark: userland dispatch binaries crash before libdispatch init on the MACHDEBUG kernel (regime cell 1 unusable)

- id: id-037
- state: **RAISED — evidence-lane limitation, twice-confirmed first-hand (op-234, op-239); NOT promoted.** Low product-impact (MACHDEBUG is not the ship conf), real evidence-coverage impact (the 3-cell engine regime has only 2 live cells). Promotion is a Coordinator call — flag, don't self-gate.
- raised: 2026-07-02 (Arranger, consolidating op-234 CAVEAT 2 + op-239 cell-1 from the two Gatekeeper runs)
- lane: evidence-lane — the op-231 engine-matrix regime (op-230 block); userland dispatch binary vs MACHDEBUG mach.ko
- relation to in-flight work: does NOT block any current op (cells 2+3 cover both twq + pthread-pool engine paths); it caps what "3-cell coverage" can actually mean.

## THE FINDING (twice, two different binaries)

The op-231 engine matrix defines 3 cells: **cell 1 = MACHDEBUG** (pool by ENOSYS construction), cell 2 = MACHDEBUGDEBUG (twq), cell 3 = MACHDEBUGDEBUG+LIBDISPATCH_DISABLE_KWQ=1 (pool). Cells 2 and 3 run clean. **Cell 1 has never produced a result** — the userland dispatch test binary crashes before/at libdispatch init on the MACHDEBUG kernel:
- **op-234 CAVEAT 2:** MACHDEBUG kernel booted fine (`sys/MACHDEBUG amd64`), but `dispatch-churn-op193` crashed before libdispatch init → banner not captured. Routed to op-233 item-3 triage (a suspected repro of the untriaged `op193-dispatch-chur.core`); hypothesised single-binary staging/KBI fluke.
- **op-239 cell 1:** a DIFFERENT binary (`op235-substrate`) crashed the same way — "dispatch binary couldn't initialize on MACHDEBUG kernel, same mach.ko/MACHDEBUG KBI issue."

**Two different binaries failing identically weakens the single-binary-fluke hypothesis** → more likely a systematic MACHDEBUG-cell dispatch-init problem (mach.ko/MACHDEBUG KBI mismatch, or a dispatch-init path that faults specifically under the MACHDEBUG kernel's THRWORKQ-ENOSYS/fallback branch). Note the tension: MACHDEBUG rode GREEN in op-198 soaks — so either those soaks didn't exercise this dispatch-init path, or something diverged since. Not yet root-caused (no first-hand trace exists).

## IMPACT
- **Product:** low — MACHDEBUG is NOT the 1.0-preview ship conf (MACHDEBUGDEBUG is, op-182 cert).
- **Evidence regime:** real — the "3-cell" engine matrix effectively has 2 live cells. The pool engine is still covered (cell 3, MACHDEBUGDEBUG+DISABLE_KWQ), so no engine path is dark; but the *native-MACHDEBUG* pool arm (the "weaker regime" li-1013 Item 1 worried about) can never self-report until this is fixed. Any claim of "MACHDEBUG-cell evidence" is currently unfulfillable.

## WHAT WOULD CLOSE IT (if promoted)
A first-hand trace of the dispatch-init crash on the MACHDEBUG kernel (why does libdispatch init fault under MACHDEBUG but not MACHDEBUGDEBUG?), then either a mach.ko/KBI fix or a documented "cell 1 retired, cell 3 is the canonical pool arm" regime-design decision. Cheap-first: confirm whether it's a KBI/lineage mismatch (rebuild the binary against the MACHDEBUG mach.ko) before assuming a kernel defect.

## RELATIONS
op-234 CAVEAT 2 (first sighting) / op-239 cell 1 (second, different binary). op-233 item 3 (`op193-dispatch-chur.core` triage — the routing op-234 proposed; the core may be the same crash). op-231 D-series (the 3-cell engine matrix design) / op-230 (regime block). li-1013 Item 1 (the MACHDEBUG "weaker regime" this cell was meant to characterize). feedback: no_conflate_gating_with_readiness (flag, don't self-promote), artifact_identity_needs_content_check (KBI/lineage suspect — check the binary-vs-mach.ko build match before blaming the kernel).
