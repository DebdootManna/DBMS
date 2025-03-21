-- 1. Insert 50 sample grocery products across 8 categories with randomized pricing and stock quantities
INSERT INTO products (name, description, category, sub_category, price, stock_quantity, discount_percent, rating, image_url, attributes)
WITH categories AS (
    SELECT unnest(ARRAY['Fruits & Vegetables', 'Dairy & Eggs', 'Snacks', 'Beverages', 
                         'Household', 'Personal Care', 'Bakery', 'Frozen Foods']) AS category
),
sub_categories AS (
    SELECT 
        'Fruits & Vegetables' AS category, unnest(ARRAY['Fresh Fruits', 'Fresh Vegetables', 'Organic Produce', 'Herbs']) AS sub_category
    UNION ALL SELECT 
        'Dairy & Eggs' AS category, unnest(ARRAY['Milk', 'Cheese', 'Yogurt', 'Eggs']) AS sub_category
    UNION ALL SELECT 
        'Snacks' AS category, unnest(ARRAY['Chips', 'Cookies', 'Nuts', 'Chocolates']) AS sub_category
    UNION ALL SELECT 
        'Beverages' AS category, unnest(ARRAY['Soft Drinks', 'Juices', 'Tea', 'Coffee']) AS sub_category
    UNION ALL SELECT 
        'Household' AS category, unnest(ARRAY['Cleaning', 'Laundry', 'Kitchen', 'Bath']) AS sub_category
    UNION ALL SELECT 
        'Personal Care' AS category, unnest(ARRAY['Soap', 'Shampoo', 'Oral Care', 'Skincare']) AS sub_category
    UNION ALL SELECT 
        'Bakery' AS category, unnest(ARRAY['Bread', 'Pastries', 'Cakes', 'Cookies']) AS sub_category
    UNION ALL SELECT 
        'Frozen Foods' AS category, unnest(ARRAY['Ice Cream', 'Frozen Meals', 'Frozen Vegetables', 'Frozen Desserts']) AS sub_category
),
products_data AS (
    SELECT 
        'Product ' || s.id AS name,
        'Description for ' || 'Product ' || s.id AS description,
        sc.category,
        sc.sub_category,
        (random() * 900 + 100)::numeric(10,2) AS price,
        (random() * 100 + 10)::int AS stock_quantity,
        (random() * 30)::int AS discount_percent,
        (random() * 4 + 1)::numeric(2,1) AS rating,
        'https://example.com/images/product-' || s.id || '.jpg' AS image_url,
        jsonb_build_object(
            'weight', (random() * 5 + 0.1)::numeric(4,2),
            'unit', (ARRAY['kg', 'g', 'l', 'ml', 'piece', 'pack'])[1 + floor(random() * 6)::int],
            'is_organic', random() > 0.7,
            'country_of_origin', (ARRAY['India', 'USA', 'China', 'Brazil', 'Australia'])[1 + floor(random() * 5)::int],
            'shelf_life_days', (random() * 90 + 30)::int,
            'nutritional_info', jsonb_build_object(
                'calories', (random() * 500)::int,
                'protein', (random() * 20)::numeric(4,1),
                'carbs', (random() * 50)::numeric(4,1),
                'fat', (random() * 30)::numeric(4,1)
            )
        ) AS attributes
    FROM 
        sub_categories sc,
        generate_series(1, 50) AS s(id)
    WHERE 
        (s.id % 8) + 1 = array_position(ARRAY['Fruits & Vegetables', 'Dairy & Eggs', 'Snacks', 'Beverages', 
                                             'Household', 'Personal Care', 'Bakery', 'Frozen Foods'], sc.category)
)
SELECT 
    name, description, category, sub_category, price, stock_quantity, 
    discount_percent, rating, image_url, attributes
FROM 
    products_data;

