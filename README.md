# NYC POS Operations - Data Cleaning, Standardization & EDA Pipeline

## Overview
This repository contains two end-to-end SQL data cleaning, preparation, and Exploratory Data Analysis (EDA) pipelines designed for raw Point of Sale (POS) transaction data from New York City restaurant operations. Built using MySQL Workbench, these projects transform messy transactional records into clean, standardized formats ready for operational reporting, financial auditing, and downstream data analysis.

Drawing on practical restaurant operations experience, these pipelines target real-world data anomalies such as duplicate transactions, inconsistent string formatting, currency symbols stored as text, negative quantities, mixed date formats, and missing relational attributes.

---

## Repository Files

| File Name | Description |
| :--- | :--- |
| **`nyc_pos_ops_cleaning.sql`** | **Project 1:** Data cleaning and standardization pipeline for multi-borough NYC POS transaction logs (`pos_transactions`), featuring staging tables, window-function deduplication, string trimming, self-join imputation, and type casting. |
| **`restaurant_audit_v2_cleaning.sql`** | **Project 2:** Full ETL data cleaning script + Exploratory Data Analysis (EDA) for multi-unit pizzeria operations (`restaurant_audit_v2`), auditing store performance and menu item revenue across Astoria and Manhattan locations. |

---

## Technical Stack & Skills Demonstrated
- **Database Management:** MySQL 8.0 / MySQL Workbench
- **Advanced SQL Techniques:**
  * Window Functions (`ROW_NUMBER()`, `PARTITION BY`) for duplicate detection and removal
  * Common Table Expressions (CTEs) & Staging Tables for multi-step transformations
  * Relational self-joins to impute and resolve missing categorical attributes
  * String & Numerical manipulation (`TRIM()`, `REPLACE()`, `ABS()`, `LIKE`) for standardization
  * Date parsing (`STR_TO_DATE()`, `DATE_FORMAT()`) across mixed input formats
  * Exploratory Data Analysis (`SUM()`, `COUNT(DISTINCT)`, `ROUND()`, `GROUP BY`, `ORDER BY`)
- **Data Pipeline Architecture:** Raw Table -> Staging Table 1 -> Staging Table 2 (Deduplicated & Cleaned) -> EDA Queries

---

## Project 1: Pipeline Workflow (`nyc_pos_ops_cleaning.sql`)

### 1. Staging and Schema Setup
To preserve raw source data integrity, the pipeline separates ingestion from transformation:
- **`pos_transactions`:** The raw database table capturing unformatted transaction logs.
- **`pos_staging` & `pos_staging2`:** Staging environments where data cleansing, standardization, and deduplication logic are executed.

### 2. Identifying and Removing Duplicate Records
Restaurant POS feeds occasionally log duplicate inserts due to network latency or retried terminal requests. Using `ROW_NUMBER()` over partitioned transaction keys in `pos_staging2`, duplicates (`row_num > 1`) are isolated and safely purged.

### 3. String Standardization, Imputation & Type Casting
- Trimmed leading/trailing whitespace and stripped trailing punctuation (`TRIM(TRAILING '.' FROM ...)`).
- Populated missing cuisine/category attributes across matching store records via relational self-joins.
- Normalized text dates into standard SQL `DATE` format and dropped temporary helper columns.

---

## Project 2: Pipeline & Exploratory Data Analysis (`restaurant_audit_v2_cleaning.sql`)

### 1. Data Cleaning & Standardization (`messy_staging2`)
- **Deduplication:** Partitioned rows by `order_id`, `store_location`, and `item_name` using `ROW_NUMBER()` to delete duplicate POS entries.
- **Text Normalization:** Standardized store locations (`Astoria`, `Manhattan`), menu items (`Large Cheese Pie`, `Pepperoni Pizza`, `Garlic Knots`, `Soda (2L)`), and payment types (`Cash`, `Credit Card`).
- **Financial & Numerical Sanitization:** Stripped `$` symbols from `order_total` and cast to `DECIMAL(10,2)`; converted negative quantity errors to positive integers using `ABS(quantity)`.
- **Date Standardization:** Converted `'Invalid Date'` entries to `NULL` and unified `MM/DD/YYYY`, `YYYY/MM/DD`, and `MM-DD-YYYY` strings into native SQL `DATE` (`YYYY-MM-DD`).

### 2. Exploratory Data Analysis (EDA) Results

#### Overall Business Summary
* **Total Unique Orders:** 25
* **Total Items Sold:** 49
* **Total Revenue:** **$652.50**
* **Average Order Value (AOV):** **$26.10**

#### Store Location Performance
| Store Location | Total Orders | Store Revenue | Revenue Share |
| :--- | :--- | :--- | :--- |
| **Astoria** | 17 | **$475.00** | 72.8% |
| **Manhattan** | 8 | **$177.50** | 27.2% |

#### Menu Item Performance
| Item Name | Units Sold | Item Revenue |
| :--- | :--- | :--- |
| **Large Cheese Pie** | 13 | **$292.50** |
| **Pepperoni Pizza** | 12 | **$270.00** |
| **Garlic Knots** | 12 | **$60.00** |
| **Soda (2L)** | 12 | **$30.00** |
