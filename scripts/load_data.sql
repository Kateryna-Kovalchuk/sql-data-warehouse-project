-- треба переконатися, що всі назви стовбців співпадають
-- COPY – якщо є доступ до файлу на сервері (найшвидший варіант).
-- \copy – якщо файл на комп'ютері (працює в psql або DBeaver).

COPY bronze.crm_cust_info(name, email, phone)
FROM 'шлях до файлу'
WITH (FORMAT csv, HEADER true);

\copy bronze.crm_cust_info FROM 'шлях до файлу' WITH (FORMAT csv, HEADER true);

-- або використати через import data (я так використала)
