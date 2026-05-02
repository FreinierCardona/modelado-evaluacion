-- 003_inserts_sch_security.rollback.sql
-- Rollback para inserts en sch_security
BEGIN;

DELETE FROM sch_security.role_permission WHERE security_permission_id IN (
  SELECT security_permission_id FROM sch_security.security_permission WHERE permission_code LIKE 'SP%'
);

DELETE FROM sch_security.user_role WHERE security_role_id IN (
  SELECT security_role_id FROM sch_security.security_role WHERE role_code LIKE 'SR%'
);

DELETE FROM sch_security.user_account WHERE username IN ('user1','user2','user3','user4','user5','user6','user7','user8','user9','user10');

DELETE FROM sch_security.security_permission WHERE permission_code LIKE 'SP%';
DELETE FROM sch_security.security_role WHERE role_code LIKE 'SR%';
DELETE FROM sch_security.user_status WHERE status_code LIKE 'US%';

COMMIT;
