# dotnix

Shared Nix configuration for NixOS, macOS, Ubuntu, WSL, OrbStack, and NAS. It
uses the [dendritic pattern](https://www.vimjoyer.com/vid79-parts-wrapped) and
[impermanence](https://www.vimjoyer.com/vid89-impermanent) to keep the setup
easy to reuse and each machine clean.

## Install

Replace `<host>` with `wsl`, `orb`, `nas`, `ubuntu`, or `macos`:

```sh
nix --extra-experimental-features "nix-command flakes" run --refresh \
  github:radutomy/dotnix#<host>
```

For a fresh NixOS installation on NixPC, find the target disk:

```sh
lsblk -pdo NAME,SIZE,MODEL
```

Install NixOS, replacing `<disk>` with a device such as `/dev/nvme0n1`:

```sh
nix --extra-experimental-features "nix-command flakes" run --refresh \
  github:radutomy/dotnix#nixpc -- <disk>
```

This formats then installs NixOS on the selected disk.

## Rebuild

Run from `~/dotnix` on any configured machine:

```sh
just switch
```

Update, rebuild, commit, and push:

```sh
just update
```

## NAS recovery

Full reinstall:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake github:radutomy/dotnix#nasFullReinstall \
  --target-host root@192.168.0.2
```

Reinstall the OS disk only:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake github:radutomy/dotnix#nasOSRecovery \
  --target-host root@192.168.0.2
```

## Live USB

Build `/tmp/live-usb.iso`:

```sh
nix --extra-experimental-features "nix-command flakes" run --refresh \
  github:radutomy/dotnix#liveUsb
```
