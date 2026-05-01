
-- CONCEPTO: HERENCIA DE ROLES EN POSTGRESQL
-- Dado que ejecutamos GRANT role_read_only TO role_data_analyst en 01_create_roles.sql,
-- role_data_analyst hereda automáticamente todos los GRANTs de role_read_only
-- (excepto WITH GRANT OPTION, que no se propaga por herencia).
-- Este archivo solo necesita cubrir los permisos NUEVOS del analista.

-- --------------------------------------------------------------------------------
-- sch_payment — Acceso de lectura para análisis financiero
-- POR QUÉ EL ANALISTA LO NECESITA
-- Para calcular ingresos, tasas de conversión de pagos, análisis de reembolsos
-- y métricas financieras, el analista necesita ver payment y payment_transaction.
-- NO necesita payment_method ni payment_status en detalle (son catálogos en
-- role_read_only ya los tiene desde sch_payment directamente).
-- --------------------------------------------------------------------------------

-- Tablas transaccionales de pago (análisis de flujo de dinero)
GRANT SELECT ON sch_payment.payment             TO role_data_analyst;
GRANT SELECT ON sch_payment.payment_transaction TO role_data_analyst;
GRANT SELECT ON sch_payment.refund              TO role_data_analyst;

-- Catálogos de pago (necesarios para joins en queries analíticos)
GRANT SELECT ON sch_payment.payment_status  TO role_data_analyst;
GRANT SELECT ON sch_payment.payment_method  TO role_data_analyst;

-- Secuencias (para análisis de gaps en IDs, auditoría de volumen de transacciones)
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_payment TO role_data_analyst;

