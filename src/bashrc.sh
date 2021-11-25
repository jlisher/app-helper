#!/usr/bin/env sh
#
# .bashrc for app utility
#
# This should be source`d in the current working shell to allow you to take full
# advantage of this utility.
#
# shellcheck disable=SC2039
# shellcheck disable=SC2207

if [ "${_APP_HELPER_DEBUG}" = "1" ]; then
    set -x # debugging, this is prints every command executed.
fi

################################################################################
# Variables
#
# Define some variables for easy configuration.
################################################################################

export _APP_HELPER_NAME="${_APP_HELPER_NAME:-}"
export _APP_HELPER_ALIAS="${_APP_HELPER_ALIAS:-}"
export _APP_HELPER_VERSION="${APP_VERSION:-}"

export _APP_HELPER_DIR="${_APP_HELPER_DIR}"
export _APP_HELPER_PATH="${APP_PATH:-}"
export _APP_HELPER_TEMP_DIR="${_APP_HELPER_TEMP_DIR:-}"

export _APP_HELPER_BASE_DIR="${_APP_HELPER_BASE_DIR:-}"
export _APP_HELPER_USER="${_APP_HELPER_USER:-}"
export _APP_HELPER_CUID="${_APP_HELPER_CUID:-}"
export _APP_HELPER_SERVICE="${_APP_HELPER_SERVICE:-}"
export _APP_HELPER_COMPOSE_FILE="${_APP_HELPER_COMPOSE_FILE:-}"

# Is packages installed and where
# values:
#   0: not installed
#   1: installed inside the service
#   2: installed on the host
#   "SERVICE_NAME": the name of the service that should run npm commands (Not Implemented)
export _APP_HELPER_NODE_INSTALLED=${_APP_HELPER_NODE_INSTALLED:-}
export _APP_HELPER_NPM_INSTALLED=${_APP_HELPER_NPM_INSTALLED:-}
export _APP_HELPER_PHP_INSTALLED=${_APP_HELPER_PHP_INSTALLED:-}
export _APP_HELPER_COMPOSER_INSTALLED=${_APP_HELPER_COMPOSER_INSTALLED:-}
export _APP_HELPER_ARTISAN_INSTALLED=${_APP_HELPER_ARTISAN_INSTALLED:-}

################################################################################
# Global variables used by App helper
################################################################################

_app_helper_get_name() {
    if [ -z "${_APP_HELPER_NAME}" ]; then
        _APP_HELPER_NAME="App Helper"
    fi

    export _APP_HELPER_NAME
    echo "${_APP_HELPER_NAME}"
    return 0
}

_app_helper_get_version() {
    if [ -z "${_APP_HELPER_VERSION}" ]; then
        _APP_HELPER_VERSION="v0.2.0"
    fi

    export _APP_HELPER_VERSION
    echo "${_APP_HELPER_VERSION}"
    return 0
}

_app_helper_get_alias() {
    if [ -n "${_APP_HELPER_ALIAS}" ]; then
        echo "${_APP_HELPER_ALIAS}"
        return 0
    fi

    _APP_HELPER_ALIAS="app"

    export _APP_HELPER_ALIAS
    echo "${_APP_HELPER_ALIAS}"
    return 0
}

_app_helper_get_dir() {
    if [ -n "${_APP_HELPER_DIR}" ]; then
        echo "${_APP_HELPER_DIR}"
        return 0
    fi

    dir="${0}"
    dir="$(dirname "${dir}")"
    dir="$(
        cd "${dir}" || return 1
        pwd
    )"

    while ! _app_helper_check_install_dir "${dir}"; do
        if [ "${dir}" = "/" ]; then
            _app_helper_print_error_message "Could not find app helper directory."
            return 1
        fi

        dir="$(dirname "${dir}")"
    done

    export _APP_HELPER_DIR="${dir}"
    echo "${_APP_HELPER_DIR}"
    return 0
}

_app_helper_get_tmp_dir() {
    if [ -n "${_APP_HELPER_TEMP_DIR}" ]; then
        echo "${_APP_HELPER_TEMP_DIR}"
        return 0
    fi

    _APP_HELPER_TEMP_DIR="/tmp"

    export _APP_HELPER_TEMP_DIR

    echo "${_APP_HELPER_TEMP_DIR}"
    return 0
}

