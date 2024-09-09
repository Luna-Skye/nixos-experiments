{ lib }: {
  # Returns a boolean indicating whether or not ANY configured home-manager user has a specific option configured
  # Takes in a list of strings representing the option path, and requires the config set to be passed
  anyUserHasOption = configPath: config: lib.any (user:
    lib.attrsets.attrByPath configPath false user
  ) (lib.attrValues config.home-manager.users);
}
