{ config, lib, ... }: {
  imports = [];


  options.pfx.user = {};


  config = {
    # Map hm user options onto system config
    users.users = builtins.mapAttrs (name: attr: {
      description = lib.mkDefault attr.pfx.user.name;
      isNormalUser = lib.mkDefault attr.pfx.user.isNormalUser;
      extraGroups = lib.mkDefault attr.pfx.user.extraGroups;
    }) config.home-manager.users;
  };
}
