
-- Revocar los permisos otorgados a role_app_service

REVOKE SELECT ON sch_geography.time_zone FROM role_app_service;
REVOKE SELECT ON sch_geography.continent FROM role_app_service;
REVOKE SELECT ON sch_geography.country FROM role_app_service;
REVOKE SELECT ON sch_geography.state_province FROM role_app_service;
REVOKE SELECT ON sch_geography.city FROM role_app_service;
REVOKE SELECT ON sch_geography.district FROM role_app_service;
REVOKE SELECT ON sch_geography.address FROM role_app_service;
REVOKE SELECT ON sch_geography.currency FROM role_app_service;
REVOKE SELECT ON ALL SEQUENCES IN SCHEMA sch_geography FROM role_app_service;

REVOKE SELECT ON sch_airline.airline FROM role_app_service;

REVOKE SELECT ON sch_identity.person_type FROM role_app_service;
REVOKE SELECT ON sch_identity.document_type FROM role_app_service;
REVOKE SELECT ON sch_identity.contact_type FROM role_app_service;

REVOKE SELECT, INSERT, UPDATE ON sch_identity.person FROM role_app_service;
REVOKE SELECT, INSERT, UPDATE ON sch_identity.person_document FROM role_app_service;
REVOKE SELECT, INSERT, UPDATE ON sch_identity.person_contact FROM role_app_service;

REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_identity FROM role_app_service;

REVOKE SELECT ON sch_security.user_status FROM role_app_service;

REVOKE SELECT ON sch_customer_and_loyalty.customer_category FROM role_app_service;
REVOKE SELECT ON sch_customer_and_loyalty.benefit_type FROM role_app_service;
REVOKE SELECT ON sch_customer_and_loyalty.loyalty_program FROM role_app_service;
REVOKE SELECT ON sch_customer_and_loyalty.loyalty_tier FROM role_app_service;

REVOKE SELECT, INSERT, UPDATE ON sch_customer_and_loyalty.customer FROM role_app_service;
REVOKE SELECT, INSERT, UPDATE ON sch_customer_and_loyalty.loyalty_account FROM role_app_service;
REVOKE SELECT, INSERT ON sch_customer_and_loyalty.loyalty_account_tier FROM role_app_service;
REVOKE SELECT, INSERT ON sch_customer_and_loyalty.miles_transaction FROM role_app_service;
REVOKE SELECT, INSERT, UPDATE ON sch_customer_and_loyalty.customer_benefit FROM role_app_service;

REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_customer_and_loyalty FROM role_app_service;

REVOKE SELECT ON sch_airport.airport FROM role_app_service;
REVOKE SELECT ON sch_airport.terminal FROM role_app_service;
REVOKE SELECT ON sch_airport.boarding_gate FROM role_app_service;
REVOKE SELECT ON sch_airport.runway FROM role_app_service;
REVOKE SELECT ON sch_airport.airport_regulation FROM role_app_service;

REVOKE SELECT ON sch_aircraft.aircraft_manufacturer FROM role_app_service;
REVOKE SELECT ON sch_aircraft.aircraft_model FROM role_app_service;
REVOKE SELECT ON sch_aircraft.cabin_class FROM role_app_service;
REVOKE SELECT ON sch_aircraft.aircraft FROM role_app_service;
REVOKE SELECT ON sch_aircraft.aircraft_cabin FROM role_app_service;
REVOKE SELECT ON sch_aircraft.aircraft_seat FROM role_app_service;

REVOKE SELECT ON sch_flight_operations.flight_status FROM role_app_service;
REVOKE SELECT ON sch_flight_operations.delay_reason_type FROM role_app_service;

REVOKE SELECT, UPDATE ON sch_flight_operations.flight FROM role_app_service;
REVOKE SELECT ON sch_flight_operations.flight_segment FROM role_app_service;
REVOKE SELECT, INSERT ON sch_flight_operations.flight_delay FROM role_app_service;

REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_flight_operations FROM role_app_service;

REVOKE SELECT ON sch_sales_reservation_and_ticketing.reservation_status FROM role_app_service;
REVOKE SELECT ON sch_sales_reservation_and_ticketing.sale_channel FROM role_app_service;
REVOKE SELECT ON sch_sales_reservation_and_ticketing.fare_class FROM role_app_service;
REVOKE SELECT ON sch_sales_reservation_and_ticketing.ticket_status FROM role_app_service;
REVOKE SELECT ON sch_sales_reservation_and_ticketing.fare FROM role_app_service;

REVOKE SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.reservation FROM role_app_service;
REVOKE SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.reservation_passenger FROM role_app_service;
REVOKE SELECT, INSERT ON sch_sales_reservation_and_ticketing.sale FROM role_app_service;
REVOKE SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.ticket FROM role_app_service;
REVOKE SELECT, INSERT ON sch_sales_reservation_and_ticketing.ticket_segment FROM role_app_service;
REVOKE SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.seat_assignment FROM role_app_service;
REVOKE SELECT, INSERT, UPDATE ON sch_sales_reservation_and_ticketing.baggage FROM role_app_service;

REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_sales_reservation_and_ticketing FROM role_app_service;

REVOKE SELECT ON sch_boarding.boarding_group FROM role_app_service;
REVOKE SELECT ON sch_boarding.check_in_status FROM role_app_service;

REVOKE SELECT, INSERT, UPDATE ON sch_boarding.check_in FROM role_app_service;
REVOKE SELECT, INSERT ON sch_boarding.boarding_pass FROM role_app_service;
REVOKE SELECT, INSERT ON sch_boarding.boarding_validation FROM role_app_service;

REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_boarding FROM role_app_service;

REVOKE SELECT ON sch_payment.payment_status FROM role_app_service;
REVOKE SELECT ON sch_payment.payment_method FROM role_app_service;

REVOKE SELECT, INSERT ON sch_payment.payment FROM role_app_service;
REVOKE SELECT, INSERT ON sch_payment.payment_transaction FROM role_app_service;
REVOKE SELECT, INSERT ON sch_payment.refund FROM role_app_service;
REVOKE UPDATE (payment_status_id, authorized_at, updated_at) ON sch_payment.payment FROM role_app_service;

REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_payment FROM role_app_service;

REVOKE SELECT ON sch_billing.tax FROM role_app_service;
REVOKE SELECT ON sch_billing.exchange_rate FROM role_app_service;
REVOKE SELECT ON sch_billing.invoice_status FROM role_app_service;

REVOKE SELECT, INSERT, UPDATE ON sch_billing.invoice FROM role_app_service;
REVOKE SELECT, INSERT ON sch_billing.invoice_line FROM role_app_service;

REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sch_billing FROM role_app_service;

