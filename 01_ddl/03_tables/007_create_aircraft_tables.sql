CREATE TABLE sch_aircraft.aircraft_manufacturer (
    aircraft_manufacturer_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    manufacturer_name varchar(120) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_manufacturer_name UNIQUE (manufacturer_name)
);

CREATE TABLE sch_aircraft.aircraft_model (
    aircraft_model_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_manufacturer_id uuid NOT NULL REFERENCES sch_aircraft.aircraft_manufacturer(aircraft_manufacturer_id),
    model_code varchar(30) NOT NULL,
    model_name varchar(120) NOT NULL,
    max_range_km integer,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_model_code UNIQUE (aircraft_manufacturer_id, model_code),
    CONSTRAINT uq_aircraft_model_name UNIQUE (aircraft_manufacturer_id, model_name),
    CONSTRAINT ck_aircraft_model_range CHECK (max_range_km IS NULL OR max_range_km > 0)
);

CREATE TABLE sch_aircraft.cabin_class (
    cabin_class_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    class_code varchar(10) NOT NULL,
    class_name varchar(60) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_cabin_class_code UNIQUE (class_code),
    CONSTRAINT uq_cabin_class_name UNIQUE (class_name)
);

CREATE TABLE sch_aircraft.aircraft (
    aircraft_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id uuid NOT NULL REFERENCES sch_airline.airline(airline_id),
    aircraft_model_id uuid NOT NULL REFERENCES sch_aircraft.aircraft_model(aircraft_model_id),
    registration_number varchar(20) NOT NULL,
    serial_number varchar(40) NOT NULL,
    in_service_on date,
    retired_on date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_registration UNIQUE (registration_number),
    CONSTRAINT uq_aircraft_serial UNIQUE (serial_number),
    CONSTRAINT ck_aircraft_service_dates CHECK (retired_on IS NULL OR in_service_on IS NULL OR retired_on >= in_service_on)
);

CREATE TABLE sch_aircraft.aircraft_cabin (
    aircraft_cabin_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_id uuid NOT NULL REFERENCES sch_aircraft.aircraft(aircraft_id),
    cabin_class_id uuid NOT NULL REFERENCES sch_aircraft.cabin_class(cabin_class_id),
    cabin_code varchar(10) NOT NULL,
    deck_number smallint NOT NULL DEFAULT 1,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_cabin_code UNIQUE (aircraft_id, cabin_code),
    CONSTRAINT ck_aircraft_cabin_deck CHECK (deck_number > 0)
);

CREATE TABLE sch_aircraft.aircraft_seat (
    aircraft_seat_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_cabin_id uuid NOT NULL REFERENCES sch_aircraft.aircraft_cabin(aircraft_cabin_id),
    seat_row_number integer NOT NULL,
    seat_column_code varchar(3) NOT NULL,
    is_window boolean NOT NULL DEFAULT false,
    is_aisle boolean NOT NULL DEFAULT false,
    is_exit_row boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_seat_position UNIQUE (aircraft_cabin_id, seat_row_number, seat_column_code),
    CONSTRAINT ck_aircraft_seat_row CHECK (seat_row_number > 0)
);

CREATE TABLE sch_aircraft.maintenance_provider (
    maintenance_provider_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    address_id uuid REFERENCES sch_geography.address(address_id),
    provider_name varchar(150) NOT NULL,
    contact_name varchar(120),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_maintenance_provider_name UNIQUE (provider_name)
);

CREATE TABLE sch_aircraft.maintenance_type (
    maintenance_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code varchar(20) NOT NULL,
    type_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_maintenance_type_code UNIQUE (type_code),
    CONSTRAINT uq_maintenance_type_name UNIQUE (type_name)
);

CREATE TABLE sch_aircraft.maintenance_event (
    maintenance_event_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_id uuid NOT NULL REFERENCES sch_aircraft.aircraft(aircraft_id),
    maintenance_type_id uuid NOT NULL REFERENCES sch_aircraft.maintenance_type(maintenance_type_id),
    maintenance_provider_id uuid REFERENCES sch_aircraft.maintenance_provider(maintenance_provider_id),
    status_code varchar(20) NOT NULL,
    started_at timestamptz NOT NULL,
    completed_at timestamptz,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_maintenance_event_status CHECK (status_code IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT ck_maintenance_event_dates CHECK (completed_at IS NULL OR completed_at >= started_at)
);
