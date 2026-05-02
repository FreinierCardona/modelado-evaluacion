-- 008_inserts_sch_sales_reservation_and_ticketing.sql
-- Inserta catálogos y datos de reservas, ventas y tickets (10 registros por tabla)
BEGIN;

-- reservation_status (10 registros)
INSERT INTO sch_sales_reservation_and_ticketing.reservation_status (status_code, status_name)
SELECT 'RS' || lpad(i::text,2,'0'), 'Reservation Status ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (status_code) DO NOTHING;

-- sale_channel (10 registros)
INSERT INTO sch_sales_reservation_and_ticketing.sale_channel (channel_code, channel_name)
SELECT 'SC' || lpad(i::text,2,'0'), 'Channel ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (channel_code) DO NOTHING;

-- fare_class (10 registros) — requiere cabin_class
WITH cc AS (
  SELECT cabin_class_id, row_number() OVER (ORDER BY class_code) AS rn
  FROM sch_aircraft.cabin_class
)
INSERT INTO sch_sales_reservation_and_ticketing.fare_class (cabin_class_id, fare_class_code, fare_class_name, is_refundable_by_default)
SELECT cc.cabin_class_id, 'FC' || lpad(cc.rn::text,2,'0'), 'Fare Class ' || cc.rn, (cc.rn % 2 = 0)
FROM cc
WHERE cc.rn <= 10
ON CONFLICT (fare_class_code) DO NOTHING;

-- fare (10 registros) — referencia airline, airports, fare_class, currency
WITH al AS (
  SELECT airline_id, row_number() OVER (ORDER BY airline_code) AS rn
  FROM sch_airline.airline
), ap AS (
  SELECT airport_id, row_number() OVER (ORDER BY airport_name) AS rn
  FROM sch_airport.airport
), ap_count AS (
  SELECT count(*) AS cnt FROM sch_airport.airport
), fc AS (
  SELECT fare_class_id, row_number() OVER (ORDER BY fare_class_code) AS rn
  FROM sch_sales_reservation_and_ticketing.fare_class
), cur AS (
  SELECT currency_id, row_number() OVER (ORDER BY iso_currency_code) AS rn
  FROM sch_geography.currency
)
INSERT INTO sch_sales_reservation_and_ticketing.fare (airline_id, origin_airport_id, destination_airport_id, fare_class_id, currency_id, fare_code, base_amount, valid_from)
SELECT
  al.airline_id,
  a1.airport_id,
  a2.airport_id,
  fc.fare_class_id,
  cur.currency_id,
  'F' || lpad(al.rn::text,4,'0'),
  100 + (al.rn * 50),
  (current_date - ((al.rn % 5) * INTERVAL '1 day'))::date
FROM al
JOIN ap_count ON true
JOIN ap a1 ON a1.rn = al.rn
JOIN ap a2 ON a2.rn = CASE WHEN al.rn < ap_count.cnt THEN al.rn + 1 ELSE 1 END
JOIN fc ON fc.rn = al.rn
JOIN cur ON cur.rn = al.rn
WHERE al.rn <= 10
  AND ap_count.cnt > 1
  AND a1.airport_id IS NOT NULL
  AND a2.airport_id IS NOT NULL
  AND a1.airport_id IS DISTINCT FROM a2.airport_id
ON CONFLICT (fare_code) DO NOTHING;

-- ticket_status (10 registros)
INSERT INTO sch_sales_reservation_and_ticketing.ticket_status (status_code, status_name)
SELECT 'TS' || lpad(i::text,2,'0'), 'Ticket Status ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (status_code) DO NOTHING;

-- reservation (10 registros) — vincula booked_by_customer_id opcionalmente
WITH c AS (
  SELECT customer_id, row_number() OVER (ORDER BY customer_id) AS rn
  FROM sch_customer_and_loyalty.customer
), rs AS (
  SELECT reservation_status_id, row_number() OVER (ORDER BY status_code) AS rn
  FROM sch_sales_reservation_and_ticketing.reservation_status
), sc AS (
  SELECT sale_channel_id, row_number() OVER (ORDER BY channel_code) AS rn
  FROM sch_sales_reservation_and_ticketing.sale_channel
)
INSERT INTO sch_sales_reservation_and_ticketing.reservation (booked_by_customer_id, reservation_status_id, sale_channel_id, reservation_code, booked_at)
SELECT c.customer_id, rs.reservation_status_id, sc.sale_channel_id,
       'R' || lpad(c.rn::text,6,'0'),
       now() - (c.rn * INTERVAL '1 day')
FROM c
JOIN rs ON rs.rn = c.rn
JOIN sc ON sc.rn = c.rn
WHERE c.rn <= 10
ON CONFLICT (reservation_code) DO NOTHING;

-- reservation_passenger (10 registros)
WITH r AS (
  SELECT reservation_id, row_number() OVER (ORDER BY reservation_id) AS rn
  FROM sch_sales_reservation_and_ticketing.reservation
), p AS (
  SELECT person_id, row_number() OVER (ORDER BY person_id) AS rn
  FROM sch_identity.person
)
INSERT INTO sch_sales_reservation_and_ticketing.reservation_passenger (reservation_id, person_id, passenger_sequence_no, passenger_type)
SELECT r.reservation_id, p.person_id, r.rn,
       CASE WHEN (r.rn % 5)=0 THEN 'INFANT' ELSE 'ADULT' END
