#!/usr/bin/env bash


# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -eo pipefail



# Set a trap to catch errors in the script and print an 
# error message with the line number where the error occurred.
trap 's=$?; echo "Error on $LINENO"; exit $s' ERR


# Define color variables
bold='\e[1m'
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
reset='\e[0m'


# Utils
# ---
function error() {
    echo "${bold}${red}Error${reset}: $1"
}

function info() {
    echo "${bold}${green}info${reset}: $1"
}

function log() {
    echo "${yellow}${1}${reset}"
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
      log "${invalid_keys}"
      valid=false
  fi

done


# If any file was found to have invalid keys, exit the script with an error code.
if ! "$valid"; then
  exit 1
fi