#!/usr/bin/env bash

function __xyz_config_usage() {
  echo ""
  echo "Usage: xyz config [<options>]"
  echo ""
  echo "Action"
  echo "    -g, --get             get value: module.name"
  echo "    -s, --set             set a variable: module.name value"
  echo "    -u, --unset           remove a variable: module.name"
  echo "    -c, --clear           clear a variable (leave it empty): module.name"
  echo "    -l, --list            list all: [module]"
  echo "    -e, --edit            open an editor: [module]"
  echo "    -f, --show-files      show user config files"
  echo "    -S, --setup           interactively completes configuration: [module]"
  echo "    -X, --export          export user config file: module path"
  echo "    -L, --load            load user config from file: file module"
  echo "    --help                shows the help docs of this command"
  echo "    -h                    shows this message and exists"
  echo ""
}

function __xyz_config() {

  local ACTION="$1"
  local CONF_KEY=
  local CONF_VAL=

  case "${ACTION}" in
    '-g' ) ACTION="--get" ;;
    '-s' ) ACTION="--set" ;;
    '-u' ) ACTION="--unset" ;;
    '-c' ) ACTION="--clear" ;;
    '-l' ) ACTION="--list" ;;
    '-e' ) ACTION="--edit" ;;
    '-f' ) ACTION="--show-files" ;;
    '-S' ) ACTION="--setup" ;;
    '-X' ) ACTION="--export" ;;
    '-L' ) ACTION="--load" ;;
    '-h' ) ACTION="" ;;
  esac

  if [[ -z "${ACTION}" ]]; then
    __xyz_config_usage
    return 129
  fi

  if [[ "${ACTION}" == "--help" ]]; then
    __xyz_config_help | less
    return 0
  fi

  if [[ ${ACTION} != -* ]]; then
    CONF_KEY=$1
    if [[ -z "$2" ]]; then
      ACTION="--get"
    else
      ACTION="--set"
      CONF_VAL=$2
    fi
  else
    CONF_KEY=$2
    if [[ "${ACTION}" == "--set" || "${ACTION}" == "--export" || "${ACTION}" == "--load" ]]; then
      CONF_VAL=$3
    fi
  fi

  case "${ACTION}" in
    '--get' )
      __xyz_config_get "${CONF_KEY}"
      return $?
      ;;
    '--set' )
      __xyz_config_set "${CONF_KEY}" "${CONF_VAL}"
      return $?
      ;;
    '--unset' )
      __xyz_config_unset "${CONF_KEY}"
      return $?
      ;;
    '--clear' )
      __xyz_config_clear "${CONF_KEY}"
      return $?
      ;;
    '--list' )
      __xyz_config_list "${CONF_KEY}"
      return $?
      ;;
    '--edit' )
      __xyz_config_edit "${CONF_KEY}"
      return $?
      ;;
    '--show-files' )
      __xyz_config_show_files
      return $?
      ;;
    '--setup' )
      __xyz_config_setup "${CONF_KEY}"
      return $?
      ;;
    '--export' )
      __xyz_config_export "${CONF_KEY}" "${CONF_VAL}"
      return $?
      ;;
    '--load' )
      __xyz_config_load "${CONF_KEY}" "${CONF_VAL}"
      return $?
      ;;
    * )
      echo ""
      __xyzman_echo_red "Error: Unknown switch \`$(echo ${ACTION} | sed -e 's/^-*//g')'"
      echo ""
      __xyz_config_usage
      return 1
      ;;
  esac
}

