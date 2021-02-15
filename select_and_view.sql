
-- Вначале просто пару запросов

-- выведем название всех перевозчиков у которых есть договора со всеми юр.лицами

SELECT name FROM carrier JOIN contract_carrier ON carrier_id = carrier.id
WHERE contract_carrier.`СТН-Б` = 1 and contract_carrier.`СТН-П` = 1 and contract_carrier.`СТН-Т` = 1 and contract_carrier.`СТН-М` = 1
and contract_carrier.`Сатурн_Н.Н` = 1 and contract_carrier.`СТН_Урал` = 1 and contract_carrier.`СТН-СИБ` = 1 and contract_carrier.`Олови` = 1 
and contract_carrier.`Сатурн_СПБ` = 1 and contract_carrier.`ТД_Сатурн` = 1;

-- Выедем реквизиты двух перевозчиков совершивих больше всех рейсов

SELECT COUNT(*) as 'кол-во рейсов', carrier.* FROM transportation JOIN carrier ON carrier.id = transportation.id_carriers
GROUP BY `название_перевозчика`
ORDER BY COUNT(*) DESC
LIMIT 2
;


-- Создадим представление которое считает в процентом соотношений сколько какой перевозчик в процентах от общего объема возит

CREATE OR REPLACE VIEW procent_transp AS
SELECT `название_перевозчика`, COUNT(*) AS 'количество рейсов', ROUND(((COUNT(*) / (SELECT COUNT(*) FROM transportation) * 100)), 2) AS '% от общего количества рейсов' FROM transportation
GROUP BY `название_перевозчика`
;


SELECT * FROM procent_transp;


-- Создадим представление которое выведет 10 водителей которые ездят чаще всего и название перевозчика от которого они возят

CREATE OR REPLACE VIEW top_10_drivers AS
SELECT `Ф.И.О`, COUNT(*), name FROM drivers JOIN carrier ON carrier.id = drivers.id_carriers 
GROUP BY `Ф.И.О`
ORDER BY COUNT(*) DESC
LIMIT 10;

SELECT * FROM top_10_drivers;



-- Удалим строки transportation где колонка id_carriers = NULL и поменяем тип столбца на NOT NULL чтобы свежие записи не могли быть NULL

-- Подобным образом я буду чистить все таблицы и менять значения на NOT NULL чтобы уже новые записи создавались корректно. Сделано это т.к я брал данные из реальной таблицы
-- Access, а создана она криво, почти без взаимосвязей, а если и с ними, то не корректными(к примерку в ней связь таблицв водителей с рейсами была по Ф.И.О водителей,
-- а они как минимум не уникальны. Т.е это демонстрационная база, рабочая будет уже оптимизирована под нормальную работу mysql хотя бы тем, что ключи не будут иметь значения Null


DELETE FROM transportation
WHERE id_carriers IS NULL;

ALTER TABLE transportation 
MODIFY COLUMN `id_carriers` BIGINT unsigned NOT NULL;






