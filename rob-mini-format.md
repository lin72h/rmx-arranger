# Op states and the board

How ops move and how the board is shown. `tools/rob` is the only way to read or change op state;
never hand-edit a state tag. (Rewritten 2026-09-28; the older CPU-style tags are mapped below.)

## States

| State | Meaning | Next |
|---|---|---|
| `draft` | brief exists; not yet sent by the Coordinator | `issued`, `hold`, `dropped` |
| `issued` | Coordinator confirmed it was relayed to the named agent | `returned`, `dropped` |
| `returned` | the agent's REPORT came back; **not** yet reviewed | `closed`, `dropped` |
| `hold` | deliberately parked; the number stays reserved | `draft`, `dropped` |
| `closed` | reviewed per the risk-sized rule and every blocker is clear (including origin reachability of produced commits) | — |
| `dropped` | did not work out or was superseded; redo work gets a new op number | — |

Transitions happen when the fact happens: `issued` when you say "sent", `returned` when you paste
the REPORT back, `closed` only after the review in
[discovery-implementation-pipeline.md](discovery-implementation-pipeline.md) § Retirement &
escalation. A dependent op lists `needs: [op-NNN]` in its header instead of a separate waiting state.

## The board

End every reply that issues, receives, or closes an op with `tools/rob board`: live ops grouped by
state, ids only, plain bullets. Closed and dropped ops never appear. `tools/rob list` gives one line
per op when detail matters.

## Op ids

`op-NNN`, sequential, never reused, never decorated (`op-151a`, `op-151-cont` are illegal). Use
`tools/rob next-id` or `tools/rob new`. Historical `op-NNNm` files remain valid; new work uses
plain `op-NNN`.

## Legacy tags

Files not yet converted keep their original header; `rob` maps it and adds front matter on the next
state change. Mapping: Draft/Ready/Awaiting → draft; Exe/In-flight/Air/Queued → issued;
Done/Returned/Partial → returned; Hold/Held/Deferred → hold; Retired/Closed → closed;
Flushed/Void/Rejected → dropped. On 2026-09-27 every returned op was closed and every stale
draft/issued op dropped as a clean-start reset (`reset: j-20260927-004`); open problems remain in
their IDQ files.
