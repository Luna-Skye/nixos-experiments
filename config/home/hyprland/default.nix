{ config, lib, ... }: {
  imports = [ ];


  options.pfx.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland installation and default configuration";

    defaultKeybinds = lib.mkEnableOption "Declares whether or not to use preconfigured keybindings";

    #  TODO: improve typing and doc desc
    monitors = lib.mkOption {
      type = lib.types.list;
      default = [{
        name = "";
        resolution = "highres";
        refreshRate = null;
        workspaces = [1];
      }];
      description = lib.mkDoc ''
        Defines monitors, resolution, and offsets for hyprland monitor layout.
      '';
    };

    windowRules = lib.mkOption {};
    layerRules = lib.mkOption {};

    execOnce = lib.mkOption {};
  };


  config = lib.mkIf (config.pfx.hyprland.enable) {
    wayland.windowManager.hyprland = {
      enable = lib.mkDefault true;
      xwayland.enable = lib.mkDefault true;
      systemd.enable = lib.mkDefault true;

      settings = {
        exec-once = lib.mkDefault [];
        workspace = lib.mkDefault [];
        monitor = lib.mkDefault [];
        windowrulev2 = lib.mkDefault [];
        layerrule = lib.mkDefault [];
      };
    };
  };
}
