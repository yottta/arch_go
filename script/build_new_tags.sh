#!/bin/bash
set -e

function print_message() {
  echo ""
  echo ""

  echo "## ------> $1"

  echo ""
  echo ""
}

script_path=$(cd `dirname $0` && pwd)

existing_tags=" $(wget -q https://registry.hub.docker.com/v1/repositories/$DOCKER_HUB_USER_ID/arch-go/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}') "

docker login -u "$DOCKER_HUB_USER_ID" -p "$DOCKER_HUB_USER_PWD"


for tag in $(git ls-remote --tags https://go.googlesource.com/go | awk '{print $2}' | grep refs/tags/go | egrep -v "go1\.[0-1]{1}\..*$" | egrep -v "go1\.1$" | egrep -v "go1$" | cut -d'/' -f3); do
  print_message "Build image $tag"

  set +e
  echo "#start#"${existing_tags}"#end#" | grep "\s$tag\s"> /dev/null
  result=$?
  set -e
  if [ $result -eq  0 ]; then
    print_message "$tag already exists. Skipping."
    continue
  fi
  docker build $script_path/../docker --build-arg go_version=$tag -t arch-go

	docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:$tag
	docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:latest
	docker push $DOCKER_HUB_USER_ID/arch-go:$tag

	print_message "$tag image processed successfully"
done
