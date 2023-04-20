#!/usr/bin/env bash

XYZ_MOD1_HOME="$(dirname $0)"

source "${XYZ_MOD1_HOME}/utils.sh"

# Path to default configuration file
default_configuration="${xyzman_user_conf_dir}/mod1.conf"
configuration_file=$default_configuration

print_usage() {
  printf "\n"
  printf "Usage: xyz fun1 [<options>] - TODO describe mod1:fun1\n"
  printf "\n"
  printf "options:\n"
  printf "    -h            print this help\n"
  printf "\n"
  printf "examples:\n"
  printf "    xyz fun1\n"
  printf "\n"
}

while getopts '\-:h' flag; do
  case "${flag}" in
    -) long_optarg="${OPTARG#*=}"
       case "${OPTARG}" in
         help ) print_usage
                exit 0 ;;
         # "--" terminates argument processing
         ''   ) break ;;
         *    ) printf "illegal option !!-- ${OPTARG}\n"
                print_usage
                exit 1 ;;
       esac ;;
    h) print_usage
       exit 0 ;;
    *) print_usage
       exit 1 ;;
  esac
done
[ $# -gt 0 ] && shift $((--OPTIND))


source $configuration_file


main() {
  validate_parameters
  if [ $? -ne 0 ]; then
    exit $?
  fi

  echo "Hello world!"

  exit $?
}


validate_parameters() {
  error=0
  if [ -z param_1 ]; then print_variable_not_set "param_1" && error=1; fi
  if [ -z param_2 ]; then print_variable_not_set "param_2" && error=1; fi

  if ((error)); then
    echo "ERROR: Validation of ${configuration_file} failed." \
         " Please, update it with the required variables and try again."
    exit 1; fi
}


main
