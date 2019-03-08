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

failed_tags=""
skipped_tags=""
built_tags=""

for tag in $(git ls-remote --tags https://go.googlesource.com/go | awk '{print $2}' | grep refs/tags/go | egrep -v "go1\.[0-1]{1}\..*$" | egrep -v "go1\.1$" | egrep -v "go1$" | cut -d'/' -f3); do
  print_message "Build image $tag"

  set +e
  echo "#start#"${existing_tags}"#end#" | grep "\s$tag\s"> /dev/null
  result=$?
  if [ $result -eq  0 ]; then
    print_message "$tag already exists. Skipping."
    skipped_tags="$skipped_tags $tag"
    continue
  fi
  docker build $script_path/../docker --build-arg go_version=$tag -t arch-go
  result=$?
  set -e
  if [ $result -ne  0 ]; then
    print_message "$tag failed building the image. Skipped."
    failed_tags="$failed_tags $tag"
    continue
  fi

	docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:$tag
	docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:latest
	docker push $DOCKER_HUB_USER_ID/arch-go:$tag

  built_tags="$built_tags $tag"
	print_message "$tag image processed successfully"
done

print_message "Skipped tags: $skipped_tags"
print_message "Failed tags: $failed_tags"
print_message "Successfully built tags: $built_tags"
