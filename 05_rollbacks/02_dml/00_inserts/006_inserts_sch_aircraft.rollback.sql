-- 006_inserts_sch_aircraft.rollback.sql
-- Rollback para inserts en sch_aircraft
BEGIN;

DELETE FROM sch_aircraft.maintenance_event WHERE notes IS NULL;
DELETE FROM sch_aircraft.maintenance_type WHERE type_code LIKE 'MT%';
DELETE FROM sch_aircraft.maintenance_provider WHERE provider_name LIKE 'Provider %';

DELETE FROM sch_aircraft.aircraft_seat WHERE seat_column_code IS NOT NULL AND seat_row_number IS NOT NULL;
DELETE FROM sch_aircraft.aircraft_cabin WHERE cabin_code LIKE 'C%';
DELETE FROM sch_aircraft.aircraft WHERE registration_number LIKE 'REG%';
DELETE FROM sch_aircraft.cabin_class WHERE class_code LIKE 'CC%';
DELETE FROM sch_aircraft.aircraft_model WHERE model_code LIKE 'M%';
DELETE FROM sch_aircraft.aircraft_manufacturer WHERE manufacturer_name LIKE 'Manufacturer %';

COMMIT;
