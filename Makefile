.DEFAULT_GOAL := help
tidy: 
	go mod tidy

##@ Utility
linter: init-go ## Execute linters on codebase
	golangci-lint run --allow-parallel-runners --verbose --timeout=5m0s

format: init-go ## Format code using goimports and golines
	@echo "Formating .go files with golines"
	find . -name '*.go' -not -path "./vendor/*" -exec golines -m 100 --shorten-comments -t 4 -w {} \;

gosec: init-go ## Execute gosec safe-coding scan
	@echo "Running gosec..."
	gosec --quiet run --exclude-dir=vendor --timeout=3m0s ./...

check: tidy format ## Check code quality before commit
	pre-commit run --all-files

cover: test ## Run the go test with coverage
	go tool cover -func coverage.out | grep 'total'

cover-html: test ## Run the go test with html coverage
	go tool cover -html coverage.out -o coverage.html


# In the go test command below the ellipsis is a wildcard syntax that matches all sub-dirs. Also, -count=1 disables caching.
test-pkg: ## Check unit test with package level coverage
	go install github.com/mfridman/tparse@latest
	$(MAKE) tidy
	go test ./... -coverprofile coverage.out  -cover -json | tparse -all

test: test-pkg show_coverage ## Check unit test with package level and total coverage

# Run 'make init' the first time you are doing development
init: init-go ## Run this to install dependencies
	python3 -m pip install --upgrade pip
	python3 -m pip install pre-commit setuptools setuptools-rust
	# Install rust, required to install detect-secrets
	curl https://sh.rustup.rs -sSf | sh -s -- -y
	# shellcheck disable=SC1090,SC3046
	$(source ~/.cargo/env)
	# Install detect-secrets
	python3 -m pip install --upgrade git+https://github.com/ibm/detect-secrets.git@0.13.1+ibm.61.dss#egg=detect-secrets
	pre-commit install
	pre-commit install-hooks

init-go: tidy ## Install golang dependencies and utilities
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.54.0
	go install github.com/securego/gosec/v2/cmd/gosec@v2.16.0
	go install golang.org/x/tools/cmd/goimports@v0.7.0
	go install github.com/segmentio/golines@v0.11.0
	go install github.com/mfridman/tparse@latest	

show_coverage: ## Show total test coverage
	@echo "COVERAGE: "`go tool cover -func coverage.out | grep total | awk '{print $$3}'`

help:  ## Display this help.
ifeq ($(OS),Windows_NT)
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  %-40s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
else
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
endif