#!/usr/bin/env bash


# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eo pipefail



# Set a trap to catch errors in the script and print an 
# error message with the line number where the error occurred.
trap 's=$?; echo "Error on $LINENO"; exit $s' ERR

# Colors
# ---
# Inspired from: https://unix.stackexchange.com/questions/9957/how-to-check-if-bash-can-print-colors

f_bold=
f_normal=
f_red=
f_green=

# Check if we are in a terminal...
if [[ -n "$TERM" ]]; then
    # See if it supports colors...
    nc=$(tput colors || true)
    if [[ -n "$nc" ]] && [[ $nc -ge 8 ]]; then
        f_bold="$(tput bold)"
        f_normal="$(tput sgr0)"
        f_red="$(tput setaf 1)"
        f_green="$(tput setaf 2)"
    fi
fi


# Utils
# ---
function error() {
    log "${f_bold}${f_red}error${f_normal}: $1"
}

function info() {
    log "${f_bold}${f_green}info${f_normal}: $1"
}



# Find all files named "fed-modules.json" in the "static" directory
# and store their paths in an array named "files".
files=($(find static -name "fed-modules.json"))

valid=true


for file in "${files[@]}"
do

  # Read the contents of the file and pass them to the jq command to extract all keys that are not camel-cased.
  invalid_keys=$(cat $file | jq 'keys[] | select(test("^[a-z]+([A-Z][a-z]*)*$") | not)')
  
  if [ -z "$invalid_keys" ]; then
      info "${file} is valid."
  else
      error "${file} is invalid. Below keys must be camel-cased."
      error "${invalid_keys}"
      valid=false
  fi

done


# If any file was found to have invalid keys, exit the script with an error code.
if ! "$valid"; then
  exit 1
fi