# nixos-experiments
A dumb little place for me to do potentially dumb things with NixOS configuration.

Right now, and for the foreseeable future, it's dedicated to an abstraction of NixOS configuration and Home-Manager configuration, aiming to improve the integration and interoperability of them for my own use cases, in a way that is either the most obscure and cursed, or the most brilliant code I've written. I'm unsure.


## TL;DR:
At the top, to save you trouble. Basically, I'm planning to write a huge config option driven layer on top of a NixOS configuration for personal use, these are my testing grounds. The experimental part is that some `system` scoped modules use the config options from the `home` scope to drive system level changes. I have absolutely no idea if this is safe, correct, or acceptable, but it seems to work through the `nix flake check` and `nix repl` commands.

The idea is for this to make home-manager users much more portable, not in the sense of taking them outside of this config, but rather moving them to any system within the config and it working how you'd expect. The goal is for systems to almost entirely be driven by only their bare-minimum core, and then primarily the users that have been overlaid onto them.

In a configuration with many individual people, hosts, and users, this *should* help retain modularity and improve predictability.


## NixOS + Home-Manager
NixOS is a Linux operating system which is declaratively configured through Nix code.

Home Manager is a Nix module for configuring your user's home scope, though it is usable in other contexts it's used as a NixOS module for my purposes. It's useful for installing packages to specific users, as well as configuring the user's `~/.config` files. It offers tons of options to hook into and configure various softwares while home-manager does most of the work for you.

They're an amazing pair of software that gives incredible control over the system, but I've found myself confused and squinting to understand which side something does or should fall on, or having to reach across the strict border of the two for various cases of configuration.

For instance, users are declared twice, once in `system` scope and once in `home` scope. This makes sense but leads to more mental overhead that can be hard to refactor. Occasionally you'll find yourself trying to install a package in the `home` scope, only to find it needs some level of system configuration to work. For instance softwares which require insecure packages to be allowed, or other cases where Lutris, Heroic, and various other gaming platforms are Home-scoped yet Steam must remain in system scope for reasons. It gets messy enough when dealing with 2 users across 3 systems and yet I have plans to expand my config to potentially 5 users across 6 systems.

This can still be managed and isn't an impossible task by any means, but it does mean that there are more than a few cases where refactoring can lead to scope gymnastics and a bit of spaghetti. Are the right insecure packages allowed for this system, was it worth moving that to a two separate 5 line module so they can be *manually* imported within each system and user for their respective scopes, are you gonna have fun disconnecting or refactoring the various imports between scopes? I haven't so far.

All of this internal yapping anytime I thought about shifting around between users and systems led me to reconsider how I've been writing Nix code. So this is my *theoretical* solution I've been exploring.




## The Experiment
What if there were just one general scope to consider when writing the majority of your configuration? That sounds a lot like the thing that initially drew me to NixOS, before understanding the distinction and importance of system vs. home scope, something I've made an utter mess of since.

A part of this mess comes from some specific and hardly neccessary desire to be able to configure a system to include an extra home-manager user without second thought or much effort. Change the single line in which that `nixosConfiguration` is declared on, to also include the name of the user in the `users` list passed into our fancy little `mkHost` function, and the `mkHost` function does the heavy lifting of building those users' configurations with home manager and even some system level config. I honestly haven't found a use for it and it feels a little nasty to me, but if my configuration can support it and I *might* need it someday, I'd like to leave myself a less painful option than refactor the whole config.

Having spent a lot of my Nix time digging through modules like [Nixvim]() and [Stylix](), I started considering a more config module driven approach.

---

The idea is, there will be a single generalized `config` scope with a codenamed config path that allows you to enable or tweak various features of the config, similar to the two aforementioned modules. From there, you *only* configure bare-minimum system-level configuration for your host, and *everything* else is configured per user in the home manager scope.

So in short, a configuration that is heavily driven by an option API that is tied primarily to which users are present. Alright, cool enough on paper but how the hell does this work? Well...


### Current Setup
This experimental repo has a few modules already setup and configured for a couple of test users, I've been using this to crawl through outputs with Nix REPL and to check if it successfully builds with the `nix flake check` command.

The modules which are implemented are `users`, `xdg`, and `hyprland`.
- `users` is responsible for user specific config and registering home-manager configured users into the system scope
- `xdg` handles configuration of a user's default applications and their user directories (desktop, download, picture, etc)
- `hyprland` enables hyprland in both home and system scope, extra options are unimplemented here

