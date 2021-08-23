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
declare _APP_HELPER_ALIAS="${_APP_HELPER_ALIAS:-}"
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

################################################################################
# functions
#
# source the functionality required
################################################################################

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
    if [[ -n "${_APP_HELPER_ALIAS}" ]]; then
        echo "${_APP_HELPER_ALIAS}"
        return 0
    fi

    _APP_HELPER_ALIAS="app"

    export _APP_HELPER_ALIAS
    echo "${_APP_HELPER_ALIAS}"
    return 0
}

_app_helper_get_dir() {
    if [[ -n "${_APP_HELPER_DIR}" ]]; then
        echo "${_APP_HELPER_DIR}"
        return 0
    fi

    local dir

    dir="${0}"
    dir="$(dirname "${dir}")"
    dir="$(
        cd "${dir}" || exit 1
        pwd
    )"

    while ! _app_helper_check_install_dir "${dir}"; do
        if [[ "${dir}" == "/" ]]; then
            _app_helper_print_error_message "Could not find app helper directory."
            exit 1
        fi

        dir="$(dirname "${dir}")"
    done

    export _APP_HELPER_DIR="${dir}"
    echo "${_APP_HELPER_DIR}"
    return 0
}

_app_helper_get_tmp_dir() {
    if [[ -n "${_APP_HELPER_TEMP_DIR}" ]]; then
        echo "${_APP_HELPER_TEMP_DIR}"
        return 0
    fi

    _APP_HELPER_TEMP_DIR="$(_app_helper_get_dir)/.tmp"

    export _APP_HELPER_TEMP_DIR

    echo "${_APP_HELPER_TEMP_DIR}"
    return 0
}

_app_helper_get_path() {
    if [[ -n "${_APP_HELPER_PATH}" ]]; then
        echo "${_APP_HELPER_PATH}"
        return 0
    fi

    _APP_HELPER_PATH="$(_app_helper_get_dir)/src/app.sh"
    #    _APP_HELPER_PATH="_app_helper_run"

    export _APP_HELPER_PATH

    echo "${_APP_HELPER_PATH}"
    return 0
}

################################################################################
# Print helpers used by App helper
################################################################################

_app_helper_print_help() {
    cat <<EOF
$(_app_helper_get_name): is a utility tool that makes working with the underlying docker container easier and faster.

Usage:
    $(_app_helper_get_alias) COMMAND [OPTIONS] [--] [OPTIONS...]

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

################################################################################
# Variable data functions
#
# These are used to allow for a dynamic consistent API
################################################################################

declare -A _app_helper_options_map
_app_helper_pass_thru_array=()

_app_helper_get_base_dir() {
    if [[ -n "${_APP_HELPER_BASE_DIR}" ]]; then
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
    if [[ -n "${_APP_HELPER_USER}" ]]; then
        echo "${_APP_HELPER_USER}"
        return 0
    fi

    _APP_HELPER_USER="www-data"

    export _APP_HELPER_USER

    echo "${_APP_HELPER_USER}"
    return 0
}

_app_helper_get_service() {
    if [[ -n "${_APP_HELPER_SERVICE}" ]]; then
        echo "${_APP_HELPER_SERVICE}"
        return 0
    fi

    _APP_HELPER_SERVICE="app"

    export _APP_HELPER_SERVICE

    echo "${_APP_HELPER_SERVICE}"
    return 0
}

_app_helper_get_compose_file() {
    if [[ -n "${_APP_HELPER_COMPOSE_FILE}" ]]; then
        echo "${_APP_HELPER_COMPOSE_FILE}"
        return 0
    fi

    _APP_HELPER_COMPOSE_FILE="$(_app_helper_get_option "base_dir")/docker-compose.yml"

    export _APP_HELPER_COMPOSE_FILE

    echo "${_APP_HELPER_COMPOSE_FILE}"
    return 0
}

_app_helper_get_option() {
    local name

    name="${1}"

    if [[ -n "${_app_helper_options_map[${name}]}" ]]; then
        echo "${_app_helper_options_map[${name}]}"
        return 0
    fi

    case "${name}" in
    base_dir)
        _app_helper_options_map[base_dir]="$(_app_helper_get_base_dir)"
        ;;
    compose_file)
        _app_helper_options_map[compose_file]="$(_app_helper_get_compose_file)"
        ;;
    user)
        _app_helper_options_map[user]="$(_app_helper_get_user)"
        ;;
    service)
        _app_helper_options_map[service]="$(_app_helper_get_service)"
        ;;
    esac

    if [[ -n "${_app_helper_options_map[${name}]}" ]]; then
        echo "${_app_helper_options_map[${name}]}"
        return 0
    fi

    _app_helper_print_error_message "OPTION not defined: ${name}"
    exit 1
}

