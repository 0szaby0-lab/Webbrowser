#!/bin/bash
# Render által átadott dinamikus PORT beállítása (alapértelmezetten 10000)
export PORT=${PORT:-10000}

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
