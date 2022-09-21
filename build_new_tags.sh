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

existing_tags=""
docker_tags_url="https://hub.docker.com/v2/namespaces/$DOCKER_HUB_USER_ID/repositories/arch-go/tags?page_size=1000"
while true; do
    res="$(wget -q $docker_tags_url -O -)"
    existing_tags="$existing_tags $(echo $res | jq '.results[].name') \n"
    docker_tags_url="$(echo $res | jq -r '.next')"
    if [ "$docker_tags_url" = "null" ]; then
        break
    fi
    echo "get the next page $docker_tags_url"
done
echo "existing tags"
echo -e "$existing_tags"
docker login -u "$DOCKER_HUB_USER_ID" -p "$DOCKER_HUB_USER_PWD"

skipped_tags=""
built_tags=""
failed_tags=""

for tag in $(git ls-remote --tags https://go.googlesource.com/go | awk '{print $2}' | grep refs/tags/go | cut -d'/' -f3); do
    print_message "Build image for go tag $tag"

    res=`echo -e "${existing_tags}" | grep '"'$tag'"' || true`
    if [ ! -z "$res" ]; then
        print_message "$tag already exists. Skipping."
        skipped_tags="$skipped_tags $tag"
        continue
    fi

    set +e
    docker build --platform linux/amd64 $script_path/docker --build-arg GO_VERSION=$tag -t arch-go
    if [ $? -ne 0 ]; then
        failed_tags="$failed_tags $tag"
        print_message "Build image failed for go tag $tag"
        continue
    fi
    set -e
    docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:$tag
    docker tag arch-go $DOCKER_HUB_USER_ID/arch-go:latest
    docker push $DOCKER_HUB_USER_ID/arch-go:$tag

    built_tags="$built_tags $tag"
    print_message "$tag image processed successfully"
done

print_message "Skipped tags: $skipped_tags"
print_message "Successfully built tags: $built_tags"
print_message "Failed tags: $failed_tags"
