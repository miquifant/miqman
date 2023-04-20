#!/usr/bin/env bash

TAG="# XYZMAN: Please, don't edit this line"
BASHRC_LINES_REGEX='^[ \t]*[^ \t#].*'${TAG}'$'

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

if prompt_yn "Do you want to keep your config files?" Y; then
  echo "User config files won't be deleted."
  echo "To remove XYZMAN completely (including user configuration files) delete directory \`${HOME}/.config/xyzman'."
else
  rm -fr ~/.config/xyzman
fi

rm -fr ~/.xyzman

# remove lines from .bashrc if they existed
if [[ -f ~/.bashrc ]]; then
  sed -i "/${BASHRC_LINES_REGEX}/d" ~/.bashrc
fi
# remove lines from .zshrc if they existed
if [[ -f ~/.zshrc ]]; then
  sed -i "/${BASHRC_LINES_REGEX}/d" ~/.zshrc
fi

echo "XYZMAN successfuly uninstalled!"
