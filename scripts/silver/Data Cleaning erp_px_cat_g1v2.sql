-- 🇺🇦 1. Отримання даних із таблиці категорій продуктів
-- 🇬🇧 1. Retrieving product category data

SELECT id, cat, subcat, maintenance FROM bronze.erp_px_cat_g1v2;

-- 🇺🇦 2. Перевірка відповідності id із silver.crm_prd_info
-- 🇬🇧 2. Checking if id matches silver.crm_prd_info

SELECT * FROM bronze.erp_px_cat_g1v2 WHERE id NOT IN (SELECT DISTINCT cat_id FROM silver.crm_prd_info);

-- 🇺🇦 3. Перевірка пробілів у категоріях, підкатегоріях та обслуговуванні
-- 🇬🇧 3. Checking for spaces in category, subcategory, and maintenance fields

SELECT id, cat, subcat, maintenance FROM bronze.erp_px_cat_g1v2 WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- 🇺🇦 4. Перевірка унікальності категорій, підкатегорій та обслуговування
-- 🇬🇧 4. Checking uniqueness of categories, subcategories, and maintenance

SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;

-- 🇺🇦 5. Завантаження даних у silver
-- 🇬🇧 5. Loading data into silver

DO $$ 
BEGIN 
    RAISE NOTICE '>> Truncating table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT id, cat, subcat, maintenance FROM bronze.erp_px_cat_g1v2;
END $$;

-- 🇺🇦 6. Перевірка перенесених даних
-- 🇬🇧 6. Validating transferred data

SELECT * FROM silver.erp_px_cat_g1v2;
