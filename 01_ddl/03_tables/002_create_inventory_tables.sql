CREATE TABLE inventory.category (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMP,
    updated_by VARCHAR(100),
    state VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE inventory.product (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL,
    category_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMP,
    updated_by VARCHAR(100),
    state VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES inventory.category(id)
);

CREATE TABLE inventory.inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL,
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMP,
    updated_by VARCHAR(100),
    state VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES inventory.product(id)
);
