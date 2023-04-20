#!/usr/bin/env bash

function __xyz_fun1() {
  export xyzman_user_conf_dir
  export xyzman_modules_dir

  ${xyzman_modules_dir}/mod1/fun1.sh $@
}
