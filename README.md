# baseimage [![Actions](https://github.com/umputun/baseimage/workflows/build/badge.svg)](https://github.com/umputun/baseimage/actions)

_minimal docker base image to build and deploy services and applications._

Three images provided:

1. go build image - `umputun/baseimage:buildgo-latest`. For build stage, includes go compiler and linters. Alpine based.
2. base application image `umputun/baseimage:app-latest`
3. scratch-based application image `umputun/baseimage:scratch-latest`


## Go Build Image

Image `umputun/baseimage:buildgo-latest` and `ghcr.io/umputun/baseimage/buildgo:latest` intends to be used in multi-stage `Dockefile` to build go applications and services.

* Relatively small, based on the official [golang:alpine](https://hub.docker.com/_/golang/) image
* Enforces `CGO_ENABLED=0`
* With fully installed and ready to use [golangci-lint](https://github.com/golangci/golangci-lint)
* Add useful packages for building and testing - [testify](https://github.com/stretchr/testify), [mockery](https://github.com/vektra/mockery) and [moq](https://github.com/matryer/moq)
* Includes [goreleaser](https://github.com/goreleaser/) and [statik](https://github.com/rakyll/statik)
* With [goveralls](https://github.com/mattn/goveralls) for easy integration with coverage services and provided `coverage.sh` script to report coverage.
* `/script/version.sh` script to make git-based version


## Base Application Image

Image `umputun/baseimage:app-latest` and `ghcr.io/umputun/baseimage/app:lastest` designed as a lightweight, ready-to-use base for various services. It adds a few things to the regular [alpine image](https://hub.docker.com/_/alpine/).

* `ENTRYPOINT /init.sh` runs `CMD` via [dumb-init](https://github.com/Yelp/dumb-init/)
* Container command runs under `app` user with uid `$APP_UID` (default 1001) 
* Optionally runs `/srv/init.sh` if provided by custom container
* Packages `tzdata`, `curl`, `su-exec`, `ca-certificates` and `openssl` pre-installed
* Adds the user `app` (uid=1001)
* By default enforces non-root execution of the command. Optional "/init-root.sh" can be used to run as root.


### Run-time Customization

The container can be customized in runtime by setting environment from docker's command line or as a part of `docker-compose.yml`

- `TIME_ZONE` - set container's TZ, default "America/Chicago". For scratch-based `TZ` should be used instead
- `APP_UID` - UID of internal `app` user, default 1001

## Example of multi-stage Dockerfile with baseimage:buildgo and baseimage:app

```dockerfile
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

CMD ["/srv/app", "param1", "param2"]
```

It will make a container running "/srv/app" (with passed params) under 'app' user.

To customize both TIME_ZONE and UID - `docker run -e TIME_ZONE=America/New_York -e APP_UID=2000 <image>`
 
## Base Scratch Image

Image `umputun/baseimage:scratch-latest` (or `ghcr.io/umputun/baseimage/scratch`) adds a few extras to the `scratch` (empty) image: 

- zoneinfo to allow change the timezone of the running application
- SSL certificates (ca-certificates)
- `/etc/passwd` and `/etc/groups` with `app` user and group added (UID:1001, GID:1001)
- `/nop` program to wait forever and do nothing

Container sets user to `app` and working directory to `/srv`, no entrypoint set. In order to change time zone `TZ` env can be used. 

The overall size of this image is about 1M only.
