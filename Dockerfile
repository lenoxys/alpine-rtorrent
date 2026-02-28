FROM alpine:3.23

ARG VERSION="0.16.2-r1"

LABEL maintainer="Gianluca Gabrielli" mail="tuxmealux+dockerhub@protonmail.com"
LABEL description="rTorrent on Alpine Linux, with a better Docker integration."
LABEL website="https://github.com/lenoxys/alpine-rtorrent"
LABEL version="$VERSION"

RUN addgroup --gid 568 rtorrent && \
    adduser -S -u 568 -G rtorrent rtorrent && \
    apk add --no-cache rtorrent="$VERSION" su-exec && \
    mkdir -p /home/rtorrent/.rtorrent/config.d/ \
             /home/rtorrent/.rtorrent/.session/ \
             /home/rtorrent/.rtorrent/watch/ \
             /home/rtorrent/rtorrent/config.d/ \
             /home/rtorrent/rtorrent/.session/ \
             /home/rtorrent/rtorrent/watch/ \
             /completed_downloads/ && \
    chown -R rtorrent:rtorrent /home/rtorrent/

COPY config.d/ /home/rtorrent/.rtorrent/config.d/
COPY .rtorrent.rc /home/rtorrent/
COPY entrypoint.sh /home/rtorrent/entrypoint.sh
RUN chmod +x /home/rtorrent/entrypoint.sh

EXPOSE 16891
EXPOSE 6881
EXPOSE 6881/udp
EXPOSE 50000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:16891 || exit 1

ENTRYPOINT ["/home/rtorrent/entrypoint.sh"]
