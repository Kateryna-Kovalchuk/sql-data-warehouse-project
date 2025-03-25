-- 🇺🇦 1. Отримання даних із таблиці локацій
-- 🇬🇧 1. Retrieving location data

SELECT cid, cntry FROM bronze.erp_loc_a101;

-- 🇺🇦 2. Перевірка відповідності cid із silver.crm_cust_info
-- 🇬🇧 2. Checking if cid matches silver.crm_cust_info

SELECT cst_key FROM silver.crm_cust_info;

-- 🇺🇦 3. Видалення дефісів із cid
-- 🇬🇧 3. Removing hyphens from cid

SELECT REPLACE(cid, '-', '') AS cid FROM bronze.erp_loc_a101;

-- 🇺🇦 4. Перевірка наявності cid у базі
-- 🇬🇧 4. Checking if all cid exist in the database

SELECT REPLACE(cid, '-', '') AS cid FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- 🇺🇦 5. Оновлення коду
-- 🇬🇧 5. Updating code

SELECT REPLACE(cid, '-', '') AS cid, cntry FROM bronze.erp_loc_a101;

-- 🇺🇦 6. Уніфікація назв країн
-- 🇬🇧 6. Standardizing country names

SELECT DISTINCT cntry FROM bronze.erp_loc_a101 ORDER BY cntry;

SELECT DISTINCT cntry,
       CASE WHEN UPPER(TRIM(cntry)) IN ('DE','GERMANY') THEN 'Germany'
            WHEN UPPER(TRIM(cntry)) IN ('AU','AUSTRALIA') THEN 'Australia'
            WHEN UPPER(TRIM(cntry)) IN ('CA','CANADA') THEN 'Canada'
            WHEN UPPER(TRIM(cntry)) IN ('FR','FRANCE') THEN 'France'
            WHEN UPPER(TRIM(cntry)) IN ('UK','UNITED KINGDOM') THEN 'United Kingdom'
            WHEN UPPER(TRIM(cntry)) IN ('US','USA','UNITED STATES') THEN 'United States'
            ELSE 'n/a' END AS standardized_cntry
FROM bronze.erp_loc_a101 ORDER BY 1;

-- 🇺🇦 7. Оновлення коду з коригуванням назв країн
-- 🇬🇧 7. Updating code with country name corrections

SELECT REPLACE(cid, '-', '') AS cid,
       CASE WHEN UPPER(TRIM(cntry)) IN ('DE','GERMANY') THEN 'Germany'
            WHEN UPPER(TRIM(cntry)) IN ('AU','AUSTRALIA') THEN 'Australia'
            WHEN UPPER(TRIM(cntry)) IN ('CA','CANADA') THEN 'Canada'
            WHEN UPPER(TRIM(cntry)) IN ('FR','FRANCE') THEN 'France'
            WHEN UPPER(TRIM(cntry)) IN ('UK','UNITED KINGDOM') THEN 'United Kingdom'
            WHEN UPPER(TRIM(cntry)) IN ('US','USA','UNITED STATES') THEN 'United States'
            ELSE 'n/a' END AS standardized_cntry
FROM bronze.erp_loc_a101;

-- 🇺🇦 8. Перенесення даних у silver
-- 🇬🇧 8. Transferring data to silver

INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT REPLACE(cid, '-', ''),
       CASE WHEN UPPER(TRIM(cntry)) IN ('DE','GERMANY') THEN 'Germany'
            WHEN UPPER(TRIM(cntry)) IN ('AU','AUSTRALIA') THEN 'Australia'
            WHEN UPPER(TRIM(cntry)) IN ('CA','CANADA') THEN 'Canada'
            WHEN UPPER(TRIM(cntry)) IN ('FR','FRANCE') THEN 'France'
            WHEN UPPER(TRIM(cntry)) IN ('UK','UNITED KINGDOM') THEN 'United Kingdom'
            WHEN UPPER(TRIM(cntry)) IN ('US','USA','UNITED STATES') THEN 'United States'
            ELSE 'n/a' END
FROM bronze.erp_loc_a101;

-- 🇺🇦 9. Перевірка якості перенесених даних
-- 🇬🇧 9. Validating transferred data

SELECT cid, cntry FROM silver.erp_loc_a101;

SELECT cid FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

SELECT DISTINCT cntry FROM silver.erp_loc_a101 ORDER BY cntry;