There are two users and two hosts, the first host only has the first user, the second host contains *both* users. `userA` has Hyprland enabled and some specific XDG config, while `userB` does not have Hyprland enabled and provides its own home config. However, when building `hostB`, Hyprland should still be configured on system level which can be checked by verifying the `outputs.nixosConfigurations.hostB.config.programs.hyprland.enable` config path. Not only that, but we should be able to see both `userA` and `userB` registered under `outputs.nixosConfigurations.hostB.config.users.users`, meaning the system level module automatically registered all users overlayed onto the system within our `flake.nix`.


### Multi-User per System
Within the `flake.nix` file, we have the `mkHost` function which takes in two arguments, the hostName, and a list of userNames. We have a simple little lambda within the home-manager module section of that function which converts that list of userNames into a map of submodules, dynamically pulling in that user's home-manager config. 

```nix
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
```

This means any number of users can be moved between various systems, with as little as one line of code changed.

```nix
nixosConfigurations = {
  hostA = mkHost "hostA" [ "userA" ];
  hostB = mkHost "hostB" [ "userB" "userA" ];
};
```

This isn't without some issue or caveat though, depending on how the user and system are configured and if important system-level configuration is missing. That's what the next section aims to solve.


### Configuration Layer
At the root of the configuration is a directory called `config`, this has the two `home` and `systems` scopes which correspond to `users` and `hosts`. The largest majority of modules here will be within the `home` scope, though many will have `system` counterparts that handle the system level configuration when enabled.


#### Home Modules
Within each `home` module, an `enable` option may be provided if the module is optional, and home-manager configuration should be handled in the case that it's enabled or required, like such

```nix
{ config, lib, ... }: {
  imports = [];

  options.pfx.moduleName = {
    enable = lib.mkEnableOption "Enable module";
  };

  config = lib.mkIf (config.pfx.moduleName.enable) {
    programs.someProgram.enable = true;
    # ...
  };
}
```


#### System Modules
If the home module requires some `system` level configuration, then that should be included at `config/system/moduleName/default.nix` and looks something like this.

```nix
{ config, lib, helpers, ... }: {
  imports = [ ];

  options.pfx.moduleName = { };

  # config if any user being built has the option enabled
  config = lib.mkIf (helpers.anyUserHasOption ["pfx" "moduleName" "enable"] config) {
    environment.sessionVariables = [];
  };
}
```

This file is slightly more complex because we're not relying on our enable option, but instead using a helper function to determine whether or not to configure the *system* scope with this module. So what's going on there? Let's take a look at that helper function real quick.

```nix
anyUserHasOption = configPath: config: lib.any (user:
  lib.attrsets.attrByPath configPath false user
) (lib.attrValues config.home-manager.users);
```

This is a little hard to parse initially, but boiled down it's a function which takes two arguments, `configPath` which is a list of strings, and `config` which is a passed in reference to the actual `config` value from where you're using the function. It then checks each individual user defined in `config.home-manager.users` and either returns that value or false by default. It's intended use is to check whether or not enable options are toggled on or off for *all* users configured for the current NixOS configuration.

> 📘 Note<br>
> This implementation of the `anyUserHasOption` helper function does not work when used within home-manager scope, it assumes `system` scoped config and drills down into the home scope. A better implementation may check and handle this differently depending on the scope which is passed. It could also help to improve clarity of what this does, as it stands it fetches the value itself or defaults to false, while the name implies it returns true if the option exists and false if not, neither is ideal and a better solution would be required beyond this experimental prototype. Possibly fetching the option and returning null if it doesn't exist.

#### Using the Config
From there, you simply declare your minimal `configuration.nix` and `hardware.nix` files in your dedicated `hosts` subdirectory, and write a `default.nix` file into your dedicated `home` subdirectory, where you can configure all of the options exposed by the `config` API. It might look something like this.

```nix
{ lib, ... }: {
  imports = [];

  pfx.moduleName = {
    enable = true;
    optionA = {};
    optionB = [];
    optionC = "";
  };

  # ...
}
```

By enabling the option in your `home` scope, upon rebuilding the system, the `system` level module will ensure that if *any* user which is overlaying the current system has enabled `moduleName`, then its `system` level configuration will automatically be applied to the host, ensuring that it's correctly set up on both sides of the fence.


## That's all she wrote
That's about all I've got to say on this concept right now, I have yet to implement or use it and have no idea if it's a good idea to. If you're inclined to talk about it or have some thoughts on it, I'd be happy to hear about it through an issue, discussion post, or any other method that.
