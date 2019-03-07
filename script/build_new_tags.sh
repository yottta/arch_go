#!/bin/bash

echo $CIRCLECI_ENV_IN_SCRIPT
for tag in $(git ls-remote --tags https://go.googlesource.com/go | awk '{print $2}' | grep refs/tags/go | cut -d'/' -f3); do
  echo "$tag"
done
