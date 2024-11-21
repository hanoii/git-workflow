#!/bin/bash
#ddev-generated
version=$(node -v | awk -F'[v.]' '{print $2}')
if [ $version -lt 18 ]; then
  prefix="n exec lts "
else
  prefix=$(npm config get prefix)/bin/
fi
echo -n "$prefix"
