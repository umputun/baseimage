# baseimage [![Docker Automated build](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/umputun/baseimage/) [![Build Status](https://travis-ci.org/umputun/baseimage.svg?branch=master)](https://travis-ci.org/umputun/baseimage)

_minimalist docker base image to build and deploy my services and applications._

Two images included:

1. go build image - `umputun/baseimage:buildgo-latest`. For build stage, includes go compiler and linters. Alpine based.
2. base application image `umputun/baseimage:app-latest`
