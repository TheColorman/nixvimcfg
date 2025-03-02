{ }: {
  pluginConfig.config = ''
    function()
      require("nvchad.configs.lspconfig").defaults()

      local lspconfig = require "lspconfig"
      local nvlsp = require "nvchad.configs.lspconfig"

      lspconfig.ts_ls.setup {
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
        -- Vue support
        init_options = {
          plugins = {
            {
              name = '@vue/typescript-plugin',
              location = '/home/boarder/node/node_modules/@vue/typescript-plugin',
              languages = { 'vue' },
            },
          },
        },
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
      }

      local servers = { "nixd", "svelte", "clangd", "ruff", "basedpyright", "dockerls", "volar" }

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

      lspconfig.eslint.setup {
        on_attach = function(client, bufnr)
          nvlsp.on_attach(client, bufnr)

          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
      }
    end
  '';
}
