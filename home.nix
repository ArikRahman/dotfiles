{ pkgs, ... }:
{
  home.username = "arik";
  home.homeDirectory = "/home/arik";
  home.stateVersion = "25.05";

   #Have to use this command:
    #home-manager switch --flake . --impure

  #found out from 
    #code --verbose ./

  #to use
    # code ./ --no-sandbox

  #Also need this command on nu
    #$env.NIXPKGS_ALLOW_UNFREE = "1"


  programs.home-manager.enable = true;
  #nixGL.vulkan.enable = true;

  # Enable Nushell
  # programs.nushell.enable = true;
  # programs.nushell.plugins = with pkgs.nushellPlugins; [
  #   nu-bookmarks
  #   nu-fetch
  #   nu-history
  #   nu-ls
  #   nu-nix
  #   nu-pkgs
  #   nu-web-get
  # ];

  programs = {
    vscode = {
      enable = true;
      profiles = {
        default = {
          extensions = with pkgs.vscode-extensions; [
            dracula-theme.theme-dracula
            #vscodevim.vim
           
            yzhang.markdown-all-in-one
          ];
        };
      };
    };

    # zed-editor = {
    #   enable = true;
    #   extensions = [ "nix" "toml" "rust" ];
    #   userSettings = {
    #     theme = {
    #       mode = "system";
    #       dark = "One Dark";
    #       light = "One Light";
    #     };
    #     hour_format = "hour24";
    #     vim_mode = true;
    #   };
    # };

    # doom-emacs = {
    #   enable = false;
    #   doomDir = ./.doom.d; # or e.g. `./doom.d` for a local configuration
    # };

    nushell = {
      enable = true;
      # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
      # configFile.source = ./config.nu;
      extraConfig = ''
        # yazi 'y' alias
        def --env y [...args] {
          let tmp = (mktemp -t "yazi-cwd.XXXXXX")
          yazi ...$args --cwd-file $tmp
          let cwd = (open $tmp)
          if $cwd != "" and $cwd != $env.PWD {
            cd $cwd
          }
          rm -fp $tmp
        }
        # end

        let carapace_completer = {|spans|
          carapace $spans.0 nushell ...$spans | from json
        }

        $env.config = {



         show_banner: false,


         completions: {


         case_sensitive: false # case-sensitive completions


         quick: true    # set to false to prevent auto-selecting completions


         partial: true    # set to false to prevent partial filling of the prompt


         algorithm: "fuzzy"    # prefix or fuzzy


         external: {


         # set to false to prevent nushell looking into $env.PATH to find more suggestions


             enable: true


         # set to lower can improve completion performance at the cost of omitting some options


             max_results: 100


             completer: $carapace_completer # check 'carapace_completer'


           }


         }
        }

        $env.PATH = ($env.PATH |
          split row (char esep) |
          prepend /home/myuser/.apps |
          append /usr/bin/env
        )
      '';
      shellAliases = {
        vi = "hx";
        vim = "hx";
        lz = "lazygit";
        # nano = "hx";
      };
    };

    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    yazi.enable = true;
    zoxide.enable = true;

    atuin = {
      enable = true;
      settings = {
        # auto_sync = true;
        # sync_frequency = "5m";
        # sync_address = "https://api.atuin.sh";
        search_mode = "fuzzy";
      };
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };

  home.packages = with pkgs; [
    nixfmt-rfc-style
    cowsay
    # nil
    # nixd
    lazygit
    # neohtop
    fastfetch
    zoxide
    # zed-editor
    vulkan-tools
    # github-desktop
    cachix
    # vscodium
    # vscode
    # zed-editor
    discordo
    just
    fzf
    fd
    ripgrep
    bat
    dust
    tree
    git
  ];
}