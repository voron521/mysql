CREATE DATABASE IF NOT EXISTS coursework;

USE coursework;


DROP TABLE IF EXISTS contract_carrier;
DROP TABLE IF EXISTS transportation;
DROP TABLE IF EXISTS contract;
DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS contract_carrier;
DROP TABLE IF EXISTS `constituent_documents_in_folder`;
DROP TABLE IF EXISTS `constituent_documents_folder`;
DROP TABLE IF EXISTS constituent_documents;
DROP TABLE IF EXISTS carrier;



DROP TABLE IF EXISTS carrier;
CREATE TABLE carrier (
  id SERIAL PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `type_of_ownership` VARCHAR(15) NOT NULL,
  `inn` VARCHAR(100) NOT NULL,
  `kpp` VARCHAR(100) DEFAULT NULL,
  `address` VARCHAR(255) NOT NULL,
  `ogrn` VARCHAR(100) NOT NULL,
  `bank` VARCHAR(255) NOT NULL,
  `r/sc` VARCHAR(255) NOT NULL,
  `k/sc` VARCHAR(255) NOT NULL,
  `bik` VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX carrier_name_idx(name)
   
)COMMENT = 'Перевозчики и их реквизиты';

DROP TABLE IF EXISTS city;
CREATE TABLE city (
  id SERIAL PRIMARY KEY,
  `название_города` VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  
)COMMENT = 'города погрузки и выгрузки';


DROP TABLE IF EXISTS contract; -- наши юр.лица с которыми перевозчика заключают договора
CREATE TABLE contract (
  id SERIAL PRIMARY KEY,
  `city_id`  BIGINT UNSIGNED NOT NULL,
  `город` VARCHAR(255),
  `юр_лицо` VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`city_id`) REFERENCES city(id)
    
 
)COMMENT = 'наши юр.лица с которыми перевозчика заключают договора';

DROP TABLE IF EXISTS contract_carrier; -- с каким юр.лицами у перевозчика есть договора
CREATE TABLE contract_carrier (
  id SERIAL PRIMARY KEY,
  `carrier_id` BIGINT UNSIGNED DEFAULT NULL,
  `название_перевозчика` VARCHAR(255), 
  `СТН-Б` BIT(1),
   `СТН-П` BIT(1),
  `СТН-Т` BIT(1),
  `СТН-М` BIT(1),
  `Сатурн_Н.Н` BIT(1),
  `СТН_Урал` BIT(1),
  `СТН-СИБ` BIT(1),
  `Олови` BIT(1),
  `Сатурн_СПБ` BIT(1),
  `ТД_Сатурн` BIT(1),

  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`carrier_id`) REFERENCES carrier(id)
)COMMENT = 'с каким юр.лицами у перевозчика есть договора';





DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL,
    name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)COMMENT = 'типо медиа файла';



