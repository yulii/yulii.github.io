.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:  ## Build docker images
	docker-compose build

bundle:  ## Install dependencies
	docker-compose run app bundle

serve: bundle  ## Run server
	docker-compose up

timestamp:
	date '+%Y-%m-%dT%H:%M:%S%z'

generate:  ## Generate category and tag pages
	docker-compose run app bin/generate

clean:  ## Remove all images and volumes
	docker-compose down --rmi all --volumes

setup: build bundle  ## Setup current project
