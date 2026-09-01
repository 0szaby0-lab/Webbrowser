FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV PORT=10000

# Szükséges csomagok telepítése (teljes képernyős VNC + böngésző)
RUN apt-get update && apt-get install -y \
    chromium \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    openbox \
    supervisor \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Automatikus teljes képernyős átirányítás a webes felületre
RUN echo '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url='\''vnc_lite.html?autoconnect=true&scale=true'\''" /></head><body></body></html>' > /usr/share/novnc/index.html

# Supervisord konfiguráció generálása közvetlenül a konténerben
RUN echo '[supervisord]\n\
nodaemon=true\n\
user=root\n\
\n\
[program:xvfb]\n\
command=/usr/bin/Xvfb :0 -screen 0 1280x720x16\n\
priority=10\n\
autorestart=true\n\
\n\
[program:openbox]\n\
command=/bin/bash -c "sleep 1 && /usr/bin/openbox"\n\
priority=20\n\
autorestart=true\n\
\n\
[program:x11vnc]\n\
command=/bin/bash -c "sleep 2 && /usr/bin/x11vnc -display :0 -nopw -listen 127.0.0.1 -forever -shared"\n\
priority=30\n\
autorestart=true\n\
\n\
[program:novnc]\n\
command=/bin/bash -c "sleep 2 && /usr/bin/websockify --web /usr/share/novnc 10000 127.0.0.1:5900"\n\
priority=40\n\
autorestart=true\n\
\n\
[program:chromium]\n\
command=/bin/bash -c "sleep 4 && /usr/bin/chromium --no-sandbox --disable-dev-shm-usage --disable-gpu --window-size=1280,720 --window-position=0,0 --kiosk https://discord.com/login"\n\
priority=50\n\
autorestart=true\n' > /etc/supervisord.conf

EXPOSE 10000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
