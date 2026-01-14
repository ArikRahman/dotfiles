# Task Plan: Fix Bash `fg: current: no such job` + `[ble: exit 1]` caused by ble.sh integration

## Goal
Eliminate the recurring Bash prompt-time error:
- `bash: fg: current: no such job`
- `[ble: exit 1]`

…by fixing the Home Manager Bash + ble.sh configuration so it is valid Bash, robust in interactive shells, and does not trigger job-control operations when no job exists.

## Scope / Constraints
- Change only Nix/Home Manager config (`dotfiles/home.nix`) unless a smaller, more appropriate place exists.
- Be conservative about deleting lines: comment out old config and annotate why.
- Ensure the fix compiles: run `nix flake check` after changes.
- Capture any troubleshooting output into a log file (repo workflow).

## Current Suspected Root Cause (from `home.nix`)
- `bashrcExtra` contains a literal `...` which is not valid Bash and can cause unpredictable execution.
- ble.sh is sourced with `--attach=none` then manually attached; attach/hook timing may interact with job-control or prompt hooks and end up calling `fg` (directly or indirectly), producing `fg: current: no such job`.

## Phases

### Phase 1 — Reproduce + isolate
- [ ] Confirm the error happens only when ble is enabled in Bash.
- [ ] Confirm it does not happen with `bash --noprofile --norc`.
- [ ] Record results in `notes.md` (include exact terminal, shell, and steps).

**Exit criteria:** We can clearly attribute the error to the ble.sh Bash integration.

### Phase 2 — Implement a safe Bash integration
- [ ] Replace the invalid Bash snippet with a minimal, valid, guarded block:
  - Source ble.sh only for interactive shells (`[[ $- == *i* ]]`).
  - Remove the `...` line.
  - Prefer simple `source ble.sh` default attach, OR keep `--attach=none` but only `ble-attach` when safe.
- [ ] Comment out the old block; add a short “what was wrong / how corrected” note per repo guidelines.

**Exit criteria:** `bashrcExtra` is valid Bash, deterministic, and uses a single attach strategy.

### Phase 3 — Validate via Nix
- [ ] Run `nix flake check` and ensure it passes.
- [ ] Record the command + output summary in `Appendix.md` if any manual command was required.
- [ ] If diagnostics arise, make 1–2 attempts to fix; then stop and ask for user input.

**Exit criteria:** `nix flake check` succeeds.

### Phase 4 — Runtime verification
- [ ] Open a new Bash interactive shell and run a few commands (`ls`, `true`, `false`, background job `sleep 1 &`) and verify no prompt-time `fg` errors.
- [ ] If still present, proceed with fallback options (below).

**Exit criteria:** No `fg`/ble exit noise during normal interactive use.

## Fallback Options (if Phase 2 doesn’t fully solve it)
- Option A: Disable ble.sh for Bash entirely and keep it only where desired (e.g., other shells).
- Option B: Pin attach behavior: always `--attach=none` and attach only after prompt init; avoid conflicting prompt frameworks.
- Option C: Add a guard to prevent job-control operations when `jobs` is empty (only if we can identify the specific hook invoking `fg`).

## Deliverables
- `dotfiles/home.nix` updated with a safe ble.sh Bash config (old lines commented, annotated).
- `dotfiles/manus/bash-fg-ble/notes.md` containing repro steps + verification.
- (Optional) `dotfiles/troubleshooting.md` entry if the issue requires deeper investigation.

## Progress Log
- Status: Planned (no changes applied yet in this file)
- Next action: Document repro + confirm ble isolation, then patch `bashrcExtra`.