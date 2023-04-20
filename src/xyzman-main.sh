#!/usr/bin/env bash

#
#   Based on SDKMAN - Copyright 2021 Marco Vermeulen
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

function xyz() {
  
  COMMAND="$1"
  
  case "${COMMAND}" in
    c)
      COMMAND="config" ;;
    1)
      COMMAND="fun1" ;;
    v)
      COMMAND="version" ;;
  esac

  # Refresh xyzman config if it exists (take changes in the same console)
  if [ -f "${XYZMAN_DIR}/etc/config" ]; then
    source "${XYZMAN_DIR}/etc/config"
  fi

  # Check version cache
  ___xyzman_check_version_cache

  # no command provided
  if [[ -z "${COMMAND}" ]]; then
    __xyz_help
    return 1
  fi

  # Check if it is a valid command
  CMD_FOUND=""
  CMD_TARGET="${XYZMAN_DIR}/src/xyzman-${COMMAND}.sh"
  if [[ -f "${CMD_TARGET}" ]]; then
    CMD_FOUND="${CMD_TARGET}"
  fi

  # couldn't find the command
  if [[ -z "${CMD_FOUND}" ]]; then
    echo ""
    __xyzman_echo_red "Invalid command: ${COMMAND}"
    echo ""
    __xyz_help
  fi

  # Check whether the command exists as an internal function...
  #
  # NOTE Internal commands use underscores rather than hyphens,
  # hence the name conversion as the first step here.
  CONVERTED_CMD_NAME=$(echo "${COMMAND}" | tr '-' '_')

  # Store the return code of the requested command
  local final_rc=0

  # Execute the requested command
  if [ -n "${CMD_FOUND}" ]; then
    # It's available as a shell function
    __xyz_"${CONVERTED_CMD_NAME}" "$2" "$3" "$4"
    final_rc=$?
  fi

  # Attempt upgrade after all is done
  if [[ "${COMMAND}" != "update" && "${xyzman_update_enable}" == true ]]; then
    __xyzman_auto_update "${XYZMAN_REMOTE_VERSION}" "${XYZMAN_VERSION}"
  fi
  return ${final_rc}
}
