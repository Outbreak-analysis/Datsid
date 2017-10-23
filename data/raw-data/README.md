## Execution


## Conventions
* -web.R script to download data when possible
* -raw.csv for downloaded data
* -info.csv is human-readable metadata (but complicated)
* -reformat.R converts input csvs to final version:
	* -db.csv


Some data sets cannot be downloaded directly with a script from the web, so they are downloaded manually and saved as a `-raw.csv` file. These datasets are:
* influenza-france-sentinelles-1985-2017 (downloaded Oct 2017. Approximate URL is in the header. Haven’t figured out yet how to download automatically, may require posting or something.)
* ((add other))


## Miscelleanous

_utils.R implements useful functions. 
