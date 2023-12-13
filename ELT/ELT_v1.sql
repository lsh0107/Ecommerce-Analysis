USE WAREHOUSE sanghyeok;


-- 매출이 가장 높은 카테고리 목록 

DROP TABLE IF EXISTS ma.analytics.revenue_summary;

CREATE TABLE ma.analytics.revenue_summary
AS
SELECT 
    joined_product.product_category_name_english as category_name,
    COUNT(DISTINCT joined_product.order_id) as num_product,
    SUM(joined_product.payment_value) as total_payment
FROM (
    SELECT oid.order_id, ce.product_category_name_english, opd.payment_value, od.order_status, od.order_delivered_customer_date 
    FROM ma.raw_data.product_data as pd
    JOIN ma.raw_data.category_english as ce ON pd.product_category_name = ce.product_category_name
    JOIN ma.raw_data.order_item_data as oid ON oid.product_id = pd.product_id
    JOIN ma.raw_data.order_data as od ON od.order_id = oid.order_id
    JOIN ma.raw_data.order_payment_data as opd ON opd.order_id = oid.order_id
) AS joined_product
WHERE 
    joined_product.order_status != 'canceled' and 
    joined_product.order_status != 'unavailable' and
    joined_product.order_delivered_customer_date IS NOT NULL
GROUP BY category_name 
ORDER BY total_payment DESC;

SELECT *
FROM ma.analytics.revenue_summary;



-- 많이 팔리는 가격대의 상품 개수 조회
DROP TABLE IF EXISTS ma.analytics.temp_product_price_range;

CREATE TABLE ma.analytics.temp_product_price_range AS
SELECT
    payment_group.price_group,
    LISTAGG(payment_group.product_category_name_english, ', ') WITHIN GROUP(ORDER BY payment_group.product_category_name_english) AS category_name,
    SUM(payment_group.num_orders) as num_orders
FROM (
    SELECT
        CEIL(opd.payment_value / 50) * 50 as price_group,
        -- CASE
        --     WHEN opd.payment_value >= 0 AND opd.payment_value < 50 THEN '0-49.99'
        --     WHEN opd.payment_value >= 50 AND opd.payment_value < 100 THEN '50-99.99'
        --     WHEN opd.payment_value >= 100 AND opd.payment_value < 150 THEN '100-149.99'
        --     WHEN opd.payment_value >= 150 AND opd.payment_value < 200 THEN '150-199.99'
        --     WHEN opd.payment_value >= 200 AND opd.payment_value < 250 THEN '200-249.99'
        --     WHEN opd.payment_value >= 250 AND opd.payment_value < 300 THEN '250-299.99'
        --     WHEN opd.payment_value >= 300 AND opd.payment_value < 350 THEN '300-349.99'
        --     WHEN opd.payment_value >= 350 AND opd.payment_value < 400 THEN '350-399.99'
        --     WHEN opd.payment_value >= 400 AND opd.payment_value < 450 THEN '400-449.99'
        --     WHEN opd.payment_value >= 450 AND opd.payment_value < 500 THEN '450-499.99'
        --     WHEN opd.payment_value >= 500 AND opd.payment_value < 1000 THEN '500-999.99'
        --     WHEN opd.payment_value >= 1000 AND opd.payment_value < 1500 THEN '1000-1499.99'
        --     WHEN opd.payment_value >= 1500 AND opd.payment_value < 2000 THEN '1500-1999.99'
        --     WHEN opd.payment_value >= 2000 AND opd.payment_value < 3000 THEN '2000-2999.99'
        --     WHEN opd.payment_value >= 3000 AND opd.payment_value < 4000 THEN '3000-3999.99'
        --     WHEN opd.payment_value >= 4000 AND opd.payment_value < 5000 THEN '4000-4999.99'
        --     ELSE '5000 and above'
        -- END AS price_group,
        ce.product_category_name_english,
        COUNT(DISTINCT opd.order_id) AS num_orders
    FROM ma.raw_data.order_payment_data opd
    JOIN ma.raw_data.order_item_data oid ON opd.order_id = oid.order_id
    JOIN ma.raw_data.product_data pd ON pd.product_id = oid.product_id
    JOIN ma.raw_data.order_data as od ON od.order_id = oid.order_id
    JOIN ma.raw_data.category_english ce ON pd.product_category_name = ce.product_category_name
    WHERE
        od.order_status != 'canceled' AND 
        od.order_status != 'unavailable' AND
        od.order_delivered_customer_date IS NOT NULL
    GROUP BY price_group, ce.product_category_name_english, od.order_status
) AS payment_group

GROUP BY payment_group.price_group
ORDER BY payment_group.price_group;

SELECT *
FROM ma.analytics.temp_product_price_range;

--카테고리이름, 금액, 판매개수
--필요한 테이블: category_english, product_data, payment_data, order_item_data
--조인: category_english <-> product_data on product_category_name
--     product_data <-> order_item_data on product_id
--     order_item_data <-> payment_data on order_id
--     order_data <-> order_item_data on order_id

WITH joined_data AS(
    SELECT 
        ce.product_category_name_english,
        opd.payment_value,
        oid.order_id,
        od.order_status,
        od.order_delivered_customer_date
    FROM ma.raw_data.product_data AS pd
    JOIN ma.raw_data.category_english AS ce ON ce.product_category_name = pd.product_category_name
    JOIN ma.raw_data.order_item_data AS oid ON oid.product_id = pd.product_id
    JOIN ma.raw_data.order_payment_data AS opd ON opd.order_id = oid.order_id
    JOIN ma.raw_data.order_data AS od ON od.order_id = oid.order_id
)

SELECT
    joined_data.product_category_name_english AS category_name,
    COUNT(joined_data.order_id) AS num_products,
    SUM(joined_data.payment_value) AS total_price
FROM joined_data
WHERE
    joined_data.order_status != 'canceled' AND 
    joined_data.order_status != 'unavailable' AND
    joined_data.order_delivered_customer_date IS NOT NULL AND
    joined_data.payment_value > 0 AND 
    joined_data.payment_value <= 500
    
GROUP BY category_name
ORDER BY num_products DESC;




--할부개월 수 보고 무이자 할부 판단

DROP TABLE IF EXISTS ma.analytics.installment_summary;

CREATE TABLE ma.analytics.installment_summary AS
WITH joined_data AS(
    SELECT 
        ce.product_category_name_english,
        opd.payment_value,
        oid.order_id,
        od.order_status,
        od.order_delivered_customer_date,
        opd.payment_installments,
        opd.payment_sequential,
        opd.payment_type
    FROM ma.raw_data.product_data AS pd
    JOIN ma.raw_data.category_english AS ce ON ce.product_category_name = pd.product_category_name
    JOIN ma.raw_data.order_item_data AS oid ON oid.product_id = pd.product_id
    JOIN ma.raw_data.order_payment_data AS opd ON opd.order_id = oid.order_id
    JOIN ma.raw_data.order_data AS od ON od.order_id = oid.order_id
)
SELECT
    joined_data.product_category_name_english AS category_name,
    -- joined_data.payment_value,
    -- joined_data.payment_type,
    ROUND(AVG(joined_data.payment_installments),1) AS installments_avg
FROM joined_data
WHERE
    joined_data.order_status != 'canceled' AND 
    joined_data.order_status != 'unavailable' AND
    joined_data.payment_type = 'credit_card'
GROUP BY 1;

SELECT *
FROM ma.analytics.installment_summary;

