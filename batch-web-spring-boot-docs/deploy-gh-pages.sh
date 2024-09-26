#!/bin/bash
##
# Makes a shallow clone for gh-pages branch, copies the new docs, adds, commits and pushes 'em.
#
# Requires the environment variable GH_TOKEN to be set to a valid GitHub-api-token.
#
# Usage:
# ./deploy-gh-pages.sh <project-version>
#
# project-version    The version folder to use in gh-pages
##
set -o errexit -o nounset

GH_URL="https://${GITHUB_TOKEN}@github.com/codecentric/spring-boot-starter-batch-web.git"
TEMPDIR="$(mktemp -d /tmp/gh-pages.XXX)"
TARGET_DIR="${GITHUB_REF_NAME/master/current}"

echo "Cloning gh-pages branch..."
git clone --branch gh-pages --single-branch --depth 1 "$GH_URL" "$TEMPDIR"

if [[ -d "$TEMPDIR"/"${TARGET_DIR}" ]]; then
   echo "Cleaning ${TARGET_DIR}..."
   rm -rf "$TEMPDIR"/"${TARGET_DIR}"
fi

echo "Copying new docs..."
mkdir -p "$TEMPDIR"/"${TARGET_DIR}"
cp -r target/generated-docs/* "$TEMPDIR"/"${TARGET_DIR}"/

pushd "$TEMPDIR" >/dev/null
git add --all .

if git diff-index --quiet HEAD; then
  echo "No changes detected."
else
  echo "Commit changes..."
  git commit --message "Docs for ${TARGET_DIR}"
  echo "Pushing gh-pages..."
  git push origin gh-pages
fi

popd >/dev/null

rm -rf "$TEMPDIR"
exit 0
