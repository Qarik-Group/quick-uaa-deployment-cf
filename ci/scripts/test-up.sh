#!/bin/bash

set -eu

cd ${REPO_ROOT:?required}

source <(bin/u env)

u_down() {
  u down -f
}
trap u_down SIGINT SIGTERM EXIT

cf api "${CF_URL:?required}"
cf auth "${CF_USERNAME:?required}" "${CF_PASSWORD:?required}"
cf target -o "${CF_ORGANIZATION:?required}" -s "${CF_SPACE:?required}"

u up --route "${CF_TEST_ROUTE:?required}"

curl -f "https://${CF_TEST_ROUTE}/login" -H "Accept: application/json"

u auth-client
uaa users
