-- 🇺🇦 1. Перевірка первинного ключа на дублікат та NULL
-- 🇬🇧 1. Checking primary key for duplicates and NULL values

SELECT cst_id, COUNT(*) 
FROM bronze.crm_cust_info  
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL
ORDER BY 2;

-- 🇺🇦 2. Аналіз дублікатів для подальшої трансформації
-- 🇬🇧 2. Analyzing duplicates for further transformation

SELECT *
FROM bronze.crm_cust_info  
WHERE cst_id = 29466;

-- 🇺🇦 3. Використання віконної функції для вибору останніх актуальних записів
-- 🇬🇧 3. Using a window function to select the latest records

SELECT *, 
       ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info;

SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t 
WHERE flag_last = 1;

-- 🇺🇦 4. Перевірка на конкретному прикладі
-- 🇬🇧 4. Checking a specific case

SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t 
WHERE flag_last = 1 AND cst_id = 29466;

-- 🇺🇦 5. Перевірка текстових даних на пробіли
-- 🇬🇧 5. Checking text data for unwanted spaces

SELECT cst_firstname 
FROM bronze.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname  
FROM bronze.crm_cust_info 
WHERE cst_lastname  != TRIM(cst_lastname);

SELECT cst_gndr  
FROM bronze.crm_cust_info 
WHERE cst_gndr  != TRIM(cst_gndr);

-- 🇺🇦 6. Оновлення даних із виправленими пробілами
-- 🇬🇧 6. Updating data with trimmed text fields

SELECT cst_id, cst_key, TRIM(cst_firstname) AS cst_firstname, TRIM(cst_lastname) AS cst_lastname, 
       cst_marital_status, cst_gndr, cst_create_date
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t 
WHERE flag_last = 1;

-- 🇺🇦 7. Стандартизація та узгодженість даних
-- 🇬🇧 7. Data Standardization & Consistency

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_gndr,
       CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a' END AS standardized_cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status 
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status,
       CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a' END AS standardized_cst_marital_status  
FROM bronze.crm_cust_info;

-- 🇺🇦 8. Вставка очищених та стандартизованих даних у таблицю silver
-- 🇬🇧 8. Inserting cleaned and standardized data into the silver table

INSERT INTO silver.crm_cust_info (
    cst_id, cst_key, cst_firstname, cst_lastname, 
    cst_marital_status, cst_gndr, cst_create_date
)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a' 
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a' 
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1 AND cst_create_date IS NOT NULL;

-- 🇺🇦 9. Перевірка чистоти даних у silver.crm_cust_info
-- 🇬🇧 9. Checking data quality in silver.crm_cust_info

-- 🇺🇦 9.1 Перевірка дубліката первинного ключа та NULL
-- 🇬🇧 9.1 Checking for duplicate primary keys and NULL values
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info  
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL
ORDER BY 2;

-- 🇺🇦 9.2 Перевірка на пробіли
-- 🇬🇧 9.2 Checking for leading/trailing spaces
SELECT cst_firstname FROM silver.crm_cust_info WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname FROM silver.crm_cust_info WHERE cst_lastname != TRIM(cst_lastname);
SELECT cst_gndr FROM silver.crm_cust_info WHERE cst_gndr != TRIM(cst_gndr);
SELECT cst_marital_status FROM silver.crm_cust_info WHERE cst_marital_status != TRIM(cst_marital_status);

-- 🇺🇦 9.3 Перевірка правильності змін значень у стовпцях "гендер" та "сімейний статус"
-- 🇬🇧 9.3 Checking correctness of gender and marital status values
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;

-- 🇺🇦 9.4 Перевірка відсутності NULL у стовпці дат
-- 🇬🇧 9.4 Checking for NULL values in the date column
SELECT cst_create_date FROM silver.crm_cust_info WHERE cst_create_date IS NULL;