_app_helper_get_path() {
    if [ -n "${_APP_HELPER_PATH}" ]; then
        echo "${_APP_HELPER_PATH}"
        return 0
    fi

    _APP_HELPER_PATH="$(_app_helper_get_dir)/src/app.sh"

    export _APP_HELPER_PATH

    echo "${_APP_HELPER_PATH}"
    return 0
}

################################################################################
# Print helpers used by App helper
# For colours: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
################################################################################

_app_helper_print_help() {
    cat <<EOF
$(_app_helper_get_name): is a utility tool that makes working with the underlying docker container easier and faster.

Usage:
    $(_app_helper_get_alias) [OPTIONS] COMMAND [--] [COMMAND_OPTIONS...]

COMMAND
    artisan     Used to run the artisan command of laravel.
    composer    run the composer tool.
    down        Tear the container down.
    install     Install the .bashrc file that you can source to setup the tool.
    npm         Run NPM inside the container.
    node        Run NodeJS inside the container.
    shell       Launches an interactive shell inside the container. (doesn't support pass thru)
    up          Bring the docker container up.
    *           This has the ability to run any command your container supports however, it is not supported by this tool yet. Please feel free to contribute and add the support for your favorite tools and scripts.

OPTIONS
    These are just extra parameters/options for the COMMAND used.

    -u | --user USER            Set the user to be used inside the container. Ignored if not running as root inside the container.
    -f | --compose-file FILE    docker-compose.yml file to use.
    -s | --service NAME         The name of the service in the docker-compose.yml file.
    -h | --help                 Print this message and exit.
    -v | --version              Print version information.
    --                          Stop processing arguments

    Please reference the relative tool's documentation for further information.

COMMAND_OPTIONS
    These are the options that should be passed to the COMMAND.
    All options set after the COMMAND will automatically be passed to the COMMAND.

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
    echo "\033[0;33mWARNING: ${1}\033[0m"
    return 0
}

_app_helper_print_error_message() {
    echo "\033[0;31mERROR: ${1}\033[0m"
    return 0
}

_app_helper_print_message() {
    echo "${1}"
    return 0
}

################################################################################
# Variable data functions
#
# These are used to allow for a dynamic consistent API
################################################################################

export _app_helper_pass_thru=""
export _app_helper_options_map_base_dir=""
export _app_helper_options_map_compose_file=""
export _app_helper_options_map_user=""
export _app_helper_options_map_service=""
export _app_helper_options_map_command=""

_app_helper_get_base_dir() {
    if [ -n "${_APP_HELPER_BASE_DIR}" ]; then
        echo "${_APP_HELPER_BASE_DIR}"
        return 0
    fi

    _APP_HELPER_BASE_DIR="$(pwd)"

    # make sure we are not in the `node_modules` directory
    _APP_HELPER_BASE_DIR="${_APP_HELPER_BASE_DIR%/node_modules*}"

    export _APP_HELPER_BASE_DIR

    echo "${_APP_HELPER_BASE_DIR}"
    return 0
}

_app_helper_get_user() {
    if [ -n "${_APP_HELPER_USER}" ]; then
        echo "${_APP_HELPER_USER}"
        return 0
    fi

    _APP_HELPER_USER="www-data"

    export _APP_HELPER_USER

    echo "${_APP_HELPER_USER}"
    return 0
}

_app_helper_get_service() {
    if [ -n "${_APP_HELPER_SERVICE}" ]; then
        echo "${_APP_HELPER_SERVICE}"
        return 0
    fi

    _APP_HELPER_SERVICE="app"

    export _APP_HELPER_SERVICE

    echo "${_APP_HELPER_SERVICE}"
    return 0
}

_app_helper_get_compose_file() {
    if [ -n "${_APP_HELPER_COMPOSE_FILE}" ]; then
        echo "${_APP_HELPER_COMPOSE_FILE}"
        return 0
    fi

    _APP_HELPER_COMPOSE_FILE="$(_app_helper_get_option "base_dir")/docker-compose.yml"

    export _APP_HELPER_COMPOSE_FILE

    echo "${_APP_HELPER_COMPOSE_FILE}"
    return 0
}

_app_helper_get_cuid() {
    if [ -n "${_APP_HELPER_CUID}" ]; then
        echo "${_APP_HELPER_CUID}"
        return 0
    fi

    _APP_HELPER_CUID="$(_app_helper_run_get_cuid)"

    export _APP_HELPER_CUID

    echo "${_APP_HELPER_CUID}"
    return 0
}

_app_helper_get_option() {
    name="${1}"

    case "${name}" in
    base_dir)
        if [ -z "${_app_helper_options_map_base_dir}" ]; then
            _app_helper_options_map_base_dir="$(_app_helper_get_base_dir)"
            export _app_helper_options_map_base_dir
        fi

        echo "${_app_helper_options_map_base_dir}"
        return 0
        ;;
    compose_file)
        if [ -z "${_app_helper_options_map_compose_file}" ]; then
            _app_helper_options_map_compose_file="$(_app_helper_get_compose_file)"
            export _app_helper_options_map_compose_file
        fi

        echo "${_app_helper_options_map_compose_file}"
        return 0
        ;;
    user)
        if [ -z "${_app_helper_options_map_user}" ]; then
            _app_helper_options_map_user="$(_app_helper_get_user)"
            export _app_helper_options_map_user
        fi

        echo "${_app_helper_options_map_user}"
        return 0
        ;;
    service)
        if [ -z "${_app_helper_options_map_service}" ]; then
            _app_helper_options_map_service="$(_app_helper_get_service)"
            export _app_helper_options_map_service
        fi

        echo "${_app_helper_options_map_service}"
        return 0
        ;;
    command)
        echo "${_app_helper_options_map_command}"
        return 0
        ;;
    esac

    _app_helper_print_error_message "OPTION not defined: ${name}"
    exit 1
}

