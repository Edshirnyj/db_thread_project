-- PostgreSQL

-- Шифрование
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Схема
CREATE SCHEMA IF NOT EXISTS admin_schema;
CREATE SCHEMA IF NOT EXISTS user_schema;
CREATE SCHEMA IF NOT EXISTS employee_schema;
CREATE SCHEMA IF NOT EXISTS mechanic_schema;
CREATE SCHEMA IF NOT EXISTS app_schema;

-- создание ролей
CREATE ROLE admin_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity';
CREATE ROLE employee_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity';
CREATE ROLE mechanic_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity';
CREATE ROLE client_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity'; 
CREATE ROLE guest_db WITH LOGIN ENCRYPTED PASSWORD '123456' VALID UNTIL 'infinity';

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

-- создание таблиц
CREATE TABLE IF NOT EXISTS app_schema.continents
(
    continent_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS app_schema.brands
(
    brand_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    continent_id INTEGER NOT NULL,

    FOREIGN KEY (continent_id) REFERENCES app_schema.continents(continent_id)
);

CREATE TABLE IF NOT EXISTS app_schema.models
(
    model_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    brand_id INTEGER NOT NULL,

    FOREIGN KEY (brand_id) REFERENCES app_schema.brands(brand_id)
);

CREATE TABLE IF NOT EXISTS user_schema.users
(
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash BYTEA NOT NULL,
    salt BYTEA NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS app_schema.clients
(
    client_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    patronymic VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL,
    city VARCHAR(255) NOT NULL,

    FOREIGN KEY (user_id) REFERENCES user_schema.users(user_id)
);

CREATE TABLE IF NOT EXISTS employee_schema.positions
(
    position_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

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

CREATE TABLE IF NOT EXISTS mechanic_schema.parts
(
    part_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_qty INTEGER NOT NULL
);

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

CREATE TABLE IF NOT EXISTS app_schema.vehicle_statuses
(
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS user_schema.roles
(
    role_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS user_schema.user_roles
(
    user_role_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES user_schema.users(user_id),
    FOREIGN KEY (role_id) REFERENCES user_schema.roles(role_id)
);

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

CREATE TABLE IF NOT EXISTS mechanic_schema.repair_orders
(
    order_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    created_by INTEGER NOT NULL,
    assigned_to INTEGER NOT NULL,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP DEFAULT NULL,
    status INTEGER NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id)  
);

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

CREATE TABLE IF NOT EXISTS app_schema.vehicle_photos
(
    photo_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    photo_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id)
);

CREATE TABLE IF NOT EXISTS app_schema.test_drives
(
    test_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    scheduled_by INTEGER NOT NULL,
    scheduled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actual_at TIMESTAMP DEFAULT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id),
    FOREIGN KEY (scheduled_by) REFERENCES employee_schema.employees(employee_id)
);

CREATE TABLE IF NOT EXISTS admin_schema.ownership_history
(
    history_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id)
);

CREATE TABLE IF NOT EXISTS employee_schema.contract_types
(
    type_contract_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL  
);

CREATE TABLE IF NOT EXISTS employee_schema.payment_types
(
    payment_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL  
);

CREATE TABLE IF NOT EXISTS employee_schema.contracts
(
    contract_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    type_id INTEGER NOT NULL,
    payment_id INTEGER NOT NULL,
    contract_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id),
    FOREIGN KEY (employee_id) REFERENCES employee_schema.employees(employee_id),
    FOREIGN KEY (type_id) REFERENCES employee_schema.contract_types(type_contract_id),
    FOREIGN KEY (payment_id) REFERENCES employee_schema.payment_types(payment_id)  
);

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

-- Процедура Insert для таблицы continents
CREATE OR REPLACE FUNCTION app_schema.insert_continent(p_name VARCHAR(255))
RETURNS VOID AS $$
BEGIN
    INSERT INTO app_schema.continents(name) VALUES(p_name);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_continent('Europe');

-- Процедура Insert для таблицы brands
CREATE OR REPLACE FUNCTION app_schema.insert_brand(p_name VARCHAR(255), p_continent_id INTEGER)
RETURNS VOID AS $$
BEGIN
    INSERT INTO app_schema.brands(name, continent_id) VALUES(p_name, p_continent_id);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_brand('BMW', 1);

