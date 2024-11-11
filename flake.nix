{
  description = "A very basic flake";

  inputs = {
    # nixpkgs is only included so I can control the version used by nixvimchad
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvimchad.url = "github:thecolorman/nixvimchad";
    nixvimchad.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {nixvimchad, self, ...}:
    nixvimchad.configure ({pkgs,...}:  (import ./nixvim.nix) // {
      extraPackages = with pkgs; [ nixd ];

      chad.plugins.lspconfig.pluginConfig.config = ''
        function()
          require("nvchad.configs.lspconfig").defaults()
          
          local lspconfig = require "lspconfig"
          
          local servers = { "nixd" }
          local nvlsp = require "nvchad.configs.lspconfig"
          
          for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup {
              on_attach = nvlsp.on_attach,
              on_init = nvlsp.on_init,
              capabilities = nvlsp.capabilities,
            }
          end
        end
      '';
    });
  }