function __xyz_config_help() {
  echo "XYZ-CONFIG"
  echo "       xyz config - Get and set xyzman options"
  echo ""
  echo "SYNOPSIS"
  echo "       xyz config [-g | --get] module.name"
  echo "       xyz config [-s | --set] module.name value"
  echo "       xyz config -u | --unset module.name"
  echo "       xyz config -c | --clear module.name"
  echo "       xyz config -l | --list [module]"
  echo "       xyz config -e | --edit [module]"
  echo "       xyz config -f | --show-files"
  echo "       xyz config -S | --setup [module]"
  echo "       xyz config -X | --export module path"
  echo "       xyz config -L | --load file module"
  echo "       xyz config -h"
  echo "       xyz config --help"
  echo ""
  echo "DESCRIPTION"
  echo "       You can query/set/unset/clear options with this command."
  echo ""
  echo "       This command will fail with non-zero status upon error. Some exit codes are:"
  echo ""
  echo "       ·   Wrong call - Unknown action (ret=1),"
  echo ""
  echo "       ·   no default editor configured (ret=2),"
  echo ""
  echo "       ·   no user config file found (ret=3),"
  echo ""
  echo "       ·   the module or key is invalid (ret=4),"
  echo ""
  echo "       ·   no module or name was provided (ret=5),"
  echo ""
  echo "       ·   the user config file cannot be written (ret=6),"
  echo ""
  echo "       ·   you try to unset or clear an option which does not exist (ret=7),"
  echo ""
  echo "       ·   the specified file does not exist or is invalid (ret=8),"
  echo ""
  echo "       ·   unknown error (ret=100), or"
  echo ""
  echo "       ·   no action provided or wrong number of arguments. See usage (ret=129)."
  echo ""
  echo "       On success, the command returns the exit code 0."
  echo ""
  echo "OPTIONS"
  echo "       -g, --get"
  echo "           Get the value for a given key. Returns error code 4 if the key was not found."
  echo ""
  echo "       -s, --set"
  echo "           Set a user config property."
  echo ""
  echo "       -u, --unset"
  echo "           Remove a user config property."
  echo ""
  echo "       -c, --clear"
  echo "           Clear a user config property (leave it empty)."
  echo ""
  echo "       -l, --list"
  echo "           List all variables set in user config files (or a single one), along with their values."
  echo ""
  echo "       -e, --edit"
  echo "           Open an editor to modify the config file."
  echo ""
  echo "       -f, --show-files"
  echo "           Show user config files locations."
  echo ""
  echo "       -S, --setup"
  echo "           Interactively setup user configuration for all modules or a single one."
  echo ""
  echo "       -X, --export"
  echo "           Export a module's user config to the specified location."
  echo ""
  echo "       -L, --load"
  echo "           Load a module's user config from a file."
  echo ""
  echo "       -h"
  echo "           Show usage message and exit."
  echo ""
  echo "       --help"
  echo "           Show this manual and exist."
}

function __xyz_config_get() {
  local -r CONF_KEY=$1
  if [[ -z "${CONF_KEY}" ]]; then
    __xyzman_echo_red "error: wrong number of arguments"
    __xyz_config_usage
    return 129
  fi
  if [[ ! ${CONF_KEY} =~ ^[^.]+[.][^.]+$ ]]; then
    __xyzman_echo_red "error: key does not contain a module name: ${CONF_KEY}"
    return 5
  fi
  local -r mod="${CONF_KEY%.*}"
  local -r key="${CONF_KEY##*.}"
  local line
  if [[ -d "${xyzman_user_conf_dir}" ]] && [[ -f "${xyzman_user_conf_dir}/${mod}.conf" ]]; then
    line=$(egrep "^${key}=" "${xyzman_user_conf_dir}/${mod}.conf")
    if [[ $? == 0 ]]; then
      echo $line | sed -e 's/^[^=]*=//g'
      return 0
    else
      __xyzman_echo_red "error: key not found in module: ${mod}.${key}"
    fi
  else
    __xyzman_echo_red "error: unknown module: ${mod}"
  fi
  return 4
}

function __xyz_config_set() {
  local -r CONF_KEY=$1
  local -r CONF_VAL=$2
  if [[ -z "${CONF_KEY}" || -z "${CONF_VAL}" ]]; then
    __xyzman_echo_red "error: wrong number of arguments"
    __xyz_config_usage
    return 129
  fi
  if [[ ! ${CONF_KEY} =~ ^[^.]+[.][^.]+$ ]]; then
    __xyzman_echo_red "error: key does not contain a module name: ${CONF_KEY}"
    return 5
  fi

  local -r mod="${CONF_KEY%.*}"
  local -r key="${CONF_KEY##*.}"

  mkdir -p "${xyzman_user_conf_dir}"
  touch "${xyzman_user_conf_dir}/${mod}.conf"

  local old_value
  old_value=$(__xyz_config_get "${CONF_KEY}")
  if [[ $? == 0 ]]; then
    sed -i -r -e "s/^${key}=.*$/${key}=${CONF_VAL//\//\\/}/" "${xyzman_user_conf_dir}/${mod}.conf" && return 0
  else
    echo "${key}=${CONF_VAL}" >> "${xyzman_user_conf_dir}/${mod}.conf" && return 0
  fi
  return 6
}

