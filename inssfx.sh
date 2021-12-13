#!/usr/bin/env bash

set -e    # fail if the operation you invoke return non-zero exit code
#set -x

VERBOSE=false
DRY_RUN=false
ENCOUNTERED_DELIM=false
SUFFIX=
DIRECTORY=
ARR_MASK=( )

input_args=( "${@}" )

function usage()
{
  cat <<EOF

${0} [-h|-v|-d] [--] suffix file...

-h Print help message
-v Increase verbosity level
-d Dry run ${0}
-- Delimiter between optional and non-optional arguments

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



for inp_arg in "${input_args[@]}"; do

    case "${inp_arg}" in

    -h)
      check_option_validity "-h" || exit 32
      usage
      exit 0
      ;;

    -v)
      check_option_validity "-v" || exit 42
      readonly VERBOSE=true
      continue
      ;;

    -d)
      check_option_validity "-d" || exit 52
      readonly DRY_RUN=true
      continue
      ;;

    --)
      check_option_validity "--" || exit 62
      ENCOUNTERED_DELIM=true
      continue
      ;;
    esac

    if ! ${ENCOUNTERED_DELIM}; then
      cat 1>&2 <<EOF
ERROR: Error in the logic of this script.
       We should not be here before encountering the '--' input argument.
EOF
      exit 75
    fi

    if [[ -z "${SUFFIX}" ]]; then
      SUFFIX="${inp_arg}"
    elif [[ -z "${DIRECTORY}" ]]; then
      DIRECTORY="${inp_arg}"
    else
      ARR_MASK+=( "${inp_arg}" )
    fi
done

FIND_CMD=( "find" "${DIRECTORY}" )
is_first_mask=true
for mask in "${ARR_MASK[@]}"; do

  if ! ${is_first_mask}; then
    FIND_CMD+=( "-o" )
  fi

  FIND_CMD+=( "-name" "${mask}" )

  is_first_mask=false
done

FILES=$( "${FIND_CMD[@]}" )


for file in "${FILES[@]}"; do


  dir_name="$(dirname "${file}")"
  stem="$(basename "${file%%.*}")"
  stem_with_suffix="${stem}${SUFFIX}"
  ext="${file##*.}"
  new_file="${dir_name}/${stem_with_suffix}.${ext}"


  cmd="mv $(if ${VERBOSE}; then echo "--verbose"; else echo ""; fi) \"${file}\" \"${new_file}\""


  if ${DRY_RUN}; then
    echo "${cmd}"
  else
    eval "${cmd}"
  fi
done


