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

# config
XYZMAN_SERVER="https://github.com"
XYZMAN_URI="miquifant/xyzman"
XYZMAN_BRANCH="main"
XYZMAN_SERVER_INSECURE=false
XYZMAN_DIR=~/.xyzman
XYZMAN_TAG="# XYZMAN: Please, don't edit this line"

prompt_yn() {
  QUESTION=$1
  [[ "$2" == "n" || "$2" == "N" ]] && DEFAULT=N || DEFAULT=Y
  VALUES=$([[ ${DEFAULT} == Y ]] && echo "Y/n" || echo "y/N")
  while true; do
    read -p "$1 [${VALUES}] " yn
    case ${yn:-${DEFAULT}} in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no (default '${DEFAULT}').";;
    esac
  done
}

# variables
xyzman_bin_folder="${XYZMAN_DIR}/bin"
xyzman_etc_folder="${XYZMAN_DIR}/etc"
xyzman_src_folder="${XYZMAN_DIR}/src"
xyzman_tmp_folder="${XYZMAN_DIR}/tmp"
xyzman_stage_folder="${xyzman_tmp_folder}/stage"
xyzman_var_folder="${XYZMAN_DIR}/var"
xyzman_config_file="${xyzman_etc_folder}/config"
xyzman_user_conf_dir="${HOME}/.config/xyzman"
xyzman_repo_url="${XYZMAN_SERVER}/${XYZMAN_URI}.git"
xyzman_bashrc_lines='^[ \t]*[^ \t#].*'${XYZMAN_TAG}'$'
xyzman_bashrc="${HOME}/.bashrc"
xyzman_zshrc="${ZDOTDIR:-${HOME}}/.zshrc"

xyzman_init_snippet=$( cat << EOF
export XYZMAN_DIR="${XYZMAN_DIR}"                                                   ${XYZMAN_TAG}
[[ -s "\${XYZMAN_DIR}/bin/xyzman-init.sh" ]] && source "\${XYZMAN_DIR}/bin/xyzman-init.sh" || : ${XYZMAN_TAG}
EOF
)

clear
echo ""
# TODO Replace by logo / banner:
echo "XYZ Manager"
echo ""
echo ""
echo " Now attempting installation..."
echo ""
echo ""

# Sanity checks

echo "Looking for git..."
if ! command -v git > /dev/null; then
  echo "Not found."
  echo "========================================================================================="
  echo " Please install git on your system using your favourite package manager."
  echo ""
  echo " Restart after installing git."
  echo "========================================================================================="
  echo ""
  exit 1
fi

echo "Checking if code can be downloaded..."
# disable ssl verification before trying to clone repo from self-signed servers
if [[ "${XYZMAN_SERVER_INSECURE}" == "true" ]] && [[ -z "$(git config --get http.sslVerify)" ]]; then
  echo "Unable."
  echo "========================================================================================="
  echo "Server '${XYZMAN_SERVER}' is self-signed."
  echo "To continue installation you must configure Git to disable SSL verification"
  echo ""
  if prompt_yn "Do you want to disable Git's SSL verification?" N; then
    git config --global http.sslVerify false
    echo "========================================================================================="
    echo ""
  else
    echo "Canceling installation. Bye!"
    echo "========================================================================================="
    echo ""
    exit 1
  fi
fi


echo "Installing XYZMAN scripts..."


# Create directory structure
echo "Create distribution directories..."
mkdir -p "${xyzman_bin_folder}"
mkdir -p "${xyzman_etc_folder}"
mkdir -p "${xyzman_src_folder}"
mkdir -p "${xyzman_tmp_folder}"
mkdir -p "${xyzman_var_folder}"
echo "Create configuration directory..."
mkdir -p "${xyzman_user_conf_dir}"


