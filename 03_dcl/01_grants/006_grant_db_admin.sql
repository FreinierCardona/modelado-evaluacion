
-- CONCEPTO: DATABASE-LEVEL GRANTS
-- A diferencia de los roles anteriores (permisos por schema/tabla), role_db_admin
-- recibe permisos a nivel de base de datos completa.
-- Esto le permite conectarse con cualquier schema, ver objetos del sistema,
-- gestionar conexiones y ejecutar operaciones administrativas.

-- ---------------------------------------------------------------------------------
-- Privilegios de base de datos completa
-- ---------------------------------------------------------------------------------
-- POR QUÉ CONNECT Y TEMPORARY
-- CONNECT: Derecho base para conectarse a la BD (podría estar revocado globalmente).
-- TEMPORARY: Crear tablas temporales para operaciones de mantenimiento/migración.
-- CREATE: Crear nuevos schemas dentro de la base de datos.
-- ---------------------------------------------------------------------------------
GRANT CONNECT, TEMPORARY, CREATE ON DATABASE modelo_bd_evaluacion TO role_db_admin;
-- Nota: Si se despliega en otro entorno, ajuste `modelo_bd_evaluacion` por el nombre correspondiente.

-- ---------------------------------------------------------------------------------
-- ALL sobre todos los schemas (ya cubierto en 01_schema_usage.sql con WITH GRANT OPTION)
-- Aquí se reafirma para claridad del contrato de seguridad.
-- ---------------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_geography TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_airline TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_identity  TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_security TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_customer_and_loyalty TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_airport TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_aircraft TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_flight_operations TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_sales_reservation_and_ticketing TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_boarding TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_payment TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_billing TO role_db_admin WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_geography TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_airline TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_identity TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_security TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_customer_and_loyalty TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_airport TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_aircraft TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_flight_operations TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_sales_reservation_and_ticketing TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_boarding TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_payment TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES  IN SCHEMA sch_billing TO role_db_admin WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_geography TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_airline TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_security TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_customer_and_loyalty TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_flight_operations TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_sales_reservation_and_ticketing TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_boarding TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_payment TO role_db_admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS  IN SCHEMA sch_billing TO role_db_admin WITH GRANT OPTION;

-- WITH GRANT OPTION
-- El DBA puede re-delegar estos permisos. Esto es el mecanismo de administración
-- delegada: el DBA de la BD puede gestionar accesos sin necesitar al superusuario
-- de la instancia de PostgreSQL (que suele ser el equipo de infraestructura).