
-- FILOSOFÍA DE ESTE ARCHIVO
-- A diferencia de role_read_only que usa GRANT ON ALL TABLES, aquí se listan
-- tablas individualmente con los permisos exactos necesarios.
-- Razón: la aplicación tiene casos de uso específicos conocidos. Ser explícito
-- documenta el contrato de acceso y hace las revisiones de seguridad más simples.

-- ----------------------------------------------------------------------------------
-- sch_geography — Solo lectura (datos de referencia, nunca modificados por la app)
-- RIESGO MITIGADO: La app no puede crear países falsos ni modificar UTC offsets,
-- lo que podría causar cálculos incorrectos de horarios de vuelo.
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_geography.time_zone TO role_app_service;
GRANT SELECT ON sch_geography.continent TO role_app_service;
GRANT SELECT ON sch_geography.country TO role_app_service;
GRANT SELECT ON sch_geography.state_province TO role_app_service;
GRANT SELECT ON sch_geography.city TO role_app_service;
GRANT SELECT ON sch_geography.district TO role_app_service;
GRANT SELECT ON sch_geography.address TO role_app_service;
GRANT SELECT ON sch_geography.currency TO role_app_service;
-- Sequences: solo USAGE para JOINs por FK, no inserta en este schema
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_geography TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_airline — Solo lectura (configuración de aerolíneas gestionada por admins)
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_airline.airline TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_identity — INSERT/UPDATE permitidos (registro de nuevos pasajeros)
-- RIESGO ANALIZADO: La app crea personas (pasajeros nuevos) y actualiza
-- datos de contacto. NO puede eliminar personas ni documentos (integridad referencial
-- y cumplimiento legal de retención de datos).
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_identity.person_type TO role_app_service;
GRANT SELECT ON sch_identity.document_type TO role_app_service;
GRANT SELECT ON sch_identity.contact_type TO role_app_service;

GRANT SELECT, INSERT, UPDATE ON sch_identity.person TO role_app_service;
GRANT SELECT, INSERT, UPDATE ON sch_identity.person_document TO role_app_service;
GRANT SELECT, INSERT, UPDATE ON sch_identity.person_contact TO role_app_service;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_identity TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_security — Acceso MÍNIMO y RESTRINGIDO
-- REGLA CRÍTICA: La aplicación puede verificar estado de usuario y leer catálogos
-- de roles, pero NUNCA puede leer password_hash ni modificar roles/permisos.
-- La autenticación (verificar password) se debe implementar como función
-- SECURITY DEFINER que la app llame sin acceso directo a la tabla.
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_security.user_status TO role_app_service;
-- NO: user_account (password_hash), security_role, user_role, role_permission

-- ----------------------------------------------------------------------------------
-- sch_customer_and_loyalty — CRUD completo (core del negocio de fidelización)
-- RIESGO ANALIZADO:
--   • INSERT en customer: registro de nuevos clientes
--   • UPDATE en loyalty_account: actualizar saldo de millas
--   • INSERT en miles_transaction: registrar transacciones de millas 
--   • NO DELETE en ninguna tabla de loyalty (auditoría de millas es regulada)
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_customer_and_loyalty.customer_category TO role_app_service;
GRANT SELECT ON sch_customer_and_loyalty.benefit_type TO role_app_service;
GRANT SELECT ON sch_customer_and_loyalty.loyalty_program TO role_app_service;
GRANT SELECT ON sch_customer_and_loyalty.loyalty_tier TO role_app_service;

GRANT SELECT, INSERT, UPDATE ON sch_customer_and_loyalty.customer TO role_app_service;
GRANT SELECT, INSERT, UPDATE ON sch_customer_and_loyalty.loyalty_account TO role_app_service;
GRANT SELECT, INSERT ON sch_customer_and_loyalty.loyalty_account_tier TO role_app_service;
GRANT SELECT, INSERT ON sch_customer_and_loyalty.miles_transaction TO role_app_service;
GRANT SELECT, INSERT, UPDATE ON sch_customer_and_loyalty.customer_benefit TO role_app_service;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_customer_and_loyalty TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_airport — Solo lectura (datos maestros gestionados por operaciones)
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_airport.airport TO role_app_service;
GRANT SELECT ON sch_airport.terminal TO role_app_service;
GRANT SELECT ON sch_airport.boarding_gate TO role_app_service;
GRANT SELECT ON sch_airport.runway TO role_app_service;
GRANT SELECT ON sch_airport.airport_regulation TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_aircraft — Solo lectura (flota gestionada por operaciones técnicas)
-- SoD: El sistema de reservas NO debe poder modificar la configuración de
-- cabinas o asientos. Si alguien cambia is_exit_row en un asiento desde la app,
-- podría afectar la seguridad del vuelo.
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_aircraft.aircraft_manufacturer TO role_app_service;
GRANT SELECT ON sch_aircraft.aircraft_model TO role_app_service;
GRANT SELECT ON sch_aircraft.cabin_class TO role_app_service;
GRANT SELECT ON sch_aircraft.aircraft TO role_app_service;
GRANT SELECT ON sch_aircraft.aircraft_cabin TO role_app_service;
GRANT SELECT ON sch_aircraft.aircraft_seat TO role_app_service;
-- NO: maintenance_event, maintenance_provider, maintenance_type
-- (la app de reservas no necesita ver historial de mantenimiento)

