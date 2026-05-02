-- 010_inserts_sch_payment.rollback.sql
-- Rollback para sch_payment
BEGIN;

DELETE FROM sch_payment.refund WHERE refund_reference LIKE 'REF%';
DELETE FROM sch_payment.payment_transaction WHERE transaction_reference LIKE 'PTR%';
DELETE FROM sch_payment.payment WHERE payment_reference LIKE 'PAY%';
DELETE FROM sch_payment.payment_method WHERE method_code LIKE 'PM%';
DELETE FROM sch_payment.payment_status WHERE status_code LIKE 'PS%';

COMMIT;
