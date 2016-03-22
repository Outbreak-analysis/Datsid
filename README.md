**Da**tabase of **t**ime **s**eries of **i**nfectious **d**iseases (Datsid)

Overview
========
This repo provides scripts that can build from scratch a SQLite database. 
The database is built from epidemiological time series of incidence, deaths, etc. that must be saved in the the _correct format_ in the `data` folder. Information regarding the tables of the database (e.g., diseases, geographical locations) must be entered beforehand (in the `tables` folder). 


Structure
========
 * `data` folder contains the `.csv` files containing the epidemiological data that populates the database. Note there are also Excel spreadsheets that were used to generate the `csv` files using a macro in `__convert_to_csv.xlsm`. The spreadsheet `__table_epievent_template.xlsx` provides a template for importing (and manipulating) new data. The format for `csv` files is without headers and as many columns as there are in the `table_epievent` table (discarding the first column which consists of unique IDs).
 * `tables` folder specifying the SQL tables.

To add data in the data base:
- if new disease add it in `tables/table_disease.csv` 
- if new location add it in `tables/table_location.csv`
- if new epidemiological data (incidence,etc.):
  - insert data using Excel spreadsheet template `table_epievent_template.xlsx` (Warning: date must be string formated as yyyy-mm-dd)
  - save Excel spreadsheet as a `csv` using the macro in `__convert_to_csv.xlsm`
- two options:
  - to add this new data set to an existing database, execute `add_timeseries xxx.db yyy.csv` to include in the existing database `xxx.db` data saved in `yyy.csv`.
  - to rebuild the _whole_ database, execute `buildNewDB xxx.db` (create a new database (named `xxx.db`) filled with data from all csv files in `data` and `tables` folders)