-- ----------------------------------------------------------------------------------
-- sch_flight_operations — Lectura de vuelos + UPDATE de status
-- RIESGO ANALIZADO: La app puede actualizar el estado de un vuelo (delay, cancel)
-- pero NO puede crear vuelos nuevos ni modificar horarios directamente.
-- El INSERT en flight_delay es legítimo (la app registra demoras reportadas).
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_flight_operations.flight_status TO role_app_service;
GRANT SELECT ON sch_flight_operations.delay_reason_type  TO role_app_service;

GRANT SELECT, UPDATE ON sch_flight_operations.flight TO role_app_service;
GRANT SELECT ON sch_flight_operations.flight_segment TO role_app_service;
GRANT SELECT, INSERT ON sch_flight_operations.flight_delay TO role_app_service;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_flight_operations TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_sales_reservation_and_ticketing — Permisos CORE del flujo de reservas
-- Este es el schema más crítico para role_app_service.
-- REGLA DE ORO: NO se otorga DELETE en reservation, ticket ni sale.
--   • Eliminar una reserva es una operación de negocio irreversible que debe
--     ir por flujo de cancelación controlado (cambio de status, no DELETE).
--   • Los tickets son documentos legales vinculados a contratos de transporte.
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_sales_reservation_and_ticketing.reservation_status TO role_app_service;
GRANT SELECT ON sch_sales_reservation_and_ticketing.sale_channel TO role_app_service;
GRANT SELECT ON sch_sales_reservation_and_ticketing.fare_class TO role_app_service;
GRANT SELECT ON sch_sales_reservation_and_ticketing.ticket_status TO role_app_service;
GRANT SELECT ON sch_sales_reservation_and_ticketing.fare TO role_app_service;

GRANT SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.reservation TO role_app_service;
GRANT SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.reservation_passenger TO role_app_service;
GRANT SELECT, INSERT ON sch_sales_reservation_and_ticketing.sale TO role_app_service;
GRANT SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.ticket TO role_app_service;
GRANT SELECT, INSERT ON sch_sales_reservation_and_ticketing.ticket_segment TO role_app_service;
GRANT SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.seat_assignment TO role_app_service;
GRANT SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.baggage TO role_app_service;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_sales_reservation_and_ticketing TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_boarding — Operaciones de check-in y embarque
-- RIESGO ANALIZADO:
--   • INSERT en check_in, boarding_pass: la app genera pases de abordar 
--   • INSERT en boarding_validation: registra cada escaneo de boarding pass 
--   • UPDATE en check_in: actualizar estado del check-in 
--   • NO DELETE: un boarding_pass emitido es un documento de seguridad
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_boarding.boarding_group TO role_app_service;
GRANT SELECT ON sch_boarding.check_in_status TO role_app_service;

GRANT SELECT, INSERT, UPDATE ON sch_boarding.check_in TO role_app_service;
GRANT SELECT, INSERT ON sch_boarding.boarding_pass TO role_app_service;
GRANT SELECT, INSERT ON sch_boarding.boarding_validation  TO role_app_service;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_boarding TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_payment — Procesamiento de pagos
-- PCI-DSS SCOPE: Permisos mínimos indispensables para el flujo de cobro.
-- REGLA CRÍTICA: NO se permite UPDATE ni DELETE sobre payment una vez creado.
--   Los cambios de estado van por payment_transaction (registro inmutable de eventos).
--   Los reembolsos van por la tabla refund (trazabilidad completa).
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_payment.payment_status TO role_app_service;
GRANT SELECT ON sch_payment.payment_method TO role_app_service;

GRANT SELECT, INSERT ON sch_payment.payment TO role_app_service;
GRANT SELECT, INSERT ON sch_payment.payment_transaction TO role_app_service;
GRANT SELECT, INSERT ON sch_payment.refund TO role_app_service;
-- UPDATE limitado en payment: solo para registrar authorized_at (post-autorización)
GRANT UPDATE (payment_status_id, authorized_at, updated_at) ON sch_payment.payment TO role_app_service;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_payment TO role_app_service;

-- ----------------------------------------------------------------------------------
-- sch_billing — Facturación
-- ----------------------------------------------------------------------------------
GRANT SELECT ON sch_billing.tax TO role_app_service;
GRANT SELECT ON sch_billing.exchange_rate TO role_app_service;
GRANT SELECT ON sch_billing.invoice_status TO role_app_service;

GRANT SELECT, INSERT, UPDATE ON sch_billing.invoice TO role_app_service;
GRANT SELECT, INSERT ON sch_billing.invoice_line TO role_app_service;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_billing TO role_app_service;