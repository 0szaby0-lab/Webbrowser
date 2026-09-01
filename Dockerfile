FROM kasmweb/chromium:1.15.0-rolling

USER root

# Nginx telepítése a Render HTTP -> Kasm HTTPS fordításhoz
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Automatikus Discord megnyitás
ENV START_URL="https://discord.com/login"

# Nginx reverse proxy beállítása (SSL átjáró és WebSocket támogatás)
RUN echo 'server { \
    listen 10000; \
    location / { \
        proxy_pass https://127.0.0.1:6901; \
        proxy_ssl_verify off; \
        proxy_http_version 1.1; \
        proxy_set_header Upgrade $http_upgrade; \
        proxy_set_header Connection "Upgrade"; \
        proxy_set_header Host $host; \
        proxy_read_timeout 86400; \
    } \
}' > /etc/nginx/sites-available/default

EXPOSE 10000

# Elindítjuk az Nginx-et a háttérben, majd átadjuk az irányítást a Kasm hivatalos indítójának
ENTRYPOINT ["/bin/bash", "-c", "service nginx start && exec /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh"]
