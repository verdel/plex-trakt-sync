#!/bin/sh

set -e

if [ -f /app/conf_templates/.env.j2 ];then
    j2 -o /app/.env /app/conf_templates/.env.j2
fi

if [ -f /app/conf_templates/.pytrakt.json.j2 ];then
    j2 -o /app/.pytrakt.json /app/conf_templates/.pytrakt.json.j2
fi

if [ -f /app/conf_templates/config.json ];then
    cp /app/conf_templates/config.json /app/config.json
fi

if [ -d "/app/conf_templates" ]; then rm -Rf /app/conf_templates; fi

if [ $# -eq 0 ]; then
  echo "Start watch"
  exec python /app/main.py watch
else
  echo "Start plex2trakt with args"
  exec python /app/main.py "$*"
fi