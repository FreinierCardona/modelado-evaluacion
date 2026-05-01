-- Revocar membresías explícitas creadas
REVOKE role_read_only FROM role_data_analyst;

-- Eliminar roles (si existen). El orden evita conflictos por dependencia
DROP ROLE IF EXISTS role_data_analyst;
DROP ROLE IF EXISTS role_app_service;
DROP ROLE IF EXISTS role_db_developer;
DROP ROLE IF EXISTS role_read_only;
DROP ROLE IF EXISTS role_db_admin;


