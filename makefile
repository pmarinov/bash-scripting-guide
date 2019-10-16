# makefile
#
# Based on ideas by Joel Dueck, see: https://github.com/otherjoel/try-pollen

SHELL = /bin/bash

# ANSI encoded colors for the help screen
BOLD = \x1b[1m
NC = \x1b[0m

# Function: `del' => $1: folder, $2: file glob
# (surround glob in double quotes when invoking)
del = find $(1) -name $(2) -exec rm -v {} \;

# Source files
core-files := pollen.rkt index.ptree
pages-sourcefiles := $(wildcard pages/*.poly.pm)

# Target files
pages-html := $(patsubst %.poly.pm,%.html,$(pages-sourcefiles))
pages-texi := $(patsubst %.poly.pm,%.texi,$(pages-sourcefiles))

# The ‘all’ rule references the rules BELOW it (the above are just variable
# definitions, not rules).
all: $(pages-sourcelistings) $(pages-html) style.css page0.info
all: ## Re-generate book (HTML and INFO)

style.css: style.css.pp
	raco pollen render $<

$(pages-html): $(core-files) template.html.p
$(pages-html): %.html: %.poly.pm
	raco pollen render -t html $<

$(pages-texi): $(core-files) template.texi.p
$(pages-texi): %.texi: %.poly.pm
	raco pollen render -t texi $<

page0.info: $(pages-texi)
	makeinfo pages/page0.texi

zap: ## Resets Pollen cache, ereases all generated file (.html, .texi, .info, and .txt files)
	$(call del,.,"*.txt")
	$(call del,.,"*.html")
	$(call del,.,"*.texi")
	$(call del,.,"*.info")
	raco pollen reset

# Self-documenting make file (http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)
help: ## Displays this help screen
	@sed -E -n -e "s%^([a-zA-Z_ ]+:).*## (.*)%${BOLD}\1${NC}\t\2%p" makefile

.DEFAULT_GOAL := help
