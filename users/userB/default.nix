{ ... }: {
  imports = [ ];


  pfx = {
    xdg = {
      enable = true;
      dir = {
        desktop     = "$HOME/Desktop";
        documents   = "$HOME/Documents";
        download    = "$HOME/Downloads";
        music       = "$HOME/Music";
        pictures    = "$HOME/Pictures";
        publicShare = "$HOME/Public";
        templates   = "$HOME/Templates";
        videos      = "$HOME/Videos";
      };
      app = {
        browser = [ "chromium" ];
        audio =   [ "elisa" ];
        video =   [ "vlc" ];
        image =   [ "gwenview" ];
      };
    };


    # WARN: Best not change these after first build
    user = {
      name = "userB";
      isNormalUser = true;
      extraGroups = [ "network-manager" "wheel" "audio" ];
    };
  };
}
