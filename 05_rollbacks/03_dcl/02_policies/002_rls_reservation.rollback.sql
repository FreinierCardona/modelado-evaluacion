
-- Deshabilita RLS y elimina policies creadas en reservation, ticket, payment y boarding_pass

-- reservation
ALTER TABLE sch_sales_reservation_and_ticketing.reservation FORCE ROW LEVEL SECURITY NO FORCE;
ALTER TABLE sch_sales_reservation_and_ticketing.reservation DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_reservation_customer ON sch_sales_reservation_and_ticketing.reservation;
DROP POLICY IF EXISTS pol_reservation_audit ON sch_sales_reservation_and_ticketing.reservation;
DROP POLICY IF EXISTS pol_reservation_admin ON sch_sales_reservation_and_ticketing.reservation;

-- ticket
ALTER TABLE sch_sales_reservation_and_ticketing.ticket FORCE ROW LEVEL SECURITY NO FORCE;
ALTER TABLE sch_sales_reservation_and_ticketing.ticket DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_ticket_customer ON sch_sales_reservation_and_ticketing.ticket;
DROP POLICY IF EXISTS pol_ticket_audit ON sch_sales_reservation_and_ticketing.ticket;
DROP POLICY IF EXISTS pol_ticket_admin ON sch_sales_reservation_and_ticketing.ticket;

-- payment
ALTER TABLE sch_payment.payment FORCE ROW LEVEL SECURITY NO FORCE;
ALTER TABLE sch_payment.payment DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_payment_customer ON sch_payment.payment;
DROP POLICY IF EXISTS pol_payment_analyst ON sch_payment.payment;
DROP POLICY IF EXISTS pol_payment_admin ON sch_payment.payment;

-- boarding_pass
ALTER TABLE sch_boarding.boarding_pass FORCE ROW LEVEL SECURITY NO FORCE;
ALTER TABLE sch_boarding.boarding_pass DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_boarding_pass_customer ON sch_boarding.boarding_pass;
DROP POLICY IF EXISTS pol_boarding_pass_operator ON sch_boarding.boarding_pass;
DROP POLICY IF EXISTS pol_boarding_pass_audit ON sch_boarding.boarding_pass;
DROP POLICY IF EXISTS pol_boarding_pass_admin ON sch_boarding.boarding_pass;

