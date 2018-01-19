OWNER := woahbase

data :
	mkdir -p $(CURDIR)/static/json/ \
		&& curl -o $(CURDIR)/static/json/docker.json -jkSL 'https://hub.docker.com/v2/repositories/$(OWNER)/?page_size=500&tags=true' \
		&& curl -o $(CURDIR)/static/json/github.json -jkSL 'https://api.github.com/users/$(OWNER)/repos?type=all&sort=updated' \
		&& [[ -d $(CURDIR)/dist ]] \
		&& mkdir -p $(CURDIR)/dist/static/json/ \
		&& cp $(CURDIR)/static/json/docker.json $(CURDIR)/dist/static/json/docker.json \
		&& cp $(CURDIR)/static/json/github.json $(CURDIR)/dist/static/json/github.json;
	git commit -am "Data updated at $$(date)";
	git push origin master;
