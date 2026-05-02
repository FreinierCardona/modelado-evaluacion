-- 005_inserts_sch_airport.rollback.sql
-- Rollback para inserts en sch_airport
BEGIN;

DELETE FROM sch_airport.airport_regulation WHERE regulation_code LIKE 'AR%';
DELETE FROM sch_airport.runway WHERE runway_code LIKE 'RW%';
DELETE FROM sch_airport.boarding_gate WHERE gate_code LIKE 'G%';
DELETE FROM sch_airport.terminal WHERE terminal_code LIKE 'T%';
DELETE FROM sch_airport.airport WHERE airport_name LIKE 'Airport %' OR iata_code IS NOT NULL AND length(iata_code)=3;

COMMIT;
