FROM ubuntu:19.04

ENV VNC_PORT=5901 \
    VNC_RESOLUTION=1024x640 \
    DISPLAY=:1 \
    TERM=xterm \
    DEBIAN_FRONTEND=noninteractive \
    HOME=/home/user \
    PATH=/opt/TurboVNC/bin:$PATH \
    SSH_PORT=22

EXPOSE $VNC_PORT
EXPOSE $SSH_PORT

# Install shared utils
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        locales \
        net-tools \
        sudo \
        supervisor \
        wget \
        openssh-server

# Install XFCE and terminal
RUN apt-get install -y --no-install-recommends \
        dbus-x11 \
        libexo-1-0 \
        x11-apps \
        x11-xserver-utils \
        xauth \
        xfce4 \
        xfce4-terminal \
        xterm
ENV TVNC_WM=xfce4-session

# Install TurboVNC
ENV TVNC_VERSION=2.2.2
RUN export TVNC_DOWNLOAD_FILE="turbovnc_${TVNC_VERSION}_amd64.deb" && \
    wget -q -O $TVNC_DOWNLOAD_FILE "https://sourceforge.net/projects/turbovnc/files/2.2.2/${TVNC_DOWNLOAD_FILE}/download" && \
    dpkg -i $TVNC_DOWNLOAD_FILE && \
    rm -f $TVNC_DOWNLOAD_FILE

# Configure SSH server
RUN mkdir -p /var/run/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/^#AllowTcpForwarding\s+.*/AllowTcpForwarding yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/^#X11Forwarding\s+.*/X11Forwarding yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/^#X11UseLocalhost\s+.*/X11UseLocalhost no/g' /etc/ssh/sshd_config

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

# Install extra common fonts
RUN apt-get install -y --no-install-recommends \
        cabextract \
        xfonts-utils && \
    wget http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb && \
	dpkg -i ttf-mscorefonts-installer_3.7_all.deb

# Setup another user
RUN useradd -ms /bin/bash user && \
    adduser user sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER user
WORKDIR $HOME

# Configure X server
RUN touch ~/.Xauthority && \
    mkdir ~/.vnc

COPY home/ $HOME/

# Copy in the init script
COPY start.sh /startup/start.sh
RUN sudo chmod +x /startup/start.sh

ENTRYPOINT [ "/startup/start.sh" ]
CMD [ "--wait" ]