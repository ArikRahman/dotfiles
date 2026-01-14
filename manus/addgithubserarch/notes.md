# Notes: GitHub CLI and Alias Implementation

- Project uses Nushell as the default shell.
- User wants `@gh` as an alias for `gh` (GitHub CLI).
- `gh` is already present in `home.packages` in `home.nix`.
- `config.nu` is used as the Nushell configuration file (sourced via `home.nix`).
- `Appendix.md` already contains instructions for `gh auth login` and `gh auth git-credential`.
- Plan: Add `alias @gh = gh` to `config.nu`.