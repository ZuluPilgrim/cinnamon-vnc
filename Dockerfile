# Base image — Ubuntu 22.04 LTS (Jammy)
FROM ubuntu:22.04

# Prevent apt from prompting for user input during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Build argument for the non-root username; can be overridden at build time
ARG USER=user

# Create a non-root group and user to run the desktop session
RUN groupadd -r $USER && useradd -r -m -g $USER $USER

# Enable the Universe repository (needed for some desktop packages)
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update

# Install all core dependencies in a single layer to keep image size down:
#   - locales, sudo, curl, gnupg, apt-transport-https: system utilities
#   - cinnamon, cinnamon-session: the desktop environment
#   - tigervnc-*: VNC server for remote desktop access
#   - mesa-*, libdrm2, libgbm1: graphics libraries (software rendering)
#   - dbus, dbus-x11: inter-process communication required by the desktop
#   - xterm, wget, openssl: general utilities
#   - supervisor: process manager that starts and monitors all services
#   - libgtk-3-0, libxss1, libasound2: GUI/audio libraries for apps
#   - x11-utils, xinit: X11 display utilities
#   - librecad: 2D CAD application
RUN apt-get install -y \
    locales sudo curl gnupg apt-transport-https \
    cinnamon cinnamon-session \
    tigervnc-standalone-server tigervnc-common \
    mesa-utils mesa-vulkan-drivers \
    dbus dbus-x11 xterm wget openssl supervisor \
    libgtk-3-0 libxss1 libasound2 libdrm2 libgbm1 \
    x11-utils \
    xinit \
    librecad \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Brave Browser from the official apt repository
RUN curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update && apt-get install -y brave-browser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install websockify (WebSocket proxy) and git (needed to clone noVNC)
RUN apt-get update && apt-get install -y websockify git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone noVNC v1.3.0 — a browser-based VNC client
RUN git clone --branch v1.3.0 https://github.com/novnc/noVNC.git /usr/share/novnc

# Wrap the Brave binary with flags required to run inside a container:
#   --no-sandbox: required because we're running as root/in a restricted env
#   --disable-gpu: no real GPU available in the container
#   --disable-software-rasterizer: avoid fallback GPU paths that may crash
#   --disable-dev-shm-usage: /dev/shm is often too small in containers
RUN mv /usr/bin/brave-browser-stable /usr/bin/brave-browser-stable.real && \
    printf '#!/bin/bash\nexec /usr/bin/brave-browser-stable.real --no-sandbox --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage "$@"\n' > /usr/bin/brave-browser-stable && \
    chmod +x /usr/bin/brave-browser-stable

# Create the dbus system socket directory
RUN mkdir -p /run/dbus

# Create the shared data directory and symlink it to the desktop for easy access
RUN mkdir -p /data && chown user:user /data
RUN mkdir -p /home/user/Desktop && ln -s /data /home/user/Desktop/SharedFiles

# Redirect noVNC root URL to the lite VNC client page
RUN echo '<html><head><meta http-equiv="refresh" content="0; url=/vnc_lite.html"></head></html>' > /usr/share/novnc/index.html

# Copy startup scripts and configuration into the image
COPY start.sh /start.sh                                               # Main entrypoint
COPY set-password.sh /set-password.sh                                 # Writes VNC password file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf         # Process manager config
COPY .xinitrc /home/user/.xinitrc                                     # X session startup file
COPY start-cinnamon.sh /usr/local/bin/start-cinnamon.sh              # Launches Cinnamon desktop

# Set correct ownership and permissions on all scripts
RUN chown user:user /home/user/.xinitrc
RUN chmod +x /home/user/.xinitrc
RUN chmod +x /usr/local/bin/start-cinnamon.sh
RUN chmod +x /start.sh /set-password.sh
RUN chown -R $USER:$USER /home/$USER

# Expose VNC (5901) and noVNC (6080) ports
# Note: noVNC is disabled in docker-compose.yml by default
EXPOSE 5901 6080

# Start the container via the main startup script
ENTRYPOINT ["/start.sh"]
