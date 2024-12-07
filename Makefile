all: build_app build_go build_scratch

build_app:
	docker build --pull -t umputun/baseimage:app-latest base.alpine -f base.alpine/Dockerfile

build_app_multi:
	docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64 --pull -t umputun/baseimage:app-latest base.alpine -f base.alpine/Dockerfile

build_go:
	docker build --pull -t umputun/baseimage:buildgo-latest build.go -f build.go/Dockerfile

build_go_multi:
	docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64  --pull -t umputun/baseimage:buildgo-latest build.go -f build.go/Dockerfile

build_scratch:
	docker build --pull -t umputun/baseimage:scratch-latest build.go -f base.scratch/Dockerfile

build_scratch_multi:
	docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64  --pull -t umputun/baseimage:scratch-latest build.go -f base.scratch/Dockerfile

.PHONY: all
