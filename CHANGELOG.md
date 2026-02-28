# Changelog

## 0.0.5

- Fix debug logging: remove invalid subsystem log names for rtorrent 0.16.x

## 0.0.4

- Add `RT_LOG_LEVEL=debug` env var for runtime debug logging

## 0.0.3

- Fix healthcheck: use TCP port check (`nc -z`) instead of HTTP on SCGI socket

## 0.0.2

- Fix `/dev/stdout` logging after privilege drop via `su-exec`

## 0.0.1

First release — rebuilt for TrueNAS Scale with VPN support.

- Alpine 3.23 with rtorrent 0.16.2
- Configurable `PUID`/`PGID` (defaults to TrueNAS `apps` UID 568)
- Gluetun VPN port forwarding (auto-detects forwarded port every 30s)
- Healthcheck for container monitoring
- Downloads at `/completed_downloads` for simple bind mounts
- NAS-friendly umask (`0002`) — Plex, Jellyfin, Samba can read downloads
- Runs as unprivileged user via `su-exec`
