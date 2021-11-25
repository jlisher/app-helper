#!/usr/bin/env sh

set -e # exit on non-zero returns

# I hope this works
if ! command -v _app_helper_run >/dev/null 2>&1; then
    path="${0}"
    path="$(dirname "${path}")"
    path="${path}/bashrc.sh"

    # shellcheck disable=SC1090
    . "${path}"
fi

_app_helper_run "${@}"
