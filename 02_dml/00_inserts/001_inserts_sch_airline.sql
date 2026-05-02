-- 001_inserts_sch_airline.sql
-- Inserta 10 aerolíneas de prueba (referenciando sch_geography.country)
BEGIN;

INSERT INTO sch_airline.airline (home_country_id, airline_code, airline_name, iata_code, icao_code, is_active)
VALUES
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='US'),'AL001','Air Alpha','A1','AA1',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='GB'),'AL002','BritAir','B2','BB2',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='FR'),'AL003','Air France Test','C3','CC3',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='DE'),'AL004','Deutsche Air','D4','DD4',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='ES'),'AL005','Iberia Test','E5','EE5',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='BR'),'AL006','BrasilFly','F6','FF6',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='CN'),'AL007','ChinaSky','G7','GG7',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='JP'),'AL008','NipponAir','H8','HH8',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='AR'),'AL009','Argento Air','I9','II9',true),
  ((SELECT country_id FROM sch_geography.country WHERE iso_alpha2='MX'),'AL010','MexiAir','J0','JJ0',true)
ON CONFLICT (airline_code) DO NOTHING;

COMMIT;
