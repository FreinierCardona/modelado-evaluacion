CREATE TABLE sch_boarding.boarding_group (
    boarding_group_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    group_code varchar(10) NOT NULL,
    group_name varchar(50) NOT NULL,
    sequence_no integer NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_boarding_group_code UNIQUE (group_code),
    CONSTRAINT uq_boarding_group_name UNIQUE (group_name),
    CONSTRAINT ck_boarding_group_sequence CHECK (sequence_no > 0)
);

CREATE TABLE sch_boarding.check_in_status (
    check_in_status_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code varchar(20) NOT NULL,
    status_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_check_in_status_code UNIQUE (status_code),
    CONSTRAINT uq_check_in_status_name UNIQUE (status_name)
);

CREATE TABLE sch_boarding.check_in (
    check_in_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_segment_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.ticket_segment(ticket_segment_id),
    check_in_status_id uuid NOT NULL REFERENCES sch_boarding.check_in_status(check_in_status_id),
    boarding_group_id uuid REFERENCES sch_boarding.boarding_group(boarding_group_id),
    checked_in_by_user_id uuid REFERENCES sch_security.user_account(user_account_id),
    checked_in_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_check_in_ticket_segment UNIQUE (ticket_segment_id)
);

CREATE TABLE sch_boarding.boarding_pass (
    boarding_pass_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    check_in_id uuid NOT NULL REFERENCES sch_boarding.check_in(check_in_id),
    boarding_pass_code varchar(40) NOT NULL,
    barcode_value varchar(120) NOT NULL,
    issued_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_boarding_pass_check_in UNIQUE (check_in_id),
    CONSTRAINT uq_boarding_pass_code UNIQUE (boarding_pass_code),
    CONSTRAINT uq_boarding_pass_barcode UNIQUE (barcode_value)
);

CREATE TABLE sch_boarding.boarding_validation (
    boarding_validation_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    boarding_pass_id uuid NOT NULL REFERENCES sch_boarding.boarding_pass(boarding_pass_id),
    boarding_gate_id uuid REFERENCES sch_airport.boarding_gate(boarding_gate_id),
    validated_by_user_id uuid REFERENCES sch_security.user_account(user_account_id),
    validated_at timestamptz NOT NULL,
    validation_result varchar(20) NOT NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_boarding_validation_result CHECK (validation_result IN ('APPROVED', 'REJECTED', 'MANUAL_REVIEW'))
);
