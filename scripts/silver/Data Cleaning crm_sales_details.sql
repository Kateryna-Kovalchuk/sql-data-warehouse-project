-- 🇺🇦 1. Отримання даних із таблиці продажів
-- 🇬🇧 1. Retrieving sales data

SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details;

-- 🇺🇦 2. Перевірка пробілів у колонці sls_ord_num
-- 🇬🇧 2. Checking for spaces in sls_ord_num column

SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- 🇺🇦 3. Перевірка відповідності ключів товарів у crm_prd_info
-- 🇬🇧 3. Checking product keys against crm_prd_info

SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT sls_prd_key FROM silver.crm_prd_info);

SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT sls_cust_id FROM silver.crm_prd_info);

-- 🇺🇦 4. Перетворення дат із числового формату у формат DATE
-- 🇬🇧 4. Converting numeric dates to DATE format

SELECT NULLIF(sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LENGTH(sls_order_dt::TEXT) != 8 OR sls_order_dt < 19000101 OR sls_order_dt > 20500101;

SELECT NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR LENGTH(sls_ship_dt::TEXT) != 8 OR sls_ship_dt < 19000101 OR sls_ship_dt > 20500101;

SELECT NULLIF(sls_due_dt,0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR LENGTH(sls_due_dt::TEXT) != 8 OR sls_due_dt < 19000101 OR sls_due_dt > 20500101;

-- 🇺🇦 5. Оновлення коду з перевіркою дат
-- 🇬🇧 5. Updating code with date validation

SELECT sls_ord_num, sls_prd_key, sls_cust_id,
       CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_order_dt::TEXT AS DATE) END AS sls_order_dt,
       CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_ship_dt::TEXT AS DATE) END AS sls_ship_dt,
       CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_due_dt::TEXT AS DATE) END AS sls_due_dt,
       sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details;

-- 🇺🇦 6. Перевірка коректності дати замовлення, доставки та видачі
-- 🇬🇧 6. Validating order, shipment, and due dates

SELECT * FROM bronze.crm_sales_details 
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt OR sls_ship_dt > sls_due_dt;

-- 🇺🇦 7. Валідація продажів, кількості та ціни
-- 🇬🇧 7. Validating sales, quantity, and price

SELECT DISTINCT sls_sales AS sls_sales_old, sls_quantity AS sls_quantity_old, sls_price AS sls_price_old,
       CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales END AS sls_sales,
       CASE WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE sls_price END AS sls_price,
       CASE WHEN sls_quantity IS NULL OR sls_quantity <= 0
            THEN sls_sales / NULLIF(sls_price,0)
            ELSE sls_quantity END AS sls_quantity
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
      OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY 1, 2, 3 DESC;

-- 🇺🇦 8. Оновлення коду та внесення очищених даних у silver
-- 🇬🇧 8. Updating code and inserting cleaned data into silver

INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
SELECT sls_ord_num, sls_prd_key, sls_cust_id,
       CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_order_dt::TEXT AS DATE) END AS sls_order_dt,
       CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_ship_dt::TEXT AS DATE) END AS sls_ship_dt,
       CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_due_dt::TEXT AS DATE) END AS sls_due_dt,
       CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales END AS sls_sales,
       CASE WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE sls_price END AS sls_price,
       CASE WHEN sls_quantity IS NULL OR sls_quantity <= 0
            THEN sls_sales / NULLIF(sls_price,0)
            ELSE sls_quantity END AS sls_quantity
FROM bronze.crm_sales_details;

-- 🇺🇦 9. Перевірка внесених даних у silver
-- 🇬🇧 9. Validating inserted data in silver

SELECT * FROM silver.crm_sales_details;
SELECT sls_ord_num FROM silver.crm_sales_details WHERE sls_ord_num != TRIM(sls_ord_num);
SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details WHERE sls_prd_key NOT IN (SELECT sls_prd_key FROM silver.crm_prd_info);
SELECT * FROM silver.crm_sales_details WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt OR sls_ship_dt > sls_due_dt;
