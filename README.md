# baseimage [![Actions](https://github.com/umputun/baseimage/workflows/build/badge.svg)](https://github.com/umputun/baseimage/actions)

_minimal docker base image to build and deploy services and applications._

Three images provided:

1. go build image - `ghcr.io/umputun/baseimage/buildgo:latest`. For build stage, includes go compiler and linters. Alpine based.
2. base application image `ghcr.io/umputun/baseimage/app:latest`
3. scratch-based application image `ghcr.io/umputun/baseimage/scratch:latest`

## Go Build Image

Image `ghcr.io/umputun/baseimage/buildgo:latest` (or `umputun/baseimage:buildgo-latest`) intends to be used in multi-stage `Dockefile` to build go applications and services.

* Relatively small, based on the official [golang:alpine](https://hub.docker.com/_/golang/) image
* Enforces `CGO_ENABLED=0`
* With fully installed and ready to use [golangci-lint](https://github.com/golangci/golangci-lint)
* Add useful packages for building and testing - [testify](https://github.com/stretchr/testify), [mockery](https://github.com/vektra/mockery) and [moq](https://github.com/matryer/moq)
* Includes [goreleaser](https://github.com/goreleaser/) and [statik](https://github.com/rakyll/statik)
* With [goveralls](https://github.com/mattn/goveralls) for easy integration with coverage services and provided `coverage.sh` script to report coverage.
* `/script/version.sh` script to make git-based version

## Base Application Image

Image `ghcr.io/umputun/baseimage/app:latest` (or `umputun/baseimage:app-latest`) designed as a lightweight, ready-to-use base for various services. It adds a few things to the regular [alpine image](https://hub.docker.com/_/alpine/).

* `ENTRYPOINT /init.sh` runs `CMD` via [dumb-init](https://github.com/Yelp/dumb-init/)
* Container command runs under `app` user with uid `$APP_UID` (default 1001)
* Optionally runs `/srv/init.sh` if provided by custom container
* Packages `tzdata`, `curl`, `su-exec`, `ca-certificates` and `openssl` pre-installed
* Adds the user `app` (uid=1001)
* By default, enforces non-root execution of the command. Optional "/init-root.sh" can be used to run as root.

### Run-time Customization

The container can be customized in runtime by setting environment from docker's command line or as a part of `docker-compose.yml`

- `TIME_ZONE` - set container's TZ, default "America/Chicago". For scratch-based `TZ` should be used instead
- `APP_UID` - UID of internal `app` user, default 1001

### Working with Docker from inside container

The `app` user is a member of the `docker` group. That allows it to interact with the Docker socket (`/var/run/docker.sock`) when it is explicitly mounted into the container. This is particularly useful for advanced use cases that require such functionality, such as monitoring other containers or accessing Docker APIs.

Under standard usage, the Docker socket is not mounted into the container. In such cases, the docker group membership does not grant the app user any elevated privileges. The container remains secure and operates with an unprivileged user.

#### Security Implications

Mounting the Docker socket into a container can pose a security risk, as it effectively grants the container access to the Docker host and its containers. This is not specific to this image but is a general consideration when working with Docker.

**Recommendation**: Only mount the Docker socket if it is necessary for your use case and you understand the associated risks.

## Example of multi-stage Dockerfile with baseimage:buildgo and baseimage:app

```dockerfile
FROM ghcr.io/umputun/baseimage/buildgo:latest as build

WORKDIR /build
ADD . /build

RUN go test ./...
RUN golangci-lint run --out-format=tab --tests=false ./...

RUN \
    revision=$(/script/git-rev.sh) && \
    echo "revision=${revision}" && \
    go build -o app -ldflags "-X main.revision=$revision -s -w" .


FROM ghcr.io/umputun/baseimage/app:latest

COPY --from=build /build/app /srv/app

EXPOSE 8080
WORKDIR /srv

CMD ["/srv/app", "param1", "param2"]
```

It will make a container running "/srv/app" (with passed params) under 'app' user.

To customize both TIME_ZONE and UID - `docker run -e TIME_ZONE=America/New_York -e APP_UID=2000 <image>`

## Base Scratch Image

Image `ghcr.io/umputun/baseimage/scratch:latest` (or `umputun/baseimage:scratch-latest`) adds a few extras to the `scratch` (empty) image:

- zoneinfo to allow change the timezone of the running application using the `TZ` environment variable
- SSL certificates (ca-certificates)
- `/etc/passwd` and `/etc/groups` with `app` user and group added (UID:1001, GID:1001)
- `/nop` program to wait forever and do nothing

Container sets user to `app` and working directory to `/srv`, no entrypoint set. In order to change time zone `TZ` env can be used.

The overall size of this image is about 512KB only, with 4MB download size due to parent layers.

### Multi-stage Dockerfile Example with baseimage:scratch

```dockerfile
# Build Stage
FROM ghcr.io/umputun/baseimage/buildgo:latest as build

WORKDIR /build
ADD . /build

RUN go test ./...
RUN golangci-lint run --out-format=tab --tests=false ./...

RUN \
    revision=$(/script/git-rev.sh) && \
    echo "revision=${revision}" && \
    go build -mod=vendor -o app -ldflags "-X main.revision=$revision -s -w" .


# Scratch-based Application Image
FROM ghcr.io/umputun/baseimage/scratch:latest

COPY --from=build /build/app /srv/app

CMD ["/srv/app", "param1", "param2"]
```

## `dk.sh`

The `dk.sh` is a simple script to get a shell inside containers that don't have one (like scratch-based containers). It works by temporarily copying BusyBox into the container and cleaning it up after you're done.

```
./dk.sh <container_name>
```

This lets you inspect and debug the container's environment easily, without leaving any leftovers.
