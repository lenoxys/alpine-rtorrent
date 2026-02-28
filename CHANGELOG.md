# Changelog

## 0.0.1

First release — rebuilt for TrueNAS Scale with VPN support.

- Alpine 3.23 with rtorrent 0.16.2
- Configurable `PUID`/`PGID` (defaults to TrueNAS `apps` UID 568)
- Gluetun VPN port forwarding (auto-detects forwarded port every 30s)
- Healthcheck for container monitoring
- Downloads at `/completed_downloads` for simple bind mounts
- NAS-friendly umask (`0002`) — Plex, Jellyfin, Samba can read downloads
- Runs as unprivileged user via `su-exec`
