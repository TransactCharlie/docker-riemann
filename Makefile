VERSION=0.2.14
APP_NAME=transactcharlie/riemann
# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help clean

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := build

# DOCKER TASKS
dockerBuild: ## Build the container
	docker build \
		-t $(APP_NAME) \
		-t $(APP_NAME):$(VERSION) \
		.

build: dockerBuild
