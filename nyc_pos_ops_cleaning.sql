USE nyc_pos_ops;

DROP TABLE IF EXISTS pos_transactions;

CREATE TABLE pos_transactions (
    restaurant_name TEXT,
    borough TEXT,
    cuisine_type TEXT,
    daily_orders INT DEFAULT NULL,
    tax_percentage TEXT,
    `date` TEXT,
    pos_system TEXT,
    account_status TEXT,
    daily_revenue INT DEFAULT NULL
);

INSERT INTO pos_transactions VALUES
('Mario Famous Pizza', 'Queens', 'Pizza', 145, '0.0887', '10/15/2026', 'Toast', 'Active', 4200),
('Mario Famous Pizza', 'Queens', 'Pizza', 145, '0.0887', '10/15/2026', 'Toast', 'Active', 4200),
('Andiamo Brick Oven', 'Manhattan', 'Pizza', 210, '0.0887', '10/16/2026', 'Square', 'Active', 6800),
('Andiamo Brick Oven', 'Manhattan', 'Pizza', 210, '0.0887', '10/16/2026', 'Square', 'Active', 6800),
('Wall Street Deli', 'Manhattan', 'Deli', 180, '0.0887', '10/17/2026', 'Clover', 'Active', 3100),
('Wall Street Deli', 'Manhattan', 'Deli', 180, '0.0887', '10/17/2026', 'Clover', 'Active', 3100),
('Astoria Slice Shop', 'Queens', 'Pizza', 120, '0.0887', '10/17/2026', 'Toast', 'Active', 3400),
('Astoria Slice Shop', 'Queens', 'Pizza', 120, '0.0887', '10/17/2026', 'Toast', 'Active', 3400),
('  Astoria Slice Shop ', 'Queens', 'Pizza', 110, '0.0887', '10/18/2026', 'Toast', 'Active', 2900),
('   FiDi Espresso Bar', 'Manhattan', 'Coffee & Cafe', 320, '0.0887', '10/18/2026', 'Square', 'Active', 2400),
('Brooklyn Bagel Co   ', 'Brooklyn', 'Bakery', 290, '0.0887', '10/19/2026', 'SpotOn', 'Active', 3500),
('  Midtown Gyro Cart  ', 'Manhattan', 'Mediterranean', 150, '0.0887', '10/19/2026', 'Clover', 'Active', 2800),
('Ditmars Oven', 'Queens.', 'Pizza Pie', 165, '0.0887', '10/20/2026', 'Toast', 'Active', 4900),
('Broadway Pizzeria', 'Queens.', 'PIZZA', 130, '0.0887', '10/21/2026', 'Slice', 'Active', 3800),
('Tribeca Crust', 'Manhattan', 'Pizza_Restaurant', 195, '0.0887', '10/21/2026', 'Toast', 'Active', 6100),
('Queens Blvd Halal', 'Queens.', 'Mediterranean', 140, '0.0887', '10/22/2026', 'Clover', 'Active', 2700),
('Steinway Cafe', 'Queens.', 'Coffee & Cafe', 205, '0.0887', '10/22/2026', 'Square', 'Active', 3150),
('Mario Famous Pizza', 'Queens', '', 160, '0.0887', '10/23/2026', 'Toast', 'Active', 4650),
('Andiamo Brick Oven', 'Manhattan', NULL, 225, '0.0887', '10/24/2026', 'Square', 'Active', 7100),
('Brooklyn Bagel Co', 'Brooklyn', '', 305, '0.0887', '10/25/2026', 'SpotOn', 'Active', 3750),
('Ditmars Oven', 'Queens', NULL, 172, '0.0887', '10/25/2026', 'Toast', 'Active', 5100),
('Ghost Kitchen NYC', 'Bronx', 'Burgers', NULL, NULL, '10/26/2026', 'Toast', 'Pending', NULL),
('Test Store Account', 'Manhattan', 'Pizza', NULL, NULL, '10/27/2026', 'Square', 'Pending', NULL),
('Closed Demo Account', 'Brooklyn', 'Deli', NULL, NULL, '10/27/2026', 'Clover', 'Inactive', NULL),
('Sitan Thai Kitchen', 'Queens', 'Thai', 95, '0.0887', '10/28/2026', 'Toast', 'Active', 3300),
('Jay Street Diner', 'Brooklyn', 'Diner', 175, '0.0887', '10/29/2026', 'SpotOn', 'Active', 4400),
('Fulton Street Slices', 'Manhattan', 'Pizza', 240, '0.0887', '10/29/2026', 'Slice', 'Active', 6900),
('30th Ave Souvlaki', 'Queens', 'Mediterranean', 185, '0.0887', '10/30/2026', 'Toast', 'Active', 5200),
('Court Street Bakery', 'Brooklyn', 'Bakery', 215, '0.0887', '10/30/2026', 'Square', 'Active', 3900),
('WTC Concourse Coffee', 'Manhattan', 'Coffee & Cafe', 410, '0.0887', '10/31/2026', 'Toast', 'Active', 4850);

