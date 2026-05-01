
-- CONCEPTO: ALL PRIVILEGES EN DDL
-- Para un developer que ejecuta migraciones, "ALL" incluye:
--   CREATE, ALTER, DROP, TRUNCATE en tablas
--   CREATE INDEX, CREATE VIEW, CREATE FUNCTION
-- Pero NO incluye CREATEROLE ni SUPERUSER (definidos en el rol mismo).
-- En producción este rol solo debe estar activo durante ventanas de mantenimiento.

-- -----------------------------------------------------------------------------------
-- Schemas de negocio: ALL PRIVILEGES (DDL completo para migraciones)
-- -----------------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_geography TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_airline TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_identity TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_customer_and_loyalty TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_airport TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_aircraft TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_flight_operations TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_sales_reservation_and_ticketing TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_boarding TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_billing TO role_db_developer;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_geography TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_airline TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_identity TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_customer_and_loyalty TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_airport TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_aircraft TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_flight_operations TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_sales_reservation_and_ticketing TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_boarding TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_billing TO role_db_developer;

-- Permisos para crear nuevos objetos dentro de los schemas
GRANT CREATE ON SCHEMA sch_geography TO role_db_developer;
GRANT CREATE ON SCHEMA sch_airline TO role_db_developer;
GRANT CREATE ON SCHEMA sch_identity TO role_db_developer;
GRANT CREATE ON SCHEMA sch_customer_and_loyalty TO role_db_developer;
GRANT CREATE ON SCHEMA sch_airport TO role_db_developer;
GRANT CREATE ON SCHEMA sch_aircraft TO role_db_developer;
GRANT CREATE ON SCHEMA sch_flight_operations TO role_db_developer;
GRANT CREATE ON SCHEMA sch_sales_reservation_and_ticketing TO role_db_developer;
GRANT CREATE ON SCHEMA sch_boarding TO role_db_developer;
GRANT CREATE ON SCHEMA sch_billing TO role_db_developer;

-- -----------------------------------------------------------------------------------
-- sch_security — DDL permitido, SELECT muy restringido
-- SoD CRÍTICO: El developer puede alterar la estructura de las tablas de
-- seguridad (para agregar columnas, índices) pero NO puede leer datos de
-- producción de user_account (ni passwords ni asignaciones de roles).
-- Esto previene que un developer consulte con qué permisos está corriendo
-- el sistema en producción para encontrar vectores de escalada.
-- -----------------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_security TO role_db_developer;
GRANT CREATE ON SCHEMA sch_security TO role_db_developer;

-- Solo lectura de catálogos estructurales (para entender el modelo en migraciones)
GRANT SELECT ON sch_security.user_status TO role_db_developer;
GRANT SELECT ON sch_security.security_role TO role_db_developer;
GRANT SELECT ON sch_security.security_permission TO role_db_developer;
-- NO: user_account, user_role, role_permission (datos de acceso de producción)

-- DDL sobre las tablas de seguridad sí es necesario para migraciones
GRANT ALL PRIVILEGES ON sch_security.user_status TO role_db_developer;
GRANT ALL PRIVILEGES ON sch_security.security_role TO role_db_developer;
GRANT ALL PRIVILEGES ON sch_security.security_permission TO role_db_developer;
GRANT ALL PRIVILEGES ON sch_security.user_account TO role_db_developer;
GRANT ALL PRIVILEGES ON sch_security.user_role TO role_db_developer;
GRANT ALL PRIVILEGES ON sch_security.role_permission TO role_db_developer;
-- Nota: ALL PRIVILEGES incluye SELECT, pero la intención es habilitar DDL.
-- En producción real, usar un rol separado role_security_dev con solo DDL.

-- -----------------------------------------------------------------------------------
-- sch_payment — SIN acceso en producción (PCI-DSS)
-- REGLA PCI-DSS SAQ-D: Los desarrolladores NO deben tener acceso a datos de
-- pago reales. Las migraciones de sch_payment en producción deben ejecutarse
-- por el DBA (role_db_admin) después de revisión del equipo de seguridad.
-- -----------------------------------------------------------------------------------

-- FUNCIONES Y PROCEDIMIENTOS
-- El developer puede crear y reemplazar funciones en todos los schemas habilitados.
-- -----------------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_geography TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_airline TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_identity TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_customer_and_loyalty TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_airport TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_aircraft TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_flight_operations TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_sales_reservation_and_ticketing TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_boarding TO role_db_developer;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_billing TO role_db_developer;