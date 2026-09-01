FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV PORT=10000

# Chromium és a szükséges grafikus/webes csomagok telepítése
RUN apt-get update && apt-get install -y \
    chromium \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    openbox \
    supervisor \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Nginx reverse proxy (Kezeli a titkosított kapcsolatot a böngésződ és a szerver között)
RUN echo 'server { \
    listen 10000; \
    location / { \
        root /usr/share/novnc; \
        index index.html; \
    } \
    location /websockify { \
        proxy_pass http://127.0.0.1:6080/; \
        proxy_http_version 1.1; \
        proxy_set_header Upgrade $http_upgrade; \
        proxy_set_header Connection "Upgrade"; \
        proxy_set_header Host $host; \
        proxy_read_timeout 86400; \
    } \
}' > /etc/nginx/sites-available/default

# Automatikus átirányítás a teljes képernyős, helyes WebSocket útvonalra
RUN echo '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url='\''vnc_lite.html?autoconnect=true&scale=true&path=websockify'\''" /></head><body></body></html>' > /usr/share/novnc/index.html

# Supervisord konfiguráció
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
[program:websockify]\n\
command=/bin/bash -c "sleep 3 && /usr/bin/websockify 127.0.0.1:6080 127.0.0.1:5900"\n\
priority=40\n\
autorestart=true\n\
\n\
[program:nginx]\n\
command=/usr/sbin/nginx -g "daemon off;"\n\
priority=50\n\
autorestart=true\n\
\n\
[program:chromium]\n\
command=/bin/bash -c "sleep 4 && /usr/bin/chromium --no-sandbox --disable-dev-shm-usage --disable-gpu --window-size=1280,720 --window-position=0,0 --kiosk https://discord.com/login"\n\
priority=60\n\
autorestart=true\n' > /etc/supervisord.conf

EXPOSE 10000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
