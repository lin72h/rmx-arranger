# id-050 — mm4 is reached by a pinned IP; `mm4.local` does not resolve on this host

- id: **id-050**
- state: **WAITING — priority low; deferred by the Coordinator (2026-09-28, j-20260928-002)**
- raised: **2026-09-28**
- parent: none (host infrastructure); related: roles.md (remote instances), LOCAL.md § mm4 access

## Problem

This host (`bdw-fx15-x64z`) cannot resolve `mm4.local`: `/etc/nsswitch.conf` has no mDNS source
(`hosts: files dns myhostname`), so `getent hosts mm4.local` returns nothing. `~/.ssh/config`
therefore pins `Host mm4` to `HostName 192.168.4.47` with `HostKeyAlias mm4`. If mm4's address
changes, ssh to mm4, and with it every mm4 seat (gatekeeper2, explorer2, advisor4), breaks until
HostName is updated by hand. The fix is one line, and the alias keeps the host keys valid.

## Current state

- Apple's `mDNSResponder-2881.120.11` is installed. `mdnsd` runs from a one-time manual start and is
  not enabled at boot (`mdnsd_enable` unset), so it stops at the next reboot.
- mm4 (macOS 27) answers mDNS natively; only this host's resolver is missing.

## To resolve (host privilege: Coordinator authority)

1. Enable `mdnsd` at boot (`/usr/local/etc/rc.d/mdnsd`).
2. Install `mDNSResponder_nss` (available from pkg) and add `mdns` to the `hosts` line of
   `/etc/nsswitch.conf`.
3. Check `getent hosts mm4.local`, then optionally set the ssh HostName back to `mm4.local`,
   keeping `HostKeyAlias mm4`.

Constraint (Coordinator): no avahi; packages through `pkg` with `doas`.

## Done when

`mm4.local` resolves on this host across a reboot, and the ssh config no longer depends on a
fixed address (or the Coordinator chooses to keep the IP).
