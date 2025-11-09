#!/bin/bash

set -e

echo "Executing Raw Data Analysis Notebook..."

jupyter execute ./data/raw/analytics.ipynb

echo "Raw Data Analysis Notebook executed successfully!"

echo "Starting ETL process"
echo "\tETL Raw -> Silver..."

jupyter execute ./etl/etl_raw_to_silver.ipynb

echo "ETL process from Raw to Silver..."

jupyter execute ./etl/etl_slv_gold.ipynb
echo "\tETL Silver -> Gold..."

echo "ETL process completed successfully!"

echo "Starting Jupyter Lab..."

jupyter lab --NotebookApp.token='' --allow-root
