-- 008_inserts_sch_sales_reservation_and_ticketing.rollback.sql
-- Rollback para sch_sales_reservation_and_ticketing
BEGIN;

DELETE FROM sch_sales_reservation_and_ticketing.baggage WHERE baggage_tag LIKE 'BG%';
DELETE FROM sch_sales_reservation_and_ticketing.seat_assignment WHERE assignment_source = 'AUTO';
DELETE FROM sch_sales_reservation_and_ticketing.ticket_segment WHERE fare_basis_code LIKE 'FB%';
DELETE FROM sch_sales_reservation_and_ticketing.ticket WHERE ticket_number LIKE 'T%';
DELETE FROM sch_sales_reservation_and_ticketing.sale WHERE sale_code LIKE 'S%';
DELETE FROM sch_sales_reservation_and_ticketing.reservation_passenger WHERE passenger_type IN ('ADULT','INFANT');
DELETE FROM sch_sales_reservation_and_ticketing.reservation WHERE reservation_code LIKE 'R%';
DELETE FROM sch_sales_reservation_and_ticketing.fare WHERE fare_code LIKE 'F%';
DELETE FROM sch_sales_reservation_and_ticketing.fare_class WHERE fare_class_code LIKE 'FC%';
DELETE FROM sch_sales_reservation_and_ticketing.ticket_status WHERE status_code LIKE 'TS%';
DELETE FROM sch_sales_reservation_and_ticketing.sale_channel WHERE channel_code LIKE 'SC%';
DELETE FROM sch_sales_reservation_and_ticketing.reservation_status WHERE status_code LIKE 'RS%';

COMMIT;
