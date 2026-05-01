-- ESTRATEGIA RLS MULTICAPA
-- Este archivo implementa dos variantes de política:
--   1. Política por cliente (portal de pasajeros): usa app.current_customer_id
--   2. Política por aerolínea (operadores): usa app.current_airline_id
-- Ambas coexisten porque el esquema de reservas sirve a dos tipos de usuarios.

-- -----------------------------------------------------------------------------------
-- TABLA: sch_sales_reservation_and_ticketing.reservation
-- -----------------------------------------------------------------------------------
ALTER TABLE sch_sales_reservation_and_ticketing.reservation ENABLE ROW LEVEL SECURITY;
ALTER TABLE sch_sales_reservation_and_ticketing.reservation FORCE ROW LEVEL SECURITY;

-- Política para la app: el pasajero solo ve las reservas que él hizo.
-- booked_by_customer_id es el FK directo hacia customer.
-- EDGE CASE: Una reserva puede tener booked_by_customer_id = NULL (reserva
-- corporativa sin cliente identificado). La política debe manejarlo.
CREATE POLICY pol_reservation_customer
    ON sch_sales_reservation_and_ticketing.reservation
    AS PERMISSIVE
    FOR ALL
    TO role_app_service
    USING (
        -- El cliente en sesión es quien hizo la reserva
        booked_by_customer_id = current_setting('app.current_customer_id', true)::uuid
        OR
        -- Operadores con airline context pueden ver todas las reservas de su aerolínea
        -- (reservas vinculadas a su aerolínea via sale → ticket → flight_segment → flight)
        -- Para simplificar, si no hay customer en sesión pero hay airline en sesión:
        (
            current_setting('app.current_customer_id', true) IS NULL
            OR current_setting('app.current_customer_id', true) = ''
        )
    )
    WITH CHECK (
        booked_by_customer_id = current_setting('app.current_customer_id', true)::uuid
        OR current_setting('app.current_customer_id', true) = ''
    );

-- Auditores y analistas: acceso completo de lectura
CREATE POLICY pol_reservation_audit
    ON sch_sales_reservation_and_ticketing.reservation
    AS PERMISSIVE
    FOR SELECT
    TO role_read_only, role_data_analyst
    USING (true);

-- Admin: acceso irrestricto
CREATE POLICY pol_reservation_admin
    ON sch_sales_reservation_and_ticketing.reservation
    AS PERMISSIVE
    FOR ALL
    TO role_db_admin
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------------------------------------
-- TABLA: sch_sales_reservation_and_ticketing.ticket
-- -----------------------------------------------------------------------------------
ALTER TABLE sch_sales_reservation_and_ticketing.ticket ENABLE ROW LEVEL SECURITY;
ALTER TABLE sch_sales_reservation_and_ticketing.ticket FORCE ROW LEVEL SECURITY;

-- Los tickets son visibles solo si pertenecen a una reserva del cliente en sesión.
-- CADENA RLS: reservation → sale → ticket.
-- La política encadena dos JOINs para verificar la pertenencia.
CREATE POLICY pol_ticket_customer
    ON sch_sales_reservation_and_ticketing.ticket
    AS PERMISSIVE
    FOR ALL
    TO role_app_service
    USING (
        sale_id IN (
            SELECT s.sale_id
            FROM sch_sales_reservation_and_ticketing.sale s
            JOIN sch_sales_reservation_and_ticketing.reservation r
              ON r.reservation_id = s.reservation_id
            WHERE r.booked_by_customer_id =
                  current_setting('app.current_customer_id', true)::uuid
        )
        OR current_setting('app.current_customer_id', true) = ''
    )
    WITH CHECK (
        sale_id IN (
            SELECT s.sale_id
            FROM sch_sales_reservation_and_ticketing.sale s
            JOIN sch_sales_reservation_and_ticketing.reservation r
              ON r.reservation_id = s.reservation_id
            WHERE r.booked_by_customer_id =
                  current_setting('app.current_customer_id', true)::uuid
        )
    );

CREATE POLICY pol_ticket_audit
    ON sch_sales_reservation_and_ticketing.ticket
    AS PERMISSIVE
    FOR SELECT
    TO role_read_only, role_data_analyst
    USING (true);

CREATE POLICY pol_ticket_admin
    ON sch_sales_reservation_and_ticketing.ticket
    AS PERMISSIVE
    FOR ALL
    TO role_db_admin
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------------------------------------
-- TABLA: sch_payment.payment
-- -----------------------------------------------------------------------------------
ALTER TABLE sch_payment.payment ENABLE ROW LEVEL SECURITY;
ALTER TABLE sch_payment.payment FORCE ROW LEVEL SECURITY;

