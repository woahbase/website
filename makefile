# run mode can be venv or docker
MODE      := docker
PORT      := 8000

# include targets as per mode
ifeq ($(MODE), docker)
	include docker.include.mk
else ifeq ($(MODE), venv)
	include venv.include.mk
endif

all: serve

build: CMD = build
build: run ## build static site

serve: CMD = serve -a 0.0.0.0:$(PORT) --watch-theme --clean
serve: run ## run dev server

deploy: deploy_netlify

clean:
	rm -rf $(CURDIR)/site;

# fonts source: https://gwfh.mranftl.com/
