{
  description = "Hyprland-like tiling setup for macOS using AeroSpace + SketchyBar + JankyBorders";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    darwinModules = {
      tiling = import ./modules/tiling;
      default = self.darwinModules.tiling;
    };
  };
}
