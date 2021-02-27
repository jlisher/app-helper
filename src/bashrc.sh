#!/usr/bin/env bash
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

declare _APP_HELPER_NAME="${_APP_HELPER_NAME:-}"
declare _APP_HELPER_FILENAME="${_APP_HELPER_FILENAME:-}"
declare _APP_HELPER_VERSION="${APP_VERSION:-}"

declare _APP_HELPER_DIR="${_APP_HELPER_DIR}"
declare _APP_HELPER_PATH="${APP_PATH:-}"
declare _APP_HELPER_TEMP_DIR="${_APP_HELPER_TEMP_DIR:-}"

declare _APP_HELPER_BASE_DIR="${_APP_HELPER_BASE_DIR:-}"
declare _APP_HELPER_USER="${_APP_HELPER_USER:-}"
declare _APP_HELPER_SERVICE="${_APP_HELPER_SERVICE:-}"
declare _APP_HELPER_COMPOSE_FILE="${_APP_HELPER_COMPOSE_FILE:-}"

# Is packages installed and where
# values:
#   0: not installed
#   1: installed inside the service
#   2: installed on the host
#   "SERVICE_NAME": the name of the service that should run npm commands (Not Implemented)
declare _APP_HELPER_NODE_INSTALLED=${_APP_HELPER_NODE_INSTALLED:-}
declare _APP_HELPER_NPM_INSTALLED=${_APP_HELPER_NPM_INSTALLED:-}
declare _APP_HELPER_PHP_INSTALLED=${_APP_HELPER_PHP_INSTALLED:-}
declare _APP_HELPER_COMPOSER_INSTALLED=${_APP_HELPER_COMPOSER_INSTALLED:-}
declare _APP_HELPER_ARTISAN_INSTALLED=${_APP_HELPER_ARTISAN_INSTALLED:-}

#
# Export variables
#
export _APP_HELPER_NAME
export _APP_HELPER_FILENAME
export _APP_HELPER_VERSION

export _APP_HELPER_DIR
export _APP_HELPER_PATH
export _APP_HELPER_TMP_DIR

export _APP_HELPER_BASE_DIR
export _APP_HELPER_USER
export _APP_HELPER_SERVICE
export _APP_HELPER_COMPOSE_FILE

export _APP_HELPER_NODE_INSTALLED
export _APP_HELPER_NPM_INSTALLED
export _APP_HELPER_PHP_INSTALLED
export _APP_HELPER_COMPOSER_INSTALLED
export _APP_HELPER_ARTISAN_INSTALLED

################################################################################
# functions
#
# source the functionality required
################################################################################

source "${_APP_HELPER_DIR}/src/variables.sh"
source "${_APP_HELPER_DIR}/src/print.sh"

################################################################################
# Completion
#
# Add bash completion support.
################################################################################

source "${_APP_HELPER_DIR}/src/completion.sh"
