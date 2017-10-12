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

Sources += buildNewDB.sh
xxx.db: $(wildcard tables/*) buildNewDB.sh
	/bin/rm -f $@
	./buildNewDB.sh xxx.db

## Make some plots
# Rscript plot_data.R $1

test:
	Rscript test.R

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
