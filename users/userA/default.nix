{ ... }: {
  imports = [ ];


  pfx = {
    xdg = {
      enable = true;
      dir = {
        desktop     = "$HOME/desktop";
        documents   = "$HOME/docs";
        download    = "$HOME/dl";
        music       = "$HOME/music";
        pictures    = "$HOME/pics";
        publicShare = "$HOME/public";
        templates   = "$HOME/templates";
        videos      = "$HOME/vids";
      };
      app = {
        browser = [ "firefox" ];
        audio =   [ "vlc" ];
        video =   [ "vlc" ];
        image =   [ "gwenview" ];
      };
    };

    hyprland = {
      enable = true;
      monitors = [];
      windowRules = [];
      layerRules = [];
    };


    # WARN: Best not change these after first build
    user = {
      name = "userA";
      isNormalUser = true;
      extraGroups = [ "network-manager" "wheel" ];
    };
  };
}
