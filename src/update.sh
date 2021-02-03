#!/usr/bin/env bash

# TODO: update this to run through the app helper script.

function getPhp() {
  if [ "$(command -v php7.4)" ]; then
    command which php7.4
  else
    command which php
  fi
}

DIR="$(realpath "$0")"
DIR="$(dirname "${DIR}")"
DIR="$(dirname "${DIR}")"

cd "${DIR}" || exit 1

PHP=$(getPhp)

${PHP} artisan down

git fetch --depth=10 --prune --progress origin
git pull

COMPOSER_MEMORY_LIMIT=-1 composer install --no-dev

${PHP} artisan migrate --force
${PHP} artisan optimize

${PHP} artisan up
