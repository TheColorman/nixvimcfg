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
          opts.__raw = ''{
            config = {
              on_init = function(client)
                  -- client.offset_encoding = "utf-8"
              end,
              handlers = {
                  ["textDocument/hover"] = function(err, result, ctx, config)
                      if result and result.contents and result.contents.value then
                          result.contents.value = result.contents.value:gsub("\\([^%w])", "%1")
                      end
                      vim.lsp.handlers["textDocument/hover"](err, result, ctx, config)
                  end,
              },
              on_attach = function(client, bufnr)
                  vim.api.nvim_set_keymap(
                      "n",
                      "gd",
                      "<cmd>lua vim.lsp.buf.definition()<CR>",
                      { noremap = true, silent = true }
                  )
                  vim.api.nvim_set_keymap(
                      "n",
                      "gD",
                      "<cmd>lua vim.lsp.buf.declaration()<CR>",
                      { noremap = true, silent = true }
                  )
                  vim.api.nvim_set_keymap(
                      "n",
                      "gi",
                      "<cmd>lua vim.lsp.buf.implementation()<CR>",
                      { noremap = true, silent = true }
                  )
              end,
              settings = {
                  ["csharp|inlay_hints"] = {
                      csharp_enable_inlay_hints_for_implicit_object_creation = true,
                      csharp_enable_inlay_hints_for_implicit_variable_types = true,
                      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                      csharp_enable_inlay_hints_for_types = true,
                      dotnet_enable_inlay_hints_for_indexer_parameters = true,
                      dotnet_enable_inlay_hints_for_literal_parameters = true,
                      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
                      dotnet_enable_inlay_hints_for_other_parameters = true,
                      dotnet_enable_inlay_hints_for_parameters = true,
                      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
                      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
                      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
                  },
                  -- ["csharp|background_analysis"] = {
                  --     dotnet_compiler_diagnostics_scope = "fullSolution",
                  --     dotnet_analyzer_diagnostics_scope = "fullSolution",
                  -- },
                  ["csharp|code_lens"] = { dotnet_enable_references_code_lens = true },
              },
            },
            exe = "Microsoft.CodeAnalysis.LanguageServer",
            args = {
                "--logLevel=Information", "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path())
            },
            filewatching = true,
            choose_target = nil,
            ignore_target = nil,
            broad_search = false,
            lock_target = false,
          }'';
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
        conform.pluginConfig = {
          opts = {
            formatters_by_ft = {
              lua = ["stylua"];
              cs = ["csharpier"];
              css = ["prettier"];
              html = ["prettier"];
              vue = ["prettier"];
              typescript = ["prettier"];
            };
            format_after_save = {
              timeout_ms = 500;
              lsp_fallback = true;
            };
          };
          config.__raw = ''
            function(_, opts)
              local conform = require("conform")

              conform.setup(opts)

              conform.formatters.csharpier = {
                args = { "--write-stdout", "--no-cache", "$FILENAME" },
              }
            end
          '';
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
