{ }: {
  pluginConfig.config = ''
    function()
      require("nvchad.configs.lspconfig").defaults()

      local lspconfig = require "lspconfig"

      local servers = { "nixd", "svelte", "clangd", "ruff", "basedpyright", "dockerls" }
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
}