function __xyz_config_unset() {
  local -r CONF_KEY=$1
  if [[ -z "${CONF_KEY}" ]]; then
    __xyzman_echo_red "error: wrong number of arguments"
    __xyz_config_usage
    return 129
  fi
  if [[ ! ${CONF_KEY} =~ ^[^.]+[.][^.]+$ ]]; then
    __xyzman_echo_red "error: key does not contain a module name: ${CONF_KEY}"
    return 5
  fi
  local -r mod="${CONF_KEY%.*}"
  local -r key="${CONF_KEY##*.}"
  local line
  if [[ -d "${xyzman_user_conf_dir}" ]] && [[ -f "${xyzman_user_conf_dir}/${mod}.conf" ]]; then
    line=$(egrep "^${key}=" "${xyzman_user_conf_dir}/${mod}.conf")
    if [[ $? == 0 ]]; then
      sed -i -r -e "s/^${key}=.*$//" "${xyzman_user_conf_dir}/${mod}.conf" && return 0
      return 6
    fi
  fi
  return 7
}

function __xyz_config_clear() {
  local -r CONF_KEY=$1
  if [[ -z "${CONF_KEY}" ]]; then
    __xyzman_echo_red "error: wrong number of arguments"
    __xyz_config_usage
    return 129
  fi
  if [[ ! ${CONF_KEY} =~ ^[^.]+[.][^.]+$ ]]; then
    __xyzman_echo_red "error: key does not contain a module name: ${CONF_KEY}"
    return 5
  fi
  local -r mod="${CONF_KEY%.*}"
  local -r key="${CONF_KEY##*.}"
  local line
  if [[ -d "${xyzman_user_conf_dir}" ]] && [[ -f "${xyzman_user_conf_dir}/${mod}.conf" ]]; then
    line=$(egrep "^${key}=" "${xyzman_user_conf_dir}/${mod}.conf")
    if [[ $? == 0 ]]; then
      sed -i -r -e "s/^${key}=.*$/${key}=/" "${xyzman_user_conf_dir}/${mod}.conf" && return 0
      return 6
    fi
  fi
  return 7
}

