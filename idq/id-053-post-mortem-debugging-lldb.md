# id-053 — A guest panic leaves too little to debug: no dumps, no LLDB path, no Mach debugger commands

- id: **id-053**
- state: **WAITING — priority medium, with id-047 (Instrumentation 1.0; Coordinator, 2026-10-01); starts with id-047's first Gatekeeper run**
- raised: **2026-10-01 by the Coordinator ("in 1.0 will be LLDB-related features")**
- parent: id-042 (1.0-preview); related: id-047, id-048, id-046
- strategy: [instrumentation-strategy.md](../instrumentation-strategy.md), Instrumentation 1.0

## Problem

When a test guest panics, the only record is the serial log. Nothing captures a kernel dump. The
images do not list their kernel and `mach.ko` debug files. There is no tool to walk Mach state (IPC
spaces, entries, ports, port sets, queued kmsgs, task and thread Mach state) in a vmcore. Sanitizer
runs (id-047) and fuzzing (id-048) will produce many panics. Each needs to be triaged from evidence,
not by re-running it.

## What exists

- **FreeBSD:** DDB panic scripts (ddb(8), `/etc/ddb.conf`, rc.conf `ddb_enable`); textdumps and
  minidumps (`dumpdev`); savecore(8) and crashinfo(8). Python kgdb scripts in `sys/tools/gdb/` set
  the form for debugger extensions.
- **Base LLDB** (LLVM 21.1.8 in alpha2) builds the FreeBSD kernel-core plugin
  (`lib/clang/liblldb/Makefile:481-485`) and scripts in Lua.
- **On this host:** ports LLDB (llvm21) scripts in Python 3.11 and links libkvm; kgdb (ports gdb)
  is installed.
- **XNU's LLDB commands:** `tools/lldbmacros/` (APSL), at
  `/Users/me/wip-mach/reference/xnu-xnu-12377.121.6/tools/lldbmacros/`. `ipc.py` has 35 commands
  (showipc, showtaskipc, showrights, showport, showpset, showkmsg, showmqueue, findportrights,
  showallports, …); `kevent.py`, `workqueue.py` and `kasan.py` are beside it.
- **Upstream:** llvm-project#180061 (FreeBSD LLDB support, now aimed at LLVM 24). It covers
  printing the message buffer, selecting the crashed thread, loading kernel modules' symbols, and
  a new test suite for the kernel-core plugin.

## Scope

1. **Panic capture in every test image (Gatekeeper):** a DDB panic script prints `bt`,
   `show alllocks`, `ps` and `alltrace` to the serial console, writes a dump to a dump device, and
   stops without rebooting. The host extracts the dump.
2. **Debug files with every image (Implementer):** `kernel.debug` and `mach.ko.debug` are listed in
   the BOM. op-396 installs them.
3. **Triage path:** show one vmcore opening in LLDB, with `mach.ko`'s symbols loaded, and in kgdb.
   Record which LLDB (base or ports) works, and every LLDB failure as a reproducible upstream
   report.
4. **Mach commands for LLDB (Implementer):** port the IPC subset of XNU's `ipc.py`, then the
   relevant parts of `kevent.py` and `workqueue.py`, to rmxOS's structures, keeping XNU's command
   names. Python, under `sys/tools/lldb/`, in `sys/tools/gdb/`'s form (a README and a self-test
   against a known vmcore).
5. **Userland cores:** launchd, libdispatch and notifyd cores go through the same LLDB path.

## Done when

A sanitizer panic from a contained run yields a dump that opens in LLDB with Mach symbols, and
`showtaskipc` and `showport` print the state behind the report.

## Notes

Base LLDB scripts in Lua, not Python. XNU-derived commands therefore run in a ports LLDB on the
host, which is where triage happens anyway.
