# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker base images for building and deploying Go applications. Three images provided:
- `ghcr.io/umputun/baseimage/buildgo` - Go build image with compiler, golangci-lint, moq, goreleaser, statik
- `ghcr.io/umputun/baseimage/app` - Alpine-based runtime with dumb-init, runs as non-root `app` user (uid 1001)
- `ghcr.io/umputun/baseimage/scratch` - Minimal scratch-based runtime (~512KB) with zoneinfo and CA certs

## Build Commands

```bash
# build all images locally
make all

# build individual images
make build_app       # base.alpine runtime
make build_go        # Go build image
make build_scratch   # scratch-based runtime

# multi-platform builds (amd64, arm64)
make build_app_multi
make build_go_multi
make build_scratch_multi
```

## Repository Structure

- `base.alpine/` - Alpine runtime image
  - `Dockerfile` - image definition
  - `files/init.sh` - entrypoint script, handles timezone, UID, and docker GID setup, drops to app user
  - `files/init-root.sh` - alternative entrypoint for root execution
- `base.scratch/` - Scratch runtime image (builds /nop wait program from C)
- `build.go/` - Go build image
  - `Dockerfile` - Go 1.26-alpine with tools (golangci-lint, moq, goreleaser, statik, goveralls)
  - `git-rev.sh` - parse git revision without .git/objects (for minimal builds)
  - `coverage.sh` - coverage reporting script
- `dk.sh` - debug helper: injects busybox shell into scratch containers

## CI/CD

Single GitHub Actions workflow (`.github/workflows/docker.yml`):
- PRs: build validation only (3 images × 2 platforms, no push)
- master/tags: build + push to ghcr.io and DockerHub
- Uses native ARM64 runners (ubuntu-24.04-arm) - no QEMU
- Parallel matrix: 3 images × 2 platforms (amd64, arm64)
- Tags: `master` for master branch, tag name + `latest` for version tags

## Version Bumping

Go build image version is controlled by env vars in `build.go/Dockerfile`:
- `GOLANGCI` - golangci-lint version
- `GORELEASER` - goreleaser version
- `GOVERALLS`, `STATIK` - other tool versions
- Base Go version in FROM directive (e.g., `golang:1.26-alpine`)
