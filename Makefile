run-test: s3proxy.jar
	./test/run-tests.sh

s3proxy.jar:
	wget https://github.com/gaul/s3proxy/releases/download/s3proxy-1.7.0/s3proxy -O s3proxy.jar

get-deps: s3proxy.jar
	go get -t ./...

appname := goofys

sources := $(wildcard *.go)

COMMIT ?= $(shell git rev-parse HEAD)
LDFLAGS ?= -X main.Version=${COMMIT}

build = CGO_ENABLED=0 GOOS=$(1) GOARCH=$(2) go build -ldflags "$(LDFLAGS)" -o build/$(appname)
tar = cd build && tar -cvzf $(1)_$(2).tar.gz $(appname)$(3) && rm $(appname)$(3)
zip = cd build && zip $(1)_$(2).zip $(appname)$(3) && rm $(appname)$(3)

build: linux_build arm_build arm64_build

linux_build: $(sources)
	$(call build,linux,amd64)
	$(call tar,linux,amd64)

arm_build: $(sources)
	$(call build,linux,arm)
	$(call tar,linux,arm)

arm64_build: $(sources)
	$(call build,linux,arm64)
	$(call tar,linux,arm64)

install:
	go install -ldflags "-X main.Version=`git rev-parse HEAD`"
