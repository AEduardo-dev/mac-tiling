{ config, lib, pkgs, ... }:

let
  cfg = config.modules.tiling.sketchybar;

  sketchybarConfigDir = pkgs.stdenv.mkDerivation {
    name = "sketchybar-config";
    src = ./sketchybar;
    installPhase = ''
      mkdir -p $out
      cp -r $src/* $out/

      substituteInPlace $out/sketchybarrc \
        --replace-fail "@BAR_COLOR@" "${cfg.theme.barColor}" \
        --replace-fail "@BAR_BORDER_COLOR@" "${cfg.theme.barBorderColor}" \
        --replace-fail "@ICON_COLOR@" "${cfg.theme.iconColor}" \
        --replace-fail "@LABEL_COLOR@" "${cfg.theme.labelColor}" \
        --replace-fail "@ACCENT_COLOR@" "${cfg.theme.accentColor}" \
        --replace-fail "@BAR_HEIGHT@" "${toString cfg.theme.barHeight}" \
        --replace-fail "@BAR_POSITION@" "${cfg.theme.barPosition}" \
        --replace-fail "@PLUGIN_DIR@" "$out/plugins"

      substituteInPlace $out/plugins/aerospace.sh \
        --replace-fail "@ACCENT_COLOR@" "${cfg.theme.accentColor}" \
        --replace-fail "@LABEL_COLOR@" "${cfg.theme.labelColor}" \
        --replace-fail "@ICON_COLOR@" "${cfg.theme.iconColor}"

      chmod +x $out/plugins/*.sh
    '';
  };

in
{
  options.modules.tiling.sketchybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.tiling.enable;
      description = "Enable SketchyBar status bar";
    };

    theme = {
      barColor = lib.mkOption { type = lib.types.str; default = "0xff1e1e2e"; description = "Bar background color (ARGB hex)"; };
      barBorderColor = lib.mkOption { type = lib.types.str; default = "0xff313244"; description = "Bar border color (ARGB hex)"; };
      iconColor = lib.mkOption { type = lib.types.str; default = "0xffcdd6f4"; description = "Icon color (ARGB hex)"; };
      labelColor = lib.mkOption { type = lib.types.str; default = "0xffcdd6f4"; description = "Label color (ARGB hex)"; };
      accentColor = lib.mkOption { type = lib.types.str; default = "0xffcba6f7"; description = "Accent color for focused items (ARGB hex)"; };
      barHeight = lib.mkOption { type = lib.types.int; default = 32; description = "Bar height in pixels"; };
      barPosition = lib.mkOption { type = lib.types.str; default = "top"; description = "Bar position (top or bottom)"; };
    };
  };

  config = lib.mkIf cfg.enable {
    services.sketchybar = {
      enable = true;
      config = builtins.readFile "${sketchybarConfigDir}/sketchybarrc";
    };

    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  };
}
