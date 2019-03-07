#!/bin/bash

set -e

script_path=$(cd `dirname $0` && pwd)
echo $CIRCLECI_ENV_IN_SCRIPT
for tag in $(git ls-remote --tags https://go.googlesource.com/go | awk '{print $2}' | grep refs/tags/go | cut -d'/' -f3); do
  echo "Build image $tag"
  docker build $script_path/../docker --build-arg go_version=$tag -t arch-go

	docker login -u "$DOCKER_HUB_USER_ID" -p "$DOCKER_HUB_PWD"
	#docker login -e $DOCKER_HUB_EMAIL -u $DOCKER_HUB_USER_ID -p $DOCKER_HUB_PWD
	docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:$tag
	docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:latest
	docker push $DOCKER_HUB_USER_ID/arch-go:$tag
	docker push $DOCKER_HUB_USER_ID/arch-go:latest

	echo "Image processed successfully"
	break
done
