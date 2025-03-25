DO $$ 
DECLARE batch_start_time TIMESTAMP;
BEGIN 
    batch_start_time := NOW();
    
    -- 🇺🇦 Очищення таблиці клієнтів CRM перед завантаженням
    -- 🇬🇧 Truncating CRM customer table before inserting new data
    RAISE NOTICE '>> Truncating table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    
    -- 🇺🇦 Завантаження очищених даних клієнтів CRM, уникаючи дублікатів
    -- 🇬🇧 Inserting cleaned CRM customer data, avoiding duplicates
    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
    cst_id, cst_key, cst_firstname, cst_lastname, 
    cst_marital_status, cst_gndr, cst_create_date
)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname),
    TRIM(cst_lastname),
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a' 
    END,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a' 
    END,
    cst_create_date
FROM (
    SELECT cst_id, cst_key, cst_firstname, cst_lastname, 
           cst_marital_status, cst_gndr, cst_create_date, 
           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1 
  AND cst_create_date IS NOT NULL;

    
    -- 🇺🇦 Очищення та завантаження даних про продукти CRM
    -- 🇬🇧 Truncating and inserting CRM product data
    RAISE NOTICE '>> Truncating table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    
    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT 
        prd_id, 
        REPLACE(SUBSTRING(prd_key FROM 1 FOR 5), '-', '_') AS cat_id, 
        SUBSTRING(prd_key FROM 7) AS prd_key, 
        prd_nm, 
        COALESCE(prd_cost, 0), 
        CASE UPPER(TRIM(prd_line)) 
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a' 
        END, 
        CAST(prd_start_dt AS DATE), 
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS DATE)
    FROM bronze.crm_prd_info
    ON CONFLICT (prd_id) DO NOTHING;

    -- 🇺🇦 Завантаження даних про продажі CRM із перевіркою дат
    -- 🇬🇧 Inserting CRM sales data with date validation
    RAISE NOTICE '>> Truncating table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    
    RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
    )
    SELECT 
        sls_ord_num, sls_prd_key, sls_cust_id, 
        CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_order_dt::TEXT AS DATE) END,
        CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_ship_dt::TEXT AS DATE) END,
        CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL ELSE CAST(sls_due_dt::TEXT AS DATE) END,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price) ELSE sls_sales END,
        CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0) ELSE sls_price END,
        CASE WHEN sls_quantity IS NULL OR sls_quantity <= 0 THEN sls_sales / NULLIF(sls_price, 0) ELSE sls_quantity END
    FROM bronze.crm_sales_details
    ON CONFLICT (sls_ord_num) DO NOTHING;
    
    -- 🇺🇦 Завантаження довідника локацій ERP
    -- 🇬🇧 Inserting ERP location reference data
    RAISE NOTICE '>> Truncating table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    
    RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';
    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT REPLACE(cid, '-', ''), 
        CASE 
            WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
            WHEN UPPER(TRIM(cntry)) IN ('AU', 'AUSTRALIA') THEN 'Australia'
            WHEN UPPER(TRIM(cntry)) IN ('CA', 'CANADA') THEN 'Canada'
            WHEN UPPER(TRIM(cntry)) IN ('FR', 'FRANCE') THEN 'France'
            WHEN UPPER(TRIM(cntry)) IN ('UK', 'UNITED KINGDOM') THEN 'United Kingdom'
            WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
            ELSE 'n/a' 
        END
    FROM bronze.erp_loc_a101
    ON CONFLICT (cid) DO NOTHING;

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Data Load Process Completed Successfully';
    RAISE NOTICE 'Total Duration: % seconds', EXTRACT(SECOND FROM (NOW() - batch_start_time));
    RAISE NOTICE '==========================================';
END $$;
