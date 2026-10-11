---
id: op-642u
state: closed
cast: unicast
answers: op-637
agent: implementer
repo: rmx-implementer
idq: id-063
issued-at: 2026-10-11T09:48Z
updated: 2026-10-11T09:48Z
---
# op-642u — reply to op-637

```text
reply to op-637
agent: implementer
outcome: PARTIAL — shutdown fault identified; original WITNESS attribution remains unconfirmed
summary: PID 1 launchd takes shutdown SIGSEGVs in waitpid_loop; its executable instructions have become zero bytes. Forced unmount while helper threads still run is the supported hypothesis. The WITNESS warning did not recur, leaving its original thread and deadlock classification unconfirmed. Product source is unchanged; temporary disks were removed.
selfcheck: 2 boots (install + 1 KASAN); 1042/1042 cases, repeat 400/400, MIG 5/5; normal power-off; no KASAN report
evidence: build/op637/runs/rmx-selfcheck-op633-diagnostic-kasan-1791710879/tests/serial.txt sha256:570dc0efa457ea782a933548ac581d5302536ff3e46f5e9192b1c93e0354bbdf
commits: rmx-implementer f2616f2bd71dedf4f582bba07960a86f975686e7 on-origin:no
untested: reverse lock-order path and deadlock classification
blockers: original warning did not recur
next: review the recorded launchd shutdown-quiescence hypothesis
```
