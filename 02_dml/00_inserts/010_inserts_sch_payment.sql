-- 010_inserts_sch_payment.sql
-- Inserta catálogos y pagos de prueba (10 registros por tabla)
BEGIN;

-- payment_status (10 registros)
INSERT INTO sch_payment.payment_status (status_code, status_name)
SELECT 'PS' || lpad(i::text,2,'0'), 'Payment Status ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (status_code) DO NOTHING;

-- payment_method (10 registros)
INSERT INTO sch_payment.payment_method (method_code, method_name)
SELECT 'PM' || lpad(i::text,2,'0'), 'Payment Method ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (method_code) DO NOTHING;

-- payment (10 registros)
WITH s AS (
  SELECT sale_id, row_number() OVER (ORDER BY sale_id) AS rn
  FROM sch_sales_reservation_and_ticketing.sale
), ps AS (
  SELECT payment_status_id, row_number() OVER (ORDER BY status_code) AS rn
  FROM sch_payment.payment_status
), pm AS (
  SELECT payment_method_id, row_number() OVER (ORDER BY method_code) AS rn
  FROM sch_payment.payment_method
), cur AS (
  SELECT currency_id, row_number() OVER (ORDER BY iso_currency_code) AS rn
  FROM sch_geography.currency
)
INSERT INTO sch_payment.payment (sale_id, payment_status_id, payment_method_id, currency_id, payment_reference, amount, authorized_at)
SELECT s.sale_id, ps.payment_status_id, pm.payment_method_id, cur.currency_id,
       'PAY' || lpad(s.rn::text,6,'0'), 100 + (s.rn * 10), now() - (s.rn * INTERVAL '1 hour')
FROM s
JOIN ps ON ps.rn = s.rn
JOIN pm ON pm.rn = s.rn
JOIN cur ON cur.rn = s.rn
WHERE s.rn <= 10
ON CONFLICT (payment_reference) DO NOTHING;

-- payment_transaction (10 registros)
WITH p AS (
  SELECT payment_id, row_number() OVER (ORDER BY payment_id) AS rn
  FROM sch_payment.payment
)
INSERT INTO sch_payment.payment_transaction (payment_id, transaction_reference, transaction_type, transaction_amount, processed_at)
SELECT p.payment_id, 'PTR' || lpad(p.rn::text,6,'0'), CASE WHEN (p.rn % 2)=0 THEN 'CAPTURE' ELSE 'AUTH' END,
       100 + (p.rn * 10), now() - (p.rn * INTERVAL '30 minute')
FROM p
WHERE p.rn <= 10
ON CONFLICT (transaction_reference) DO NOTHING;

-- refund (10 registros)
WITH p AS (
  SELECT payment_id, row_number() OVER (ORDER BY payment_id) AS rn
  FROM sch_payment.payment
)
INSERT INTO sch_payment.refund (payment_id, refund_reference, amount, requested_at)
SELECT p.payment_id, 'REF' || lpad(p.rn::text,6,'0'), (p.rn % 3) * 10 + 1, now() - (p.rn * INTERVAL '2 day')
FROM p
WHERE p.rn <= 10
ON CONFLICT (refund_reference) DO NOTHING;

COMMIT;
