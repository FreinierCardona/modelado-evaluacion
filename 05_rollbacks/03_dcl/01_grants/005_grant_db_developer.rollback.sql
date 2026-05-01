
-- Revocar ALL PRIVILEGES y CREATE sobre schemas y objetos para role_db_developer

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_geography FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_airline FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_identity FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_customer_and_loyalty FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_airport FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_aircraft FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_flight_operations FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_sales_reservation_and_ticketing FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_boarding FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA sch_billing FROM role_db_developer;

REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_geography FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_airline FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_identity FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_customer_and_loyalty FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_airport FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_aircraft FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_flight_operations FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_sales_reservation_and_ticketing FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_boarding FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_billing FROM role_db_developer;

REVOKE CREATE ON SCHEMA sch_geography FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_airline FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_identity FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_customer_and_loyalty FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_airport FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_aircraft FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_flight_operations FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_sales_reservation_and_ticketing FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_boarding FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_billing FROM role_db_developer;

REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_geography FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_airline FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_identity FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_customer_and_loyalty FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_airport FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_aircraft FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_flight_operations FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_sales_reservation_and_ticketing FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_boarding FROM role_db_developer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA sch_billing FROM role_db_developer;

REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sch_security FROM role_db_developer;
REVOKE CREATE ON SCHEMA sch_security FROM role_db_developer;

REVOKE SELECT ON sch_security.user_status FROM role_db_developer;
REVOKE SELECT ON sch_security.security_role FROM role_db_developer;
REVOKE SELECT ON sch_security.security_permission FROM role_db_developer;

REVOKE ALL PRIVILEGES ON sch_security.user_status FROM role_db_developer;
REVOKE ALL PRIVILEGES ON sch_security.security_role FROM role_db_developer;
REVOKE ALL PRIVILEGES ON sch_security.security_permission FROM role_db_developer;
REVOKE ALL PRIVILEGES ON sch_security.user_account FROM role_db_developer;
REVOKE ALL PRIVILEGES ON sch_security.user_role FROM role_db_developer;
REVOKE ALL PRIVILEGES ON sch_security.role_permission FROM role_db_developer;

