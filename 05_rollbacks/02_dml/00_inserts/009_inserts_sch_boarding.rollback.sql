-- 009_inserts_sch_boarding.rollback.sql
-- Rollback para sch_boarding
BEGIN;

DELETE FROM sch_boarding.boarding_validation WHERE validation_result IN ('APPROVED','REJECTED','MANUAL_REVIEW');
DELETE FROM sch_boarding.boarding_pass WHERE boarding_pass_code LIKE 'BP%';
DELETE FROM sch_boarding.check_in WHERE checked_in_at IS NOT NULL;
DELETE FROM sch_boarding.boarding_group WHERE group_code LIKE 'BG%';
DELETE FROM sch_boarding.check_in_status WHERE status_code LIKE 'CIS%';

COMMIT;
