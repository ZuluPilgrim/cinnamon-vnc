FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ARG USER=user
RUN groupadd -r $USER && useradd -r -m -g $USER $USER

# Update and enable Universe repository
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update

# Install Core System, Desktop, VNC, and Utilities
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

# Install Brave browser
RUN curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update && apt-get install -y brave-browser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install websockify and noVNC
RUN apt-get update && apt-get install -y websockify git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone noVNC files
RUN git clone --branch v1.3.0 https://github.com/novnc/noVNC.git /usr/share/novnc

# Add Brave no-sandbox wrapper
RUN mv /usr/bin/brave-browser-stable /usr/bin/brave-browser-stable.real && \
    printf '#!/bin/bash\nexec /usr/bin/brave-browser-stable.real --no-sandbox --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage "$@"\n' > /usr/bin/brave-browser-stable && \
    chmod +x /usr/bin/brave-browser-stable

# Create dbus socket directory
RUN mkdir -p /run/dbus

# Create persistent data directory and symlink to desktop
RUN mkdir -p /data && chown user:user /data
RUN mkdir -p /home/user/Desktop && ln -s /data /home/user/Desktop/SharedFiles

# Add index redirect to vnc.html
RUN echo '<html><head><meta http-equiv="refresh" content="0; url=/vnc_lite.html"></head></html>' > /usr/share/novnc/index.html

# Copy scripts and configs
COPY start.sh /start.sh
COPY set-password.sh /set-password.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY .xinitrc /home/user/.xinitrc
COPY start-cinnamon.sh /usr/local/bin/start-cinnamon.sh

# Set permissions
RUN chown user:user /home/user/.xinitrc
RUN chmod +x /home/user/.xinitrc
RUN chmod +x /usr/local/bin/start-cinnamon.sh
RUN chmod +x /start.sh /set-password.sh
RUN chown -R $USER:$USER /home/$USER

EXPOSE 5901 6080
ENTRYPOINT ["/start.sh"]
