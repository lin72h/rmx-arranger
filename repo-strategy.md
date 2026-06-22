# Repository Strategy

This document governs how the FreeBSD source tree at
`freebsd-src-stable-15` is maintained as a long-lived fork with Mach
kernel integration.

## Principles

1. Never rebase local work onto upstream. Always merge.
2. Upstream FreeBSD history is preserved exactly on a tracking branch.
3. Local commits are permanent. No force-push, no history rewriting.
4. Conflict resolution happens once per merge, not once per commit.
5. Generated files are never hand-resolved. They are regenerated from
   their source.

## Branch Model

```
upstream/stable/15          FreeBSD official (read-only, git fetch)
        |
        v  fast-forward only
stable/15                   Local tracking branch
        |
        v  periodic merge
main                        Integration branch (upstream + local)
```

### Branch rules

| Branch | Rule |
| --- | --- |
| `stable/15` | Tracks `upstream/stable/15` exactly. Only fast-forward merges. Never commit directly. |
| `main` | All local Mach work lives here. Receives merges from `stable/15`. Push to `origin` and `backup`. |

Topic branches (`rmx/topic-name`) may be used for experimental work.
Merge into `main` when ready. Delete after merge.

## Remotes

| Remote | URL | Purpose |
| --- | --- | --- |
| `upstream` | `git@github.com:freebsd/freebsd-src.git` | FreeBSD official. Read-only. |
| `origin` | `git@github.com:lin72h/rmxOS.git` | GitHub fork. Push when history shape is suitable. |
| `backup` | `../remotes/rmxOS.git` | Local bare mirror. Push after every committed checkpoint. |

## Why Merge, Not Rebase

The project modifies `sys/kern/syscalls.master` and 13 generated output
files. FreeBSD modifies these files regularly. In a rebase workflow:

- Every upstream commit that touches `syscalls.master` creates a conflict
  in 14 files.
- Each conflict must be resolved for every rebased commit (N conflicts
  times M local commits).
- Force-push is required after every rebase, destroying remote history.
- Multiple agents cannot safely work on a rebased branch.

In a merge workflow:

- Conflicts are resolved once per merge, regardless of how many upstream
  commits are in the merge.
- History is permanent. No force-push.
- Multiple agents can work on `main` simultaneously.
- `git diff stable/15..main` always shows exactly the local delta.

## Upstream Sync Procedure

### When to sync

| Phase | Frequency |
| --- | --- |
| Design and planning | Monthly or before each milestone |
| Active development and testing | Weekly |
| Before any release or branch cut | Immediately |

### Steps

```sh
# 1. Fetch latest FreeBSD
git fetch upstream

# 2. Fast-forward the tracking branch
git checkout stable/15
git merge --ff-only upstream/stable/15

# 3. Merge into main
git checkout main
git merge stable/15
```

If the merge is clean, commit and push. If there are conflicts, see the
next section.

### Conflict resolution

#### syscalls.master and generated files

This is the most common conflict. Procedure:

1. Open `sys/kern/syscalls.master` and resolve the conflict.
   The Mach syscall block starts after the standard FreeBSD syscalls.
   Usually the resolution is: keep the upstream additions, keep our Mach
   block, adjust any line-number offsets.

2. Regenerate ALL output files from the merged master:

   ```sh
   cd freebsd-src-stable-15
   /usr/libexec/flua sys/tools/syscalls/main.lua sys/kern/syscalls.master
   ```

3. Stage the regenerated files:

   ```sh
   git add sys/kern/init_sysent.c sys/kern/syscalls.c sys/kern/systrace_args.c
   git add sys/sys/syscall.h sys/sys/syscall.mk sys/sys/sysproto.h
   git add lib/libsys/_libsys.h lib/libsys/syscalls.map
   git add sys/compat/freebsd32/freebsd32_syscall.h
   git add sys/compat/freebsd32/freebsd32_syscalls.c
   git add sys/compat/freebsd32/freebsd32_sysent.c
   git add sys/compat/freebsd32/freebsd32_systrace_args.c
   ```

