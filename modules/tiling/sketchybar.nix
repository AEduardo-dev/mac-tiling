{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.tiling.sketchybar;

  sketchybarConfigDir = pkgs.stdenv.mkDerivation {
    name = "sketchybar-config";
    src = ./sketchybar;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r $src/* $out/

      substituteInPlace $out/plugins/aerospace.sh \
        --replace-fail "@ACCENT_COLOR@" "${cfg.theme.accentColor}" \
        --replace-fail "@ICON_COLOR@" "${cfg.theme.iconColor}" \
        --replace-fail "@FOCUSED_ICON_COLOR@" "${cfg.theme.focusedIconColor}"

      chmod +x $out/plugins/*.sh
      chmod +x $out/sketchybarrc

      patchShebangs $out/sketchybarrc
      patchShebangs $out/plugins
    '';
    meta = {
      description = "SketchyBar configuration files";
      platforms = lib.platforms.darwin;
    };
  };
in {
  options.modules.tiling.sketchybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.tiling.enable;
      description = "Enable SketchyBar status bar";
    };

    theme = {
      barColor = lib.mkOption {
        type = lib.types.strMatching "0x[0-9a-fA-F]{8}";
        default = "0xff1e1e2e";
        description = "Bar background color (ARGB hex)";
      };
      barBorderColor = lib.mkOption {
        type = lib.types.strMatching "0x[0-9a-fA-F]{8}";
        default = "0xff313244";
        description = "Bar border color (ARGB hex)";
      };
      iconColor = lib.mkOption {
        type = lib.types.strMatching "0x[0-9a-fA-F]{8}";
        default = "0xffcdd6f4";
        description = "Icon color (ARGB hex)";
      };
      labelColor = lib.mkOption {
        type = lib.types.strMatching "0x[0-9a-fA-F]{8}";
        default = "0xffcdd6f4";
        description = "Label color (ARGB hex)";
      };
      accentColor = lib.mkOption {
        type = lib.types.strMatching "0x[0-9a-fA-F]{8}";
        default = "0xffcba6f7";
        description = "Accent color for focused items (ARGB hex)";
      };
      focusedIconColor = lib.mkOption {
        type = lib.types.strMatching "0x[0-9a-fA-F]{8}";
        default = "0xff1e1e2e";
        description = "Icon color on the focused workspace badge (ARGB hex)";
      };
      barHeight = lib.mkOption {
        type = lib.types.int;
        default = 32;
        description = "Bar height in pixels";
      };
      barPosition = lib.mkOption {
        type = lib.types.enum ["top" "bottom"];
        default = "top";
        description = "Bar position (top or bottom)";
      };
    };

    hideMenuBar = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Hide the native macOS menu bar when SketchyBar is enabled";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sketchybar = {
      enable = true;
      config = let
        template = builtins.readFile ./sketchybar/sketchybarrc;
      in
        lib.replaceStrings
        [
          "@BAR_COLOR@"
          "@BAR_BORDER_COLOR@"
          "@ICON_COLOR@"
          "@LABEL_COLOR@"
          "@ACCENT_COLOR@"
          "@BAR_HEIGHT@"
          "@BAR_POSITION@"
          "@PLUGIN_DIR@"
        ]
        [
          cfg.theme.barColor
          cfg.theme.barBorderColor
          cfg.theme.iconColor
          cfg.theme.labelColor
          cfg.theme.accentColor
          (toString cfg.theme.barHeight)
          cfg.theme.barPosition
          "${sketchybarConfigDir}/plugins"
        ]
        template;
    };

    system.defaults.NSGlobalDomain._HIHideMenuBar = cfg.hideMenuBar;
  };
}