-- 2. Update product stock after order completion using a CTE that calculates remaining stock
WITH order_products AS (
    SELECT 
        oi.product_id,
        SUM(oi.quantity) AS total_quantity_ordered
    FROM 
        order_items oi
    JOIN 
        orders o ON oi.order_id = o.order_id
    WHERE 
        o.order_id = '00000000-0000-0000-0000-000000000001'
        AND o.status = 'processing'
    GROUP BY 
        oi.product_id
),
stock_updates AS (
    UPDATE products p
    SET 
        stock_quantity = p.stock_quantity - op.total_quantity_ordered
    FROM 
        order_products op
    WHERE 
        p.product_id = op.product_id
        AND p.stock_quantity >= op.total_quantity_ordered
    RETURNING 
        p.product_id, 
        p.name, 
        p.stock_quantity AS new_stock_quantity, 
        op.total_quantity_ordered
),
order_update AS (
    UPDATE orders
    SET 
        status = CASE 
            WHEN (SELECT COUNT(*) FROM order_products) = (SELECT COUNT(*) FROM stock_updates)
            THEN 'out_for_delivery'::order_status
            ELSE 'cancelled'::order_status
        END,
        processed_at = CASE 
            WHEN (SELECT COUNT(*) FROM order_products) = (SELECT COUNT(*) FROM stock_updates)
            THEN NOW()
            ELSE NULL
        END,
        shipped_at = CASE 
            WHEN (SELECT COUNT(*) FROM order_products) = (SELECT COUNT(*) FROM stock_updates)
            THEN NOW()
            ELSE NULL
        END,
        cancelled_at = CASE 
            WHEN (SELECT COUNT(*) FROM order_products) != (SELECT COUNT(*) FROM stock_updates)
            THEN NOW()
            ELSE NULL
        END,
        order_metadata = order_metadata || jsonb_build_object(
            'fulfillment_notes', CASE 
                WHEN (SELECT COUNT(*) FROM order_products) = (SELECT COUNT(*) FROM stock_updates)
                THEN 'All items in stock'
                ELSE 'Some items out of stock'
            END
        )
    WHERE 
        order_id = '00000000-0000-0000-0000-000000000001'
    RETURNING 
        order_id, 
        status, 
        processed_at, 
        shipped_at
)
SELECT 
    su.product_id,
    su.name,
    su.new_stock_quantity,
    su.total_quantity_ordered,
    o.order_id,
    o.status,
    o.processed_at,
    CASE 
        WHEN o.status = 'out_for_delivery' THEN 'Order processed successfully'
        ELSE 'Order cancelled due to insufficient stock'
    END AS result
FROM 
    stock_updates su
CROSS JOIN 
    order_update o;

-- 3. Transfer cart items to order_items while preserving cart snapshot prices
DO $$
DECLARE
    v_user_id UUID := '00000000-0000-0000-0000-000000000001';
    v_order_id UUID;
    v_total_amount NUMERIC(12,2);
    v_delivery_fee NUMERIC(6,2) := 49.99;
BEGIN
    -- Start a transaction
    BEGIN
        -- Check if the user has items in cart
        IF NOT EXISTS (SELECT 1 FROM cart_items WHERE user_id = v_user_id) THEN
            RAISE EXCEPTION 'No items in cart for user %', v_user_id;
        END IF;
        
        -- Calculate total amount
        SELECT 
            SUM(p.price * (1 - p.discount_percent / 100.0) * c.quantity)
        INTO 
            v_total_amount
        FROM 
            cart_items c
        JOIN 
            products p ON c.product_id = p.product_id
        WHERE 
            c.user_id = v_user_id;
        
        -- Create a new order
        INSERT INTO orders (
            user_id, 
            total_amount, 
            delivery_fee,
            delivery_address,
            payment_method,
            status,
            payment_status,
            order_metadata
        )
        SELECT 
            v_user_id,
            v_total_amount + v_delivery_fee,
            v_delivery_fee,
            u.delivery_address,
            COALESCE(u.preferred_payment_method, '{"type": "cash", "details": "Cash on delivery"}'),
            'pending',
            'pending',
            jsonb_build_object(
                'device_info', 'Mobile App v1.2.3',
                'ip_address', '192.168.1.1',
                'promotion_codes', '[]'::jsonb
            )
        FROM 
            users u
        WHERE 
            u.user_id = v_user_id
        RETURNING 
            order_id INTO v_order_id;
        
        -- Transfer cart items to order_items
        INSERT INTO order_items (
            order_id,
            product_id,
            quantity,
            price_at_order,
            discount_percent_at_order
        )
        SELECT 
            v_order_id,
            c.product_id,
            c.quantity,
            p.price,
            p.discount_percent
        FROM 
            cart_items c
        JOIN 
            products p ON c.product_id = p.product_id
        WHERE 
            c.user_id = v_user_id;
        
        -- Delete cart items
        DELETE FROM cart_items WHERE user_id = v_user_id;
        
        -- Update user loyalty points
        UPDATE users
        SET 
            loyalty_points = loyalty_points + (v_total_amount / 10)::int
        WHERE 
            user_id = v_user_id;
            
        -- Commit the transaction
        COMMIT;
        
        RAISE NOTICE 'Order created successfully with order_id: %', v_order_id;
        
    EXCEPTION WHEN OTHERS THEN
        -- Rollback the transaction
        ROLLBACK;
        RAISE NOTICE 'Failed to create order: %', SQLERRM;
    END;
