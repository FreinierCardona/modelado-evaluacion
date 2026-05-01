
-- USAGE EN SCHEMA
-- En PostgreSQL, USAGE sobre un schema es una condición necesaria pero NO
-- suficiente para acceder a sus objetos. Es una "llave de puerta", sin ella,
-- el rol ni siquiera puede "ver" que las tablas existen dentro del schema.
-- Esto es diferente del modelo de MySQL donde los permisos son solo sobre tablas.
-- Siempre se debe conceder USAGE en schema + permiso específico sobre el objeto.
--
-- RIESGO MITIGADO: Permite un aislamiento granular por dominio de negocio.
-- Un rol que procesa pagos no necesita "entrar" al schema de aircraft.

-- --------------------------------------------------------------------------------
-- PASO PREVIO CRÍTICO
-- Revocar el permiso por defecto de PUBLIC sobre todos los schemas.
-- Por defecto PostgreSQL permite que cualquier rol autenticado tenga USAGE
-- en el schema public. En un entorno multischema esto debe eliminarse
-- explícitamente para que los GRANTs siguientes tengan efecto real.
-- --------------------------------------------------------------------------------

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_geography FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_airline FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_identity FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_security FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_customer_and_loyalty FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_airport FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_aircraft FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_flight_operations FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_sales_reservation_and_ticketing FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_boarding FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_payment FROM PUBLIC;
REVOKE ALL ON SCHEMA sch_billing FROM PUBLIC;

-- --------------------------------------------------------------------------------
-- ROLE: role_read_only — Acceso a todos los schemas de negocio, EXCEPTO sch_security
-- --------------------------------------------------------------------------------

-- POR QUÉ EXCLUIR sch_security
-- La tabla user_account contiene password_hash. Aunque role_read_only solo
-- tendría SELECT, exponer hashes a roles de auditoría viola el principio de
-- "datos sensibles solo a quien los necesita operativamente".
-- Un auditor puede verificar conteos y estados sin leer los hashes.
-- --------------------------------------------------------------------------------

GRANT USAGE ON SCHEMA sch_geography TO role_read_only;
GRANT USAGE ON SCHEMA sch_airline TO role_read_only;
GRANT USAGE ON SCHEMA sch_identity TO role_read_only;
GRANT USAGE ON SCHEMA sch_customer_and_loyalty TO role_read_only;
GRANT USAGE ON SCHEMA sch_airport TO role_read_only;
GRANT USAGE ON SCHEMA sch_aircraft TO role_read_only;
GRANT USAGE ON SCHEMA sch_flight_operations TO role_read_only;
GRANT USAGE ON SCHEMA sch_sales_reservation_and_ticketing TO role_read_only;
GRANT USAGE ON SCHEMA sch_boarding TO role_read_only;
-- sch_billing: SÍ (puede ver facturas, no montos de pago procesado)
GRANT USAGE ON SCHEMA sch_billing TO role_read_only;
-- sch_payment: NO para role_read_only base (datos PCI-DSS). Solo para roles con necesidad específica.
-- sch_security: NO (contiene password_hash en user_account).

-- --------------------------------------------------------------------------------
-- ROLE: role_data_analyst — Mismos schemas que read_only + sch_payment (agregado)
-- --------------------------------------------------------------------------------
-- POR QUÉ EL ANALISTA ACCEDE A sch_billing PERO NO A sch_payment
-- El analista necesita datos de facturación para reportes de ingresos (invoice, invoice_line).
-- Los detalles de transacciones de pago (número de tarjeta cifrado, referencias de
-- gateway) son PCI-DSS y no son necesarios para análisis de negocio.
-- role_data_analyst hereda role_read_only, por lo que ya tiene USAGE
-- en los schemas anteriores. Solo se necesita agregar los nuevos.
-- --------------------------------------------------------------------------------

GRANT USAGE ON SCHEMA sch_payment TO role_data_analyst;
-- sch_security sigue excluido incluso para el analista.

