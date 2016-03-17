# tmp_data
Temporary repo showing a database example.


To add data in the data base:
- if new disease add it in `tables/table_disease.csv` 
- if new location add it in `tables/table_location.csv`
- insert data using Excel spreadsheet template `table_epievent_template.xlsx`
- save Excel spreadsheet as a `csv` file (NO HEADERS)

`buildNewDB xxx.db` creates a new database filled with data from csv files in `data` and `tables` folders.
