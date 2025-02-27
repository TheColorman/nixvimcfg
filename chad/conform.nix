{}: {
  pluginConfig = {
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
}