END $$;

-- 4. Calculate dynamic user loyalty tiers based on 6-month spending
WITH user_orders AS (
    SELECT 
        u.user_id,
        u.full_name,
        u.loyalty_points,
        COALESCE(SUM(o.total_amount), 0) AS total_6month_spending,
        COUNT(o.order_id) AS orders_6month,
        COALESCE(AVG(o.total_amount), 0) AS avg_order_value
    FROM 
        users u
    LEFT JOIN 
        orders o ON u.user_id = o.user_id
        AND o.created_at >= (NOW() - INTERVAL '6 months')
        AND o.status = 'delivered'
    GROUP BY 
        u.user_id, u.full_name, u.loyalty_points
),
loyalty_calculation AS (
    SELECT 
        user_id,
        full_name,
        loyalty_points,
        total_6month_spending,
        orders_6month,
        avg_order_value,
        CASE
            WHEN total_6month_spending >= 50000 OR orders_6month >= 50 THEN 'platinum'::loyalty_tier
            WHEN total_6month_spending >= 20000 OR orders_6month >= 25 THEN 'gold'::loyalty_tier
            WHEN total_6month_spending >= 10000 OR orders_6month >= 10 THEN 'silver'::loyalty_tier
            ELSE 'bronze'::loyalty_tier
        END AS calculated_tier
    FROM 
        user_orders
)
UPDATE users u
SET 
    loyalty_tier = lc.calculated_tier,
    loyalty_points = CASE
        WHEN lc.calculated_tier = 'platinum' THEN u.loyalty_points + 1000
        WHEN lc.calculated_tier = 'gold' THEN u.loyalty_points + 500
        WHEN lc.calculated_tier = 'silver' THEN u.loyalty_points + 200
        ELSE u.loyalty_points
    END
FROM 
    loyalty_calculation lc
WHERE 
    u.user_id = lc.user_id
    AND u.loyalty_tier != lc.calculated_tier
RETURNING 
    u.user_id,
    u.full_name,
    u.loyalty_tier,
    u.loyalty_points,
    lc.total_6month_spending,
    lc.orders_6month,
    lc.avg_order_value;

