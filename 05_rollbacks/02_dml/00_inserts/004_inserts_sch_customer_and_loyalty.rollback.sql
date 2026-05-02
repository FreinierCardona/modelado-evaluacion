-- 004_inserts_sch_customer_and_loyalty.rollback.sql
-- Rollback para inserts en sch_customer_and_loyalty
BEGIN;

DELETE FROM sch_customer_and_loyalty.customer_benefit WHERE granted_at IS NOT NULL AND benefit_type_id IN (
  SELECT benefit_type_id FROM sch_customer_and_loyalty.benefit_type WHERE benefit_code LIKE 'BT%'
);

DELETE FROM sch_customer_and_loyalty.miles_transaction WHERE loyalty_account_id IN (
  SELECT loyalty_account_id FROM sch_customer_and_loyalty.loyalty_account WHERE account_number LIKE 'LA%'
);

DELETE FROM sch_customer_and_loyalty.loyalty_account_tier WHERE loyalty_account_id IN (
  SELECT loyalty_account_id FROM sch_customer_and_loyalty.loyalty_account WHERE account_number LIKE 'LA%'
);

DELETE FROM sch_customer_and_loyalty.loyalty_account WHERE account_number LIKE 'LA%';

DELETE FROM sch_customer_and_loyalty.customer WHERE customer_since IS NOT NULL AND customer_id IN (
  SELECT customer_id FROM sch_customer_and_loyalty.customer
);

DELETE FROM sch_customer_and_loyalty.loyalty_tier WHERE tier_code LIKE 'LT%';
DELETE FROM sch_customer_and_loyalty.loyalty_program WHERE program_code LIKE 'LP%';
DELETE FROM sch_customer_and_loyalty.benefit_type WHERE benefit_code LIKE 'BT%';
DELETE FROM sch_customer_and_loyalty.customer_category WHERE category_code LIKE 'CC%';

COMMIT;