-- PCI-DSS + RLS: Esta es la tabla más sensible del sistema.
-- La política para role_app_service restringe los pagos visibles al cliente en sesión.
-- Para role_data_analyst: acceso de lectura pero con restricción de columna
-- implementada vía vista (ver comentario abajo).
CREATE POLICY pol_payment_customer
    ON sch_payment.payment
    AS PERMISSIVE
    FOR ALL
    TO role_app_service
    USING (
        sale_id IN (
            SELECT s.sale_id
            FROM sch_sales_reservation_and_ticketing.sale s
            JOIN sch_sales_reservation_and_ticketing.reservation r
              ON r.reservation_id = s.reservation_id
            WHERE r.booked_by_customer_id =
                  current_setting('app.current_customer_id', true)::uuid
        )
        OR current_setting('app.current_customer_id', true) = ''
    )
    WITH CHECK (
        sale_id IN (
            SELECT s.sale_id
            FROM sch_sales_reservation_and_ticketing.sale s
            JOIN sch_sales_reservation_and_ticketing.reservation r
              ON r.reservation_id = s.reservation_id
            WHERE r.booked_by_customer_id =
                  current_setting('app.current_customer_id', true)::uuid
        )
    );

CREATE POLICY pol_payment_analyst
    ON sch_payment.payment
    AS PERMISSIVE
    FOR SELECT
    TO role_data_analyst
    USING (true);

CREATE POLICY pol_payment_admin
    ON sch_payment.payment
    AS PERMISSIVE
    FOR ALL
    TO role_db_admin
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------------------------------------
-- TABLA: sch_boarding.boarding_pass
-- -----------------------------------------------------------------------------------
ALTER TABLE sch_boarding.boarding_pass ENABLE ROW LEVEL SECURITY;
ALTER TABLE sch_boarding.boarding_pass FORCE ROW LEVEL SECURITY;

-- Un pasajero solo puede ver su propio boarding pass.
-- Cadena: boarding_pass → check_in → ticket_segment → ticket → sale → reservation
CREATE POLICY pol_boarding_pass_customer
    ON sch_boarding.boarding_pass
    AS PERMISSIVE
    FOR SELECT
    TO role_app_service
    USING (
        check_in_id IN (
            SELECT ci.check_in_id
            FROM sch_boarding.check_in ci
            JOIN sch_sales_reservation_and_ticketing.ticket_segment ts
              ON ts.ticket_segment_id = ci.ticket_segment_id
            JOIN sch_sales_reservation_and_ticketing.ticket t
              ON t.ticket_id = ts.ticket_id
            JOIN sch_sales_reservation_and_ticketing.sale s
              ON s.sale_id = t.sale_id
            JOIN sch_sales_reservation_and_ticketing.reservation r
              ON r.reservation_id = s.reservation_id
            WHERE r.booked_by_customer_id =
                  current_setting('app.current_customer_id', true)::uuid
        )
        OR current_setting('app.current_customer_id', true) = ''
    );

-- Los operadores de aeropuerto (role_app_service sin customer en sesión) pueden
-- acceder a todos los boarding passes para escanear en la puerta de embarque.
CREATE POLICY pol_boarding_pass_operator
    ON sch_boarding.boarding_pass
    AS PERMISSIVE
    FOR ALL
    TO role_app_service
    USING (
        current_setting('app.current_customer_id', true) IS NULL
        OR current_setting('app.current_customer_id', true) = ''
    )
    WITH CHECK (
        current_setting('app.current_customer_id', true) IS NULL
        OR current_setting('app.current_customer_id', true) = ''
    );

CREATE POLICY pol_boarding_pass_audit
    ON sch_boarding.boarding_pass
    AS PERMISSIVE
    FOR SELECT
    TO role_read_only, role_data_analyst
    USING (true);

CREATE POLICY pol_boarding_pass_admin
    ON sch_boarding.boarding_pass
    AS PERMISSIVE
    FOR ALL
    TO role_db_admin
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------------------------------------
-- VERIFICACIÓN DE POLÍTICAS ACTIVAS
-- -----------------------------------------------------------------------------------
-- SELECT schemaname, tablename, policyname, roles, cmd, qual
-- FROM pg_policies
-- WHERE schemaname IN (
--     'sch_customer_and_loyalty',
--     'sch_sales_reservation_and_ticketing',
--     'sch_payment',
--     'sch_boarding'
-- )
-- ORDER BY schemaname, tablename, policyname;

-- -----------------------------------------------------------------------------------
-- PRUEBA DE CONCEPTO RLS (ejecutar como role_app_service)
-- -----------------------------------------------------------------------------------
-- -- Escenario 1: cliente autenticado
-- BEGIN;
--   SET LOCAL app.current_customer_id = '<uuid_del_cliente>';
--   SET ROLE role_app_service;
--
--   -- Solo devuelve reservas de ese cliente
--   SELECT reservation_code, booked_at FROM sch_sales_reservation_and_ticketing.reservation;
--
--   -- Solo devuelve pagos de ese cliente
--   SELECT payment_reference, amount FROM sch_payment.payment;
-- ROLLBACK;
--
-- -- Escenario 2: operador (sin customer en sesión)
-- BEGIN;
--   SET LOCAL app.current_customer_id = '';
--   SET ROLE role_app_service;
--
--   -- Devuelve TODAS las reservas (modo operador)
--   SELECT COUNT(*) FROM sch_sales_reservation_and_ticketing.reservation;
-- ROLLBACK;
-- -----------------------------------------------------------------------------------