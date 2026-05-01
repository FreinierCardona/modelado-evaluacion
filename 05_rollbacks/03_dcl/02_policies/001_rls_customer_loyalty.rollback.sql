
-- Deshabilita las políticas RLS y remueve las policies creadas

-- customer
ALTER TABLE sch_customer_and_loyalty.customer FORCE ROW LEVEL SECURITY NO FORCE;
ALTER TABLE sch_customer_and_loyalty.customer DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_customer_app_service ON sch_customer_and_loyalty.customer;
DROP POLICY IF EXISTS pol_customer_audit_roles ON sch_customer_and_loyalty.customer;
DROP POLICY IF EXISTS pol_customer_admin ON sch_customer_and_loyalty.customer;

-- loyalty_account
ALTER TABLE sch_customer_and_loyalty.loyalty_account FORCE ROW LEVEL SECURITY NO FORCE;
ALTER TABLE sch_customer_and_loyalty.loyalty_account DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_loyalty_account_app_service ON sch_customer_and_loyalty.loyalty_account;
DROP POLICY IF EXISTS pol_loyalty_account_audit ON sch_customer_and_loyalty.loyalty_account;
DROP POLICY IF EXISTS pol_loyalty_account_admin ON sch_customer_and_loyalty.loyalty_account;

-- miles_transaction
ALTER TABLE sch_customer_and_loyalty.miles_transaction FORCE ROW LEVEL SECURITY NO FORCE;
ALTER TABLE sch_customer_and_loyalty.miles_transaction DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_miles_transaction_app_service ON sch_customer_and_loyalty.miles_transaction;
DROP POLICY IF EXISTS pol_miles_transaction_audit ON sch_customer_and_loyalty.miles_transaction;
DROP POLICY IF EXISTS pol_miles_transaction_admin ON sch_customer_and_loyalty.miles_transaction;

-- loyalty_account_tier
ALTER TABLE sch_customer_and_loyalty.loyalty_account_tier FORCE ROW LEVEL SECURITY NO FORCE;
ALTER TABLE sch_customer_and_loyalty.loyalty_account_tier DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_loyalty_tier_app_service ON sch_customer_and_loyalty.loyalty_account_tier;
DROP POLICY IF EXISTS pol_loyalty_tier_audit ON sch_customer_and_loyalty.loyalty_account_tier;
DROP POLICY IF EXISTS pol_loyalty_tier_admin ON sch_customer_and_loyalty.loyalty_account_tier;
