#!/bin/bash
# set-password.sh — Writes the VNC password file for the desktop user
# This script can be run manually to reset the VNC password without
# rebuilding the container. The password is read from the VNC_PASSWORD
# environment variable (set in your .env file).

USER_NAME=user

# Create the VNC config directory if it doesn't already exist
mkdir -p /home/$USER_NAME/.vnc

# Convert the plaintext password to TigerVNC's binary password format.
# vncpasswd -f reads from stdin and writes the encrypted result to stdout.
echo "$VNC_PASSWORD" | vncpasswd -f > /home/$USER_NAME/.vnc/passwd

# Restrict the password file to owner read/write only (required by TigerVNC)
chmod 600 /home/$USER_NAME/.vnc/passwd

# Ensure the entire .vnc directory is owned by the desktop user
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.vnc
