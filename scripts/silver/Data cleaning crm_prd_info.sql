
--1) приведемо до єдиного вигляду колонку prd_key з erp , а саме зменшимо до 5 символів та замість дефісу поставимо нижнє підкреслення
select 
prd_id 
, prd_key 
, replace (substring(prd_key,1,5),'-','_') as cat_id 
, substring(prd_key,7, LENGTH(prd_key)) as prd_key  
, prd_nm 
, prd_cost
, prd_line 
, prd_start_dt 
, prd_end_dt 
from bronze.crm_prd_info 


select distinct id
from bronze.erp_px_cat_g1v2 epcgv 


select 
 replace (substring(prd_key,1,5),'-','_') as cat_id 
, substring(prd_key,7, LENGTH(prd_key)) as prd_key  
from bronze.crm_prd_info 
where substring(prd_key,7, LENGTH(prd_key)) in (select sls_prd_key from bronze.crm_sales_details)


-- 2. Перевіремо всі текстові дані на небажані пробіли
-- ціль : відсутні значення

-- виведемо всі значення, де є пробіл в імені
select prd_nm
from bronze.crm_prd_info cpi  
where prd_nm != trim(prd_nm) 

--3. перевіремо числа на null та негативні числа
select *
from bronze.crm_prd_info cpi 

select *
from bronze.crm_prd_info 
where prd_cost is null or prd_cost < 0

-- змінемо код, додавши заміну null на 0

select 
prd_id 
, prd_key 
, replace (substring(prd_key,1,5),'-','_') as cat_id 
, substring(prd_key,7, LENGTH(prd_key)) as prd_key  
, prd_nm 
, COALESCE(prd_cost,0) as prd_cost
, prd_line 
, prd_start_dt 
, prd_end_dt 
from bronze.crm_prd_info 

-- 4) розпишемо скорочення на повну назву
select distinct prd_line 
, case when upper(trim(prd_line)) = 'M' then 'Mountain'
	   when upper(trim(prd_line)) = 'R' then 'Road'
	   when upper(trim(prd_line)) = 'S' then 'other Sales'
	   when upper(trim(prd_line)) = 'T' then 'Touring'
	   else 'n/a' end as prd_line
from bronze.crm_prd_info 

select 
prd_id 
, prd_key 
, replace (substring(prd_key,1,5),'-','_') as cat_id 
, substring(prd_key,7, LENGTH(prd_key)) as prd_key  
, prd_nm 
, COALESCE(prd_cost,0) as prd_cost
, case upper(trim(prd_line)) 
	   when 'M' then 'Mountain'
	   when 'R' then 'Road'
	   when 'S' then 'Other Sales'
	   when 'T' then 'Touring'
	   else 'n/a' end as prd_line 
, prd_start_dt 
, prd_end_dt 
from bronze.crm_prd_info 

-- 5) перевіряємо дійсність дат
select *
from bronze.crm_prd_info 
where prd_end_dt < prd_start_dt 

-- проблема полягає в тому, що в деяких даних, кінцева дата менша ніж дата старту
-- виправляємо по такій логіці: дата кінця повинна бути на 1 день менша дати наступного старту, в останній якщо нема інформації про зацінчення угоди, то ставимо null 
SELECT 
    prd_start_dt, 
    prd_end_dt, 
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS prd_end_dt_test
FROM bronze.crm_prd_info 
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

select 
prd_id 
, prd_key 
, replace (substring(prd_key,1,5),'-','_') as cat_id 
, substring(prd_key,7, LENGTH(prd_key)) as prd_key  
, prd_nm 
, COALESCE(prd_cost,0) as prd_cost
, case upper(trim(prd_line)) 
	   when 'M' then 'Mountain'
	   when 'R' then 'Road'
	   when 'S' then 'Other Sales'
	   when 'T' then 'Touring'
	   else 'n/a' end as prd_line 
, prd_start_dt 
, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS prd_end_dt 
from bronze.crm_prd_info 

--6) в датах нема інфомації про час, тому прибираємо

select 
prd_id 
, prd_key 
, replace (substring(prd_key,1,5),'-','_') as cat_id 
, substring(prd_key,7, LENGTH(prd_key)) as prd_key  
, prd_nm 
, COALESCE(prd_cost,0) as prd_cost
, case upper(trim(prd_line)) 
	   when 'M' then 'Mountain'
	   when 'R' then 'Road'
	   when 'S' then 'Other Sales'
	   when 'T' then 'Touring'
	   else 'n/a' end as prd_line 
, cast (prd_start_dt as date) as  prd_start_dt
, cast( LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' as date) AS prd_end_dt 
from bronze.crm_prd_info 

--7) вносимо очищенні дані в сільвер

INSERT INTO silver.crm_prd_info (
   prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
)
select 
prd_id 
, replace (substring(prd_key,1,5),'-','_') as cat_id 
, substring(prd_key,7, LENGTH(prd_key)) as prd_key  
, prd_nm 
, COALESCE(prd_cost,0) as prd_cost
, case upper(trim(prd_line)) 
	   when 'M' then 'Mountain'
	   when 'R' then 'Road'
	   when 'S' then 'Other Sales'
	   when 'T' then 'Touring'
	   else 'n/a' end as prd_line 
, cast (prd_start_dt as date) as  prd_start_dt
, cast( LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' as date) AS prd_end_dt 
from bronze.crm_prd_info 

-- перевіряємо отриманий результат

select prd_nm
from silver.crm_prd_info cpi  
where prd_nm != trim(prd_nm) 


select *
from silver.crm_prd_info 
where prd_cost is null or prd_cost < 0

select distinct prd_line 
from silver.crm_prd_info 

select *
from silver.crm_prd_info 
where prd_end_dt < prd_start_dt