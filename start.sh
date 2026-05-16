#!/bin/bash
# start.sh — Container entrypoint script
# Called by Docker when the container starts (see ENTRYPOINT in Dockerfile).
# Responsibilities:
#   1. Ensure /home has correct permissions
#   2. Set up the user home directory on first run
#   3. Validate and write the VNC password
#   4. Hand off to supervisord to manage all services

# Ensure /home is world-executable so users can access their subdirectories
chmod 755 /home

# First-run detection: if .profile doesn't exist, this is a fresh home directory.
# This avoids re-running setup when the home volume already has user data.
if [ ! -f /home/user/.profile ]; then
    echo "First run - setting up home directory..."
    mkdir -p /home/user
    chown -R user:user /home/user
    chmod 755 /home/user
fi

# Remove stale ICEauthority file which can prevent desktop session from starting
rm -f /home/user/.ICEauthority

# Validate that VNC_PASSWORD was provided via the .env file / environment
if [ -z "$VNC_PASSWORD" ]; then
    echo "ERROR: VNC_PASSWORD environment variable not set"
    exit 1
fi

# Write the VNC password to the TigerVNC password file.
# vncpasswd -f reads plaintext from stdin and writes the encrypted binary format.
mkdir -p /home/user/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/user/.vnc/passwd
chmod 600 /home/user/.vnc/passwd          # Restrict read access to owner only
chown -R user:user /home/user/.vnc

echo "VNC Password file created successfully."

# Launch supervisord in the foreground.
# supervisord manages all services (dbus, Xvnc, Cinnamon, noVNC) as defined
# in /etc/supervisor/conf.d/supervisord.conf
exec /usr/bin/supervisord -n
