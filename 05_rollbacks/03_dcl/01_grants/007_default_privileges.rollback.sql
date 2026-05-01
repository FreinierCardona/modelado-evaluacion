
-- Para role_read_only defaults (revertir):
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_geography REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_airline REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_identity REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_customer_and_loyalty REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_airport REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_aircraft REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_flight_operations REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_sales_reservation_and_ticketing REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_boarding REVOKE SELECT ON TABLES FROM role_read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_billing REVOKE SELECT ON TABLES FROM role_read_only;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_sales_reservation_and_ticketing REVOKE SELECT ON SEQUENCES FROM role_read_only;

-- Para role_data_analyst defaults en sch_payment
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_payment REVOKE SELECT ON TABLES FROM role_data_analyst;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_payment REVOKE SELECT ON SEQUENCES FROM role_data_analyst;

-- Para role_app_service defaults
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_geography REVOKE SELECT ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_airline REVOKE SELECT ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_airport REVOKE SELECT ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_aircraft REVOKE SELECT ON TABLES FROM role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_identity REVOKE SELECT, INSERT, UPDATE ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_customer_and_loyalty REVOKE SELECT, INSERT, UPDATE ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_flight_operations REVOKE SELECT ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_sales_reservation_and_ticketing REVOKE SELECT, INSERT, UPDATE ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_boarding REVOKE SELECT, INSERT, UPDATE ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_payment REVOKE SELECT, INSERT ON TABLES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_billing REVOKE SELECT, INSERT, UPDATE ON TABLES FROM role_app_service;

ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_identity REVOKE USAGE, SELECT ON SEQUENCES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_customer_and_loyalty REVOKE USAGE, SELECT ON SEQUENCES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_sales_reservation_and_ticketing REVOKE USAGE, SELECT ON SEQUENCES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_boarding REVOKE USAGE, SELECT ON SEQUENCES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_payment REVOKE USAGE, SELECT ON SEQUENCES FROM role_app_service;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_billing REVOKE USAGE, SELECT ON SEQUENCES FROM role_app_service;

-- Para role_db_admin defaults (revoke ALL granted by default)
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_geography REVOKE ALL ON TABLES FROM role_db_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE role_db_developer IN SCHEMA sch_payment REVOKE ALL ON TABLES FROM role_db_admin;

