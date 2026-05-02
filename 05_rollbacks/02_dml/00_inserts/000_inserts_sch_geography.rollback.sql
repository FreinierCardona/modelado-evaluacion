-- 000_inserts_sch_geography.rollback.sql
-- Rollback de los inserts realizados en sch_geography (eliminar en orden inverso)
BEGIN;

-- eliminar addresses
DELETE FROM sch_geography.address
WHERE address_line_1 IN (
  '100 Main St','10 High St','5 Rue de Test','1 Schlossplatz','Calle 1','Av Paulista','Tiananmen Rd','Chiyoda 1-1','Florida 200','Av Vallarta 1000'
);

-- eliminar districts (preciso por city)
DELETE FROM sch_geography.district d
USING sch_geography.city c
WHERE d.city_id = c.city_id AND (
  (c.city_name='Los Angeles' AND d.district_name='Downtown') OR
  (c.city_name='London' AND d.district_name='Central') OR
  (c.city_name='Paris' AND d.district_name='Centre') OR
  (c.city_name='Stuttgart' AND d.district_name='Mitte') OR
  (c.city_name='Madrid' AND d.district_name='Centro') OR
  (c.city_name='Sao Paulo' AND d.district_name='Centro') OR
  (c.city_name='Beijing' AND d.district_name='Dongcheng') OR
  (c.city_name='Tokyo' AND d.district_name='Chiyoda') OR
  (c.city_name='Buenos Aires' AND d.district_name='Microcentro') OR
  (c.city_name='Guadalajara' AND d.district_name='Centro')
);

-- eliminar cities
DELETE FROM sch_geography.city WHERE city_name IN ('Los Angeles','London','Paris','Stuttgart','Madrid','Sao Paulo','Beijing','Tokyo','Buenos Aires','Guadalajara');

-- eliminar states
DELETE FROM sch_geography.state_province WHERE state_name IN ('California','England','Ile-de-France','Baden-Wurttemberg','Madrid','Sao Paulo','Beijing','Tokyo','Buenos Aires','Jalisco');

-- eliminar countries
DELETE FROM sch_geography.country WHERE iso_alpha2 IN ('US','GB','FR','DE','ES','BR','CN','JP','AR','MX');

-- eliminar currencies
DELETE FROM sch_geography.currency WHERE iso_currency_code IN ('USD','EUR','GBP','BRL','CNY','JPY','ARS','MXN','CAD','AUD');

-- eliminar continents
DELETE FROM sch_geography.continent WHERE continent_code IN ('AFR','ANT','ASI','EUR','NAM','SAM','OCE','OT1','OT2','OT3');

-- eliminar time_zones
DELETE FROM sch_geography.time_zone WHERE time_zone_name IN ('UTC-8','UTC-7','UTC-6','UTC-5','UTC-3','UTC+0','UTC+1','UTC+2','UTC+8','UTC+9');

COMMIT;