function __xyz_config_show_files() {
  if [[ -d "${xyzman_user_conf_dir}" ]] && [[ "$(ls -A ${xyzman_user_conf_dir}/*.conf 2>/dev/null)" ]]; then
    ls "${xyzman_user_conf_dir}"/*.conf | sed -e 's/^/- /g'
    return 0
  else
    echo ""
    __xyzman_echo_red "Unable to find user config files. Please reinstall XYZMAN."
    return 3
  fi
}

function __xyz_config_edit() {
  if [[ -d "${xyzman_user_conf_dir}" ]] && [[ "$(ls -A ${xyzman_user_conf_dir}/*.conf 2>/dev/null)" ]]; then

    local -r editor=(${EDITOR:=vi})
    if ! command -v "${editor[@]}" > /dev/null; then
      __xyzman_echo_red "No default editor configured."
      __xyzman_echo_yellow "Please set the default editor with the EDITOR environment variable."
      return 2
    fi

    if [[ ! -z "$1" ]]; then
      if [[ -d "${xyzman_user_conf_dir}" ]] && [[ -f "${xyzman_user_conf_dir}/$1.conf" ]]; then
        file="${xyzman_user_conf_dir}/$1.conf"
      else
        __xyzman_echo_red "error: unknown module: $1"
        return 4
      fi
    else
      local conf_files=()
      local select_opts=()
      for conf_file in "${xyzman_user_conf_dir}"/*.conf; do
        local file_name=$(basename ${conf_file} .conf)
        conf_files+=(${conf_file})
        select_opts+=("${file_name}")
      done

      if [[ 1 -lt ${#select_opts[@]} ]]; then
        echo ""
        __xyzman_echo_yellow "There are multiple user config files. You must chose which one do you want to edit."
        echo ""
        local -r OLD_PS3="$PS3"
        local -r message="Config to edit ('q' to quit)? "
        PS3="${message}"
        select file in "${select_opts[@]}"; do
          if [[ "${REPLY}" == "q" || "${REPLY}" == "Q" ]]; then
            echo ""
            unset file conf_file
            return 0
          elif [[ "1" -le "${REPLY}" ]] && [[ "${REPLY}" -le ${#select_opts[@]} ]]; then
            break
          else
            echo ""
            __xyzman_echo_red "Wrong selection: Select any number from 1-${#select_opts[@]}"
            echo ""
            # show options again
            PS3=""
            echo "dummy" | select dummy in "${select_opts[@]}"; do break; done
            PS3="${message}"
          fi
        done
        PS3="${OLD_PS3}"
        file="${conf_files[$((${REPLY} - 1))]}"
      else
        file="${conf_file}"
      fi
    fi
    # Edit user config file in default editor
    "${editor[@]}" "${file}"
    echo ""
    unset file conf_file
    return 0

  else
    echo ""
    __xyzman_echo_red "Unable to find user config files. Please reinstall XYZMAN."
    return 3
  fi
}

function __xyz_config_list() {
  if [[ -d "${xyzman_user_conf_dir}" ]] && [[ "$(ls -A ${xyzman_user_conf_dir}/*.conf 2>/dev/null)" ]]; then
    if [[ -z "$1" ]]; then
      local user_conf_files=$(ls "${xyzman_user_conf_dir}"/*.conf)
    else
      local user_conf_files="${xyzman_user_conf_dir}/$1.conf"
      if [[ ! -f "${user_conf_files}" ]]; then
        __xyzman_echo_red "error: unknown module: $1"
        return 4
      fi
    fi
    for user_config in ${user_conf_files}; do
      local config_file="$(basename ${user_config})"
      local module="${config_file%.*}"
      # FIX for some reason, gawk is not found until I interactively source xyzman-init script
      awk "/^[ ]*[^#][^=]*=.+$/{print \"${module}.\"\$0}" "${user_config}"
    done
    unset user_config
    return 0
  else
    echo ""
    __xyzman_echo_red "Unable to find user config files. Please reinstall XYZMAN."
    return 3
  fi
}

function __xyz_config_setup() {
  # Set ^H as erase character, instead of ^? to avoid this behavior in mobaXterm:
  # If you write 123, then press del 3 times and write abc, the result IS NOT 'abc' but '123^H^H^Habc'
  old_stty_erase_char=$(stty|sed -e 's/^/; /g'|egrep '; erase = [^;]*;'|sed -re 's/^.*; erase = ([^;]*);.*$/\1/g')
  stty erase \^H
  if [[ -d "${xyzman_user_conf_dir}" ]] && [[ "$(ls -A ${xyzman_user_conf_dir}/*.conf 2>/dev/null)" ]]; then

    local existing_modules=()
    for conf_file in "${xyzman_user_conf_dir}"/*.conf; do existing_modules+=("$(basename ${conf_file} .conf)"); done
    unset conf_file

    local modules
    if [[ -z "$1" ]]; then
      modules=${existing_modules[@]}
    else
      modules=("$1")
    fi

    local -r mods=(${modules[@]})
    if [[ 1 -lt ${#mods[@]} ]]; then
      echo ""
      __xyzman_echo_yellow "Multiple modules will be configured now (${#mods[@]})."
    fi

    for mod in ${modules[@]}; do
      echo ""
      __xyzman_echo_cyan "Module setup wizard for \`${mod}' module."
      
      if [[ -d "${xyzman_user_conf_dir}" ]] && [[ -f "${xyzman_user_conf_dir}/${mod}.conf" ]]; then
        echo ""
        local lines=$(egrep --color=never '^[ ]*[^#=]+=[ ]*$' "${xyzman_user_conf_dir}/${mod}.conf")
        for line in ${lines}; do
          local varname=$(echo "${line}" | sed -r -e "s/^[ ]*([^#=]+)=[ ]*$/\1/g")
          local goahead=0
          local linesread=0
          until [[ ${linesread} -lt ${goahead} ]]; do
            ((goahead++))
            description=$(
              egrep -A ${goahead} "^### ${varname}[:]" "${xyzman_user_conf_dir}/${mod}.conf" \
              | egrep '^### '
            )
            linesread=$(echo -e "${description}" | wc -l)
          done
          example=$(
            egrep "^# ${varname}=" "${xyzman_user_conf_dir}/${mod}.conf" \
            | sed -r -e "s/# ${varname}=/\> /g"
          )
          echo "+==================================================================================================="
          echo -n "| "
          __xyzman_echo_green "${varname}"
          echo "+---------------------------------------------------------------------------------------------------"
          if [[ ! -z "${description}" ]]; then
            echo "${description}" | sed -r -e "s/^### ${varname}[:] /| /g" | sed -r -e 's/### /| /g'
          fi
          if [[ ! -z "${example}" ]]; then
            echo "|"
            echo "| Example:"
            echo "|"
            echo "| ${example}"
          fi
          echo "|"
          echo -n "| "
          __xyzman_echo_confirm "your value ? "
          read value
          echo "|"
          if [[ ! -z "${value}" ]]; then
            __xyz_config_set "${mod}.${varname}" "${value}"
          fi
          unset varname goahead linesread description example value
        done
        if [[ ! -z "${lines}" ]]; then
          echo "+==================================================================================================="
        fi
        unset line
      else
        echo ""
        __xyzman_echo_red "Unknown module"
      fi
    done
    stty erase ${old_stty_erase_char}
    unset mod old_stty_erase_char
    echo ""
    return 0

  else
    stty erase ${old_stty_erase_char}
    unset old_stty_erase_char
    echo ""
    __xyzman_echo_red "Unable to find user config files. Please reinstall XYZMAN."
    return 3
  fi  
}

function __xyz_config_export() {
  local -r MODULE="$1"
  local -r TARGET_PATH="$2"
  if [[ -z "${MODULE}" || -z "${TARGET_PATH}" ]]; then
    __xyzman_echo_red "error: wrong number of arguments. Needed MODULE and TARGET_PATH."
    __xyz_config_usage
    return 129
  fi

  if [[ -d "${xyzman_user_conf_dir}" ]] && [[ "$(ls -A ${xyzman_user_conf_dir}/*.conf)" ]]; then
    local -r user_conf_file="${xyzman_user_conf_dir}/$1.conf"
    if [[ ! -f "${user_conf_file}" ]]; then
      __xyzman_echo_red "error: unknown module: $1"
      return 4
    fi
    [[ -d "${TARGET_PATH}" ]] && local target_file="${TARGET_PATH}/${MODULE}.conf" || local target_file="${TARGET_PATH}"

    if [[ -f "${target_file}" ]]; then
      __xyzman_echo_confirm "File exists. Would you like to overwrite it? [y/N] "
      read overwrite
      if [[ "${overwrite}" != "Y" && "${overwrite}" != "y" ]]; then
        __xyzman_echo_no_colour "Config export cancelled."
        return 0
      fi
      unset overwrite
    fi

    cp "${user_conf_file}" "${target_file}"
    ret_status=$?
    if [[ "${ret_status}" == "0" ]]; then
      __xyzman_echo_no_colour "Configuration exported successfully"
      return 0
    else
      __xyzman_echo_red "error: Unable to export configuration due an unknown error"
      return 100
    fi
  else
    echo ""
    __xyzman_echo_red "Unable to find user config files. Please reinstall XYZMAN."
    return 3
  fi
}

function __xyz_config_load() {
  local -r FILE=$1
  local -r MODULE=$2
  if [[ -z "${FILE}" || -z "${MODULE}" ]]; then
    __xyzman_echo_red "error: wrong number of arguments. Needed FILE and MODULE."
    __xyz_config_usage
    return 129
  fi

  if [[ -f "${FILE}" ]]; then
    local -r user_conf_file="${xyzman_user_conf_dir}/${MODULE}.conf"
    if [[ -f "${user_conf_file}" ]]; then
      __xyzman_echo_no_colour "# ${MODULE} Config found"
      __xyzman_echo_cyan "Original contents retained as ${user_conf_file}.bak"
      cp "${user_conf_file}" "${user_conf_file}.bak"
    else
      __xyzman_echo_yellow "warning: ${MODULE} config didn't exist and will be created. Maybe you misspelled it?"
    fi
    cp "${FILE}" ${user_conf_file}
    __xyzman_echo_no_colour "${user_conf_file} updated."
  else
    __xyzman_echo_red "Unable to load config from file. Not found '${FILE}'"
    return 8
  fi
}
