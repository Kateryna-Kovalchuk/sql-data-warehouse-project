-- 🇺🇦 1. Приведення колонки prd_key до єдиного вигляду
-- 🇬🇧 1. Standardizing prd_key column format

SELECT prd_id, prd_key,
       REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, 
       SUBSTRING(prd_key,7, LENGTH(prd_key)) AS prd_key,
       prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt 
FROM bronze.crm_prd_info;

-- 🇺🇦 2. Аналіз унікальних значень id у таблиці erp_px_cat_g1v2
-- 🇬🇧 2. Analyzing unique id values in erp_px_cat_g1v2

SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;

-- 🇺🇦 3. Перевірка існування prd_key у sales_details
-- 🇬🇧 3. Checking prd_key existence in sales_details

SELECT REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, 
       SUBSTRING(prd_key,7, LENGTH(prd_key)) AS prd_key
FROM bronze.crm_prd_info 
WHERE SUBSTRING(prd_key,7, LENGTH(prd_key)) IN (SELECT sls_prd_key FROM bronze.crm_sales_details);

-- 🇺🇦 4. Перевірка текстових даних на небажані пробіли
-- 🇬🇧 4. Checking text data for unwanted spaces

SELECT prd_nm FROM bronze.crm_prd_info WHERE prd_nm != TRIM(prd_nm);

-- 🇺🇦 5. Перевірка числових даних на NULL та негативні значення
-- 🇬🇧 5. Checking numerical data for NULL and negative values

SELECT * FROM bronze.crm_prd_info;
SELECT * FROM bronze.crm_prd_info WHERE prd_cost IS NULL OR prd_cost < 0;

-- 🇺🇦 6. Оновлення числових значень, заміна NULL на 0
-- 🇬🇧 6. Updating numerical values, replacing NULL with 0

SELECT prd_id, prd_key, 
       REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, 
       SUBSTRING(prd_key,7, LENGTH(prd_key)) AS prd_key, 
       prd_nm, COALESCE(prd_cost,0) AS prd_cost, prd_line, prd_start_dt, prd_end_dt 
FROM bronze.crm_prd_info;

-- 🇺🇦 7. Розшифрування скорочень у колонці prd_line
-- 🇬🇧 7. Expanding abbreviations in prd_line column

SELECT DISTINCT prd_line, 
       CASE 
           WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
           WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
           WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
           WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
           ELSE 'n/a' 
       END AS prd_line
FROM bronze.crm_prd_info;

-- 🇺🇦 8. Перевірка коректності дат
-- 🇬🇧 8. Checking date validity

SELECT * FROM bronze.crm_prd_info WHERE prd_end_dt < prd_start_dt;

-- 🇺🇦 9. Виправлення дат: якщо кінцева дата менша за початкову, коригуємо її
-- 🇬🇧 9. Fixing dates: adjusting end date when it is earlier than start date

SELECT prd_start_dt, prd_end_dt, 
       LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

-- 🇺🇦 10. Видалення часу із дат
-- 🇬🇧 10. Removing time component from dates

SELECT prd_id, prd_key, 
       REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, 
       SUBSTRING(prd_key,7, LENGTH(prd_key)) AS prd_key, 
       prd_nm, COALESCE(prd_cost,0) AS prd_cost, 
       CASE UPPER(TRIM(prd_line)) 
           WHEN 'M' THEN 'Mountain'
           WHEN 'R' THEN 'Road'
           WHEN 'S' THEN 'Other Sales'
           WHEN 'T' THEN 'Touring'
           ELSE 'n/a' 
       END AS prd_line, 
       CAST(prd_start_dt AS DATE) AS prd_start_dt, 
       CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS DATE) AS prd_end_dt 
FROM bronze.crm_prd_info;

-- 🇺🇦 11. Завантаження очищених даних у silver
-- 🇬🇧 11. Inserting cleaned data into silver

INSERT INTO silver.crm_prd_info (
    prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
)
SELECT prd_id, 
       REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, 
       SUBSTRING(prd_key,7, LENGTH(prd_key)) AS prd_key, 
       prd_nm, COALESCE(prd_cost,0) AS prd_cost, 
       CASE UPPER(TRIM(prd_line)) 
           WHEN 'M' THEN 'Mountain'
           WHEN 'R' THEN 'Road'
           WHEN 'S' THEN 'Other Sales'
           WHEN 'T' THEN 'Touring'
           ELSE 'n/a' 
       END AS prd_line, 
       CAST(prd_start_dt AS DATE) AS prd_start_dt, 
       CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS DATE) AS prd_end_dt 
FROM bronze.crm_prd_info;

-- 🇺🇦 12. Перевірка отриманого результату
-- 🇬🇧 12. Validating inserted results

SELECT prd_nm FROM silver.crm_prd_info WHERE prd_nm != TRIM(prd_nm);
SELECT * FROM silver.crm_prd_info WHERE prd_cost IS NULL OR prd_cost < 0;
SELECT DISTINCT prd_line FROM silver.crm_prd_info;
SELECT * FROM silver.crm_prd_info WHERE prd_end_dt < prd_start_dt;
SELECT * FROM silver.crm_prd_info;
