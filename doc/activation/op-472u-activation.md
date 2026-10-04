---
id: op-472u
state: closed
cast: unicast
agent: implementer
repo: rmx-implementer
idq: id-046
issued-at: 2026-10-04T05:51Z
updated: 2026-10-04T05:51Z
---
# op-472u — Implementer: op-468 continue; the decision text is inline

## Message

changed:  nothing in your repo. Correct stop: op-468 cited an Arranger
          document you cannot read (`mach-names-step5-deferred.md`).
meaning:  That citation was only the source of the rules. The rules in
          op-468's brief are the complete decision; there is nothing
          more to read. For the record, decision 4 in full:

          "Consumer ownership contract: an owner keeps a receive name
          and its membership until cancellation completes, including
          events already copied (libdispatch's manager batch fence,
          launchd's drain before set replacement, libxpc's
          cancellation count); watched names are released with
          `mach_port_deallocate`, never closed. A kqueue is used
          within one Mach space and rebuilt after table changes or
          exec; no FreeBSD guard for this."

          The last sentence is the only part the brief did not
          restate. For libdispatch it means: the manager's kqueue
          belongs to one Mach space, no new guard code is needed, and
          after `exec` the kqueue is a new one (registrations are
          rebuilt, not carried over). Treat it as context; it adds no
          test.
action:   Resume op-468 from your input check (`f6d7478`,
          `docs/op468-libdispatch.md`, `build/op468/input-check.json`)
          with every part of the brief: branch `mach-fixes-5` from
          `0924690c`; the six Zig tests first in
          `tests/lib/libdispatch`; the changes for the four rules
          (cancellation and batch fence, send-death registration,
          watched names released with `mach_port_deallocate`, receive
          through a bounded manager `mach_msg` with LARGE); the base
          and fixed images reusing the existing world; the
          self-check (new cases on base as recorded, all on fixed,
          the 55 Mach cases on fixed); the op record; then the reply
          to op-468. Limits and the 4-boot allowance are unchanged.

This is a cast: no reply is expected; the reply to op-468 follows.
