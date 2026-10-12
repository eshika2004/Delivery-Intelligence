CREATE TABLE public.customer (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

select * from customer;

CREATE TABLE orders (
    ord_inx INTEGER,
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);
select * from orders;

CREATE TABLE order_items (
	ord_id INTEGER,
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);
select * from order_items;

CREATE TABLE public.order_payment (
    row_id INTEGER,
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(10,2)
);
select * from order_payment;

CREATE TABLE public.order_review (
    row_id INTEGER,
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE public.products (
    row_id INTEGER,
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght NUMERIC,
    product_description_lenght NUMERIC,
    product_photos_qty NUMERIC,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

CREATE TABLE public.sellers (
    seller_id TEXT,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);

CREATE TABLE public.product_category_name_translation (
    product_category_name TEXT,
    product_category_name_english TEXT
);

CREATE TABLE public.geolocation (
    geo_id INTEGER,
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city TEXT,
    geolocation_state TEXT
);

ALTER TABLE public.orders DROP COLUMN ord_inx;
ALTER TABLE public.orders DROP COLUMN unnamed;
ALTER TABLE public.order_items DROP COLUMN ord_id;
ALTER TABLE public.order_payment DROP COLUMN row_id;
ALTER TABLE public.order_review DROP COLUMN row_id;
ALTER TABLE public.products DROP COLUMN row_id;
ALTER TABLE public.geolocation DROP COLUMN geo_id;

SELECT 'customer' AS table_name, COUNT(*) AS row_count FROM public.customer
UNION ALL
SELECT 'orders', COUNT(*) FROM public.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM public.order_items
UNION ALL
SELECT 'order_payment', COUNT(*) FROM public.order_payment
UNION ALL
SELECT 'order_review', COUNT(*) FROM public.order_review
UNION ALL
SELECT 'products', COUNT(*) FROM public.products
UNION ALL
SELECT 'sellers', COUNT(*) FROM public.sellers
UNION ALL
SELECT 'product_category_name_translation', COUNT(*) 
FROM public.product_category_name_translation
UNION ALL
SELECT 'geolocation', COUNT(*) FROM public.geolocation;

SELECT COUNT(*) AS unmatched_customers
FROM public.orders o
LEFT JOIN public.customer c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS unmatched_orders
FROM public.order_items oi
LEFT JOIN public.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(DISTINCT oi.order_id) AS unmatched_order_ids
FROM public.order_items oi
LEFT JOIN public.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS unmatched_products
FROM public.order_items oi
LEFT JOIN public.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(DISTINCT oi.product_id) AS unmatched_product_ids
FROM public.order_items oi
LEFT JOIN public.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT DISTINCT oi.product_id
FROM public.order_items oi
LEFT JOIN public.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS unmatched_sellers
FROM public.order_items oi
LEFT JOIN public.sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

SELECT COUNT(*) AS unmatched_orders
FROM public.order_payment op
LEFT JOIN public.orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(DISTINCT op.order_id) AS unmatched_order_ids
FROM public.order_payment op
LEFT JOIN public.orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS unmatched_orders
FROM public.order_review r
LEFT JOIN public.orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(DISTINCT r.order_id) AS unmatched_order_ids
FROM public.order_review r
LEFT JOIN public.orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS unmatched_categories
FROM public.products p
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

  SELECT DISTINCT p.product_category_name
FROM public.products p
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

  SELECT COUNT(*) AS unmatched_customer_zip_codes
FROM public.customer c
LEFT JOIN public.geolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

SELECT COUNT(DISTINCT c.customer_zip_code_prefix) AS unmatched_customer_zip_codes
FROM public.customer c
LEFT JOIN public.geolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

SELECT DISTINCT c.customer_zip_code_prefix
FROM public.customer c
LEFT JOIN public.geolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL
LIMIT 20;

SELECT COUNT(*) AS unmatched_seller_zip_codes
FROM public.sellers s
LEFT JOIN public.geolocation g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

SELECT COUNT(DISTINCT s.seller_zip_code_prefix) AS unmatched_seller_zip_codes
FROM public.sellers s
LEFT JOIN public.geolocation g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

SELECT COUNT(*) AS invalid_shipping_dates
FROM public.order_items oi
JOIN public.orders o
    ON oi.order_id = o.order_id
WHERE oi.shipping_limit_date < o.order_purchase_timestamp;

--Primary keys
ALTER TABLE public.customer
ADD CONSTRAINT customer_pk PRIMARY KEY (customer_id);

ALTER TABLE public.orders
ADD CONSTRAINT orders_pk PRIMARY KEY (order_id);

ALTER TABLE public.order_items
ADD CONSTRAINT order_items_pk PRIMARY KEY (order_id, order_item_id);

ALTER TABLE public.order_payment
ADD CONSTRAINT order_payment_pk
PRIMARY KEY (order_id, payment_sequential);

ALTER TABLE public.order_review
ADD CONSTRAINT order_review_pk
PRIMARY KEY (order_id, review_id);

ALTER TABLE public.products
ADD CONSTRAINT products_pk PRIMARY KEY (product_id);

ALTER TABLE public.sellers
ADD CONSTRAINT sellers_pk PRIMARY KEY (seller_id);

ALTER TABLE public.product_category_name_translation
ADD CONSTRAINT category_translation_pk
PRIMARY KEY (product_category_name);

SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'PRIMARY KEY'
ORDER BY tc.table_name;

--Foreign keys
ALTER TABLE public.orders
ADD CONSTRAINT orders_customer_fk
FOREIGN KEY (customer_id)
REFERENCES public.customer(customer_id);

ALTER TABLE public.order_items
ADD CONSTRAINT order_items_seller_fk
FOREIGN KEY (seller_id)
REFERENCES public.sellers(seller_id);

SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;

--ML analytical dataset
SELECT
    order_id,
    COUNT(*) AS item_count,
    SUM(price) AS total_price,
    SUM(freight_value) AS total_freight,
    COUNT(DISTINCT seller_id) AS seller_count,
    COUNT(DISTINCT product_id) AS product_count
FROM public.order_items
GROUP BY order_id;

SELECT
    oi.order_id,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT t.product_category_name_english) AS category_count,
    STRING_AGG(
        DISTINCT COALESCE(t.product_category_name_english, p.product_category_name),
        ', '
    ) AS product_categories,
    AVG(p.product_weight_g) AS avg_product_weight_g
FROM public.order_items oi
LEFT JOIN public.products p
    ON oi.product_id = p.product_id
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY oi.order_id;

SELECT
    oi.order_id,
    COUNT(DISTINCT s.seller_id) AS seller_count,
    STRING_AGG(DISTINCT s.seller_state, ', ') AS seller_states
FROM public.order_items oi
LEFT JOIN public.sellers s
    ON oi.seller_id = s.seller_id
GROUP BY oi.order_id;

SELECT
    order_id,
    SUM(payment_value) AS total_payment_value,
    MAX(payment_installments) AS max_installments,
    COUNT(DISTINCT payment_type) AS payment_type_count,
    STRING_AGG(DISTINCT payment_type, ', ') AS payment_types
FROM public.order_payment
GROUP BY order_id;

SELECT
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0
    END AS late_delivery,
    COUNT(*) AS order_count
FROM public.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY late_delivery
ORDER BY late_delivery;

CREATE OR REPLACE VIEW order_items_summary AS
SELECT
    order_id,
    COUNT(*) AS item_count,
    SUM(price) AS total_price,
    SUM(freight_value) AS total_freight,
    COUNT(DISTINCT seller_id) AS seller_count,
    COUNT(DISTINCT product_id) AS product_count
FROM public.order_items
GROUP BY order_id;

CREATE OR REPLACE VIEW order_product_summary AS
SELECT
    oi.order_id,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT t.product_category_name_english) AS category_count,
    STRING_AGG(
        DISTINCT COALESCE(
            t.product_category_name_english,
            p.product_category_name
        ),
        ', '
    ) AS product_categories,
    AVG(p.product_weight_g) AS avg_product_weight_g
FROM public.order_items oi
LEFT JOIN public.products p
    ON oi.product_id = p.product_id
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY oi.order_id;

CREATE OR REPLACE VIEW order_seller_summary AS
SELECT
    oi.order_id,
    COUNT(DISTINCT s.seller_id) AS seller_count,
    STRING_AGG(DISTINCT s.seller_state, ', ') AS seller_states
FROM public.order_items oi
LEFT JOIN public.sellers s
    ON oi.seller_id = s.seller_id
GROUP BY oi.order_id;

CREATE OR REPLACE VIEW order_payment_summary AS
SELECT
    order_id,
    SUM(payment_value) AS total_payment_value,
    MAX(payment_installments) AS max_installments,
    COUNT(DISTINCT payment_type) AS payment_type_count,
    STRING_AGG(DISTINCT payment_type, ', ') AS payment_types
FROM public.order_payment
GROUP BY order_id;

CREATE OR REPLACE VIEW public.order_product_summary AS
SELECT
    oi.order_id,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT t.product_category_name_english) AS category_count,
    STRING_AGG(
        DISTINCT COALESCE(
            t.product_category_name_english,
            p.product_category_name
        ),
        ', '
    ) AS product_categories,
    AVG(p.product_weight_g) AS avg_product_weight_g
