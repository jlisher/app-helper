#!/usr/bin/env bash

#
# Global variables used by App helper
#

_app_helper_get_name() {
    if [ -z "${_APP_HELPER_NAME}" ]; then
        _APP_HELPER_NAME="App Helper"
    fi

    echo "${_APP_HELPER_NAME}"
    return 0
}

_app_helper_get_version() {
    if [ -z "${_APP_HELPER_VERSION}" ]; then
        _APP_HELPER_VERSION="v0.0.1"
    fi

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

    dir="$(realpath "${0}")"
    dir="$(dirname "${dir}")"

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

    export _APP_HELPER_PATH

    echo "${_APP_HELPER_PATH}"
    return 0
}
