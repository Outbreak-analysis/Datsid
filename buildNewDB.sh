#!/bin/bash
cd $(dirname $0) 

## Check tables
Rscript table_checks.R

## Download & reformat data for tables
./data/raw-data/create-data-for-db.sh

## Make the database structure
sqlite3 $1 < ./sql/create_tables.sql

## Fill in data from data/ directory
Rscript fill_epievents.R $1

## Make some plots
Rscript plot_data.R $1
