#!/bin/bash

_app_name() {
    echo "${_APP_HELPER_NAME}"
    return 0
}

_app_help_message() {
    cat <<EOF
$(_app_name): is a utility tool that makes working with the underlying docker container easier and faster.

Usage:
    app COMMAND [--] [OPTIONS]

COMMAND
    artisan     Used to run the artisan command of laravel.
    composer    run the composer tool.
    down        Tear the container down.
    install     Install the .bashrc file that you can source to setup the tool.
    npm         Run NPM inside the container.
    node        Run NodeJS inside the container.
    shell       Launches an interactive shell inside the container. aliases: sh, bash
    up          Bring the docker container up.
    update      Update script for updating the production releases.
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

_app_print_version() {
    cat <<EOF
$(_app_name) simple container command runner
Version: ${_APP_HELPER_VERSION}
EOF
    exit 0
}

_app_install_check() {
    local name error=0

    name="${1}"

    case "${name}" in
    npm|nodejs|node)
        if [[ "${_APP_NODE_INSTALLED}" -eq 0 ]]; then
            error=1
        fi
        ;;
    artisan|php)
        if [[ "${_APP_ARTISAN_INSTALLED}" -eq 0 ]]; then
            error=1
        fi
        ;;
    composer)
        if [[ "${_APP_COMPOSER_INSTALLED}" -eq 0 ]]; then
            error=1
        fi
        ;;
    esac

    if [[ "${error}" -ne 0 ]]; then
        cat <<EOF
${name} is not installed in the container or on the host.
Please install ${name}.
EOF
            exit 1
    fi
}

# Help if no command
if [ $# -eq 0 ]; then
    _app_help_message
fi

# define local variables to be used
if [[ -n "${_APP_BASE_DIR}" ]]; then
  _app_base_dir_option="${_APP_BASE_DIR}"
else
  _app_base_dir_option="$(pwd)"
fi

if [[ -n "${_APP_COMPOSE_FILE}" ]]; then
  _app_compose_file_option="${_APP_COMPOSE_FILE}"
else
  _app_compose_file_option="${_app_base_dir_option}/docker-compose.yml"
fi

_app_user_option="${_APP_USER}"
_app_service_option="${_APP_SERVICE}"

_app_pass_thru_array=()
_app_command=""

# parse command
case "${1}" in
# catch install command.
# We don't process this, simply run the install.sh script and exit.
install)
  dir="$(realpath "$0")"
  dir="$(dirname "$dir")"
  bash "${dir}/install.sh"
  exit 0
  ;;
# catch artisan commands
artisan)
    _app_install_check "${1}"
    _app_command="php artisan"
    ;;
# catch composer commands
composer)
    _app_install_check "${1}"
    _app_command="COMPOSER_MEMORY_LIMIT=-1 composer"
    ;;
# catch node commands
npm | node)
    _app_install_check "${1}"
    _app_command="${1}"
    ;;
# catch special control commands, these are used later.
# keeping them separate to allow us to control and extend it in the future.
up | down | update | shell)
    _app_command="${1}"
    ;;
# here we just catch the command so we can pass it to the container service
*)
    _app_install_check "${1}"
    if [[ ! "$1" =~ ^- ]]; then
        _app_command="${1}"
    fi
    ;;
esac

if [[ -n "${_app_command}" ]]; then
    shift
fi

# parse options
while [[ ! "${1}" == '--' ]] && [[ -n "${1}" ]]; do
    case "${1}" in
    -v | --version)
        _app_print_version
        ;;
    -h | --help)
        _app_help_message
        ;;
    -b | --base-dir | --base-directory)
        shift
        _app_base_dir_option="${1}"
        ;;
    -f | --compose-file)
        shift
        _app_compose_file_option="${1}"
        ;;
    -u | --user)
        shift
        _app_user_option="${1}"
        ;;
    -s | --service)
        shift
        _app_service_option="${1}"
        ;;
    *)
        _app_pass_thru_array+=("${1}")
        ;;
    esac
    shift
done
if [[ "${1}" == '--' ]]; then
    shift
fi
while [[ -n "${1}" ]]; do
    _app_pass_thru_array+=("${1}")
    shift
done

_app_pass_thru="${_app_pass_thru_array[*]}"

# run script
case "${_app_command}" in
up)
    docker-compose -f "${_app_compose_file_option}" up "${_app_service_option}" "${_app_pass_thru}"
    ;;
down)
    docker-compose -f "${_app_compose_file_option}" down "${_app_service_option}" "${_app_pass_thru}"
    ;;
update)
    bash "${_app_base_dir_option}/src/update.sh"
    ;;
shell)
    docker-compose -f "${_app_compose_file_option}" exec "${_app_service_option}" su "${_app_user_option}"
    ;;
node | npm)
    if [[ "${_APP_NODE_INSTALLED}" -eq 1 ]]; then
        docker-compose -f "${_app_compose_file_option}" exec "${_app_service_option}" su -c "${_app_command} ${_app_pass_thru}" "${_app_user_option}"
    elif [[ "${_APP_NODE_INSTALLED}" -eq 2 ]]; then
        "${_app_command}" "${_app_pass_thru}"
    fi
    ;;
*)
    docker-compose -f "${_app_compose_file_option}" exec "${_app_service_option}" su -c "${_app_command} ${_app_pass_thru}" "${_app_user_option}"
    ;;
esac
