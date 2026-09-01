FROM kasmweb/chromium:1.15.0-rolling

USER root

# Nginx telepítése
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Belépési adatok beállítása
ENV VNC_USER="kasm_user"
ENV VNC_PW="Discord123!"
ENV START_URL="https://discord.com/login"

# Nginx konfiguráció az Authorization és WebSocket fejlécek továbbításával
RUN echo 'server { \
    listen 10000; \
    location / { \
        proxy_pass https://127.0.0.1:6901; \
        proxy_ssl_verify off; \
        proxy_http_version 1.1; \
        proxy_set_header Upgrade $http_upgrade; \
        proxy_set_header Connection "Upgrade"; \
        proxy_set_header Host $host; \
        proxy_set_header Authorization $http_authorization; \
        proxy_pass_header Authorization; \
        proxy_read_timeout 86400; \
    } \
}' > /etc/nginx/sites-available/default

EXPOSE 10000

ENTRYPOINT ["/bin/bash", "-c", "service nginx start && exec /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh"]
