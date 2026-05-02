-- 011_inserts_sch_billing.rollback.sql
-- Rollback para sch_billing
BEGIN;

DELETE FROM sch_billing.invoice_line WHERE line_description LIKE 'Line item %';
DELETE FROM sch_billing.invoice WHERE invoice_number LIKE 'INV%';
DELETE FROM sch_billing.invoice_status WHERE status_code LIKE 'IS%';
DELETE FROM sch_billing.exchange_rate WHERE rate_value IS NOT NULL;
DELETE FROM sch_billing.tax WHERE tax_code LIKE 'TX%';

COMMIT;
