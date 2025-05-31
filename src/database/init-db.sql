-- PostgreSQL

-- Шифрование
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Схема
CREATE SCHEMA IF NOT EXISTS admin_schema;
CREATE SCHEMA IF NOT EXISTS user_schema;
CREATE SCHEMA IF NOT EXISTS employee_schema;
CREATE SCHEMA IF NOT EXISTS mechanic_schema;
CREATE SCHEMA IF NOT EXISTS app_schema;

--====================================================================================

-- создание ролей
CREATE ROLE admin_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity';
CREATE ROLE employee_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity';
CREATE ROLE mechanic_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity';
CREATE ROLE client_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity'; 
CREATE ROLE guest_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity';

--====================================================================================

-- назначение ролей для схемы admin_schema
GRANT ALL PRIVILEGES ON SCHEMA admin_schema TO admin_db WITH GRANT OPTION;
GRANT USAGE ON SCHEMA admin_schema TO employee_db, mechanic_db, client_db, guest_db;

-- назначение ролей для схемы user_schema
GRANT ALL PRIVILEGES ON SCHEMA user_schema TO admin_db WITH GRANT OPTION;
GRANT USAGE ON SCHEMA user_schema TO employee_db, mechanic_db;
GRANT USAGE ON SCHEMA user_schema TO client_db;
GRANT USAGE ON SCHEMA user_schema TO guest_db;

-- назначение ролей для схемы employee_schema
GRANT ALL PRIVILEGES ON SCHEMA employee_schema TO admin_db WITH GRANT OPTION;
GRANT USAGE ON SCHEMA employee_schema TO employee_db;
GRANT USAGE ON SCHEMA employee_schema TO mechanic_db, client_db;
GRANT USAGE ON SCHEMA employee_schema TO guest_db;

-- назначение ролей для схемы mechanic_schema
GRANT ALL PRIVILEGES ON SCHEMA mechanic_schema TO admin_db WITH GRANT OPTION;
GRANT USAGE ON SCHEMA mechanic_schema TO employee_db;
GRANT USAGE ON SCHEMA mechanic_schema TO mechanic_db;
GRANT USAGE ON SCHEMA mechanic_schema TO client_db;
GRANT USAGE ON SCHEMA mechanic_schema TO guest_db;

-- назначение ролей для схемы app_schema
GRANT ALL PRIVILEGES ON SCHEMA app_schema TO admin_db WITH GRANT OPTION;
GRANT USAGE ON SCHEMA app_schema TO employee_db;
GRANT USAGE ON SCHEMA app_schema TO mechanic_db, client_db;
GRANT USAGE ON SCHEMA app_schema TO guest_db;

--====================================================================================

/* создание таблиц */

-- Таблица Континенты.
/*  Таблица континентов производителей автомобилей. 
    Она содержит информацию о местоположении каждого производителя автомобилей.
    Например, Азия, Европа, Северная Америка и т. д. 
    Это статическая таблица, которая не изменяется со временем.
    Она позволяет связать каждый производитель автомобилей с его континентом. */
CREATE TABLE 
IF NOT EXISTS app_schema.continents
(
    continent_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица Производители.
/*  Таблица производителей автомобилей.
    Она содержит информацию о производителях автомобилей, которые
    зарегистрированы в системе.
    В ней хранятся такие данные как имя производителя, континент, на котором
    расположен производитель.
    Это статическая таблица, которая не изменяется со временем.
    Она позволяет связать каждый автомобиль с его производителем,
    а также с континентом, на котором расположен производитель. */
CREATE TABLE IF NOT EXISTS app_schema.brands
(
    brand_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    continent_id INTEGER NOT NULL,

    FOREIGN KEY (continent_id) REFERENCES app_schema.continents(continent_id)
);

-- Таблица Модели.
/*  Таблица моделей автомобилей, которые зарегистрированы в системе.
    Она содержит информацию о моделях автомобилей, которые
    зарегистрированы в системе.
    В ней хранятся такие данные как имя модели, производитель, к которому
    относится данный автомобиль.
    Это динамическая таблица, которая изменяется со временем.
    Она позволяет связать каждый автомобиль с его моделью,
    а также с производителем, к которому относится данный автомобиль. */
CREATE TABLE IF NOT EXISTS app_schema.models
(
    model_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    brand_id INTEGER NOT NULL,

    FOREIGN KEY (brand_id) REFERENCES app_schema.brands(brand_id)
);

-- Таблица Пользователи.
/*  Данная таблица предназначена для хранения данных о пользователях веб-приложения.
    Она содержит информацию о логине, пароле (который зашифрован с помощью "соли"), дате регистрации,
    а также дату последнего изменения данных о пользователе.
    Она является динамической таблицей, т.е. ее содержимое может изменяться со временем.
    Она предназначена для хранения информации о всех пользователях, которые зарегистрированы в системе,
    а также для хранения информации о дате регистрации, и дате последнего изменения данных о пользователе.
    Она является важной составляющей системы, так как позволяет идентифицировать каждого пользователя,
    а также хранить информацию о нем. */
CREATE TABLE IF NOT EXISTS user_schema.users
(
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash BYTEA NOT NULL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица Клиенты.
/*  Таблица содержит информацию о клиентах, которые зарегистрированы в системе.
    Она предназначена для хранения данных о клиентах, таких как имя, фамилия, отчество,
    дата рождения, город проживания.
    Она является важной составляющей системы, так как позволяет связать каждого клиента
    с его данными, а также с данными о его автомобилях, которые он приобрел в салоне.
    Она также позволяет связать каждого клиента с его заказами, которые он оставил в салоне.
    Она является динамической таблицей, изменяющейся со временем.
    Она предназначена для хранения информации о клиентах, которые зарегистрированы в системе,
    а также для хранения информации о данных клиента, таких как имя, фамилия, отчество,
    дата рождения, город проживания. */
CREATE TABLE IF NOT EXISTS app_schema.clients
(
    client_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    patronymic VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL,
    city VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,

    FOREIGN KEY (user_id) REFERENCES user_schema.users(user_id)
);

-- Таблица должность
/*  Данная таблица предназначена для хранения данных о должностях в компании.
    Она содержит информацию о должностях, таких как название должности.
    Она является динамической таблицей, изменяющейся со временем.
    Она предназначена для хранения информации о всех должностях в компании,
    а также для хранения информации о названии каждой должности.
    Она является важной составляющей системы, так как позволяет связать каждую должность
    с ее данными, а также с данными о сотрудниках, которые работают в данной должности. */
CREATE TABLE IF NOT EXISTS app_schema.positions
(
    position_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица Сотрудники.
/*  Данная таблица предназначена для хранения данных о сотрудниках, которые работают в компании.
    Она содержит информацию о сотрудниках, таких как имя, фамилия, отчество, дата начала работы,
    должность, номер телефона.
    Она является динамической таблицей, изменяющейся со временем.
    Она предназначена для хранения информации о всех сотрудниках, которые работают в компании,
    а также для хранения информации о дате начала работы, должности и номере телефона каждого сотрудника.
    Она является важной составляющей системы, так как позволяет связать каждого сотрудника
    с его данными, а также с данными о его должности, и номером телефона.
    Она также позволяет связать каждого сотрудника с его заказами, которые он оставил в салоне.
    Она является динамической таблицей, изменяющейся со временем.
    Она предназначена для хранения информации о сотрудниках, которые зарегистрированы в системе,
    а также для хранения информации о данных сотрудника, таких как имя, фамилия, отчество,
    дата начала работы, должность, номер телефона. */
CREATE TABLE IF NOT EXISTS employee_schema.employees
(
    employee_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    patronymic VARCHAR(255) NOT NULL,
    position_id INTEGER NOT NULL,
    hired_at DATE NOT NULL,
    phone_number VARCHAR(255) NOT NULL,

    FOREIGN KEY (user_id) REFERENCES user_schema.users(user_id),
    FOREIGN KEY (position_id) REFERENCES employee_schema.positions(position_id)
);

-- Таблица Части.
/*  Таблица частей, которые используются в ремонте автомобилей,
    Например: Колесо, Двигатель, Аккумулятор, Масло, Фильтр, Амортизатор, Ремень безопасности
    и другие запчасти, которые могут быть использованы при ремонте автомобиля.
    Является статической таблицей, изменения в которой происходят редко.
    Она предназначена для хранения информации о частях, которые могут быть использованы в ремонте,
    а также для хранения информации о цене каждой части, количестве частей на складе.
    Она позволяет связать каждый ремонт с конкретными частями, которые были использованы в этом ремонте,
    а также позволяет связать каждый заказ с конкретными частями, которые были использованы в этом заказе.
    Она является важной составляющей системы, так как позволяет связать каждый ремонт с конкретными
    частями, которые были использованы в этом ремонте, а также позволяет связать каждый заказ
    с конкретными частями, которые были использованы в этом заказе. */
CREATE TABLE IF NOT EXISTS mechanic_schema.parts
(
    part_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_qty INTEGER NOT NULL
);

-- Таблица Желаемые модели.
/*  Таблица желаемых моделей.
    Она предназначена для хранения информации о моделях автомобилей, которые клиенты
    хотели бы приобрести. Она связывает клиента с моделью автомобиля, которую он хочет
    приобрести, а также с брендом автомобиля, к которому относится модель. Она
    является динамической таблицей. */
CREATE TABLE IF NOT EXISTS app_schema.wishlists
(
    wishlist_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    model_id INTEGER NOT NULL,
    brand_id INTEGER NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id),
    FOREIGN KEY (model_id) REFERENCES app_schema.models(model_id),
    FOREIGN KEY (brand_id) REFERENCES app_schema.brands(brand_id)
);

-- Таблица Статусы.
/*  Данная таблица предназначена для хранения различных статусов, которые может иметь автомобиль.
    Например, Новый - автомобиль, который только что был доставлен на склад,
    В ремонте - автомобиль, который сейчас находится на ремонте,
    Продан - автомобиль, который уже был продан и т. д.
    Она является статической таблицей, т.е. ее содержимое не изменяется со временем.
    Она предназначена для хранения информации о различных статусах, которые может иметь автомобиль,
    а также для хранения информации о связанных с ними автомобилях. */
CREATE TABLE IF NOT EXISTS app_schema.vehicle_statuses
(
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица Роли.
/*  Данная таблица предназначена для хранения информации о типах аккаунтов,
    указывая, является ли аккаунт аккаунтом сотрудника, клиента или администратора.
    Например: client - аккаунт клиента, employee - аккаунт сотрудника, admin - аккаунт администратора.
    Таблица является статической, это значит, что она не изменяется со временем,
    и содержит фиксированный набор ролей, которые могут быть назначены пользователям.
    Она используется для контроля доступа к различным частям системы и определения
    уровня привилегий, предоставляемых каждому пользователю. */
CREATE TABLE IF NOT EXISTS user_schema.roles
(
    role_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица пользователи-ролей.
/*  Данная таблица предназначена для связи аккаунтов пользователей с ролями, которые
    они имеют. Она позволяет связать каждого пользователя с одной или несколькими ролями,
    для которых он имеет доступ. Она является динамической таблицей, изменения в которой
    могут происходить при добавлении или удалении пользователей, а также при изменении
    ролей, которые присвоены каждому пользователю. Она является важной составляющей системы,
    так как позволяет контролировать доступ к различным частям системы, и определить
    уровень привилегий, которые имеют пользователи. */
CREATE TABLE IF NOT EXISTS user_schema.user_roles
(
    user_role_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES user_schema.users(user_id),
    FOREIGN KEY (role_id) REFERENCES user_schema.roles(role_id)
);

-- Таблица транспортных средств, которые записаны в автосалоне.
/*  Данная таблица предназначена для хранения информации о транспортных средствах,
    которые зарегистрированы в системе. Она содержит информацию о VIN номере, 
    модели, производителе, году выпуска, цвете, пробеге и статусе автомобиля. 
    Она является важной составляющей системы, так как позволяет связать каждый автомобиль 
    с его данными, а также с данными о его владельце, и о заказах, которые он оставил 
    в салоне. Она является динамической таблицей, изменения в которой могут
    происходить при добавлении или удалении автомобилей, а также при изменении
    данных о них. */
CREATE TABLE IF NOT EXISTS app_schema.vehicles
(
    vehicle_id SERIAL PRIMARY KEY,
    vin VARCHAR(255) NOT NULL,
    model_id INTEGER NOT NULL,
    brand_id INTEGER NOT NULL,
    year SMALLINT NOT NULL,
    color VARCHAR(255) NOT NULL,
    mileage INTEGER NOT NULL,
    status_id INTEGER NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (model_id) REFERENCES app_schema.models(model_id),
    FOREIGN KEY (brand_id) REFERENCES app_schema.brands(brand_id),
    FOREIGN KEY (status_id) REFERENCES app_schema.vehicle_statuses(status_id)
);

-- Таблица ремонтных заказов.
/*  Данная таблица предназначена для хранения информации о заказах на ремонт транспортных средств.
    Она позволяет отслеживать каждую заявку на ремонт, включая идентификатор заказа, транспортное средство,
    на которое оформлен заказ, дату открытия и закрытия заказа, статус выполнения заказа, а также общую стоимость.
    Эта информация позволяет легко управлять и контролировать процессы ремонта, а также анализировать 
    текущие и прошлые заказы для улучшения обслуживания клиентов. */
CREATE TABLE IF NOT EXISTS mechanic_schema.repair_orders
(
    order_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    created_by VARCHAR(255) NOT NULL,
    assigned_to VARCHAR(255) NOT NULL,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP DEFAULT,
    status INTEGER NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id)  
);

-- Таблица частей для ремонтных заказов.
/*  Данная таблица предназначена для хранения информации о частях, которые необходимы для ремонта
    транспортных средств. Она содержит информацию о названии, цене, описании и идентификаторе части.
    Она является важной составляющей системы, так как позволяет связать каждую часть с ее данными,
    а также с данными о заказах, в которых она используется. Она является динамической таблицей,
    изменения в которой могут происходить при добавлении или удалении частей, а также при изменении
    данных о них. */
CREATE TABLE IF NOT EXISTS mechanic_schema.repair_parts
(
    repair_part_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    part_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    line_cost DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (order_id) REFERENCES mechanic_schema.repair_orders(order_id),
    FOREIGN KEY (part_id) REFERENCES mechanic_schema.parts(part_id)
);

-- Таблица фотографий транспортных средств.
/*  Данная таблица предназначена для хранения информации о фотографиях транспортных средств.
    Она содержит информацию о идентификаторе фотографии, идентификаторе транспортного средства,
    пути к фотографии и дате загрузки. Она является важной составляющей системы, так как позволяет
    связать каждую фотографию с ее данными, а также с данными о транспортных средствах, в которых
    она используется. Она является динамической таблицей, изменения в которой могут происходить
    при добавлении или удалении фотографий, а также при изменении данных о них. */
CREATE TABLE IF NOT EXISTS app_schema.vehicle_photos
(
    photo_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    photo_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id)
);

-- Таблица тест-драивов.
/*  Данная таблица предназначена для хранения информации о тест-драивах.
    Она содержит информацию о идентификаторе тест-драива, идентификаторе транспортного средства,
    идентификаторе клиента, идентификаторе сотрудника, дате запланированного тест-драива,
    дате фактического тест-драива. Она является важной составляющей системы, так как позволяет
    связать каждый тест-драив с его данными, а также с данными о транспортных средствах, в которых
    он используется. Она является динамической таблицей, изменения в которой могут происходить
    при добавлении или удалении тест-драивов, а также при изменении данных о них. */
CREATE TABLE IF NOT EXISTS app_schema.test_drives
(
    test_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    scheduled_by INTEGER NOT NULL,
    scheduled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actual_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id),
    FOREIGN KEY (scheduled_by) REFERENCES employee_schema.employees(employee_id)
);

-- Таблица истории владельцев.
/*  Данная таблица предназначена для хранения информации о владельцах транспортных средств.
    Она содержит информацию о идентификаторе истории владельца, идентификаторе транспортного
    средства, идентификаторе клиента, дате начала владения и дате окончания владения.  
    Она является важной составляющей системы, так как позволяет связать каждую историю владельца
    с ее данными, а также с данными о транспортных средствах, в которых он используется.
    Она является динамической таблицей, изменения в которой могут происходить при добавлении
    или удалении историй владельцев, а также при изменении данных о них. */
CREATE TABLE IF NOT EXISTS admin_schema.ownership_history
(
    history_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    from_date DATE NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id)
);

