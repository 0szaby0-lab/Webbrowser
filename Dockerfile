FROM node:20-alpine

WORKDIR /app

# Szükséges csomagok telepítése
RUN apk add --no-cache git

# Az ipari standard Ultraviolet Proxy letöltése
RUN git clone https://github.com/titaniumnetwork-dev/Ultraviolet-App.git .

# Függőségek telepítése
RUN npm install

# Render port beállítása (a Render környezeti változóját használja)
ENV PORT=10000
EXPOSE 10000

# Proxy szerver indítása
CMD ["npm", "start"]
