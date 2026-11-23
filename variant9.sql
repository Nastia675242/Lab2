-- Практическая работа №2: Создание запросов
-- Вариант 9: Клиенты + Заказы
-- База данных: Lab1
-- Таблицы: clients, orders (созданы в Практической работе №1)
-- Выполнять запросы по порядку в Query Tool (F5).

-- =========================================================
-- Задание 1. Выбрать клиентов от 18 до 30 лет,
-- проживающих в Москве.
-- AGE вычисляет возраст относительно текущей даты.
-- =========================================================
SELECT *
FROM clients
WHERE AGE(CURRENT_DATE, birth_date) >= INTERVAL '18 years'
  AND AGE(CURRENT_DATE, birth_date) <= INTERVAL '30 years'
  AND address ILIKE '%Москва%';


-- =========================================================
-- Задание 2. Выбрать клиентов, сделавших заказы в 2008 году.
-- JOIN связывает клиентов с их заказами.
-- =========================================================
SELECT DISTINCT c.*
FROM clients c
JOIN orders o ON c.client_id = o.client_id
WHERE o.order_date >= DATE '2008-01-01'
  AND o.order_date < DATE '2009-01-01';


-- =========================================================
-- Задание 3. Создать таблицу с данными второго запроса
-- и контактными телефонами.
-- DROP TABLE позволяет пересоздать таблицу при повторном запуске.
-- =========================================================
DROP TABLE IF EXISTS clients_2008;

CREATE TABLE clients_2008 AS
SELECT DISTINCT c.client_id,
       c.last_name,
       c.first_name,
       c.middle_name,
       c.birth_date,
       c.is_company_rep,
       c.address,
       c.phone
FROM clients c
JOIN orders o ON c.client_id = o.client_id
WHERE o.order_date >= DATE '2008-01-01'
  AND o.order_date < DATE '2009-01-01';


-- =========================================================
-- Задание 4. Добавить в созданную таблицу клиентов,
-- у которых отсутствует контактный телефон.
-- В исходной таблице phone объявлен NOT NULL, поэтому
-- при исходной структуре таких клиентов быть не должно.
-- =========================================================
INSERT INTO clients_2008
    (client_id, last_name, first_name, middle_name,
     birth_date, is_company_rep, address, phone)
SELECT c.client_id, c.last_name, c.first_name, c.middle_name,
       c.birth_date, c.is_company_rep, c.address, c.phone
FROM clients c
WHERE c.phone IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM clients_2008 t
      WHERE t.client_id = c.client_id
  );


-- =========================================================
-- Задание 5. Для телефонных номеров, начинающихся на 8,
-- заменить первую цифру на 7.
-- SUBSTRING сохраняет часть номера после первой цифры.
-- =========================================================
UPDATE clients_2008
SET phone = '7' || SUBSTRING(phone FROM 2)
WHERE phone LIKE '8%';


-- =========================================================
-- Задание 6. Удалить клиентов с фамилиями на А, Б или В.
-- =========================================================
DELETE FROM clients_2008
WHERE last_name ILIKE 'А%'
   OR last_name ILIKE 'Б%'
   OR last_name ILIKE 'В%';


-- =========================================================
-- Задание 7. Посчитать средний срок сборки заказов
-- для каждого клиента в днях.
-- AVG — агрегатная функция среднего значения.
-- =========================================================
SELECT c.client_id,
       c.last_name,
       c.first_name,
       AVG(o.assembly_deadline - o.order_date) AS average_assembly_days
FROM clients c
JOIN orders o ON c.client_id = o.client_id
GROUP BY c.client_id, c.last_name, c.first_name
ORDER BY c.client_id;


-- =========================================================
-- Использованные встроенные/агрегатные функции:
-- AGE — вычисляет интервал между датами.
-- CURRENT_DATE — текущая дата.
-- ILIKE — поиск текста без учёта регистра.
-- SUBSTRING — извлекает часть строки.
-- AVG — вычисляет среднее значение (агрегатная функция).
-- =========================================================
