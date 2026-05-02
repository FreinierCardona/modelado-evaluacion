-- 001_inserts_sch_airline.rollback.sql
-- Rollback para inserts en sch_airline
BEGIN;

DELETE FROM sch_airline.airline WHERE airline_code IN ('AL001','AL002','AL003','AL004','AL005','AL006','AL007','AL008','AL009','AL010');

COMMIT;
