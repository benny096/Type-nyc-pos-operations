# NYC POS Operations - Data Cleaning & Standardization Pipeline

## Overview
This repository contains a robust SQL data cleaning and preparation pipeline designed for raw Point of Sale (POS) transaction data from New York City restaurant operations. Built using MySQL Workbench, this project transforms messy transactional records into a clean, standardized format ready for operational reporting, financial auditing, and downstream data analysis.

Drawing on practical restaurant operations experience, this pipeline targets real-world data anomalies such as duplicate transactions, inconsistent string formatting, trailing punctuation, and missing relational attributes.

---

## Technical Stack & Skills Demonstrated
* **Database Management:** MySQL / MySQL Workbench
* **Advanced SQL Techniques:**
  * Window Functions (`ROW_NUMBER()`, `PARTITION BY`) for duplicate detection and removal
  * Common Table Expressions (CTEs) for multi-step staging transformations
  * Relational self-joins to impute and resolve missing categorical attributes
  * String manipulation functions (`TRIM()`, character replacement) for data standardization
* **Data Pipeline Architecture:** Raw Table $\rightarrow$ Staging Table $\rightarrow$ Production-Ready Cleaned Table

---

## Pipeline Workflow (`nyc_pos_ops_cleaning.sql`)

### 1. Staging and Schema Setup
To preserve raw source data integrity, the pipeline separates ingestion from transformation:
* **`pos_transactions`:** The raw database table capturing unformatted transaction logs.
* **`pos_staging` & `pos_staging2`:** Staging environments where data cleansing, standardization, and deduplication logic are executed.

### 2. Identifying and Removing Duplicate Records
Restaurant POS feeds can occasionally log duplicate inserts due to network latency or retried terminal requests. Using MySQL window functions, duplicates are identified across transaction keys and safely purged:
```sql
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY transaction_id, store_id, transaction_date, item_id, quantity, price
           ) AS row_num
    FROM pos_staging
)
DELETE FROM duplicate_cte
WHERE row_num > 1;
