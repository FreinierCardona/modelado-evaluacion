-- 000_inserts_sch_geography.sql
-- Inserta datos de prueba en sch_geography (10 filas por tabla)
-- Orden interno respetando FKs: time_zone, continent, currency, country, state_province, city, district, address
BEGIN;

-- time_zone (10 registros)
INSERT INTO sch_geography.time_zone (time_zone_name, utc_offset_minutes)
VALUES
  ('UTC-8', -480),
  ('UTC-7', -420),
  ('UTC-6', -360),
  ('UTC-5', -300),
  ('UTC-3', -180),
  ('UTC+0', 0),
  ('UTC+1', 60),
  ('UTC+2', 120),
  ('UTC+8', 480),
  ('UTC+9', 540)
ON CONFLICT (time_zone_name) DO NOTHING;

-- continent (10 registros)
INSERT INTO sch_geography.continent (continent_code, continent_name)
VALUES
  ('AFR', 'Africa'),
  ('ANT', 'Antarctica'),
  ('ASI', 'Asia'),
  ('EUR', 'Europe'),
  ('NAM', 'North America'),
  ('SAM', 'South America'),
  ('OCE', 'Oceania'),
  ('OT1', 'Other 1'),
  ('OT2', 'Other 2'),
  ('OT3', 'Other 3')
ON CONFLICT (continent_code) DO NOTHING;

-- currency (10 registros) — códigos reales cuando aplican
INSERT INTO sch_geography.currency (iso_currency_code, currency_name, currency_symbol, minor_units)
VALUES
  ('USD','US Dollar','$',2),
  ('EUR','Euro','€',2),
  ('GBP','British Pound','£',2),
  ('BRL','Brazilian Real','R$',2),
  ('CNY','Chinese Yuan','¥',2),
  ('JPY','Japanese Yen','¥',0),
  ('ARS','Argentine Peso','$',2),
  ('MXN','Mexican Peso','$',2),
  ('CAD','Canadian Dollar','$',2),
  ('AUD','Australian Dollar','$',2)
ON CONFLICT (iso_currency_code) DO NOTHING;

-- country (10 registros) — referencia a continent por continent_code
INSERT INTO sch_geography.country (continent_id, iso_alpha2, iso_alpha3, country_name)
VALUES
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='NAM'),'US','USA','United States'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='EUR'),'GB','GBR','United Kingdom'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='EUR'),'FR','FRA','France'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='EUR'),'DE','DEU','Germany'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='EUR'),'ES','ESP','Spain'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='SAM'),'BR','BRA','Brazil'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='ASI'),'CN','CHN','China'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='ASI'),'JP','JPN','Japan'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='SAM'),'AR','ARG','Argentina'),
  ((SELECT continent_id FROM sch_geography.continent WHERE continent_code='NAM'),'MX','MEX','Mexico')
ON CONFLICT (iso_alpha2) DO NOTHING;

-- state_province (10 registros)
INSERT INTO sch_geography.state_province (country_id, state_code, state_name)
VALUES
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='US'),'CA','California'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='GB'),'ENG','England'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='FR'),'IDF','Ile-de-France'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='DE'),'BW','Baden-Wurttemberg'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='ES'),'MD','Madrid'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='BR'),'SP','Sao Paulo'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='CN'),'BJ','Beijing'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='JP'),'TK','Tokyo'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='AR'),'BA','Buenos Aires'),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='MX'),'JA','Jalisco')
ON CONFLICT (country_id, state_name) DO NOTHING;

-- city (10 registros)
INSERT INTO sch_geography.city (state_province_id, time_zone_id, city_name)
VALUES
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='California'), (SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC-8'), 'Los Angeles'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='England'),    (SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC+0'), 'London'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='Ile-de-France'),(SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC+1'), 'Paris'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='Baden-Wurttemberg'),(SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC+1'), 'Stuttgart'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='Madrid'),      (SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC+1'), 'Madrid'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='Sao Paulo'),    (SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC-3'), 'Sao Paulo'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='Beijing'),     (SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC+8'), 'Beijing'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='Tokyo'),       (SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC+9'), 'Tokyo'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='Buenos Aires'),(SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC-3'), 'Buenos Aires'),
  ((SELECT state_province_id FROM sch_geography.state_province WHERE state_name='Jalisco'),     (SELECT time_zone_id FROM sch_geography.time_zone WHERE time_zone_name='UTC-6'), 'Guadalajara')
ON CONFLICT (state_province_id, city_name) DO NOTHING;

-- district (10 registros)
INSERT INTO sch_geography.district (city_id, district_name)
VALUES
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Los Angeles'),'Downtown'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='London'),'Central'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Paris'),'Centre'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Stuttgart'),'Mitte'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Madrid'),'Centro'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Sao Paulo'),'Centro'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Beijing'),'Dongcheng'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Tokyo'),'Chiyoda'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Buenos Aires'),'Microcentro'),
  ((SELECT city_id FROM sch_geography.city WHERE city_name='Guadalajara'),'Centro')
ON CONFLICT (city_id, district_name) DO NOTHING;

-- address (10 registros)
INSERT INTO sch_geography.address (district_id, address_line_1, address_line_2, postal_code, latitude, longitude)
SELECT d.district_id, t.address_line_1, t.address_line_2, t.postal_code, t.latitude, t.longitude
FROM (
  VALUES
    ('Los Angeles','Downtown','100 Main St', NULL, '90012', 34.053690, -118.242766),
    ('London','Central','10 High St', NULL, 'EC1A', 51.515617, -0.091998),
    ('Paris','Centre','5 Rue de Test', NULL, '75001', 48.856614, 2.352222),
    ('Stuttgart','Mitte','1 Schlossplatz', NULL, '70173', 48.775846, 9.182932),
    ('Madrid','Centro','Calle 1', NULL, '28013', 40.416775, -3.703790),
    ('Sao Paulo','Centro','Av Paulista', NULL, '01311-000', -23.561414, -46.655881),
    ('Beijing','Dongcheng','Tiananmen Rd', NULL, '100006', 39.908823, 116.397470),
    ('Tokyo','Chiyoda','Chiyoda 1-1', NULL, '100-8111', 35.693840, 139.753955),
    ('Buenos Aires','Microcentro','Florida 200', NULL, 'C1005', -34.603684, -58.381559),
    ('Guadalajara','Centro','Av Vallarta 1000', NULL, '44100', 20.659698, -103.349609)
  ) AS t(city_name, district_name, address_line_1, address_line_2, postal_code, latitude, longitude)
  JOIN sch_geography.city c ON c.city_name = t.city_name
  JOIN sch_geography.district d ON d.city_id = c.city_id AND d.district_name = t.district_name
ON CONFLICT (district_id, address_line_1) DO NOTHING;

COMMIT;
