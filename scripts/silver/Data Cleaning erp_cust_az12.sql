-- 🇺🇦 1. Отримання даних про клієнтів ERP
-- 🇬🇧 1. Retrieving ERP customer data

SELECT cid, bdate, gen FROM bronze.erp_cust_az12;

-- 🇺🇦 2. Трансформація cid у формат із silver.crm_cust_info
-- 🇬🇧 2. Transforming cid to match format in silver.crm_cust_info

SELECT cid,
       CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END AS cid,
       bdate, gen
FROM bronze.erp_cust_az12;

-- 🇺🇦 3. Перевірка коректності трансформації cid
-- 🇬🇧 3. Validating cid transformation

SELECT cid,
       CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END AS cid,
       bdate, gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);

-- 🇺🇦 4. Перевірка діапазону дат народження
-- 🇬🇧 4. Checking birth date range

SELECT bdate FROM bronze.erp_cust_az12 WHERE bdate < '1900-01-01' OR bdate > CURRENT_DATE;

-- 🇺🇦 5. Оновлення коду із перевіркою дат
-- 🇬🇧 5. Updating code with birth date validation

SELECT CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END AS cid,
       CASE WHEN bdate > CURRENT_DATE THEN NULL ELSE bdate END AS bdate,
       gen
FROM bronze.erp_cust_az12;

-- 🇺🇦 6. Уніфікація формату гендеру
-- 🇬🇧 6. Standardizing gender format

SELECT DISTINCT gen FROM bronze.erp_cust_az12;

SELECT DISTINCT gen,
       CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
            ELSE 'n/a' END AS standardized_gen
FROM bronze.erp_cust_az12;

-- 🇺🇦 7. Оновлення коду із виправленням гендеру
-- 🇬🇧 7. Updating code with gender corrections

SELECT CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END AS cid,
       CASE WHEN bdate > CURRENT_DATE THEN NULL ELSE bdate END AS bdate,
       CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
            ELSE 'n/a' END AS gen
FROM bronze.erp_cust_az12;

-- 🇺🇦 8. Перенесення даних у silver
-- 🇬🇧 8. Transferring data to silver

INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END AS cid,
       CASE WHEN bdate > CURRENT_DATE THEN NULL ELSE bdate END AS bdate,
       CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
            ELSE 'n/a' END AS gen
FROM bronze.erp_cust_az12;

-- 🇺🇦 9. Перевірка перенесених даних
-- 🇬🇧 9. Validating transferred data

SELECT * FROM silver.erp_cust_az12 LIMIT 10;

SELECT cid, bdate, gen FROM silver.erp_cust_az12 WHERE cid NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);

SELECT bdate FROM silver.erp_cust_az12 WHERE bdate < '1900-01-01' OR bdate > CURRENT_DATE;

SELECT DISTINCT gen FROM silver.erp_cust_az12;
