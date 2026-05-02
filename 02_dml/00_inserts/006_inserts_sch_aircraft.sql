-- 006_inserts_sch_aircraft.sql
-- Inserta fabricantes, modelos, cabinas, aeronaves y eventos de mantenimiento (10 registros por tabla)
BEGIN;

-- aircraft_manufacturer (10 registros)
INSERT INTO sch_aircraft.aircraft_manufacturer (manufacturer_name)
SELECT 'Manufacturer ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (manufacturer_name) DO NOTHING;

-- aircraft_model (10 registros)
WITH am AS (
  SELECT aircraft_manufacturer_id, row_number() OVER (ORDER BY manufacturer_name) AS rn
  FROM sch_aircraft.aircraft_manufacturer
)
INSERT INTO sch_aircraft.aircraft_model (aircraft_manufacturer_id, model_code, model_name, max_range_km)
SELECT am.aircraft_manufacturer_id, 'M' || lpad(am.rn::text,3,'0'), 'Model ' || am.rn, 5000 + (am.rn * 200)
FROM am
WHERE am.rn <= 10
ON CONFLICT (aircraft_manufacturer_id, model_code) DO NOTHING;

-- cabin_class (10 registros)
INSERT INTO sch_aircraft.cabin_class (class_code, class_name)
SELECT 'CC' || lpad(i::text,2,'0'), 'Cabin ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (class_code) DO NOTHING;

-- aircraft (10 registros) — referencia a airline y modelo
WITH al AS (
  SELECT airline_id, row_number() OVER (ORDER BY airline_code) AS rn
  FROM sch_airline.airline
), amod AS (
  SELECT aircraft_model_id, row_number() OVER (ORDER BY model_code) AS rn
  FROM sch_aircraft.aircraft_model
)
INSERT INTO sch_aircraft.aircraft (airline_id, aircraft_model_id, registration_number, serial_number, in_service_on)
SELECT al.airline_id, amod.aircraft_model_id,
       'REG' || lpad(al.rn::text,4,'0'), 'SN' || lpad(al.rn::text,6,'0'),
       current_date - (al.rn * INTERVAL '365 day')
FROM al
JOIN amod ON amod.rn = al.rn
WHERE al.rn <= 10
ON CONFLICT (registration_number) DO NOTHING;

-- aircraft_cabin (10 registros)
WITH ac AS (
  SELECT aircraft_id, row_number() OVER (ORDER BY aircraft_id) AS rn
  FROM sch_aircraft.aircraft
), cc AS (
  SELECT cabin_class_id, row_number() OVER (ORDER BY class_code) AS rn
  FROM sch_aircraft.cabin_class
)
INSERT INTO sch_aircraft.aircraft_cabin (aircraft_id, cabin_class_id, cabin_code, deck_number)
SELECT ac.aircraft_id, cc.cabin_class_id, 'C' || ac.rn, 1
FROM ac
JOIN cc ON cc.rn = ac.rn
WHERE ac.rn <= 10
ON CONFLICT (aircraft_id, cabin_code) DO NOTHING;

-- aircraft_seat (10 registros)
WITH ac AS (
  SELECT aircraft_cabin_id, row_number() OVER (ORDER BY aircraft_cabin_id) AS rn
  FROM sch_aircraft.aircraft_cabin
)
INSERT INTO sch_aircraft.aircraft_seat (aircraft_cabin_id, seat_row_number, seat_column_code, is_window, is_aisle)
SELECT ac.aircraft_cabin_id, ((ac.rn - 1) % 30) + 1, chr((65 + ((ac.rn - 1) % 6))::int)::varchar,
       (ac.rn % 3)=0, (ac.rn % 4)=0
FROM ac
WHERE ac.rn <= 10
ON CONFLICT (aircraft_cabin_id, seat_row_number, seat_column_code) DO NOTHING;

-- maintenance_provider (10 registros)
WITH adr AS (
  SELECT address_id, row_number() OVER (ORDER BY address_line_1) AS rn
  FROM sch_geography.address
)
INSERT INTO sch_aircraft.maintenance_provider (address_id, provider_name, contact_name)
SELECT adr.address_id, 'Provider ' || adr.rn, 'Contact ' || adr.rn
FROM adr
WHERE adr.rn <= 10
ON CONFLICT (provider_name) DO NOTHING;

-- maintenance_type (10 registros)
INSERT INTO sch_aircraft.maintenance_type (type_code, type_name)
SELECT 'MT' || lpad(i::text,2,'0'), 'Maintenance Type ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (type_code) DO NOTHING;

-- maintenance_event (10 registros)
WITH acft AS (
  SELECT aircraft_id, row_number() OVER (ORDER BY aircraft_id) AS rn
  FROM sch_aircraft.aircraft
), mt AS (
  SELECT maintenance_type_id, row_number() OVER (ORDER BY type_code) AS rn
  FROM sch_aircraft.maintenance_type
), mp AS (
  SELECT maintenance_provider_id, row_number() OVER (ORDER BY provider_name) AS rn
  FROM sch_aircraft.maintenance_provider
)
INSERT INTO sch_aircraft.maintenance_event (aircraft_id, maintenance_type_id, maintenance_provider_id, status_code, started_at)
SELECT acft.aircraft_id, mt.maintenance_type_id, mp.maintenance_provider_id,
       CASE WHEN (acft.rn % 2)=0 THEN 'PLANNED' ELSE 'COMPLETED' END,
       now() - (acft.rn * INTERVAL '7 day')
FROM acft
JOIN mt ON mt.rn = acft.rn
JOIN mp ON mp.rn = acft.rn
WHERE acft.rn <= 10
ON CONFLICT DO NOTHING;

COMMIT;
