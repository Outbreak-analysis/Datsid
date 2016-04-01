# Goals

 - consistent database format
 - updates by just adding formatted files to input source directories + make
 - input files should NOT NEED to know about database labels (that is, primary keys)
 - input checking
 - convenience access functions

# Anti-Goals

 - handling translation from raw data format into ingest format

# Schema Modifications

 - changed schema to read more like English when written.  For example, in previous schema:
```
SELECT disease_name FROM table_disease WHERE disease_id==1;
```
has way too much disease.  Reads more naturally as
```
SELECT name FROM disease WHERE id==1;
```
Another (extended example):
```
SELECT eventtype, disease_name FROM table_epievent, table_disease WHERE table_epievent.disease_id == table_disease.disease_id AND table_disease.disease_id == 42;
```
versus
```
SELECT epievent.type, disease.name FROM epievent, disease WHERE epievent.disease_id == disease.id AND disease.id == 42;
```
 - TODO: for locations, switch from adjacency list to nested interval (https://communities.bmc.com/docs/DOC-9902)
 - TODO: for diseases, switch from adjacency list to nested interval (https://communities.bmc.com/docs/DOC-9902)