-- 5. Find top 10 most abandoned products in carts using window functions
WITH abandoned_carts AS (
    SELECT 
        c.product_id,
        p.name,
        p.category,
        p.price,
        p.discount_percent,
        c.quantity,
        c.added_at,
        c.updated_at,
        EXTRACT(EPOCH FROM (NOW() - c.updated_at))/3600 AS hours_in_cart,
        ROW_NUMBER() OVER(PARTITION BY c.product_id ORDER BY c.updated_at DESC) AS recency_rank,
        COUNT(*) OVER(PARTITION BY c.product_id) AS total_appearances,
        SUM(c.quantity) OVER(PARTITION BY c.product_id) AS total_quantity,
        AVG(c.quantity) OVER(PARTITION BY c.product_id) AS avg_quantity,
        PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY c.quantity) OVER(PARTITION BY c.product_id) AS median_quantity,
        RANK() OVER(ORDER BY COUNT(*) OVER(PARTITION BY c.product_id) DESC) AS abandonment_rank
    FROM 
        cart_items c
    JOIN 
        products p ON c.product_id = p.product_id
    WHERE 
        c.updated_at < (NOW() - INTERVAL '24 hours')
        AND NOT EXISTS (
            SELECT 1 FROM orders o 
            WHERE o.user_id = c.user_id 
            AND o.created_at > c.updated_at
        )
),
product_abandonment_stats AS (
    SELECT 
        product_id,
        name,
        category,
        price,
        discount_percent,
        total_appearances,
        total_quantity,
        avg_quantity,
        median_quantity,
        abandonment_rank,
        AVG(hours_in_cart) AS avg_hours_in_cart,
        SUM(quantity * price * (1 - discount_percent/100.0)) AS total_value_abandoned
    FROM 
        abandoned_carts
    GROUP BY 
        product_id, name, category, price, discount_percent, 
        total_appearances, total_quantity, avg_quantity, median_quantity, abandonment_rank
)
SELECT 
    product_id,
    name,
    category,
    price,
    discount_percent,
    total_appearances,
    total_quantity,
    avg_quantity::numeric(10,2),
    median_quantity::numeric(10,2),
    avg_hours_in_cart::numeric(10,2) AS avg_hours_in_cart,
    total_value_abandoned::numeric(10,2) AS total_value_abandoned,
    jsonb_build_object(
        'conversion_opportunity', total_value_abandoned::numeric(10,2),
        'suggested_actions', jsonb_build_array(
            'Send targeted discount',
            'Display prominently in recommendations',
            'Review product pricing',
            'Check product description completeness'
        )
    ) AS insights
FROM 
    product_abandonment_stats
WHERE 
    abandonment_rank <= 10
ORDER BY 
    abandonment_rank;

-- 6. Generate weekly sales reports with YoY comparison using date functions
WITH date_range AS (
    SELECT 
        generate_series(
            date_trunc('week', NOW() - INTERVAL '52 weeks'),
            date_trunc('week', NOW()),
            '1 week'::interval
        ) AS week_start
),
weekly_sales AS (
    SELECT 
        date_trunc('week', o.created_at) AS week_start,
        SUM(o.total_amount) AS total_sales,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(DISTINCT o.user_id) AS unique_customers,
        SUM(o.total_amount) / COUNT(DISTINCT o.order_id) AS avg_order_value,
        SUM(oi.quantity) AS total_items_sold,
        COUNT(DISTINCT oi.product_id) AS unique_products_sold
    FROM 
        orders o
    JOIN 
        order_items oi ON o.order_id = oi.order_id
    WHERE 
        o.status = 'delivered'
        AND o.created_at >= (NOW() - INTERVAL '52 weeks')
    GROUP BY 
        date_trunc('week', o.created_at)
),
category_sales AS (
    SELECT 
        date_trunc('week', o.created_at) AS week_start,
        p.category,
        SUM(oi.quantity * oi.price_at_order * (1 - oi.discount_percent_at_order/100.0)) AS category_sales,
        SUM(oi.quantity) AS category_quantity
    FROM 
        orders o
    JOIN 
        order_items oi ON o.order_id = oi.order_id
    JOIN 
        products p ON oi.product_id = p.product_id
    WHERE 
        o.status = 'delivered'
        AND o.created_at >= (NOW() - INTERVAL '52 weeks')
    GROUP BY 
        date_trunc('week', o.created_at),
        p.category
),
yearly_comparison AS (
    SELECT 
        d.week_start,
        EXTRACT(WEEK FROM d.week_start) AS week_number,
        ws.total_sales,
        ws.order_count,
        ws.unique_customers,
        ws.avg_order_value,
        ws.total_items_sold,
        ws.unique_products_sold,
        LAG(ws.total_sales, 52) OVER (ORDER BY d.week_start) AS last_year_sales,
        LAG(ws.order_count, 52) OVER (ORDER BY d.week_start) AS last_year_orders,
        LAG(ws.unique_customers, 52) OVER (ORDER BY d.week_start) AS last_year_customers,
        jsonb_object_agg(
            cs.category, 
            jsonb_build_object(
                'sales', cs.category_sales,
                'quantity', cs.category_quantity
            )
        ) AS category_breakdown
    FROM 
        date_range d
    LEFT JOIN 
        weekly_sales ws ON d.week_start = ws.week_start
    LEFT JOIN 
        category_sales cs ON d.week_start = cs.week_start
    GROUP BY 
        d.week_start, 
        ws.total_sales, 
        ws.order_count, 
        ws.unique_customers, 
        ws.avg_order_value, 
        ws.total_items_sold, 
        ws.unique_products_sold
)
SELECT 
    week_start,
    week_number,
    COALESCE(total_sales, 0)::numeric(12,2) AS total_sales,
    COALESCE(order_count, 0) AS order_count,
    COALESCE(unique_customers, 0) AS unique_customers,
    COALESCE(avg_order_value, 0)::numeric(12,2) AS avg_order_value,
    COALESCE(total_items_sold, 0) AS total_items_sold,
    COALESCE(unique_products_sold, 0) AS unique_products_sold,
    COALESCE(last_year_sales, 0)::numeric(12,2) AS last_year_sales,
    COALESCE(last_year_orders, 0) AS last_year_orders,
    COALESCE(last_year_customers, 0) AS last_year_customers,
    CASE 
        WHEN last_year_sales IS NULL OR last_year_sales = 0 THEN NULL
        ELSE ((total_sales - last_year_sales) / last_year_sales * 100)::numeric(12,2)
    END AS sales_yoy_growth_percent,
    CASE 
        WHEN last_year_orders IS NULL OR last_year_orders = 0 THEN NULL
        ELSE ((order_count - last_year_orders) / last_year_orders * 100)::numeric(12,2)
    END AS orders_yoy_growth_percent,
    category_breakdown
