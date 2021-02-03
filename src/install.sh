#!/bin/bash

_APP_HELPER_DIR="$(realpath "$0")"
_APP_HELPER_DIR="$(dirname "${_APP_HELPER_DIR}")"
_APP_HELPER_DIR="$(dirname "${_APP_HELPER_DIR}")"

_APP_BASE_DIR="$(pwd)"
PROJECT_RC="${_APP_BASE_DIR}/.bashrc"

# touch the file if it doesn't exist. Just to make things more consistent later.
[ ! -f "${PROJECT_RC}" ] && touch "${PROJECT_RC}"

# Now lets write our helpers that will need to be source'd.
cat >>"${PROJECT_RC}"<<EOF
# .bashrc for the app helper script. This just sets the app helper directory
# and sources the bashrc for the app helper.
export _APP_HELPER_DIR="${_APP_HELPER_DIR}"
[ -f "\${_APP_HELPER_DIR}/src/bashrc.sh" ] && source "\${_APP_HELPER_DIR}/src/bashrc.sh"
EOF
