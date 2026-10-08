---
id: op-563u
state: closed
cast: unicast
answers: op-560
agent: gatekeeper1
repo: rmx-gatekeeper1
idq: id-061
issued-at: 2026-10-08T05:13Z
updated: 2026-10-08T05:13Z
---
# op-563u — reply to op-560

```text
reply to op-560
agent:      gatekeeper1
outcome:    DONE — overlay route adopted; corrected op-547 proof passed
attempts:   consumed 4/5; base install PASS sha256:f99d7234a32064339ace22cb04a3868500db07459510e24e4711749ab7665adb; base tests PASS sha256:14dfdb0d992caa64fe55ce02ca9b0b5f214aeed02d8bc66a2f5b546a7bb24df4; fixed install PASS sha256:060f28098bd13dcbc387d313670f2b4de24de3094804ace72be8678c0a1df5b3; fixed tests PASS sha256:2b694dc86cd09967fb6ba9ada919ab7b252c90096f7e6c517f3fc6178a4d78e5
disposition: accepted — build/op560/disposition.json
evidence:   build/op560/results.md; observations.json; attempt-ledger.json; serial-hashes.txt; runner-note.md; evidence/cleanup.json
commits:    rmx-gatekeeper1 95547543247f0ebc4f0d8f24f314810a1be7d6d5 on-origin:yes
untested:   temporary reference count 2 was not observed; wider soak
blockers:   none
next:       consume the accepted proof
```
