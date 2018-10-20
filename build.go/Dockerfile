FROM golang:1.11-alpine

RUN \
    apk add --no-cache --update tzdata git bash curl && \
    cp /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    rm -rf /var/cache/apk/*

RUN go version

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
ENV GOLANGCILINT=1.5
ENV GOMETALINTER=2.0.11


RUN \
    go get -u -v github.com/alecthomas/gometalinter && \
    cd /go/src/github.com/alecthomas/gometalinter && \
    git checkout v${GOMETALINTER} && \
    go install github.com/alecthomas/gometalinter && \
    gometalinter --install 

ADD https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCILINT}/golangci-lint-${GOLANGCILINT}-linux-amd64.tar.gz /tmp/golangci-lint.tar.gz
RUN \
    cd /tmp && tar -zxf /tmp/golangci-lint.tar.gz && \
    mv /tmp/golangci-lint-${GOLANGCILINT}-linux-amd64/golangci-lint /go/bin/golangci-lint &&\
    chmod +x /go/bin/golangci-lint

RUN \
    go get -u -v github.com/golang/dep/cmd/dep && \
    go get -u -v github.com/kardianos/govendor && \
    go get -u -v github.com/mattn/goveralls && \
    go get -u -v github.com/jteeuwen/go-bindata/... && \
    go get -u -v github.com/stretchr/testify && \
    go get -u -v github.com/vektra/mockery/.../


ADD coverage.sh /script/coverage.sh
ADD checkvendor.sh /script/checkvendor.sh
ADD git-rev.sh /script/git-rev.sh

RUN \
    chmod +x /script/coverage.sh /script/checkvendor.sh /script/git-rev.sh && \
    ln -s /script/checkvendor.sh $GOPATH/bin/checkvendor
