# rmxOS — the platform for SuperApp 2.0

Two-audience marketing brief. Same core story, two vocabularies.

- **Version 1** — business / non-technical readers.
- **Version 2** — lightly-technical readers.

> Truth-in-advertising note (keep in mind when pitching): the "many small processes
> share ONE load-aware core budget" claim is the *aspirational* end state — the
> cross-process concurrency budget is still kernel work in progress. The technical
> copy below deliberately claims only what is true today (per-process elastic
> concurrency + bounded memory), and reserves the shared-budget idea for "vision"
> framing. Adjust the lean if the venue calls for more vision vs. more rigor.

---

# Version 1 — For business people

## rmxOS: The operating system built for SuperApp 2.0

**The world fell in love with the SuperApp.** WeChat, ChatGPT, Grab, Alipay — one app
where you do *everything*: chat, pay, shop, book, ask an AI. People love the
convenience of a single front door.

But there's a catch. Today's SuperApps are **one giant program trying to be everything
at once.** That design has a hidden cost:

- When one feature breaks, the whole thing can go down.
- Every new feature makes it heavier, slower, and hungrier for memory.
- A single bad plugin or partner can potentially see *everything* inside the app.
- Only the platform owner can safely add to it — everyone else is locked out.

This is **SuperApp 1.0**: convenient on the outside, a fragile monolith on the inside.

### SuperApp 2.0: same convenience, built the right way

rmxOS is the platform for **SuperApp 2.0** — you keep the "do everything in one place"
experience users love, but instead of one giant blob, the app is built from **many
small, independent building blocks that snap together** — the way the web is built from
many pages and services rather than one enormous program.

What that gets you:

| SuperApp 1.0 (the monolith) | SuperApp 2.0 (on rmxOS) |
|---|---|
| One crash can take everything down | Each piece fails alone; the rest keeps running |
| Always-on, always eating memory | Pieces wake up when needed, sleep when idle — you pay for what you use |
| Everything can see everything | Each piece is walled off and only gets what it needs |
| Only the owner can extend it | A safe ecosystem — partners plug in without risk |
| Gets slower as it grows | Stays fast and lean as it grows |

### Why it matters to the business

- **Lower cost to run.** Idle features cost almost nothing because the system
  automatically parks what isn't in use. You're not paying to keep a hundred features
  "warm" 24/7.
- **More reliable.** No more "the whole app is down." Problems stay contained.
- **Trustworthy by design.** Every building block is *signed and verifiable*, and every
  action leaves an *audit trail*. That's the foundation for real privacy and for letting
  third parties safely extend your app.
- **A real ecosystem.** Because each piece is isolated and verifiable, you can open the
  platform to partners and developers without betting the whole app on their code.

**The pitch in one line:** *rmxOS gives you the all-in-one SuperApp experience your
users want — with the safety, efficiency, and openness of a modern, modular platform
underneath.*

---

# Version 2 — For technical (lightly hardcore) people

## rmxOS: a modular substrate for the SuperApp, built on UNIX bones

SuperApp 1.0 (WeChat, ChatGPT-as-platform) proved the demand: one surface, every
capability. But the dominant implementation is a **single long-running monolith** — one
process, one memory footprint, one blast radius, one trust domain. It doesn't fail
gracefully, it doesn't scale down, and it can't safely host untrusted extensions.

**SuperApp 2.0 keeps the product promise and drops the monolith.** The model: the app is
a *constellation of small UNIX processes*, composed like the web — loosely coupled,
independently deployable, individually replaceable. rmxOS is the OS that makes that model
cheap and first-class, because it ships the primitives a modular SuperApp actually needs:

### The building blocks

- **UNIX processes as the unit of composition.** Each capability (a channel, a plugin, a
  provider, an agent) is its own process with its own address space and its own fault
  boundary. A crash is contained; an upgrade is a process swap, not a redeploy of the
  world.

- **launchd as the orchestrator.** Modules are **demand-activated**: launchd loads a
  process on first use and unloads it when idle. Your hundred-feature SuperApp doesn't
  run a hundred resident daemons — it runs the handful that are actually in use right now.

- **notifyd for lightweight coordination.** A fast, cheap publish/subscribe signaling
  plane so modules can coordinate state without heavyweight channels or constant polling.
  It's the nervous system between the parts.

- **OpenZFS snapshots + clones for copy-on-write state sharing.** Modules **fork shared
  state via ZFS snapshots** instead of copying or fighting over it. Every fork is a cheap
  CoW view; writes diverge without clobbering the parent. That's near-instant,
  space-efficient state forking for per-session, per-tenant, or per-experiment isolation.

- **libdispatch / `pthread_workqueue` for elastic concurrency.** Threads are **spun up
  under load, parked and retired when idle**, with width managed by the runtime rather
  than the app. Many small processes don't each explode their own thread pool —
  concurrency tracks actual work, so you stay inside a bounded memory budget instead of
  drowning in idle threads.

- **Mach IPC / XPC as first-class transport.** The inter-module boundary is a **real,
  typed, efficient IPC layer**, not ad-hoc sockets and JSON-over-a-pipe glued on
  afterward. XPC makes "many small processes talking constantly" fast, ergonomic, and the
  *default* — which is exactly what a decomposed SuperApp lives or dies on.

- **Code signing + audit trail as the root of privilege separation.** Every process is
  **signed and verifiable**, and its actions are **auditable**. That's the substrate for
  real least-privilege: each module is granted only the capabilities it needs, its
  provenance is checkable, and its behavior is traceable. This is what lets you host
  third-party and untrusted extensions *inside* the SuperApp without handing them the keys.

### The thesis

SuperApp 1.0 chose the monolith because the underlying platforms made decomposition
expensive — process spawn, IPC, state sharing, and concurrency were all costly enough
that "one big process" won by default. **rmxOS changes the cost curve.** On a Darwin/Mach
userland, demand-activation, first-class IPC, CoW state forking, and kernel-managed
concurrency are cheap and native — so the *modular* architecture becomes the *efficient*
one.

**SuperApp 2.0 = the convenience of the monolith, factored into the process model the
monolith was avoiding.** rmxOS is the platform where that factoring is the path of least
resistance.
