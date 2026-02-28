#!/bin/sh

export TERM=xterm

PUID=${PUID:-568}
PGID=${PGID:-568}

# Update rtorrent user/group to match requested UID/GID
if [ "$(id -u rtorrent)" != "$PUID" ] || [ "$(id -g rtorrent)" != "$PGID" ]; then
    deluser rtorrent 2>/dev/null
    delgroup rtorrent 2>/dev/null
    addgroup -g "$PGID" rtorrent
    adduser -S -u "$PUID" -G rtorrent -h /home/rtorrent rtorrent
fi

# Seed default configs on first run
if [ -z "$(ls -A /home/rtorrent/rtorrent/config.d/ 2>/dev/null)" ]; then
    cp -r /home/rtorrent/.rtorrent/config.d/* /home/rtorrent/rtorrent/config.d/
fi

# Fix ownership for runtime directories
chown -R rtorrent:rtorrent /home/rtorrent/
chown rtorrent:rtorrent /completed_downloads/

# Enable debug logging via RT_LOG_LEVEL env var
RT_LOG_LEVEL=${RT_LOG_LEVEL:-info}
RUNTIME_RC="/home/rtorrent/rtorrent/config.d/99-runtime.rc"
if [ "$RT_LOG_LEVEL" = "debug" ]; then
    cat > "$RUNTIME_RC" <<'EOF'
log.add_output = "debug", "log"
log.add_output = "dht_debug", "log"
log.add_output = "peer_debug", "log"
log.add_output = "socket_debug", "log"
log.add_output = "storage_debug", "log"
log.add_output = "tracker_debug", "log"
log.add_output = "torrent_debug", "log"
log.add_output = "rpc_debug", "log"
EOF
else
    rm -f "$RUNTIME_RC"
fi

# Ensure rtorrent can write to container stdout for logging
chmod 0666 /proc/self/fd/1 2>/dev/null || true

# Drop privileges and start rtorrent
exec su-exec rtorrent rtorrent
