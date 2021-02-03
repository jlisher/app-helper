#!/bin/bash
#
# .bashrc for app utility
#
# This should be source`d in the current working shell to allow you to take full
# advantage of this utility.
#

################################################################################
# Variables
#
# Define some variables for easy configuration.
################################################################################

declare _APP_HELPER_NAME="${_APP_HELPER_NAME:-App Helper}"
declare _APP_HELPER_FILENAME="${_APP_HELPER_FILENAME:-app}"
declare _APP_HELPER_VERSION="${APP_VERSION:-"v0.0.1-alpha"}"
declare _APP_HELPER_DIR="${_APP_HELPER_DIR:-}"
declare _APP_HELPER_PATH="${APP_PATH:-}"

declare _APP_BASE_DIR="${_APP_BASE_DIR:-$(pwd)}"
declare _APP_USER="${_APP_USER:-www-data}"
declare _APP_SERVICE="${_APP_SERVICE:-app}"
declare _APP_COMPOSE_FILE="${_APP_COMPOSE_FILE:-${_APP_BASE_DIR}/docker-compose.yml}"

# Is packages installed and where
# values:
#   0: not installed
#   1: installed inside the service
#   2: installed on the host
#   "SERVICE_NAME": the name of the service that should run npm commands (Not Implemented)
declare _APP_NODE_INSTALLED=${_APP_NODE_INSTALLED:-}
declare _APP_COMPOSER_INSTALLED=${_APP_COMPOSER_INSTALLED:-}
declare _APP_ARTISAN_INSTALLED=${_APP_ARTISAN_INSTALLED:-}

declare _APP_COMPLETION_ARTISAN_COMMANDS
declare _APP_COMPLETION_COMPOSER_COMMANDS
declare _APP_COMPLETION_NPM_COMMANDS
declare _APP_COMPLETION_NODE_OPTIONS
declare _APP_COMPLETION_COMMANDS
declare _APP_COMPLETION_OPTIONS

#
# Export variables
#
export _APP_HELPER_NAME
export _APP_HELPER_VERSION
export _APP_HELPER_DIR
export _APP_HELPER_PATH

export _APP_BASE_DIR
export _APP_USER
export _APP_SERVICE
export _APP_COMPOSE_FILE

export _APP_NODE_INSTALLED
export _APP_COMPOSER_INSTALLED
export _APP_ARTISAN_INSTALLED

export _APP_COMPLETION_ARTISAN_COMMANDS
export _APP_COMPLETION_COMPOSER_COMMANDS
export _APP_COMPLETION_NPM_COMMANDS
export _APP_COMPLETION_NODE_OPTIONS
export _APP_COMPLETION_COMMANDS
export _APP_COMPLETION_OPTIONS

#
# Check if all variables are set
#

if [ -z "${_APP_HELPER_DIR}" ]; then
  _APP_HELPER_DIR="$(realpath "$0")"
  _APP_HELPER_DIR="$(dirname "${_APP_HELPER_DIR}")"
  _APP_HELPER_DIR="$(dirname "${_APP_HELPER_DIR}")"

  if [ ! -e "${_APP_HELPER_DIR}/._app_helper_dir" ]; then
    echo "There was an error while setting the app helper directory."
    echo "Please debug, current value: \"${_APP_HELPER_DIR}\""
  fi

  export _APP_HELPER_DIR
fi

if [ -z "${_APP_HELPER_PATH}" ]; then
  _APP_HELPER_PATH="${_APP_HELPER_DIR}/bin/${_APP_HELPER_FILENAME}"

  export _APP_HELPER_PATH
fi

if [ -z "${_APP_NODE_INSTALLED}" ]; then
  if [[ -n $(${_APP_HELPER_PATH} command -- -v node) ]]; then
    _APP_NODE_INSTALLED=1
  elif [[ -n $(command -v node) ]]; then
    _APP_NODE_INSTALLED=2
  else
    _APP_NODE_INSTALLED=0
  fi

  export _APP_NODE_INSTALLED
fi

if [ -z "${_APP_COMPOSER_INSTALLED}" ]; then
  if [[ -n $(${_APP_HELPER_PATH} command -- -v composer) ]]; then
    _APP_COMPOSER_INSTALLED=1
  elif [[ -n $(command -v composer) ]]; then
    _APP_COMPOSER_INSTALLED=2
  else
    _APP_COMPOSER_INSTALLED=0
  fi

  export _APP_COMPOSER_INSTALLED
fi

if [ -z "${_APP_ARTISAN_INSTALLED}" ]; then
  if [[ -n $(${_APP_HELPER_PATH} command -- -v php) ]]; then
    _APP_ARTISAN_INSTALLED=1
  elif [[ -n $(command -v php) ]]; then
    _APP_ARTISAN_INSTALLED=2
  else
    _APP_ARTISAN_INSTALLED=0
  fi

  export _APP_ARTISAN_INSTALLED
fi

################################################################################
# Aliases
#
# Add bash aliases for commands.
################################################################################

alias app="\${_APP_HELPER_PATH}"

################################################################################
# Completion
#
# Add bash completion support.
################################################################################

source "${_APP_HELPER_DIR}/src/completion.sh"
