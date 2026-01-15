{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # Walker config + theme (declarative)
  #
  # Why:
  # - `walker` errors if `~/.config/walker` doesn't exist.
  # - Keep launcher behavior reproducible.
  # - Provide a minimal dark theme so it's not a blinding white box.
  #
  # Notes:
  # - Walker reads config from `~/.config/walker/config.toml`.
  # - Themes live under `~/.config/walker/themes/<name>/style.css`.
  xdg.enable = true;

  xdg.configFile."walker/config.toml".text = ''
    # Minimal Walker configuration (generated declaratively by Home Manager)
    #
    # Why:
    # - Prevents `walker` from erroring about missing config dir.
    # - Keeps launcher behavior reproducible.
    theme = "arik-dark"

    [placeholders.default]
    input = "Search"
    list = "Results"
  '';

  xdg.configFile."walker/themes/arik-dark/style.css".text = ''
    /*
      Walker theme: arik-dark

      Goal:
      - Minimal dark theme override so Walker isn't a blinding white box.
      - Keep it small; Walker themes inherit from default by default.
    */

    window {
      background: rgba(29, 32, 33, 0.92);
      color: #ebdbb2;
    }

    entry {
      background: rgba(60, 56, 54, 0.85);
      color: #fbf1c7;
      border: 1px solid rgba(80, 73, 69, 0.90);
      border-radius: 10px;
      padding: 8px 10px;
    }

    list {
      background: transparent;
      color: #ebdbb2;
    }

    row {
      padding: 6px 10px;
      border-radius: 10px;
    }

    row:selected {
      background: rgba(60, 56, 54, 0.90);
      color: #fbf1c7;
    }
  '';
}
