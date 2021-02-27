#!/usr/bin/env bash

#
# Print helpers used by App helper
#

_app_helper_print_help() {
    cat <<EOF
$(_app_helper_get_name): is a utility tool that makes working with the underlying docker container easier and faster.

Usage:
    app COMMAND [OPTIONS] [--] [OPTIONS...]

COMMAND
    artisan     Used to run the artisan command of laravel.
    composer    run the composer tool.
    down        Tear the container down.
    install     Install the .bashrc file that you can source to setup the tool.
    npm         Run NPM inside the container.
    node        Run NodeJS inside the container.
    shell       Launches an interactive shell inside the container. (doesn't support pass thru)
    up          Bring the docker container up.
    update      Update script for updating the production releases. (experimental - going to change)
    *           This has the ability to run any command your container supports however, it is not supported by this tool yet. Please feel free to contribute and add the support for your favorite tools and scripts.

OPTIONS
    These are just extra parameters/options for the COMMAND used.

    -u | --user USER            Set the user to be used inside the container.
    -f | --compose-file FILE    docker-compose.yml file to use.
    -s | --service NAME         The name of the service in the docker-compose.yml file.
    -h | --help                 Print this message and exit.
    -v | --version              Print version information.
    --                          Pass arguments after this thru to the command

    Please reference the relative tool's documentation for further information.

Note: Environment variables are available however not documented yet. see .bashrc for details.
EOF
    exit 0
}

_app_helper_print_version() {
    cat <<EOF
$(_app_helper_get_name) simple container command runner
Version: $(_app_helper_get_version)
EOF
    exit 0
}

_app_helper_print_debug_message() {
    if [ -z "${_APP_HELPER_DEBUG}" ]; then
        return 0
    fi

    echo "DEBUG: ${1}"
    return 0
}

_app_helper_print_info_message() {
    echo "INFO: ${1}"
    return 0
}

_app_helper_print_warning_message() {
    echo "WARNING: ${1}"
    return 0
}

_app_helper_print_error_message() {
    echo "ERROR: ${1}"
    return 0
}

_app_helper_print_message() {
    echo "${1}"
    return 0
}