FROM 
    yearly_comparison
WHERE 
    week_start >= (NOW() - INTERVAL '12 weeks')
ORDER BY 
    week_start DESC;

-- 7. Implement dynamic pricing rules using CASE statements
WITH stock_levels AS (
    SELECT 
        p.product_id,
        p.name,
        p.category,
        p.price AS original_price,
        p.stock_quantity,
        p.discount_percent AS original_discount,
        CASE
            WHEN p.stock_quantity < 10 THEN 'low'
            WHEN p.stock_quantity BETWEEN 10 AND 30 THEN 'medium'
            WHEN p.stock_quantity > 30 AND p.stock_quantity <= 50 THEN 'high'
            ELSE 'overstock'
        END AS stock_level
    FROM 
        products p
),
category_avg_price AS (
    SELECT 
        category,
        AVG(original_price) AS avg_category_price
    FROM 
        stock_levels
    GROUP BY 
        category
),
price_adjustments AS (
    SELECT 
        sl.product_id,
        sl.name,
        sl.category,
        sl.original_price,
        sl.stock_quantity,
        sl.stock_level,
        sl.original_discount,
        cap.avg_category_price,
        CASE
            WHEN sl.stock_level = 'low' THEN sl.original_price * 1.15
            WHEN sl.stock_level = 'medium' THEN sl.original_price * 1.05
            WHEN sl.stock_level = 'high' THEN sl.original_price * 0.95
            WHEN sl.stock_level = 'overstock' THEN sl.original_price * 0.85
            ELSE sl.original_price
        END AS adjusted_price,
        CASE
            WHEN sl.stock_level = 'low' THEN sl.original_discount - 5
            WHEN sl.stock_level = 'medium' THEN sl.original_discount
            WHEN sl.stock_level = 'high' THEN sl.original_discount + 5
            WHEN sl.stock_level = 'overstock' THEN sl.original_discount + 15
            ELSE sl.original_discount
        END AS adjusted_discount,
        CASE
            WHEN sl.stock_level = 'low' THEN 'High demand, limited stock'
            WHEN sl.stock_level = 'medium' THEN 'Normal demand and stock'
            WHEN sl.stock_level = 'high' THEN 'Excess stock, promote consumption'
            WHEN sl.stock_level = 'overstock' THEN 'Urgent stock reduction needed'
            ELSE 'Normal pricing'
        END AS pricing_strategy
    FROM 
        stock_levels sl
    JOIN 
        category_avg_price cap ON sl.category = cap.category
)
UPDATE products p
SET 
    price = pa.adjusted_price,
    discount_percent = pa.adjusted_discount,
    attributes = p.attributes || jsonb_build_object(
        'pricing_history', COALESCE(
            p.attributes->'pricing_history', 
            jsonb_build_array()
        ) || jsonb_build_object(
            'date', CURRENT_DATE,
            'original_price', pa.original_price,
            'adjusted_price', pa.adjusted_price,
            'original_discount', pa.original_discount,
            'adjusted_discount', pa.adjusted_discount,
            'stock_level', pa.stock_level,
            'pricing_strategy', pa.pricing_strategy
        ),
        'price_last_updated', CURRENT_TIMESTAMP,
        'price_adjustment_reason', pa.pricing_strategy
    )
