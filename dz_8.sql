-- Практическое задание по теме “Транзакции, переменные, представления”


--  1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
--  Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

USE sample;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

START TRANSACTION;

INSERT INTO users SELECT * FROM dz_8.users WHERE id = 1;

COMMIT;

SELECT * FROM users;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.

USE dz_8;

CREATE VIEW test AS
SELECT products.name AS products_name, catalogs.name AS catalogs_name
FROM products
LEFT JOIN catalogs
USING(id); 

SELECT * FROM test;

--  3. по желанию) Пусть имеется таблица с календарным полем created_at.
--  В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17.
--  Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1,
--  если дата присутствует в исходном таблице и 0, если она отсутствует.

DROP TABLE IF EXISTS `dates_august`;
CREATE TABLE `dates_august`(
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO `dates_august` VALUES('2018-08-01'), ('2018-08-04'), ('2018-08-17');



DROP TABLE IF EXISTS `dates_august2`;
CREATE TABLE `dates_august2`(
	id SERIAL PRIMARY KEY,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    `check` INT
);



DROP TABLE IF EXISTS `numbers`; -- вспомогательная таблица для создания диапазона дат
CREATE TABLE `numbers`(
	idi SERIAL PRIMARY KEY,
	id INT
);
INSERT `numbers`(id) VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),(31);

INSERT INTO dates_august2 (`created_at`)
SELECT '2018-08-01 00:00:00' + INTERVAL (id - 1) DAY
FROM `numbers`;

    
SELECT * FROM `dates_august2`;

SELECT created_at, checking FROM `dates_august2`  -- окончательный запрос для вывода результата задачи
JOIN (SELECT ((SELECT '2018-08-01' + INTERVAL (id - 1) DAY)
		IN (
			SELECT dates_august2.created_at
			FROM dates_august
			JOIN dates_august2
			ON dates_august.created_at = dates_august2.created_at))
			AS `checking`, idi
	
			FROM `numbers`)
			AS name
ON idi = id			
;


-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at.
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

DROP TABLE IF EXISTS `dates_4`;
CREATE TABLE `dates_4`(
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO `dates_4` VALUES('2018-08-01'), ('2018-08-02'), ('2011-02-11'), ('2003-12-25'), ('2021-05-10'), ('2018-03-20'), ('2020-01-01'), ('2001-09-19'), ('2015-04-03');

SELECT * FROM `dates_4`
ORDER BY created_at DESC
LIMIT 5
;


DELETE FROM `dates_4`
WHERE created_at NOT IN (SELECT * FROM (SELECT * FROM `dates_4`
ORDER BY created_at DESC
LIMIT 5) AS name_1
);


SELECT * FROM `dates_4`;



/* Практическое задание по теме “Администрирование MySQL” */

/*
1. Создайте двух пользователей которые имеют доступ к базе данных shop.
Первому пользователю shop_read должны быть доступны только запросы на чтение данных,
второму пользователю shop — любые операции в пределах базы данных shop.
 */

CREATE USER shop_read IDENTIFIED BY '1234';

CREATE USER shop IDENTIFIED BY 'abcd';


GRANT SELECT ON *.* TO shop_read;

GRANT ALL ON shop.* TO shop;

/*
2. (по желанию) Пусть имеется таблица accounts содержащая три столбца
id, name, password, содержащие первичный ключ, имя пользователя и его пароль.
Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако,
мог бы извлекать записи из представления username.
 */

USE shop;

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	`password` INT
);


INSERT accounts(name,`password`) VALUES('Genry', 1509), ('Jhon', 1234), ('Ivan', 5678);

CREATE VIEW username
AS SELECT id, name
FROM accounts;

CREATE USER user_read IDENTIFIED BY '1234';

GRANT SELECT ON shop.username TO user_read;

/*Практическое задание по теме “Хранимые процедуры и функции, триггеры"
*/

/* 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
*/

DELIMITER //

DROP FUNCTION IF EXISTS hello//

CREATE FUNCTION hello()
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
  IF(HOUR(NOW()) BETWEEN 6 and 11) THEN
	RETURN "Доброе утро";
  ELSEIF(HOUR(NOW()) BETWEEN 11 and 17) THEN
	RETURN "Добрый день";
  ELSEIF(HOUR(NOW()) BETWEEN 17 and 0) THEN
	RETURN "Добрый вечер";
  ELSE
	RETURN "Доброй ночи";
  END IF;
END //

DELIMITER ;

SELECT hello() AS 'Приветствие';

/* 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
Допустимо присутствие обоих полей или одно из них. Ситуация,
 когда оба поля принимают неопределенное значение NULL неприемлема.
 Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
 При попытке присвоить полям NULL-значение необходимо отменить операцию.
*/


DROP TABLE IF EXISTS products2;
CREATE TABLE products2(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) DEFAULT NULL,
	description VARCHAR(255) DEFAULT NULL
);

INSERT products2 (name, description) VALUES
('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.'),

('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.'),
('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.'),
('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.'),
('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.') ,
('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX'),
('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX'),
('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX');




SELECT * FROM products2;


DELIMITER //

CREATE TRIGGER check_name_desc_not_null BEFORE INSERT ON products2
FOR EACH ROW
BEGIN
  IF((NEW.`name` IS NULL) AND (NEW.`description` IS NULL)) THEN
  	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'name and description cannot be NULL';
  END IF;
END//

INSERT products2 (name, description) VALUES
(NULL, NULL);

/* 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи.
 Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел.
 Вызов функции FIBONACCI(10) должен возвращать число 55.
 */



DROP FUNCTION IF EXISTS fibo ;

DELIMITER //
CREATE FUNCTION fibo(n INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE fibo_number INT;
  DECLARE a_number INT;
  DECLARE b_number INT;
  SET fibo_number = 0;
  SET a_number = 0;
  SET b_number = 1;
	  IF n IN (1, 2) THEN
		RETURN 1;
	  ELSE
	 	WHILE n > 1 DO
	 		SET fibo_number = (a_number + b_number);
	 	    SET a_number = b_number;
	 	    SET b_number = fibo_number;
	 		SET n = n - 1;
	 	END WHILE;
      END IF;
  RETURN fibo_number;
END //

DELIMITER ;

SELECT fibo(10);

