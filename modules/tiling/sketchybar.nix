{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.tiling.sketchybar;

  fixPathsScript = pkgs.writeScript "fix-config-dir.pl" ''
    use strict;
    use warnings;
    my $replacement = $ARGV[0];
    while (my $file = <STDIN>) {
        chomp $file;
        open my $fh, '<', $file or next;
        my $content = do { local $/; <$fh> };
        close $fh;
        $content =~ s/\$\{CONFIG_DIR:-[^}]*\}/$replacement/g;
        $content =~ s/\$\{CONFIG_DIR\}/$replacement/g;
        $content =~ s/\$CONFIG_DIR/$replacement/g;
        open $fh, '>', $file or next;
        print $fh $content;
        close $fh;
    }
  '';

  sketchybarConfigDir = pkgs.stdenv.mkDerivation {
    name = "sketchybar-config";
    src = ./sketchybar;
    dontBuild = true;
    nativeBuildInputs = [pkgs.perl];
    installPhase = ''
      mkdir -p $out
      cp -r $src/* $out/
      chmod -R u+w $out

      find $out -type f \( -name "*.sh" -o -name "sketchybarrc" -o -name "*.example" \) \
        | perl ${fixPathsScript} "$out"

      find $out -name "*.sh" -exec chmod +x {} \;
      chmod +x $out/sketchybarrc
      patchShebangs $out
    '';
    meta = {
      description = "SketchyBar configuration files (sketchybar-gray)";
      platforms = lib.platforms.darwin;
    };
  };

  widgetListToStr = widgets:
    if widgets == []
    then ""
    else lib.concatStringsSep " " widgets;
in {
  options.modules.tiling.sketchybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.tiling.enable;
      description = "Enable SketchyBar status bar";
    };

    theme = lib.mkOption {
      type = lib.types.enum [
        "onedark"
        "onelight"
        "nord"
        "tokyonight"
        "githubdark"
        "githublight"
        "gruvboxdark"
        "gruvboxlight"
        "ayudark"
        "ayulight"
        "blossomlight"
      ];
      default = "onedark";
      description = "Color theme for SketchyBar (one of the 11 built-in themes)";
    };

    barStyle = lib.mkOption {
      type = lib.types.enum ["block" "compact"];
      default = "block";
      description = "Bar style: 'block' (colored backgrounds per widget) or 'compact' (grouped sections)";
    };

    barHeight = lib.mkOption {
      type = lib.types.int;
      default = 37;
      description = "Bar height in pixels";
    };

    barPosition = lib.mkOption {
      type = lib.types.enum ["top" "bottom"];
      default = "top";
      description = "Bar position (top or bottom)";
    };

    barBackground = lib.mkOption {
      type = lib.types.enum ["transparent" "bg1"];
      default = "transparent";
      description = "Bar background: 'transparent' or 'bg1' (solid theme background color)";
    };

    weatherLocation = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Location for weather widget (e.g. 'New York', 'London'). Empty string uses the default location 'Seoul'.";
    };

    calendarFormat = lib.mkOption {
      type = lib.types.str;
      default = "YYYY-MM-DD";
      description = "Date format for the calendar widget (e.g. 'YYYY-MM-DD', 'ddd MM/DD')";
    };

    widgets = {
      left = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Widgets shown on the left side.";
      };
      center = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Widgets shown in the center.";
      };
      right = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Widgets shown on the right side.";
      };
    };

    fonts = {
      labelFamily = lib.mkOption {
        type = lib.types.str;
        default = "SpaceMono Nerd Font Mono";
        description = "Font family for labels and icons";
      };
      iconSize = lib.mkOption {
        type = lib.types.str;
        default = "18.0";
        description = "Icon font size";
      };
      labelSize = lib.mkOption {
        type = lib.types.str;
        default = "12.0";
        description = "Label font size";
      };
      appIconSize = lib.mkOption {
        type = lib.types.str;
        default = "13.5";
        description = "App icon font size (requires sketchybar-app-font)";
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
      extraPackages = [pkgs.jq pkgs.bc];
      config = let
        leftStr = widgetListToStr cfg.widgets.left;
        centerStr = widgetListToStr cfg.widgets.center;
        rightStr = widgetListToStr cfg.widgets.right;
        weatherLoc =
          if cfg.weatherLocation == ""
          then "Seoul"
          else cfg.weatherLocation;
      in ''
        #!/usr/bin/env bash

        # Nix-managed configuration — do not edit directly
        export SBAR_THEME="${cfg.theme}"
        export SBAR_BAR_STYLE="${cfg.barStyle}"
        export SBAR_BAR_HEIGHT=${toString cfg.barHeight}
        export SBAR_BAR_POSITION="${cfg.barPosition}"
        export SBAR_BAR_BACKGROUND="${cfg.barBackground}"
        export SBAR_WEATHER_LOCATION="${weatherLoc}"
        export SBAR_CALENDAR_FORMAT="${cfg.calendarFormat}"
        export SBAR_LABEL_FONT_FAMILY="${cfg.fonts.labelFamily}"
        export SBAR_ICON_FONT_SIZE="${cfg.fonts.iconSize}"
        export SBAR_LABEL_FONT_SIZE="${cfg.fonts.labelSize}"
        export SBAR_APP_ICON_FONT_SIZE="${cfg.fonts.appIconSize}"
        ${lib.optionalString (leftStr != "") ''export SBAR_WIDGETS_LEFT_ENABLED="${leftStr}"''}
        ${lib.optionalString (centerStr != "") ''export SBAR_WIDGETS_CENTER_ENABLED="${centerStr}"''}
        ${lib.optionalString (rightStr != "") ''export SBAR_WIDGETS_RIGHT_ENABLED="${rightStr}"''}

        export CONFIG_DIR="${sketchybarConfigDir}"
        source "${sketchybarConfigDir}/sketchybarrc"
      '';
    };

    environment.systemPackages = with pkgs; [
      jq
      bc
    ];

    system.defaults.NSGlobalDomain._HIHideMenuBar = cfg.hideMenuBar;
  };
}
