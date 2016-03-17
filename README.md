# tmp_data
Temporary repo showing a database example.


To add data in the data base:
- if new disease add it in `tables/table_disease.csv` 
- if new location add it in `tables/table_location.csv`
- if new epidemiological data (incidence,etc.):
  - insert data using Excel spreadsheet template `table_epievent_template.xlsx` (Warning: date must be string formated as yyyy-mm-dd)
  - save Excel spreadsheet as a `csv` using the macro in `__convert_to_csv.xlsm`

`buildNewDB xxx.db` creates a new database filled with data from csv files in `data` and `tables` folders.
