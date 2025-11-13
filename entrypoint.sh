#!/bin/bash

set -e

echo "Executing Raw Data Analysis Notebook..."

jupyter execute ./data_layer/raw/analytics.ipynb

echo "Raw Data Analysis Notebook executed successfully!"

echo "Starting ETL process from Raw to Silver..."

jupyter execute ./transformer/etl/raw_to_silver.ipynb

echo "Starting ETL process from Silver to Gold..."

jupyter execute ./transformer/etl/silver_to_gold.ipynb

echo "ETL process completed successfully!"

echo "Starting Jupyter Lab..."

jupyter lab --NotebookApp.token=''
