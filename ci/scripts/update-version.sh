#!/bin/bash

set -eu

: ${ENTITY_NAME:?required}
ENTITY_VERSION=$(cat $ENTITY_NAME/version)

if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "${GIT_EMAIL:?required}"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "${GIT_NAME:?required}"
fi

git clone git git-output
pushd git-output

sed -i "s/.*${ENTITY_NAME}.*/${ENTITY_NAME}=$ENTITY_VERSION/" .versions

git merge --no-edit ${BRANCH}
git add -A
git status
git commit -m "bump ${ENTITY_NAME} v${ENTITY_VERSION}"
popd
