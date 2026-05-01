
-- ESTRATEGIA DE GRANTS
-- Se usa GRANT SELECT ON ALL TABLES IN SCHEMA por eficiencia, seguido de
-- REVOKEs selectivos sobre tablas con datos hipersensibles.
-- Alternativa más estricta: listar tabla por tabla (más verboso pero más explícito).
-- En este modelo se prefiere "conceder amplio, revocar específico" para reducir
-- el riesgo de olvidar agregar una tabla nueva a la lista de permisos.

-- -------------------------------------------------------------------------------
-- sch_geography — Datos de referencia geográfica (sin información sensible)
-- Riesgo: Muy bajo. Son catálogos públicos (países, ciudades, zonas horarias).
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_geography TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_geography TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_airline — Datos de aerolíneas
-- Riesgo: Bajo. Información pública (IATA codes, nombres de aerolínea).
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_airline TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_airline TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_identity — Datos personales (PII)
-- ATENCIÓN PII: Contiene nombre, fecha de nacimiento, documentos de identidad.
-- Riesgo: Alto. Sin embargo, role_read_only está pensado para uso interno
-- autorizado (auditoría). En producción real, evaluar si añadir enmascaramiento
-- de datos dinámico (ej: extensión anon de PostgreSQL).
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_identity TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_identity TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_security — Acceso MUY RESTRICTIVO
-- NUNCA SE EXPONE: user_account contiene password_hash.
--   Aunque sea un hash (bcrypt/argon2), un auditor no tiene necesidad legítima
--   de verlo. "Need to know" aplicado estrictamente.
-- Solo se permite ver los catálogos de roles y permisos (metadata no sensible).
-- -------------------------------------------------------------------------------
GRANT SELECT ON sch_security.security_role       TO role_read_only;
GRANT SELECT ON sch_security.security_permission TO role_read_only;
GRANT SELECT ON sch_security.user_status         TO role_read_only;
-- NO: user_account (password_hash), user_role, role_permission
-- Un auditor puede ver QUÉ roles existen sin ver QUIÉN los tiene asignados.

-- -------------------------------------------------------------------------------
-- sch_customer_and_loyalty — Datos de clientes y programa de lealtad
-- ATENCIÓN PII: Linked a sch_identity via person_id.
-- La RLS (definida en 02_policies/) agrega una capa adicional de restricción
-- para que en contextos de portal de cliente solo se vean los propios datos.
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_customer_and_loyalty TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_customer_and_loyalty TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_airport — Datos de aeropuertos, terminales, puertas, pistas
-- Riesgo: Bajo-Medio. Información operacional pero no sensible a nivel personal.
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_airport TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_airport TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_aircraft — Flota, cabinas, asientos, mantenimiento
-- Riesgo: Medio. Los eventos de mantenimiento podrían ser sensibles
-- competitivamente, pero son necesarios para auditoría de seguridad aérea.
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_aircraft TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_aircraft TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_flight_operations — Vuelos, segmentos, delays
-- Riesgo: Bajo. Información operacional relevante para auditoría de puntualidad.
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_flight_operations TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_flight_operations TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_sales_reservation_and_ticketing — Reservas, tickets, asignaciones de asiento
-- Riesgo: Alto (contiene itinerarios de pasajeros identificables).
-- La RLS sobre reservation limita la exposición en contextos de portal.
-- Para auditoría interna el acceso completo es necesario.
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_sales_reservation_and_ticketing TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_sales_reservation_and_ticketing TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_boarding — Check-in, pases de abordar, validaciones
-- Riesgo: Medio. Útil para auditoría de procesos de embarque.
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_boarding TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_boarding TO role_read_only;

-- -------------------------------------------------------------------------------
-- sch_payment — NO concedido a role_read_only base
-- PCI-DSS: Las tablas payment y payment_transaction contienen referencias
-- a transacciones financieras. Aunque no almacenamos números de tarjeta en
-- texto plano, las referencias de pago son datos PCI-DSS Scope.
-- Solo role_data_analyst y superiores acceden bajo necesidad justificada.
-- -------------------------------------------------------------------------------
-- (sin grants para role_read_only en sch_payment — por diseño intencional)

-- -------------------------------------------------------------------------------
-- sch_billing — Facturas e impuestos (visible para auditoría contable)
-- Riesgo: Medio-Alto. Datos financieros pero necesarios para auditoría.
-- Los montos de invoice_line no incluyen información de método de pago.
-- -------------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA sch_billing TO role_read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA sch_billing TO role_read_only;