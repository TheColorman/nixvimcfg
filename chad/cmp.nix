{ }: {
  pluginConfig.opts.__raw = ''
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
}
