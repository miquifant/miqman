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

function __xyzman_echo_debug() {
  if [[ "${xyzman_debug_mode}" == 'true' ]]; then
    echo "$1"
  fi
}

function __xyzman_curl() {
  if [[ "${xyzman_insecure_ssl}" == 'true' ]]; then
    curl --insecure --silent --location --connect-timeout ${xyzman_curl_connect_timeout} --max-time ${xyzman_curl_max_time} "$1"
  else
    curl --silent --location --connect-timeout ${xyzman_curl_connect_timeout} --max-time ${xyzman_curl_max_time} "$1"
  fi
}

function __xyzman_echo() {
  if [[ "${xyzman_colour_enable}" == 'false' ]]; then
    echo -e "$2"
  else
    echo -e "\033[1;$1$2\033[0m"
  fi
}

function __xyzman_echo_red() {
  __xyzman_echo "31m" "$1"
}

function __xyzman_echo_no_colour() {
  echo "$1"
}

function __xyzman_echo_yellow() {
  __xyzman_echo "33m" "$1"
}

function __xyzman_echo_green() {
  __xyzman_echo "32m" "$1"
}

function __xyzman_echo_cyan() {
  __xyzman_echo "36m" "$1"
}

function __xyzman_echo_confirm() {
  if [[ "${xyzman_colour_enable}" == 'false' ]]; then
    echo -n "$1"
  else
    echo -e -n "\033[1;33m$1\033[0m"
  fi
}
