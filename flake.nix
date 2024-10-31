{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixvimchad.url = "github:thecolorman/nixvimchad";
    nixvimchad.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {nixvimchad, ...}:
    nixvimchad.configure ({pkgs,...}: {
      nixvimConfig = (import ./nixvim.nix) // {
        extraPackages = with pkgs; [ nixd ];
      };

      lspconfig.servers = [ "nixd" ];
    });
  }