FROM public.order_items oi
LEFT JOIN public.products p
    ON oi.product_id = p.product_id
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY oi.order_id;

--Final data
CREATE OR REPLACE VIEW public.ml_order_dataset AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_state,
    o.order_purchase_timestamp,

    oi.item_count,
    oi.total_price,
    oi.total_freight,
    oi.seller_count,
    oi.product_count,

    op.total_payment_value,
    op.max_installments,
    op.payment_type_count,
    op.payment_types,

    ps.category_count,
    ps.product_categories,
    ps.avg_product_weight_g,

    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1
        ELSE 0
    END AS late_delivery

FROM public.orders o

LEFT JOIN public.customer c
    ON o.customer_id = c.customer_id

LEFT JOIN public.order_items_summary oi
    ON o.order_id = oi.order_id

LEFT JOIN public.order_product_summary ps
    ON o.order_id = ps.order_id

LEFT JOIN public.order_payment_summary op
    ON o.order_id = op.order_id

WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL;

SELECT COUNT(*)
FROM public.ml_order_dataset;

SELECT *
FROM public.ml_order_dataset
LIMIT 10;

SELECT
    COUNT(*) FILTER (WHERE customer_state IS NULL) AS missing_customer_state,
    COUNT(*) FILTER (WHERE item_count IS NULL) AS missing_item_count,
    COUNT(*) FILTER (WHERE total_price IS NULL) AS missing_total_price,
    COUNT(*) FILTER (WHERE total_freight IS NULL) AS missing_total_freight,
    COUNT(*) FILTER (WHERE product_categories IS NULL) AS missing_product_categories,
    COUNT(*) FILTER (WHERE total_payment_value IS NULL) AS missing_payment_value
FROM public.ml_order_dataset;

SELECT COUNT(*) AS orders_without_items
FROM public.ml_order_dataset m
LEFT JOIN public.order_items_summary oi
    ON m.order_id = oi.order_id
WHERE oi.order_id IS NULL;

SELECT COUNT(*) AS orders_without_payment
FROM public.ml_order_dataset m
LEFT JOIN public.order_payment_summary op
    ON m.order_id = op.order_id
WHERE op.order_id IS NULL;

SELECT COUNT(*) AS orders_with_items_but_no_category
FROM public.ml_order_dataset m
JOIN public.order_items_summary oi
    ON m.order_id = oi.order_id
WHERE m.product_categories IS NULL;

CREATE TABLE public.ml_order_dataset_table AS
SELECT *
FROM public.ml_order_dataset;

SELECT COUNT(*)
FROM public.ml_order_dataset_table;