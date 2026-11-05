USE restaurant_audit_v2;

SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS messy_staging;

CREATE TABLE messy_staging
LIKE messy_orders_v2;

INSERT INTO messy_staging
SELECT *
FROM messy_orders_v2;


DROP TABLE IF EXISTS messy_staging2;

CREATE TABLE `messy_staging2` (
  `order_id` int DEFAULT NULL,
  `store_location` text,
  `item_name` text,
  `quantity` int DEFAULT NULL,
  `order_total` text,
  `payment_type` text,
  `order_date` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO messy_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY order_id, store_location, item_name) AS row_num 
FROM messy_staging;

DELETE  
FROM messy_staging2 
WHERE row_num > 1;

UPDATE messy_staging2
SET store_location = TRIM(store_location),
    item_name = TRIM(item_name),
    payment_type = TRIM(payment_type);

UPDATE messy_staging2 
SET store_location = 'Astoria' 
WHERE store_location LIKE '%astoria%';

UPDATE messy_staging2 
SET store_location = 'Manhattan' 
WHERE store_location LIKE '%manhattan%';

UPDATE messy_staging2 
SET item_name = 'Large Cheese Pie' 
WHERE item_name LIKE '%cheese%';

UPDATE messy_staging2 
SET item_name = 'Garlic Knots' 
WHERE item_name LIKE '%garlic%';

UPDATE messy_staging2 
SET item_name = 'Pepperoni Pizza' 
WHERE item_name LIKE '%pepperoni%';

UPDATE messy_staging2 
SET item_name = 'Soda (2L)' 
WHERE item_name LIKE '%soda%';

UPDATE messy_staging2 
SET payment_type = 'Cash' 
WHERE payment_type LIKE '%cash%';

UPDATE messy_staging2 
SET payment_type = 'Credit Card' 
WHERE payment_type LIKE '%credit%';

UPDATE messy_staging2 
SET payment_type = 'Cash' 
WHERE payment_type LIKE '%unknown%';



UPDATE messy_staging2 
SET order_total = REPLACE(order_total, '$', '');

ALTER TABLE messy_staging2 
MODIFY COLUMN order_total DECIMAL(10,2);

UPDATE messy_staging2 
SET quantity = ABS(quantity) 
WHERE quantity < 0;


UPDATE messy_staging2 
SET order_date = NULL  
WHERE order_date LIKE 'Invalid Date' OR order_date = '';

UPDATE messy_staging2 
SET order_date = DATE_FORMAT(STR_TO_DATE(order_date, '%m/%d/%Y'), '%Y-%m-%d') 
WHERE order_date LIKE '__/__/____';

UPDATE messy_staging2 
SET order_date = DATE_FORMAT(STR_TO_DATE(order_date, '%Y/%m/%d'), '%Y-%m-%d') 
WHERE order_date LIKE '____/__/__';

UPDATE messy_staging2 
SET order_date = DATE_FORMAT(STR_TO_DATE(order_date, '%m-%d-%Y'), '%Y-%m-%d') 
WHERE order_date LIKE '__-__-____';

ALTER TABLE messy_staging2 
DROP COLUMN row_num;

ALTER TABLE messy_staging2 
MODIFY COLUMN order_date DATE;

SELECT * 
FROM messy_staging2;


SELECT
COUNT(DISTINCT order_id) AS total_orders,
SUM(quantity) AS total_items_sold,
SUM(order_total)AS total_revnue,
ROUND(SUM(order_total)/ COUNT(DISTINCT order_id),2) AS average_order_value
FROM messy_staging2;


SELECT 
    store_location,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_total) AS store_revenue
FROM messy_staging2
GROUP BY store_location
ORDER BY store_revenue DESC;

SELECT 
    item_name,
    SUM(quantity) AS units_sold,
    SUM(order_total) AS item_revenue
FROM messy_staging2
GROUP BY item_name
ORDER BY item_revenue DESC;


