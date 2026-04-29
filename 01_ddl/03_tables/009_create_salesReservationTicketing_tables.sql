CREATE TABLE sch_sales_reservation_and_ticketing.reservation_status (
    reservation_status_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code varchar(20) NOT NULL,
    status_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_reservation_status_code UNIQUE (status_code),
    CONSTRAINT uq_reservation_status_name UNIQUE (status_name)
);

CREATE TABLE sch_sales_reservation_and_ticketing.sale_channel (
    sale_channel_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    channel_code varchar(20) NOT NULL,
    channel_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_sale_channel_code UNIQUE (channel_code),
    CONSTRAINT uq_sale_channel_name UNIQUE (channel_name)
);

CREATE TABLE sch_sales_reservation_and_ticketing.fare_class (
    fare_class_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cabin_class_id uuid NOT NULL REFERENCES sch_aircraft.cabin_class(cabin_class_id),
    fare_class_code varchar(10) NOT NULL,
    fare_class_name varchar(80) NOT NULL,
    is_refundable_by_default boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_fare_class_code UNIQUE (fare_class_code),
    CONSTRAINT uq_fare_class_name UNIQUE (fare_class_name)
);

CREATE TABLE sch_sales_reservation_and_ticketing.fare (
    fare_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id uuid NOT NULL REFERENCES sch_airline.airline(airline_id),
    origin_airport_id uuid NOT NULL REFERENCES sch_airport.airport(airport_id),
    destination_airport_id uuid NOT NULL REFERENCES sch_airport.airport(airport_id),
    fare_class_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.fare_class(fare_class_id),
    currency_id uuid NOT NULL REFERENCES sch_geography.currency(currency_id),
    fare_code varchar(30) NOT NULL,
    base_amount numeric(12, 2) NOT NULL,
    valid_from date NOT NULL,
    valid_to date,
    baggage_allowance_qty integer NOT NULL DEFAULT 0,
    change_penalty_amount numeric(12, 2),
    refund_penalty_amount numeric(12, 2),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_fare_code UNIQUE (fare_code),
    CONSTRAINT ck_fare_airports CHECK (origin_airport_id <> destination_airport_id),
    CONSTRAINT ck_fare_base_amount CHECK (base_amount >= 0),
    CONSTRAINT ck_fare_baggage_allowance CHECK (baggage_allowance_qty >= 0),
    CONSTRAINT ck_fare_change_penalty CHECK (change_penalty_amount IS NULL OR change_penalty_amount >= 0),
    CONSTRAINT ck_fare_refund_penalty CHECK (refund_penalty_amount IS NULL OR refund_penalty_amount >= 0),
    CONSTRAINT ck_fare_validity CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

CREATE TABLE sch_sales_reservation_and_ticketing.ticket_status (
    ticket_status_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code varchar(20) NOT NULL,
    status_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_ticket_status_code UNIQUE (status_code),
    CONSTRAINT uq_ticket_status_name UNIQUE (status_name)
);

CREATE TABLE sch_sales_reservation_and_ticketing.reservation (
    reservation_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    booked_by_customer_id uuid REFERENCES sch_customer_and_loyalty.customer(customer_id),
    reservation_status_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.reservation_status(reservation_status_id),
    sale_channel_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.sale_channel(sale_channel_id),
    reservation_code varchar(20) NOT NULL,
    booked_at timestamptz NOT NULL,
    expires_at timestamptz,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_reservation_code UNIQUE (reservation_code),
    CONSTRAINT ck_reservation_dates CHECK (expires_at IS NULL OR expires_at > booked_at)
);

CREATE TABLE sch_sales_reservation_and_ticketing.reservation_passenger (
    reservation_passenger_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.reservation(reservation_id),
    person_id uuid NOT NULL REFERENCES sch_identity.person(person_id),
    passenger_sequence_no integer NOT NULL,
    passenger_type varchar(20) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_reservation_passenger_person UNIQUE (reservation_id, person_id),
    CONSTRAINT uq_reservation_passenger_sequence UNIQUE (reservation_id, passenger_sequence_no),
    CONSTRAINT ck_reservation_passenger_sequence CHECK (passenger_sequence_no > 0),
    CONSTRAINT ck_reservation_passenger_type CHECK (passenger_type IN ('ADULT', 'CHILD', 'INFANT'))
);

CREATE TABLE sch_sales_reservation_and_ticketing.sale (
    sale_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.reservation(reservation_id),
    currency_id uuid NOT NULL REFERENCES sch_geography.currency(currency_id),
    sale_code varchar(30) NOT NULL,
    sold_at timestamptz NOT NULL,
    external_reference varchar(50),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_sale_code UNIQUE (sale_code)
);

CREATE TABLE sch_sales_reservation_and_ticketing.ticket (
    ticket_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.sale(sale_id),
    reservation_passenger_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.reservation_passenger(reservation_passenger_id),
    fare_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.fare(fare_id),
    ticket_status_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.ticket_status(ticket_status_id),
    ticket_number varchar(20) NOT NULL,
    issued_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_ticket_number UNIQUE (ticket_number)
);

CREATE TABLE sch_sales_reservation_and_ticketing.ticket_segment (
    ticket_segment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.ticket(ticket_id),
    flight_segment_id uuid NOT NULL REFERENCES sch_flight_operations.flight_segment(flight_segment_id),
    segment_sequence_no integer NOT NULL,
    fare_basis_code varchar(20),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_ticket_segment_sequence UNIQUE (ticket_id, segment_sequence_no),
    CONSTRAINT uq_ticket_segment_flight UNIQUE (ticket_id, flight_segment_id),
    CONSTRAINT uq_ticket_segment_pair UNIQUE (ticket_segment_id, flight_segment_id),
    CONSTRAINT ck_ticket_segment_sequence CHECK (segment_sequence_no > 0)
);

CREATE TABLE sch_sales_reservation_and_ticketing.seat_assignment (
    seat_assignment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_segment_id uuid NOT NULL,
    flight_segment_id uuid NOT NULL,
    aircraft_seat_id uuid NOT NULL REFERENCES sch_aircraft.aircraft_seat(aircraft_seat_id),
    assigned_at timestamptz NOT NULL,
    assignment_source varchar(20) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_seat_assignment_ticket_segment UNIQUE (ticket_segment_id),
    CONSTRAINT uq_seat_assignment_flight_seat UNIQUE (flight_segment_id, aircraft_seat_id),
    CONSTRAINT ck_seat_assignment_source CHECK (assignment_source IN ('AUTO', 'MANUAL', 'CUSTOMER')),
    CONSTRAINT fk_seat_assignment_ticket_segment FOREIGN KEY (ticket_segment_id, flight_segment_id)
        REFERENCES sch_sales_reservation_and_ticketing.ticket_segment(ticket_segment_id, flight_segment_id)
);

CREATE TABLE sch_sales_reservation_and_ticketing.baggage (
    baggage_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_segment_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.ticket_segment(ticket_segment_id),
    baggage_tag varchar(30) NOT NULL,
    baggage_type varchar(20) NOT NULL,
    baggage_status varchar(20) NOT NULL,
    weight_kg numeric(6, 2) NOT NULL,
    checked_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_baggage_tag UNIQUE (baggage_tag),
    CONSTRAINT ck_baggage_type CHECK (baggage_type IN ('CHECKED', 'CARRY_ON', 'SPECIAL')),
    CONSTRAINT ck_baggage_status CHECK (baggage_status IN ('REGISTERED', 'LOADED', 'CLAIMED', 'LOST')),
    CONSTRAINT ck_baggage_weight CHECK (weight_kg > 0)
);