DROP TABLE IF EXISTS constituent_documents;
CREATE TABLE constituent_documents(
	id SERIAL,
    media_type_id BIGINT UNSIGNED NOT NULL,
    carrier_id BIGINT UNSIGNED NOT NULL,
  	body text,
    filename VARCHAR(255),
    size INT,
    metadata JSON,
    `y/n` BIT(1) DEFAULT 0,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (carrier_id) REFERENCES carrier(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
)COMMENT = 'учредительные документы перевозчика';


DROP TABLE IF EXISTS `constituent_documents_folder`;
CREATE TABLE `constituent_documents_folder` (
	`id` SERIAL,
	`name` varchar(255) DEFAULT NULL,
    `carrier_id` BIGINT UNSIGNED DEFAULT NULL,
    FOREIGN KEY (carrier_id) REFERENCES carrier(id),
  	PRIMARY KEY (`id`)
)COMMENT = 'папки учредительных документов перевозчиков';

DROP TABLE IF EXISTS `constituent_documents_in_folder`;
CREATE TABLE `constituent_documents_in_folder` (
	id SERIAL,
	`folder_id` BIGINT unsigned NULL,
	`constituent_documents_id` BIGINT unsigned NOT NULL,

	FOREIGN KEY (folder_id) REFERENCES constituent_documents_folder(id),
    FOREIGN KEY (constituent_documents_id) REFERENCES constituent_documents(id)
)COMMENT = 'в какой папке, какой учредительный документ лежит';

DROP TABLE IF EXISTS drivers;
CREATE TABLE drivers (
  id SERIAL PRIMARY KEY,
  `Ф.И.О` VARCHAR(255) NOT NULL,
  `серия` VARCHAR(255) NOT NULL, -- паспорта
  `номер` VARCHAR(255) NOT NULL, -- паспорта
  `кем_выдан` VARCHAR(255) NOT NULL, -- паспорта
  `дата_выдачи` DATE DEFAULT NULL,  -- паспорт
  `машина` VARCHAR(255) DEFAULT NULL, -- 
  `телефон` VARCHAR(255) DEFAULT NULL,
  `направление` VARCHAR(255) DEFAULT NULL,
  `id_carriers` BIGINT UNSIGNED DEFAULT NULL,
  `название_перевозчика` VARCHAR(255) DEFAULT NULL,
  FOREIGN KEY (`id_carriers`) REFERENCES carrier(id),
  INDEX name_driver_idx(`Ф.И.О`),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX carrier_name_idx(`название_перевозчика`)
   
)COMMENT = 'данные по водителям';



DROP TABLE IF EXISTS transportation;
CREATE TABLE transportation (
  id SERIAL PRIMARY KEY,
  `№_в_Атракс` VARCHAR(255) DEFAULT NULL, -- Это номер в системе автоторгов(интернер площадка - аукцион) по перевозкам
  `Дата_заказа` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `План_дат_погр` DATE DEFAULT NULL,
  `Дата_реестр` DATE DEFAULT NULL,
  `фактическая_дата погрузки` DATE DEFAULT NULL,
  `city_id_start` BIGINT UNSIGNED DEFAULT NULL,
  `город_погрузки` VARCHAR(255) DEFAULT NULL,
  `city_id_stop` BIGINT UNSIGNED DEFAULT NULL,
  `город_выгрузки` VARCHAR(255) DEFAULT NULL,
  `площадка_погрузки` VARCHAR(255) DEFAULT NULL,
  `адрес_доставки` VARCHAR(255) DEFAULT NULL,
  `id_carriers` BIGINT unsigned DEFAULT NULL,
  `название_перевозчика` VARCHAR(255) DEFAULT NULL,
  `id_driver`  BIGINT unsigned DEFAULT NULL,
  `Ф.И.О_водителя` VARCHAR(255) DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX carrier_name_idx(`название_перевозчика`),
  FOREIGN KEY (`id_carriers`) REFERENCES carrier(id),
  FOREIGN KEY (`id_driver`) REFERENCES drivers(id),
  FOREIGN KEY (`city_id_start`) REFERENCES city(id),
  FOREIGN KEY (`city_id_stop`) REFERENCES city(id)
   
)COMMENT = 'рейсы перевозчиков';




-- НИЖЕ ТРИГЕРЫ


DROP TRIGGER IF EXISTS check_city_contract_insert;
DELIMITER //
CREATE TRIGGER check_city_contract_insert BEFORE INSERT ON contract -- если id не вписан, тригер сам подтягивает нужный id по названию города
FOR EACH ROW
BEGIN
  DECLARE cit_id INT;
  SELECT id INTO cit_id FROM city WHERE city.`название_города` = NEW.`город` ;
  SET NEW.city_id = COALESCE(NEW.city_id, cit_id);
END//

DROP TRIGGER IF EXISTS check_city_contract_update;
DELIMITER //
CREATE TRIGGER check_city_contract_update BEFORE UPDATE ON contract -- если id не вписан, тригер сам подтягивает нужный id по названию города
FOR EACH ROW
BEGIN
  DECLARE cit_id INT;
  SELECT id INTO cit_id FROM city WHERE city.`название_города` = NEW.`город` ;
  SET NEW.city_id = COALESCE(NEW.city_id, cit_id);
END//













DROP TRIGGER IF EXISTS check_kpp_in_carrier_insert;
DELIMITER //
CREATE TRIGGER `check_kpp_in_carrier_insert` BEFORE INSERT ON carrier
FOR EACH ROW
BEGIN
	IF((NEW.`kpp` IS NULL) AND (NEW.`type_of_ownership` LIKE 'ООО')) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'У юр.лица с формой собственности ООО обязательно должен быть КПП';
    END IF;
END//

DROP TRIGGER IF EXISTS check_kpp_in_carrier_update;
DELIMITER //
CREATE TRIGGER `check_kpp_in_carrier_update` BEFORE INSERT ON carrier
FOR EACH ROW
BEGIN
	IF((NEW.`kpp` IS NULL) AND (NEW.`type_of_ownership` LIKE 'ООО')) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'У юр.лица с формой собственности ООО обязательно должен быть КПП';
    END IF;
END//





DROP TRIGGER IF EXISTS check_city_in_transportation_insert;
DELIMITER //
CREATE TRIGGER check_city_in_transportation_insert BEFORE INSERT ON transportation -- если id города погрузки или выгрузки не вписан, тригер сам подтягивает нужный id по названию города
FOR EACH ROW
BEGIN
  DECLARE cit_id_1 INT;
  DECLARE cit_id_2 INT;
  DECLARE drive_id INT;
  DECLARE carr_id INT;
  SELECT id INTO cit_id_1 FROM city WHERE city.`название_города` = NEW.`город_погрузки` OR city.`название_города` LIKE CONCAT('%', NEW.`город_погрузки`, '%');
  SET NEW.city_id_start = COALESCE(NEW.city_id_start, cit_id_1);
  SELECT id INTO cit_id_2 FROM city WHERE city.`название_города` = NEW.`город_выгрузки` ;
  SET NEW.city_id_stop = COALESCE(NEW.city_id_stop, cit_id_2);
  SELECT drivers.id INTO drive_id FROM drivers JOIN transportation ON drivers.`Ф.И.О` = NEW.`Ф.И.О_водителя` LIMIT 1;
  SET NEW.id_driver = COALESCE(NEW.id_driver, drive_id);
  SELECT carrier.id INTO carr_id FROM carrier JOIN transportation ON carrier.name = NEW.`название_перевозчика` OR carrier.name LIKE CONCAT('%', NEW.`название_перевозчика`, '%') LIMIT 1;
  SET NEW.id_carriers = COALESCE(NEW.id_carriers, carr_id);
  IF(NEW.`№_в_Атракс` = '') THEN
     SET NEW.`№_в_Атракс` = NULL;
  END IF;
END//

DROP TRIGGER IF EXISTS check_city_in_transportation_update;
DELIMITER //
CREATE TRIGGER check_city_in_transportation_update BEFORE INSERT ON transportation -- если id города погрузки или выгрузки не вписан, тригер сам подтягивает нужный id по названию города
FOR EACH ROW
BEGIN
  DECLARE cit_id_1 INT;
  DECLARE cit_id_2 INT;
  DECLARE drive_id INT;
  DECLARE carr_id INT;
  SELECT id INTO cit_id_1 FROM city WHERE city.`название_города` = NEW.`город_погрузки` ;
  SET NEW.city_id_start = COALESCE(NEW.city_id_start, cit_id_1);
  SELECT id INTO cit_id_2 FROM city WHERE city.`название_города` = NEW.`город_выгрузки` ;
  SET NEW.city_id_stop = COALESCE(NEW.city_id_stop, cit_id_2);
  SELECT drivers.id INTO drive_id FROM drivers JOIN transportation ON drivers.`Ф.И.О` = NEW.`Ф.И.О_водителя` LIMIT 1;
  SET NEW.id_driver = COALESCE(NEW.id_driver, drive_id);
  SELECT carrier.id INTO carr_id FROM carrier JOIN transportation ON carrier.name = NEW.`название_перевозчика` LIMIT 1;
  SET NEW.id_carriers = COALESCE(NEW.id_carriers, carr_id);
  IF(NEW.`№_в_Атракс` = '') THEN
     SET NEW.`№_в_Атракс` = NULL;
  END IF;
END//







DROP TRIGGER IF EXISTS check_id_carrier_in_drivers_insert;
DELIMITER //
CREATE TRIGGER check_id_carrier_in_drivers_insert BEFORE INSERT ON drivers -- если id перевозчика у водителя не задан, тригер сам подтягивает нужный id по названию перевозчика если может, в противном случае null
FOR EACH ROW
BEGIN
  DECLARE carr INT;
  SELECT id INTO carr FROM carrier WHERE carrier.name = NEW.`название_перевозчика` ;
  SET NEW.id_carriers = COALESCE(NEW.id_carriers, carr);
END//

DROP TRIGGER IF EXISTS check_id_carrier_in_drivers_update;
DELIMITER //
CREATE TRIGGER check_id_carrier_in_drivers_update BEFORE INSERT ON drivers -- если id перевозчика у водителя не задан, тригер сам подтягивает нужный id по названию перевозчика если может, в противном случае null
FOR EACH ROW
BEGIN
  DECLARE carr INT;
  SELECT id INTO carr FROM carrier WHERE carrier.name = NEW.`название_перевозчика` ;
  SET NEW.id_carriers = COALESCE(NEW.id_carriers, carr);
END//






DROP TRIGGER IF EXISTS check_id_contract_carrier_insert;
DELIMITER //
CREATE TRIGGER check_id_contract_carrier_insert BEFORE INSERT ON contract_carrier -- если id перевозчика не задан, тригер сам подтягивает нужный id по названию перевозчика если может, в противном случае null
FOR EACH ROW
BEGIN
  DECLARE carr1 INT;
  SELECT id INTO carr1 FROM carrier WHERE carrier.name = NEW.`название_перевозчика` ;
  SET NEW.carrier_id = COALESCE(carr1, NEW.carrier_id);
END//

DROP TRIGGER IF EXISTS check_id_contract_carrier_update;
DELIMITER //
CREATE TRIGGER check_id_contract_carrier_update BEFORE INSERT ON contract_carrier -- если id перевозчика не задан, тригер сам подтягивает нужный id по названию перевозчика если может, в противном случае null
FOR EACH ROW
BEGIN
  DECLARE carr1 INT;
  SELECT id INTO carr1 FROM carrier WHERE carrier.name = NEW.`название_перевозчика` ;
  SET NEW.carrier_id = COALESCE(carr1, NEW.carrier_id);
END//



DROP TABLE IF EXISTS carriers_documents_complete;
CREATE TABLE carriers_documents_complete (
    id BIGINT UNSIGNED NOT NULL,
    carrier_name VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = ARCHIVE;



DROP TRIGGER IF EXISTS contract_carrier_insert;

delimiter //
CREATE TRIGGER contract_carrier_insert AFTER INSERT ON contract_carrier
FOR EACH ROW
BEGIN
	IF(NEW.`СТН-Б` = 1 and NEW.`СТН-П` = 1 and NEW.`СТН-Т` = 1 and NEW.`СТН-М` = 1
    and NEW.`Сатурн_Н.Н` = 1 and NEW.`СТН_Урал` = 1 and NEW.`СТН-СИБ` = 1 and NEW.`Олови` = 1 
    and NEW.`Сатурн_СПБ` = 1 and NEW.`ТД_Сатурн` = 1) THEN

	  INSERT INTO carriers_documents_complete (id, carrier_name)
	  VALUES (NEW.id, NEW.`название_перевозчика`);
	END IF;
END //
delimiter ;



DROP TRIGGER IF EXISTS contract_carrier_update;
delimiter //
CREATE TRIGGER contract_carrier_update AFTER UPDATE ON contract_carrier
FOR EACH ROW
BEGIN
	IF(NEW.`СТН-Б` = 1 and NEW.`СТН-П` = 1 and NEW.`СТН-Т` = 1 and NEW.`СТН-М` = 1
    and NEW.`Сатурн_Н.Н` = 1 and NEW.`СТН_Урал` = 1 and NEW.`СТН-СИБ` = 1 and NEW.`Олови` = 1 
    and NEW.`Сатурн_СПБ` = 1 and NEW.`ТД_Сатурн` = 1) THEN

	  INSERT INTO carriers_documents_complete (id, carrier_name)
	  VALUES (NEW.id, NEW.`название_перевозчика`);
	END IF;
END //
delimiter ;

