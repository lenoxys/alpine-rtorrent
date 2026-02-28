# alpine-rtorrent

A lightweight, security-focused [rTorrent](https://github.com/rakshasa/rtorrent) Docker image based on [Alpine Linux](https://alpinelinux.org/). Designed for TrueNAS Scale but works anywhere Docker runs.

- Modular configuration split into drop-in `.rc` files
- Runs as an unprivileged user with configurable `PUID`/`PGID`
- Built-in [Gluetun](https://github.com/qdm12/gluetun) VPN port forwarding support
- [Flood](https://github.com/jesec/flood) web UI ready via XMLRPC
- Logs to stdout for `docker logs` integration
- Healthcheck included

## Quick Start

```bash
docker run -d --name rtorrent \
  -p 50000:50000 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v /path/to/session:/home/rtorrent/rtorrent/.session \
  -v /path/to/downloads:/completed_downloads \
  -v /path/to/watch:/home/rtorrent/rtorrent/watch \
  ghcr.io/lenoxys/alpine-rtorrent:latest
```

Or build it yourself:

```bash
git clone https://github.com/lenoxys/alpine-rtorrent.git
cd alpine-rtorrent
docker build -t alpine-rtorrent:latest .
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `568` | User ID for the rtorrent process |
| `PGID` | `568` | Group ID for the rtorrent process |

The default UID/GID `568` matches the TrueNAS Scale `apps` user. Override them to match your host filesystem permissions:

```bash
docker run -d -e PUID=1000 -e PGID=1000 ...
```

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `50000` | TCP | Incoming peer traffic |
| `6881` | TCP/UDP | DHT (Distributed Hash Table) |
| `16891` | TCP | XMLRPC socket for remote control (Flood, etc.) |

Only `50000` and `6881` are needed for rTorrent to function. Port `16891` is for third-party applications like Flood.

**Warning:** The XMLRPC port (`16891`) has no authentication. Do not expose it to the host network directly. Use Docker networks to restrict access to trusted containers only.

## Volumes & Bind Mounts

| Container Path | Purpose | Notes |
|----------------|---------|-------|
| `/completed_downloads` | Downloaded files | Bind mount to your media storage |
| `/home/rtorrent/rtorrent/.session` | Session data | Persists torrent state across restarts |
| `/home/rtorrent/rtorrent/watch` | Watch directories | Drop `.torrent` files to load/start |
| `/home/rtorrent/rtorrent/config.d` | Configuration | Mount to override default configs |

The `watch` directory contains two subdirectories created on first run:
- `watch/load` — dropped `.torrent` files are loaded
- `watch/start` — dropped `.torrent` files are loaded and started immediately

## Gluetun VPN Integration

This image includes built-in support for [Gluetun](https://github.com/qdm12/gluetun) VPN port forwarding. When running behind Gluetun, the forwarded port is automatically detected and applied to rTorrent every 30 seconds.

Run in Gluetun's network namespace:

```bash
docker run -d --name rtorrent \
  --network=container:gluetun \
  -v /tmp/gluetun:/tmp/gluetun:ro \
  -v /path/to/session:/home/rtorrent/rtorrent/.session \
  -v /path/to/downloads:/completed_downloads \
  ghcr.io/lenoxys/alpine-rtorrent:latest
```

When not using Gluetun, the port forwarding schedule runs harmlessly as a no-op.

## TrueNAS Scale

This image is built for TrueNAS Scale's Apps system:

- Default UID/GID `568` matches the TrueNAS `apps` user
- No `VOLUME` directives that create orphaned anonymous volumes
- Healthcheck for app status monitoring
- The `/completed_downloads` directory is only chowned at the top level (not recursively), so startup stays fast even with large media libraries

## Configuration

Configuration is modular, split into files under `config.d/`:

| File | Purpose |
|------|---------|
| `00-main.rc` | Core settings: paths, ports, peers, limits |
| `01-log.rc` | Logging to stdout |
| `05-dht.rc` | DHT and PEX |
| `05-xmlrpc.rc` | XMLRPC daemon mode |
| `10-flood.rc` | Flood web UI compatibility |
| `15-gluetun.rc` | Gluetun VPN port forwarding |

To override, mount your own `config.d` directory:

```bash
-v /path/to/config:/home/rtorrent/rtorrent/config.d
```

Default configs are seeded on first run only (when `config.d` is empty).

## Logs

Logs are written to `/dev/stdout` for Docker log driver integration:

```bash
docker logs rtorrent
```

This behavior can be changed by editing [`config.d/01-log.rc`](config.d/01-log.rc).

## Credits

This project is a fork of [StayPirate/alpine-rtorrent](https://github.com/StayPirate/alpine-rtorrent) by Gianluca Gabrielli. The original project established the Alpine Linux base, modular configuration approach, and security-first design.
