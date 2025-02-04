FROM debian:12

LABEL maintainer="dev <dev@example.com>"

ENV VNC_SCREEN_SIZE=1920x1080

RUN sed -i s/deb.debian.org/mirrors.ustc.edu.cn/g /etc/apt/sources.list.d/debian.sources &&\
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gnupg2 \
    fonts-noto-cjk \
    pulseaudio \
    supervisor \
    xvfb \
    x11vnc \
    libegl1-mesa \
    wget && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf /var/cache/* /var/log/apt/* /tmp/*

RUN mkdir -p /tmp/install && \
    wget --no-check-certificate -c -O /tmp/install/Moonlight-6.1.0-x86_64.AppImage https://ghfast.top/https://github.com/moonlight-stream/moonlight-qt/releases/download/v6.1.0/Moonlight-6.1.0-x86_64.AppImage && \
    chmod +x /tmp/install/Moonlight-6.1.0-x86_64.AppImage && \
    cd /tmp/install && \
    ./Moonlight-6.1.0-x86_64.AppImage --appimage-extract && \
    cp squashfs-root/usr/* /usr/ -r && \
    rm -rf /tmp/install


RUN useradd -m -G pulse-access moonlight && \
    usermod -s /bin/bash moonlight

COPY copyables /

USER moonlight

VOLUME ["/home/moonlight"]

WORKDIR /home/moonlight

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]