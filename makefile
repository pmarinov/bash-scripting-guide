# makefile
#
# Based on ideas by Joel Dueck, see: https://github.com/otherjoel/try-pollen

SHELL = /bin/bash

zap: ## Resets Pollen cache, deletes LaTeX working folders, feed.xml and all .html, .ltx files
	rm pages/*.html pages/*.texi pages/*.txt; \
	rm template.texi template.html \
	rm page0.info; \
	raco pollen reset

# Self-documenting make file (http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)
help: ## Displays this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
