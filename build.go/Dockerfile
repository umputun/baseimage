FROM golang:1.16-alpine
LABEL maintainer="Umputun <umputun@gmail.com>"

ARG TARGETARCH
ENV \
    TIME_ZONE=America/Chicago   \
    CGO_ENABLED=0               \
    GOARCH=$TARGETARCH          \
    GOVERALLS=0.0.8             \
    GOLANGCI=1.39.0             \
    STATIK=0.1.7                \
    GORELEASER=0.162.0

RUN \
    apk add --no-cache --update tzdata git bash curl && \
    echo "${TIME_ZONE}" > /etc/timezone && \
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
    date && \
    rm -rf /var/cache/apk/*

RUN \
    go version && \
    go get -u github.com/stretchr/testify && \
    go get -u github.com/vektra/mockery/.../ && mockery -version && \
    go get github.com/matryer/moq && moq -version

RUN \
    go get github.com/golangci/golangci-lint/cmd/golangci-lint@v${GOLANGCI} && \
    golangci-lint --version

RUN go get github.com/mattn/goveralls@v${GOVERALLS} && which goveralls
RUN go get github.com/rakyll/statik@v${STATIK} && which statik
RUN go get github.com/goreleaser/goreleaser@v${GORELEASER} &&  goreleaser -v

ADD coverage.sh /script/coverage.sh
ADD git-rev.sh /script/git-rev.sh
ADD version.sh /script/version.sh

RUN chmod +x /script/coverage.sh /script/git-rev.sh /script/version.sh
