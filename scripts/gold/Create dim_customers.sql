SELECT    cci.cst_id
		, cci.cst_key
		, cci.cst_firstname
		, cci.cst_lastname
		, cci.cst_marital_status
		, cci.cst_gndr
		, cci.cst_create_date
		, eca.bdate 
		, eca.gen 
		, ela.cntry 
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid 

-- перевіоемо чи нема дублікатів після обʼєднання

select cst_id , count(*) from
(
SELECT    cci.cst_id
		, cci.cst_key
		, cci.cst_firstname
		, cci.cst_lastname
		, cci.cst_marital_status
		, cci.cst_gndr
		, cci.cst_create_date
		, eca.bdate 
		, eca.gen 
		, ela.cntry 
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid ) 
group by cst_id
having count(*) >1 

-- перевіряємо поля cci.cst_gndr та eca.gen  на корректність при поєднанні таблиць

SELECT   distinct cci.cst_gndr
		, eca.gen 
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid 
order by 1,2

-- інформація з crm вважаємо за головну, напишемо умови обробки неточностей


SELECT   distinct cci.cst_gndr
		, eca.gen 
		, case when cci.cst_gndr != 'n/a' then cci.cst_gndr
		else coalesce (eca.gen,'n/a') end as new_gen
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid 
order by 1,2

-- оновлюємо код

SELECT    cci.cst_id
		, cci.cst_key
		, cci.cst_firstname
		, cci.cst_lastname
		, cci.cst_marital_status
		, case when cci.cst_gndr != 'n/a' then cci.cst_gndr
		else coalesce (eca.gen,'n/a') end as new_gen
		, cci.cst_create_date
		, eca.bdate 
		, ela.cntry 
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid 

-- переменуємо назви колонок на більш зрозумілі

SELECT    cci.cst_id as customer_id
		, cci.cst_key as customer_number
		, cci.cst_firstname as first_name
		, cci.cst_lastname as last_name
		, cci.cst_marital_status as marital_status
		, case when cci.cst_gndr != 'n/a' then cci.cst_gndr
		else coalesce (eca.gen,'n/a') end as gender
		, cci.cst_create_date as create_date
		, eca.bdate as birthdate
		, ela.cntry as country
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid 

-- змінемо по порядку поля, для більш логічного розташування

SELECT    cci.cst_id as customer_id
		, cci.cst_key as customer_number
		, cci.cst_firstname as first_name
		, cci.cst_lastname as last_name
		, ela.cntry as country
		, cci.cst_marital_status as marital_status
		, case when cci.cst_gndr != 'n/a' then cci.cst_gndr
		else coalesce (eca.gen,'n/a') end as gender
		, eca.bdate as birthdate
		, cci.cst_create_date as create_date		
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid 

-- створемо id від DWH

SELECT  row_number () over (order by cst_id) as customer_key
		,  cci.cst_id as customer_id
		, cci.cst_key as customer_number
		, cci.cst_firstname as first_name
		, cci.cst_lastname as last_name
		, ela.cntry as country
		, cci.cst_marital_status as marital_status
		, case when cci.cst_gndr != 'n/a' then cci.cst_gndr
		else coalesce (eca.gen,'n/a') end as gender
		, eca.bdate as birthdate
		, cci.cst_create_date as create_date		
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid 

-- створюємо VIEW 

create view gold.dim_customers as (
SELECT  row_number () over (order by cst_id) as customer_key
		,  cci.cst_id as customer_id
		, cci.cst_key as customer_number
		, cci.cst_firstname as first_name
		, cci.cst_lastname as last_name
		, ela.cntry as country
		, cci.cst_marital_status as marital_status
		, case when cci.cst_gndr != 'n/a' then cci.cst_gndr
		else coalesce (eca.gen,'n/a') end as gender
		, eca.bdate as birthdate
		, cci.cst_create_date as create_date		
FROM silver.crm_cust_info cci
left join silver.erp_cust_az12 eca on 
cci.cst_key = eca.cid 
left join silver.erp_loc_a101 ela on
cci.cst_key = ela.cid ) 

-- перевіряємо корректність даних

select * from gold.dim_customers dc 

select distinct gender  from gold.dim_customers dc 