-- --------------------------------------------------------------------------------

-- ROLE: role_app_service — Todos los schemas operativos necesarios para el flujo de negocio
-- --------------------------------------------------------------------------------

-- PRINCIPIO DE MENOR PRIVILEGIO APLICADO
-- Se otorga USAGE solo a schemas donde la aplicación tiene operaciones legítimas.
-- La aplicación NO necesita entrar a sch_aircraft para reservar un vuelo:
-- la relación flight → aircraft es transparente a nivel de datos de reserva.
-- --------------------------------------------------------------------------------

GRANT USAGE ON SCHEMA sch_geography TO role_app_service;
GRANT USAGE ON SCHEMA sch_airline TO role_app_service;
GRANT USAGE ON SCHEMA sch_identity TO role_app_service;
-- sch_security: acceso MUY limitado (solo lectura de catálogos, no a credenciales)
GRANT USAGE ON SCHEMA sch_security TO role_app_service;
GRANT USAGE ON SCHEMA sch_customer_and_loyalty TO role_app_service;
GRANT USAGE ON SCHEMA sch_airport TO role_app_service;
GRANT USAGE ON SCHEMA sch_aircraft TO role_app_service;
GRANT USAGE ON SCHEMA sch_flight_operations TO role_app_service;
GRANT USAGE ON SCHEMA sch_sales_reservation_and_ticketing TO role_app_service;
GRANT USAGE ON SCHEMA sch_boarding TO role_app_service;
GRANT USAGE ON SCHEMA sch_payment TO role_app_service;
GRANT USAGE ON SCHEMA sch_billing TO role_app_service;

-- --------------------------------------------------------------------------------
-- ROLE: role_db_developer — Acceso a todos los schemas (necesita DDL para migraciones)
-- --------------------------------------------------------------------------------

-- POR QUÉ EL DEVELOPER NECESITA TODOS LOS SCHEMAS
-- Las migraciones pueden tocar cualquier schema (agregar columnas, índices, FKs
-- entre schemas). Sin embargo, CREATE/ALTER de objetos ≠ SELECT en datos reales.
-- Los GRANTs de datos en 05_grant_db_developer.sql serán restrictivos.
-- --------------------------------------------------------------------------------

GRANT USAGE ON SCHEMA sch_geography TO role_db_developer;
GRANT USAGE ON SCHEMA sch_airline TO role_db_developer;
GRANT USAGE ON SCHEMA sch_identity TO role_db_developer;
GRANT USAGE ON SCHEMA sch_security TO role_db_developer;
GRANT USAGE ON SCHEMA sch_customer_and_loyalty TO role_db_developer;
GRANT USAGE ON SCHEMA sch_airport TO role_db_developer;
GRANT USAGE ON SCHEMA sch_aircraft TO role_db_developer;
GRANT USAGE ON SCHEMA sch_flight_operations TO role_db_developer;
GRANT USAGE ON SCHEMA sch_sales_reservation_and_ticketing  TO role_db_developer;
GRANT USAGE ON SCHEMA sch_boarding TO role_db_developer;
GRANT USAGE ON SCHEMA sch_billing TO role_db_developer;
-- sch_payment: NO en producción para el developer (datos PCI-DSS sensibles)
-- --------------------------------------------------------------------------------

-- ROLE: role_db_admin — Acceso total a todos los schemas
-- --------------------------------------------------------------------------------

GRANT ALL ON SCHEMA sch_geography TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_airline TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_identity TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_security TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_customer_and_loyalty TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_airport TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_aircraft TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_flight_operations TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_sales_reservation_and_ticketing  TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_boarding TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_payment TO role_db_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA sch_billing TO role_db_admin WITH GRANT OPTION;

-- [WITH GRANT OPTION]
-- Permite a role_db_admin re-delegar permisos a otros roles sin necesitar
-- intervención del superusuario de instancia. Esto es el modelo de administración
-- delegada: el DBA de la base controla su propio espacio de permisos.