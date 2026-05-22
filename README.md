# dotnix

Personal NixOS configuration covering my WSL setup, OrbStack VM, and home NAS, plus the editor/terminal/shell dotfiles that go with them. Built as a flake-parts flake; modules are auto-imported from `modules/` via `import-tree`.

## Install or update a host

Pick the host name (`wsl`, `orb`, or `nas`) and run it on the target machine:

```sh
nix --extra-experimental-features "nix-command flakes" run github:radutomy/dotnix#<wsl|orb|nas>
```

## NAS provisioning

The NAS has three installation modes, each driven by [`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere). All three assume SSH access to the target as `root` and, except for the full reinstall, that Ubuntu (or any reachable Linux) is already running on the disk.

### Full reinstall — wipes the OS disk and recreates the ZFS pool

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake github:radutomy/dotnix#nasFullReinstall \
  --target-host root@192.168.0.2
```

### OS-only recovery — reinstalls the OS disk, keeps the existing ZFS pool intact

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake github:radutomy/dotnix#nasOSRecovery \
  --target-host root@192.168.0.2
```

### ZFS pool wipe — wipes and reconfigures the data pool only

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake github:radutomy/dotnix#nasDataWiper \
  --target-host root@192.168.0.2 \
  --phases kexec,disko,reboot
```

## Live USB

Build a bootable installer image at `/tmp/live-usb.iso`. Flash it with [Balena Etcher](https://etcher.balena.io/) or Rufus in `dd` mode:

```sh
nix --extra-experimental-features "nix-command flakes" run github:radutomy/dotnix#liveUsb
```