-- Таблица контрактов.
/*  Данная таблица предназначена для хранения информации о контрактах.
    Она содержит информацию о идентификаторе контракта, идентификаторе транспортного
    средства, идентификаторе клиента, идентификаторе сотрудника, идентификаторе типа контракта,
    идентификаторе типа оплаты, дате заключения контракта, общую стоимость контракта.
    Она является важной составляющей системы, так как позволяет связать каждый контракт с его
    данными, а также с данными о транспортных средствах, в которых он используется, клиентах,
    сотрудниках, типах контрактов и типах оплаты. Она является динамической таблицей, изменения
    в которой могут происходить при добавлении или удалении контрактов, а также при изменении
    данных о них. */
CREATE TABLE IF NOT EXISTS employee_schema.contract_types
(
    type_contract_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL  
);

-- Таблица контрактов.
/*  Данная таблица предназначена для хранения информации о контрактах.
    Она содержит информацию о идентификаторе оплаты, названии оплаты.
    Она является важной составляющей системы, так как позволяет связать каждую оплату с ее данными.
    Она является динамической таблицей, изменения в которой могут происходить при добавлении
    или удалении оплат, а также при изменении данных о них. */
CREATE TABLE IF NOT EXISTS employee_schema.payment_types
(
    payment_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL  
);

-- Таблица контрактов.
/*  Данная таблица предназначена для хранения информации о контрактах.
    Она содержит информацию о идентификаторе контракта, идентификаторе транспортного
    средства, идентификаторе клиента, идентификаторе сотрудника, идентификаторе типа контракта,
    идентификаторе типа оплаты, дате заключения контракта, общую стоимость контракта.
    Она является важной составляющей системы, так как позволяет связать каждый контракт с его
    данными, а также с данными о транспортных средствах, в которых он используется, клиентах,
    сотрудниках, типах контрактов и типах оплаты. Она является динамической таблицей, изменения
    в которой могут происходить при добавлении или удалении контрактов, а также при изменении
    данных о них. */
CREATE TABLE IF NOT EXISTS employee_schema.contracts
(
    contract_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    type_id INTEGER NOT NULL,
    payment_id INTEGER NOT NULL,
    history_id INTEGER NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id),
    FOREIGN KEY (employee_id) REFERENCES employee_schema.employees(employee_id),
    FOREIGN KEY (type_id) REFERENCES employee_schema.contract_types(type_contract_id),
    FOREIGN KEY (payment_id) REFERENCES employee_schema.payment_types(payment_id),
    FOREIGN KEY (history_id) REFERENCES employee_schema.history_owners(history_id)
);

-- Таблица паспортов.
/*  Данная таблица предназначена для хранения информации о паспортах.
    Она содержит информацию о идентификаторе паспорта, идентификаторе клиента,
    серии паспорта, номере паспорта, органе выдачи, дате выдачи.
    Она является важной составляющей системы, так как позволяет связать каждый паспорт с его
    данными, а также с данными о клиентах. Она является динамической таблицей, изменения
    в которой могут происходить при добавлении или удалении паспортов, а также при изменении
    данных о них. */
CREATE TABLE IF NOT EXISTS user_schema.passports
(
    passport_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    series VARCHAR(255) NOT NULL,
    number VARCHAR(255) NOT NULL,
    issued_by VARCHAR(255) NOT NULL,
    issued_date DATE NOT NULL,  

    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id)
);

--====================================================================================

-- разграничение доступа для таблиц

-- user_schema tables
GRANT SELECT, INSERT ON user_schema.users TO client_db;
GRANT SELECT ON user_schema.users TO guest_db;
GRANT SELECT, INSERT, UPDATE ON user_schema.passports TO client_db;

-- app_schema tables
GRANT SELECT, INSERT ON app_schema.clients TO client_db;
GRANT SELECT ON app_schema.clients TO guest_db;
GRANT SELECT, INSERT, UPDATE ON app_schema.vehicles TO employee_db;
GRANT SELECT ON app_schema.vehicle_photos TO guest_db;
GRANT SELECT, INSERT ON app_schema.test_drives TO employee_db;

-- employee_schema tables
GRANT SELECT, INSERT, UPDATE ON employee_schema.employees TO employee_db;
GRANT SELECT ON employee_schema.employees TO guest_db;
GRANT SELECT, INSERT, UPDATE ON employee_schema.contracts TO employee_db;
GRANT SELECT ON employee_schema.contract_types TO guest_db;
GRANT SELECT ON employee_schema.payment_types TO guest_db;

