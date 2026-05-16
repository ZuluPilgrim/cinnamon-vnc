#!/bin/bash

chmod 755 /home

# Only set up home if it's empty/new
if [ ! -f /home/user/.profile ]; then
    echo "First run - setting up home directory..."
    mkdir -p /home/user
    chown -R user:user /home/user
    chmod 755 /home/user
fi

rm -f /home/user/.ICEauthority

# Ensure password is set
if [ -z "$VNC_PASSWORD" ]; then
    echo "ERROR: VNC_PASSWORD environment variable not set"
    exit 1
fi

# Create VNC password
mkdir -p /home/user/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/user/.vnc/passwd
chmod 600 /home/user/.vnc/passwd
chown -R user:user /home/user/.vnc

echo "VNC Password file created successfully."

# Start supervisor
exec /usr/bin/supervisord -n
