
-- ROL 1 — role_db_admin  (Administrador de Base de Datos)
CREATE ROLE role_db_admin
    NOLOGIN
    NOINHERIT
    CREATEROLE
    CREATEDB;

COMMENT ON ROLE role_db_admin IS
    'DBA de la BD de aerolínea. Control total DDL + gestión de roles. '
    'Sin SUPERUSER para limitar acceso a nivel de instancia y sistema operativo.';


-- ROL 2 — role_read_only  (Solo Lectura)
CREATE ROLE role_read_only
    NOLOGIN
    NOINHERIT;

COMMENT ON ROLE role_read_only IS
    'Lectura de todos los esquemas de negocio. Excluye sch_security (password_hash). '
    'Uso: auditoría interna, soporte N1, dashboards de monitoreo operativo.';


-- ROL 3 — role_data_analyst  (Analista de Datos / BI)
CREATE ROLE role_data_analyst
    NOLOGIN
    NOINHERIT;

GRANT role_read_only TO role_data_analyst;

COMMENT ON ROLE role_data_analyst IS
    'Analista BI. Hereda role_read_only. Acceso adicional a funciones analíticas. '
    'Sin escritura operativa. Sin acceso a sch_security ni detalles de pago PCI.';


-- ROL 4 — role_app_service  (Cuenta de Servicio de la Aplicación)
CREATE ROLE role_app_service
    NOLOGIN
    NOINHERIT;

COMMENT ON ROLE role_app_service IS
    'Cuenta de servicio del backend (API/microservicios). DML sobre esquemas '
    'operativos. Sin DDL, sin DROP/TRUNCATE, sin acceso a password_hash. '
    'Respetar RLS habilitado (BYPASSRLS=false implícito).';


-- ROL 5 — role_db_developer  (Desarrollador de Base de Datos)
CREATE ROLE role_db_developer
    NOLOGIN
    NOINHERIT;

COMMENT ON ROLE role_db_developer IS
    'Desarrollador BD. DDL sobre esquemas de negocio para migraciones CI/CD. '
    'Sin CREATEROLE (SoD crítico). Sin acceso a sch_payment en producción. '
    'Activar solo en ventanas de mantenimiento controladas.';


-- RESUMEN DE JERARQUÍA

--
--   role_db_admin          → Control total DDL + roles (sin SUPERUSER de instancia)
--       │
--   role_db_developer      → DDL de esquemas de negocio (sin gestión de roles)
--       │
--   role_app_service       → DML operativo (INSERT/UPDATE en flujo de negocio)
--       │
--   role_data_analyst      → SELECT extendido + funciones analíticas
--       │   (hereda)
--   role_read_only         → SELECT en esquemas de negocio (base de jerarquía)
--
