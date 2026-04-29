CREATE TABLE sch_customer_and_loyalty.customer_category (
    customer_category_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code varchar(20) NOT NULL,
    category_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_category_code UNIQUE (category_code),
    CONSTRAINT uq_customer_category_name UNIQUE (category_name)
);

CREATE TABLE sch_customer_and_loyalty.benefit_type (
    benefit_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    benefit_code varchar(30) NOT NULL,
    benefit_name varchar(100) NOT NULL,
    benefit_description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_benefit_type_code UNIQUE (benefit_code),
    CONSTRAINT uq_benefit_type_name UNIQUE (benefit_name)
);

CREATE TABLE sch_customer_and_loyalty.loyalty_program (
    loyalty_program_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id uuid NOT NULL REFERENCES sch_airline.airline(airline_id),
    default_currency_id uuid NOT NULL REFERENCES sch_geography.currency(currency_id),
    program_code varchar(20) NOT NULL,
    program_name varchar(120) NOT NULL,
    expiration_months integer,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_loyalty_program_code UNIQUE (airline_id, program_code),
    CONSTRAINT uq_loyalty_program_name UNIQUE (airline_id, program_name),
    CONSTRAINT ck_loyalty_program_expiration CHECK (expiration_months IS NULL OR expiration_months > 0)
);

CREATE TABLE sch_customer_and_loyalty.loyalty_tier (
    loyalty_tier_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    loyalty_program_id uuid NOT NULL REFERENCES sch_customer_and_loyalty.loyalty_program(loyalty_program_id),
    tier_code varchar(20) NOT NULL,
    tier_name varchar(80) NOT NULL,
    priority_level integer NOT NULL,
    required_miles integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_loyalty_tier_code UNIQUE (loyalty_program_id, tier_code),
    CONSTRAINT uq_loyalty_tier_name UNIQUE (loyalty_program_id, tier_name),
    CONSTRAINT ck_loyalty_tier_priority CHECK (priority_level > 0),
    CONSTRAINT ck_loyalty_tier_required_miles CHECK (required_miles >= 0)
);

CREATE TABLE sch_customer_and_loyalty.customer (
    customer_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id uuid NOT NULL REFERENCES sch_airline.airline(airline_id),
    person_id uuid NOT NULL REFERENCES sch_identity.person(person_id),
    customer_category_id uuid REFERENCES sch_customer_and_loyalty.customer_category(customer_category_id),
    customer_since date NOT NULL DEFAULT current_date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_airline_person UNIQUE (airline_id, person_id)
);

CREATE TABLE sch_customer_and_loyalty.loyalty_account (
    loyalty_account_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id uuid NOT NULL REFERENCES sch_customer_and_loyalty.customer(customer_id),
    loyalty_program_id uuid NOT NULL REFERENCES sch_customer_and_loyalty.loyalty_program(loyalty_program_id),
    account_number varchar(40) NOT NULL,
    opened_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_loyalty_account_number UNIQUE (account_number),
    CONSTRAINT uq_loyalty_account_customer_program UNIQUE (customer_id, loyalty_program_id)
);

CREATE TABLE sch_customer_and_loyalty.loyalty_account_tier (
    loyalty_account_tier_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    loyalty_account_id uuid NOT NULL REFERENCES sch_customer_and_loyalty.loyalty_account(loyalty_account_id),
    loyalty_tier_id uuid NOT NULL REFERENCES sch_customer_and_loyalty.loyalty_tier(loyalty_tier_id),
    assigned_at timestamptz NOT NULL,
    expires_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_loyalty_account_tier_point UNIQUE (loyalty_account_id, assigned_at),
    CONSTRAINT ck_loyalty_account_tier_dates CHECK (expires_at IS NULL OR expires_at > assigned_at)
);

CREATE TABLE sch_customer_and_loyalty.miles_transaction (
    miles_transaction_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    loyalty_account_id uuid NOT NULL REFERENCES sch_customer_and_loyalty.loyalty_account(loyalty_account_id),
    transaction_type varchar(20) NOT NULL,
    miles_delta integer NOT NULL,
    occurred_at timestamptz NOT NULL,
    reference_code varchar(60),
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_miles_transaction_type CHECK (transaction_type IN ('EARN', 'REDEEM', 'ADJUST')),
    CONSTRAINT ck_miles_delta_non_zero CHECK (miles_delta <> 0)
);

CREATE TABLE sch_customer_and_loyalty.customer_benefit (
    customer_benefit_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id uuid NOT NULL REFERENCES sch_customer_and_loyalty.customer(customer_id),
    benefit_type_id uuid NOT NULL REFERENCES sch_customer_and_loyalty.benefit_type(benefit_type_id),
    granted_at timestamptz NOT NULL,
    expires_at timestamptz,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_benefit UNIQUE (customer_id, benefit_type_id, granted_at),
    CONSTRAINT ck_customer_benefit_dates CHECK (expires_at IS NULL OR expires_at > granted_at)
);
