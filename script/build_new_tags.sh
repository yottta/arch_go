#!/bin/bash
set -e

script_path=$(cd `dirname $0` && pwd)

existing_tags=" $(wget -q https://registry.hub.docker.com/v1/repositories/$DOCKER_HUB_USER_ID/arch-go/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}') "

for tag in $(git ls-remote --tags https://go.googlesource.com/go | awk '{print $2}' | grep refs/tags/go | egrep -v "go1\.[0-1]{1}\..*$" | egrep -v "go1\.1$" | egrep -v "go1$" | cut -d'/' -f3); do
  echo "Build image $tag"

  echo "#start#"${existing_tags}"#end#" | grep "\s$1\s"> /dev/null
  if [ $? -eq  0 ]; then
    echo "$tag already exists. Skipping."
    continue
  fi
  docker build $script_path/../docker --build-arg go_version=$tag -t arch-go

	docker login -u "$DOCKER_HUB_USER_ID" -p "$DOCKER_HUB_USER_PWD"
	docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:$tag
	docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:latest
	docker push $DOCKER_HUB_USER_ID/arch-go:$tag
	docker push $DOCKER_HUB_USER_ID/arch-go:latest

	echo "Image processed successfully"
	break
done
