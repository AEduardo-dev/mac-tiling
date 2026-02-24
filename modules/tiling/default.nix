{ config, lib, pkgs, ... }:

let
  cfg = config.modules.tiling;
in
{
  imports = [
    ./aerospace.nix
    ./sketchybar.nix
    ./jankyborders.nix
  ];

  options.modules.tiling = {
    enable = lib.mkEnableOption "Hyprland-like tiling setup (AeroSpace + SketchyBar + JankyBorders)";
  };
}
