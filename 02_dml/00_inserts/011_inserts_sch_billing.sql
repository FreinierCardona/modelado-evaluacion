-- 011_inserts_sch_billing.sql
-- Inserta impuestos, tasas de cambio, facturas y líneas de factura (10 registros por tabla)
BEGIN;

-- tax (10 registros)
INSERT INTO sch_billing.tax (tax_code, tax_name, rate_percentage, effective_from)
SELECT 'TX' || lpad(i::text,2,'0'), 'Tax ' || i, 5.0 + i, current_date - (i * INTERVAL '30 day')
FROM generate_series(1,10) AS s(i)
ON CONFLICT (tax_code) DO NOTHING;

-- exchange_rate (10 registros) — entre pares de monedas
WITH cur AS (
  SELECT currency_id, row_number() OVER (ORDER BY iso_currency_code) AS rn
  FROM sch_geography.currency
), cur_count AS (
  SELECT count(*) AS cnt FROM sch_geography.currency
)
INSERT INTO sch_billing.exchange_rate (from_currency_id, to_currency_id, effective_date, rate_value)
SELECT c1.currency_id, c2.currency_id,
       (current_date - ((c1.rn % 5) * INTERVAL '1 day'))::date,
       1.0 + (c1.rn * 0.01)
FROM cur c1
JOIN cur_count ON true
JOIN cur c2 ON c2.rn = CASE WHEN c1.rn < cur_count.cnt THEN c1.rn + 1 ELSE 1 END
WHERE c1.rn <= 10
  AND cur_count.cnt > 1
  AND c1.currency_id IS DISTINCT FROM c2.currency_id
ON CONFLICT (from_currency_id, to_currency_id, effective_date) DO NOTHING;

-- invoice_status (10 registros)
INSERT INTO sch_billing.invoice_status (status_code, status_name)
SELECT 'IS' || lpad(i::text,2,'0'), 'Invoice Status ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (status_code) DO NOTHING;

-- invoice (10 registros)
WITH s AS (
  SELECT sale_id, row_number() OVER (ORDER BY sale_id) AS rn
  FROM sch_sales_reservation_and_ticketing.sale
), ist AS (
  SELECT invoice_status_id, row_number() OVER (ORDER BY status_code) AS rn
  FROM sch_billing.invoice_status
), cur AS (
  SELECT currency_id, row_number() OVER (ORDER BY iso_currency_code) AS rn
  FROM sch_geography.currency
)
INSERT INTO sch_billing.invoice (sale_id, invoice_status_id, currency_id, invoice_number, issued_at)
SELECT s.sale_id, ist.invoice_status_id, cur.currency_id, 'INV' || lpad(s.rn::text,7,'0'), now() - (s.rn * INTERVAL '1 day')
FROM s
JOIN ist ON ist.rn = s.rn
JOIN cur ON cur.rn = s.rn
WHERE s.rn <= 10
ON CONFLICT (invoice_number) DO NOTHING;

-- invoice_line (10 registros)
WITH inv AS (
  SELECT invoice_id, row_number() OVER (ORDER BY invoice_id) AS rn
  FROM sch_billing.invoice
), tx AS (
  SELECT tax_id, row_number() OVER (ORDER BY tax_code) AS rn
  FROM sch_billing.tax
)
INSERT INTO sch_billing.invoice_line (invoice_id, tax_id, line_number, line_description, quantity, unit_price)
SELECT inv.invoice_id, tx.tax_id, 1, 'Line item ' || inv.rn, 1.0, 100.0 + (inv.rn * 10)
FROM inv
JOIN tx ON tx.rn = inv.rn
WHERE inv.rn <= 10
ON CONFLICT (invoice_id, line_number) DO NOTHING;

COMMIT;
