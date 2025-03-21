-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create enum types
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'out_for_delivery', 'delivered', 'cancelled');
CREATE TYPE loyalty_tier AS ENUM ('bronze', 'silver', 'gold', 'platinum');

-- Create tables with constraints and indexes
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(12) UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    delivery_address JSONB NOT NULL,
    preferred_payment_method JSONB,
    last_active TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    loyalty_tier loyalty_tier DEFAULT 'bronze',
    loyalty_points INT DEFAULT 0,
    CONSTRAINT valid_phone CHECK (phone_number ~ '^[0-9]{10,12}$')
);

CREATE INDEX idx_users_last_active ON users(last_active);
CREATE INDEX idx_users_loyalty_tier ON users(loyalty_tier);
CREATE INDEX idx_users_delivery_address ON users USING GIN(delivery_address);

-- Create products table
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    discount_percent INT DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    rating NUMERIC(2,1) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    image_url TEXT,
    attributes JSONB DEFAULT '{}',
    search_vector tsvector,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_sub_category ON products(sub_category);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_stock ON products(stock_quantity);
CREATE INDEX idx_products_rating ON products(rating);
CREATE INDEX idx_products_search ON products USING GIN(search_vector);
CREATE INDEX idx_products_attributes ON products USING GIN(attributes);

-- Create cart_items table
CREATE TABLE cart_items (
    cart_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

CREATE INDEX idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);
CREATE INDEX idx_cart_items_added_at ON cart_items(added_at);

-- Create orders table
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    delivery_fee NUMERIC(6,2) DEFAULT 0 CHECK (delivery_fee >= 0),
    delivery_address JSONB NOT NULL,
    delivery_instructions TEXT,
    status order_status DEFAULT 'pending',
    payment_method JSONB NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    delivery_time_minutes INT,
    delivery_distance_meters INT,
    order_metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_delivered_at ON orders(delivered_at);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);

-- Create order_items table
CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_order NUMERIC(10,2) NOT NULL CHECK (price_at_order >= 0),
    discount_percent_at_order INT DEFAULT 0 CHECK (discount_percent_at_order >= 0 AND discount_percent_at_order <= 100),
    item_subtotal NUMERIC(12,2) GENERATED ALWAYS AS 
        (quantity * price_at_order * (1 - discount_percent_at_order / 100.0)) STORED
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Create a function to update search vector
CREATE OR REPLACE FUNCTION products_search_update() RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.category, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.sub_category, '')), 'D');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update search vector
CREATE TRIGGER products_search_update_trigger
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION products_search_update();

-- Create a function to update product timestamps
CREATE OR REPLACE FUNCTION update_product_timestamp() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update product timestamps
CREATE TRIGGER update_product_timestamp_trigger
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_product_timestamp();

-- Create a function to update cart timestamps
CREATE OR REPLACE FUNCTION update_cart_timestamp() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update cart timestamps
CREATE TRIGGER update_cart_timestamp_trigger
BEFORE UPDATE ON cart_items
FOR EACH ROW EXECUTE FUNCTION update_cart_timestamp();

-- Create RLS policies for users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY users_select_policy ON users FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY users_update_policy ON users FOR UPDATE USING (auth.uid() = user_id);

-- Create RLS policies for cart_items table
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY cart_items_select_policy ON cart_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY cart_items_insert_policy ON cart_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY cart_items_update_policy ON cart_items FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY cart_items_delete_policy ON cart_items FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for orders table
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY orders_select_policy ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY orders_insert_policy ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY orders_update_status_policy ON orders FOR UPDATE 
    USING (auth.uid() = user_id AND status = 'pending');