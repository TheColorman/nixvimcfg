{
  description = "A very basic flake";

  inputs = {
    # nixpkgs is only included so I can control the version used by nixvimchad
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvimchad.url = "github:thecolorman/nixvimchad";
    nixvimchad.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {nixvimchad, ...}:
    nixvimchad.configure ({pkgs,...}:  let
      roslyn-nvim = pkgs.vimUtils.buildVimPlugin {
        pname = "roslyn.nvim";
        version = "2025-02-20";
        src = pkgs.fetchFromGitHub {
          owner = "seblyng";
          repo = "roslyn.nvim";
          rev = "633a61c30801a854cf52f4492ec8702a8c4ec0e9";
          hash = "sha256-PX0r8TFF/Y22zmx+5nYpbNjwKg4nk2N5U41uYE7YnE8=";
        };
      };

      mergedAttrs = (import ./nixvim/mappings.nix {});
    in mergedAttrs // {
      extraPackages = with pkgs; [
        nixd
        svelte-language-server
      ];

      plugins.lazy.plugins = [
        (import ./plugins/roslyn-nvim.nix { inherit roslyn-nvim; })
        (import ./plugins/instant-nvim.nix { inherit (pkgs.vimPlugins) instant-nvim; })
      ];

      chad.plugins = {
        lspconfig = (import ./chad/lspconfig.nix {});
        conform = (import ./chad/conform.nix {});
        cmp = (import ./chad/cmp.nix {});
        treesitter = (import ./chad/treesitter.nix {});
      };
    });
  }
