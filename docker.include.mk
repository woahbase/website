# this file is included when MODE is set to 'docker' in makefile

ifndef REGISTRY # ensure REGISTRY in env is prioritised over default
	REGISTRY := $(shell docker info -f '{{.IndexServerAddress}}'|awk -F[/:] '{print $$4}')# default is index.docker.io
endif

CNTNAME		:= docker_mkdocsmaterial
IMAGETAG	:= $(REGISTRY)/woahbase/alpine-mkdocsmaterial:9.6.11
PUID			:= $(shell id -u)
PGID			:= $(shell id -g)

RUNFLAGS  := \
		--hostname mkdocsmaterial \
		--name $(CNTNAME) \
		--workdir /home/alpine/project \
		-c 512 -m 256m \
		-e PGID=$(PGID) -e PUID=$(PUID) \
		-p $(PORT):$(PORT) \
		-v $(CURDIR):/home/alpine/project \
		-v /etc/hosts:/etc/hosts:ro \
		-v /etc/localtime:/etc/localtime:ro \
		#

# run: CMD = e.g build or serve
run: ## run with docker
	docker run --rm -i \
		$(RUNFLAGS) \
		$(IMAGETAG) \
		mkdocs $(CMD)

shell: ## get a shell with docker
	docker run --rm -it \
		$(RUNFLAGS) \
		$(IMAGETAG) \
		bash

test: build ## test static site with nginx
	docker run --rm \
		--name docker_nginx \
		-e PGID=$(PGID) \
		-e PUID=$(PUID) \
		-p 80:80 \
		-p 443:443 \
		-v $(CURDIR)/site:/config/www \
		$(REGISTRY)/woahbase/alpine-nginx

deploy_netlify:  ## deploy site to netlify (as draft unless $(PROD) is set)
	docker run --rm \
		--name docker_netlify \
		--workdir /home/alpine/project \
		-c 512 \
		-m 768m \
		-e NETLIFY_AUTH_TOKEN=$(if $(NETLIFY_AUTH_TOKEN),$(NETLIFY_AUTH_TOKEN),$(error NETLIFY_AUTH_TOKEN is not defined)) \
		-e NETLIFY_SITE_ID=$(if $(NETLIFY_SITE_ID),$(NETLIFY_SITE_ID),$(error NETLIFY_SITE_ID is not defined)) \
		-e PGID=$(PGID) \
		-e PUID=$(PUID) \
		-e S6_NPM_LOCAL_PACKAGES=netlify-cli \
		-e S6_NPM_PROJECTDIR=/home/alpine/project \
		-v $(CURDIR):/home/alpine/project \
		$(REGISTRY)/woahbase/alpine-nodejs \
		netlify \
		--telemetry-disable \
		deploy \
		--dir=site \
		--$(if $(PROD),prod,alias="draft-$${BUILDNUMBER:-manual}") \
		--message "Buildbot deploy $${BUILDNUMBER:-undefined}-$(shell date -u +%Y%m%d)" \
	#
