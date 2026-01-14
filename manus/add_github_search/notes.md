# Research Notes: GitHub Search Engine

## GitHub Search URL Pattern
- Standard search URL: `https://github.com/search?q={searchTerms}`
- Alternatively, for code/repos: `https://github.com/search?q={searchTerms}&type=repositories`
- The user requested a general `@gh` shortcut, so the base search is most appropriate.

## Favicon URL
- GitHub favicon: `https://github.com/favicon.ico`

## Implementation Details
- Target file: `home.nix`
- Target location: `programs.firefox.profiles.default.search.engines.Add` (or equivalent in the `zenWrapped` definition)
- New entry:
  ```nix
  {
    Name = "GitHub";
    URLTemplate = "https://github.com/search?q={searchTerms}";
    IconURL = "https://github.com/favicon.ico";
    Alias = "@gh";
  }
  ```
