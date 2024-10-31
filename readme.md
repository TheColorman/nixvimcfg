# Colorman's NixVim config

Neovim configuration built using [NixVim](https://github.com/nix-community/nixvim). This configuration is an extension of my [NixvimChad](https://github.com/thecolorman/nixvimchad) config. NixvimChad is a base NixVim configuration that aims to mimic [NvChad](https://nvchad.com) as closely as possible. See the NixvimChad repository to find out how you can make your own NvChad-based config.

## Trying out

You can test out the configuration with the following command:

```bash
nix run github:thecolorman/nixvimcfg
# or edit a file
nix run github:thecolorman/nixvimcfg -- file.nix
```

> [!IMPORTANT]
> I am [Colemak](https://colemak.org) user (Colemak-DH specifically) and so I have remapped common keys such as home row navigation to better suit the keyboard layout.

## Theme

This config doesn't have a theme, as all my theming is generated and managed by [Stylix](https://stylix.danth.me/) (see my Stylix config [here](https://github.com/TheColorman/nixcfg/blob/master/modules/profiles/stylix/default.nix)). I match my themes to my wallpaper, and I switch my wallpaper every 6 months.
