FROM lscr.io/linuxserver/webtop:chromium-alpine

# Render port beállítása és socat telepítése a forgalom átirányításához
RUN apk add --no-cache socat

# Discord automatikus megnyitása induláskor
ENV START_PAGE="https://discord.com/login"

# A 3000-es belső webes port átirányítása a Render 10000-es portjára
EXPOSE 10000
CMD /init & sleep 3 && socat TCP-LISTEN:10000,fork TCP:127.0.0.1:3000
