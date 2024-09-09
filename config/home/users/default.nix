{ config, lib, ... }: {
  imports = [];


  options.pfx.user = {
    name = lib.mkOption {};
    isNormalUser = lib.mkOption {};
    extraGroups = lib.mkOption {};
  };


  # NOTE: Ideally there'd be better mkIf checks here
  config = lib.mkIf (config.pfx.user.name != "") {
    home.username = lib.mkDefault config.pfx.user.name;
    home.homeDirectory = lib.mkForce "/home/${config.pfx.user.name}";

    home.stateVersion = lib.mkDefault "23.11";
    programs.home-manager.enable = lib.mkDefault true;
  };
}
