#!/usr/bin/env bash

set -euo pipefail

psql_c() {
  psql "$(heroku config:get DATABASE_URL -a "${HEROKU_APPNAME}")" \
    --echo-all \
    --command "$(cat -)"
}

sql_content() {
  cat <<- SQL

-- Create table
CREATE TABLE people (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  is_on_call BOOLEAN NOT NULL
);

-- Populate table
INSERT INTO people
  (name, is_on_call) VALUES
  ('D', FALSE),
  ('N', FALSE);

SQL
}

sql_content | psql_c
