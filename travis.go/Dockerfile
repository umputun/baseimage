FROM umputun/baseimage:buildgo-latest

ARG CI
ARG TRAVIS
ARG TRAVIS_BRANCH
ARG TRAVIS_COMMIT
ARG TRAVIS_JOB_ID
ARG TRAVIS_JOB_NUMBER
ARG TRAVIS_OS_NAME
ARG TRAVIS_PULL_REQUEST
ARG TRAVIS_PULL_REQUEST_SHA
ARG TRAVIS_REPO_SLUG
ARG TRAVIS_TAG
ARG COVERALLS_TOKEN

ARG SKIP_TESTS
ARG SRC 

WORKDIR /src
ADD ${SRC} /src
ENV GO111MODULE=on

RUN echo "source=$SRC"

# run tests
RUN \
    if [ -z "$SKIP_TESTS" ] ; then \ 
    go test -v -mod=vendor -covermode=count -coverprofile=profile.cov ./...; \
    else echo "skip tests" ; fi


# linters
RUN if [ -z "$SKIP_TESTS" ] ; then \
    golangci-lint run --no-config --issues-exit-code=0 --deadline=5m \
    --disable-all --enable=deadcode --enable=gocyclo --enable=golint --enable=varcheck --enable=gosimple \
    --enable=structcheck --enable=errcheck --enable=dupl --enable=ineffassign --enable=staticcheck  \
    --enable=interfacer --enable=unconvert --enable=goconst --enable=gosec --enable=govet --enable=gocritic ; \
    else echo "skip  linters" ; fi