-- Now test your select query:
SELECT * FROM pos_transactions LIMIT 0, 1000;
SELECT * FROM pos_transactions LIMIT 0, 1000;

SET SQL_SAFE_UPDATES = 0;

SELECT * 
FROM pos_staging;

-- COPY THE EXACT STRUCTURE
DROP TABLE IF EXISTS pos_staging;

CREATE TABLE pos_staging
LIKE pos_transactions;

INSERT INTO pos_staging
SELECT *
FROM pos_transactions;

SELECT *
FROM pos_staging;


-- CREATE REMOVE TABLE ALSO CHECK UP THE WINDOW FUNCTION

WITH duplicated_cte AS(
SELECT *,
ROW_NUMBER()OVER(PARTITION BY restaurant_name,borough,cuisine_type,daily_orders,tax_percentage,`date`,pos_system,account_status,daily_revenue) AS row_num FROM pos_staging)
SELECT *
FROM duplicated_cte
WHERE row_num > 1;


SELECT *
FROM pos_staging
WHERE restaurant_name = 'MARIO FAMOUS PIZZA'


-- CREATE A SECOUND STAGE TABLE with the real number row_num into
USE nyc_pos_ops;

-- 1. Drop and recreate pos_staging2 fresh
DROP TABLE IF EXISTS pos_staging2;

CREATE TABLE pos_staging2 (
  restaurant_name text,
  borough text,
  cuisine_type text,
  daily_orders int DEFAULT NULL,
  tax_percentage text,
  `date` text,
  pos_system text,
  account_status text,
  daily_revenue int DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Insert data from pos_staging into pos_staging2 WITHOUT row_num in the partition list
INSERT INTO pos_staging2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY restaurant_name, borough, cuisine_type, daily_orders, 
                 tax_percentage, `date`, pos_system, account_status, daily_revenue
) AS row_num
FROM pos_staging;

-- 3. Delete the duplicates where row_num > 1
DELETE FROM pos_staging2
WHERE row_num > 1;

-- 4. View your clean table!
SELECT * 
FROM pos_staging2;

-- Standardizing data
SELECT DISTINCT restaurant_name,TRIM(restaurant_name)
FROM pos_staging2;

UPDATE pos_staging2
SET restaurant_name = TRIM(restaurant_name);

SELECT DISTINCT borough
FROM pos_staging2
ORDER BY 1;

SELECT DISTINCT borough, TRIM(TRAILING '.' FROM borough)
FROM pos_staging2
ORDER BY 1;

UPDATE pos_staging2
SET cuisine_type = 'Pizza'
WHERE cuisine_type IN ('PIZZA', 'Pizza Pie', 'Pizza_Restaurant');

UPDATE pos_staging2
SET borough = TRIM(TRAILING '.' FROM borough)
WHERE borough LIKE 'Queens%';


SELECT * 
FROM pos_staging2;

-- 1. Test your conversion first to ensure it looks correct
SELECT DISTINCT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date
FROM pos_staging2;

-- 2. Update the table correctly using pos_staging2 and the right format mask
UPDATE pos_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- 3. View your final cleaned table
SELECT * 
FROM pos_staging2;

ALTER TABLE pos_staging2 
MODIFY COLUMN `date` DATE;

ALTER TABLE pos_staging2 
MODIFY COLUMN tax_percentage DECIMAL(5,4);

-- Handle null values and blank values

SELECT * 
FROM pos_staging2
WHERE daily_orders IS NULL
OR cuisine_type IS NULL;

SELECT *
FROM pos_staging2
WHERE cuisine_type IS NULL OR cuisine_type = '' OR TRIM(cuisine_type) = ''
   OR daily_orders IS NULL
   OR tax_percentage IS NULL OR tax_percentage = ''
   OR daily_revenue IS NULL;
   
   
SELECT borough,SUM(daily_revenue) AS total_revenue
FROM pos_staging2
WHERE account_status = 'Active'
GROUP BY borough
ORDER BY total_revenue DESC;



ALTER TABLE pos_staging2 MODIFY COLUMN `date` DATE;
ALTER TABLE pos_staging2 MODIFY COLUMN tax_percentage DECIMAL(5,4);


SELECT *
FROM pos_staging2;