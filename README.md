# Cinnamon Linux Desktop in Docker

A containerised Cinnamon Linux desktop accessible via VNC, built with the help of [Claude AI](https://claude.ai) and inspired by the How-To Geek article **[I run a full Linux desktop in Docker just because I can](https://www.howtogeek.com/i-run-a-linux-desktop-in-docker-because-i-can/)**.

## What's inside

- **Ubuntu 22.04** base image
- **Cinnamon** desktop environment
- **TigerVNC** for remote desktop access
- **noVNC** for optional browser-based access
- **[Brave Browser](https://brave.com)** — privacy-focused web browser
- **[LibreCAD](https://librecad.org)** — open source 2D CAD application

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [Docker Compose](https://docs.docker.com/compose/install/) installed

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/ZuluPilgrim/cinnamon-vnc.git
   cd cinnamon-vnc
   ```

2. **Create your environment file**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and set a strong VNC password:
   ```
   VNC_PASSWORD=your-secure-password
   BIND_IP=127.0.0.1
   ```
   > ⚠️ Never commit `.env` to version control — it is already listed in `.gitignore`.

## Running

Build the image (required on first run or after any changes to the Dockerfile):
```bash
sudo docker compose build --no-cache
```

Start the container:
```bash
sudo docker compose up -d
```

Connect with any VNC client (e.g. [TigerVNC Viewer](https://tigervnc.org), [RealVNC](https://www.realvnc.com)) at:
```
localhost:5901
```

## Stopping

```bash
sudo docker compose down
```

## Credits

- Inspired by the How-To Geek article: [I run a full Linux desktop in Docker just because I can](https://www.howtogeek.com/i-run-a-linux-desktop-in-docker-because-i-can/) by Ali Haider
- Built with the assistance of [Claude AI](https://claude.ai) by [Anthropic](https://www.anthropic.com)
