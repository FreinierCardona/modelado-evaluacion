
-- CONCEPTO: ROW LEVEL SECURITY (RLS)
-- RLS permite definir predicados adicionales (filtros WHERE invisibles) que se
-- aplican automáticamente en cada query sobre la tabla, según el rol que lo ejecuta.
-- Es la diferencia entre "quién puede acceder a la tabla" (GRANTs) y
-- "qué filas puede ver" (RLS policies).
--
-- Ejemplo sin RLS: SELECT * FROM customer  → devuelve TODOS los clientes
-- Ejemplo con RLS: SELECT * FROM customer  → devuelve SOLO el cliente autenticado
--
-- MECANISMO DE IDENTIFICACIÓN DE SESIÓN
-- Se usa un parámetro de sesión: app.current_customer_id
-- La aplicación lo establece al inicio de cada sesión de usuario:
--   SET LOCAL app.current_customer_id = '550e8400-e29b-41d4-a716-446655440000';
-- Las políticas RLS usan current_setting() para leerlo.
--
-- RIESGO MITIGADO
-- Sin RLS, un bug de autorización en la capa de aplicación (IDOR — Insecure Direct
-- Object Reference) expondría datos de todos los clientes. RLS agrega una capa
-- de defensa en profundidad directamente en la base de datos.

-- ------------------------------------------------------------------------------------
-- TABLA: sch_customer_and_loyalty.customer
-- ------------------------------------------------------------------------------------

-- Paso 1: Habilitar RLS en la tabla (por defecto está deshabilitado)
-- Una vez habilitado, NINGUNA fila es visible hasta que una política lo permite.
-- EXCEPCIÓN: Los dueños de la tabla y roles con BYPASSRLS siempre lo evitan.
ALTER TABLE sch_customer_and_loyalty.customer ENABLE ROW LEVEL SECURITY;

-- Paso 2: Forzar RLS incluso para el dueño de la tabla
-- Sin FORCE, el usuario que creó la tabla la ve completa. En producción,
-- la cuenta de servicio no debe ver datos de otros clientes ni siquiera como owner.
ALTER TABLE sch_customer_and_loyalty.customer FORCE ROW LEVEL SECURITY;

-- Política para role_app_service:
-- La app puede ver/modificar solo el cliente cuyo ID está en la sesión.
-- PERMISSIVE vs RESTRICTIVE:
--   PERMISSIVE (default): las políticas se combinan con OR. Basta que una permita.
--   RESTRICTIVE: las políticas se combinan con AND. Todas deben permitir.
-- Se usa PERMISSIVE aquí porque habrá diferentes políticas para diferentes roles.
CREATE POLICY pol_customer_app_service
    ON sch_customer_and_loyalty.customer
    AS PERMISSIVE
    FOR ALL
    TO role_app_service
    USING (
        -- La fila es visible si su customer_id coincide con el de la sesión actual
        customer_id = current_setting('app.current_customer_id', true)::uuid
    )
    WITH CHECK (
        -- Solo se pueden insertar/actualizar filas del propio cliente
        customer_id = current_setting('app.current_customer_id', true)::uuid
    );

-- Política para role_read_only y role_data_analyst: acceso total (auditoría)
-- POR QUÉ PERMITIR TODO A AUDITORES
-- Los auditores necesitan ver todos los registros para análisis transversal.
-- Su restricción es de TIPO (solo SELECT), no de FILAS.
-- true = la condición siempre se cumple → todas las filas son visibles.
CREATE POLICY pol_customer_audit_roles
    ON sch_customer_and_loyalty.customer
    AS PERMISSIVE
    FOR SELECT
    TO role_read_only, role_data_analyst
    USING (true);

-- Política para role_db_admin: acceso irrestricto
CREATE POLICY pol_customer_admin
    ON sch_customer_and_loyalty.customer
    AS PERMISSIVE
    FOR ALL
    TO role_db_admin
    USING (true)
    WITH CHECK (true);

-- ------------------------------------------------------------------------------------
-- TABLA: sch_customer_and_loyalty.loyalty_account
-- ------------------------------------------------------------------------------------
ALTER TABLE sch_customer_and_loyalty.loyalty_account ENABLE ROW LEVEL SECURITY;
ALTER TABLE sch_customer_and_loyalty.loyalty_account FORCE ROW LEVEL SECURITY;

-- La app solo puede acceder a la loyalty_account del cliente en sesión.
-- Para esto, el parámetro de sesión es el mismo customer_id.
CREATE POLICY pol_loyalty_account_app_service
    ON sch_customer_and_loyalty.loyalty_account
    AS PERMISSIVE
    FOR ALL
    TO role_app_service
    USING (
        customer_id = current_setting('app.current_customer_id', true)::uuid
    )
    WITH CHECK (
        customer_id = current_setting('app.current_customer_id', true)::uuid
    );

