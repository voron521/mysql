/* 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products
в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.
*/


USE shop;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
    id BIGINT NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
	created_at DATETIME NOT NULL
) ENGINE = ARCHIVE;


-- создаем тригеры для трех таблиц users, catalogs и products 

DROP TRIGGER IF EXISTS users_insert;
delimiter //
CREATE TRIGGER users_insert AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs (id, table_name, name, created_at)
	VALUES (NEW.id, 'users', NEW.name, CURRENT_TIMESTAMP);
END //
delimiter ;




DROP TRIGGER IF EXISTS catalogs_insert;
delimiter //
CREATE TRIGGER catalogs_insert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs (id, table_name, name, created_at)
	VALUES (NEW.id, 'catalogs', NEW.name, CURRENT_TIMESTAMP);
END //
delimiter ;


DROP TRIGGER IF EXISTS products_insert;
delimiter //
CREATE TRIGGER products_insert AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs (id, table_name, name, created_at)
	VALUES (NEW.id, 'products', NEW.name, CURRENT_TIMESTAMP);
END //
delimiter ;


-- Проверим

INSERT INTO users (name, birthday_at)
VALUES ('andrew', '1988-09-15');

SELECT * FROM users;
SELECT * FROM logs;



/*(по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
*/

DROP TABLE IF EXISTS users_for_dz_9; 
CREATE TABLE users_for_dz_9 (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	birthday_at DATE,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
 	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);



DROP PROCEDURE IF EXISTS users_for_dz_9_insert ;
delimiter //
CREATE PROCEDURE users_for_dz_9_insert ()
BEGIN
	DECLARE a INT DEFAULT 150;
	DECLARE b INT DEFAULT 0;
	WHILE a > 0 DO
		INSERT INTO users_for_dz_9(name, birthday_at) VALUES (CONCAT('user_', b), CURRENT_TIMESTAMP);
		SET a = a - 1;
		SET b = b + 1;

	END WHILE;
END //
delimiter ;

CALL users_for_dz_9_insert;


SELECT * FROM users_for_dz_9;
