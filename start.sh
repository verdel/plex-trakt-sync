#!/bin/sh

set -e

function configFromTemplate {
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
}

cd /app

if [ $# -eq 0 ]; then
  configFromTemplate
  echo "Start watch"
  exec python3 -m plextraktsync watch
elif [ $1 = "init" ]; then
  echo "PlexTraktSync initial configuration"
  python3 -m plextraktsync plex-login
  python3 -m plextraktsync trakt-login
  echo
  echo "Plex environment variables"
  if [ -f /app/.env ];then
    source /app/.env
    echo -e "PLEX_URL=${PLEX_BASEURL}\nPLEX_TOKEN=${PLEX_TOKEN}"
  fi

  echo
  echo "Trakt environment variables"
  if [ -f /app/.pytrakt.json ];then
    cat /app/.pytrakt.json | jq --raw-output '.| "TRAKT_CLIENT_ID=\(.CLIENT_ID)\nTRAKT_CLIENT_SECRET=\(.CLIENT_SECRET)\nTRAKT_OAUTH_TOKEN=\(.OAUTH_TOKEN)\nTRAKT_OAUTH_REFRESH=\(.OAUTH_REFRESH)\nTRAKT_OAUTH_EXPIRES_AT=\(.OAUTH_EXPIRES_AT)"'
  fi
  echo
  echo "Now you can run the docker container with the specified environment variables"
  exit 0
else
  configFromTemplate
  echo "Start plex2trakt with args"
  exec python3 -m plextraktsync "$*"
fi