# This should maybe be cleaned up but works for now
_app_helper_get_command_install_location() {
    local name

    name="${1}"

    case "${name}" in
    node)
        if [[ -z "${_APP_HELPER_NODE_INSTALLED}" ]]; then
            if [[ -n $($(_app_helper_get_path) command -- -v node) ]]; then
                _APP_HELPER_NODE_INSTALLED=1
            elif [[ -n $(command -v node) ]]; then
                _APP_HELPER_NODE_INSTALLED=2
            else
                _APP_HELPER_NODE_INSTALLED=0
            fi

            export _APP_HELPER_NODE_INSTALLED
        fi

        echo "${_APP_HELPER_NODE_INSTALLED}"
        ;;
    npm)
        if [[ -z "${_APP_HELPER_NPM_INSTALLED}" ]]; then
            _APP_HELPER_NPM_INSTALLED="$(_app_helper_get_command_install_location "node")"
            export _APP_HELPER_NPM_INSTALLED
        fi

        echo "${_APP_HELPER_NPM_INSTALLED}"
        ;;
    php)
        if [[ -z "${_APP_HELPER_PHP_INSTALLED}" ]]; then
            if [[ -n $($(_app_helper_get_path) command -- -v php) ]]; then
                _APP_HELPER_PHP_INSTALLED=1
            elif [[ -n $(command -v php) ]]; then
                _APP_HELPER_PHP_INSTALLED=2
            else
                _APP_HELPER_PHP_INSTALLED=0
            fi

            export _APP_HELPER_PHP_INSTALLED
        fi

        echo "${_APP_HELPER_PHP_INSTALLED}"
        ;;
    artisan)
        if [[ -z "${_APP_HELPER_ARTISAN_INSTALLED}" ]]; then
            _APP_HELPER_ARTISAN_INSTALLED="$(_app_helper_get_command_install_location "php")"

            if [[ "${_APP_HELPER_ARTISAN_INSTALLED}" -gt 0 ]] && [[ ! -x "$(_app_helper_get_base_dir)/artisan" ]]; then
                _APP_HELPER_ARTISAN_INSTALLED=0
            fi

            export _APP_HELPER_ARTISAN_INSTALLED
        fi

        echo "${_APP_HELPER_ARTISAN_INSTALLED}"
        ;;
    composer)
        if [[ -z "${_APP_HELPER_COMPOSER_INSTALLED}" ]]; then
            if [[ -n $($(_app_helper_get_path) command -- -v composer) ]]; then
                _APP_HELPER_COMPOSER_INSTALLED=1
            elif [[ -n $(command -v composer) ]]; then
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
    [[ ! -e "${1}/.app_helper_dir" ]] && return 1

    return 0
}

_app_helper_check_command_install() {
    local name error=0

    name="${1}"

    [[ "$(_app_helper_get_command_install_location "${name}")" -eq 0 ]] && error=1

    if [[ "${error}" -ne 0 ]]; then
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
    while [[ ! "${1}" == '--' ]] && [[ -n "${1}" ]]; do
        case "${1}" in
        -v | --version)
            _app_helper_print_version
            ;;
        -h | --help)
            _app_helper_print_help
            ;;
        -b | --base-dir | --base-directory)
            shift
            _app_helper_options_map[base_dir]="${1}"
            ;;
        -f | --compose-file)
            shift
            _app_helper_options_map[compose_file]="${1}"
            ;;
        -u | --user)
            shift
            _app_helper_options_map[user]="${1}"
            ;;
        -s | --service)
            shift
            _app_helper_options_map[service]="${1}"
            ;;
        *)
            # parse command
            if [[ ! "${1}" =~ ^- ]] && [[ -z "${_app_helper_options_map[command]}" ]]; then
                _app_helper_options_map[command]="${1}"
            else
                # add all unneeded arguments to the `_app_helper_pass_thru_array` array
                _app_helper_pass_thru_array+=("${1}")
            fi
            ;;
        esac
        shift
    done

    # check for pass thru argument and shift it off
    if [[ "${1}" == '--' ]]; then
        shift
    fi

    # add all remaining arguments to the `_app_helper_pass_thru_array` array
    while [[ -n "${1}" ]]; do
        _app_helper_pass_thru_array+=("${1}")
        shift
    done
}