-- Процедура Insert для таблицы models
CREATE OR REPLACE FUNCTION app_schema.insert_model(p_name VARCHAR(255), p_brand_id INTEGER)
RETURNS VOID AS $$
BEGIN
    INSERT INTO app_schema.models(name, brand_id) VALUES(p_name, p_brand_id);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_model('X5', 1);

-- Процедура Insert для таблицы users
CREATE OR REPLACE FUNCTION user_schema.insert_user(p_email VARCHAR(255), p_password_hash BYTEA, p_salt BYTEA)
RETURNS VOID AS $$
BEGIN
    INSERT INTO user_schema.users(email, password_hash, salt) VALUES(p_email, p_password_hash, p_salt);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL user_schema.insert_user('7Kq9E@example.com', 'password_hash', 'salt');

-- Процедура Insert для таблицы clients
CREATE OR REPLACE FUNCTION app_schema.insert_client(p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_birth_date DATE, p_city VARCHAR(255))
RETURNS VOID AS $$
BEGIN
    INSERT INTO app_schema.clients(user_id, firstname, lastname, patronymic, birth_date, city) VALUES(p_user_id, p_firstname, p_lastname, p_patronymic, p_birth_date, p_city);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL app_schema.insert_client(1, 'John', 'Smith', 'Petrovich', '1990-01-01', 'Saint-Petersburg');

-- Процедура Insert для таблицы positions
CREATE OR REPLACE FUNCTION employee_schema.insert_position(p_name VARCHAR(255))
RETURNS VOID AS $$
BEGIN
    INSERT INTO employee_schema.positions(name) VALUES(p_name);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.insert_position('Mechanic');

-- Процедура Insert для таблицы employees
CREATE OR REPLACE FUNCTION employee_schema.insert_employee(p_user_id INTEGER, p_firstname VARCHAR(255), p_lastname VARCHAR(255), p_patronymic VARCHAR(255), p_position_id INTEGER, p_hired_at DATE, p_phone_number VARCHAR(255))
RETURNS VOID AS $$
BEGIN
    INSERT INTO employee_schema.employees(user_id, firstname, lastname, patronymic, position_id, hired_at, phone_number) VALUES(p_user_id, p_firstname, p_lastname, p_patronymic, p_position_id, p_hired_at, p_phone_number);
END;
$$ LANGUAGE plpgsql;
-- Вызов: CALL employee_schema.insert_employee(1, 'John', 'Smith', 'Petrovich', 1, '2022-01-01', '123-45-67');

CREATE TABLE IF NOT EXISTS mechanic_schema.parts
(
    part_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_qty INTEGER NOT NULL
);

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

CREATE TABLE IF NOT EXISTS app_schema.vehicle_statuses
(
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS user_schema.roles
(
    role_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS user_schema.user_roles
(
    user_role_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES user_schema.users(user_id),
    FOREIGN KEY (role_id) REFERENCES user_schema.roles(role_id)
);

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

CREATE TABLE IF NOT EXISTS mechanic_schema.repair_orders
(
    order_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    created_by INTEGER NOT NULL,
    assigned_to INTEGER NOT NULL,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP DEFAULT NULL,
    status INTEGER NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id)  
);

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

CREATE TABLE IF NOT EXISTS app_schema.vehicle_photos
(
    photo_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    photo_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id)
);

CREATE TABLE IF NOT EXISTS app_schema.test_drives
(
    test_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    scheduled_by INTEGER NOT NULL,
    scheduled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actual_at TIMESTAMP DEFAULT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id),
    FOREIGN KEY (scheduled_by) REFERENCES employee_schema.employees(employee_id)
);

CREATE TABLE IF NOT EXISTS admin_schema.ownership_history
(
    history_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id)
);

CREATE TABLE IF NOT EXISTS employee_schema.contract_types
(
    type_contract_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL  
);

CREATE TABLE IF NOT EXISTS employee_schema.payment_types
(
    payment_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL  
);

CREATE TABLE IF NOT EXISTS employee_schema.contracts
(
    contract_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    type_id INTEGER NOT NULL,
    payment_id INTEGER NOT NULL,
    contract_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (vehicle_id) REFERENCES app_schema.vehicles(vehicle_id),
    FOREIGN KEY (client_id) REFERENCES app_schema.clients(client_id),
    FOREIGN KEY (employee_id) REFERENCES employee_schema.employees(employee_id),
    FOREIGN KEY (type_id) REFERENCES employee_schema.contract_types(type_contract_id),
    FOREIGN KEY (payment_id) REFERENCES employee_schema.payment_types(payment_id)  
);

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