FROM 
    price_adjustments pa
WHERE 
    p.product_id = pa.product_id
    AND (
        p.price != pa.adjusted_price
        OR p.discount_percent != pa.adjusted_discount
    )
RETURNING 
    p.product_id,
    p.name,
    p.category,
    pa.original_price,
    p.price AS new_price,
    pa.original_discount,
    p.discount_percent AS new_discount,
    pa.stock_level,
    pa.pricing_strategy,
    (p.price * (1 - p.discount_percent/100.0))::numeric(10,2) AS final_price,
    (pa.original_price * (1 - pa.original_discount/100.0))::numeric(10,2) AS original_final_price,
    (((p.price * (1 - p.discount_percent/100.0)) - (pa.original_price * (1 - pa.original_discount/100.0))) / 
     (pa.original_price * (1 - pa.original_discount/100.0)) * 100)::numeric(10,2) AS price_change_percent;

-- 8. Create materialized view for personalized recommendations using purchase history joins
-- This view aggregates detailed purchase data, computes additional statistics,
-- and ranks products for each user based on purchase frequency and monetary value.
-- It also demonstrates JSONB operations by embedding purchase stats in the result.

-- Step 8.1: Create a CTE for detailed purchase history over the last 6 months.
WITH detailed_purchase AS (
  SELECT 
    u.user_id,
    oi.product_id,
    p.category,
    SUM(oi.quantity) AS total_quantity,
    COUNT(*) AS purchase_count,
    SUM(oi.quantity * p.price) AS total_spent,
    AVG(p.price) AS avg_price,
    MAX(o.created_at) AS last_purchase_date,
    -- Build a JSONB object with additional stats.
    jsonb_build_object(
      'totalSpent', SUM(oi.quantity * p.price),
      'orderCount', COUNT(*),
      'averagePrice', AVG(p.price)
    ) AS purchase_stats
  FROM orders o
  INNER JOIN order_items oi ON o.order_id = oi.order_id
  INNER JOIN products p ON oi.product_id = p.product_id
  INNER JOIN users u ON o.user_id = u.user_id
  WHERE o.created_at > NOW() - INTERVAL '6 months'
  GROUP BY u.user_id, oi.product_id, p.category
),

-- Step 8.2: Rank products per user based on purchase count and total spent.
ranked_purchases AS (
  SELECT
    dp.*,
    ROW_NUMBER() OVER (PARTITION BY dp.user_id ORDER BY dp.purchase_count DESC, dp.total_spent DESC) AS prod_rank,
    -- Determine a recommendation score tier based on purchase count.
    CASE
      WHEN dp.purchase_count >= 10 THEN 'Platinum'
      WHEN dp.purchase_count >= 5 THEN 'Gold'
      ELSE 'Silver'
    END AS loyalty_tier
  FROM detailed_purchase dp
)

-- Step 8.3: Create the materialized view using the ranked purchases.
CREATE MATERIALIZED VIEW IF NOT EXISTS personalized_recommendations AS
SELECT
  rp.user_id,
  rp.product_id,
  rp.category,
  rp.total_quantity,
  rp.purchase_count,
  rp.total_spent,
  rp.avg_price,
  rp.last_purchase_date,
  rp.purchase_stats,
  rp.loyalty_tier,
  rp.prod_rank
