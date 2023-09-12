GOCMD=go
GOTEST=$(GOCMD) test
GOVET=$(GOCMD) vet
BINARY_NAME=qr-gen
SRC_NAME=qr-gen.go
BIN_DIR=bin

VERSION?=0.1.0

README_FILE=README.md

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all test build vendor

all: help

## Build:
build: ## Build your project and put the output binary into local dir
	GOARCH=amd64 GOOS=darwin go build -o ${BINARY_NAME}-darwin-x86_64 ${SRC_NAME}
	GOARCH=amd64 GOOS=linux go build -o ${BINARY_NAME}-linux ${SRC_NAME}
	GOARCH=amd64 GOOS=windows go build -o ${BINARY_NAME}-windows ${SRC_NAME}
	GOARCH=arm64 GOOS=darwin go build -o ${BINARY_NAME}-darwin-arm64 ${SRC_NAME}

macos: ## Build only macOS ARM64 binaries and put the output binary into ./pkg/ directory
	GOARCH=arm64 GOOS=darwin go build -o ${BINARY_NAME}-darwin-arm64 ${SRC_NAME}
	cp ${BINARY_NAME}-darwin-arm64 ./${BIN_DIR}/${BINARY_NAME}
	rm ${BINARY_NAME}-darwin-arm64
	cp ${CONFIG_FILE} ./${BIN_DIR}/${CONFIG_FILE}
	cp ${README_FILE} ./${BIN_DIR}/${README_FILE}

package: ## Package your project and put the output binary into local dir
	cp ${BINARY_NAME}-{darwin-x86_64,linux,windows,darwin-arm64} ./${BIN_DIR}/
	rm ${BINARY_NAME}-{darwin-x86_64,linux,windows,darwin-arm64}

run: build package
	./${BINARY_NAME}

clean: ## Remove build related file
	go clean
	rm ${BINARY_NAME}-darwin-x86_64
	rm ${BINARY_NAME}-linux
	rm ${BINARY_NAME}-windows
	rm ${BINARY_NAME}-darwin-arm64

vendor: ## Copy of all packages needed to support builds and tests in the vendor directory
	$(GOCMD) mod vendor

## Test:
test: ## Run the tests of the project
	go test ./...

test_coverage:
	go test ./... -coverprofile=coverage.out

## Other:
dep: ## Get the dependencies
	go mod download

vet:
	go vet

lint:
	golangci-lint run --enable-all

## Help:
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
