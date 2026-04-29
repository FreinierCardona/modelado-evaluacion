CREATE TABLE sch_airport.airport (
    airport_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    address_id uuid NOT NULL REFERENCES sch_geography.address(address_id),
    airport_name varchar(150) NOT NULL,
    iata_code varchar(3),
    icao_code varchar(4),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_airport_iata UNIQUE (iata_code),
    CONSTRAINT uq_airport_icao UNIQUE (icao_code),
    CONSTRAINT ck_airport_iata_len CHECK (iata_code IS NULL OR char_length(iata_code) = 3),
    CONSTRAINT ck_airport_icao_len CHECK (icao_code IS NULL OR char_length(icao_code) = 4)
);

CREATE TABLE sch_airport.terminal (
    terminal_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    airport_id uuid NOT NULL REFERENCES sch_airport.airport(airport_id),
    terminal_code varchar(10) NOT NULL,
    terminal_name varchar(80),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_terminal_code UNIQUE (airport_id, terminal_code)
);

CREATE TABLE sch_airport.boarding_gate (
    boarding_gate_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    terminal_id uuid NOT NULL REFERENCES sch_airport.terminal(terminal_id),
    gate_code varchar(10) NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_boarding_gate_code UNIQUE (terminal_id, gate_code)
);

CREATE TABLE sch_airport.runway (
    runway_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    airport_id uuid NOT NULL REFERENCES sch_airport.airport(airport_id),
    runway_code varchar(20) NOT NULL,
    length_meters integer NOT NULL,
    surface_type varchar(30),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_runway_code UNIQUE (airport_id, runway_code),
    CONSTRAINT ck_runway_length CHECK (length_meters > 0)
);

CREATE TABLE sch_airport.airport_regulation (
    airport_regulation_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    airport_id uuid NOT NULL REFERENCES sch_airport.airport(airport_id),
    regulation_code varchar(30) NOT NULL,
    regulation_title varchar(150) NOT NULL,
    issuing_authority varchar(120) NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_airport_regulation UNIQUE (airport_id, regulation_code),
    CONSTRAINT ck_airport_regulation_dates CHECK (effective_to IS NULL OR effective_to >= effective_from)
);
