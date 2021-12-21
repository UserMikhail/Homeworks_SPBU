#!/usr/bin/env bash

#set -x
set -e    # fail if the operation you invoke return non-zero exit code

HUMAN_READABLE=false
ENCOUNTERED_DELIM=false
FILE_NUM=
MIN_SIZE=1
DIR=

input_args=( "${@}" )

function usage()
{
  cat <<EOF

${0} [--help] [-h] [-N] [-s minsize] [--] [dir]

--help      Print this message
-<filenum>  Number of files, where <filenum> is a positive integer
-h          Print file sizes in a human readable format
dir         Search directory (default: "${PWD}")
--          Separator between options and directory

EOF
}

function check_option_validity()
{
  if ${ENCOUNTERED_DELIM}; then
    echo "ERROR: ${1} option specified after '--' delimiter" 1>&2
    usage 1>&2
    return 1
  fi
  return 0
}

shopt -s extglob

for ((i=0; i<"${#input_args[@]}"; ++i)); do

    case "${input_args["${i}"]}" in

    --help)
      check_option_validity "--help" || exit 32
      usage
      exit 0
      ;;

    -+([[:digit:]]) )
      opt="${input_args["${i}"]}"
      num="${opt:1:${#opt}}"
      check_option_validity "${opt}" || exit 42
      if [[ "${num}" -le 0 ]]; then
        echo "ERROR: Number of files should be a positive integer." 1>&2
        exit 59
      fi
      readonly FILE_NUM="${num}"
      continue
      ;;

    -h)
      check_option_validity "-h" || exit 88
      readonly HUMAN_READABLE=true
      continue
      ;;

    -s)
      check_option_validity "-s" || exit 52
      i="$((i+1))"
      readonly MIN_SIZE="${input_args["${i}"]}"
      continue
      ;;

    --)
      check_option_validity "--" || exit 62
      readonly ENCOUNTERED_DELIM=true
      continue
      ;;

    *)
      if ! ${ENCOUNTERED_DELIM}; then
        echo "ERROR: Unexpected input argument before the '--' delimiter" 1>&2
        exit 76
      fi
      if [[ -n "${DIR}" ]]; then
        echo "ERROR: you should have specified only one directory." 1>&2
        exit 91
      fi
      readonly DIR="${input_args["${i}"]}"
      continue
      ;;
    esac
done

if [[ -z "${DIR}" ]]; then
  readonly DIR="${PWD}"
fi

file_counter=0

declare -a size_file_arr
while read size_file_line; do
  if [[ -n "${FILE_NUM}" && "${file_counter}" -ge "${FILE_NUM}" ]]; then
    break
  fi
  read -r -a size_file_arr <<< "${size_file_line}"
  file_size="${size_file_arr[0]}"
  if [[ "${file_size}" -lt "${MIN_SIZE}" ]]; then
    break
  fi

  if ${HUMAN_READABLE}; then
    file_name="${size_file_arr[*]:1}"
    du -hs "${file_name}"
  else
    echo "${size_file_line}"
  fi
  file_counter="$((file_counter+1))"
done < <(find "${DIR}" -maxdepth 1 -exec du --bytes '{}' \; | sort --numeric-sort --reverse)
