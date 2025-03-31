SELECT 
	  sls_ord_num
	, sls_prd_key
	, sls_cust_id
	, sls_order_dt
	, sls_ship_dt
	, sls_due_dt
	, sls_sales
	, sls_quantity
	, sls_price
FROM silver.crm_sales_details;

-- поєднаємо з інформацією про продукт та клієнтів з дайменш таблиць і замінемо key на дані з тих таблиць, так як в нас fact табличка 

SELECT 
	  sls_ord_num
	, dp.product_key  
	, dc.customer_key 
	, sls_order_dt
	, sls_ship_dt
	, sls_due_dt
	, sls_sales
	, sls_quantity
	, sls_price
FROM silver.crm_sales_details csd
left join gold.dim_products dp 
on csd.sls_prd_key = dp.product_number 
left join gold.dim_customers dc 
on csd.sls_cust_id = dc.customer_id 

-- переіменування стовбців

SELECT 
	  csd.sls_ord_num as order_number
	, dp.product_key  
	, dc.customer_key 
	, csd.sls_order_dt as order_date
	, csd.sls_ship_dt as shipping_date
	, csd.sls_due_dt as due_date
	, csd.sls_sales as sales_amount
	, csd.sls_quantity as quanity
	, csd.sls_price as price
FROM silver.crm_sales_details csd
left join gold.dim_products dp 
on csd.sls_prd_key = dp.product_number 
left join gold.dim_customers dc 
on csd.sls_cust_id = dc.customer_id 

-- стовбці розташовані добре, тому створюємо view

create view gold.fact_sales as (
SELECT 
	  csd.sls_ord_num as order_number
	, dp.product_key  
	, dc.customer_key 
	, csd.sls_order_dt as order_date
	, csd.sls_ship_dt as shipping_date
	, csd.sls_due_dt as due_date
	, csd.sls_sales as sales_amount
	, csd.sls_quantity as quanity
	, csd.sls_price as price
FROM silver.crm_sales_details csd
left join gold.dim_products dp 
on csd.sls_prd_key = dp.product_number 
left join gold.dim_customers dc 
on csd.sls_cust_id = dc.customer_id )

select * from gold.fact_sales fs2 

-- перевіряємо чи зі всіма табличками інтегрується і чи нема NULL

select * 
from gold.fact_sales f
left join gold.dim_customers dc 
on dc.customer_key = f.customer_key 
left join gold.dim_products dp 
on dp.product_key = f.product_key 
where dc.customer_key is null or dp.product_key  is null

