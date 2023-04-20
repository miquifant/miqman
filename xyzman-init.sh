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

# set env vars if not set
if [[ -z "${XYZMAN_DIR}" ]]; then
  export XYZMAN_DIR="${HOME}/.xyzman"
fi

if [ -z "${XYZMAN_VERSION}" ]; then
  export XYZMAN_VERSION="$(head -1 ${XYZMAN_DIR}/var/curvers)"
fi

# Load the xyzman config if it exists.
if [ -f "${XYZMAN_DIR}/etc/config" ]; then
  source "${XYZMAN_DIR}/etc/config"
fi

# Source xyzman module scripts.
OLD_IFS="${IFS}"
IFS=$'\n'
scripts=($(find "${XYZMAN_DIR}/src" -type f -name 'xyzman-*.sh'))
for f in "${scripts[@]}"; do
  source "${f}"
done
IFS="${OLD_IFS}"
unset OLD_IFS scripts f

# Create upgrade delay file if it doesn't exist
if [[ ! -f "${XYZMAN_DIR}/var/delay_upgrade" ]]; then
  touch "${XYZMAN_DIR}/var/delay_upgrade"
fi
