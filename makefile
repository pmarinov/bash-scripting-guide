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
pages-web := $(patsubst pages/%, web/%, $(pages-html))
# Special case: remove page0.html (replace with en empty strng)
pages-web := $(pages-web:web/page0.html=)

# The ‘all’ rule references the rules BELOW it (the above are just variable
# definitions, not rules).
all: $(pages-sourcelistings) $(pages-html) style.css $(pages-web) web/index.html web/style.css \
    page0.info home/bash-scripting-guide.info home/index.html
all: ## Re-generate book (HTML and INFO)

style.css: style.css.pp
	@echo "[" $@ "]"
	raco pollen render $<

$(pages-html): $(core-files) template.html.p
$(pages-html): %.html: %.poly.pm
	@echo "[" $@ "]"
	raco pollen render -t html $<

web/style.css: style.css
	mkdir -p web
	cp -p style.css web/style.css

# Special case: transfer page0.html as index.html
web/index.html: pages/page0.html
	mkdir -p web
	sed -e 's~../style.css~style.css~' -e 's~page0~index~' $< > $@

# HTML rendering for the web
$(pages-web): web/%.html: pages/%.html
	mkdir -p web
	sed -e 's~../style.css~style.css~' -e 's~page0~index~' $< > $@

# Info pages: First the texi files
$(pages-texi): $(core-files) template.texi.p
$(pages-texi): %.texi: %.poly.pm
	@echo "[" $@ "]"
	raco pollen render -t texi $<

# Info pages: Compile the texi into info
page0.info: $(pages-texi)
	makeinfo --no-split pages/page0.texi

# Home page folder on the web
home/bash-scripting-guide.info: page0.info
	mkdir -p home
	cp -v page0.info $@

# The info file will be available from the home page
home/index.html: home.html
	mkdir -p home
	cp -v home.html $@

zap: ## Resets Pollen cache, ereases all generated file (.html, .texi, .info, and .txt files)
	$(call del,./pages,"*.txt")
	$(call del,./pages,"*.html")
	$(call del,./home,"*.html")
	$(call del,./home,"*.info")
	$(call del,./web,"*.html")
	$(call del,./web,"style.css")
	$(call del,./pages,"*.texi")
	$(call del,.,"page0.info")
	raco pollen reset

# Self-documenting make file (http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)
help: ## Displays this help screen
	@sed -E -n -e "s%^([a-zA-Z_ ]+:).*## (.*)%${BOLD}\1${NC}\t\2%p" makefile

.DEFAULT_GOAL := help
