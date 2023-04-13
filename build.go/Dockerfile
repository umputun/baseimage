FROM golang:1.20-alpine
LABEL maintainer="Umputun <umputun@gmail.com>"

ENV \
    TIME_ZONE=America/Chicago   \
    CGO_ENABLED=0               \
    GOVERALLS=0.0.11            \
    GOLANGCI=1.51.2             \
    STATIK=0.1.7                \
    GORELEASER=1.15.2

RUN \
    apk add --no-cache --update tzdata git bash curl && \
    echo "${TIME_ZONE}" > /etc/timezone && \
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
    date && \
    rm -rf /var/cache/apk/*

RUN \
    go version && \
    go install github.com/matryer/moq@latest && moq -version

RUN \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v${GOLANGCI} && \
    golangci-lint --version

RUN go install github.com/mattn/goveralls@v${GOVERALLS} && which goveralls
RUN go install github.com/rakyll/statik@v${STATIK} && which statik
RUN go install github.com/goreleaser/goreleaser@v${GORELEASER} &&  goreleaser -v

COPY coverage.sh /script/coverage.sh
COPY git-rev.sh /script/git-rev.sh
COPY version.sh /script/version.sh

RUN chmod +x /script/coverage.sh /script/git-rev.sh /script/version.sh
