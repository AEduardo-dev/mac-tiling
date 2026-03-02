{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.tiling.aerospace;
  sketchybar-hook = "exec-and-forget sketchybar --trigger aerospace_workspace_change";

  # Workspace names: user-defined or default 1–5
  workspaceNames =
    if cfg.workspaces != {}
    then builtins.attrNames cfg.workspaces
    else map toString (lib.range 1 5);

  # Single-char workspace name → lowercase key (multi-char → null, no auto-binding)
  nameToKey = name:
    if builtins.stringLength name == 1
    then lib.toLower name
    else null;

  # Generate alt-<key> / alt-shift-<key> bindings for each workspace
  workspaceBindings = lib.foldl' (
    acc: name: let
      key = nameToKey name;
    in
      if key != null
      then
        acc
        // {
          "alt-${key}" = "workspace ${name}";
          "alt-shift-${key}" = ["move-node-to-workspace ${name}" "${sketchybar-hook}"];
        }
      else acc
  ) {} workspaceNames;

  # workspace-to-monitor-force-assignment from workspaces with monitor set
  monitorAssignments = lib.filterAttrs (_: ws: ws.monitor != null) cfg.workspaces;
  workspaceToMonitor = lib.mapAttrs (_: ws: ws.monitor) monitorAssignments;

  # All apps across all workspaces (flat list of {wsName, app})
  allApps = lib.concatLists (lib.mapAttrsToList (
    wsName: ws: map (app: {inherit wsName app;}) ws.apps
  ) cfg.workspaces);

  # on-window-detected rules
  windowRules = map ({
    wsName,
    app,
  }:
    (
      if app.id != null
      then {"if".app-id = app.id;}
      else {"if".app-name-regex-substring = app.name;}
    )
    // {run = "move-node-to-workspace ${wsName}";})
  allApps;

  # after-startup-command: auto-launch apps
  launchCommands = map ({app, ...}:
    if app.id != null
    then "exec-and-forget open -b ${app.id}"
    else "exec-and-forget open -a '${app.name}'")
  allApps;

  appType = lib.types.submodule {
    options = {
      id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "App bundle ID (e.g., com.google.Chrome). Takes precedence over 'name' for matching.";
      };
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "App name regex substring (e.g., Chrome). Used when 'id' is not set.";
      };
    };
  };

  monitorType = lib.types.nullOr (lib.types.oneOf [
    lib.types.str
    lib.types.int
    (lib.types.listOf (lib.types.either lib.types.str lib.types.int))
  ]);
in {
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

    workspaces = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          monitor = lib.mkOption {
            type = monitorType;
            default = null;
            description = "Monitor to force-assign this workspace to (string pattern, int index, or list of fallbacks). See AeroSpace docs for monitor patterns.";
          };
          apps = lib.mkOption {
            type = lib.types.listOf appType;
            default = [];
            description = "Apps to auto-place and auto-launch in this workspace. Each entry needs at least 'id' or 'name'.";
          };
        };
      });
      default = {};
      description = ''
        Workspace definitions with monitor assignments and app placement rules.
        When set, keybindings are auto-generated for single-character workspace names.
        When empty (default), workspaces 1–5 are created with default keybindings.
      '';
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra AeroSpace settings to merge with defaults";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.all (a: a.app.id != null || a.app.name != null) allApps;
        message = "Each app in modules.tiling.aerospace.workspaces.*.apps must have at least one of 'id' or 'name' set";
      }
    ];

    services.aerospace = {
      enable = true;
      settings =
        lib.recursiveUpdate ({
            enable-normalization-flatten-containers = true;
            enable-normalization-opposite-orientation-for-nested-containers = true;
            on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

            gaps = {
              inner = {
                horizontal = cfg.gaps.inner.horizontal;
                vertical = cfg.gaps.inner.vertical;
              };
              outer = {
                left = cfg.gaps.outer.left;
                bottom = cfg.gaps.outer.bottom;
                top = cfg.gaps.outer.top;
                right = cfg.gaps.outer.right;
              };
            };

            exec-on-workspace-change = [
              "${pkgs.bash}/bin/bash"
              "-c"
              "command -v sketchybar >/dev/null 2>&1 && sketchybar --trigger aerospace_workspace_change AEROSP_FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE AEROSP_PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
            ];

            mode = {
              main.binding =
                {
                  "alt-h" = "focus left";
                  "alt-j" = "focus down";
                  "alt-k" = "focus up";
                  "alt-l" = "focus right";
                  "alt-shift-h" = "move left";
                  "alt-shift-j" = "move down";
                  "alt-shift-k" = "move up";
                  "alt-shift-l" = "move right";
                  "alt-f" = "fullscreen";
                  "alt-shift-space" = "layout floating tiling";
                  "alt-slash" = "layout tiles horizontal vertical";
                  "alt-comma" = "layout accordion horizontal vertical";
                  "alt-shift-minus" = "resize smart -50";
                  "alt-shift-equal" = "resize smart +50";
                  "alt-tab" = "focus-monitor next";
                  "alt-shift-tab" = "move-node-to-monitor next";
                  "alt-shift-semicolon" = "mode service";
                }
                // workspaceBindings;
              service.binding = {
                "esc" = ["reload-config" "mode main"];
                "r" = ["flatten-workspace-tree" "mode main"];
                "f" = ["layout floating tiling" "mode main"];
                "backspace" = ["close-all-windows-but-current" "mode main"];
              };
            };
          }
          // lib.optionalAttrs (workspaceToMonitor != {}) {
            workspace-to-monitor-force-assignment = workspaceToMonitor;
          }
          // lib.optionalAttrs (windowRules != []) {
            on-window-detected = windowRules;
          }
          // lib.optionalAttrs (launchCommands != []) {
            after-startup-command = launchCommands;
          })
        cfg.extraSettings;
    };
  };
}
