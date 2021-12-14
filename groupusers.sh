set -e

FILE="/etc/group"
input_args=( "${@}" )

if [[ "${input_args[${1}]}" == "-f" ]]; then
  readonly FILE="${input_args[${2}]}"
fi
for arg in "${@}"; do
  if [[ "${arg}" == "-f" && ! "${arg}" == "${input_args[1]}" ]]; then
    echo "ERROR: Not correct use -f" 1>&2
    return 2
  fi
done
CHECK="$(grep "${input_args["$((len_arr-1))"]}:" "$FILE")"
if [[ -z "${CHECK}" ]]; then
  echo "ERROR: No group name: ${input_args["$((len_arr-1))"]} in file: ${FILE}:" 1>&2
  return 1
fi
len_arr="${#input_args[@]}"
while IFS=":" read -r namegroup word num names
do
  echo "${names}"
done < <(grep "${input_args["$((len_arr-1))"]}:" "$FILE")
