-- 물류부 (1~5)

-- ********************** 
-- 1. fr_value_sales
-- : 물류 비용(freight_value)와 판매량(sales) 간의 관계
-- : 물류 비용 구간별 판매량 확인
-- : bar chart (X-axis: fr_value_section - Bar: sales)

DROP TABLE IF EXISTS ma.analytics.fr_value_sales;

CREATE TABLE ma.analytics.fr_value_sales AS
  SELECT CASE
      WHEN freight_value >= 0 and freight_value < 10 THEN '0~9'
      WHEN freight_value >= 10 and freight_value < 20 THEN '10~19'
      WHEN freight_value >= 20 and freight_value < 30 THEN '20~29'
      WHEN freight_value >= 30 and freight_value < 40 THEN '30~39'
      WHEN freight_value >= 40 and freight_value < 50 THEN '40~49'
      WHEN freight_value >= 50 and freight_value < 60 THEN '50~59'
      WHEN freight_value >= 60 and freight_value < 70 THEN '60~69'
      WHEN freight_value >= 70 and freight_value < 80 THEN '70~79'
      WHEN freight_value >= 80 and freight_value < 90 THEN '80~89'
      WHEN freight_value >= 90 and freight_value < 100 THEN '90~99'
      ELSE '100~'
    END AS fr_value_section,
    COUNT(*) as sales
  FROM real_order_data a JOIN order_item_data b ON a.order_id = b.order_id
  GROUP BY 1
  ORDER BY CASE
      WHEN fr_value_section = '0~9' THEN 0
      WHEN fr_value_section = '10~19' THEN 1
      WHEN fr_value_section = '20~29' THEN 2
      WHEN fr_value_section = '30~39' THEN 3
      WHEN fr_value_section = '40~49' THEN 4
      WHEN fr_value_section = '50~59' THEN 5
      WHEN fr_value_section = '60~69' THEN 6
      WHEN fr_value_section = '70~79' THEN 7
      WHEN fr_value_section = '80~89' THEN 8
      WHEN fr_value_section = '90~99' THEN 9
      ELSE 10
    END ASC
;


-- (1 테이블 확인)
-- SELECT CASE
--       WHEN freight_value >= 0 and freight_value < 10 THEN '0~9'
--       WHEN freight_value >= 10 and freight_value < 20 THEN '10~19'
--       WHEN freight_value >= 20 and freight_value < 30 THEN '20~29'
--       WHEN freight_value >= 30 and freight_value < 40 THEN '30~39'
--       WHEN freight_value >= 40 and freight_value < 50 THEN '40~49'
--       WHEN freight_value >= 50 and freight_value < 60 THEN '50~59'
--       WHEN freight_value >= 60 and freight_value < 70 THEN '60~69'
--       WHEN freight_value >= 70 and freight_value < 80 THEN '70~79'
--       WHEN freight_value >= 80 and freight_value < 90 THEN '80~89'
--       WHEN freight_value >= 90 and freight_value < 100 THEN '90~99'
--       ELSE '100~'
--     END AS fr_value_section,
--     COUNT(*) as sales
--   FROM real_order_data a JOIN order_item_data b ON a.order_id = b.order_id
--   GROUP BY 1
--   ORDER BY CASE
--       WHEN fr_value_section = '0~9' THEN 0
--       WHEN fr_value_section = '10~19' THEN 1
--       WHEN fr_value_section = '20~29' THEN 2
--       WHEN fr_value_section = '30~39' THEN 3
--       WHEN fr_value_section = '40~49' THEN 4
--       WHEN fr_value_section = '50~59' THEN 5
--       WHEN fr_value_section = '60~69' THEN 6
--       WHEN fr_value_section = '70~79' THEN 7
--       WHEN fr_value_section = '80~89' THEN 8
--       WHEN fr_value_section = '90~99' THEN 9
--       ELSE 10
--     END ASC
-- ;
-- ********************** 


-- ********************** 
-- 2. fr_value_weight
-- : 물류 비용(freight_value)와 상품 무개(product_wegiht_g) 간의 관계
-- : 상품 무게 구간별 평균 물류 비용 확인
-- : 구간 선정 기준 = 택배사 택배 무게별 운임 기준 참고 (극소형/소형/중형/대형/특대형 5가지 구간)
-- : bar chart (X-axis: weight_section - Bar: avg_fr_value)

