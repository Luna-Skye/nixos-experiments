{
  description = "Totality NixOS Dotfiles";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    inherit (inputs.nixpkgs) lib;
    helpers = import ./utils { inherit lib; };

    mkHost = host: users: lib.nixosSystem {
      specialArgs = { inherit inputs; inherit helpers; };
      system = "x86_64-linux";
      modules = [
        # host specific configuration (system level)
        (./hosts + "/${host}/hardware.nix")
        (./hosts + "/${host}/configuration.nix")

        # home-manager module
        home-manager.nixosModules.home-manager {
          home-manager.extraSpecialArgs = { inherit inputs; inherit self; inherit helpers; }; #  TODO: make sure i'm handling these inherits properly
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";

          # hm users
          home-manager.users = builtins.listToAttrs (
            map (user: {
              name = user;
              value.imports = [
                (./config/home)
                (./users + "/${user}")
              ];
            })
            users
          );
        }

        (./config/system)
      ];
    };
  in {
    nixosConfigurations = {
      hostA = mkHost "hostA" [ "userA" ];
      hostB = mkHost "hostB" [ "userB" "userA" ];
    };
  };
}
