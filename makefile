OWNER := woahbase

data :
	mkdir -p $(CURDIR)/static/json/ \
		&& curl -o $(CURDIR)/static/json/docker.json -jkSL 'https://hub.docker.com/v2/repositories/$(OWNER)/?page_size=500&tags=true' \
		&& curl -o $(CURDIR)/static/json/github.json -jkSL 'https://api.github.com/orgs/$(OWNER)/repos' \
		&& [[ -d $(CURDIR)/dist ]] \
		&& mkdir -p $(CURDIR)/dist/static/json/ \
		&& cp $(CURDIR)/static/json/docker.json $(CURDIR)/dist/static/json/docker.json \
		&& cp $(CURDIR)/static/json/github.json $(CURDIR)/dist/static/json/github.json
