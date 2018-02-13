TARGET=raw.csv
RAW_URL=https://www.cdc.gov/vhf/ebola/csv/graph1-cumulative-reported-cases-all.xlsx
XLS_FILE=ebola-west-africa-2014-USCDC.xlsx

csv_file: raw_data $(TARGET)

raw_data: $(XLS_FILE)

$(XLS_FILE):
	curl -o $@ $(RAW_URL)

raw.csv:
	Rscript raw_csv.R $(XLS_FILE) $@

clean:
	rm -f $(TARGET)
	rm -f $(XLS_FILE)
