# mac-tiling

Hyprland-like tiling setup for macOS using **AeroSpace + SketchyBar + JankyBorders**, packaged as a reusable nix-darwin module.

## Features

- **AeroSpace** — i3-like tiling WM with vim keybindings, workspaces, multi-monitor support
- **SketchyBar** — customizable status bar with AeroSpace workspace integration
- **JankyBorders** — colored window borders for active/inactive windows
- Catppuccin Mocha theme by default
- All components toggleable and configurable via nix-darwin options

## Usage

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

```nix
{
  modules.tiling = {
    enable = true;

    aerospace = {
      gaps.outer.top = 40;
      extraSettings = {
        # any extra aerospace.toml settings merged in
      };
    };

    sketchybar.theme = {
      accentColor = "0xff89b4fa";  # Catppuccin Blue
      barHeight = 34;
    };

    jankyborders = {
      activeColor = "0xff89b4fa";
      width = 4.0;
      style = "round";
    };
  };
}
```

## Recommended macOS Settings

Disable "Displays have separate Spaces" for best multi-monitor experience:

```bash
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer
```

Logout and back in for it to take effect.
