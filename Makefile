GOCMD=go
GOTEST=$(GOCMD) test
GOVET=$(GOCMD) vet
BINARY_NAME=qr-gen
SRC_NAME=qr-gen
BIN_DIR=bin
RM=@rm -f
CP=@cp
MV=@mv

VERSION?=0.1.0

README_FILE=README.md

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all test build package

all: help

## Build:
build: ## Build your project and put the output binary into local dir
	GOARCH=amd64 GOOS=darwin go build -o ${BINARY_NAME}-darwin-x86_64 ${SRC_NAME}
	GOARCH=amd64 GOOS=linux go build -o ${BINARY_NAME}-linux ${SRC_NAME}
	GOARCH=amd64 GOOS=windows go build -o ${BINARY_NAME}-windows ${SRC_NAME}
	GOARCH=arm64 GOOS=darwin go build -o ${BINARY_NAME}-darwin-arm64 ${SRC_NAME}

macos: ## Build only macOS ARM64 binaries and put the output binary into ./pkg/ directory
	GOARCH=arm64 GOOS=darwin go build -o ${BINARY_NAME}-darwin-arm64 ${SRC_NAME}
	${CP} ${BINARY_NAME}-darwin-arm64 ./${BIN_DIR}/${BINARY_NAME}
	${RM} ${BINARY_NAME}-darwin-arm64

package: ## Package your project and put the output binary into local dir
	${CP} ${BINARY_NAME}-{darwin-x86_64,linux,windows,darwin-arm64} ./${BIN_DIR}/
	${RM} ${BINARY_NAME}-{darwin-x86_64,linux,windows,darwin-arm64}
	${MV} ${BIN_DIR}/${BINARY_NAME}-windows ${BIN_DIR}/${BINARY_NAME}-windows.exe

run: build package
	./${BINARY_NAME}

clean: ## Remove build related file
	@go clean
	${RM} ${BIN_DIR}/${BINARY_NAME}-darwin-x86_64
	${RM} ${BIN_DIR}/${BINARY_NAME}-linux
	${RM} ${BIN_DIR}/${BINARY_NAME}-windows*
	${RM} ${BIN_DIR}/${BINARY_NAME}-darwin-arm64

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
