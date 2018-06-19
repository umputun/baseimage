FROM golang:1.10-alpine

RUN \
    apk add --no-cache --update tzdata git bash curl && \
    cp /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    rm -rf /var/cache/apk/*

RUN go version

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
ENV GOLANGCILINT=1.5

RUN \
    go get -u github.com/golang/dep/cmd/dep && \
    go get -u github.com/kardianos/govendor && \
    go get -u github.com/mattn/goveralls && \
    go get -u github.com/jteeuwen/go-bindata/... && \
    go get -u github.com/stretchr/testify && \
    go get -u github.com/vektra/mockery/.../ && \
    go get -u gopkg.in/alecthomas/gometalinter.v2 && \
    ln -s /go/bin/gometalinter.v2 /go/bin/gometalinter && \
    gometalinter --install --force

ADD https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCILINT}/golangci-lint-${GOLANGCILINT}-linux-amd64.tar.gz /tmp/golangci-lint.tar.gz

RUN \
    cd /tmp && tar -zxf /tmp/golangci-lint.tar.gz && \
    mv /tmp/golangci-lint-${GOLANGCILINT}-linux-amd64/golangci-lint /go/bin/golangci-lint && \
    chmod +x /go/bin/golangci-lint


ADD coverage.sh /script/coverage.sh
ADD checkvendor.sh /script/checkvendor.sh
ADD git-rev.sh /script/git-rev.sh

RUN \
    chmod +x /script/coverage.sh /script/checkvendor.sh /script/git-rev.sh && \
    ln -s /script/checkvendor.sh $GOPATH/bin/checkvendor
