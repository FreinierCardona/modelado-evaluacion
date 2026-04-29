CREATE TABLE sch_billing.tax (
    tax_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tax_code varchar(20) NOT NULL,
    tax_name varchar(100) NOT NULL,
    rate_percentage numeric(6, 3) NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_tax_code UNIQUE (tax_code),
    CONSTRAINT uq_tax_name UNIQUE (tax_name),
    CONSTRAINT ck_tax_rate CHECK (rate_percentage >= 0),
    CONSTRAINT ck_tax_dates CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

CREATE TABLE sch_billing.exchange_rate (
    exchange_rate_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency_id uuid NOT NULL REFERENCES sch_geography.currency(currency_id),
    to_currency_id uuid NOT NULL REFERENCES sch_geography.currency(currency_id),
    effective_date date NOT NULL,
    rate_value numeric(18, 8) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_exchange_rate UNIQUE (from_currency_id, to_currency_id, effective_date),
    CONSTRAINT ck_exchange_rate_pair CHECK (from_currency_id <> to_currency_id),
    CONSTRAINT ck_exchange_rate_value CHECK (rate_value > 0)
);

CREATE TABLE sch_billing.invoice_status (
    invoice_status_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code varchar(20) NOT NULL,
    status_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_invoice_status_code UNIQUE (status_code),
    CONSTRAINT uq_invoice_status_name UNIQUE (status_name)
);

CREATE TABLE sch_billing.invoice (
    invoice_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id uuid NOT NULL REFERENCES sch_sales_reservation_and_ticketing.sale(sale_id),
    invoice_status_id uuid NOT NULL REFERENCES sch_billing.invoice_status(invoice_status_id),
    currency_id uuid NOT NULL REFERENCES sch_geography.currency(currency_id),
    invoice_number varchar(40) NOT NULL,
    issued_at timestamptz NOT NULL,
    due_at timestamptz,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_invoice_number UNIQUE (invoice_number),
    CONSTRAINT ck_invoice_dates CHECK (due_at IS NULL OR due_at >= issued_at)
);

CREATE TABLE sch_billing.invoice_line (
    invoice_line_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id uuid NOT NULL REFERENCES sch_billing.invoice(invoice_id),
    tax_id uuid REFERENCES sch_billing.tax(tax_id),
    line_number integer NOT NULL,
    line_description varchar(200) NOT NULL,
    quantity numeric(12, 2) NOT NULL,
    unit_price numeric(12, 2) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_invoice_line_number UNIQUE (invoice_id, line_number),
    CONSTRAINT ck_invoice_line_number CHECK (line_number > 0),
    CONSTRAINT ck_invoice_line_quantity CHECK (quantity > 0),
    CONSTRAINT ck_invoice_line_unit_price CHECK (unit_price >= 0)
);
