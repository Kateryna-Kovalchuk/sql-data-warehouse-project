-- 🔹 Перевірка, чи існує БД
SELECT 1 FROM pg_database WHERE datname = 'DataWareHouse';

--  Якщо нема, створюємо
CREATE DATABASE "DataWarehouse";

-- Перевірка та створення схем
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
