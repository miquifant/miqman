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

# import config from environment
[[ -z ${xyzman_server} ]]       && echo "Unable to update Xyzman. Missing variable xyzman_server"        && exit 1
[[ -z ${xyzman_uri} ]]          && echo "Unable to update Xyzman. Missing variable xyzman_uri"           && exit 1
[[ -z ${xyzman_branch} ]]       && echo "Unable to update Xyzman. Missing variable xyzman_branch"        && exit 1
[[ -z ${xyzman_insecure_ssl} ]] && echo "Unable to update Xyzman. Missing variable xyzman_insecure_ssl"  && exit 1

# variables
xyzman_bin_folder="${XYZMAN_DIR}/bin"
xyzman_etc_folder="${XYZMAN_DIR}/etc"
xyzman_src_folder="${XYZMAN_DIR}/src"
xyzman_tmp_folder="${XYZMAN_DIR}/tmp"
xyzman_stage_folder="${xyzman_tmp_folder}/stage"
xyzman_var_folder="${XYZMAN_DIR}/var"
xyzman_config_file="${xyzman_etc_folder}/config"
xyzman_user_conf_dir="${HOME}/.config/xyzman"
xyzman_repo_url="${xyzman_server}/${xyzman_uri}.git"


# setup

echo ""
echo "Updating XYZMAN..."


# Create directory structure
mkdir -p "${xyzman_bin_folder}"
mkdir -p "${xyzman_etc_folder}"
mkdir -p "${xyzman_src_folder}"
mkdir -p "${xyzman_tmp_folder}"
mkdir -p "${xyzman_var_folder}"
mkdir -p "${xyzman_user_conf_dir}"

# fetch new distribution
rm -fr ${xyzman_stage_folder}
pushd ${xyzman_tmp_folder} >/dev/null
git clone --depth 1 --branch ${xyzman_branch} ${xyzman_repo_url} ${xyzman_stage_folder}
ret=$?
popd >/dev/null
[[ ${ret} != 0 ]] && echo "Unable to download application. Upgrade will halt now!" && exit 2
[[ -d ${xyzman_stage_folder}/.git ]] && rm -fr ${xyzman_stage_folder}/.git


# prime config file
touch "${xyzman_config_file}"
if [[ -z $(egrep 'xyzman_update_enable' ${xyzman_config_file}) ]]; then
  echo "xyzman_update_enable=true" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_server' ${xyzman_config_file}) ]]; then
  echo "xyzman_server=${xyzman_server}" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_uri' ${xyzman_config_file}) ]]; then
  echo "xyzman_uri=${xyzman_uri}" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_branch' ${xyzman_config_file}) ]]; then
  echo "xyzman_branch=${xyzman_branch}" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_insecure_ssl' ${xyzman_config_file}) ]]; then
  echo "xyzman_insecure_ssl=${xyzman_insecure_ssl}" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_curl_connect_timeout' ${xyzman_config_file}) ]]; then
  echo "xyzman_curl_connect_timeout=7" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_curl_max_time' ${xyzman_config_file}) ]]; then
  echo "xyzman_curl_max_time=10" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_debug_mode' ${xyzman_config_file}) ]]; then
  echo "xyzman_debug_mode=false" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_colour_enable' ${xyzman_config_file}) ]]; then
  echo "xyzman_colour_enable=true" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_user_conf_dir' ${xyzman_config_file}) ]]; then
  echo "xyzman_user_conf_dir=${xyzman_user_conf_dir}" >> "${xyzman_config_file}"
fi
if [[ -z $(egrep 'xyzman_modules_dir' ${xyzman_config_file}) ]]; then
  echo "xyzman_modules_dir=${xyzman_src_folder}" >> "${xyzman_config_file}"
fi


# install scripts
mv "${xyzman_stage_folder}/xyzman-init.sh" "${xyzman_bin_folder}/"
mv "${xyzman_stage_folder}/uninstall-xyzman.sh" "${xyzman_bin_folder}/"
mv "${xyzman_stage_folder}"/src/xyzman-* "${xyzman_src_folder}/"

# install modules
for module in $(cd "${xyzman_stage_folder}/src" && ls -d */); do
  rm -fr "${xyzman_src_folder}/${module}/"
  mkdir -p "${xyzman_src_folder}/${module}/"
  for srcfile in $(ls "${xyzman_stage_folder}/src/${module}/" | egrep -v '(README[.](md|rst)|default[.]cfg)'); do
    cp -ar "${xyzman_stage_folder}/src/${module}/${srcfile}" "${xyzman_src_folder}/${module}/"
  done
done

# create user config files
for user_config in $(ls "${xyzman_stage_folder}"/src/*/default.cfg 2>/dev/null); do
  module="$(basename $(dirname ${user_config}))"
  if [[ ! -f "${xyzman_user_conf_dir}/${module}.conf" ]]; then
    # TODO Extract to a function to allow migration of configs
    mv "${xyzman_stage_folder}/src/${module}/default.cfg" "${xyzman_user_conf_dir}/${module}.conf"
  fi
done

# drop version token
XYZMAN_VERSION="$(head -1 ${xyzman_stage_folder}/version)"
echo "Set version to ${XYZMAN_VERSION} ..."
echo "${XYZMAN_VERSION}" > "${xyzman_var_folder}/curvers"
echo "${XYZMAN_VERSION}" > "${xyzman_var_folder}/version"

# clean up staging folder
rm -fr "${xyzman_stage_folder}"


# the end
echo ""
echo ""
echo "Successfully upgraded XYZMAN!"
echo ""
echo "Open a new terminal to start using XYZMAN ${XYZMAN_VERSION}."
echo ""
echo "Enjoy!!!"
echo ""
