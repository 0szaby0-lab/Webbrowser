FROM kasmweb/chromium:1.15.0-rolling

USER root

# Socat telepítése a belső HTTPS port átirányításához a Render portjára
RUN apt-get update && apt-get install -y socat && rm -rf /var/lib/apt/lists/*

ENV START_URL="https://discord.com/login"

EXPOSE 10000

# A Kasmweb belső 6901-es webes portját kötjük a Render 10000-es portjára
CMD /dockerstartup/kasm_default_profile.sh /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh & sleep 4 && socat TCP-LISTEN:10000,fork TCP:127.0.0.1:6901
