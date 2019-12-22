FROM golang:1.13-alpine
LABEL maintainer="Umputun <umputun@gmail.com>"

ENV \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOVERALLS=0.0.4 \
    GOLANGCI=1.21.0 \
    STATIK=0.1.6

RUN \
    apk add --no-cache --update tzdata git bash curl && \
    cp /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    rm -rf /var/cache/apk/*

RUN \
    go version && \
    go get -u -v github.com/golang/dep/cmd/dep && \
    go get -u -v github.com/kardianos/govendor && \
    go get -u -v github.com/jteeuwen/go-bindata/... && \
    go get -u -v github.com/stretchr/testify && \
    go get -u -v github.com/vektra/mockery/.../

RUN \
    go get -u -v github.com/golangci/golangci-lint/cmd/golangci-lint && \
    cd /go/src/github.com/golangci/golangci-lint && \
    git checkout v${GOLANGCI} && \
    cd /go/src/github.com/golangci/golangci-lint/cmd/golangci-lint && \
    go install -ldflags "-X 'main.version=$(git describe --tags)' -X 'main.commit=$(git rev-parse --short HEAD)' -X 'main.date=$(date)'" && \
    golangci-lint --version

RUN \
    go get -u -v github.com/mattn/goveralls && \
    cd /go/src/github.com/mattn/goveralls && \
    git checkout v${GOVERALLS} && \
    go install github.com/mattn/goveralls

RUN \
    go get -u -v github.com/rakyll/statik && \
    cd /go/src/github.com/rakyll/statik && \
    git checkout v${STATIK} && \
    go install github.com/rakyll/statik

ADD coverage.sh /script/coverage.sh
ADD checkvendor.sh /script/checkvendor.sh
ADD git-rev.sh /script/git-rev.sh

RUN chmod +x /script/coverage.sh /script/checkvendor.sh /script/git-rev.sh
