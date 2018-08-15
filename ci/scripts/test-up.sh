#!/bin/bash

set -eu

cd ${REPO_ROOT:?required}

eval "$(bin/quaa env)"

u_down() {
  set +e
  cf logs uaa --recent
  echo
  echo
  echo "Cleaning up..."
  quaa down -f
}
trap u_down SIGINT SIGTERM EXIT

cf api "${CF_URL:?required}"
cf auth "${CF_USERNAME:?required}" "${CF_PASSWORD:?required}"
cf target -o "${CF_ORGANIZATION:?required}" -s "${CF_SPACE:?required}"

cf cs elephantsql turtle uaa-db

quaa up --route "${CF_TEST_ROUTE:?required}"

curl -f "https://${CF_TEST_ROUTE}/login" -H "Accept: application/json"

quaa auth-client
uaa users
