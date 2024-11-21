#!/bin/bash
#ddev-generated
set -e -o pipefail

$(/var/www/html/.ddev/readme/whichnode.sh)prettier /var/www/html/README.md --cache-location /var/www/html/.ddev/readme/.cache/prettier --write --config=/var/www/html/.ddev/readme/.prettierrc
$(/var/www/html/.ddev/readme/whichnode.sh)markdown-toc -i /var/www/html/README.md
