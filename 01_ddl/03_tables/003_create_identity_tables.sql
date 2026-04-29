CREATE TABLE sch_identity.person_type (
    person_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code varchar(20) NOT NULL,
    type_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_person_type_code UNIQUE (type_code),
    CONSTRAINT uq_person_type_name UNIQUE (type_name)
);

CREATE TABLE sch_identity.document_type (
    document_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code varchar(20) NOT NULL,
    type_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_document_type_code UNIQUE (type_code),
    CONSTRAINT uq_document_type_name UNIQUE (type_name)
);

CREATE TABLE sch_identity.contact_type (
    contact_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code varchar(20) NOT NULL,
    type_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_contact_type_code UNIQUE (type_code),
    CONSTRAINT uq_contact_type_name UNIQUE (type_name)
);

CREATE TABLE sch_identity.person (
    person_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_type_id uuid NOT NULL REFERENCES sch_identity.person_type(person_type_id),
    nationality_country_id uuid REFERENCES sch_geography.country(country_id),
    first_name varchar(80) NOT NULL,
    middle_name varchar(80),
    last_name varchar(80) NOT NULL,
    second_last_name varchar(80),
    birth_date date,
    gender_code varchar(1),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_person_gender CHECK (gender_code IS NULL OR gender_code IN ('F', 'M', 'X'))
);

CREATE TABLE sch_identity.person_document (
    person_document_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id uuid NOT NULL REFERENCES sch_identity.person(person_id),
    document_type_id uuid NOT NULL REFERENCES sch_identity.document_type(document_type_id),
    issuing_country_id uuid REFERENCES sch_geography.country(country_id),
    document_number varchar(64) NOT NULL,
    issued_on date,
    expires_on date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_person_document_natural UNIQUE (document_type_id, issuing_country_id, document_number),
    CONSTRAINT ck_person_document_dates CHECK (expires_on IS NULL OR issued_on IS NULL OR expires_on >= issued_on)
);

CREATE TABLE sch_identity.person_contact (
    person_contact_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id uuid NOT NULL REFERENCES sch_identity.person(person_id),
    contact_type_id uuid NOT NULL REFERENCES sch_identity.contact_type(contact_type_id),
    contact_value varchar(180) NOT NULL,
    is_primary boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_person_contact_value UNIQUE (person_id, contact_type_id, contact_value)
);
