# Datsid
### Hooks for the editor to set the default target
current: target
-include target.mk

##################################################################

# make files

Sources = Makefile .gitignore README.md stuff.mk LICENSE.md
include stuff.mk
# include $(ms)/perl.def

Sources += notes.txt

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

## Testing scripting basics
Sources += script.sh
script.out: script.sh
	./$< > $@

check:
	Rscript glimpse.R xxx.db

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk

-include $(ms)/wrapR.mk
# -include $(ms)/oldlatex.mk
