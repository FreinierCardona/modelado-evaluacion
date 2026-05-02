-- 004_inserts_sch_customer_and_loyalty.sql
-- Inserta datos de cliente y lealtad (10 registros por tabla)
BEGIN;

-- customer_category (10 registros)
INSERT INTO sch_customer_and_loyalty.customer_category (category_code, category_name)
SELECT 'CC' || lpad(i::text,2,'0'), 'Customer Category ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (category_code) DO NOTHING;

-- benefit_type (10 registros)
INSERT INTO sch_customer_and_loyalty.benefit_type (benefit_code, benefit_name, benefit_description)
SELECT 'BT' || lpad(i::text,2,'0'), 'Benefit ' || i, 'Benefit description ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (benefit_code) DO NOTHING;

-- loyalty_program (10 registros) — necesita airline y currency
WITH al AS (
  SELECT airline_id, row_number() OVER (ORDER BY airline_code) AS rn
  FROM sch_airline.airline
), cur AS (
  SELECT currency_id, row_number() OVER (ORDER BY iso_currency_code) AS rn
  FROM sch_geography.currency
)
INSERT INTO sch_customer_and_loyalty.loyalty_program (airline_id, default_currency_id, program_code, program_name, expiration_months)
SELECT al.airline_id, cur.currency_id, 'LP' || lpad(al.rn::text,2,'0'), 'Loyalty Program ' || al.rn, 24
FROM al
JOIN cur ON cur.rn = al.rn
WHERE al.rn <= 10
ON CONFLICT (airline_id, program_code) DO NOTHING;

-- loyalty_tier (10 registros)
WITH lp AS (
  SELECT loyalty_program_id, row_number() OVER (ORDER BY program_code) AS rn
  FROM sch_customer_and_loyalty.loyalty_program
)
INSERT INTO sch_customer_and_loyalty.loyalty_tier (loyalty_program_id, tier_code, tier_name, priority_level, required_miles)
SELECT lp.loyalty_program_id, 'LT' || lpad(lp.rn::text,2,'0'), 'Tier ' || lp.rn, lp.rn, lp.rn * 1000
FROM lp
WHERE lp.rn <= 10
ON CONFLICT (loyalty_program_id, tier_code) DO NOTHING;

-- customer (10 registros) — vincula person_id y airline
WITH al AS (
  SELECT airline_id, row_number() OVER (ORDER BY airline_code) AS rn
  FROM sch_airline.airline
), p AS (
  SELECT person_id, row_number() OVER (ORDER BY person_id) AS rn
  FROM sch_identity.person
), cc AS (
  SELECT customer_category_id, row_number() OVER (ORDER BY category_code) AS rn
  FROM sch_customer_and_loyalty.customer_category
)
INSERT INTO sch_customer_and_loyalty.customer (airline_id, person_id, customer_category_id, customer_since)
SELECT al.airline_id, p.person_id, cc.customer_category_id,
       (current_date - ((al.rn % 365) * INTERVAL '1 day'))::date
FROM al
JOIN p ON p.rn = al.rn
JOIN cc ON cc.rn = al.rn
WHERE al.rn <= 10
ON CONFLICT (airline_id, person_id) DO NOTHING;

-- loyalty_account (10 registros)
WITH c AS (
  SELECT customer_id, row_number() OVER (ORDER BY customer_id) AS rn
  FROM sch_customer_and_loyalty.customer
), lp AS (
  SELECT loyalty_program_id, row_number() OVER (ORDER BY program_code) AS rn
  FROM sch_customer_and_loyalty.loyalty_program
)
INSERT INTO sch_customer_and_loyalty.loyalty_account (customer_id, loyalty_program_id, account_number, opened_at)
SELECT c.customer_id, lp.loyalty_program_id, 'LA' || lpad(c.rn::text,6,'0'), now() - (c.rn * INTERVAL '1 day')
FROM c
JOIN lp ON lp.rn = c.rn
WHERE c.rn <= 10
ON CONFLICT (account_number) DO NOTHING;

-- loyalty_account_tier (10 registros)
WITH la AS (
  SELECT loyalty_account_id, row_number() OVER (ORDER BY loyalty_account_id) AS rn
  FROM sch_customer_and_loyalty.loyalty_account
), lt AS (
  SELECT loyalty_tier_id, row_number() OVER (ORDER BY tier_code) AS rn
  FROM sch_customer_and_loyalty.loyalty_tier
)
INSERT INTO sch_customer_and_loyalty.loyalty_account_tier (loyalty_account_id, loyalty_tier_id, assigned_at, expires_at)
SELECT la.loyalty_account_id, lt.loyalty_tier_id, now() - (la.rn * INTERVAL '30 day'), NULL
FROM la
JOIN lt ON lt.rn = la.rn
WHERE la.rn <= 10
ON CONFLICT (loyalty_account_id, assigned_at) DO NOTHING;

-- miles_transaction (10 registros)
WITH la AS (
  SELECT loyalty_account_id, row_number() OVER (ORDER BY loyalty_account_id) AS rn
  FROM sch_customer_and_loyalty.loyalty_account
)
INSERT INTO sch_customer_and_loyalty.miles_transaction (loyalty_account_id, transaction_type, miles_delta, occurred_at, reference_code)
SELECT la.loyalty_account_id,
       CASE WHEN (la.rn % 2)=0 THEN 'EARN' ELSE 'REDEEM' END,
       CASE WHEN (la.rn % 2)=0 THEN (1000 * la.rn) ELSE -(500 * la.rn) END,
       now() - (la.rn * INTERVAL '2 day'),
       'MT' || lpad(la.rn::text,4,'0')
FROM la
WHERE la.rn <= 10
ON CONFLICT DO NOTHING;

-- customer_benefit (10 registros)
WITH c AS (
  SELECT customer_id, row_number() OVER (ORDER BY customer_id) AS rn
  FROM sch_customer_and_loyalty.customer
), bt AS (
  SELECT benefit_type_id, row_number() OVER (ORDER BY benefit_code) AS rn
  FROM sch_customer_and_loyalty.benefit_type
)
INSERT INTO sch_customer_and_loyalty.customer_benefit (customer_id, benefit_type_id, granted_at, expires_at)
SELECT c.customer_id, bt.benefit_type_id, now() - (c.rn * INTERVAL '10 day'), now() + (c.rn * INTERVAL '180 day')
FROM c
JOIN bt ON bt.rn = c.rn
WHERE c.rn <= 10
ON CONFLICT DO NOTHING;

COMMIT;
