SELECT prd_id
, cat_id
, prd_key
, prd_nm
, prd_cost
, prd_line
, prd_start_dt
, prd_end_dt
, epcgv.cat 
, epcgv.subcat 
, epcgv.maintenance 
FROM silver.crm_prd_info cpi

-- filter out all historical data
SELECT 
	  prd_id
	, cat_id
	, prd_key
	, prd_nm
	, prd_cost
	, prd_line
	, prd_start_dt
	, prd_end_dt
FROM silver.crm_prd_info cpi
where prd_end_dt is null 

-- поєднуємо таблиці по продукту
SELECT prd_id
, cat_id
, prd_key
, prd_nm
, prd_cost
, prd_line
, prd_start_dt
, prd_end_dt
, epcgv.cat 
, epcgv.subcat 
, epcgv.maintenance 
FROM silver.crm_prd_info cpi
left join silver.erp_px_cat_g1v2 epcgv 
on cpi.cat_id = epcgv.id 
where prd_end_dt is null -- filter out all historical data


-- перевіряємо на дублі
select prd_key , count(*) from( 
SELECT prd_id
, cat_id
, prd_key
, prd_nm
, prd_cost
, prd_line
, prd_start_dt
, prd_end_dt
, epcgv.cat 
, epcgv.subcat 
, epcgv.maintenance 
FROM silver.crm_prd_info cpi
left join silver.erp_px_cat_g1v2 epcgv 
on cpi.cat_id = epcgv.id 
where prd_end_dt is null -- filter out all historical data
)
group by 1
having count(*)>1 

-- вибудовуємо стовбці у корректному порядку

SELECT 
  cpi.prd_id
, cpi.prd_key
, cpi.prd_nm
, cpi.cat_id
, epcgv.cat 
, epcgv.subcat
, epcgv.maintenance 
, cpi.prd_cost
, cpi.prd_line
, cpi.prd_start_dt
, cpi.prd_end_dt 

FROM silver.crm_prd_info cpi
left join silver.erp_px_cat_g1v2 epcgv 
on cpi.cat_id = epcgv.id 
where prd_end_dt is null -- filter out all historical data

-- переіменування стовбців

SELECT 
  cpi.prd_id as product_id
, cpi.prd_key as product_number
, cpi.prd_nm as product_name
, cpi.cat_id as category_id
, epcgv.cat as category
, epcgv.subcat as subcategory
, epcgv.maintenance 
, cpi.prd_cost as cost
, cpi.prd_line as product_line
, cpi.prd_start_dt as start_date
--, cpi.prd_end_dt 

FROM silver.crm_prd_info cpi
left join silver.erp_px_cat_g1v2 epcgv 
on cpi.cat_id = epcgv.id 
where prd_end_dt is null -- filter out all historical data

-- додаємо ключ

SELECT 
	  row_number () over (order by cpi.prd_start_dt, cpi.prd_key) as product_key
	, cpi.prd_id as product_id
	, cpi.prd_key as product_number
	, cpi.prd_nm as product_name
	, cpi.cat_id as category_id
	, epcgv.cat as category
	, epcgv.subcat as subcategory
	, epcgv.maintenance 
	, cpi.prd_cost as cost
	, cpi.prd_line as product_line
	, cpi.prd_start_dt as start_date

FROM silver.crm_prd_info cpi
left join silver.erp_px_cat_g1v2 epcgv 
on cpi.cat_id = epcgv.id 
where prd_end_dt is null -- filter out all historical data

-- створюємо VIEW
create view gold.dim_products as(
SELECT 
	  row_number () over (order by cpi.prd_start_dt, cpi.prd_key) as product_key
	, cpi.prd_id as product_id
	, cpi.prd_key as product_number
	, cpi.prd_nm as product_name
	, cpi.cat_id as category_id
	, epcgv.cat as category
	, epcgv.subcat as subcategory
	, epcgv.maintenance 
	, cpi.prd_cost as cost
	, cpi.prd_line as product_line
	, cpi.prd_start_dt as start_date

FROM silver.crm_prd_info cpi
left join silver.erp_px_cat_g1v2 epcgv 
on cpi.cat_id = epcgv.id 
where prd_end_dt is null -- filter out all historical data
)

-- переглянемо, чи все добре
select * from gold.dim_products dp 