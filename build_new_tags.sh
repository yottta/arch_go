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

existing_tags="$(wget -q https://hub.docker.com/v2/namespaces/$DOCKER_HUB_USER_ID/repositories/arch-go/tags -O - | jq '.results[].name')"
echo "$existing_tags"
docker login -u "$DOCKER_HUB_USER_ID" -p "$DOCKER_HUB_USER_PWD"

skipped_tags=""
built_tags=""

for tag in $(git ls-remote --tags https://go.googlesource.com/go | awk '{print $2}' | grep refs/tags/go | egrep -v "go1\.[0-1]{1}\..*$" | egrep -v "go1\.1$" | egrep -v "go1$" | cut -d'/' -f3); do
    print_message "Build image $tag"

    res=`echo "${existing_tags}" | grep '"'$tag'"' || true`
    if [ ! -z "$res" ]; then
        print_message "$tag already exists. Skipping."
        skipped_tags="$skipped_tags $tag"
        continue
    fi

    docker build --platform linux/amd64 $script_path/docker --build-arg GO_VERSION=$tag -t arch-go
    docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:$tag
    docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:latest
    docker push $DOCKER_HUB_USER_ID/arch-go:$tag

    built_tags="$built_tags $tag"
    print_message "$tag image processed successfully"
done

print_message "Skipped tags: $skipped_tags"
print_message "Successfully built tags: $built_tags"