-- mechanic_schema tables
GRANT SELECT, INSERT, UPDATE ON mechanic_schema.repair_orders TO mechanic_db;
GRANT SELECT ON mechanic_schema.parts TO guest_db;
GRANT SELECT, INSERT ON mechanic_schema.repair_parts TO mechanic_db;

-- admin_schema tables
GRANT SELECT ON admin_schema.ownership_history TO guest_db;
GRANT SELECT, INSERT, UPDATE ON admin_schema.ownership_history TO admin_db;

-- Процедура: app_schema.select_continent(p_continent_id INTEGER)
/*  Функция: Создает запрос на выборку названия континента
    по его идентификатору.
    Она принимает идентификатор континента в качестве параметра.
    Она используется для получения названия континента по его идентификатору.
*/
CREATE OR REPLACE 
PROCEDURE app_schema.select_continent(p_continent_id INTEGER)
AS $$
BEGIN
    SELECT name 
    FROM app_schema.continents 
    WHERE continent_id = p_continent_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_continent(1);

-- Процедура: app_schema.insert_continent(p_name VARCHAR(255))
/*  Функция: Создает запрос на вставку нового континента в таблицу.
    Она принимает название континента в качестве параметра.
    Она используется для добавления нового континента в систему. 
*/
CREATE OR REPLACE 
PROCEDURE app_schema.insert_continent(p_name VARCHAR(255))
AS $$
BEGIN
    INSERT INTO app_schema.continents(name) 
    VALUES(p_name);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_continent('Europe');

-- Процедура: app_schema.update_continent(p_continent_id INTEGER, p_name VARCHAR(255))
/*  Функция: Создает запрос на обновление названия континента в таблице.
    Она принимает идентификатор континента и новое название в качестве параметров.
    Она используется для обновления названия континента в системе. 
*/
CREATE OR REPLACE
PROCEDURE app_schema.update_continent(p_continent_id INTEGER, p_name VARCHAR(255))
AS $$
BEGIN
    UPDATE app_schema.continents 
    SET name = p_name 
    WHERE continent_id = p_continent_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_continent(1, 'North America');

