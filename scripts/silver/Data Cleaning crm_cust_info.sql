select *
from bronze.crm_cust_info cci 

-- 1. Перевіремо primary key на дублікати та NULL

select 
cst_id ,
count(*) 
from bronze.crm_cust_info  
group by cst_id 
having count(*)>1 or cst_id is null
order by 2;

-- тепер розглянемо, що всередені дублікатів, для подальшої трансформації

select *
from bronze.crm_cust_info  
where cst_id = 29466;

-- використаємо віконну функцію для того, щоб вибрати тільки свіжі дані
select *, 
row_number () over (PARTITION BY cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info ;

select *
from (select *, 
row_number () over (PARTITION BY cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info) t where flag_last=1
-- перевіремо на конткретному прикладі
select *
from (select *, 
row_number () over (PARTITION BY cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info) t where flag_last=1 and cst_id = 29466


-- 2. Перевіремо всі текстові дані на небажані пробіли
-- ціль : відсутні значення

-- виведемо всі значення, де є пробіл в імені
select cst_firstname 
from bronze.crm_cust_info 
where cst_firstname != trim(cst_firstname) 

select cst_lastname  
from bronze.crm_cust_info 
where cst_lastname  != trim(cst_lastname) 

select cst_gndr  
from bronze.crm_cust_info 
where cst_gndr  != trim(cst_gndr) 

--  оновлений код, з урахуванням, ім'я та призвіще без пробілів

select cst_id
, cst_key
, trim(cst_firstname) as cst_firstname
, trim(cst_lastname) as cst_lastname
, cst_marital_status
, cst_gndr
, cst_create_date
from (select *, 
row_number () over (PARTITION BY cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info) t where flag_last=1

-- 3) Data Standardization & Consistency
select distinct cst_gndr
from bronze.crm_cust_info  


select distinct cst_gndr,
case when upper(trim(cst_gndr)) = 'F' then 'Female'
	when upper(trim(cst_gndr)) = 'M' then 'Male'
	else 'n/a' end cst_gndr 
from bronze.crm_cust_info  

select distinct cst_marital_status 
from bronze.crm_cust_info  

select distinct cst_marital_status ,
case when upper(trim(cst_marital_status )) = 'S' then 'Single'
	when upper(trim(cst_marital_status )) = 'M' then 'Married'
	else 'n/a' end cst_marital_status  
from bronze.crm_cust_info  

--  оновлений код і фінальний код, з урахуванням, гендеру, сімейного статусу та обробки null
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
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1 
  AND cst_create_date IS NOT NULL;
 
 -- перевірка чистоти даних
 
--1) Перевіремо primary key на дублікати та NULL
 select 
cst_id ,
count(*) 
from silver.crm_cust_info  
group by cst_id 
having count(*)>1 or cst_id is null
order by 2;

--2) перевірка на пробіли

select cst_firstname 
from silver.crm_cust_info 
where cst_firstname != trim(cst_firstname) 

select cst_lastname  
from silver.crm_cust_info 
where cst_lastname  != trim(cst_lastname); 

select cst_gndr  
from silver.crm_cust_info 
where cst_gndr  != trim(cst_gndr) ;

select cst_marital_status  
from silver.crm_cust_info 
where cst_marital_status  != trim(cst_marital_status) ;

-- 3) перевірка корректність зміни назв гендер та статус

select distinct cst_gndr
from silver.crm_cust_info  

select distinct cst_marital_status
from silver.crm_cust_info  

--4) відсутність null у даті

select cst_create_date 
from silver.crm_cust_info  
where cst_create_date is null 

  