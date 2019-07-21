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

# Install the theme
ENV THEME_VERSION=20190718
RUN export THEME_DOWNLOAD_FILE="FlatTheme-${THEME_VERSION}.tar.gz" && \
    export THEME_TEMP_DIR="/tmp/FlatTheme" && \
    export THEME_INSTALL_DIR="/usr/share/themes/FlatTheme" && \
    wget -q -O $THEME_DOWNLOAD_FILE "https://github.com/daniruiz/flat-remix-gtk/archive/${THEME_VERSION}.tar.gz" && \
    mkdir $THEME_TEMP_DIR && \
    mkdir $THEME_INSTALL_DIR && \
    tar -xzf $THEME_DOWNLOAD_FILE --strip 1 -C $THEME_TEMP_DIR && \
    cp -r $THEME_TEMP_DIR/Flat-Remix-GTK-Blue-Dark/* $THEME_INSTALL_DIR && \
    rm -rf $THEME_TEMP_DIR && \
    rm -f $THEME_DOWNLOAD_FILE

# Install the icons
ENV ICONS_VERSION=20190719
RUN export ICONS_DOWNLOAD_FILE="FlatThemeIcons-${ICONS_VERSION}.tar.gz" && \
    export ICONS_TEMP_DIR="/tmp/FlatThemeIcons" && \
    export ICONS_INSTALL_DIR="/usr/share/icons/FlatTheme" && \
    wget -q -O $ICONS_DOWNLOAD_FILE "https://github.com/daniruiz/flat-remix/archive/${ICONS_VERSION}.tar.gz" && \
    mkdir $ICONS_TEMP_DIR && \
    mkdir $ICONS_INSTALL_DIR && \
    tar -xzf $ICONS_DOWNLOAD_FILE --strip 1 -C $ICONS_TEMP_DIR && \
    cp -r $ICONS_TEMP_DIR/Flat-Remix-Blue-Dark/* $ICONS_INSTALL_DIR && \
    rm -rf $ICONS_TEMP_DIR && \
    rm -f $ICONS_DOWNLOAD_FILE && \
    gtk-update-icon-cache $ICONS_INSTALL_DIR

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
    export FONTS_VERSION=3.7 && \
    export FONTS_DOWNLOAD_FILE="ttf-mscorefonts-installer_${FONTS_VERSION}_all.deb" && \
    wget -q -O $FONTS_DOWNLOAD_FILE "http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/${FONTS_DOWNLOAD_FILE}" && \
	dpkg -i ttf-mscorefonts-installer_3.7_all.deb && \
    rm -f $FONTS_DOWNLOAD_FILE

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