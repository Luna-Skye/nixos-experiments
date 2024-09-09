{ config, lib, ... }:
let
  associations = config: {
    "text/html" = config.pfx.xdg.app.browser;
    "x-scheme-handler/http" = config.pfx.xdg.app.browser;
    "x-scheme-handler/https" = config.pfx.xdg.app.browser;
    "x-scheme-handler/ftp" = config.pfx.xdg.app.browser;
    "x-scheme-handler/about" = config.pfx.xdg.app.browser;
    "x-scheme-handler/unknown" = config.pfx.xdg.app.browser;
    "application/x-extension-htm" = config.pfx.xdg.app.browser;
    "application/x-extension-html" = config.pfx.xdg.app.browser;
    "application/x-extension-shtml" = config.pfx.xdg.app.browser;
    "application/xhtml+xml" = config.pfx.xdg.app.browser;
    "application/x-extension-xhtml" = config.pfx.xdg.app.browser;
    "application/x-extension-xht" = config.pfx.xdg.app.browser;
    "application/json" = config.pfx.xdg.app.browser;
    "application/pdf" = config.pfx.xdg.app.browser;

    "audio/*" = config.pfx.xdg.app.audio;
    "video/*" = config.pfx.xdg.app.video;
    "image/*" = config.pfx.xdg.app.image;
  };
in {
  imports = [];

  options.pfx.xdg = {
    enable = lib.mkEnableOption {};

    dir = lib.mkOption {};
    app = lib.mkOption {};
  };

  config = lib.mkIf (config.pfx.xdg.enable) {
    xdg = {
      userDirs = {
        enable = true;
      } // config.pfx.xdg.dir;
      mimeApps = {
        enable = true;

        associations.added = associations config;
        defaultApplications = associations config;
      };
    };
  };
}
