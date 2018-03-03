scrape :
	dovue "-- node ./src/scraper.js"

dev :
	dovue "-- npm run dev"

build :
	dovue "-- npm run build"

data :
	git commit -am "Data updated at $$(date)"
	git push origin master;

.PHONY : build
