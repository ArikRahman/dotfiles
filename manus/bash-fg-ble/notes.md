# Notes: bash `fg: current: no such job` + `[ble: exit 1]`

## Symptom
In an interactive shell, after a simple command like `ls`, the terminal prints:

- `bash: fg: current: no such job`
- `[ble: exit 1]`

This strongly suggests **ble.sh (Bash Line Editor)** is active and some ble-related hook is causing `fg` to run when there is no current stopped job.

## What the messages mean
- `bash: fg: current: no such job`
  - `fg` only works if there is a “current job” (a stopped/backgrounded job in the current shell).
  - This message happens when `fg` is invoked but **job control has nothing to foreground**.

- `[ble: exit 1]`
  - This prefix is emitted by **ble.sh** when a ble hook / internal command exits with non-zero status.
  - The timing (immediately after a command) aligns with ble executing code from prompt hooks (`PROMPT_COMMAND`, `DEBUG` trap, `precmd`-like handlers).

## Most likely root cause (config-level)
In `dotfiles/home.nix`, Bash is configured:

- `programs.bash.enable = true;`
- `programs.bash.bashrcExtra` contains:

  - `source "$(blesh-share)"/ble.sh --attach=none`
  - a literal `...`
  - `ble-attach`

Concerns:
1. `...` is **not valid bash**; if it is literally present in the generated `~/.bashrc`, Bash will attempt to execute it as a command and it will fail (exit 127). That could cascade into ble error handling, depending on where it appears relative to ble initialization.

2. Using `--attach=none` and then calling `ble-attach` later can be correct, but it is more fragile than simply attaching once in an interactive shell. Any prompt/job-control-related behavior while partially initialized can lead to weirdness.

## Why ble.sh is implicated (evidence)
- The `[ble: ...]` marker is direct evidence ble.sh is loaded.
- The error appears after running normal commands (like `ls`), which is when prompt hooks run.
- `fg` is not normally called by bash itself post-command; it’s typically invoked by shell functions, keybindings, or prompt frameworks.

## Expected verification steps (if/when checking manually)
Without changing config, you can verify quickly:

- Confirm ble is loaded:
  - `echo $BLE_VERSION`
- Bypass all rc scripts:
  - `bash --noprofile --norc`
  - If the issue disappears here, the problem is in `.bashrc`/HM-generated content, not in bash itself.

## Proposed remediation direction
Make `bashrcExtra`:
- valid bash only (remove literal `...`)
- only load ble in interactive shells
- avoid split attach flow unless needed

Safer pattern:
- `case $- in *i*) ... ;; esac`
- `source "$(blesh-share)/ble.sh"` (default attach) OR explicitly attach once correctly

## Mistake / correction log (for this investigation)
- Mistake: initial assumption was “bash is broken”.
- Correction: the presence of `[ble: exit 1]` and the configuration that loads ble.sh indicates the breakage is in **ble.sh integration / `.bashrc` content**, not bash itself.

## Notes about Nix/Home Manager context
- The bash integration is being managed via Home Manager (`programs.bash`).
- Fix should be implemented in `dotfiles/home.nix` so it is reproducible and doesn’t require ad-hoc edits in `~/.bashrc`.