FROM r
JOIN p ON p.rn = r.rn
WHERE r.rn <= 10
ON CONFLICT DO NOTHING;

-- sale (10 registros)
WITH r AS (
  SELECT reservation_id, row_number() OVER (ORDER BY reservation_id) AS rn
  FROM sch_sales_reservation_and_ticketing.reservation
), cur AS (
  SELECT currency_id, row_number() OVER (ORDER BY iso_currency_code) AS rn
  FROM sch_geography.currency
)
INSERT INTO sch_sales_reservation_and_ticketing.sale (reservation_id, currency_id, sale_code, sold_at)
SELECT r.reservation_id, cur.currency_id, 'S' || lpad(r.rn::text,6,'0'), now() - (r.rn * INTERVAL '2 hour')
FROM r
JOIN cur ON cur.rn = r.rn
WHERE r.rn <= 10
ON CONFLICT (sale_code) DO NOTHING;

-- ticket (10 registros)
WITH s AS (
  SELECT sale_id, row_number() OVER (ORDER BY sale_id) AS rn
  FROM sch_sales_reservation_and_ticketing.sale
), rp AS (
  SELECT reservation_passenger_id, row_number() OVER (ORDER BY reservation_passenger_id) AS rn
  FROM sch_sales_reservation_and_ticketing.reservation_passenger
), f AS (
  SELECT fare_id, row_number() OVER (ORDER BY fare_code) AS rn
  FROM sch_sales_reservation_and_ticketing.fare
), ts AS (
  SELECT ticket_status_id, row_number() OVER (ORDER BY status_code) AS rn
  FROM sch_sales_reservation_and_ticketing.ticket_status
)
INSERT INTO sch_sales_reservation_and_ticketing.ticket (sale_id, reservation_passenger_id, fare_id, ticket_status_id, ticket_number, issued_at)
SELECT s.sale_id, rp.reservation_passenger_id, f.fare_id, ts.ticket_status_id,
       'T' || lpad(s.rn::text,8,'0'),
       now() - (s.rn * INTERVAL '1 hour')
FROM s
JOIN rp ON rp.rn = s.rn
JOIN f ON f.rn = s.rn
JOIN ts ON ts.rn = s.rn
WHERE s.rn <= 10
ON CONFLICT (ticket_number) DO NOTHING;

-- ticket_segment (10 registros)
WITH t AS (
  SELECT ticket_id, row_number() OVER (ORDER BY ticket_id) AS rn
  FROM sch_sales_reservation_and_ticketing.ticket
), fs AS (
  SELECT flight_segment_id, row_number() OVER (ORDER BY flight_segment_id) AS rn
  FROM sch_flight_operations.flight_segment
)
INSERT INTO sch_sales_reservation_and_ticketing.ticket_segment (ticket_id, flight_segment_id, segment_sequence_no, fare_basis_code)
SELECT t.ticket_id, fs.flight_segment_id, 1, 'FB' || lpad(t.rn::text,3,'0')
FROM t
JOIN fs ON fs.rn = t.rn
WHERE t.rn <= 10
ON CONFLICT DO NOTHING;

-- seat_assignment (10 registros) — referencia seat + ticket_segment + flight_segment
WITH ts AS (
  SELECT ticket_segment_id, row_number() OVER (ORDER BY ticket_segment_id) AS rn
  FROM sch_sales_reservation_and_ticketing.ticket_segment
), fs AS (
  SELECT flight_segment_id, row_number() OVER (ORDER BY flight_segment_id) AS rn
  FROM sch_flight_operations.flight_segment
), asat AS (
  SELECT aircraft_seat_id, row_number() OVER (ORDER BY aircraft_seat_id) AS rn
  FROM sch_aircraft.aircraft_seat
)
INSERT INTO sch_sales_reservation_and_ticketing.seat_assignment (ticket_segment_id, flight_segment_id, aircraft_seat_id, assigned_at, assignment_source)
SELECT ts.ticket_segment_id, fs.flight_segment_id, asat.aircraft_seat_id, now() - (ts.rn * INTERVAL '30 minute'), 'AUTO'
FROM ts
JOIN fs ON fs.rn = ts.rn
JOIN asat ON asat.rn = ts.rn
WHERE ts.rn <= 10
ON CONFLICT DO NOTHING;

-- baggage (10 registros)
WITH ts AS (
  SELECT ticket_segment_id, row_number() OVER (ORDER BY ticket_segment_id) AS rn
  FROM sch_sales_reservation_and_ticketing.ticket_segment
)
INSERT INTO sch_sales_reservation_and_ticketing.baggage (ticket_segment_id, baggage_tag, baggage_type, baggage_status, weight_kg)
SELECT ts.ticket_segment_id, 'BG' || lpad(ts.rn::text,5,'0'), 'CHECKED', 'REGISTERED', 15.0 + ts.rn
FROM ts
WHERE ts.rn <= 10
ON CONFLICT (baggage_tag) DO NOTHING;

COMMIT;