DROP TABLE IF EXISTS ma.analytics.fr_value_weight;

CREATE TABLE ma.analytics.fr_value_weight AS
    SELECT CASE
            WHEN ROUND(c.product_weight_g) > 0 and ROUND(c.product_weight_g) <= 2000 THEN '1_극소형'
            WHEN ROUND(c.product_weight_g) > 2000 and ROUND(c.product_weight_g) <= 5000 THEN '2_소형'
            WHEN ROUND(c.product_weight_g) > 5000 and ROUND(c.product_weight_g) <= 10000 THEN '3_중형'
            WHEN ROUND(c.product_weight_g) > 10000 and ROUND(c.product_weight_g) <= 15000 THEN '4_대형'
            WHEN ROUND(c.product_weight_g) > 15000 THEN '5_특대형'
        END AS weight_section,
        AVG(b.freight_value) as avg_fr_value
    FROM real_order_data a JOIN order_item_data b ON a.order_id = b.order_id
        LEFT JOIN product_data c ON b.product_id = c.product_id
    WHERE c.product_weight_g > 0
    GROUP BY weight_section
    ORDER BY CASE
        WHEN weight_section = '1_극소형' THEN 0
        WHEN weight_section = '2_소형' THEN 1
        WHEN weight_section = '3_중형' THEN 2
        WHEN weight_section = '4_대형' THEN 3
        WHEN weight_section = '5_특대형' THEN 4
    END ASC
;


-- (2. 테이블 확인)
SELECT CASE
        WHEN ROUND(c.product_weight_g) > 0 and ROUND(c.product_weight_g) <= 2000 THEN '1_극소형'
        WHEN ROUND(c.product_weight_g) > 2000 and ROUND(c.product_weight_g) <= 5000 THEN '2_소형'
        WHEN ROUND(c.product_weight_g) > 5000 and ROUND(c.product_weight_g) <= 10000 THEN '3_중형'
        WHEN ROUND(c.product_weight_g) > 10000 and ROUND(c.product_weight_g) <= 15000 THEN '4_대형'
        WHEN ROUND(c.product_weight_g) > 15000 THEN '5_특대형'
    END AS weight_section,
    AVG(b.freight_value) as avg_fr_value
FROM real_order_data a JOIN order_item_data b ON a.order_id = b.order_id
    LEFT JOIN product_data c ON b.product_id = c.product_id
WHERE c.product_weight_g > 0
GROUP BY weight_section
ORDER BY CASE
        WHEN weight_section = '1_극소형' THEN 0
        WHEN weight_section = '2_소형' THEN 1
        WHEN weight_section = '3_중형' THEN 2
        WHEN weight_section = '4_대형' THEN 3
        WHEN weight_section = '5_특대형' THEN 4
    END ASC
;
-- ********************** 


-- ********************** 
-- 3. state_avg_fr_value
-- : 구매자 지역(customer_state)과 물류 비용(freight_value)간의 관계
-- : 지역별 평균 배송비 확인
-- : bar chart (X-axis: customer_state - Bar: avg_fr_value)

DROP TABLE IF EXISTS ma.analytics.state_avg_fr_value;

CREATE TABLE ma.analytics.state_avg_fr_value AS
    SELECT customer_state,
        AVG(freight_value) as avg_fr_value
    FROM customer_data c JOIN real_order_data o ON c.customer_id = o.customer_id
        JOIN order_item_data i ON o.order_id = i.order_id
    GROUP BY customer_state
    ORDER BY avg_fr_value DESC
;

-- (3. 테이블 확인)
-- SELECT customer_state,
--     AVG(freight_value) as avg_fr_value
-- FROM customer_data c JOIN real_order_data o ON c.customer_id = o.customer_id
--     JOIN order_item_data i ON o.order_id = i.order_id
-- GROUP BY customer_state
-- ORDER BY avg_fr_value DESC;
-- ********************** 


-- ********************** 
-- 4. state_prefer_category
-- : 구매자 지역(customer_state)과 상품 카테고리(product_category_name)간의 관계
-- : 판매량 기반 지역별 상위 3개의 선호 카테고리 확인
-- : bar chart (X-axis: customer_state - Bar: avg_fr_value)

DROP TABLE IF EXISTS ma.analytics.state_prefer_category;

