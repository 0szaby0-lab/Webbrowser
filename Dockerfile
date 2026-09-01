FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0

# Szükséges csomagok telepítése
RUN apt-get update && apt-get install -y \
    chromium \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    openbox \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Automatikus csatlakozást és átméretezést biztosító kezdőoldal
RUN echo '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url='\''vnc.html?autoconnect=true&resize=scale'\''" /></head><body></body></html>' > /usr/share/novnc/index.html

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 10000
CMD ["/entrypoint.sh"]
