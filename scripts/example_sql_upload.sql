CREATE OR REPLACE FUNCTION bronze.load_bronze()
RETURNS VOID AS
$$
DECLARE 
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    batch_start_time := NOW();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    -- Завантаження CRM-таблиць
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- Завантаження crm_cust_info
    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    COPY bronze.crm_cust_info FROM 'шлях до файлу' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(SECOND FROM (end_time - start_time));

    -- Завантаження crm_prd_info
    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info FROM 'шлях до файлу' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(SECOND FROM (end_time - start_time));

    -- Завантаження crm_sales_details
    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details FROM 'шлях до файлу' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(SECOND FROM (end_time - start_time));

    -- Завантаження ERP-таблиць
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    -- Завантаження erp_loc_a101
    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101 FROM 'шлях до файлу' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(SECOND FROM (end_time - start_time));

    -- Завантаження erp_cust_az12
    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12 FROM 'шлях до файлу' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(SECOND FROM (end_time - start_time));

    -- Завантаження erp_px_cat_g1v2
    start_time := NOW();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2 FROM 'шлях до файлу' DELIMITER ',' CSV HEADER;
    end_time := NOW();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(SECOND FROM (end_time - start_time));

    batch_end_time := NOW();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: % seconds', EXTRACT(SECOND FROM (batch_end_time - batch_start_time));
    RAISE NOTICE '==========================================';

EXCEPTION 
    WHEN OTHERS THEN 
        RAISE NOTICE '==========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE '==========================================';
END;
$$ LANGUAGE plpgsql;