_app_helper_install() {
    PROJECT_RC="$(_app_helper_get_base_dir)/.bashrc"

    # touch the file if it doesn't exist. Just to make things more consistent later.
    [[ ! -f "${PROJECT_RC}" ]] && touch "${PROJECT_RC}"

    sed -zi "s/# $(_app_helper_get_name) .bashrc\n.*\n# $(_app_helper_get_name) .bashrc\n//g" "${PROJECT_RC}"

    # Now lets write our helpers that will need to be `source`'d.
    cat >>"${PROJECT_RC}" <<EOF
# $(_app_helper_get_name) .bashrc
# This just sets the app helper directory and script alias, as sources the bashrc for the app helper.
#
_APP_HELPER_DIR="$(_app_helper_get_dir)"
source "\${_APP_HELPER_DIR}/src/bashrc.sh"
alias $(_app_helper_get_alias)="$(_app_helper_get_path)"
_app_helper_load_environment
_app_helper_clear_tmp
complete -o default -F _app_helper_completion "$(_app_helper_get_alias)"

#
# Export variables
#
export _APP_HELPER_NAME
export _APP_HELPER_ALIAS
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
    local command

    command="$(_app_helper_get_option "command")"

    _app_helper_check_command_install "${command}"

    case "${command}" in
    down) _app_helper_run_down ;;
    up) _app_helper_run_up ;;

    install) _app_helper_install ;;
    update) _app_helper_git_update ;;

    php | npm | node)
        case "$(_app_helper_get_command_install_location "${command}")" in
        1) _app_helper_run_container "${command}" ;;
        2) _app_helper_run_local "${command}" ;;
        esac
        ;;
    artisan)
        case "$(_app_helper_get_command_install_location "artisan")" in
        1) _app_helper_run_container "php artisan" ;;
        2) _app_helper_run_local "php artisan" ;;
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
    docker-compose -f "$(_app_helper_get_option "compose_file")" down "$(_app_helper_get_option "service")" "${_app_helper_pass_thru_array[@]}"

    exit $?
}

_app_helper_run_up() {
    docker-compose -f "$(_app_helper_get_option "compose_file")" up "$(_app_helper_get_option "service")" "${_app_helper_pass_thru_array[@]}"

    exit $?
}

_app_helper_run_shell() {
    docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" su -s /bin/sh "$(_app_helper_get_option "user")"

    exit $?
}

_app_helper_run_container() {
    local command

    command="${1}"

    docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" su -s /bin/sh -c "${command} ${_app_helper_pass_thru_array[*]}" "$(_app_helper_get_option "user")"

    exit $?
}

_app_helper_run_local() {
    local command

    command="${1}"

    "${command}" "${_app_helper_pass_thru_array[@]}"

    exit $?
}

_app_helper_clear_tmp() {
    for file in "$(_app_helper_get_tmp_dir)"/*.list; do
        if [ -w "${file}" ]; then
            rm "${file}"
        fi
    done
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
    # Help if no arguments passed
    [[ "$#" -eq 0 ]] && _app_helper_print_help

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
    local file

    file="$(_app_helper_get_dir)/conf/completion_commands.list"

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_options_completions() {
    local file

    file="$(_app_helper_get_dir)/conf/completion_options.list"

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_composer_completions() {
    if [[ "$(_app_helper_get_command_install_location "composer")" -eq 0 ]]; then
        return 0
    fi

    local file

    file="$(_app_helper_get_tmp_dir)/composer_commands.list"

    if [[ ! -f "${file}" ]] && [[ -w "$(dirname "${file}")" ]]; then
        $(_app_helper_get_path) composer -- --raw --no-ansi list | sed "s/[[:space:]].*//" | sed "s/[[:space:]]//" >"${file}"
    fi

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_artisan_completions() {
    if [[ "$(_app_helper_get_command_install_location "artisan")" -eq 0 ]]; then
        return 0
    fi

    local file

    file="$(_app_helper_get_tmp_dir)/artisan_commands.list"

    if [[ ! -f "${file}" ]] && [[ -w "$(dirname "${file}")" ]]; then
        $(_app_helper_get_path) artisan -- --raw --no-ansi list | sed "s/[[:space:]].*//" | sed "s/[[:space:]]//" >"${file}"
    fi

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_npm_commands_completions() {
    if [[ "$(_app_helper_get_command_install_location "npm")" -eq 0 ]]; then
        return 0
    fi

    local file

    file="$(_app_helper_get_dir)/conf/npm_commands.list"

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_node_options_completions() {
    if [[ "$(_app_helper_get_command_install_location "node")" -eq 0 ]]; then
        return 0
    fi

    local file

    file="$(_app_helper_get_dir)/conf/node_options.list"

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_completion() {
    local word_list cur_command

    if [ "${COMP_CWORD}" -eq 1 ]; then
        word_list="$(_app_helper_commands_completions)"
    else
        cur_command="${COMP_WORDS[1]}"

        case "${cur_command}" in
        # artisan completion
        artisan)
            COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
            word_list="$(_app_helper_artisan_completions)"
            ;;
        # composer completion
        composer)
            word_list="$(_app_helper_composer_completions)"
            ;;
        # npm completion. Stolen from the `npm completion` command
        npm)
            word_list="$(_app_helper_npm_commands_completions)"
            ;;
        node)
            word_list="$(_app_helper_node_options_completions)"
            ;;
        esac
    fi

    if [ -n "${word_list}" ]; then
        word_list="${word_list} $(_app_helper_options_completions)"
        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "${word_list}" -- "${COMP_WORDS[COMP_CWORD]}"))
    else
        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -o default -- "${COMP_WORDS[COMP_CWORD]}"))
    fi

    return 0
}
