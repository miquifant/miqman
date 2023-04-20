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

function ___xyzman_check_version_cache() {
  local version_url
  local version_file="${XYZMAN_DIR}/var/version"

  if [[ -f "${version_file}" && -z "$(find "${version_file}" -mmin +$((60 * 24)))" ]]; then
    __xyzman_echo_debug "Not refreshing version cache now..."
    XYZMAN_REMOTE_VERSION=$(cat "${version_file}")
  else
    __xyzman_echo_debug "Version cache needs updating..."
    __xyzman_echo_debug "Refreshing version cache..."
    version_url="${xyzman_server}/${xyzman_uri}/raw/${xyzman_branch}/version"
    XYZMAN_REMOTE_VERSION=$(__xyzman_curl "${version_url}")
    if [[ -z "${XYZMAN_REMOTE_VERSION}" || -n "$(echo "${XYZMAN_REMOTE_VERSION}" | tr '[:upper:]' '[:lower:]' | grep 'html')" ]]; then
      __xyzman_echo_debug "Version information corrupt or empty! Ignoring: ${XYZMAN_REMOTE_VERSION}"
      XYZMAN_REMOTE_VERSION="${XYZMAN_VERSION}"
    else
      __xyzman_echo_debug "Overwriting version cache with: ${XYZMAN_REMOTE_VERSION}"
      echo "${XYZMAN_REMOTE_VERSION}" | tee "${version_file}" > /dev/null
    fi
  fi
}
