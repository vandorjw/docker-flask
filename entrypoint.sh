#!/bin/bash
set -e
cmd="$@"

source /app/.venv/bin/activate

function postgres_ready(){
python << END
import sys
import psycopg2
try:
    conn = psycopg2.connect("$DATABASE_URL")
except psycopg2.OperationalError:
    sys.exit(-1)
sys.exit(0)
END
}

function elasticsearch_ready(){
python << END
import sys
import requests
try:
    r = requests.get("http://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT")
except:
    sys.exit(-1)
sys.exit(0)
END
}

if [ -z ${DATABASE_URL} ]; then
  echo "DATABASE_URL not set, continuing";
else
  until postgres_ready; do
    echo "Postgres cannot be reached at: $DATABASE_URL, retrying in 1 second!";
    sleep 1
  done
fi

if [ -z ${ELASTICSEARCH_HOST} ]; then
  echo "ELASTICSEARCH_HOST not set, continuing";
elif [ -z ${ELASTICSEARCH_PORT} ]; then
  echo "ELASTICSEARCH_PORT not set, continuing";
else
  until elasticsearch_ready; do
    echo "elasticsearch connot be reached at: http://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT, retrying in 1 second!";
    sleep 1
  done
fi

if [ -z $cmd ]; then
  if [ ${AUTO_RELOAD} ]
  then
    gunicorn manage:app --reload
  else
    gunicorn manage:app
  fi
else
  echo "Running command passed (by the compose file)"
  exec $cmd
fi
