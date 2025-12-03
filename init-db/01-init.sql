-- Sample Database Schema and Data
-- This will automatically run when PostgreSQL starts for the first time

-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    UNIQUE(order_id, product_id)
);

-- Insert sample customers
INSERT INTO customers (name, email, phone) VALUES
    ('John Doe', 'john.doe@example.com', '555-0101'),
    ('Jane Smith', 'jane.smith@example.com', '555-0102'),
    ('Bob Johnson', 'bob.johnson@example.com', '555-0103'),
    ('Alice Williams', 'alice.williams@example.com', '555-0104'),
    ('Charlie Brown', 'charlie.brown@example.com', '555-0105');

-- Insert sample products
INSERT INTO products (name, description, price, stock_quantity) VALUES
    ('Laptop', 'High-performance laptop with 16GB RAM', 1299.99, 50),
    ('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 200),
    ('Keyboard', 'Mechanical gaming keyboard', 89.99, 150),
    ('Monitor', '27-inch 4K display', 399.99, 75),
    ('USB Cable', 'USB-C charging cable', 12.99, 500),
    ('Headphones', 'Noise-cancelling headphones', 199.99, 100),
    ('Webcam', '1080p HD webcam', 79.99, 120),
    ('Desk Lamp', 'LED desk lamp with adjustable brightness', 39.99, 80);

-- Insert sample orders
INSERT INTO orders (customer_id, total_amount, status) VALUES
    (1, 1329.98, 'completed'),
    (1, 89.99, 'completed'),
    (2, 479.98, 'pending'),
    (3, 1699.97, 'completed'),
    (4, 42.98, 'shipped'),
    (5, 199.99, 'pending');

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    -- Order 1: John's laptop + mouse
    (1, 1, 1, 1299.99),
    (1, 2, 1, 29.99),
    -- Order 2: John's keyboard
    (2, 3, 1, 89.99),
    -- Order 3: Jane's monitor + webcam
    (3, 4, 1, 399.99),
    (3, 7, 1, 79.99),
    -- Order 4: Bob's laptop + monitor + headphones
    (4, 1, 1, 1299.99),
    (4, 4, 1, 399.99),
    -- Order 5: Alice's cables + desk lamp
    (5, 5, 2, 12.99),
    (5, 8, 1, 39.99),
    -- Order 6: Charlie's headphones
    (6, 6, 1, 199.99);

-- Create some useful views
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT
    c.id as customer_id,
    c.name,
    c.email,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email;

CREATE OR REPLACE VIEW product_sales_summary AS
SELECT
    p.id as product_id,
    p.name,
    p.price,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) as total_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) as revenue
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.price, p.stock_quantity;

-- Create indexes for better query performance
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Output success message
DO $$
BEGIN
    RAISE NOTICE 'Database initialized successfully!';
    RAISE NOTICE 'Sample data loaded:';
    RAISE NOTICE '  - % customers', (SELECT COUNT(*) FROM customers);
    RAISE NOTICE '  - % products', (SELECT COUNT(*) FROM products);
    RAISE NOTICE '  - % orders', (SELECT COUNT(*) FROM orders);
    RAISE NOTICE '  - % order items', (SELECT COUNT(*) FROM order_items);
END $$;
