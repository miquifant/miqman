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

function __xyz_update() {
  local force_update
  force_update="$1"
  if [[ "${XYZMAN_REMOTE_VERSION}" == "${XYZMAN_VERSION}" && "${force_update}" != "force" ]]; then
    echo "No update available at this time."
  else
    export xyzman_server
    export xyzman_uri
    export xyzman_branch
    export xyzman_insecure_ssl
    __xyzman_curl "${xyzman_server}/${xyzman_uri}/raw/${xyzman_branch}/update-xyzman.sh" | bash
  fi
}

function __xyzman_auto_update() {
  local remote_version version delay_upgrade

  remote_version="$1"
  version="$2"
  delay_upgrade="${XYZMAN_DIR}/var/delay_upgrade"

  if [[ -n "$(find "${delay_upgrade}" -mtime +1)" && "${remote_version}" != "${version}" ]]; then
    echo ""
    echo ""
    __xyzman_echo_yellow "ATTENTION: A new version of XYZMAN is available..."
    echo ""
    __xyzman_echo_no_colour "The current version is ${remote_version}, but you have ${version}."
    echo ""

    __xyzman_echo_confirm "Would you like to upgrade now? [Y/n] "
    read upgrade

    if [[ -z "${upgrade}" ]]; then
      upgrade="Y"
    fi

    if [[ "${upgrade}" == "Y" || "${upgrade}" == "y" ]]; then
      __xyz_update
      unset upgrade
    else
      __xyzman_echo_no_colour "Not upgrading today..."
    fi

    touch "${delay_upgrade}"
  fi
}
