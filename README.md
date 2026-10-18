# dotnix

Shared Nix configuration for my NixOS machines. It uses the [dendritic pattern](https://www.vimjoyer.com/vid79-parts-wrapped) and
[impermanence](https://www.vimjoyer.com/vid89-impermanent) to keep the setup easy to reuse.

## Install

For a fresh NixOS installation on NixPC, NixQS or NixMi, find the target disk:

```sh
lsblk -pdo NAME,SIZE,MODEL
```

Install NixOS, replacing 
`<host>` with `nixpc, nixqs or nixmi` 
`<disk>` with a device such as `/dev/nvme0n1`

```sh
nix --extra-experimental-features "nix-command flakes" run --refresh \
  github:radutomy/dotnix#<host> -- <disk>
```

On the NAS, run:

```sh
nix --extra-experimental-features "nix-command flakes" run --refresh \
  github:radutomy/dotnix#nas
```

For a Raspberry Pi 4, flash an SD card from a desktop. The hostname is one of
the names listed in `modules/hosts/nixpi/main.nix`:

```sh
nix run --refresh github:radutomy/dotnix#nixpi-image -- <hostname> <wifi-ssid> <wifi-password> <device>

# Example
nix run --refresh github:radutomy/dotnix#nixpi-image -- nixpi IoT 'ihavenoidea' /dev/sda
```

## NAS

- LAN: `192.168.0.2`
- Tailscale: `100.68.0.2` (`nas.feist-tint.ts.net`)

### Web services


| Service | Port |
| --- | --- |
| Home Assistant | 8123 |
| Immich | 2283 |
| AdGuard Home | 3000 |
| Filebrowser (read-only `/drive` mirror) | 8080 |
| Glances | 61208 |
| qBittorrent | 9090 |

### Network services


| Service | Port | Notes |
| --- | --- | --- |
| DNS (AdGuard Home) | 53/tcp+udp | Resolver for the LAN |
| DHCP (AdGuard Home) | 67/udp | Leases `192.168.0.50`–`192.168.0.250`, gateway `192.168.0.1` |
| Tailscale | 41641/udp | WireGuard |

## NAS recovery

Full reinstall:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake github:radutomy/dotnix#nas-full-reinstall \
  --target-host root@192.168.0.2
```

Reinstall the OS disk only:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake github:radutomy/dotnix#nas-os-recovery \
  --target-host root@192.168.0.2
```

## Live USB

Build `/tmp/live-usb.iso`:

```sh
nix --extra-experimental-features "nix-command flakes" run --refresh \
  github:radutomy/dotnix#live-usb
```