# This should maybe be cleaned up but works for now
_app_helper_get_command_install_location() {
    name="${1}"

    case "${name}" in
    node)
        if [ -z "${_APP_HELPER_NODE_INSTALLED}" ]; then
            if [ -n "$($(_app_helper_get_path) command -- -v node)" ]; then
                _APP_HELPER_NODE_INSTALLED=1
            elif [ -n "$(command -v node)" ]; then
                _APP_HELPER_NODE_INSTALLED=2
            else
                _APP_HELPER_NODE_INSTALLED=0
            fi

            export _APP_HELPER_NODE_INSTALLED
        fi

        echo "${_APP_HELPER_NODE_INSTALLED}"
        ;;
    npm)
        if [ -z "${_APP_HELPER_NPM_INSTALLED}" ]; then
            _APP_HELPER_NPM_INSTALLED="$(_app_helper_get_command_install_location "node")"
            export _APP_HELPER_NPM_INSTALLED
        fi

        echo "${_APP_HELPER_NPM_INSTALLED}"
        ;;
    php)
        if [ -z "${_APP_HELPER_PHP_INSTALLED}" ]; then
            if [ -n "$($(_app_helper_get_path) command -- -v php)" ]; then
                _APP_HELPER_PHP_INSTALLED=1
            elif [ -n "$(command -v php)" ]; then
                _APP_HELPER_PHP_INSTALLED=2
            else
                _APP_HELPER_PHP_INSTALLED=0
            fi

            export _APP_HELPER_PHP_INSTALLED
        fi

        echo "${_APP_HELPER_PHP_INSTALLED}"
        ;;
    artisan)
        if [ -z "${_APP_HELPER_ARTISAN_INSTALLED}" ]; then
            _APP_HELPER_ARTISAN_INSTALLED="$(_app_helper_get_command_install_location "php")"

            if [ "${_APP_HELPER_ARTISAN_INSTALLED}" -gt 0 ] && [ ! -f "$(_app_helper_get_base_dir)/artisan" ]; then
                _APP_HELPER_ARTISAN_INSTALLED=0
            fi

            export _APP_HELPER_ARTISAN_INSTALLED
        fi

        echo "${_APP_HELPER_ARTISAN_INSTALLED}"
        ;;
    composer)
        if [ -z "${_APP_HELPER_COMPOSER_INSTALLED}" ]; then
            if [ -n "$($(_app_helper_get_path) command -- -v composer)" ]; then
                _APP_HELPER_COMPOSER_INSTALLED=1
            elif [ -n "$(command -v composer)" ]; then
                _APP_HELPER_COMPOSER_INSTALLED=2
            else
                _APP_HELPER_COMPOSER_INSTALLED=0
            fi

            export _APP_HELPER_COMPOSER_INSTALLED
        fi

        echo "${_APP_HELPER_COMPOSER_INSTALLED}"
        ;;
    *)
        # fallback to container service
        echo 1
        ;;
    esac
}

################################################################################
# Checks
################################################################################

_app_helper_check_install_dir() {
    [ ! -e "${1}/.app_helper_dir" ] && return 1

    return 0
}

