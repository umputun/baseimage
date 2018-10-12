# baseimage [![Docker Automated build](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/umputun/baseimage/) [![Build Status](https://travis-ci.org/umputun/baseimage.svg?branch=master)](https://travis-ci.org/umputun/baseimage)

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

### Example of Dockerfile from baseimage:buildgo 

```docker
ROM umputun/baseimage:buildgo-latest as build-backend

WORKDIR /go/src/github.com/umputun/remark

ADD app /go/src/github.com/umputun/remark/app
ADD vendor /go/src/github.com/umputun/remark/vendor
ADD .git /go/src/github.com/umputun/remark/.git

RUN cd app && go test ./...

RUN gometalinter --disable-all --deadline=300s --vendor --enable=vet --enable=vetshadow --enable=golint \
    --enable=staticcheck --enable=ineffassign --enable=goconst --enable=errcheck --enable=unconvert \
    --enable=deadcode  --enable=gosimple --enable=gas --exclude=test --exclude=mock --exclude=vendor ./...

RUN mkdir -p target && /script/coverage.sh

RUN \
    version=$(/script/git-rev.sh) && \
    echo "version $version" && \  
    go build -o remark -ldflags "-X main.revision=${version} -s -w" ./app
```

## Base Application Image

Image `umputun/baseimage:app-latest` designed as a lightweight, ready-to-use base for various services. It adds a few things to the regular [alpine image](https://hub.docker.com/_/alpine/).

* `ENTRYPOINT /init.sh` runs `CMD` via [dumb-init](https://github.com/Yelp/dumb-init/)
* Optionally runs `/srv/init.sh` if provided by custom container
* Packages `tzdata`, `curl` and `openssl`
* Adds user `app` (uid=1001)
