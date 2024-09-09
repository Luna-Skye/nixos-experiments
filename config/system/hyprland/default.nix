{ config, lib, helpers, ... }: {
  imports = [ ];


  options.pfx.hyprland = { };


  config = lib.mkIf (
    # config.pfx.hyprland.enable ||
    helpers.anyUserHasOption ["pfx" "hyprland" "enable"] config
  ) {
    programs.hyprland.enable = lib.mkDefault true;
    services.displayManager.defaultSession = lib.mkDefault "hyprland";
  };
}