_app_helper_check_command_install() {
    error=0
    name="${1}"

    [ "$(_app_helper_get_command_install_location "${name}")" -eq 0 ] && error=1

    if [ "${error}" -ne 0 ]; then
        _app_helper_print_error_message "${name} is not installed in the container or on the host."
        _app_helper_print_error_message "Please install ${name}."
        exit 1
    fi
}

################################################################################
# Commands
################################################################################

_app_helper_collect_arguments() {
    # parse options
    while true; do
        case "${1}" in
        -v | --version)
            _app_helper_print_version
            ;;
        -h | --help)
            _app_helper_print_help
            ;;
        -b | --base-dir | --base-directory)
            shift
            _app_helper_options_map_base_dir="${1}"
            export _app_helper_options_map_base_dir
            shift
            ;;
        -f | --compose-file)
            shift
            _app_helper_options_map_compose_file="${1}"
            export _app_helper_options_map_compose_file
            shift
            ;;
        -u | --user)
            shift
            _app_helper_options_map_user="${1}"
            export _app_helper_options_map_user
            shift
            ;;
        -s | --service)
            shift
            _app_helper_options_map_service="${1}"
            export _app_helper_options_map_service
            shift
            ;;
        *)
            _app_helper_options_map_command="${1}"
            export _app_helper_options_map_command
            shift
            # break out of the while loop if we have a command set
            break
            ;;
        esac
    done

    # check for pass thru argument and shift it off
    if [ "${1}" = '--' ]; then
        shift
    fi

    # add all remaining arguments to the `_app_helper_pass_thru_array` array
    while [ -n "${1}" ]; do
        _app_helper_pass_thru="${_app_helper_pass_thru} ${1}"
        shift
    done

    export _app_helper_pass_thru
}

_app_helper_install() {
    PROJECT_RC="$(_app_helper_get_base_dir)/.bashrc"
    TEMP_FILE="$(_app_helper_get_tmp_dir)/~.bashrc.tmp"

    # process current .bashrc file
    if test -f "${PROJECT_RC}"; then
        jq --raw-output --raw-input --slurp \
            'split("\n") | {lines: ., first: index("# App Helper .bashrc"), last: rindex("# App Helper .bashrc")} | {pre_plucked: .lines[:.first], post_plucked: .lines[(.last + 1):]} | flatten | join("\n")' \
            "${PROJECT_RC}" >"${TEMP_FILE}"

        mv "${TEMP_FILE}" "${PROJECT_RC}"
    else
        touch "${PROJECT_RC}"
    fi

    # Now lets write our helpers that will need to be `source`'d.
    cat >>"${PROJECT_RC}" <<EOF
# $(_app_helper_get_name) .bashrc
# This just sets the app helper directory and script alias, as sources the bashrc for the app helper.
#
_APP_HELPER_DIR="$(_app_helper_get_dir)"
source "\${_APP_HELPER_DIR}/src/bashrc.sh"
alias $(_app_helper_get_alias)="$(_app_helper_get_path)"

#
# Export variables
#
export _APP_HELPER_BASE_DIR="$(_app_helper_get_base_dir)"
export _APP_HELPER_USER="$(_app_helper_get_user)"
export _APP_HELPER_CUID="$(_app_helper_run_get_cuid)"
export _APP_HELPER_SERVICE="$(_app_helper_get_service)"
export _APP_HELPER_COMPOSE_FILE="$(_app_helper_get_compose_file)"

# Is packages installed and where
# values:
#   0: not installed
#   1: installed inside the service
#   2: installed on the host
#   "SERVICE_NAME": the name of the service that should run npm commands (Not Implemented)
export _APP_HELPER_NODE_INSTALLED="${_APP_HELPER_NODE_INSTALLED:-}"
export _APP_HELPER_NPM_INSTALLED="${_APP_HELPER_NPM_INSTALLED:-}"
export _APP_HELPER_PHP_INSTALLED="${_APP_HELPER_PHP_INSTALLED:-}"
export _APP_HELPER_COMPOSER_INSTALLED="${_APP_HELPER_COMPOSER_INSTALLED:-}"
export _APP_HELPER_ARTISAN_INSTALLED="${_APP_HELPER_ARTISAN_INSTALLED:-}"

#
# Load the environment
#
_app_helper_load_environment
_app_helper_clear_tmp
complete -o default -F _app_helper_completion "$(_app_helper_get_alias)"

# $(_app_helper_get_name) .bashrc
EOF

    # print the success message and exit
    _app_helper_print_info_message "$(_app_helper_get_name) has been successfully installed in your project."
    _app_helper_print_info_message ""
    _app_helper_print_info_message "Note: some lines have been appended to the following files:"
    _app_helper_print_info_message "  - ${PROJECT_RC}"
    _app_helper_print_info_message "These appends are required for the tool to function."
    exit 0
}

