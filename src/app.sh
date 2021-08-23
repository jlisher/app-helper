#!/usr/bin/env bash

# I hope this works
if ! command -v _app_helper_get_dir >/dev/null 2>&1; then
    path="${0}"
    path="$(dirname "${path}")"
    path="${path}/bashrc.sh"

    # shellcheck disable=SC1090
    source "${path}"
fi

_app_helper_run "${@}"
