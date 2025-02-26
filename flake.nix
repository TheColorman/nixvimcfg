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
    in (import ./nixvim.nix) // {
      extraPackages = with pkgs; [ nixd svelte-language-server ];

      plugins.lazy.plugins = [
        {
          pkg = roslyn-nvim;
          ft = "cs";
          opts = {};
        }
      ];

      chad.plugins = {
        lspconfig.pluginConfig.config = ''
          function()
            require("nvchad.configs.lspconfig").defaults()

            local lspconfig = require "lspconfig"

            local servers = { "nixd", "svelte", "clangd", "ruff", "dockerls" }
            local nvlsp = require "nvchad.configs.lspconfig"

            for _, lsp in ipairs(servers) do
              lspconfig[lsp].setup {
                on_attach = nvlsp.on_attach,
                on_init = nvlsp.on_init,
                capabilities = nvlsp.capabilities,
              }
            end

            lspconfig.docker_compose_language_service.setup {
              on_attach = nvlsp.on_attach,
              on_init = nvlsp.on_init,
              capabilities = nvlsp.capabilities,
              filetypes = { "yaml.docker-compose", "yaml.docker-stack" },
            }
          end
        '';
        conform.pluginConfig.opts = {
          formatters_by_ft = {lua = ["stylua"];};
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
        };

        cmp.pluginConfig.opts.__raw = ''
          function ()
            -- Inherited from the nixvimchad cmp.nix plugin
            local config = require "nvchad.configs.cmp"
            local cmp = require "cmp"

            -- Removes the default Enter map to accept a suggestion, uses ctrl+y instead
            config.mapping["<CR>"] = nil
            config.mapping["<C-y>"] = cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Insert,
              select = true,
            }
            return config
          end
        '';
      };
    });
  }
