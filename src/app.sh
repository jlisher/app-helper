#!/usr/bin/env bash

# Get the parent directory
DIR="$(realpath "${0}")"
DIR="$(dirname "${DIR}")"

# source required files
source "${DIR}/variables.sh"
source "${DIR}/print.sh"
source "${DIR}/core.sh"

# Help if no arguments passed
[[ "$#" -eq 0 ]] && _app_helper_print_help

# Collect passed arguments
_app_helper_collect_arguments "$@"

# Run the command
_app_helper_run_command
