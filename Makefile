MAIN_VERSION:=$(shell git describe --abbrev=0 --tags || echo "0.1.0")
VERSION:=${MAIN_VERSION}\#$(shell git log -n 1 --pretty=format:"%h")
PACKAGES:=$(shell go list ./... | sed -n '1!p' | grep -v /vendor/)
LDFLAGS:=-ldflags "-X github.com/quantumew/builder/app.Version=${VERSION}"
TAG:=aufait-builder

default: run

depends:
	go get .

test:
	echo "mode: count" > coverage-all.out
	$(foreach pkg,$(PACKAGES), \
		go test -p=1 -cover -covermode=count -coverprofile=coverage.out ${pkg}; \
		tail -n +2 coverage.out >> coverage-all.out;)

cover: test
	go tool cover -html=coverage-all.out

run:
	go run ${LDFLAGS} server.go

build: clean
	go build ${LDFLAGS} -a -o "builds/${GOOS}/builder" server.go

docker:
	docker build --cache-from ${TAG}:latest --tag ${TAG} .

clean:
	rm -rf coverage.out coverage-all.out
