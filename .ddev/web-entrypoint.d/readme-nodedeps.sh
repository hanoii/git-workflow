#!/usr/bin/env bash
#ddev-generated

# We install it as a web-entrypoint.d shell because that's after n installs the
# configured version

version=$(node -v | awk -F'[v.]' '{print $2}'); \
if [ $version -lt 18 ]; then \
  n install lts -d; \
  n exec lts npm install -g markdown-toc prettier; \
else \
  npm install -g markdown-toc prettier; \
fi
