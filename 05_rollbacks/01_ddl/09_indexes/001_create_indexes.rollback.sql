-- Rollback: drop indexes created in 01_ddl/09_indexes/001_create_indexes.sql
DROP INDEX IF EXISTS idx_country_continent_id;
DROP INDEX IF EXISTS idx_state_country_id;
DROP INDEX IF EXISTS idx_city_state_id;
DROP INDEX IF EXISTS idx_district_city_id;
DROP INDEX IF EXISTS idx_address_district_id;

DROP INDEX IF EXISTS idx_person_person_type_id;
DROP INDEX IF EXISTS idx_person_nationality_country_id;
DROP INDEX IF EXISTS idx_person_document_person_id;
DROP INDEX IF EXISTS idx_person_document_number;
DROP INDEX IF EXISTS idx_person_contact_person_id;
DROP INDEX IF EXISTS idx_person_contact_value;

DROP INDEX IF EXISTS idx_user_account_status_id;
DROP INDEX IF EXISTS idx_user_role_user_account_id;
DROP INDEX IF EXISTS idx_user_role_role_id;
DROP INDEX IF EXISTS idx_role_permission_role_id;
DROP INDEX IF EXISTS idx_role_permission_permission_id;

DROP INDEX IF EXISTS idx_customer_person_id;
DROP INDEX IF EXISTS idx_loyalty_program_airline_id;
DROP INDEX IF EXISTS idx_loyalty_account_customer_id;
DROP INDEX IF EXISTS idx_loyalty_account_tier_account_id;
DROP INDEX IF EXISTS idx_miles_transaction_account_id;

DROP INDEX IF EXISTS idx_airport_address_id;
DROP INDEX IF EXISTS idx_terminal_airport_id;
DROP INDEX IF EXISTS idx_boarding_gate_terminal_id;
DROP INDEX IF EXISTS idx_runway_airport_id;

DROP INDEX IF EXISTS idx_aircraft_airline_id;
DROP INDEX IF EXISTS idx_aircraft_model_id;
DROP INDEX IF EXISTS idx_aircraft_cabin_aircraft_id;
DROP INDEX IF EXISTS idx_aircraft_seat_cabin_id;
DROP INDEX IF EXISTS idx_maintenance_event_aircraft_id;

DROP INDEX IF EXISTS idx_flight_aircraft_id;
DROP INDEX IF EXISTS idx_flight_service_date;
DROP INDEX IF EXISTS idx_flight_segment_flight_id;
DROP INDEX IF EXISTS idx_flight_segment_origin_airport_id;
DROP INDEX IF EXISTS idx_flight_segment_destination_airport_id;
DROP INDEX IF EXISTS idx_flight_delay_segment_id;

DROP INDEX IF EXISTS idx_fare_class_cabin_class_id;
DROP INDEX IF EXISTS idx_fare_airline_id;
DROP INDEX IF EXISTS idx_reservation_status_id;
DROP INDEX IF EXISTS idx_reservation_booked_by_customer_id;
DROP INDEX IF EXISTS idx_reservation_passenger_person_id;
DROP INDEX IF EXISTS idx_sale_reservation_id;
DROP INDEX IF EXISTS idx_ticket_sale_id;
DROP INDEX IF EXISTS idx_ticket_reservation_passenger_id;
DROP INDEX IF EXISTS idx_ticket_segment_ticket_id;
DROP INDEX IF EXISTS idx_ticket_segment_flight_segment_id;
DROP INDEX IF EXISTS idx_seat_assignment_aircraft_seat_id;
DROP INDEX IF EXISTS idx_baggage_ticket_segment_id;

DROP INDEX IF EXISTS idx_check_in_status_id;
DROP INDEX IF EXISTS idx_boarding_pass_check_in_id;
DROP INDEX IF EXISTS idx_boarding_validation_boarding_pass_id;

DROP INDEX IF EXISTS idx_payment_sale_id;
DROP INDEX IF EXISTS idx_payment_status_id;
DROP INDEX IF EXISTS idx_payment_transaction_payment_id;
DROP INDEX IF EXISTS idx_refund_payment_id;

DROP INDEX IF EXISTS idx_exchange_rate_from_to_date;
DROP INDEX IF EXISTS idx_invoice_sale_id;
DROP INDEX IF EXISTS idx_invoice_status_id;
DROP INDEX IF EXISTS idx_invoice_line_invoice_id;
