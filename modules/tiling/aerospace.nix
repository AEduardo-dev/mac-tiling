{ config, lib, pkgs, ... }:

let
  cfg = config.modules.tiling.aerospace;
in
{
  options.modules.tiling.aerospace = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.tiling.enable;
      description = "Enable AeroSpace tiling window manager";
    };

    gaps = {
      inner = {
        horizontal = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Inner horizontal gap between tiled windows";
        };
        vertical = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Inner vertical gap between tiled windows";
        };
      };
      outer = {
        top = lib.mkOption {
          type = lib.types.int;
          default = 38;
          description = "Top outer gap — increase to make room for SketchyBar";
        };
        bottom = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Bottom outer gap";
        };
        left = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Left outer gap";
        };
        right = lib.mkOption {
          type = lib.types.int;
          default = 8;
          description = "Right outer gap";
        };
      };
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra AeroSpace settings to merge with defaults";
    };
  };

  config = lib.mkIf cfg.enable {
    services.aerospace = {
      enable = true;
      settings = lib.recursiveUpdate {
        start-at-login = true;
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

        gaps = {
          inner = { horizontal = cfg.gaps.inner.horizontal; vertical = cfg.gaps.inner.vertical; };
          outer = { left = cfg.gaps.outer.left; bottom = cfg.gaps.outer.bottom; top = cfg.gaps.outer.top; right = cfg.gaps.outer.right; };
        };

        exec-on-workspace-change = [
          "${pkgs.bash}/bin/bash" "-c"
          "sketchybar --trigger aerospace_workspace_change AEROSP_FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE AEROSP_PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
        ];

        mode = {
          main.binding = {
            "alt-h" = "focus left";
            "alt-j" = "focus down";
            "alt-k" = "focus up";
            "alt-l" = "focus right";
            "alt-shift-h" = "move left";
            "alt-shift-j" = "move down";
            "alt-shift-k" = "move up";
            "alt-shift-l" = "move right";
            "alt-1" = "workspace 1";
            "alt-2" = "workspace 2";
            "alt-3" = "workspace 3";
            "alt-4" = "workspace 4";
            "alt-5" = "workspace 5";
            "alt-6" = "workspace 6";
            "alt-7" = "workspace 7";
            "alt-8" = "workspace 8";
            "alt-9" = "workspace 9";
            "alt-shift-1" = "move-node-to-workspace 1";
            "alt-shift-2" = "move-node-to-workspace 2";
            "alt-shift-3" = "move-node-to-workspace 3";
            "alt-shift-4" = "move-node-to-workspace 4";
            "alt-shift-5" = "move-node-to-workspace 5";
            "alt-shift-6" = "move-node-to-workspace 6";
            "alt-shift-7" = "move-node-to-workspace 7";
            "alt-shift-8" = "move-node-to-workspace 8";
            "alt-shift-9" = "move-node-to-workspace 9";
            "alt-f" = "fullscreen";
            "alt-shift-space" = "layout floating tiling";
            "alt-slash" = "layout tiles horizontal vertical";
            "alt-comma" = "layout accordion horizontal vertical";
            "alt-shift-minus" = "resize smart -50";
            "alt-shift-equal" = "resize smart +50";
            "alt-tab" = "focus-monitor next";
            "alt-shift-tab" = "move-node-to-monitor next";
            "alt-shift-semicolon" = "mode service";
          };
          service.binding = {
            "esc" = [ "reload-config" "mode main" ];
            "r" = [ "flatten-workspace-tree" "mode main" ];
            "f" = [ "layout floating tiling" "mode main" ];
            "backspace" = [ "close-all-windows-but-current" "mode main" ];
          };
        };
      } cfg.extraSettings;
    };
  };
}
