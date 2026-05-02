-- 002_inserts_sch_identity.sql
-- Inserta catálogos y 10 personas con documentos y contactos
BEGIN;

-- person_type (10 registros)
INSERT INTO sch_identity.person_type (type_code, type_name)
SELECT 'PT' || lpad(i::text,2,'0'), 'Person Type ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (type_code) DO NOTHING;

-- document_type (10 registros)
INSERT INTO sch_identity.document_type (type_code, type_name)
SELECT 'DT' || lpad(i::text,2,'0'), 'Document Type ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (type_code) DO NOTHING;

-- contact_type (10 registros)
INSERT INTO sch_identity.contact_type (type_code, type_name)
SELECT 'CT' || lpad(i::text,2,'0'), 'Contact Type ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (type_code) DO NOTHING;

-- person (10 registros) — usa person_type y países existentes
WITH pt AS (
  SELECT person_type_id, row_number() OVER (ORDER BY type_code) AS rn
  FROM sch_identity.person_type
), cn AS (
  SELECT country_id, row_number() OVER (ORDER BY iso_alpha2) AS rn
  FROM sch_geography.country
)
INSERT INTO sch_identity.person (person_type_id, nationality_country_id, first_name, middle_name, last_name, second_last_name, birth_date, gender_code)
SELECT pt.person_type_id, cn.country_id,
       'TestFirst' || pt.rn, NULL, 'TestLast' || pt.rn, NULL,
       (current_date - ((25 + pt.rn) * INTERVAL '1 year'))::date,
       CASE WHEN (pt.rn % 2)=0 THEN 'M' ELSE 'F' END
FROM pt
JOIN cn ON cn.rn = pt.rn
WHERE pt.rn <= 10
ON CONFLICT DO NOTHING;

-- person_document (10 registros) — vincula cada persona con un documento único
WITH p AS (
  SELECT person_id, row_number() OVER (ORDER BY person_id) AS rn
  FROM sch_identity.person
), dt AS (
  SELECT document_type_id, row_number() OVER (ORDER BY type_code) AS rn
  FROM sch_identity.document_type
), cn AS (
  SELECT country_id, row_number() OVER (ORDER BY iso_alpha2) AS rn
  FROM sch_geography.country
)
INSERT INTO sch_identity.person_document (person_id, document_type_id, issuing_country_id, document_number, issued_on, expires_on)
SELECT p.person_id, dt.document_type_id, cn.country_id,
       'DOC-' || lpad(p.rn::text,3,'0'),
       (current_date - ((5 + p.rn) * INTERVAL '1 year'))::date,
       (current_date + ((5 + p.rn) * INTERVAL '1 year'))::date
FROM p
JOIN dt ON dt.rn = p.rn
JOIN cn ON cn.rn = p.rn
WHERE p.rn <= 10
ON CONFLICT (document_type_id, issuing_country_id, document_number) DO NOTHING;

-- person_contact (10 registros) — un contacto por persona
WITH p AS (
  SELECT person_id, row_number() OVER (ORDER BY person_id) AS rn
  FROM sch_identity.person
), ct AS (
  SELECT contact_type_id, row_number() OVER (ORDER BY type_code) AS rn
  FROM sch_identity.contact_type
)
INSERT INTO sch_identity.person_contact (person_id, contact_type_id, contact_value, is_primary)
SELECT p.person_id, ct.contact_type_id, 'person' || p.rn || '@example.com', true
FROM p
JOIN ct ON ct.rn = p.rn
WHERE p.rn <= 10
ON CONFLICT (person_id, contact_type_id, contact_value) DO NOTHING;

COMMIT;
