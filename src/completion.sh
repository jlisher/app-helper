#!/bin/bash

# used to add completions for artisan command options/flags
__app_artisan_options_completions() {
  local command

  command="${1}"

#  add some more functionality
}

_app_completion_set_env() {
  if [ -z "${_APP_COMPLETION_COMMANDS}" ]; then
    _APP_COMPLETION_COMMANDS="$(cat <"${_APP_HELPER_DIR}/conf/completion_commands.list" | tr "[:space:]" " ")"

    export _APP_COMPLETION_COMMANDS
  fi

  if [ -z "${_APP_COMPLETION_OPTIONS}" ]; then
    _APP_COMPLETION_OPTIONS="$(cat <"${_APP_HELPER_DIR}/conf/completion_options.list" | tr "[:space:]" " ")"

    export _APP_COMPLETION_OPTIONS
  fi

  if [ -z "${_APP_COMPLETION_NPM_COMMANDS}" ]; then
    _APP_COMPLETION_NPM_COMMANDS="$(cat <"${_APP_HELPER_DIR}/conf/npm_completion_commands.list" | tr "[:space:]" " ")"

    export _APP_COMPLETION_NPM_COMMANDS
  fi

  if [ -z "${_APP_COMPLETION_NODE_OPTIONS}" ]; then
    _APP_COMPLETION_NODE_OPTIONS="$(cat <"${_APP_HELPER_DIR}/conf/node_completion_options.list" | tr "[:space:]" " ")"

    export _APP_COMPLETION_NODE_OPTIONS
  fi

  if [ -z "${_APP_COMPLETION_COMPOSER_COMMANDS}" ]; then
    case "${_APP_COMPOSER_INSTALLED}" in
    1)
      _APP_COMPLETION_COMPOSER_COMMANDS="$(app composer -- --raw --no-ansi list | sed "s/[[:space:]].*//g" | tr "[:space:]" " ")"
      ;;
    2)
      _APP_COMPLETION_COMPOSER_COMMANDS="$(composer -- --raw --no-ansi list | sed "s/[[:space:]].*//g" | tr "[:space:]" " ")"
      ;;
    esac

    export _APP_COMPLETION_COMPOSER_COMMANDS
  fi

  if [ -z "${_APP_COMPLETION_ARTISAN_COMMANDS}" ]; then
    case "${_APP_ARTISAN_INSTALLED}" in
    1)
      _APP_COMPLETION_ARTISAN_COMMANDS="$(app artisan -- --raw --no-ansi list | sed "s/[[:space:]].*//g" | tr "[:space:]" " ")"
      ;;
    2)
      _APP_COMPLETION_ARTISAN_COMMANDS="$(php artisan -- --raw --no-ansi list | sed "s/[[:space:]].*//g" | tr "[:space:]" " ")"
      ;;
    esac

    export _APP_COMPLETION_ARTISAN_COMMANDS
  fi
}

# app completion
_app_completion() {
  local word_list cur_command

  _app_completion_set_env

  if [ "${COMP_CWORD}" == "1" ]; then
    word_list="${_APP_COMPLETION_COMMANDS}"
  else
    cur_command="${COMP_WORDS[1]}"

    case "${cur_command}" in
    # artisan completion
    artisan)
      COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
      word_list="${_APP_COMPLETION_ARTISAN_COMMANDS}"
      ;;
    # composer completion
    composer)
      word_list="${_APP_COMPLETION_COMPOSER_COMMANDS}"
      ;;
    # npm completion. Stolen from the `npm completion` command
    npm)
      word_list="${_APP_COMPLETION_NPM_COMMANDS}"
      ;;
    node)
      word_list="${_APP_COMPLETION_NODE_OPTIONS}"
      ;;
    esac
  fi

  if [ -n "${word_list}" ]; then
    word_list="${word_list} ${_APP_COMPLETION_OPTIONS}"
    COMPREPLY=($(compgen -W "${word_list}" -- "${COMP_WORDS[COMP_CWORD]}"))
  else
    COMPREPLY=($(compgen -o default -- "${COMP_WORDS[COMP_CWORD]}"))
  fi

  if [ "${_APP_HELPER_DEBUG}" == "1" ]; then
    touch "${_APP_HELPER_DIR}/.debug_completion"
    cat >>"${_APP_HELPER_DIR}/.debug_completion" <<EOF
--------------------------------------------------------------------------------
Completion Dump
Timestamp: $(date)
--------------------------------------------------------------------------------
COMP_LINE: "${COMP_LINE}"
COMP_WORDS: "${COMP_WORDS[@]}"
COMP_WORDS_INDEX: "${!COMP_WORDS[@]}"
COMP_CWORD: "${COMP_CWORD}"
CURR_WORD: "${COMP_WORDS[COMP_CWORD]}"
COMP_WORDBREAKS: "${COMP_WORDBREAKS}"
cur_command: "${cur_command}"
word_list: "${word_list}"
COMPREPLY: "${COMPREPLY[@]}"

EOF
  fi

  return 0
}

complete -F _app_completion "${_APP_HELPER_FILENAME:-app}"
