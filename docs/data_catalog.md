# Data Catalog for Gold Layer

## Огляд | Overview  
Gold Layer – це рівень даних бізнес-рівня, структурований для підтримки аналітичних і звітних завдань. Він складається з таблиць вимірів та фактів для конкретних бізнес-метрик.  
**Gold Layer** is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact tables for specific business metrics.  

## Таблиці | Tables  

### gold.dim_customers  
**Призначення:** Містить інформацію про клієнтів, розширену демографічними та географічними даними.  
**Purpose:** Stores customer details enriched with demographic and geographic data.  

| Назва колонки        | Тип даних        | Опис (🇺🇦)                                                              | Description (🇬🇧)                                                   |
|----------------------|------------------|-------------------------------------------------------------------------------|------------------------------------------------------------------------|
| customer_key         | INT              | Унікальний ключ, що ідентифікує кожного клієнта в таблиці.                     | Unique key identifying each customer in the table.                     |
| customer_id          | INT              | Унікальний числовий ідентифікатор клієнта.                                    | Unique numeric identifier for the customer.                           |
| customer_number      | NVARCHAR(50)     | Алфавітно-цифровий ідентифікатор клієнта для відстеження та референції.       | Alphanumeric identifier for tracking and reference.                   |
| first_name           | NVARCHAR(50)     | Ім'я клієнта.                                                                 | Customer's first name.                                                 |
| last_name            | NVARCHAR(50)     | Прізвище клієнта.                                                             | Customer's last name.                                                  |
| country              | NVARCHAR(50)     | Країна проживання клієнта (наприклад, 'Australia').                           | Customer's country of residence (e.g., 'Australia').                   |
| marital_status       | NVARCHAR(50)     | Сімейний стан клієнта (наприклад, 'Married', 'Single').                        | Customer's marital status (e.g., 'Married', 'Single').                 |
| gender               | NVARCHAR(50)     | Стать клієнта (наприклад, 'Male', 'Female', 'n/a').                           | Customer's gender (e.g., 'Male', 'Female', 'n/a').                     |
| birthdate            | DATE             | Дата народження клієнта у форматі YYYY-MM-DD (наприклад, 1971-10-06).          | Customer's birth date in YYYY-MM-DD format (e.g., 1971-10-06).         |
| create_date          | DATE             | Дата створення запису клієнта в системі.                                      | The date the customer record was created in the system.                |

### gold.dim_products  
**Призначення:** Містить інформацію про товари та їх атрибути.  
**Purpose:** Provides information about the products and their attributes.  

| Назва колонки        | Тип даних        | Опис (🇺🇦)                                                              | Description (🇬🇧)                                                   |
|----------------------|------------------|-------------------------------------------------------------------------------|------------------------------------------------------------------------|
| product_key          | INT              | Унікальний ключ, що ідентифікує кожен товар у таблиці.                         | Unique key identifying each product in the table.                      |
| product_id           | INT              | Унікальний ідентифікатор товару для внутрішнього обліку.                       | Unique identifier for the product for internal accounting.             |
| product_number       | NVARCHAR(50)     | Алфавітно-цифровий код товару, що використовується для категоризації або інвентаризації. | Alphanumeric product code used for categorization or inventory.        |
| product_name         | NVARCHAR(50)     | Описова назва товару, що містить основні характеристики (тип, колір, розмір).  | Descriptive product name containing key characteristics (type, color, size). |
| category_id          | NVARCHAR(50)     | Унікальний ідентифікатор категорії товару.                                     | Unique identifier for the product category.                            |
| category             | NVARCHAR(50)     | Загальна класифікація товару (наприклад, 'Bikes', 'Components').               | General classification of the product (e.g., 'Bikes', 'Components').   |
| subcategory          | NVARCHAR(50)     | Детальніша класифікація товару в межах категорії.                              | More detailed product classification within the category.              |
| maintenance_required | NVARCHAR(50)     | Чи потребує товар обслуговування ('Yes', 'No').                               | Whether the product requires maintenance ('Yes', 'No').                |
| cost                 | DECIMAL(10,2)    | Вартість або базова ціна товару у грошових одиницях.                           | Cost or base price of the product in monetary units.                   |
| product_line         | NVARCHAR(50)     | Лінійка товарів або серія, до якої належить товар.                             | Product line or series the product belongs to.                         |
| start_date           | DATE             | Дата, коли товар став доступним для продажу або використання.                 | The date the product became available for sale or use.                 |

### gold.fact_sales  
**Призначення:** Містить дані про продажі для аналітичних цілей.  
**Purpose:** Stores transactional sales data for analytical purposes.  

| Назва колонки        | Тип даних        | Опис (🇺🇦)                                                              | Description (🇬🇧)                                                   |
|----------------------|------------------|-------------------------------------------------------------------------------|------------------------------------------------------------------------|
| order_number         | NVARCHAR(50)     | Унікальний алфавітно-цифровий ідентифікатор кожного замовлення.                | Unique alphanumeric identifier for each order.                         |
| product_key          | INT              | Ключ, що зв'язує замовлення з таблицею товарів.                                | Key linking the order to the product table.                            |
| customer_key         | INT              | Ключ, що зв'язує замовлення з таблицею клієнтів.                               | Key linking the order to the customer table.                           |
| order_date           | DATE             | Дата розміщення замовлення.                                                   | The date the order was placed.                                         |
| shipping_date        | DATE             | Дата відправлення замовлення клієнту.                                         | The date the order was shipped to the customer.                        |
| due_date             | DATE             | Дата, коли оплата за замовлення мала бути здійснена.                          | The date when payment for the order was due.                           |
| sales_amount         | DECIMAL(10,2)    | Загальна сума продажу у грошових одиницях.                                    | Total sales amount in monetary units.                                  |
| quantity             | INT              | Кількість одиниць товару в замовленні.                                        | Quantity of product units in the order.                                |
| price                | DECIMAL(10,2)    | Ціна за одиницю товару.                                                      | Price per unit of the product.                                         |
