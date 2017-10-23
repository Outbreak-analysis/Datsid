Importing new data using Excel
=========

* 1/ Open (in read-only mode) the Excel spreadsheet `__table_epievent_template.xlsx` to enter the data in the format expected by the Excel pipeline. Some manual reformating work is probably necessary from the raw data.
* 2/ Save this Excel spreadsheet with an explicit name including disease, location, time frame.
* 3/ Add the name of this newly created spreadsheet to the list of spreadsheets in `__convert_to_csv.xlsm` and run the macro. This will make sure the csv file created has the correct format before being inserted in the SQLlite database.

