-- 007_inserts_sch_flight_operations.rollback.sql
-- Rollback para sch_flight_operations
BEGIN;

DELETE FROM sch_flight_operations.flight_delay WHERE delay_minutes IS NOT NULL;
DELETE FROM sch_flight_operations.flight_segment WHERE segment_number = 1;
DELETE FROM sch_flight_operations.flight WHERE flight_number LIKE 'FL%';
DELETE FROM sch_flight_operations.delay_reason_type WHERE reason_code LIKE 'DR%';
DELETE FROM sch_flight_operations.flight_status WHERE status_code LIKE 'FS%';

COMMIT;
