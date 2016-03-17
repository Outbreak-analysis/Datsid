# tmp_data
Temporary repo showing a database example.

Overview
========
This repo provides scripts that can build from scratch a SQLite database. 
Before it can be built, epidemiological time series of incidence, deaths, etc. must be saved in the the _correct format_ in the `data` folder. Also, information regarding diseases and geographical locations must be saved in the `tables` folder. 


Structure
========
 * `data` folder contains the `.csv` files containing the epidemiological data that populates the database. Note there are also Excel spreadsheets that were used to generate the `csv` files using a macro in `__convert_to_csv.xlsm`. The spreadsheet `__table_epievent_template.xlsx` provides a template for importing (and manipulating) new data.
 * `tables` folder specify

To add data in the data base:
- if new disease add it in `tables/table_disease.csv` 
- if new location add it in `tables/table_location.csv`
- if new epidemiological data (incidence,etc.):
  - insert data using Excel spreadsheet template `table_epievent_template.xlsx` (Warning: date must be string formated as yyyy-mm-dd)
  - save Excel spreadsheet as a `csv` using the macro in `__convert_to_csv.xlsm`

Executables
===========
`buildNewDB xxx.db` creates a new database filled with data from csv files in `data` and `tables` folders.