FROM ranked_purchases rp
WHERE rp.last_purchase_date IS NOT NULL
WITH NO DATA;

-- Add an index for fast lookup in the materialized view.
CREATE UNIQUE INDEX IF NOT EXISTS idx_personalized_recs ON personalized_recommendations (user_id, product_id);

-- Optionally, schedule periodic refresh of the materialized view using a CRON job or manual REFRESH MATERIALIZED VIEW CONCURRENTLY.
-- REFRESH MATERIALIZED VIEW CONCURRENTLY personalized_recommendations;


-- 9. Optimize delivery routes with geometric patterns in delivery addresses
-- This section extracts coordinates stored as JSONB from the users table, converts them to a PostGIS geometry,
-- and then leverages spatial indexing and functions to optimize route calculations.

-- 9.1: Alter the users table to add a geometry column if it doesn't already exist.
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS geom GEOMETRY(Point, 4326);

-- 9.2: Update the new geometry column using JSONB values from the delivery_address column.
-- Assume delivery_address JSONB contains keys "lat" and "lon".
UPDATE users
SET geom = ST_SetSRID(
              ST_MakePoint(
                (delivery_address->>'lon')::numeric, 
                (delivery_address->>'lat')::numeric
              ), 4326)
WHERE delivery_address ? 'lat' AND delivery_address ? 'lon';

-- 9.3: Create a spatial index on the geom column to optimize location queries.
CREATE INDEX IF NOT EXISTS idx_users_geom ON users USING GIST (geom);

-- 9.4: Example query: Find users within a 5km radius of a given store coordinate.
SELECT 
  user_id, 
  full_name, 
  delivery_address,
  ST_Distance(geom, ST_SetSRID(ST_MakePoint(-73.935242, 40.730610), 4326)) AS distance
FROM users
WHERE ST_DWithin(
        geom, 
        ST_SetSRID(ST_MakePoint(-73.935242, 40.730610), 4326),
        5000
      )
ORDER BY distance;


-- 10. Calculate real-time inventory alerts using trigger functions on concurrent operations
-- This part implements a PL/pgSQL trigger function that updates product stock on order completion,
-- logs low inventory events, and uses robust error handling and transactional controls.

-- 10.1: Create a table to log inventory alerts.
CREATE TABLE IF NOT EXISTS inventory_alerts (
    alert_id SERIAL PRIMARY KEY,
    product_id UUID REFERENCES products(product_id),
    alert_message TEXT,
    alert_time TIMESTAMPTZ DEFAULT NOW()
);

-- 10.2: Create the trigger function to update inventory and log alerts.
CREATE OR REPLACE FUNCTION update_inventory_and_alert() 
RETURNS TRIGGER AS $$
DECLARE
    remaining_stock INT;
BEGIN
    -- Use a CTE to calculate the new stock.
    WITH updated AS (
      UPDATE products
      SET stock_quantity = stock_quantity - NEW.quantity
      WHERE product_id = NEW.product_id
      RETURNING stock_quantity
    )
    SELECT stock_quantity INTO remaining_stock FROM updated;
    
    -- Check for low inventory and log an alert if below the threshold (e.g., less than 10 items).
    IF remaining_stock < 10 THEN
      INSERT INTO inventory_alerts(product_id, alert_message, alert_time)
      VALUES (NEW.product_id, 'Low inventory: only ' || remaining_stock || ' items left', NOW());
      RAISE NOTICE 'Low inventory alert: Product % has only % items left', NEW.product_id, remaining_stock;
    END IF;
    
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error in update_inventory_and_alert trigger for product %: %', NEW.product_id, SQLERRM;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 10.3: Create a trigger on the order_items table to invoke the inventory update function after an insert.
CREATE TRIGGER trg_update_inventory
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_inventory_and_alert();

-- Optionally, wrap inventory update operations within a transaction block for additional safety.
BEGIN;
-- (Perform order insertion and related operations here)
COMMIT;
