#!/bin/bash
set -e

# Set the password
PASSWD_PATH="$HOME/.vnc/passwd"
echo "$VNC_PW" | vncpasswd -f >> $PASSWD_PATH && chmod 600 $PASSWD_PATH

# Startup the VNC server
vncserver $DISPLAY -nohttpd -depth 32 -geometry $VNC_RESOLUTION -name "Ubuntu VNC"

if [ -z "$1" ] || [[ $1 =~ -w|--wait ]]; then
    echo -e "Waiting for VNC server to exit"
    wait
else
    echo -e "Executing '$@'"
    exec "$@"
fi