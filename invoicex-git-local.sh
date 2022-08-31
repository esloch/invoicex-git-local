#!/usr/bin/env bash

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $(basename "$0") <repo-path> <start-date> <end-date> <author>"
  exit 0
fi

if [[ -z "${1}" ]]; then
  echo "[EE] <repo-path> not given."
  exit 1
fi

if [[ -z "${2}" ]]; then
  echo "[EE] <start-date> not given."
  exit 1
fi

if [[ -z "${3}" ]]; then
  echo "[EE] <end-date> not given."
  exit 1
fi

if [[ -z "${4}" ]]; then
  echo "[EE] <author> not given."
  exit 1
fi

set -ex

REPO_PATH="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
REPO_NAME=$(basename "$1")

START_DATE=${2}
END_DATE=${3}
AUTHOR=${4}

ROOT_DIR="$(dirname "$(realpath "$0")")"

cd ${REPO_PATH}
CURRENT_BRANCH="$(git branch --show-current)"

TMP_DIR=/tmp/git-local-report
FILE_NAME="${START_DATE}--${END_DATE}.csv"
FILE_PATH=${TMP_DIR}/${FILE_NAME}

mkdir -p ${TMP_DIR}

if [ ! -f "${FILE_PATH}" ]; then
  echo "repo_name;branch_name;hash;date;author;title" > ${FILE_PATH}
fi

git fetch origin

# for branch in "$(git branch)"; do
branches=()
eval "$(git for-each-ref --shell --format='branches+=(%(refname))' refs/heads/)"
for branch in "${branches[@]}"; do
  git checkout "${branch}"
  # git pull
  git log \
    --since=${START_DATE} \
    --until=${END_DATE} \
    --author="${AUTHOR}" \
    --date-order \
    --pretty=tformat:"${REPO_NAME};${branch};%h;%as;%an;%s" >> ${FILE_PATH}
done;

git checkout $CURRENT_BRANCH

${ROOT_DIR}/clean-data.py ${FILE_PATH}

