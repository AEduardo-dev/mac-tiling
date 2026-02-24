{
  description = "Hyprland-like tiling setup for macOS using AeroSpace + SketchyBar + JankyBorders";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, nix-darwin, ... }:
    let
      forEachDarwinSystem = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) [ "aarch64-darwin" "x86_64-darwin" ]);
    in
    {
      darwinModules = {
        tiling = import ./modules/tiling;
        default = self.darwinModules.tiling;
      };

      checks = forEachDarwinSystem (system: {
        eval = (import ./checks/eval-darwin.nix {
          inherit nix-darwin nixpkgs system;
          tilingModule = self.darwinModules.tiling;
        }).system;
      });
    };
}
