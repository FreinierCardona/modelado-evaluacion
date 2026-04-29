CREATE TABLE sch_geography.time_zone (
    time_zone_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    time_zone_name varchar(64) NOT NULL,
    utc_offset_minutes integer NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_time_zone_name UNIQUE (time_zone_name)
);

CREATE TABLE sch_geography.continent (
    continent_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    continent_code varchar(3) NOT NULL,
    continent_name varchar(64) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_continent_code UNIQUE (continent_code),
    CONSTRAINT uq_continent_name UNIQUE (continent_name)
);

CREATE TABLE sch_geography.country (
    country_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    continent_id uuid NOT NULL REFERENCES sch_geography.continent(continent_id),
    iso_alpha2 varchar(2) NOT NULL,
    iso_alpha3 varchar(3) NOT NULL,
    country_name varchar(128) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_country_alpha2 UNIQUE (iso_alpha2),
    CONSTRAINT uq_country_alpha3 UNIQUE (iso_alpha3),
    CONSTRAINT uq_country_name UNIQUE (country_name)
);

CREATE TABLE sch_geography.state_province (
    state_province_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id uuid NOT NULL REFERENCES sch_geography.country(country_id),
    state_code varchar(10),
    state_name varchar(128) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_state_country_name UNIQUE (country_id, state_name)
);

CREATE TABLE sch_geography.city (
    city_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    state_province_id uuid NOT NULL REFERENCES sch_geography.state_province(state_province_id),
    time_zone_id uuid NOT NULL REFERENCES sch_geography.time_zone(time_zone_id),
    city_name varchar(128) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_city_state_name UNIQUE (state_province_id, city_name)
);

CREATE TABLE sch_geography.district (
    district_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    city_id uuid NOT NULL REFERENCES sch_geography.city(city_id),
    district_name varchar(128) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_district_city_name UNIQUE (city_id, district_name)
);

CREATE TABLE sch_geography.address (
    address_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id uuid NOT NULL REFERENCES sch_geography.district(district_id),
    address_line_1 varchar(200) NOT NULL,
    address_line_2 varchar(200),
    postal_code varchar(20),
    latitude numeric(10, 7),
    longitude numeric(10, 7),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_address_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT ck_address_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

CREATE TABLE sch_geography.currency (
    currency_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    iso_currency_code varchar(3) NOT NULL,
    currency_name varchar(64) NOT NULL,
    currency_symbol varchar(8),
    minor_units smallint NOT NULL DEFAULT 2,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_currency_code UNIQUE (iso_currency_code),
    CONSTRAINT uq_currency_name UNIQUE (currency_name),
    CONSTRAINT ck_currency_minor_units CHECK (minor_units BETWEEN 0 AND 4)
);