CREATE TABLE ma.analytics.state_prefer_category AS
    SELECT *
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_state ORDER BY prefer DESC) AS RankNo
        FROM (
            SELECT c.customer_state,
                    t.product_category_name_english,
                    COUNT(*) as prefer
            FROM order_item_data i JOIN product_data p ON i.product_id = p.product_id
              JOIN real_order_data o ON i.order_id = o.order_id
              JOIN customer_data c ON o.customer_id = c.customer_id
              LEFT JOIN category_english t ON p.product_category_name = t.product_category_name
            GROUP BY 1, 2
        )
    )
    WHERE RankNo <= 3
;

-- (4. 테이블 확인)
-- SELECT *
-- FROM (
--     SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_state ORDER BY prefer DESC) AS RankNo
--     FROM (
--         SELECT c.customer_state,
--                 t.product_category_name_english,
--                 COUNT(*) as prefer
--         FROM order_item_data i JOIN product_data p ON i.product_id = p.product_id
--           JOIN real_order_data o ON i.order_id = o.order_id
--           JOIN customer_data c ON o.customer_id = c.customer_id
--           LEFT JOIN category_english t ON p.product_category_name = t.product_category_name
--         GROUP BY 1, 2
--     )
-- )
-- WHERE RankNo <= 3
-- ;
-- ********************** 


-- ********************** 
-- 5. customer_type_avg_arival
-- : 고객 타입(활성/비활성)과 물류 도착시간(avg_arival)의 관계
-- : 활성/비활성 고객 분류에 평균 물류 도착시간이 미친 영향 파악
-- : bar chart (X-axis: customer_activity - Bar: avg_arival)
DROP TABLE IF EXISTS ma.analytics.customer_type_avg_arival;

CREATE TABLE ma.analytics.customer_type_avg_arival AS
    SELECT a.customer_activity,
    AVG(DATEDIFF('day', b.order_delivered_carrier_date, b.order_delivered_customer_date)) as avg_arival
    FROM ma.analytics.customer_type_data a JOIN real_order_data b ON a.customer_id = b.customer_id
    GROUP BY a.customer_activity
;


-- (5. 테이블 확인)
-- SELECT *
-- FROM ma.analytics.customer_type_data;

SELECT a.customer_activity,
    AVG(DATEDIFF('day', b.order_delivered_carrier_date, b.order_delivered_customer_date)) as avg_arival
FROM ma.analytics.customer_type_data a JOIN real_order_data b ON a.customer_id = b.customer_id
GROUP BY a.customer_activity;



-- 경영지원팀 (6)
-- 6. state_prefer_category_summary
-- : 지역(customer_state)별 선호 상품 카테고리(product_category_name)의 공급 현황
-- : 지역별 선호 카테고리(판매량 top 1)의 주문 건수 및 판매자 수 확인
-- : bar chart (X-axis: customer_state - Bar: sales, sellers_amount)
DROP TABLE IF EXISTS ma.analytics.state_prefer_category_summary;

CREATE TABLE ma.analytics.state_prefer_category_summary AS
    SELECT d.customer_state,
            d.product_category_name_english,
            COUNT(a.order_id) as sales,
            COUNT(DISTINCT(c.seller_id)) as sellers_amount
    FROM order_item_data a JOIN real_order_data b ON a.order_id = b.order_id
        JOIN seller_data c ON a.seller_id = c.seller_id
        LEFT JOIN ma.analytics.state_prefer_category d ON c.seller_state = d.customer_state
    WHERE d.rankno=1
    GROUP BY 1, 2;


-- (6. 테이블 확인)
-- 필요한 테이블: real_order JOIN order_item(주문 건수), 물류부 ELT 테이블(선호도 상위 1위 카테고리), seller(판매자 수), 
-- SELECT d.customer_state,
--         d.product_category_name_english,
--         COUNT(a.order_id) as sales, -- 주문 건수
--         COUNT(DISTINCT(c.seller_id)) as sellers_amount -- 판매자 수
-- FROM order_item_data a JOIN real_order_data b ON a.order_id = b.order_id
--     JOIN seller_data c ON a.seller_id = c.seller_id
--     LEFT JOIN ma.analytics.state_prefer_category d ON c.seller_state = d.customer_state
-- WHERE d.rankno=1
-- GROUP BY 1, 2
-- ;

