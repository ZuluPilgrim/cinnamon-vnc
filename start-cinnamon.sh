#!/bin/bash
# start-cinnamon.sh — Launches the Cinnamon desktop session
# Called by supervisord after Xvnc has started (see supervisord.conf priority order).
# Runs as root initially, then drops to the 'user' account via `su` to start the session.

# ── Wait for Xvnc to be ready ────────────────────────────────────────────────
# Poll the display server up to 30 times (30 seconds) before giving up.
# xdpyinfo queries display :1; if it succeeds, Xvnc is accepting connections.
for i in $(seq 1 30); do
    if xdpyinfo -display :1 >/dev/null 2>&1; then
        echo "Xvnc is ready."
        break
    fi
    echo "Waiting for Xvnc... ($i)"
    sleep 1
done

# ── Fix permissions ───────────────────────────────────────────────────────────
chmod 755 /home
chown -R user:user /home/user

# Remove stale X session lock files that can prevent a new session from starting
rm -f /home/user/.ICEauthority /home/user/.Xauthority

# Remove Brave Browser singleton lock files left over from a previous session.
# Without this, Brave refuses to start thinking another instance is already running.
rm -f /home/user/.config/BraveSoftware/Brave-Browser/Singleton*

# ── Set up environment variables ──────────────────────────────────────────────
export DISPLAY=:1                   # Target the Xvnc virtual display
export HOME=/home/user
export USER=user
export LIBGL_ALWAYS_SOFTWARE=1      # Force software rendering (no GPU in container)
export CLUTTER_BACKEND=x11          # Tell Clutter (used by Cinnamon) to use X11
export XDG_RUNTIME_DIR=/run/user/$(id -u user)

# Create and secure the XDG runtime directory required by dbus and desktop services
mkdir -p "$XDG_RUNTIME_DIR"
chown user:user "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# ── Launch Cinnamon as the non-root user ──────────────────────────────────────
# Drop privileges to 'user' via `su` and start a full dbus-managed desktop session.
# dbus-launch ensures each session has its own dbus instance.
exec su - user -c "
    export DISPLAY=:1
    export LIBGL_ALWAYS_SOFTWARE=1
    export CLUTTER_BACKEND=x11
    export XDG_RUNTIME_DIR=/run/user/\$(id -u)
    exec dbus-launch --exit-with-session /usr/bin/cinnamon-session
"
