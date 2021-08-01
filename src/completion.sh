#!/bin/bash

_app_helper_clear_tmp() {
    for file in "$(_app_helper_get_tmp_dir)"/*.list; do
        if [ -w "${file}" ]; then
            rm "${file}"
        fi
    done
}

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
    local file

    file="$(_app_helper_get_tmp_dir)/composer_commands.list"

    if [[ ! -f "${file}" ]] && [[ -w "$(dirname "${file}")" ]]; then
        $(_app_helper_get_path) composer -- --raw --no-ansi list | sed "s/[[:space:]].*//g" >"${file}"
    fi

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_artisan_completions() {
    local file

    file="$(_app_helper_get_tmp_dir)/artisan_commands.list"

    if [[ ! -f "${file}" ]] && [[ -w "$(dirname "${file}")" ]]; then
        $(_app_helper_get_path) artisan -- --raw --no-ansi list | sed "s/[[:space:]].*//g" >"${file}"
    fi

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_npm_commands_completions() {
    local file

    file="$(_app_helper_get_dir)/conf/npm_commands.list"

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

_app_helper_node_options_completions() {
    local file

    file="$(_app_helper_get_dir)/conf/node_options.list"

    cat <"${file}" | tr "[:space:]" " "

    return 0
}

# app completion
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

# clear the temp storage everytime this file is sourced.
_app_helper_clear_tmp

complete -F _app_helper_completion "$(_app_helper_get_alias)"
