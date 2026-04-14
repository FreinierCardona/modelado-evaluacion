CREATE TABLE bill.bill (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    total NUMERIC(14,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMP,
    updated_by VARCHAR(100),
    state VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_bill_user
        FOREIGN KEY (user_id)
        REFERENCES security."user"(id)
);

CREATE TABLE bill.bill_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    total NUMERIC(14,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMP,
    updated_by VARCHAR(100),
    state VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_bill_item_bill
        FOREIGN KEY (bill_id)
        REFERENCES bill.bill(id),
    CONSTRAINT fk_bill_item_product
        FOREIGN KEY (product_id)
        REFERENCES inventory.product(id)
);
