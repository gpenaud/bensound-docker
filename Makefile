## permanent variables
.ONESHELL:
SHELL 			:= /bin/bash
PROJECT			?= github.com/gpenaud/bensound
RELEASE			?= $(shell git describe --tags --abbrev=0)
CURRENT_TAG ?= $(shell git describe --exact-match --tags 2> /dev/null)
COMMIT			?= $(shell git rev-parse --short HEAD)
BUILD_TIME  ?= $(shell date -u '+%Y-%m-%d_%H:%M:%S')

# ---------------------------------------------------------------------------- #
# 													 Containers Operations									           #
# ---------------------------------------------------------------------------- #

## Build bensound-webserver container
build:
	docker build --tag bensound-webserver .

## Start bensound-webserver container
up:
	docker run -it --name bensound-webserver bensound-webserver:latest
	# --entrypoint=/bin/bash

## Remove bensound-webserver container
down:
	docker rm --force bensound-webserver

## Enter in bensound container
enter:
	docker exec -it bensound-webserver /bin/bash

## Start, then log bensound stack locally
stack-up:
	docker compose up --build --detach
	docker compose logs --follow application

## Stop local alterconso stack
stack-down:
	docker compose down --volumes

## Enter in bensound container
stack-enter:
	docker compose exec application /bin/bash

## Launch, then enter in bensound container
stack-run-enter:
	docker compose run --entrypoint=/bin/bash application

# ---------------------------------------------------------------------------- #
# 													Certificates Operations									           #
# ---------------------------------------------------------------------------- #

## Install mkcert for self-signed certificates generation
certificates-install-mkcert:
	sudo apt install --yes libnss3-tools
	sudo wget -O /usr/local/bin/mkcert "https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64" && sudo chmod +x /usr/local/bin/mkcert
	mkcert -install

## Generate self-signed certificates
certificates-generate:
	mkcert -cert-file apache2/certificates/bensound-cert.pem -key-file apache2/certificates/bensound-key.pem bensound.localhost www.bensound.localhost
	chmod 0644 apache2/certificates/bensound-key.pem
	mkcert -cert-file apache2/certificates/phpmyadmin-cert.pem -key-file apache2/certificates/phpmyadmin-key.pem phpmyadmin.bensound.localhost
	chmod 0644 apache2/certificates/phpmyadmin-key.pem

## Colors
COLOR_RESET       = $(shell tput sgr0)
COLOR_ERROR       = $(shell tput setaf 1)
COLOR_COMMENT     = $(shell tput setaf 3)
COLOR_TITLE_BLOCK = $(shell tput setab 4)

## Display this help text
help:
	@printf "\n"
	@printf "${COLOR_TITLE_BLOCK}${PROJECT} Makefile${COLOR_RESET}\n"
	@printf "\n"
	@printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	@printf " make build\n\n"
	@printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	@awk '/^[a-zA-Z\-_0-9@]+:/ { \
				helpLine = match(lastLine, /^## (.*)/); \
				helpCommand = substr($$1, 0, index($$1, ":")); \
				helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
				printf " ${COLOR_INFO}%-29s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
		{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@printf "\n"
