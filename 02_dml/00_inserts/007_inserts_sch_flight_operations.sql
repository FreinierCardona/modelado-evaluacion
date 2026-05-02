-- 007_inserts_sch_flight_operations.sql
-- Inserta estados de vuelo, razones de delay, vuelos, segmentos y delays (10 registros)
BEGIN;

-- flight_status (10 registros)
INSERT INTO sch_flight_operations.flight_status (status_code, status_name)
SELECT 'FS' || lpad(i::text,2,'0'), 'Flight Status ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (status_code) DO NOTHING;

-- delay_reason_type (10 registros)
INSERT INTO sch_flight_operations.delay_reason_type (reason_code, reason_name)
SELECT 'DR' || lpad(i::text,2,'0'), 'Delay Reason ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (reason_code) DO NOTHING;

-- flight (10 registros) — referencia airline y aircraft
WITH al AS (
  SELECT airline_id, row_number() OVER (ORDER BY airline_code) AS rn
  FROM sch_airline.airline
), ac AS (
  SELECT aircraft_id, row_number() OVER (ORDER BY aircraft_id) AS rn
  FROM sch_aircraft.aircraft
), fs AS (
  SELECT flight_status_id, row_number() OVER (ORDER BY status_code) AS rn
  FROM sch_flight_operations.flight_status
)
INSERT INTO sch_flight_operations.flight (airline_id, aircraft_id, flight_status_id, flight_number, service_date)
SELECT al.airline_id, ac.aircraft_id, fs.flight_status_id,
       'FL' || lpad(al.rn::text,4,'0'),
       (current_date + ((al.rn % 30) * INTERVAL '1 day'))::date
FROM al
JOIN ac ON ac.rn = al.rn
JOIN fs ON fs.rn = al.rn
WHERE al.rn <= 10
ON CONFLICT (airline_id, flight_number, service_date) DO NOTHING;

-- flight_segment (10 registros) — cada flight tiene un segmento que enlaza dos aeropuertos distintos
WITH f AS (
  SELECT flight_id, row_number() OVER (ORDER BY flight_id) AS rn
  FROM sch_flight_operations.flight
), ap AS (
  SELECT airport_id, row_number() OVER (ORDER BY airport_name) AS rn
  FROM sch_airport.airport
), ap_count AS (
  SELECT count(*) AS cnt FROM sch_airport.airport
)
INSERT INTO sch_flight_operations.flight_segment (flight_id, origin_airport_id, destination_airport_id, segment_number, scheduled_departure_at, scheduled_arrival_at)
SELECT f.flight_id, a1.airport_id, a2.airport_id, 1,
       now() + (f.rn * INTERVAL '1 hour'),
       now() + ((f.rn + 2) * INTERVAL '1 hour')
FROM f
CROSS JOIN ap_count
JOIN ap a1 ON a1.rn = f.rn
JOIN ap a2 ON a2.rn = CASE WHEN f.rn < ap_count.cnt THEN f.rn + 1 ELSE 1 END
WHERE f.rn <= ap_count.cnt
  AND ap_count.cnt > 1
  AND a1.airport_id IS NOT NULL
  AND a2.airport_id IS NOT NULL
  AND a1.airport_id IS DISTINCT FROM a2.airport_id
ON CONFLICT (flight_id, segment_number) DO NOTHING;

-- flight_delay (10 registros) — registra delays sobre segmentos
WITH fs_seg AS (
  SELECT flight_segment_id, row_number() OVER (ORDER BY flight_segment_id) AS rn
  FROM sch_flight_operations.flight_segment
), dr AS (
  SELECT delay_reason_type_id, row_number() OVER (ORDER BY reason_code) AS rn
  FROM sch_flight_operations.delay_reason_type
)
INSERT INTO sch_flight_operations.flight_delay (flight_segment_id, delay_reason_type_id, reported_at, delay_minutes)
SELECT fs_seg.flight_segment_id, dr.delay_reason_type_id,
       now() - (fs_seg.rn * INTERVAL '15 minute'),
       10 * fs_seg.rn
FROM fs_seg
JOIN dr ON dr.rn = fs_seg.rn
WHERE fs_seg.rn <= 10
ON CONFLICT DO NOTHING;

COMMIT;
