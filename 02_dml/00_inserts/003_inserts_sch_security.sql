-- 003_inserts_sch_security.sql
-- Inserta catálogos de seguridad y cuentas de usuario de prueba
BEGIN;

-- user_status (10 registros)
INSERT INTO sch_security.user_status (status_code, status_name)
SELECT 'US' || lpad(i::text,2,'0'), 'User Status ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (status_code) DO NOTHING;

-- security_role (10 registros)
INSERT INTO sch_security.security_role (role_code, role_name, role_description)
SELECT 'SR' || lpad(i::text,2,'0'), 'Security Role ' || i, 'Auto-generated role ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (role_code) DO NOTHING;

-- security_permission (10 registros)
INSERT INTO sch_security.security_permission (permission_code, permission_name, permission_description)
SELECT 'SP' || lpad(i::text,2,'0'), 'Security Permission ' || i, 'Permission generated ' || i
FROM generate_series(1,10) AS s(i)
ON CONFLICT (permission_code) DO NOTHING;

-- user_account (10 registros) — una cuenta por persona existente
WITH p AS (
  SELECT person_id, row_number() OVER (ORDER BY person_id) AS rn
  FROM sch_identity.person
), us AS (
  SELECT user_status_id, row_number() OVER (ORDER BY status_code) AS rn
  FROM sch_security.user_status
)
INSERT INTO sch_security.user_account (person_id, user_status_id, username, password_hash)
SELECT p.person_id, us.user_status_id, 'user' || p.rn, 'testhash' || p.rn
FROM p
JOIN us ON us.rn = p.rn
WHERE p.rn <= 10
ON CONFLICT (person_id) DO NOTHING;

-- user_role (10 registros) — asigna roles a cuentas
WITH ua AS (
  SELECT user_account_id, row_number() OVER (ORDER BY user_account_id) AS rn
  FROM sch_security.user_account
), sr AS (
  SELECT security_role_id, row_number() OVER (ORDER BY role_code) AS rn
  FROM sch_security.security_role
)
INSERT INTO sch_security.user_role (user_account_id, security_role_id, assigned_at, assigned_by_user_id)
SELECT ua.user_account_id, sr.security_role_id, now() - (ua.rn * INTERVAL '1 day'), NULL
FROM ua
JOIN sr ON sr.rn = ua.rn
WHERE ua.rn <= 10
ON CONFLICT (user_account_id, security_role_id) DO NOTHING;

-- role_permission (10 registros) — asocia permisos a roles
WITH sr AS (
  SELECT security_role_id, row_number() OVER (ORDER BY role_code) AS rn
  FROM sch_security.security_role
), sp AS (
  SELECT security_permission_id, row_number() OVER (ORDER BY permission_code) AS rn
  FROM sch_security.security_permission
)
INSERT INTO sch_security.role_permission (security_role_id, security_permission_id, granted_at)
SELECT sr.security_role_id, sp.security_permission_id, now() - (sr.rn * INTERVAL '1 hour')
FROM sr
JOIN sp ON sp.rn = sr.rn
WHERE sr.rn <= 10
ON CONFLICT (security_role_id, security_permission_id) DO NOTHING;

COMMIT;
