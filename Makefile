default: epidata.sqlite

%.sqlite: ingest.R data/*.csv
	# if %.sqlite doesn't exist, create it
	if [ ! -e $@ ]; then sqlite3 $@ < ./sql/create_tables.sql; fi
	# using ingest script ($<), insert into the target db ($@) all csvs which are newer than the db ($?)
	Rscript $< $@ $?