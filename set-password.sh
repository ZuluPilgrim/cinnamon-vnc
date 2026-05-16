#!/bin/bash

USER_NAME=user

mkdir -p /home/$USER_NAME/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/$USER_NAME/.vnc/passwd
chmod 600 /home/$USER_NAME/.vnc/passwd
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.vnc
