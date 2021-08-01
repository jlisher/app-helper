#!/usr/bin/env bash

#
# Variable data
#
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

#
# Checks
#
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

#
# Commands
#
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
export _APP_HELPER_DIR="$(_app_helper_get_dir)"
alias $(_app_helper_get_alias)="$(_app_helper_get_path)"
[ -f "\${_APP_HELPER_DIR}/src/bashrc.sh" ] && source "\${_APP_HELPER_DIR}/src/bashrc.sh"
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

_app_helper_git_update() {
    local current_dir

    current_dir="${PWD}"

    if [[ -z "$(command -v php)" ]]; then
        _app_helper_print_error_message "No php executable was found."
        exit 1
    fi

    if [[ -z "$(command -v git)" ]]; then
        _app_helper_print_error_message "No git executable was found."
        exit 1
    fi

    if [[ -z "$(command -v composer)" ]]; then
        _app_helper_print_error_message "No composer executable was found."
        exit 1
    fi

    if [[ ! -d "$(_app_helper_get_base_dir)/.git" ]]; then
        _app_helper_print_error_message "No git repo was found in your project directory."
        exit 1
    fi

    if ! cd "$(_app_helper_get_base_dir)"; then
        _app_helper_print_error_message "There was an issue while accessing your your project directory."
        exit 1
    fi

    git fetch --depth=10 --prune --progress origin

    php artisan down
    git pull

    COMPOSER_MEMORY_LIMIT=-1 composer install --no-dev

    php artisan migrate --force
    php artisan optimize

    php artisan up

    _app_helper_print_info_message "Project successfully updated."

    if ! cd "${current_dir}"; then
        _app_helper_print_error_message "There was an issue reverting back to the original directory."
        exit 1
    fi

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
    docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" su "$(_app_helper_get_option "user")"

    exit $?
}

_app_helper_run_container() {
    local command

    command="${1}"

    docker-compose -f "$(_app_helper_get_option "compose_file")" exec "$(_app_helper_get_option "service")" su -c "${command} ${_app_helper_pass_thru_array[*]}" "$(_app_helper_get_option "user")"

    exit $?
}

_app_helper_run_local() {
    local command

    command="${1}"

    "${command}" "${_app_helper_pass_thru_array[@]}"

    exit $?
}
