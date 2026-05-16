#!/bin/bash

# Wait for Xvnc to be ready
for i in $(seq 1 30); do
    if xdpyinfo -display :1 >/dev/null 2>&1; then
        echo "Xvnc is ready."
        break
    fi
    echo "Waiting for Xvnc... ($i)"
    sleep 1
done

# Fix permissions
chmod 755 /home
chown -R user:user /home/user
rm -f /home/user/.ICEauthority /home/user/.Xauthority

# Remove Brave lock files from previous session
rm -f /home/user/.config/BraveSoftware/Brave-Browser/Singleton*

export DISPLAY=:1
export HOME=/home/user
export USER=user
export LIBGL_ALWAYS_SOFTWARE=1
export CLUTTER_BACKEND=x11
export XDG_RUNTIME_DIR=/run/user/$(id -u user)
mkdir -p "$XDG_RUNTIME_DIR"
chown user:user "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Start cinnamon session as user with dbus
exec su - user -c "
    export DISPLAY=:1
    export LIBGL_ALWAYS_SOFTWARE=1
    export CLUTTER_BACKEND=x11
    export XDG_RUNTIME_DIR=/run/user/\$(id -u)
    exec dbus-launch --exit-with-session /usr/bin/cinnamon-session
"