CREATE POLICY pol_loyalty_account_audit
    ON sch_customer_and_loyalty.loyalty_account
    AS PERMISSIVE
    FOR SELECT
    TO role_read_only, role_data_analyst
    USING (true);

CREATE POLICY pol_loyalty_account_admin
    ON sch_customer_and_loyalty.loyalty_account
    AS PERMISSIVE
    FOR ALL
    TO role_db_admin
    USING (true)
    WITH CHECK (true);

-- ------------------------------------------------------------------------------------
-- TABLA: sch_customer_and_loyalty.miles_transaction
-- ------------------------------------------------------------------------------------
ALTER TABLE sch_customer_and_loyalty.miles_transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE sch_customer_and_loyalty.miles_transaction FORCE ROW LEVEL SECURITY;

-- SUBQUERY EN POLÍTICA RLS
-- La tabla miles_transaction no tiene customer_id directamente: lo hereda vía
-- loyalty_account. Se usa una subquery correlacionada para verificar la pertenencia.
-- CONSIDERACIÓN DE RENDIMIENTO: Esta subquery se ejecuta por cada fila evaluada.
-- Es fundamental que loyalty_account_id esté indexado (ya está en el modelo).
CREATE POLICY pol_miles_transaction_app_service
    ON sch_customer_and_loyalty.miles_transaction
    AS PERMISSIVE
    FOR ALL
    TO role_app_service
    USING (
        loyalty_account_id IN (
            SELECT loyalty_account_id
            FROM sch_customer_and_loyalty.loyalty_account
            WHERE customer_id = current_setting('app.current_customer_id', true)::uuid
        )
    )
    WITH CHECK (
        loyalty_account_id IN (
            SELECT loyalty_account_id
            FROM sch_customer_and_loyalty.loyalty_account
            WHERE customer_id = current_setting('app.current_customer_id', true)::uuid
        )
    );

CREATE POLICY pol_miles_transaction_audit
    ON sch_customer_and_loyalty.miles_transaction
    AS PERMISSIVE
    FOR SELECT
    TO role_read_only, role_data_analyst
    USING (true);

CREATE POLICY pol_miles_transaction_admin
    ON sch_customer_and_loyalty.miles_transaction
    AS PERMISSIVE
    FOR ALL
    TO role_db_admin
    USING (true)
    WITH CHECK (true);

-- ------------------------------------------------------------------------------------
-- TABLA: sch_customer_and_loyalty.loyalty_account_tier
-- ------------------------------------------------------------------------------------
ALTER TABLE sch_customer_and_loyalty.loyalty_account_tier ENABLE ROW LEVEL SECURITY;
ALTER TABLE sch_customer_and_loyalty.loyalty_account_tier FORCE ROW LEVEL SECURITY;

CREATE POLICY pol_loyalty_tier_app_service
    ON sch_customer_and_loyalty.loyalty_account_tier
    AS PERMISSIVE
    FOR ALL
    TO role_app_service
    USING (
        loyalty_account_id IN (
            SELECT loyalty_account_id
            FROM sch_customer_and_loyalty.loyalty_account
            WHERE customer_id = current_setting('app.current_customer_id', true)::uuid
        )
    )
    WITH CHECK (
        loyalty_account_id IN (
            SELECT loyalty_account_id
            FROM sch_customer_and_loyalty.loyalty_account
            WHERE customer_id = current_setting('app.current_customer_id', true)::uuid
        )
    );

CREATE POLICY pol_loyalty_tier_audit
    ON sch_customer_and_loyalty.loyalty_account_tier
    AS PERMISSIVE
    FOR SELECT
    TO role_read_only, role_data_analyst
    USING (true);

CREATE POLICY pol_loyalty_tier_admin
    ON sch_customer_and_loyalty.loyalty_account_tier
    AS PERMISSIVE
    FOR ALL
    TO role_db_admin
    USING (true)
    WITH CHECK (true);

-- ------------------------------------------------------------------------------------
-- USO EN LA APLICACIÓN
-- Al inicio de cada request autenticado, la app debe establecer el contexto:
-- ------------------------------------------------------------------------------------
--
-- -- Ejemplo en transaction de aplicación (pseudocódigo SQL):
-- BEGIN;
--   -- Establecer el customer en contexto para que RLS filtre correctamente.
--   -- SET LOCAL tiene scope solo dentro de la transacción actual.
--   SET LOCAL app.current_customer_id = '550e8400-e29b-41d4-a716-446655440000';
--
--   -- Ahora todas las queries sobre tablas con RLS solo ven datos de ese customer.
--   SELECT * FROM sch_customer_and_loyalty.customer;              -- 1 fila
--   SELECT * FROM sch_customer_and_loyalty.loyalty_account;       -- N cuentas del cliente
--   SELECT * FROM sch_customer_and_loyalty.miles_transaction;     -- Solo sus millas
-- COMMIT;
-- -- Al finalizar la transacción, SET LOCAL se revierte automáticamente.
-- ------------------------------------------------------------------------------------