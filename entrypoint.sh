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

# Drop privileges and start rtorrent
exec su-exec rtorrent rtorrent