echo "Prime the config file..."
rm -fr "${xyzman_config_file}"
echo "xyzman_update_enable=true"                     >> "${xyzman_config_file}"
echo "xyzman_server=${XYZMAN_SERVER}"                >> "${xyzman_config_file}"
echo "xyzman_uri=${XYZMAN_URI}"                      >> "${xyzman_config_file}"
echo "xyzman_branch=${XYZMAN_BRANCH}"                >> "${xyzman_config_file}"
echo "xyzman_insecure_ssl=${XYZMAN_SERVER_INSECURE}" >> "${xyzman_config_file}"
echo "xyzman_curl_connect_timeout=7"                 >> "${xyzman_config_file}"
echo "xyzman_curl_max_time=10"                       >> "${xyzman_config_file}"
echo "xyzman_debug_mode=false"                       >> "${xyzman_config_file}"
echo "xyzman_colour_enable=true"                     >> "${xyzman_config_file}"
echo "xyzman_user_conf_dir=${xyzman_user_conf_dir}"  >> "${xyzman_config_file}"
echo "xyzman_modules_dir=${xyzman_src_folder}"       >> "${xyzman_config_file}"


echo "Download scripts..."
rm -fr ${xyzman_stage_folder}
pushd ${xyzman_tmp_folder} >/dev/null
git clone --depth 1 --branch ${XYZMAN_BRANCH} ${xyzman_repo_url} ${xyzman_stage_folder}
ret=$?
popd >/dev/null
[[ ${ret} != 0 ]] && echo "FATAL - An error occurred while downloading application. Installation will halt now!" && exit 2
[[ -d ${xyzman_stage_folder}/.git ]] && rm -fr ${xyzman_stage_folder}/.git


echo "Install scripts..."
mv "${xyzman_stage_folder}/xyzman-init.sh" "${xyzman_bin_folder}/"
mv "${xyzman_stage_folder}/uninstall-xyzman.sh" "${xyzman_bin_folder}/"
mv "${xyzman_stage_folder}"/src/xyzman-* "${xyzman_src_folder}/"


echo "Install modules..."
for module in $(cd "${xyzman_stage_folder}/src" && ls -d */); do
  echo "  ♠ $module"
  rm -fr "${xyzman_src_folder}/${module}/"
  mkdir -p "${xyzman_src_folder}/${module}/"
  for srcfile in $(ls "${xyzman_stage_folder}/src/${module}/" | egrep -v '(README[.](md|rst)|default[.]cfg)'); do
    cp -ar "${xyzman_stage_folder}/src/${module}/${srcfile}" "${xyzman_src_folder}/${module}/"
  done
done


echo "Create user config files..."
for user_config in $(ls "${xyzman_stage_folder}"/src/*/default.cfg 2>/dev/null); do
  module="$(basename $(dirname ${user_config}))"
  echo -n "  ♣ module \`${module}'... "
  if [[ -f "${xyzman_user_conf_dir}/${module}.conf" ]]; then
    # TODO Extract to a function to allow migration of configs
    echo "SKIPPED (already exists)"
  else
    mv "${xyzman_stage_folder}/src/${module}/default.cfg" "${xyzman_user_conf_dir}/${module}.conf"
    echo "OK"
  fi
done


XYZMAN_VERSION="$(head -1 ${xyzman_stage_folder}/version)"
echo "Set version to ${XYZMAN_VERSION} ..."
echo "${XYZMAN_VERSION}" > "${xyzman_var_folder}/curvers"
echo "${XYZMAN_VERSION}" > "${xyzman_var_folder}/version"

# clean up staging folder
rm -fr "${xyzman_stage_folder}"


echo "Attempt update of interactive bash profile..."
# remove lines from .bashrc if they existed
if [[ -f "${xyzman_bashrc}" ]]; then
  sed -i "/${xyzman_bashrc_lines}/d" "${xyzman_bashrc}"
fi
# write xyzman init snipet in .bashrc
echo -e "${xyzman_init_snippet}" >> "${xyzman_bashrc}"
echo "Added xyzman init snippet to ${xyzman_bashrc}"


echo "Attempt update of zsh profile..."
# remove lines from zshrc if they existed
if [[ -f "${xyzman_zshrc}" ]]; then
  sed -i "/${xyzman_bashrc_lines}/d" "${xyzman_zshrc}"
fi
# write xyzman init snipet in .zshrc
echo -e "${xyzman_init_snippet}" >> "${xyzman_zshrc}"
echo "Added xyzman init snippet to ${xyzman_zshrc}"


echo -e "\n\nAll done!\n\n"

echo "Please open a new terminal, or run the following in the existing one:"
echo ""
echo "    source \"${XYZMAN_DIR}/bin/xyzman-init.sh\""
echo ""
echo "Then issue the following command:"
echo ""
echo "    xyz help"
echo ""
echo "Enjoy!!!"
