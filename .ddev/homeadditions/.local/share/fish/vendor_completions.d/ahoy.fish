#ddev-generated

# @TODO: Try to use ahoy -f as part of the commands so autocomplete works with that
# was playing with `ahoy --help | sed -z 's/.*COMMANDS:\(.*\)GLOBAL.*/\1/' | cut -d ' ' -f 4'`
# to extract commands instead of --generate-bash-completion but needs more work
# apparently argparse can be used to extract the file parameter.

function __fish_ahoy_subcommand
  set -l cmd (commandline)
  eval $cmd --generate-bash-completion | grep -vw h | grep -vw help
end

function __fish_ahoy_config
  set -l cmd (commandline -ct)
  echo "cmd: $cmd" >> debug.txt
  set -l dirglob ""
  set -l dirfind "."
  if test -d (string replace -r '(.*)/[^\/]*$' '$1/' $cmd)
    set dirglob (string replace -r '(.*)/[^\/]*$' '$1/' $cmd)
    set dirfind (string replace -r '(.*)/[^\/]*$' '$1/' $cmd)
  end
  set -l configs $dirglob.*.yml $dirglob.*.yaml $dirglob.*.yml $dirglob*.yaml
  for i in $configs
    echo $i
  end
  find $dirfind -mindepth 1 -maxdepth 1 -type d | sed 's/\.\/\(.*\)/\1/g' | sed 's/$/\//g' | sort
end

complete -c ahoy -f -n "not __fish_seen_subcommand_from (ahoy --generate-bash-completion)" -a "(ahoy --generate-bash-completion)"
complete -c ahoy -n "__fish_seen_subcommand_from (ahoy -h | grep ▼ | cut -d ' ' -f 4)" -a "(__fish_ahoy_subcommand)"
complete -c ahoy -s f -l file -x -a "(__fish_ahoy_config)"
