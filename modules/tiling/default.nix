{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./aerospace.nix
    ./sketchybar.nix
    ./jankyborders.nix
  ];

  options.modules.tiling = {
    enable = lib.mkEnableOption "Hyprland-like tiling setup (AeroSpace + SketchyBar + JankyBorders)";
  };
}
