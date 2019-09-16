# baseimage [![Docker Automated build](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/umputun/baseimage/) [![Build Status](https://github.com/umputun/baseimage/workflows/build/badge.svg)]

_minimalist docker base image to build and deploy my services and applications._

Two images included:

1. go build image - `umputun/baseimage:buildgo-latest`. For build stage, includes go compiler and linters. Alpine based.
2. base application image `umputun/baseimage:app-latest`

## Go Build Image

Image `umputun/baseimage:buildgo-latest` intends to be used in multi-stage `Dockefile` to build go applications and services.

* Relatively small, based on the official [golang:alpine](https://hub.docker.com/_/golang/) image
* Enforces `CGO_ENABLED=0` and `GOARCH=amd64`
* Adds vendor tool [dep](https://github.com/golang/dep) and [govendor](https://github.com/kardianos/govendor)
* With fully installed and ready to use linters [gometalinter](https://github.com/alecthomas/gometalinter) and [golangci-lint](https://github.com/golangci/golangci-lint)
* Add useful packages for building and testing - [testify](https://github.com/stretchr/testify), [mockery](https://github.com/vektra/mockery) and [go-bindata](https://github.com/jteeuwen/go-bindata)
* With [goveralls](https://github.com/mattn/goveralls) for easy integration with coverage services and provided `coverage.sh` script to report coverage.
* `git-rev.sh` script to make git-based version without full `.git` copied (works without `.git/objects`)


## Base Application Image

Image `umputun/baseimage:app-latest` designed as a lightweight, ready-to-use base for various services.
It adds a few things to the regular [alpine image](https://hub.docker.com/_/alpine/).

* `ENTRYPOINT /init.sh` runs `CMD` via [dumb-init](https://github.com/Yelp/dumb-init/)
* Container command runs under `app` user with uid `$APP_UID` (default 1001) 
* Optionally runs `/srv/init.sh` if provided by custom container
* Packages `tzdata`, `curl`, `su-exec`, `ca-certificates` and `openssl` pre-installed
* Adds the user `app` (uid=1001)
* By default enforces non-root execution of the command. Optional "/init-root.sh" can be used to run as root.

### Run-time Customization

The container can be customized in runtime by setting environment from docker's command line or as a part of `docker-compose.yml`

- `TIME_ZONE` - set container's TZ, default "America/Chicago"
- `APP_UID` - UID of internal `app` user, default 1001

## Example of multi-stage Dockerfile with baseimage:buildgo and baseimage:app

```docker
FROM umputun/baseimage:buildgo as build

WORKDIR /build
ADD . /build

RUN go test -mod=vendor ./...
RUN golangci-lint run --out-format=tab --tests=false ./...

RUN \
    revison=$(/script/git-rev.sh) && \
    echo "revision=${revison}" && \
    go build -mod=vendor -o app -ldflags "-X main.revision=$revison -s -w" .


FROM umputun/baseimage:app

COPY --from=build /build/app /srv/app

EXPOSE 8080
WORKDIR /srv

CMD ["/srv/app", "param1", "param2]
```

It will make a container running "/srv/app" (with passed params) under 'app' user.

To customize both TIME_ZONE and UID - `docker run -e TIME_ZONE=America/New_York -e APP_UID=2000 <image>`
 