4. Complete the merge commit.

Never hand-edit generated syscall files. Always regenerate.

#### proc.h, event.h, file.h, conf/options

These conflicts are rare and usually trivial. Our changes are small
(3-6 lines each) at a specific offset. Upstream changes are usually
elsewhere in the file. Resolution: take both sides, adjust offsets if
the struct layout changed.

#### kern/kern_event.c

Rare. Our change is one line in the filter registration table. If
upstream adds a new filter, adjust the table position.

#### Files under sys/compat/mach/ and sys/sys/mach/

These directories do not exist in upstream FreeBSD. They will never
conflict with upstream merges.

### Conflict frequency expectations

| File | Frequency | Difficulty |
| --- | --- | --- |
| `sys/kern/syscalls.master` | Monthly | Mechanical: merge then regenerate |
| 13 generated syscall files | When master conflicts | Always regenerate, never hand-resolve |
| `sys/sys/proc.h` | Quarterly | Trivial: adjust offset of our 3-line addition |
| `sys/sys/event.h` | Rare | Trivial: adjust EVFILT number if new filters added |
| `sys/conf/options` | Rare | Trivial: adjust line position |
| `sys/sys/file.h` | Rare | Trivial: adjust DTYPE number if new types added |
| `sys/kern/kern_event.c` | Rare | Trivial: adjust table position |
| Everything in `sys/compat/mach/` | Never | N/A |
| Everything in `sys/sys/mach/` | Never | N/A |

## Commit Conventions

### Message format

```
mach: <short summary in imperative mood>

<paragraph explaining what and why>

Upstream-Base: <FreeBSD stable/15 commit hash at time of commit>
NextBSD-Origin: <donor hash> <original subject>   # when applicable
Generated-By: <tool/revision>                      # when applicable
Rebase-Notes: <what was adapted for FreeBSD 15>    # when applicable
```

### Rules

1. Separate FreeBSD-modifying changes from pure additions in different
   commits. This keeps the conflict surface visible and resolutions
   obvious.

2. When modifying `syscalls.master`, always regenerate and include the
   generated files in the same commit.

3. Each commit should be a logical unit that can be reviewed
   independently.

4. Keep unrelated FreeBSD 15 adaptation commits separate from Mach logic
   changes.

5. When a commit corresponds to a NextBSD donor commit, preserve the
   original subject line and author attribution in the commit body.

## Adding New Mach Features

When new kernel work is committed (e.g., IPC hardening, module-to-kernel
migration):

1. If the change only touches `sys/compat/mach/` or `sys/sys/mach/`:
   commit freely. Zero conflict risk with upstream.

2. If the change modifies an existing FreeBSD file: make a separate,
   small commit for the FreeBSD changes. Document why the hook is
   needed.

3. If the change adds or modifies entries in `syscalls.master`:
   regenerate outputs in the same commit.

4. If the change adds a new FreeBSD struct field, kqueue filter, file
   type, or kernel option: gate it behind `#ifdef COMPAT_MACH` when
   possible.

## Useful Commands

```sh
# Show exactly our delta from upstream
git diff stable/15..main

# Show just our commits (excluding merges)
git log stable/15..main --no-merges

# Show merge history for a clean timeline
git log --first-parent main

# Show which FreeBSD files we modify
git diff stable/15..main --stat -- ':!sys/compat/mach' ':!sys/sys/mach' \
    ':!sys/sys/mach_debug' ':!sys/modules/mach' ':!include/apple' ':!include/mach' \
    ':!include/Availability*' ':!include/TargetConditionals.h'

# Count our total delta
git diff stable/15..main --shortstat
```

## Backup Procedure

After every committed checkpoint:

```sh
git push backup main
git push backup stable/15
```

Important:

1. Only committed state is backed up by git push.
2. Uncommitted changes remain only in the working tree.
3. The local bare backup at `../remotes/rmxOS.git` is the insurance
   copy. GitHub (`origin`) is secondary.
