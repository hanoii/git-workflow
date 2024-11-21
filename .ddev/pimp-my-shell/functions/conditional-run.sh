#ddev-generated

cr_init() {
  if [ "$#" -lt 3 ]; then
    >&2 echo -e "\033[0;31m[error/${FUNCNAME[0]}] You need to pass an ID, an extra string (or empty), and a list of tar extra parameters followed by a list of files and/or directories.\033[0m"
    return 10
  fi
  local id=$1
  local extra=$2
  local hash_filename=".cr.hash.$id"
  local hash_filepath="/tmp/${hash_filename}"
  shift 2
  # gzip -n is so that gzip doesn't add timestamp, that's also the reason I am
  # not using `tar -zcf` instead.
  { echo "$extra"; tar --mtime='1970-01-01' -cf - "$@";} | gzip -n | sha1sum | cut -d ' ' -f 1 > $hash_filepath
  mkdir -p /mnt/ddev-global-cache/pimp-my-shell/${HOSTNAME}/cr
}

cr_should_run() {
  if [ "$#" -lt 1 ]; then
    >&2 echo -e "\033[0;31m[error/${FUNCNAME[0]}] You need to pass an ID.\033[0m"
    return 10
  fi
  local id=$1
  local hash_filename=".cr.hash.$id"
  local hash_filepath="/tmp/${hash_filename}"
  local stored_hash_filepath="/mnt/ddev-global-cache/pimp-my-shell/${HOSTNAME}/cr/${hash_filename}"
  [[ ! -f $stored_hash_filepath ]] || ! cmp -s "$stored_hash_filepath" $hash_filepath
}

cr_success() {
  if [ "$#" -lt 1 ]; then
    >&2 echo -e "\033[0;31m[error/${FUNCNAME[0]}] You need to pass an ID.\033[0m"
    return 10
  fi
  local id=$1
  local hash_filename=".cr.hash.$id"
  local hash_filepath="/tmp/${hash_filename}"
  local stored_hash_filepath="/mnt/ddev-global-cache/pimp-my-shell/${HOSTNAME}/cr/${hash_filename}"
  cp $hash_filepath $stored_hash_filepath
}
