#!/bin/bash

set -e

FILE="/etc/passwd"
USER_NAME="${USER}"
if [[ "${1}" == "-f" ]]; then
  readonly FILE="${2}"
  if [[ -n "${3}" ]]; then
    readonly USER_NAME="${3}"
  fi
else
  if [[ -n "${1}" ]]; then
    readonly USER_NAME="${1}"
  fi
fi

while IFS=":" read -r username password userid groupid comment homedir cmdshell
do
  echo "${homedir}"
done < <(grep "^${USER_NAME}:" "${FILE}")
