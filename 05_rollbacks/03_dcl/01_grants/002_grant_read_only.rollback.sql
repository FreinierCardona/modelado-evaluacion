
-- Revocar SELECT y SEQUENCES concedidos a role_read_only

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_geography FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_geography FROM role_read_only;

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_airline FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_airline FROM role_read_only;

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_identity FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_identity FROM role_read_only;

REVOKE SELECT ON sch_security.security_role FROM role_read_only;
REVOKE SELECT ON sch_security.security_permission FROM role_read_only;
REVOKE SELECT ON sch_security.user_status FROM role_read_only;

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_customer_and_loyalty FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_customer_and_loyalty FROM role_read_only;

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_airport FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_airport FROM role_read_only;

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_aircraft FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_aircraft FROM role_read_only;

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_flight_operations FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_flight_operations FROM role_read_only;

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_sales_reservation_and_ticketing FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_sales_reservation_and_ticketing FROM role_read_only;

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_boarding FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_boarding FROM role_read_only;

-- sch_payment: no grants fueron otorgados a role_read_only en el changeset original

REVOKE SELECT ON ALL TABLES IN SCHEMA sch_billing FROM role_read_only;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_billing FROM role_read_only;
