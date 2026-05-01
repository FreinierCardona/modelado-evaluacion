
-- [CONCEPTO: EL PROBLEMA DE LOS OBJETOS FUTUROS]
-- GRANT ON ALL TABLES solo cubre las tablas EXISTENTES al momento de ejecutarse.
-- Si mañana una migración crea la tabla sch_billing.invoice_adjustment, los roles
-- NO tendrán ningún permiso sobre ella hasta que se ejecute otro GRANT explícito.
-- ALTER DEFAULT PRIVILEGES resuelve esto: define los permisos que se aplican
-- AUTOMÁTICAMENTE cada vez que el rol dueño crea un nuevo objeto.
-- RIESGO MITIGADO: Evita "agujeros de permisos" por tablas nuevas sin GRANTs.

-- ----------------------------------------------------------------------------------
-- ¿QUIÉN CREA LOS OBJETOS?
-- Los objetos son creados por el usuario que ejecuta las migraciones (role_db_developer
-- o un usuario con ese rol activo). 
-- ----------------------------------------------------------------------------------
-- DEFAULT PRIVILEGES para role_read_only
-- Cualquier tabla futura en schemas de negocio → SELECT automático
-- ----------------------------------------------------------------------------------
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_geography
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_airline
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_identity
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_customer_and_loyalty
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_airport
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_aircraft
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_flight_operations
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_sales_reservation_and_ticketing
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_boarding
    GRANT SELECT ON TABLES TO role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_billing
    GRANT SELECT ON TABLES TO role_read_only;

-- Secuencias futuras → SELECT para role_read_only
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_sales_reservation_and_ticketing
    GRANT SELECT ON SEQUENCES TO role_read_only;

-- ----------------------------------------------------------------------------------
-- DEFAULT PRIVILEGES para role_data_analyst
-- Tablas futuras en sch_payment → SELECT automático
-- ----------------------------------------------------------------------------------
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_payment
    GRANT SELECT ON TABLES TO role_data_analyst;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_payment
    GRANT SELECT ON SEQUENCES TO role_data_analyst;

-- ----------------------------------------------------------------------------------
-- DEFAULT PRIVILEGES para role_app_service
-- Tablas y secuencias futuras en schemas operativos
-- [IMPORTANTE]: Solo se configura para schemas donde la app tiene DML.
-- Para schemas de solo lectura (sch_geography, sch_aircraft) solo SELECT.
-- ----------------------------------------------------------------------------------

-- Schemas de solo lectura para la app
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_geography
    GRANT SELECT ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_airline
    GRANT SELECT ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_airport
    GRANT SELECT ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_aircraft
    GRANT SELECT ON TABLES TO role_app_service;

-- Schemas operativos con DML para la app
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_identity
    GRANT SELECT, INSERT, UPDATE ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_customer_and_loyalty
    GRANT SELECT, INSERT, UPDATE ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_flight_operations
    GRANT SELECT ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_sales_reservation_and_ticketing
    GRANT SELECT, INSERT, UPDATE ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_boarding
    GRANT SELECT, INSERT, UPDATE ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_payment
    GRANT SELECT, INSERT ON TABLES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_billing
    GRANT SELECT, INSERT, UPDATE ON TABLES TO role_app_service;

-- Secuencias futuras → USAGE, SELECT para role_app_service (necesita nextval para INSERTs)
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_identity
    GRANT USAGE, SELECT ON SEQUENCES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_customer_and_loyalty
    GRANT USAGE, SELECT ON SEQUENCES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_sales_reservation_and_ticketing
    GRANT USAGE, SELECT ON SEQUENCES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_boarding
    GRANT USAGE, SELECT ON SEQUENCES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_payment
    GRANT USAGE, SELECT ON SEQUENCES TO role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_billing
    GRANT USAGE, SELECT ON SEQUENCES TO role_app_service;

-- ----------------------------------------------------------------------------------
-- DEFAULT PRIVILEGES para role_db_admin
-- Todo objeto futuro en cualquier schema → ALL PRIVILEGES
-- ----------------------------------------------------------------------------------
DO $do$
DECLARE
    v_schemas TEXT[] := ARRAY[
        'sch_geography', 'sch_airline', 'sch_identity', 'sch_security',
        'sch_customer_and_loyalty', 'sch_airport', 'sch_aircraft',
        'sch_flight_operations', 'sch_sales_reservation_and_ticketing',
        'sch_boarding', 'sch_payment', 'sch_billing'
    ];
    v_schema TEXT;
BEGIN
    -- Nota: ALTER DEFAULT PRIVILEGES no soporta iteración directa en SQL plano.
    -- Este bloque DO es solo documentativo del patrón a seguir manualmente.
    -- En la práctica se ejecuta una sentencia por schema como las anteriores.
    RAISE NOTICE 'Ejecutar ALTER DEFAULT PRIVILEGES para role_db_admin en cada schema listado.';
END $do$;

-- Patrón a replicar por cada schema:
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_geography
    GRANT ALL ON TABLES TO role_db_admin WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer
    IN SCHEMA sch_payment
    GRANT ALL ON TABLES TO role_db_admin WITH GRANT OPTION;

-- [Y así sucesivamente para cada schema con role_db_admin]

-- ----------------------------------------------------------------------------------
-- VERIFICACIÓN (ejecutar como superusuario para auditar)
-- ----------------------------------------------------------------------------------
-- SELECT grantor, grantee, table_schema, table_name, privilege_type
-- FROM information_schema.role_table_grants
-- WHERE grantee IN ('role_read_only','role_data_analyst','role_app_service',
--                   'role_db_developer','role_db_admin')
-- ORDER BY grantee, table_schema, table_name, privilege_type;