# arranger0 — template for the Arranger role

The Arranger is a singleton, so its template lives inside its instance repo. `files/` holds the
Arranger's rendered instructions (`AGENTS.md`, `arranger-rulebook.md`); `template.json` names the
root template `rmx-role0` as parent. Change these files, then run `tools/roles render rmx-arranger`.
If a second Arranger is ever added, this directory moves out to `rmx-arranger0` and this repo
becomes `rmx-arranger1`.
