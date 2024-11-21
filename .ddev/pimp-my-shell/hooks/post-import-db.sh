#!/bin/bash
#ddev-generated
set -e -o pipefail

for f in /var/www/html/.ddev/pimp-my-shell/hooks/post-import-db.d/*; do
  if [ -x $f ]; then
    gum log --level info "Running $f ..."
    if $f "$@"; then
      :
    else
      exit_code=$?
      gum log --level error "$f exited with $exit_code."
    fi
  fi
  if [ -f $f.source ]; then
    gum log --level info "Sourcing $f.source ..."
    source $f.source
    rm $f.source
  fi
done
