# arch_go

Creates docker images containing [Arch Linux](https://www.archlinux.org/) and [Go (Golang)](https://golang.org/) installation.

# How it works

This repo contains 3 files:
* A Dockerfile that is used to create the actual image;
* A bash script used to ensure that for the most of the available Go versions is a built Docker image;
* CircleCI config file that is used to start the bash script periodically;


## Dockerfile
This can be found in [here](docker/Dockerfile).
This is receiving one argument called `go_version` which is should contains the Go version that has to be built in the current image.
The only thing that is done here is to download the binary and extract it to `/usr/local` and update the `PATH` of the image in order to make the go binaries available right away.

## Bash script
This can be found in [here](script/build_new_tags.sh).
This is responsible with fetching the already built images from [DockerHub](https://hub.docker.com/r/yottta/arch-go).
Also this is listing most of the releases from the [Golang git repo](https://go.googlesource.com/go) and for every one of those that has no image built in arch-go, is building it and push it to the DockerHub.

## CircleCI config
This can be found in [here](.circleci/config.yml)
This is just a config file that gives to the script the ability to perform Docker related commands.
Also in this file is a configuration for a CircleCI workflow to be executed once a week, on Sunday, meaning that if since the last Sunday a new Golang version was released, then the correspondent image will be built as well.

# How to use it
You should just use the normal Dockerfile statement

    FROM yottta/arch-go:<tag>
    
or using a command similar with this one

    docker run --rm -it yottta/arch-go:<tag> bash
    
where `<tag>` should be replaced with the [tag of the image](https://hub.docker.com/r/yottta/arch-go/tags) that you want to use.
