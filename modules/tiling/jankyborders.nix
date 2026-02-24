{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.tiling.jankyborders;
in {
  options.modules.tiling.jankyborders = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.tiling.enable;
      description = "Enable JankyBorders for window borders";
    };

    activeColor = lib.mkOption {
      type = lib.types.strMatching "0x[0-9a-fA-F]{8}";
      default = "0xffcba6f7";
      description = "Active window border color (ARGB hex)";
    };
    inactiveColor = lib.mkOption {
      type = lib.types.strMatching "0x[0-9a-fA-F]{8}";
      default = "0xff313244";
      description = "Inactive window border color (ARGB hex)";
    };
    width = lib.mkOption {
      type = lib.types.float;
      default = 5.0;
      description = "Border width";
    };
    style = lib.mkOption {
      type = lib.types.enum ["round" "square"];
      default = "round";
      description = "Border style (round or square)";
    };
    hidpi = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable HiDPI mode";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jankyborders = {
      enable = true;
      active_color = cfg.activeColor;
      inactive_color = cfg.inactiveColor;
      width = cfg.width;
      style = cfg.style;
      hidpi = cfg.hidpi;
    };
  };
}
