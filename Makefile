export TIME_ZONE := America/Chicago

all: build_app build_go

build_app:
	docker build --pull --build-arg TIME_ZONE=${TIME_ZONE} -t umputun/baseimage:app-latest base.alpine -f base.alpine/Dockerfile

build_go:
	docker build --pull --build-arg TIME_ZONE=${TIME_ZONE} -t umputun/baseimage:buildgo-latest build.go -f build.go/Dockerfile


.PHONY: all