-- Процедура: app_schema.delete_continent(p_continent_id INTEGER)
/*  Функция: Создает запрос на удаление континента из таблицы.
    Она принимает идентификатор континента в качестве параметра.
    Она используется для удаления континента из системы. 
*/
CREATE OR REPLACE
PROCEDURE app_schema.delete_continent(p_continent_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.continents 
    WHERE continent_id = p_continent_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_continent(1);

-- Процедура: app_schema.select_brand(p_brand_id INTEGER)
/*  Функция: Создает запрос на выборку названия марок авто
    по его идентификатору.
    Она принимает идентификатор марки в качестве параметра.
    Она используется для получения названия марки по его идентификатору.
*/
CREATE OR REPLACE 
PROCEDURE app_schema.select_brand(p_brand_id INTEGER)
AS $$
BEGIN
    SELECT name 
    FROM app_schema.brands 
    WHERE brand_id = p_brand_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_brand(1);

-- Процедура: app_schema.insert_brand(p_name VARCHAR(255), p_continent_id INTEGER)
/*  Функция: Создает запрос на вставку новой марки в таблицу.
    Она принимает название марки и идентификатор континента в качестве параметров.
    Она используется для добавления новой марки в систему. 
*/
CREATE OR REPLACE
PROCEDURE app_schema.insert_brand(p_name VARCHAR(255), p_continent_id INTEGER)
AS $$
BEGIN
    INSERT INTO app_schema.brands(name, continent_id) 
    VALUES(p_name, p_continent_id);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_brand('Toyota', 1);

-- Процедура: app_schema.update_brand(p_brand_id INTEGER, p_name VARCHAR(255), p_continent_id INTEGER)
/*  Функция: Создает запрос на обновление названия марки и континента в таблице.
    Она принимает идентификатор марки, новое название и идентификатор континента в качестве параметров.
    Она используется для обновления названия марки и континента в системе. 
*/
CREATE OR REPLACE 
PROCEDURE app_schema.update_brand(p_brand_id INTEGER, p_name VARCHAR(255), p_continent_id INTEGER)
AS $$
BEGIN
    UPDATE app_schema.brands 
    SET name = p_name, continent_id = p_continent_id 
    WHERE brand_id = p_brand_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_brand(1, 'Honda', 1);

-- Процедура: app_schema.delete_brand(p_brand_id INTEGER)
/*  Функция: Создает запрос на удаление марки из таблицы.
    Она принимает идентификатор марки в качестве параметра.
    Она используется для удаления марки из системы. 
*/
CREATE OR REPLACE
PROCEDURE app_schema.delete_brand(p_brand_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.brands 
    WHERE brand_id = p_brand_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_brand(1);

-- Процедура: app_schema.select_model(p_model_id INTEGER)
/*  Функция: Создает запрос на выборку названия модели по его идентификатору.
    Она принимает идентификатор модели в качестве параметра.
    Она используется для получения названия модели по его идентификатору.
*/
CREATE OR REPLACE 
PROCEDURE app_schema.select_model(p_model_id INTEGER)
AS $$
BEGIN
    SELECT name 
    FROM app_schema.models 
    WHERE model_id = p_model_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_model(1);

-- Процедура: app_schema.insert_model(p_name VARCHAR(255), p_brand_id INTEGER)
/*  Функция: Создает запрос на вставку новой модели в таблицу.
    Она принимает название модели и идентификатор марки в качестве параметров.
    Она используется для добавления новой модели в систему. 
*/
CREATE OR REPLACE 
PROCEDURE app_schema.insert_model(p_name VARCHAR(255), p_brand_id INTEGER)
AS $$
BEGIN
    INSERT INTO app_schema.models(name, brand_id) 
    VALUES(p_name, p_brand_id);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_model('Camry', 1);

-- Процедура: app_schema.update_model(p_model_id INTEGER, p_name VARCHAR(255), p_brand_id INTEGER)
/*  Функция: Создает запрос на обновление названия модели и марки в таблице.
    Она принимает идентификатор модели, новое название и идентификатор марки в качестве параметров.
    Она используется для обновления названия модели и марки в системе. 
*/
CREATE OR REPLACE 
PROCEDURE app_schema.update_model(p_model_id INTEGER, p_name VARCHAR(255), p_brand_id INTEGER)
AS $$
BEGIN
    UPDATE app_schema.models 
    SET name = p_name, brand_id = p_brand_id 
    WHERE model_id = p_model_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_model(1, 'Corolla', 1);

-- Процедура: app_schema.delete_model(p_model_id INTEGER)
/*  Функция: Создает запрос на удаление модели из таблицы.
    Она принимает идентификатор модели в качестве параметра.
    Она используется для удаления модели из системы.
*/
CREATE OR REPLACE 
PROCEDURE app_schema.delete_model(p_model_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.models 
    WHERE model_id = p_model_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_model(1);

-- Процедура: app_schema.select_user(p_user_id INTEGER)
/*  Функция: Создает запрос на выборку email пользователя по его идентификатору.
    Она принимает идентификатор пользователя в качестве параметра.
    Она используется для получения email пользователя по его идентификатору.
*/
CREATE OR REPLACE 
PROCEDURE app_schema.select_user(p_user_id INTEGER)
AS $$
BEGIN
    SELECT email 
    FROM app_schema.users 
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_user(1);

/*  Функция: Создает запрос на вставку нового пользователя в таблицу.
    Она принимает email пользователя, хэш пароля и соль в качестве параметров.
    Она используется для добавления нового пользователя в систему. 
*/
CREATE OR REPLACE PROCEDURE user_schema.insert_user(
    p_email VARCHAR(255), 
    p_password VARCHAR(255)
) 
LANGUAGE plpgsql AS $$
BEGIN
    -- Хешируем пароль перед вставкой
    INSERT INTO user_schema.users(email, password_hash) 
    VALUES (p_email, crypt(p_password, gen_salt('bf')));
END;
$$;
-- Вызов: CALL user_schema.insert_user('7Kq9E@example.com', 'password_hash', 'salt');

/*  Функция: Создает запрос на обновление данных пользователя в таблице.
    Она принимает идентификатор пользователя, новый email, хэш пароля и соль в качестве параметров.
    Она используется для обновления данных пользователя в системе.
*/
CREATE OR REPLACE PROCEDURE user_schema.update_user(
    p_user_id INTEGER, 
    p_email VARCHAR(255), 
    p_password VARCHAR(255)
) 
LANGUAGE plpgsql AS $$
DECLARE
    v_user_exists BOOLEAN;
BEGIN
    -- Проверяем, существует ли пользователь
    SELECT EXISTS (SELECT 1 FROM user_schema.users WHERE user_id = p_user_id) INTO v_user_exists;
    
    IF NOT v_user_exists THEN
        RAISE EXCEPTION 'User ID % not found', p_user_id;
    END IF;

    -- Обновляем данные и хешируем новый пароль
    UPDATE user_schema.users 
    SET email = p_email, password_hash = crypt(p_password, gen_salt('bf'))
    WHERE user_id = p_user_id;
END;
$$;

-- Вызов: CALL user_schema.update_user(1, '7Kq9E@example.com', 'password_hash', 'salt');

-- Процедура: user_schema.delete_user(p_user_id INTEGER)
/*  Функция: Создает запрос на удаление пользователя из таблицы.
    Она принимает идентификатор пользователя в качестве параметра.
    Она используется для удаления пользователя из системы. 
*/
CREATE OR REPLACE 
PROCEDURE user_schema.delete_user(p_user_id INTEGER)
AS $$
BEGIN
    DELETE FROM user_schema.users 
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.delete_user(1);

-- Процедура: app_schema.select_client(p_client_id INTEGER)
/*  Функция: Создает запрос на выборку данных о клиенте по его идентификатору.
    Она принимает идентификатор клиента в качестве параметра.
    Она используется для получения данных о клиенте по его идентификатору.
*/
CREATE OR REPLACE
PROCEDURE app_schema.select_client(p_client_id INTEGER)
AS $$
BEGIN
    SELECT * 
    FROM app_schema.clients 
    WHERE client_id = p_client_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_client(1);

-- Процедура: app_schema.insert_client(p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_birth_date DATE, p_city VARCHAR(255), p_phone VARCHAR(255))
/*  Функция: Создает запрос на вставку нового клиента в таблицу. 
    Оно принимает идентификатор пользователя, имя, фамилию, отчество, дату рождения и город в качестве параметров.
    Она используется для добавления нового клиента в систему.
*/
CREATE OR REPLACE 
PROCEDURE app_schema.insert_client(p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_birth_date DATE, p_city VARCHAR(255), p_phone VARCHAR(255))
AS $$
BEGIN
    INSERT INTO app_schema.clients(user_id, firstname, lastname, patronymic, birth_date, city, phone) 
    VALUES(p_user_id, p_firstname, p_lastname, p_patronymic, p_birth_date, p_city, p_phone);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_client(1, 'John', 'Smith', 'Petrovich', '1990-01-01', 'New York', '123-456-7890');

-- Процедура: app_schema.update_client(p_client_id INTEGER, p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_birth_date DATE, p_city VARCHAR(255), p_phone VARCHAR(255))
/*  Функция: Создает запрос на обновление данных о клиенте в таблице.
    Она принимает идентификатор клиента, новые данные о клиенте в качестве параметров.
    Она используется для обновления данных о клиенте в системе.
*/
CREATE OR REPLACE
PROCEDURE app_schema.update_client(p_client_id INTEGER, p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_birth_date DATE, p_city VARCHAR(255), p_phone VARCHAR(255))
AS $$
BEGIN
    UPDATE app_schema.clients 
    SET user_id = p_user_id, firstname = p_firstname, lastname = p_lastname, patronymic = p_patronymic, birth_date = p_birth_date, city = p_city, phone = p_phone 
    WHERE client_id = p_client_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_client(1, 1, 'John', 'Smith', 'Petrovich', '1990-01-01', 'New York', '123-456-7890');

-- Процедура: app_schema.delete_client(p_client_id INTEGER)
/*  Функция: Создает запрос на удаление клиента из таблицы.
    Она принимает идентификатор клиента в качестве параметра.
    Она используется для удаления клиента из системы. 
*/
CREATE OR REPLACE
PROCEDURE app_schema.delete_client(p_client_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.clients 
    WHERE client_id = p_client_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_client(1);

-- Процедура: employee_schema.select_position(p_position_id INTEGER)
/*  Функция: Создает запрос на выборку данных о должности по ее идентификатору.
    Она принимает идентификатор должности в качестве параметра.
    Она используется для получения данных о должности по ее идентификатору. 
*/
CREATE OR REPLACE
PROCEDURE employee_schema.select_position(p_position_id INTEGER)
AS $$
BEGIN
    SELECT * 
    FROM employee_schema.positions 
    WHERE position_id = p_position_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.select_position(1);

-- Процедура: employee_schema.insert_position(p_name VARCHAR(255))
/*  Функция: Создает запрос на вставку новой должности в таблицу.
    Она принимает название должности в качестве параметра.
    Она используется для добавления новой должности в систему. 
*/
CREATE OR REPLACE
PROCEDURE employee_schema.insert_position(p_name VARCHAR(255))
AS $$
BEGIN
    INSERT INTO employee_schema.positions(name) VALUES(p_name);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.insert_position('Manager');

-- Процедура: employee_schema.update_position(p_position_id INTEGER, p_name VARCHAR(255))
/*  Функция: Создает запрос на обновление данных о должности в таблице.
    Она принимает идентификатор должности и новое название должности в качестве параметров.
    Она используется для обновления данных о должности в системе. */
CREATE OR REPLACE
PROCEDURE employee_schema.update_position(p_position_id INTEGER, p_name VARCHAR(255))
AS $$
BEGIN
    UPDATE employee_schema.positions 
    SET name = p_name 
    WHERE position_id = p_position_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.update_position(1, 'Manager');

-- Процедура: employee_schema.delete_position(p_position_id INTEGER)
/*  Функция: Создает запрос на удаление должности из таблицы.
    Она принимает идентификатор должности в качестве параметра.
    Она используется для удаления должности из системы. 
*/
CREATE OR REPLACE
PROCEDURE employee_schema.delete_position(p_position_id INTEGER)
AS $$
BEGIN
    DELETE FROM employee_schema.positions 
    WHERE position_id = p_position_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.delete_position(1);

-- Процедура: employee_schema.select_employee(p_employee_id INTEGER)
/*  Функция: Создает запрос на выборку данных о сотруднике по его идентификатору.
    Она принимает идентификатор сотрудника в качестве параметра.
    Она используется для получения данных о сотруднике из системы. 
*/
CREATE OR REPLACE
PROCEDURE employee_schema.select_employee(p_employee_id INTEGER)
AS $$
BEGIN
    SELECT * 
    FROM employee_schema.employees 
    WHERE employee_id = p_employee_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.select_employee(1);

-- Процедура: employee_schema.insert_employee(p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_position_id INTEGER, p_hired_at DATE, p_phone VARCHAR(255))
/*  Функция: Создает запрос на вставку нового сотрудника в таблицу. 
    Она принимает идентификатор пользователя, имя, фамилию и отчество, идентификатор должности, дату приема на работу и номер телефона в качестве параметров.
    Она используется для добавления нового сотрудника в систему.
*/
CREATE OR REPLACE 
PROCEDURE employee_schema.insert_employee(p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_position_id INTEGER, p_hired_at DATE, p_phone VARCHAR(255))
AS $$
BEGIN
    INSERT INTO employee_schema.employees(user_id, firstname, lastname, patronymic, position_id, hired_at, phone) 
    VALUES(p_user_id, p_firstname, p_lastname, p_patronymic, p_position_id, p_hired_at, p_phone);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.insert_employee(1, 'John', 'Smith', 'Petrovich', 1, '2022-01-01', '123-456-7890');

-- Процедура: employee_schema.update_employee(p_employee_id INTEGER, p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_position_id INTEGER, p_hired_at DATE, p_phone_number VARCHAR(255))
/*  Функция: Создает запрос на обновление данных о сотруднике в таблице. 
    Она принимает индексатор сотрудника, юзера, имя, фамилию, отчество, должность, дату приема на работу и номер телефона в качестве параметров.
    Она используется для обновления данных о сотруднике в системе.
*/
CREATE OR REPLACE 
PROCEDURE employee_schema.update_employee(p_employee_id INTEGER, p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_position_id INTEGER, p_hired_at DATE, p_phone_number VARCHAR(255))
AS $$
BEGIN
    UPDATE employee_schema.employees 
    SET user_id = p_user_id, firstname = p_firstname, lastname = p_lastname, patronymic = p_patronymic, position_id = p_position_id, hired_at = p_hired_at, phone = p_phone_number 
    WHERE employee_id = p_employee_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.update_employee(1, 1, 'John', 'Smith', 'Petrovich', 1, '2022-01-01', '123-456-7890');

-- Процедура: employee_schema.delete_employee(p_employee_id INTEGER)
/*  Функция: Создает запрос на удаление сотрудника из таблицы.
    Она принимает идентификатор сотрудника в качестве параметра.
    Она используется для удаления сотрудника из системы. 
*/
CREATE OR REPLACE
PROCEDURE employee_schema.delete_employee(p_employee_id INTEGER)
AS $$
BEGIN
    DELETE FROM employee_schema.employees 
    WHERE employee_id = p_employee_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.delete_employee(1);

-- Процедура: mechanic_schema.select_part(p_part_id INTEGER)
/*  Функция: Создает запрос на выборку данных о запчасти по ее идентификатору.
    Она принимает идентификатор запчасти в качестве параметра.
    Она используется для получения данных о запчасти из системы. 
*/
CREATE OR REPLACE
PROCEDURE mechanic_schema.select_part(p_part_id INTEGER)
AS $$
BEGIN
    SELECT * FROM mechanic_schema.parts 
    WHERE part_id = p_part_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.select_part(1);

-- Процедура: mechanic_schema.insert_part(p_name VARCHAR(255), p_unit_price DECIMAL(10, 2), p_stock_qty INTEGER)
/*  Функция: Создает запрос на добавление новой запчасти в таблицу.
    Она принимает название, цену и количество запчастей в качестве параметров.
    Она используется для добавления новой запчасти в систему. 
*/
CREATE OR REPLACE
PROCEDURE mechanic_schema.insert_part(p_name VARCHAR(255), p_unit_price DECIMAL(10, 2), p_stock_qty INTEGER)
AS $$
BEGIN
    INSERT INTO mechanic_schema.parts(name, unit_price, stock_qty) 
    VALUES(p_name, p_unit_price, p_stock_qty);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.insert_part('Tire', 100.00, 10);

-- Процедура: mechanic_schema.update_part(p_part_id INTEGER, p_name VARCHAR(255), p_unit_price DECIMAL(10, 2), p_stock_qty INTEGER)
/*  Функция: Создает запрос на обновление данных о запчасти в таблице.
    Она принимает идентификатор запчасти, название, цену и количество запчастей в качестве параметров.
    Она используется для обновления данных о запчасти в системе. */
CREATE OR REPLACE 
PROCEDURE mechanic_schema.update_part(p_part_id INTEGER, p_name VARCHAR(255), p_unit_price DECIMAL(10, 2), p_stock_qty INTEGER)
AS $$
BEGIN
    UPDATE mechanic_schema.parts 
    SET name = p_name, unit_price = p_unit_price, stock_qty = p_stock_qty 
    WHERE part_id = p_part_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.update_part(1, 'Tire', 100.00, 10);

-- Процедура: mechanic_schema.delete_part(p_part_id INTEGER)
/*  Функция: Создает запрос на удаление запчасти из таблицы.
    Она принимает идентификатор запчасти в качестве параметра.
    Она используется для удаления запчасти из системы. */
CREATE OR REPLACE
PROCEDURE mechanic_schema.delete_part(p_part_id INTEGER)
AS $$
BEGIN
    DELETE FROM mechanic_schema.parts 
    WHERE part_id = p_part_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.delete_part(1);

-- Процедура: app_schema.select_wishlist(p_wishlist_id INTEGER)
/*  Функция: Создает запрос на выборку данных о списке желаний по идентификатору.
    Она принимает идентификатор списка желаний в качестве параметра.
    Она используется для получения данных о списке желаний из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.select_wishlist(p_wishlist_id INTEGER)
AS $$
BEGIN
    SELECT * FROM app_schema.wishlists 
    WHERE wishlist_id = p_wishlist_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_wishlist(1);

-- Процедура: app_schema.insert_wishlist(p_client_id INTEGER, p_model_id INTEGER, p_brand_id INTEGER)
/*  Функция: Создает запрос на добавление нового списка желаний в таблицу.
    Она принимает идентификатор клиента, идентификатор модели и идентификатор бренда в качестве параметров.
    Она используется для добавления нового списка желаний в систему. */
CREATE OR REPLACE
PROCEDURE app_schema.insert_wishlist(p_client_id INTEGER, p_model_id INTEGER, p_brand_id INTEGER)
AS $$
BEGIN
    INSERT INTO app_schema.wishlists(client_id, model_id, brand_id) 
    VALUES(p_client_id, p_model_id, p_brand_id);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_wishlist(1, 1, 1);

-- Процедура: app_schema.update_wishlist(p_wishlist_id INTEGER, p_client_id INTEGER, p_model_id INTEGER, p_brand_id INTEGER)
/*  Функция: Создает запрос на обновление данных о списке желаний в таблице.
    Она принимает идентификатор списка желаний, идентификатор клиента, идентификатор модели и идентификатор бренда в качестве параметров.
    Она используется для обновления данных о списке желаний в системе.
*/
CREATE OR REPLACE
PROCEDURE app_schema.update_wishlist(p_wishlist_id INTEGER, p_client_id INTEGER, p_model_id INTEGER, p_brand_id INTEGER)
AS $$
BEGIN
    UPDATE app_schema.wishlists 
    SET client_id = p_client_id, model_id = p_model_id, brand_id = p_brand_id 
    WHERE wishlist_id = p_wishlist_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_wishlist(1, 1, 1, 1);

-- Процедура: app_schema.delete_wishlist(p_wishlist_id INTEGER)
/*  Функция: Удаляет список желаний из таблицы.
    Она принимает идентификатор списка желаний в качестве параметра.
    Она используется для удаления списка желаний из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.delete_wishlist(p_wishlist_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.wishlists 
    WHERE wishlist_id = p_wishlist_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_wishlist(1);

-- Процедура: app_schema.select_vehicle_status(p_vehicle_status_id INTEGER)
/*  Функция: Создает запрос на выборку данных о статусе автомобиля по идентификатору.
    Она принимает идентификатор статуса автомобиля в качестве параметра.
    Она используется для получения данных о статусе автомобиля из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.select_vehicle_status(p_vehicle_status_id INTEGER)
AS $$
BEGIN
    SELECT * FROM app_schema.vehicle_statuses 
    WHERE vehicle_status_id = p_vehicle_status_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_vehicle_status(1);

-- Процедура: app_schema.insert_vehicle_status(p_name VARCHAR(255))
/*  Функция: Создает запрос на добавление нового статуса автомобиля в таблицу.
    Она принимает название статуса автомобиля в качестве параметра.
    Она используется для добавления нового статуса автомобиля в систему. */
CREATE OR REPLACE
PROCEDURE app_schema.insert_vehicle_status(p_name VARCHAR(255))
AS $$
BEGIN
    INSERT INTO app_schema.vehicle_statuses(name) 
    VALUES(p_name);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_vehicle_status('Not Available');

-- Процедура: app_schema.update_vehicle_status(p_vehicle_status_id INTEGER, p_name VARCHAR(255))
/*  Функция: Обновляет данные о статусе автомобиля в таблице.
    Она принимает идентификатор статуса автомобиля и название статуса в качестве параметров.
    Она используется для обновления данных о статусе автомобиля в системе. */
CREATE OR REPLACE
PROCEDURE app_schema.update_vehicle_status(p_vehicle_status_id INTEGER, p_name VARCHAR(255))
AS $$
BEGIN
    UPDATE app_schema.vehicle_statuses 
    SET name = p_name 
    WHERE vehicle_status_id = p_vehicle_status_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_vehicle_status(1, 'Not Available');

-- Процедура: app_schema.delete_vehicle_status(p_vehicle_status_id INTEGER)
/*  Функция: Удаляет статус автомобиля из таблицы.
    Она принимает идентификатор статуса автомобиля в качестве параметра.
    Она используется для удаления статуса автомобиля из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.delete_vehicle_status(p_vehicle_status_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.vehicle_statuses 
    WHERE vehicle_status_id = p_vehicle_status_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_vehicle_status(1);

-- Процедура: app_schema.select_role(p_role_id INTEGER)
/*  Функция: Создает запрос на выборку данных о роли пользователя по идентификатору.
    Она принимает идентификатор роли пользователя в качестве параметра.
    Она используется для получения данных о роли пользователя из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.select_role(p_role_id INTEGER)
AS $$
BEGIN
    SELECT * FROM user_schema.roles 
    WHERE role_id = p_role_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_role(1);

-- Процедура: user_schema.insert_role(p_name VARCHAR(255))
/*  Функция: Создает запрос на добавление новой роли пользователя в таблицу.
    Она принимает название роли пользователя в качестве параметра.
    Она используется для добавления новой роли пользователя в систему. */
CREATE OR REPLACE
PROCEDURE user_schema.insert_role(p_name VARCHAR(255))
AS $$
BEGIN
    INSERT INTO user_schema.roles(name) 
    VALUES(p_name);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.insert_role('User');

-- Процедура: user_schema.update_role(p_role_id INTEGER, p_name VARCHAR(255))
/*  Функция: Обновляет данные о роли пользователя в таблице.
    Она принимает идентификатор роли пользователя и название роли в качестве параметров.
    Она используется для обновления данных о роли пользователя в системе. */
CREATE OR REPLACE
PROCEDURE user_schema.update_role(p_role_id INTEGER, p_name VARCHAR(255))
AS $$
BEGIN
    UPDATE user_schema.roles 
    SET name = p_name 
    WHERE role_id = p_role_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.update_role(1, 'User');

-- Процедура: user_schema.delete_role(p_role_id INTEGER)
/*  Функция: Удаляет роль пользователя из таблицы.
    Она принимает идентификатор роли пользователя в качестве параметра.
    Она используется для удаления роли пользователя из системы. */
CREATE OR REPLACE 
PROCEDURE user_schema.delete_role(p_role_id INTEGER)
AS $$
BEGIN
    DELETE FROM user_schema.roles 
    WHERE role_id = p_role_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.delete_role(1);

-- Процедура: user_schema.select_user_role(p_user_role_id INTEGER)
/*  Функция: Создает запрос на выборку данных о роли пользователя по идентификатору.
    Она принимает идентификатор роли пользователя в качестве параметра.
    Она используется для получения данных о роли пользователя из системы. */
CREATE OR REPLACE
PROCEDURE user_schema.select_user_role(p_user_role_id INTEGER)
AS $$
BEGIN
    SELECT * FROM user_schema.user_roles 
    WHERE user_role_id = p_user_role_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.select_user_role(1);

-- Процедура: user_schema.insert_user_role(p_user_id INTEGER, p_role_id INTEGER)
/*  Функция: Создает запрос на добавление новой роли пользователя в таблицу.
    Она принимает идентификатор пользователя и идентификатор роли в качестве параметров.
    Она используется для добавления новой роли пользователя в систему. */
CREATE OR REPLACE
PROCEDURE user_schema.insert_user_role(p_user_id INTEGER, p_role_id INTEGER)
AS $$
BEGIN
    INSERT INTO user_schema.user_roles(user_id, role_id) 
    VALUES(p_user_id, p_role_id);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.insert_user_role(1, 1);

-- Процедура: user_schema.update_user_role(p_user_role_id INTEGER, p_user_id INTEGER, p_role_id INTEGER)
/*  Функция: Обновляет данные о связи пользователя с ролью в таблице user_roles.
    Она принимает идентификатор связи пользователя с ролью, идентификатор пользователя 
    и идентификатор роли в качестве параметров.
    Эта процедура используется для изменения роли, присвоенной пользователю, 
    или для изменения пользователя, к которому применена роль. */
CREATE OR REPLACE 
PROCEDURE user_schema.update_user_role(p_user_role_id INTEGER, p_user_id INTEGER, p_role_id INTEGER)
AS $$
BEGIN
    UPDATE user_schema.user_roles 
    SET user_id = p_user_id, role_id = p_role_id 
    WHERE user_role_id = p_user_role_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.update_user_role(1, 1, 1);

-- Процедура: user_schema.delete_user_role(p_user_role_id INTEGER)
/*  Функция: Удаляет связь пользователя с ролью из таблицы user_roles.
    Она принимает идентификатор связи пользователя с ролью в качестве параметра.
    Она используется для удаления связи пользователя с ролью из системы. */
CREATE OR REPLACE
PROCEDURE user_schema.delete_user_role(p_user_role_id INTEGER)
AS $$
BEGIN
    DELETE FROM user_schema.user_roles 
    WHERE user_role_id = p_user_role_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.delete_user_role(1);

-- Процедура: app_schema.select_vehicle(p_vehicle_id INTEGER)
/*  Функция: Создает запрос на выборку данных о автомобиле по идентификатору.
    Она принимает идентификатор автомобиля в качестве параметра.
    Она используется для получения данных об автомобиле из система. */
CREATE OR REPLACE 
PROCEDURE app_schema.select_vehicle(p_vehicle_id INTEGER)
AS $$
BEGIN
    SELECT * FROM app_schema.vehicles 
    WHERE vehicle_id = p_vehicle_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_vehicle(1);

-- Процедура: app_schema.insert_vehicle(p_vin VARCHAR(255), p_model_id INTEGER, p_brand_id INTEGER, p_year SMALLINT, p_color VARCHAR(255), p_mileage INTEGER, p_status_id INTEGER)
/*  Функция: Создает запрос на вставку нового автомобиля в таблицу.
    Она принимает VIN, идентификатор модели, идентификатор марки, год выпуска, 
    цвет, пробег и идентификатор статуса в качестве параметров.
    Она используется для добавления нового автомобиля в систему. */
CREATE OR REPLACE
PROCEDURE app_schema.insert_vehicle(p_vin VARCHAR(255), p_model_id INTEGER, p_brand_id INTEGER, p_year SMALLINT, p_color VARCHAR(255), p_mileage INTEGER, p_status_id INTEGER)
AS $$
BEGIN
    INSERT INTO app_schema.vehicles(vin, model_id, brand_id, year, color, mileage, status_id) 
    VALUES(p_vin, p_model_id, p_brand_id, p_year, p_color, p_mileage, p_status_id);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_vehicle('VIN123', 1, 1, 2022, 'Red', 10000, 1);

-- Процедура: app_schema.update_vehicle(p_vehicle_id INTEGER, p_vin VARCHAR(255), p_model_id INTEGER, p_brand_id INTEGER, p_year SMALLINT, p_color VARCHAR(255), p_mileage INTEGER, p_status_id INTEGER)
/*  Функция: Создает запрос на обновление данных о автомобиле в таблице.
    Она принимает идентификатор автомобиля, VIN, идентификатор модели, 
    идентификатор марки, год выпуска, цвет, пробег и идентификатор статуса в качестве параметров.
    Она используется для обновления данных об автомобиле в системе. */
CREATE OR REPLACE 
PROCEDURE app_schema.update_vehicle(p_vehicle_id INTEGER, p_vin VARCHAR(255), p_model_id INTEGER, p_brand_id INTEGER, p_year SMALLINT, p_color VARCHAR(255), p_mileage INTEGER, p_status_id INTEGER)
AS $$
BEGIN
    UPDATE app_schema.vehicles 
    SET vin = p_vin, model_id = p_model_id, brand_id = p_brand_id, year = p_year, color = p_color, mileage = p_mileage, status_id = p_status_id 
    WHERE vehicle_id = p_vehicle_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_vehicle(1, 'VIN123', 1, 1, 2022, 'Red', 10000, 1);

-- Процедура: app_schema.delete_vehicle(p_vehicle_id INTEGER)
/*  Функция: Создает запрос на удаление автомобиля из таблицы.
    Она принимает идентификатор автомобиля в качестве параметра.
    Она используется для удаления автомобиля из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.delete_vehicle(p_vehicle_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.vehicles 
    WHERE vehicle_id = p_vehicle_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_vehicle(1);

-- Процедура: mechanic_schema.select_repair_order(p_order_id INTEGER)
/*  Функция: Создает запрос на выборку данных о ремонтном заказе по идентификатору.
    Она принимает идентификатор ремонтного заказа в качестве параметра.
    Она используется для получения данных о ремонтном заказе из системы. */
CREATE OR REPLACE
PROCEDURE mechanic_schema.select_repair_order(p_order_id INTEGER)
AS $$
BEGIN
    SELECT * FROM mechanic_schema.repair_orders 
    WHERE order_id = p_order_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.select_repair_order(1);

-- Процедура: mechanic_schema.insert_repair_order(p_vehicle_id INTEGER, p_created_by INTEGER, p_assigned_to INTEGER, p_status_id INTEGER, p_total_cost DECIMAL)
/*  Функция: Создает запрос на вставку нового ремонтного заказа в таблицу.
    Она принимает идентификатор автомобиля, идентификатор создателя, 
    идентификатора назначенного механика, идентификатор статуса и общую стоимость в качестве параметров.
    Она используется для добавления нового ремонтного заказа в систему. */
CREATE OR REPLACE 
PROCEDURE mechanic_schema.insert_repair_order(p_vehicle_id INTEGER, p_created_by INTEGER, p_assigned_to INTEGER, p_status_id INTEGER, p_total_cost DECIMAL)
AS $$
BEGIN
    INSERT INTO mechanic_schema.repair_orders(vehicle_id, created_by, assigned_to, status_id, total_cost) 
    VALUES(p_vehicle_id, p_created_by, p_assigned_to, p_status_id, p_total_cost);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.insert_repair_order(1, 1, 1, 1, 1000);

-- Процедура: mechanic_schema.update_repair_order(p_order_id INTEGER, p_vehicle_id INTEGER, p_created_by INTEGER, p_assigned_to INTEGER)
/*  Функция: Создает запрос на обновление данных о ремонтном заказе в таблице.
    Она принимает идентификатор ремонтного заказа, идентификатор автомобиля, идентификатор создателя и идентификатора назначенного механика в качестве параметров.
    Она используется для обновления данных о ремонтном заказе в системе. */
CREATE OR REPLACE
PROCEDURE mechanic_schema.update_repair_order(p_order_id INTEGER, p_vehicle_id INTEGER, p_created_by INTEGER, p_assigned_to INTEGER)
AS $$
BEGIN
    UPDATE mechanic_schema.repair_orders 
    SET vehicle_id = p_vehicle_id, created_by = p_created_by, assigned_to = p_assigned_to 
    WHERE order_id = p_order_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.update_repair_order(1, 1, 1, 1);

-- Процедура: mechanic_schema.delete_repair_order(p_order_id INTEGER)
/*  Функция: Создает запрос на удаление ремонтного заказа из таблицы.
    Она принимает идентификатор ремонтного заказа в качестве параметра.
    Она используется для удаления ремонтного заказа из системы. */
CREATE OR REPLACE
PROCEDURE mechanic_schema.delete_repair_order(p_order_id INTEGER)
AS $$
BEGIN
    DELETE FROM mechanic_schema.repair_orders 
    WHERE order_id = p_order_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.delete_repair_order(1);

-- Процедура: mechanic_schema.select_repair_part(p_repair_part_id INTEGER)
/*  Функция: Создает запрос на выборку данных о запчасти по идентификатору.
    Она принимает идентификатор запчасти в качестве параметра.
    Она используется для получения данных о запчасти из системы. */
CREATE OR REPLACE
PROCEDURE mechanic_schema.select_repair_part(p_repair_part_id INTEGER)
AS $$
BEGIN
    SELECT * FROM mechanic_schema.repair_parts 
    WHERE repair_part_id = p_repair_part_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.select_repair_part(1);

-- Процедура: mechanic_schema.insert_repair_part(p_order_id INTEGER, p_part_id INTEGER, p_quantity INTEGER, p_line_cost DECIMAL(10, 2))
/*  Функция: Создает запрос на вставку новой запчасти в таблицу.
    Она принимает идентификатор ремонтного заказа, идентификатор запчасти, количество и стоимость в качестве параметров.
    Она используется для добавления новой запчасти в систему. */
CREATE OR REPLACE
PROCEDURE mechanic_schema.insert_repair_part(p_order_id INTEGER, p_part_id INTEGER, p_quantity INTEGER, p_line_cost DECIMAL(10, 2))
AS $$
BEGIN
    INSERT INTO mechanic_schema.repair_parts(order_id, part_id, quantity, line_cost) 
    VALUES(p_order_id, p_part_id, p_quantity, p_line_cost);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.insert_repair_part(1, 1, 1, 100.00);

-- Процедура: mechanic_schema.update_repair_part(p_order_id INTEGER, p_part_id INTEGER, p_quantity INTEGER, p_line_cost DECIMAL(10, 2))
/*  Функция: Создает запрос на обновление данных о запчасти в таблице.
    Она принимает идентификатор ремонтного заказа, идентификатор запчасти, количество и стоимость в качестве параметров.
    Она используется для обновления данных о запчасти в системе. */
CREATE OR REPLACE
PROCEDURE mechanic_schema.update_repair_part(p_repair_part_id INTEGER, p_order_id INTEGER, p_part_id INTEGER, p_quantity INTEGER, p_line_cost DECIMAL(10, 2))
AS $$
BEGIN
    UPDATE mechanic_schema.repair_parts 
    SET order_id = p_order_id, part_id = p_part_id, quantity = p_quantity, line_cost = p_line_cost 
    WHERE repair_part_id = p_repair_part_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.update_repair_part(1, 1, 1, 1, 100.00);

-- Процедура: mechanic_schema.delete_repair_part(p_repair_part_id INTEGER)
/*  Функция: Создает запрос на удаление запчасти из таблицы.
    Она принимает идентификатор запчасти в качестве параметра.
    Она используется для удаления запчасти из системы. */
CREATE OR REPLACE
PROCEDURE mechanic_schema.delete_repair_part(p_repair_part_id INTEGER)
AS $$
BEGIN
    DELETE FROM mechanic_schema.repair_parts 
    WHERE repair_part_id = p_repair_part_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL mechanic_schema.delete_repair_part(1);

-- Процедура: app_schema.select_vegicle_photo(p_photo_id INTEGER)
/*  Функция: Создает запрос на выборку данных о фотографии автомобиля по идентификатору.
    Она принимает идентификатор фотографии в качестве параметра.
    Она используется для получения данных о фотографии автомобиля из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.select_vehicle_photo(p_photo_id INTEGER)
AS $$
BEGIN
    SELECT * FROM app_schema.vehicle_photos 
    WHERE photo_id = p_photo_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_vehicle_photo(1);

-- Процедура: app_schema.insert_vehicle_photo(p_vehicle_id INTEGER, p_photo_path VARCHAR(255))
/*  Функция: Создает запрос на вставку новой фотографии автомобиля в таблицу.    
    Она принимает идентификатор автомобиля и путь к фотографии в качестве параметров.
    Она используется для добавления новой фотографии автомобиля в систему. */
CREATE OR REPLACE
PROCEDURE app_schema.insert_vehicle_photo(p_vehicle_id INTEGER, p_photo_path VARCHAR(255))
AS $$
BEGIN
    INSERT INTO app_schema.vehicle_photos(vehicle_id, photo_path) 
    VALUES(p_vehicle_id, p_photo_path);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_vehicle_photo(1, 'path/to/photo.jpg');

-- Процедура: app_schema.update_vehicle_photo(p_photo_id INTEGER, p_vehicle_id INTEGER, p_photo_path VARCHAR(255))
/*  Функция: Создает запрос на обновление данных о фотографии автомобиля в таблице.
    Она принимает идентификатор автомобиля и путь к новой фотографии в качестве параметров.
    Она используется для обновления данных о фотографии автомобиля в системе. */
CREATE OR REPLACE
PROCEDURE app_schema.update_vehicle_photo(p_photo_id INTEGER, p_vehicle_id INTEGER, p_photo_path VARCHAR(255))
AS $$
BEGIN
    UPDATE app_schema.vehicle_photos 
    SET vehicle_id = p_vehicle_id, photo_path = p_photo_path 
    WHERE photo_id = p_photo_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_vehicle_photo(1, 1, 'path/to/new_photo.jpg');

-- Процедура: app_schema.delete_vehicle_photo(p_photo_id INTEGER)
/*  Функция: Создает запрос на удаление фотографии автомобиля из таблицы.
    Она принимает идентификатор фотографии в качестве параметра.
    Она используется для удаления фотографии автомобиля из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.delete_vehicle_photo(p_photo_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.vehicle_photos 
    WHERE photo_id = p_photo_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_vehicle_photo(1);

-- Процедура: app_schema.select_test_drive(p_test_id INTEGER)
/*  Функция: Создает запрос на выборку данных о тест-драйве по идентификатору.
    Она принимает идентификатор тест-драйва в качестве параметра.
    Она используется для получения данных о тест-драйве из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.select_test_drive(p_test_id INTEGER)
AS $$
BEGIN
    SELECT * FROM app_schema.test_drives 
    WHERE test_id = p_test_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.select_test_drive(1);

-- Процедура: app_schema.insert_test_drive(p_vehicle_id INTEGER, p_client_id INTEGER, p_scheduled_by INTEGER)
/*  Функция: Создает запрос на вставку нового тест-драйва в таблицу.
    Она принимает идентификатор автомобиля, идентификатор клиента и идентификатор пользователя,
    запланировавшего тест-драйв в качестве параметров.
    Она используется для добавления нового тест-драйва в систему. */
CREATE OR REPLACE
PROCEDURE app_schema.insert_test_drive(p_vehicle_id INTEGER, p_client_id INTEGER, p_scheduled_by INTEGER)
AS $$
BEGIN
    INSERT INTO app_schema.test_drives(vehicle_id, client_id, scheduled_by) 
    VALUES(p_vehicle_id, p_client_id, p_scheduled_by);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_test_drive(1, 1, 1);

-- Процедура: app_schema.update_test_drive(p_test_drive_id INTEGER, p_vehicle_id INTEGER, p_client_id INTEGER, p_scheduled_by INTEGER)
/*  Функция: Создает запрос на обновление данных о тест-драйве в таблице.
    Она принимает идентификатор тест-драйва, идентификатор автомобиля, идентификатор клиента и идентификатор пользователя,
    запланировавшего тест-драйв в качестве параметров.
    Она используется для обновления данных о тест-драйве в системе. */
CREATE OR REPLACE
PROCEDURE app_schema.update_test_drive(p_test_drive_id INTEGER, p_vehicle_id INTEGER, p_client_id INTEGER, p_scheduled_by INTEGER)
AS $$
BEGIN
    UPDATE app_schema.test_drives 
    SET vehicle_id = p_vehicle_id, client_id = p_client_id, scheduled_by = p_scheduled_by 
    WHERE test_drive_id = p_test_drive_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_test_drive(1, 1, 1, 1);

-- Процедура: app_schema.delete_test_drive(p_test_drive_id INTEGER)
/*  Функция: Создает запрос на удаление тест-драйва из таблицы.
    Она принимает идентификатор тест-драйва в качестве параметра.
    Она используется для удаления тест-драйва из системы. */
CREATE OR REPLACE
PROCEDURE app_schema.delete_test_drive(p_test_drive_id INTEGER)
AS $$
BEGIN
    DELETE FROM app_schema.test_drives 
    WHERE test_drive_id = p_test_drive_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.delete_test_drive(1);

-- Процедура: admin_schema.select_ownership_history(p_vehicle_id INTEGER)
/*  Функция: Создает запрос на выборку истории владения автомобилем из таблицы.
    Она принимает идентификатор автомобиля в качестве параметра.
    Она используется для получения истории владения автомобилем из системы. */
CREATE OR REPLACE
PROCEDURE admin_schema.select_ownership_history(p_vehicle_id INTEGER)
AS $$
BEGIN
    SELECT * FROM admin_schema.ownership_history 
    WHERE vehicle_id = p_vehicle_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL admin_schema.select_ownership_history(1);

-- Процедура: admin_schema.insert_ownership_history(p_vehicle_id INTEGER, p_client_id INTEGER, p_from_date DATE)
/*  Функция: Создает запрос на вставку новой записи о владении автомобилем в таблицу.
    Оно принимает идентификатор автомобиля, идентификатор клиента и даты начала и окончания владения в качестве параметров.
    Она используется для добавления новой записи о владении автомобилем в систему. */
CREATE OR REPLACE FUNCTION admin_schema.insert_ownership_history(p_vehicle_id INTEGER, p_client_id INTEGER, p_from_date DATE)
RETURNS VOID AS $$
BEGIN
    INSERT INTO admin_schema.ownership_history(vehicle_id, client_id, from_date) 
    VALUES(p_vehicle_id, p_client_id, p_from_date);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL admin_schema.insert_ownership_history(1, 1, '2023-01-01');

-- Процедура: admin_schema.update_ownership_history(p_contract_id INTEGER, p_vehicle_id INTEGER, p_client_id INTEGER, p_from_date DATE)
/*  Функция: Создает запрос на обновление данных о владении автомобилем в таблице.
    Она принимает идентификатор автомобиля, идентификатор клиента и даты начала и окончания владения в качестве параметров.
    Она используется для обновления данных о владении автомобилем в системе. */
CREATE OR REPLACE FUNCTION admin_schema.update_ownership_history(p_contract_id INTEGER, p_vehicle_id INTEGER, p_client_id INTEGER, p_from_date DATE)
RETURNS VOID AS $$
BEGIN
    UPDATE admin_schema.ownership_history 
    SET vehicle_id = p_vehicle_id, client_id = p_client_id, from_date = p_from_date 
    WHERE contract_id = p_contract_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL admin_schema.update_ownership_history(1, 1, 1, '2023-01-01');


-- Процедура: admin_schema.delete_ownership_history(p_vehicle_id INTEGER)
/*  Функция: Создает запрос на удаление данных о владении автомобилем из таблицы.
    Она принимает идентификатор автомобиля в качестве параметра.
    Она используется для удаления данных о владении автомобилем из системы. */
CREATE OR REPLACE
PROCEDURE admin_schema.delete_ownership_history(p_vehicle_id INTEGER)
AS $$
BEGIN
    DELETE FROM admin_schema.ownership_history 
    WHERE vehicle_id = p_vehicle_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL admin_schema.delete_ownership_history(1);

-- Процедура: employee_schema.select_contract_type(p_contract_type_id INTEGER)
/*  Функция: Создает запрос на выборку типа контракта из таблицы.
    Она принимает идентификатор типа контракта в качестве параметра.
    Она используется для получения типа контракта из системы. */
CREATE OR REPLACE
PROCEDURE employee_schema.select_contract_type(p_contract_type_id INTEGER)
AS $$
BEGIN
    SELECT * FROM employee_schema.contract_types 
    WHERE contract_type_id = p_contract_type_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.select_contract_type(1);

-- Процедура: employee_schema.insert_contract_type(p_name VARCHAR(255))
/*  Функция: Создает запрос на вставку нового типа контракта в таблицу.
    Она принимает название типа контракта в качестве параметра.
    Она используется для добавления нового типа контракта в систему. */
CREATE OR REPLACE
PROCEDURE employee_schema.insert_contract_type(p_name VARCHAR(255))
AS $$
BEGIN
    INSERT INTO employee_schema.contract_types(name) 
    VALUES(p_name);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.insert_contract_type('Lease');

-- Процедура: employee_schema.update_contract_type(p_contract_type_id INTEGER, p_name VARCHAR(255))
/*  Функция: Создает запрос на обновление типа контракта в таблице.
    Она принимает идентификатор типа контракта и название в качестве параметров.
    Она используется для обновления типа контракта в системе. */
CREATE OR REPLACE
PROCEDURE employee_schema.update_contract_type(p_contract_type_id INTEGER, p_name VARCHAR(255))
AS $$
BEGIN
    UPDATE employee_schema.contract_types 
    SET name = p_name 
    WHERE contract_type_id = p_contract_type_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.update_contract_type(1, 'Lease');

-- Процедура: employee_schema.delete_contract_type(p_contract_type_id INTEGER)
/*  Функция: Создает запрос на удаление типа контракта из таблицы.
    Она принимает идентификатор типа контракта в качестве параметра.
    Она используется для удаления типа контракта из системы. */
CREATE OR REPLACE 
PROCEDURE employee_schema.delete_contract_type(p_contract_type_id INTEGER)
AS $$
BEGIN
    DELETE FROM employee_schema.contract_types 
    WHERE contract_type_id = p_contract_type_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.delete_contract_type(1);

-- Процедура: employee_schema.select_payment_type(p_payment_type_id INTEGER)
/*  Функция: Создает запрос на выборку типа оплаты из таблицы.
    Она принимает идентификатор типа оплаты в качестве параметра.
    Она используется для получения типа оплаты из системы. */
CREATE OR REPLACE
PROCEDURE employee_schema.select_payment_type(p_payment_type_id INTEGER)
AS $$
BEGIN
    SELECT * FROM employee_schema.payment_types 
    WHERE payment_id = p_payment_type_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.select_payment_type(1);


-- Процедура: employee_schema.insert_payment_type(p_name VARCHAR(255))
/*  Функция: Создает запрос на вставку нового типа оплаты в таблицу.
    Она принимает название типа оплаты в качестве параметра.
    Она используется для добавления нового типа оплаты в систему. */
CREATE OR REPLACE
PROCEDURE employee_schema.insert_payment_type(p_name VARCHAR(255))
AS $$
BEGIN
    INSERT INTO employee_schema.payment_types(name) 
    VALUES(p_name);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.insert_payment_type('Cash');

-- Процедура: employee_schema.update_payment_type(p_payment_type_id INTEGER, p_name VARCHAR(255))
/*  Функция: Создает запрос на обновление типа оплаты в таблице.
    Она принимает идентификатор типа оплаты и название в качестве параметров.
    Она используется для обновления типа оплаты в системе. */
CREATE OR REPLACE
PROCEDURE employee_schema.update_payment_type(p_payment_type_id INTEGER, p_name VARCHAR(255))
AS $$
BEGIN
    UPDATE employee_schema.payment_types 
    SET name = p_name 
    WHERE payment_id = p_payment_type_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.update_payment_type(1, 'Cash');

-- Процедура: employee_schema.delete_payment_type(p_payment_type_id INTEGER)
/*  Функция: Создает запрос на удаление типа оплаты из таблицы.
    Она принимает идентификатор типа оплаты в качестве параметра.
    Она используется для удаления типа оплаты из системы. */
CREATE OR REPLACE
PROCEDURE employee_schema.delete_payment_type(p_payment_type_id INTEGER)
AS $$
BEGIN
    DELETE FROM employee_schema.payment_types 
    WHERE payment_id = p_payment_type_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.delete_payment_type(1);

-- Процедура: employee_schema.select_contract(p_contract_id INTEGER)
/*  Функция: Создает запрос на выборку контракта из таблицы.
    Она принимает идентификатор контракта в качестве параметра.
    Она используется для получения контракта из системы. */
CREATE OR REPLACE
PROCEDURE employee_schema.select_contract(p_contract_id INTEGER)
AS $$
BEGIN
    SELECT * FROM employee_schema.contracts 
    WHERE contract_id = p_contract_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.select_contract(1);

-- Процедура: employee_schema.insert_contract(p_vehicle_id INTEGER, p_client_id INTEGER, p_employee_id INTEGER, p_contract_type_id INTEGER, p_payment_type_id INTEGER, p_history_id INTEGER, p_total_price DECIMAL(10, 2))
/*  Функция: Создает запрос на вставку нового контракта в таблицу.
    Она принимает идентификатор автомобиля, идентификатор клиента, идентификатор сотрудника, идентификатор типа контракта, идентификатор типа оплаты, идентификатор истории в качестве параметров.
    Она используется для добавления нового контракта в систему. */
CREATE OR REPLACE
PROCEDURE employee_schema.insert_contract(p_vehicle_id INTEGER, p_client_id INTEGER, p_employee_id INTEGER, p_contract_type_id INTEGER, p_payment_type_id INTEGER, p_history_id INTEGER, p_total_price DECIMAL(10, 2))
AS $$
BEGIN
    INSERT INTO employee_schema.contracts(vehicle_id, client_id, employee_id, contract_type_id, payment_type_id, history_id, total_price) 
    VALUES(p_vehicle_id, p_client_id, p_employee_id, p_contract_type_id, p_payment_type_id, p_history_id, p_total_price);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.insert_contract(1, 1, 1, 1, 1, 1, 1);

-- Процедура: employee_schema.update_contract(p_contract_id INTEGER, p_vehicle_id INTEGER, p_client_id INTEGER, p_employee_id INTEGER, p_contract_type_id INTEGER, p_payment_type_id INTEGER, p_history_id INTEGER, p_total_price DECIMAL(10, 2))
/*  Функция: Создает запрос на обновление контракта в таблице.
    Она принимает идентификатор контракта и все параметры в качестве параметров.
    Она используется для обновления контракта в системе. */
CREATE OR REPLACE
PROCEDURE employee_schema.update_contract(p_contract_id INTEGER, p_vehicle_id INTEGER, p_client_id INTEGER, p_employee_id INTEGER, p_contract_type_id INTEGER, p_payment_type_id INTEGER, p_history_id INTEGER, p_total_price DECIMAL(10, 2))
AS $$
BEGIN
    UPDATE employee_schema.contracts
    SET 
        vehicle_id = p_vehicle_id,
        client_id = p_client_id,
        employee_id = p_employee_id,
        contract_type_id = p_contract_type_id,
        payment_type_id = p_payment_type_id,
        history_id = p_history_id,
        total_price = p_total_price
    WHERE contract_id = p_contract_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.update_contract(1, 1, 1, 1, 1, 1, 1, 1);

-- Процедура: employee_schema.delete_contract(p_contract_id INTEGER)
/*  Функция: Создает запрос на удаление контракта из таблицы.
    Она принимает идентификатор контракта в качестве параметра.
    Она используется для удаления контракта из системы. */
CREATE OR REPLACE
PROCEDURE employee_schema.delete_contract(p_contract_id INTEGER)
AS $$
BEGIN
    DELETE FROM employee_schema.contracts 
    WHERE contract_id = p_contract_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.delete_contract(1);

-- Процедура: user_schema.select_passport(p_passport_id INTEGER)
/*  Функция: Создает запрос на выборку паспорта из таблицы.
    Она принимает идентификатор паспорта в качестве параметра.
    Она используется для получения информации о паспорте. */
CREATE OR REPLACE
PROCEDURE user_schema.select_passport(p_passport_id INTEGER)
AS $$
BEGIN
    SELECT * FROM user_schema.passports WHERE passport_id = p_passport_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.select_passport(1);

-- Процедура: employee_schema.insert_passport(p_client_id INTEGER, p_series VARCHAR(255), p_number VARCHAR(255), p_issued_by VARCHAR(255), p_issued_date DATE)  
/*  Функция: Создает запрос на вставку нового паспорта в таблицу.
    Она принимает идентификатор клиента, серию, номер и дату выдачи в качестве параметров.
    Она используется для добавления нового паспорта в систему. */
CREATE OR REPLACE
PROCEDURE employee_schema.insert_passport(p_client_id INTEGER, p_series VARCHAR(255), p_number VARCHAR(255), p_issued_by VARCHAR(255), p_issued_date DATE)
AS $$
BEGIN
    INSERT INTO employee_schema.passports(client_id, series, number, issued_by, issued_date) 
    VALUES(p_client_id, p_series, p_number, p_issued_by, p_issued_date);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.insert_passport(1, 'A123456789', '1234567890', 'Government', '2022-01-01');

-- Процедура: employee_schema.update_passport(p_passport_id INTEGER, p_client_id INTEGER, p_series VARCHAR(255), p_number VARCHAR(255), p_issued_by VARCHAR(255), p_issued_date DATE)
/*  Функция: Создает запрос на обновление паспорта в таблице.
    Она принимает идентификатор паспорта и все параметры в качестве параметров.
    Она используется для обновления паспорта в системе. */
CREATE OR REPLACE
PROCEDURE employee_schema.update_passport(p_passport_id INTEGER, p_client_id INTEGER, p_series VARCHAR(255), p_number VARCHAR(255), p_issued_by VARCHAR(255), p_issued_date DATE)
AS $$
BEGIN
    UPDATE employee_schema.passports
    SET 
        client_id = p_client_id,
        series = p_series,
        number = p_number,
        issued_by = p_issued_by,
        issued_date = p_issued_date
    WHERE passport_id = p_passport_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.update_passport(1, 1, 'A123456789', '1234567890', 'Government', '2022-01-01');

-- Процедура: employee_schema.delete_passport(p_passport_id INTEGER)
/*  Функция: Создает запрос на удаление паспорта из таблицы.
    Она принимает идентификатор паспорта в качестве параметра.
    Она используется для удаления паспорта из системы. */
CREATE OR REPLACE
PROCEDURE employee_schema.delete_passport(p_passport_id INTEGER)
AS $$
BEGIN
    DELETE FROM employee_schema.passports 
    WHERE passport_id = p_passport_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.delete_passport(1);

-- Процедура: app_schema.register_user(p_email VARCHAR(255), p_password VARCHAR(255))
CREATE OR REPLACE
PROCEDURE app_schema.register_user(p_email VARCHAR(255), p_password VARCHAR(255))
AS $$
DECLARE
    v_salt BYTEA := gen_salt('bf');
BEGIN
    INSERT INTO user_schema.users(email, password_hash) 
    VALUES(p_email, crypt(p_password, v_salt));
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.register_user('7Kq9E@example.com', 'password_hash');

-- Процедура: app_schema.authenticate_user(p_email VARCHAR(255), p_password VARCHAR(255))
CREATE OR REPLACE
PROCEDURE app_schema.authenticate_user(p_email VARCHAR(255), p_password VARCHAR(255))
AS $$
DECLARE
    v_password_hash BYTEA;
BEGIN
    SELECT password_hash INTO v_password_hash FROM user_schema.users WHERE email = p_email;
    IF v_password_hash = crypt(p_password, v_password_hash) THEN
        SELECT * FROM user_schema.users WHERE email = p_email;
    END IF;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.authenticate_user('7Kq9E@example.com', 'password_hash');

-- Процедура: app_schema.update_user_profile(p_user_id INTEGER, p_email VARCHAR(255), p_password VARCHAR(255))
CREATE OR REPLACE
PROCEDURE app_schema.update_user_profile(p_user_id INTEGER, p_email VARCHAR(255), p_password VARCHAR(255))
AS $$
DECLARE
    v_user_exists BOOLEAN;
BEGIN
    SELECT EXISTS (SELECT 1 FROM user_schema.users WHERE user_id = p_user_id) INTO v_user_exists;
    
    IF NOT v_user_exists THEN
        RAISE EXCEPTION 'User ID % not found', p_user_id;
    END IF;

    UPDATE user_schema.users 
    SET email = p_email, password_hash = crypt(p_password, gen_salt('bf'))
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.update_user_profile(1, '7Kq9E@example.com', 'password_hash');

-- Процедура: AssignUserRole(userId, newRoleId)
CREATE OR REPLACE
PROCEDURE employee_schema.assign_user_role(p_user_id INTEGER, p_role_id INTEGER)
AS $$
BEGIN
    INSERT INTO user_schema.roles(user_id, role_id)
    VALUES (p_user_id, p_role_id);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.assign_user_role(1, 1);

-- Процедура: RemoveUserRole(userId, roleId)
CREATE OR REPLACE
PROCEDURE employee_schema.remove_user_role(p_user_id INTEGER, p_role_id INTEGER)
AS $$
BEGIN
    DELETE FROM user_schema.roles
    WHERE user_id = p_user_id AND role_id = p_role_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.remove_user_role(1, 1);

-- Функция: admin_schema.get_sale_statistics()
CREATE OR REPLACE
FUNCTION admin_schema.get_sale_statistics()
RETURNS TABLE (type_contract VARCHAR(255), total DECIMAL(10, 2)) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (CASE type_id WHEN 1 THEN 'purchase' WHEN 2 THEN 'sale' END) AS type_contract,
        SUM(total_price) AS total
    FROM employee_schema.contracts
    GROUP BY type_id;
END;
$$ LANGUAGE plpgsql;
-- Вызов: SELECT * FROM admin_schema.get_sale_statistics();

-- Функция: admin_schema.log_user_actions()
CREATE OR REPLACE
FUNCTION admin_schema.log_user_actions()
RETURNS TABLE (user_id INTEGER, action_type VARCHAR(255)) AS $$
BEGIN
    RETURN QUERY
    SELECT user_id, (CASE WHEN inserted THEN 'inserted' WHEN updated THEN 'updated' WHEN deleted THEN 'deleted' END) AS action_type
    FROM user_schema.users_log;
END;
$$ LANGUAGE plpgsql;
-- Вызов: SELECT * FROM admin_schema.log_user_actions();

-- Триггер: tr_log_user_actions
CREATE TRIGGER tr_log_user_actions
AFTER INSERT OR UPDATE OR DELETE ON user_schema.users
FOR EACH ROW
EXECUTE FUNCTION admin_schema.log_user_actions();