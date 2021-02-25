FROM golang:1.15-alpine
LABEL maintainer="Umputun <umputun@gmail.com>"

ENV \
    TIME_ZONE=America/Chicago \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOVERALLS=0.0.6 \
    GOLANGCI=1.31.0 \
    STATIK=0.1.7 \ 
    GORELEASER=0.143.0

RUN \
    apk add --no-cache --update tzdata git bash curl && \
    echo "${TIME_ZONE}" > /etc/timezone && \
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
    date && \
    rm -rf /var/cache/apk/*

RUN \
    go version && \
    go get -u -v github.com/golang/dep/cmd/dep && \
    go get -u -v github.com/kardianos/govendor && \
    go get -u -v github.com/go-bindata/go-bindata/... && \
    go get -u -v github.com/stretchr/testify && \
    GO111MODULE=on go get -u -v github.com/vektra/mockery/.../

RUN \
    GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint@v${GOLANGCI} && \
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

RUN \
    wget https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER}/goreleaser_Linux_x86_64.tar.gz -O /tmp/goreleaser_Linux_x86_64.tar.gz && \
    cd /tmp && tar -zxf /tmp/goreleaser_Linux_x86_64.tar.gz && \
    mv /tmp/goreleaser /usr/bin/goreleaser && \
    goreleaser -v

ADD coverage.sh /script/coverage.sh
ADD checkvendor.sh /script/checkvendor.sh
ADD git-rev.sh /script/git-rev.sh

RUN chmod +x /script/coverage.sh /script/checkvendor.sh /script/git-rev.sh
