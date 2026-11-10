_: {
  flake.modules.nixos.hardware = {
    services.fwupd.enable = true;
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;
  };
}
