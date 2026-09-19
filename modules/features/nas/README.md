# Nas

LAN: `192.168.0.2`
Tailscale: `100.68.220.97` (`nas.feist-tint.ts.net`)

## Web services

| Service | Port |
| --- | --- |
| Home Assistant | 8123 |
| Immich | 2283 |
| AdGuard Home | 3000 |
| Filebrowser (read-only `/drive` mirror) | 8080 |
| Glances | 61208 |

## Network services

<!-- markdownlint-disable MD013 -->
| Service | Port | Notes |
| --- | --- | --- |
| DNS (AdGuard Home) | 53/tcp+udp | Resolver for the LAN |
| DHCP (AdGuard Home) | 67/udp | Leases `192.168.0.50`–`192.168.0.250`, gateway `192.168.0.1` |
| NFS | 2049/tcp+udp | `/tank`, `/gdrive` to the LAN |
| Tailscale | 41641/udp | WireGuard |
<!-- markdownlint-enable MD013 -->
