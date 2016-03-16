# tmp_data
Temporary repo showing a database example.

Run `Rscript read_IDDB.R`

To add data in the data base:
- if new disease add it in `table_disease` ('browse Data' in SqliteBrowser')
- if new location add it in `table_location`
- insert data in Excel spreadsheet template `table_epievent.xlsx` (make sure the first column `epieventid` is copied down)
- save Excel spreadsheet as a `csv` file (NO HEADERS & ONLY NEW DATA!)

`sqlite3 IDDB-test.db`
`sqlite> .mode csv`
`sqlite> .import path/foo.csv table_epievent`

