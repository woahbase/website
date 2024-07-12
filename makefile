MODE      := docker ## run mode can be docker (or venv)
PORT      := 8000   ## port to listen on

# include targets as per mode
ifeq ($(MODE), docker)
	include docker.include.mk
# else ifeq ($(MODE), venv)
# 	include venv.include.mk
endif

## ---
## Target : Depends :Description
## ---

all: serve ## develop

build: CMD = build
build: run ## build static site

serve: CMD = serve -a 0.0.0.0:$(PORT) --watch-theme --clean
serve: run ## run dev server

deploy: deploy_netlify  ## deploy site

clean: # cleanup build artifacts
	rm -rf $(CURDIR)/site;

help : ## show this help
	@sed -ne '/@sed/!s/## /|/p' $(MAKEFILE_LIST) | sed -e's/\W*:\W*=/:/g' | column -et -c 3 -s ':|?=' #| sort -h
