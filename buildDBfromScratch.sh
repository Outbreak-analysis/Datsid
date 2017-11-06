#!/bin/bash
cd $(dirname $0) 

## Check tables for duplicates, etc.
Rscript table_checks.R

## Download & reformat data for tables
## data/raw-data/create-data-for-db.R 
(cd data/raw-data/ && Rscript create-data-for-db.R)

## Make the database structure
sqlite3 $1 < ./sql/create_tables.sql

## Fill in data from data/ directory
Rscript fill_epievents.R $1

## Summary of this new database
./glimpse $1
