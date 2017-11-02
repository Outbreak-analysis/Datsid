# Datsid
### Hooks for the editor to set the default target
current: target
-include target.mk

##################################################################

# make files

Sources = Makefile .gitignore README.md stuff.mk LICENSE.md
include stuff.mk
# include $(ms)/perl.def

##################################################################

## Content

Sources += $(wildcard *.R)

Sources += buildDBfromScratch.sh buildNewDB.sh

new.db: $(wildcard tables/*) buildDBfromScratch.sh
	-/bin/rm -f $@
	./$(filter %.sh, $^) $@

Sources += $(wildcard sql/*.sql)

## Make some plots
# Rscript plot_data.R $1

test:
	Rscript test.R

script.out: script.sh
	./$< > $@

check:
	Rscript glimpse.R xxx.db

######################################################################

### Makestuff

## Change this name to download a new version of the makestuff directory
# Makefile: start.makestuff

-include $(ms)/git.mk
-include $(ms)/visual.mk

-include $(ms)/wrapR.mk
# -include $(ms)/oldlatex.mk
