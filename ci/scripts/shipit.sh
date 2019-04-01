#!/bin/bash

#
# ci/scripts/shipit.sh
#
# Script for generating Github release / tag assets

set -eu

header() {
	echo
	echo "###############################################"
	echo
	echo $*
	echo
}

: ${BRANCH:?required}
: ${REPO_ROOT:?required}
: ${REPO_ROOT_MASTER:?required}
: ${REPO_OUT:?required}
: ${REPO_OUT_MASTER:?required}
: ${RELEASE_ROOT:?required}

: ${GITHUB_OWNER:?required}
: ${GITHUB_REPO:?required}
: ${GIT_EMAIL:?required}
: ${GIT_NAME:?required}

: ${VERSION_FROM:?required}

if [[ ! -f ${VERSION_FROM} ]]; then
  echo >&2 "Version file (${VERSION_FROM}) not found.  Did you misconfigure Concourse?"
  exit 2
fi
VERSION=$(cat ${VERSION_FROM})
if [[ -z ${VERSION} ]]; then
  echo >&2 "Version file (${VERSION_FROM}) was empty.  Did you misconfigure Concourse?"
  exit 2
fi

if [[ ! -f ${REPO_ROOT}/ci/release_notes.md ]]; then
  echo >&2 "ci/release_notes.md not found.  Did you forget to write them?"
  exit 1
fi

###############################################################

git clone "${REPO_ROOT}" "${REPO_OUT}"
git clone "${REPO_ROOT_MASTER}" "${REPO_OUT_MASTER}"

header "Generate Github release & Slack notification"
mkdir -p ${RELEASE_ROOT}/artifacts
echo "v${VERSION}"                 > ${RELEASE_ROOT}/tag
echo "v${VERSION}"                 > ${RELEASE_ROOT}/name
mv ${REPO_OUT}/ci/release_notes.md   ${RELEASE_ROOT}/notes.md
cat >> ${RELEASE_ROOT}/notes.md <<EOF

### Versions
\`\`\`plain
$(cat ${REPO_OUT_MASTER}/.versions)
\`\`\`
EOF

cat > ${NOTIFICATION_OUT:-notifications}/message <<EOS
New ${GITHUB_REPO} v${VERSION} released. <https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/tag/v${VERSION}|Release notes>.
EOS


header "Update git repo for release of ${VERSION}"
pushd "${REPO_OUT}" > /dev/null

# item to change in .versions
ENTITY_NAME=uaa-deployment
sed -i "s/.*${ENTITY_NAME}.*/${ENTITY_NAME}=$VERSION/" .versions

if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "${GIT_EMAIL}"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "${GIT_NAME}"
fi

git merge --no-edit "${BRANCH}"
git add -A
git status
git commit -m "release v${VERSION}"
popd > /dev/null


header "Merge to master"
pushd "${REPO_OUT_MASTER}" > /dev/null
git pull ../${REPO_OUT} -X theirs --no-edit
popd > /dev/null

