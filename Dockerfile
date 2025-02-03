FROM debian:11

LABEL maintainer="Tomohisa Kusano <siomiz@gmail.com>"

ENV VNC_SCREEN_SIZE=1920x1080

COPY copyables /

# Update packages, install essential dependencies, and clean up
RUN sed -i s/deb.debian.org/mirrors.ustc.edu.cn/g /etc/apt/sources.list &&\
    sed -i s/security.debian.org/mirrors.ustc.edu.cn/g /etc/apt/sources.list &&\
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gnupg2 \
    fonts-noto-cjk \
    pulseaudio \
    supervisor \
    libfuse-dev \
    x11vnc \
    fluxbox \
    eterm \
    wget && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf /var/cache/* /var/log/apt/* /tmp/*

# Install Latest Google Chrome and Chrome Remote Desktop
RUN wget --no-check-certificate -c -O /tmp/Moonlight-6.1.0-x86_64.AppImage https://proxy.lishichen.cn/https://github.com/moonlight-stream/moonlight-qt/releases/download/v6.1.0/Moonlight-6.1.0-x86_64.AppImage && \
    chmod +x /tmp/Moonlight-6.1.0-x86_64.AppImage

# Configure the environment
RUN useradd -m -G chrome-remote-desktop,pulse-access chrome && \
    usermod -s /bin/bash chrome && \
    ln -s /crdonly /usr/local/sbin/crdonly && \
    ln -s /update /usr/local/sbin/update && \
    mkdir -p /home/chrome/.config/chrome-remote-desktop /home/chrome/.fluxbox && \
    echo ' \n\
       session.screen0.toolbar.visible:        false\n\
       session.screen0.fullMaximization:       true\n\
       session.screen0.maxDisableResize:       true\n\
       session.screen0.maxDisableMove: true\n\
       session.screen0.defaultDeco:    NONE\n\
    ' >> /home/chrome/.fluxbox/init && \
    chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

USER chrome

VOLUME ["/home/chrome"]

WORKDIR /home/chrome

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]