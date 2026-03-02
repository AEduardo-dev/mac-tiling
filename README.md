# mac-tiling

Hyprland-like tiling setup for macOS using **AeroSpace + SketchyBar + JankyBorders**, packaged as a reusable nix-darwin module.

Includes a feature-rich SketchyBar configuration ported from [zerochae/sketchybar-gray](https://github.com/zerochae/sketchybar-gray) with 11 built-in themes, 2 bar styles, and a wide selection of widgets.

## Preview

The default `onedark` theme with `block` style gives each widget a colored background block. The `compact` style groups all widgets into a single rounded section per side.

## Features

- **AeroSpace** — i3-like tiling WM with vim keybindings, workspaces, multi-monitor support
- **SketchyBar** — rich status bar with workspaces, clock, weather, battery, CPU, RAM, disk, network, volume, and more
- **JankyBorders** — colored window borders for active/inactive windows
- 11 built-in themes: `onedark`, `onelight`, `nord`, `tokyonight`, `githubdark`, `githublight`, `gruvboxdark`, `gruvboxlight`, `ayudark`, `ayulight`, `blossomlight`
- 2 bar styles: `block` and `compact`
- All components toggleable and configurable via nix-darwin options

## Prerequisites

- macOS (Apple Silicon or Intel)
- [Nix](https://nixos.org/download) with flakes enabled
- [nix-darwin](https://github.com/LnL7/nix-darwin) installed
- [Nerd Font](https://www.nerdfonts.com/) installed (e.g. `SpaceMono Nerd Font Mono`) — required for icons
- [`sketchybar-app-font`](https://github.com/kvndrsslr/sketchybar-app-font) — optional, for app icons in the workspace widget

## Installation

Add this flake as an input in your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    mac-tiling.url = "github:AEduardo-dev/mac-tiling";
  };

  outputs = { self, nixpkgs, darwin, mac-tiling, ... }: {
    darwinConfigurations."my-mac" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./configuration.nix
        mac-tiling.darwinModules.default
        {
          modules.tiling.enable = true;
        }
      ];
    };
  };
}
```

## Configuration

### Basic enable with defaults

```nix
{
  modules.tiling.enable = true;
}
```

### Custom theme

```nix
{
  modules.tiling.sketchybar = {
    theme = "tokyonight";     # or: onedark, nord, githubdark, gruvboxdark, ...
    barStyle = "compact";     # or: block
  };
}
```

### Custom widget layout

```nix
{
  modules.tiling.sketchybar = {
    widgets = {
      left   = [ "space" ];
      center = [ "front_app" ];
      right  = [ "clock" "calendar" "volume" "battery" "cpu" ];
    };
  };
}
```

### Weather location

```nix
{
  modules.tiling.sketchybar.weatherLocation = "London";
}
```

### Calendar format

```nix
{
  modules.tiling.sketchybar.calendarFormat = "ddd YYYY-MM-DD";
}
```

### Workspace-monitor assignment & app placement

```nix
{
  modules.tiling.aerospace.workspaces = {
    "1" = {
      monitor = "main";
      apps = [
        { id = "com.mitchellh.ghostty"; }
        { name = "Terminal"; }
      ];
    };
    "2" = {
      monitor = "secondary";
      apps = [
        { id = "com.google.Chrome"; }
      ];
    };
    "3" = {
      monitor = [ "secondary" 2 ];  # fallback: try "secondary", then monitor 2
      apps = [
        { id = "com.microsoft.VSCode"; }
      ];
    };
  };
}
```

This generates:
- **Workspace-to-monitor assignment** — workspaces 1, 2, 3 are pinned to their monitors
- **Auto-placement** — when Chrome opens, it moves to workspace 2 (`on-window-detected`)
- **Auto-launch** — all listed apps start on AeroSpace startup (`after-startup-command`)
- **Keybindings** — `alt-1`/`alt-shift-1` through `alt-3`/`alt-shift-3` are auto-generated

When no workspaces are defined, 5 default workspaces (1–5) with keybindings are created.

### Full example with all options

```nix
{
  modules.tiling = {
    enable = true;

    aerospace = {
      gaps = {
        inner = { horizontal = 8; vertical = 8; };
        outer = { top = 40; bottom = 8; left = 8; right = 8; };
      };

      workspaces = {
        "1" = { monitor = "main"; apps = [{ id = "com.mitchellh.ghostty"; }]; };
        "2" = { monitor = "main"; apps = [{ id = "com.google.Chrome"; }]; };
        "3" = { monitor = "secondary"; apps = [{ id = "com.microsoft.VSCode"; }]; };
        "4" = { monitor = "secondary"; };
        "5" = {};
      };
    };

    sketchybar = {
      theme           = "onedark";
      barStyle        = "block";
      barHeight       = 37;
      barPosition     = "top";
      barBackground   = "transparent";   # or "bg1"
      weatherLocation = "New York";
      calendarFormat  = "ddd YYYY-MM-DD";
      hideMenuBar     = true;

      widgets = {
        left   = [ "space" ];
        center = [ "front_app" ];
        right  = [ "clock" "calendar" "weather" "caffeinate" "volume" "battery" "disk" "ram" "cpu" ];
      };

      fonts = {
        labelFamily  = "SpaceMono Nerd Font Mono";
        iconSize     = "18.0";
        labelSize    = "12.0";
        appIconSize  = "13.5";
      };
    };

    jankyborders = {
      activeColor   = "0xFF98c379";
      inactiveColor = "0xFF282c34";
      width         = 4.0;
      style         = "round";
    };
  };
}
```

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `modules.tiling.aerospace.workspaces` | attrsOf submodule | `{}` | Workspace definitions (monitor + apps). When empty, defaults to 5 workspaces (1–5) |
| `modules.tiling.aerospace.workspaces.<name>.monitor` | null or str or int or list | `null` | Monitor to force-assign workspace to (pattern, index, or fallback list) |
| `modules.tiling.aerospace.workspaces.<name>.apps` | list of submodule | `[]` | Apps to auto-place and auto-launch in this workspace |
| `modules.tiling.aerospace.workspaces.<name>.apps.*.id` | null or str | `null` | App bundle ID (e.g., `com.google.Chrome`) |
| `modules.tiling.aerospace.workspaces.<name>.apps.*.name` | null or str | `null` | App name regex substring (e.g., `Chrome`) |
| `modules.tiling.sketchybar.enable` | bool | `modules.tiling.enable` | Enable SketchyBar |
| `modules.tiling.sketchybar.theme` | enum | `"onedark"` | Color theme |
| `modules.tiling.sketchybar.barStyle` | enum | `"block"` | Bar style (`block` or `compact`) |
| `modules.tiling.sketchybar.barHeight` | int | `37` | Bar height in pixels |
| `modules.tiling.sketchybar.barPosition` | enum | `"top"` | Bar position (`top` or `bottom`) |
| `modules.tiling.sketchybar.barBackground` | enum | `"transparent"` | Bar background (`transparent` or `bg1`) |
| `modules.tiling.sketchybar.weatherLocation` | string | `""` | Weather location (empty = Seoul default) |
| `modules.tiling.sketchybar.calendarFormat` | string | `"YYYY-MM-DD"` | Calendar date format |
| `modules.tiling.sketchybar.widgets.left` | list of string | `[]` | Left widgets (empty = default: `space`) |
| `modules.tiling.sketchybar.widgets.center` | list of string | `[]` | Center widgets (empty = default: `front_app`) |
| `modules.tiling.sketchybar.widgets.right` | list of string | `[]` | Right widgets (empty = default: `clock weather caffeinate volume battery disk ram cpu kakaotalk config`) |
| `modules.tiling.sketchybar.fonts.labelFamily` | string | `"SpaceMono Nerd Font Mono"` | Label font family |
| `modules.tiling.sketchybar.fonts.iconSize` | string | `"18.0"` | Icon font size |
| `modules.tiling.sketchybar.fonts.labelSize` | string | `"12.0"` | Label font size |
| `modules.tiling.sketchybar.fonts.appIconSize` | string | `"13.5"` | App icon font size |
| `modules.tiling.sketchybar.hideMenuBar` | bool | `true` | Hide native macOS menu bar |

## Available Themes

| Theme | Type | Description |
|-------|------|-------------|
| `onedark` | dark | One Dark (default) |
| `onelight` | light | One Light |
| `nord` | dark | Nord |
| `tokyonight` | dark | Tokyo Night |
| `githubdark` | dark | GitHub Dark |
| `githublight` | light | GitHub Light |
| `gruvboxdark` | dark | Gruvbox Dark |
| `gruvboxlight` | light | Gruvbox Light |
| `ayudark` | dark | Ayu Dark |
| `ayulight` | light | Ayu Light |
| `blossomlight` | light | Blossom Light |

## Available Widgets

| Widget | Description |
|--------|-------------|
| `space` | AeroSpace workspaces (shows running app icons, click to switch) |
| `front_app` | Currently focused application |
| `clock` | Current time (format: `SBAR_CLOCK_FORMAT`) |
| `calendar` | Current date (format: `SBAR_CALENDAR_FORMAT`) |
| `weather` | Current weather via wttr.in (requires `weatherLocation`) |
| `battery` | Battery percentage and charging status |
| `volume` | System volume with mute toggle |
| `cpu` | CPU usage with graph |
| `ram` | RAM usage with graph |
| `disk` | Disk usage percentage |
| `netstat` | Network upload/download speed |
| `caffeinate` | Toggle system sleep prevention |
| `bluetooth` | Bluetooth on/off status |
| `kakaotalk` | KakaoTalk notification badge |
| `config` | Settings gear icon (opens sketchybar-gray UI if installed) |

## Font Requirements

The status bar requires a [Nerd Font](https://www.nerdfonts.com/) for icons. Install one of:

- **SpaceMono Nerd Font Mono** (default) — available via Homebrew: `brew install --cask font-space-mono-nerd-font`
- Any other Nerd Font — set via `fonts.labelFamily`

The [`sketchybar-app-font`](https://github.com/kvndrsslr/sketchybar-app-font) for app icons is automatically installed by this module.

## Recommended macOS Settings

Disable "Displays have separate Spaces" for best multi-monitor experience:

```bash
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer
```

Logout and back in for it to take effect.

## Troubleshooting

**Icons not showing (empty rectangles)**
: Install a [Nerd Font](https://www.nerdfonts.com/) and set `fonts.labelFamily` to match. Restart SketchyBar after installing.

**Workspace widget missing**
: Ensure AeroSpace is running (`aerospace list-workspaces --all`). The space widget falls back to Mission Control if AeroSpace is not found.

**Weather not showing**
: Set `weatherLocation` to a valid city name. Requires internet access to `wttr.in`. `jq` and `curl` must be in PATH (added automatically via `environment.systemPackages`).

**App icons in workspace are empty**
: Ensure `sketchybar-app-font` is installed (automatically installed by this module). Try restarting SketchyBar with `sketchybar --reload`.

**SketchyBar not starting**
: Check logs with `sudo launchctl start org.nixos.sketchybar` and look in `/var/log/sketchybar.log`.

## Credits

- [zerochae/sketchybar-gray](https://github.com/zerochae/sketchybar-gray) — Original SketchyBar configuration (MIT)
- [FelixKratz/SketchyBar](https://github.com/FelixKratz/SketchyBar) — SketchyBar status bar
- [nikitabobko/AeroSpace](https://github.com/nikitabobko/AeroSpace) — AeroSpace tiling window manager
- [FelixKratz/JankyBorders](https://github.com/FelixKratz/JankyBorders) — JankyBorders window borders

## License

MIT