_app_helper_run_command() {
    command="$(_app_helper_get_option "command")"

    _app_helper_check_command_install "${command}"

    case "${command}" in
    down) _app_helper_run_down ;;
    up) _app_helper_run_up ;;

    install) _app_helper_install ;;

    php | npm | node)
        case "$(_app_helper_get_command_install_location "${command}")" in
        1) _app_helper_run_container "${command}" ;;
        2) _app_helper_run_local "${command}" ;;
        esac
        ;;
    artisan)
        case "$(_app_helper_get_command_install_location "artisan")" in
        1) _app_helper_run_container "php -d memory_limit=-1 artisan" ;;
        2) _app_helper_run_local "php -d memory_limit=-1 artisan" ;;
        esac
        ;;
    composer)
        case "$(_app_helper_get_command_install_location "composer")" in
        1) _app_helper_run_container "COMPOSER_MEMORY_LIMIT=-1 composer" ;;
        2) _app_helper_run_local "COMPOSER_MEMORY_LIMIT=-1 composer" ;;
        esac
        ;;

    shell) _app_helper_run_shell ;;

    *) _app_helper_run_container "${command}" ;;
    esac

    exit $?
}

_app_helper_run_down() {
    docker-compose -f "$(_app_helper_get_option "compose_file")" down "$(_app_helper_get_option "service")" "${_app_helper_pass_thru}"

    exit $?
}

_app_helper_run_up() {
    docker-compose -f "$(_app_helper_get_option "compose_file")" up "$(_app_helper_get_option "service")" "${_app_helper_pass_thru}"

    exit $?
}

_app_helper_run_shell() {
    # don't use su for execution if we are not running as root.
    case "$(_app_helper_get_cuid)" in
    0*)
        docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" su -s /bin/sh "$(_app_helper_get_option "user")"
        ;;
    *)
        docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" /bin/sh -l
        ;;
    esac

    exit $?
}

_app_helper_run_container() {
    command="${1}"

    # don't use su for execution if we are not running as root.
    case "$(_app_helper_get_cuid)" in
    0*)
        docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" su -s /bin/sh -c "${command} ${_app_helper_pass_thru}" "$(_app_helper_get_option "user")"
        ;;
    *)
        docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" /bin/sh -c "${command} ${_app_helper_pass_thru}"
        ;;
    esac
    exit $?
}

_app_helper_run_get_cuid() {
    # for some reason `\r` is printed with the uid, so piping to `sed 's/\r//'` to clean that up.
    docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" id -u | sed 's/\r//'
    return $?
}

_app_helper_run_local() {
    command="${1}"

    "${command}" "${_app_helper_pass_thru}"

    exit $?
}

_app_helper_clear_tmp() {
    test -f "$(_app_helper_get_tmp_dir)/composer_commands.json" && rm -rf "$(_app_helper_get_tmp_dir)/composer_commands.json"
    test -f "$(_app_helper_get_tmp_dir)/artisan_commands.json" && rm -rf "$(_app_helper_get_tmp_dir)/artisan_commands.json"
}

_app_helper_load_environment() {
    _app_helper_get_name >/dev/null 2>&1
    _app_helper_get_version >/dev/null 2>&1
    _app_helper_get_dir >/dev/null 2>&1
    _app_helper_get_alias >/dev/null 2>&1
    _app_helper_get_path >/dev/null 2>&1
    _app_helper_get_base_dir >/dev/null 2>&1

    _app_helper_get_command_install_location "php" >/dev/null 2>&1
    _app_helper_get_command_install_location "npm" >/dev/null 2>&1
    _app_helper_get_command_install_location "node" >/dev/null 2>&1
    _app_helper_get_command_install_location "artisan" >/dev/null 2>&1
    _app_helper_get_command_install_location "composer" >/dev/null 2>&1
}

_app_helper_run() {
    # reset options
    export _app_helper_pass_thru=""
    export _app_helper_options_map_base_dir=""
    export _app_helper_options_map_compose_file=""
    export _app_helper_options_map_user=""
    export _app_helper_options_map_service=""

    # Help if no arguments passed
    [ "$#" -eq 0 ] && _app_helper_print_help

    # Collect passed arguments
    _app_helper_collect_arguments "$@"

    # Run the command
    _app_helper_run_command
}

