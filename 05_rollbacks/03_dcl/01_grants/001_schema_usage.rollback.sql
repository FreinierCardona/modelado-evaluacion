
-- Revocar permisos otorgados a roles explícitos
REVOKE USAGE ON SCHEMA sch_geography FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_airline FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_identity FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_customer_and_loyalty FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_airport FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_aircraft FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_flight_operations FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_sales_reservation_and_ticketing FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_boarding FROM role_read_only;
REVOKE USAGE ON SCHEMA sch_billing FROM role_read_only;

REVOKE USAGE ON SCHEMA sch_payment FROM role_data_analyst;

REVOKE USAGE ON SCHEMA sch_geography FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_airline FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_identity FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_security FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_customer_and_loyalty FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_airport FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_aircraft FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_flight_operations FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_sales_reservation_and_ticketing FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_boarding FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_payment FROM role_app_service;
REVOKE USAGE ON SCHEMA sch_billing FROM role_app_service;

REVOKE USAGE ON SCHEMA sch_geography FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_airline FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_identity FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_security FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_customer_and_loyalty FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_airport FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_aircraft FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_flight_operations FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_sales_reservation_and_ticketing FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_boarding FROM role_db_developer;
REVOKE USAGE ON SCHEMA sch_billing FROM role_db_developer;

REVOKE ALL ON SCHEMA sch_geography FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_airline FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_identity FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_security FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_customer_and_loyalty FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_airport FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_aircraft FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_flight_operations FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_sales_reservation_and_ticketing FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_boarding FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_payment FROM role_db_admin;
REVOKE ALL ON SCHEMA sch_billing FROM role_db_admin;

-- Restaurar (invertir los REVOKE ALL aplicados a PUBLIC)
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA sch_geography TO PUBLIC;
GRANT ALL ON SCHEMA sch_airline TO PUBLIC;
GRANT ALL ON SCHEMA sch_identity TO PUBLIC;
GRANT ALL ON SCHEMA sch_security TO PUBLIC;
GRANT ALL ON SCHEMA sch_customer_and_loyalty TO PUBLIC;
GRANT ALL ON SCHEMA sch_airport TO PUBLIC;
GRANT ALL ON SCHEMA sch_aircraft TO PUBLIC;
GRANT ALL ON SCHEMA sch_flight_operations TO PUBLIC;
GRANT ALL ON SCHEMA sch_sales_reservation_and_ticketing TO PUBLIC;
GRANT ALL ON SCHEMA sch_boarding TO PUBLIC;
GRANT ALL ON SCHEMA sch_payment TO PUBLIC;
GRANT ALL ON SCHEMA sch_billing TO PUBLIC;
