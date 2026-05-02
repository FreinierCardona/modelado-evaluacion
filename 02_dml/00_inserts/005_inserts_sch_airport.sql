-- 005_inserts_sch_airport.sql
-- Inserta aeropuertos, terminales, puertas y pistas (10 registros por tabla)
BEGIN;

-- airport (hasta 10 registros) — usa direcciones ya creadas en sch_geography.address
WITH a AS (
  SELECT address_id, row_number() OVER (ORDER BY address_line_1) AS rn
  FROM sch_geography.address
)
INSERT INTO sch_airport.airport (address_id, airport_name, iata_code, icao_code, is_active)
SELECT
  a.address_id,
  'Airport ' || a.rn,
  lpad(substr('AAA'||a.rn::text, -3),3,'A'),
  lpad(substr('IIII'||a.rn::text, -4),4,'I'),
  true
FROM a
WHERE a.rn <= 10
ON CONFLICT (iata_code) DO NOTHING;

-- terminal (uno por aeropuerto existente, hasta 10)
WITH at AS (
  SELECT airport_id, row_number() OVER (ORDER BY airport_name) AS rn
  FROM sch_airport.airport
)
INSERT INTO sch_airport.terminal (airport_id, terminal_code, terminal_name)
SELECT
  at.airport_id,
  'T' || at.rn,
  'Terminal ' || at.rn
FROM at
WHERE at.rn <= 10
ON CONFLICT (airport_id, terminal_code) DO NOTHING;

-- boarding_gate (uno por terminal existente, hasta 10)
WITH t AS (
  SELECT terminal_id, row_number() OVER (ORDER BY terminal_name) AS rn
  FROM sch_airport.terminal
)
INSERT INTO sch_airport.boarding_gate (terminal_id, gate_code, is_active)
SELECT
  t.terminal_id,
  'G' || t.rn,
  true
FROM t
WHERE t.rn <= 10
ON CONFLICT (terminal_id, gate_code) DO NOTHING;

-- runway (hasta 10 registros)
WITH a2 AS (
  SELECT airport_id, row_number() OVER (ORDER BY airport_name) AS rn
  FROM sch_airport.airport
)
INSERT INTO sch_airport.runway (airport_id, runway_code, length_meters, surface_type)
SELECT
  a2.airport_id,
  'RW' || lpad(a2.rn::text,2,'0'),
  2500 + (a2.rn * 100),
  CASE WHEN (a2.rn % 2)=0 THEN 'Asphalt' ELSE 'Concrete' END
FROM a2
WHERE a2.rn <= 10
ON CONFLICT (airport_id, runway_code) DO NOTHING;

-- airport_regulation (hasta 10 registros)
WITH a3 AS (
  SELECT airport_id, row_number() OVER (ORDER BY airport_name) AS rn
  FROM sch_airport.airport
)
INSERT INTO sch_airport.airport_regulation (airport_id, regulation_code, regulation_title, issuing_authority, effective_from)
SELECT
  a3.airport_id,
  'AR' || lpad(a3.rn::text,3,'0'),
  'Regulation ' || a3.rn,
  'Authority ' || a3.rn,
  current_date - (a3.rn * INTERVAL '30 day')
FROM a3
WHERE a3.rn <= 10
ON CONFLICT (airport_id, regulation_code) DO NOTHING;

COMMIT;
