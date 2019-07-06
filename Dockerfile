FROM ubuntu:19.04

ENV VNC_PORT=5901 \
    VNC_RESOLUTION=1024x640 \
    DISPLAY=:1 \
    TERM=xterm \
    DEBIAN_FRONTEND=noninteractive \
    HOME=/home/user \
    PATH=/opt/TurboVNC/bin:$PATH

EXPOSE $VNC_PORT
WORKDIR $HOME

# Install shared utils
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        locales \
        net-tools \
        supervisor \
        wget

# Install XFCE and terminal
RUN apt-get install -y --no-install-recommends \
        dbus-x11 \
        libexo-1-0 \
        x11-xserver-utils \
        xauth \
        xfce4 \
        xfce4-terminal \
        xterm && \
    touch ~/.Xauthority
ENV TVNC_WM=xfce4-session

# Install TurboVNC
ENV TVNC_VERSION=2.2.2
RUN export TVNC_DOWNLOAD_FILE="turbovnc_${TVNC_VERSION}_amd64.deb" && \
    wget -q -O $TVNC_DOWNLOAD_FILE "https://sourceforge.net/projects/turbovnc/files/2.2.2/${TVNC_DOWNLOAD_FILE}/download" && \
    dpkg -i $TVNC_DOWNLOAD_FILE && \
    rm -f $TVNC_DOWNLOAD_FILE && \
    mkdir "$HOME/.vnc"

# Configure X server
RUN xset -dpms & \
    xset s noblank & \
    xset s off &

# Install Firefox
ENV FF_VERSION=68.0b14
RUN export FF_DOWNLOAD_FILE="firefox-${FF_VERSION}.tar.bz2" && \
    export FF_DOWNLOAD_URL="https://ftp.mozilla.org/pub/devedition/releases/${FF_VERSION}/linux-x86_64/en-US/${FF_DOWNLOAD_FILE}" && \
    export FF_INSTALL_DIR="/usr/lib/firefox" && \
    wget -q -O $FF_DOWNLOAD_FILE $FF_DOWNLOAD_URL && \
    mkdir $FF_INSTALL_DIR && \
    tar -xjf $FF_DOWNLOAD_FILE --strip 1 -C $FF_INSTALL_DIR && \
    rm -f $FF_DOWNLOAD_FILE && \
    ln -s "$FF_INSTALL_DIR/firefox" /usr/bin/firefox

# Install Sublime Text
ENV ST_VERSION=3207
RUN export ST_DOWNLOAD_FILE="sublime_text_3_build_${ST_VERSION}_x64.tar.bz2" && \
    export ST_INSTALL_DIR="/usr/lib/st3" && \
    wget -q -O $ST_DOWNLOAD_FILE "https://download.sublimetext.com/${ST_DOWNLOAD_FILE}" && \
    mkdir $ST_INSTALL_DIR && \
    tar -xjf $ST_DOWNLOAD_FILE --strip 1 -C $ST_INSTALL_DIR && \
    rm -f $ST_DOWNLOAD_FILE && \
    ln -s "$ST_INSTALL_DIR/sublime_text" /usr/bin/sublime

# Install extras
#RUN apt-get install -y --no-install-recommends \
#        ttf-mscorefonts-installer

COPY home/ /home/user/
RUN find /home/user/ -name '*.desktop' -exec chmod $verbose a+x {} +

COPY start.sh /startup/start.sh
RUN chmod +x /startup/start.sh

ENTRYPOINT [ "/startup/start.sh" ]
CMD [ "--wait" ]