#!/bin/bash
#
# Common utility functions
#

. $UB_HOME/errors.bash

#
# Logging and process execution
#
function linfo {
  echo "[INFO ] $@"
}

function lerror {
  echo "[ERROR] $@"
}

function die {
  eval lerror "$1 -\$$(echo $@)"
  exit 1
}

linfo "Using a root directory of ${UB_HOME}"