################################################################################
# Completion
#
# Add bash completion support.
################################################################################

_app_helper_commands_completions() {
    file="$(_app_helper_get_dir)/conf/completion_commands.list"

    jq --raw-output --raw-input --slurp 'split("\n") | join(" ")' "${file}"

    return 0
}

_app_helper_options_completions() {
    file="$(_app_helper_get_dir)/conf/completion_options.list"

    jq --raw-output --raw-input --slurp 'split("\n") | join(" ")' "${file}"

    return 0
}

_app_helper_composer_completions() {
    if [ "$(_app_helper_get_command_install_location "composer")" -eq 0 ]; then
        return 0
    fi

    file="$(_app_helper_get_tmp_dir)/composer_commands.json"
    cur_command="list"
    current_word="${1}"
    current_command="${2}"
    word_list=""

    if [ ! -f "${file}" ]; then
        $(_app_helper_get_path) composer -- list --format=json >"${file}"
    fi

    if test "${current_word}" -eq 2; then
        word_list="$(jq --raw-output '.namespaces[].commands | join(" ")' "${file}")"
    else
        cur_command="${current_command}"
    fi

    options_list="$(jq --arg cur_command "${cur_command}" --raw-output '.commands[] | select(.name==$cur_command) | [.definition.options[].name] | join(" ")' "${file}")"
    word_list="${word_list} ${options_list}"

    echo "${word_list}"

    return 0
}

_app_helper_artisan_completions() {
    if [ "$(_app_helper_get_command_install_location "artisan")" -eq 0 ]; then
        return 0
    fi

    file="$(_app_helper_get_tmp_dir)/artisan_commands.json"
    cur_command="list"
    current_word="${1}"
    current_command="${2}"
    word_list=""

    if [ ! -f "${file}" ]; then
        $(_app_helper_get_path) artisan -- list --format=json >"${file}"
    fi

    if test "${current_word}" -eq 2; then
        word_list="$(jq --raw-output '.namespaces[].commands | join(" ")' "${file}")"
    else
        cur_command="${current_command}"
    fi

    options_list="$(jq --arg cur_command "${cur_command}" --raw-output '.commands[] | select(.name==$cur_command) | [.definition.options[].name] | join(" ")' "${file}")"
    word_list="${word_list} ${options_list}"

    echo "${word_list}"

    return 0
}

_app_helper_npm_commands_completions() {
    if [ "$(_app_helper_get_command_install_location "npm")" -eq 0 ]; then
        return 0
    fi

    file="$(_app_helper_get_dir)/conf/npm_commands.list"

    jq --raw-output --raw-input --slurp 'split("\n") | join(" ")' "${file}"

    return 0
}

_app_helper_node_options_completions() {
    if [ "$(_app_helper_get_command_install_location "node")" -eq 0 ]; then
        return 0
    fi

    file="$(_app_helper_get_dir)/conf/node_options.list"

    jq --raw-output --raw-input --slurp 'split("\n") | join(" ")' "${file}"

    return 0
}

_app_helper_completion() {
    if [ "${COMP_CWORD}" -eq 1 ]; then
        word_list="$(_app_helper_commands_completions)"
        word_list="${word_list} $(_app_helper_options_completions)"
    else
        # TODO: update this to allow the command to be found even if it is not the first argument
        cur_command="${COMP_WORDS[1]}"

        case "${cur_command}" in
        # artisan completion
        artisan)
            COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
            word_list="$(_app_helper_artisan_completions "${COMP_CWORD}" "${COMP_WORDS[2]}")"
            ;;
        # composer completion
        composer)
            word_list="$(_app_helper_composer_completions "${COMP_CWORD}" "${COMP_WORDS[2]}")"
            ;;
        # npm completion. Stolen from the `npm completion` command
        npm)
            word_list="$(_app_helper_npm_commands_completions)"
            ;;
        node)
            word_list="$(_app_helper_node_options_completions)"
            ;;
        # add the options completions if no command has been used
        *)
            word_list="${word_list} $(_app_helper_options_completions)"
        esac
    fi

    if [ -n "${word_list}" ]; then
        COMPREPLY=($(compgen -W "${word_list}" -- "${COMP_WORDS[COMP_CWORD]}"))
    else
        COMPREPLY=($(compgen -o default -- "${COMP_WORDS[COMP_CWORD]}"))
    fi

    return 0
}
