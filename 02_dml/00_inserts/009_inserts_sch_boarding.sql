-- 009_inserts_sch_boarding.sql
-- Inserta datos de embarque: grupos, check-ins, pases y validaciones (10 registros)
BEGIN;

-- boarding_group (10 registros)
INSERT INTO sch_boarding.boarding_group (group_code, group_name, sequence_no)
SELECT 'BG' || lpad(i::text,2,'0'), 'Boarding Group ' || i, i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (group_code) DO NOTHING;

-- check_in_status (10 registros)
INSERT INTO sch_boarding.check_in_status (status_code, status_name)
SELECT 'CIS' || lpad(i::text,2,'0'), 'Check-in Status ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (status_code) DO NOTHING;

-- check_in (10 registros)
WITH ts AS (
  SELECT ticket_segment_id, row_number() OVER (ORDER BY ticket_segment_id) AS rn
  FROM sch_sales_reservation_and_ticketing.ticket_segment
), cis AS (
  SELECT check_in_status_id, row_number() OVER (ORDER BY status_code) AS rn
  FROM sch_boarding.check_in_status
), bg AS (
  SELECT boarding_group_id, row_number() OVER (ORDER BY group_code) AS rn
  FROM sch_boarding.boarding_group
), ua AS (
  SELECT user_account_id, row_number() OVER (ORDER BY user_account_id) AS rn
  FROM sch_security.user_account
)
INSERT INTO sch_boarding.check_in (ticket_segment_id, check_in_status_id, boarding_group_id, checked_in_by_user_id, checked_in_at)
SELECT ts.ticket_segment_id, cis.check_in_status_id, bg.boarding_group_id, ua.user_account_id, now() - (ts.rn * INTERVAL '2 hour')
FROM ts
JOIN cis ON cis.rn = ts.rn
JOIN bg ON bg.rn = ts.rn
JOIN ua ON ua.rn = ts.rn
WHERE ts.rn <= 10
ON CONFLICT (ticket_segment_id) DO NOTHING;

-- boarding_pass (10 registros)
WITH ci AS (
  SELECT check_in_id, row_number() OVER (ORDER BY check_in_id) AS rn
  FROM sch_boarding.check_in
)
INSERT INTO sch_boarding.boarding_pass (check_in_id, boarding_pass_code, barcode_value, issued_at)
SELECT ci.check_in_id, 'BP' || lpad(ci.rn::text,8,'0'), 'BC' || lpad(ci.rn::text,12,'0'), now() - (ci.rn * INTERVAL '1 hour')
FROM ci
WHERE ci.rn <= 10
ON CONFLICT (boarding_pass_code) DO NOTHING;

-- boarding_validation (10 registros)
WITH bp AS (
  SELECT boarding_pass_id, row_number() OVER (ORDER BY boarding_pass_id) AS rn
  FROM sch_boarding.boarding_pass
), bg AS (
  SELECT boarding_gate_id, row_number() OVER (ORDER BY boarding_gate_id) AS rn
  FROM sch_airport.boarding_gate
), ua AS (
  SELECT user_account_id, row_number() OVER (ORDER BY user_account_id) AS rn
  FROM sch_security.user_account
)
INSERT INTO sch_boarding.boarding_validation (boarding_pass_id, boarding_gate_id, validated_by_user_id, validated_at, validation_result)
SELECT bp.boarding_pass_id, bg.boarding_gate_id, ua.user_account_id, now() - (bp.rn * INTERVAL '30 minute'),
       CASE WHEN (bp.rn % 5)=0 THEN 'MANUAL_REVIEW' WHEN (bp.rn % 4)=0 THEN 'REJECTED' ELSE 'APPROVED' END
FROM bp
JOIN bg ON bg.rn = bp.rn
JOIN ua ON ua.rn = bp.rn
WHERE bp.rn <= 10
ON CONFLICT DO NOTHING;

COMMIT;
