-- create or replace table ma.analytics.active_inactive_purchase as
select A.customer_activity, B.payment_value
from customer_type_data A
join order_payment_data B on A.order_id=B.order_id


SELECT *
FROM customer_type_data
LIMIT 10;


-- 활성, 비활성 고객별 만족도
-- create or replace table ma.analytics.active_inactive_review as
select A.customer_activity, B.review_comment_message
from customer_type_data A
join order_review_data B on B.order_id=A.order_id
where A.customer_activity='inactive' and B.review_comment_message is not null


-- 활성, 비활성 고객별 만족도
-- create or replace table ma.analytics.active_inactive_score as
select A.customer_activity, 
B.review_score
from customer_type_data A
join order_review_data B on B.order_id=A.order_id


-- 고객종류 테이블 (마지막구매일,구매횟수,리뷰횟수,선호카테고리, 할인쿠폰)
-- 마지막 구매일이 5개월 이 넘는 고객을 대상으로 email 발송
-- 리뷰를 많이 쓰는 고객은 -30% 할인쿠폰
-- 리뷰를 안쓰면 -20% 쿠폰
-- 쿠폰은 가장 좋아하는 카테고리로 줌
-- 이메일주소 구매자 앞 4자리 +naver.com

-- 2016 9 4~ 2017 10 17


-- create or replace table customer_type_data as
-- 1. 고객별 마지막 구매일 추출
-- 2. 고객별 마지막 구매일 6개월 기준으로 비활성 고객 구분
with A as(
    select 
        customer_id,order_id,
        max(order_purchase_timestamp) AS last_purchase_timestamp,
        case when max(order_purchase_timestamp)<=
        DATEADD(month,-6,'2018-10-17') 
        then 'inactive' else 'active' END AS customer_activity
    from real_order_data
    group by customer_id,order_id
),

-- 분석위한 테이블 join
D as(
    select A.order_id, B.customer_id, A.last_purchase_timestamp, A.customer_activity,B.customer_state
    from customer_data B
    join A on A.customer_id=B.customer_id
),

-- 경영부서에서 받은 지역별 선호 카테고리 데이터 join
G as(
    select D.* ,F.product_category_name_english
    from STATE_PREFER_CATEGORY_SUMMARY F
    join D on D.customer_state=F.customer_state
),

-- 리뷰 쓰는사람과 안쓰는사람 구분
I as(
    select G.order_id,
        G.customer_id,
        G.last_purchase_timestamp,
        G.customer_activity,
        G.customer_state,
        G.product_category_name_english,
        case when count(H.review_comment_message) = 0 then false else true end as has_written_review
    from order_review_data H
    join G on G.order_id=H.order_id
    group by G.order_id,
        G.customer_id,
        G.last_purchase_timestamp,
        G.customer_activity,
        G.customer_state,
        G.product_category_name_english
),
J as(
    select distinct K.customer_unique_id,I.*
    from customer_data K
    join I on I.customer_id=K.customer_id
)
-- 리뷰를 많이 쓰는 고객은 -30% 할인쿠폰, 안쓰는 고객은 -20% 쿠폰, 
-- 이메일주소 unique_id 앞 4자리 +naver.com
select J.*,
    case when J.has_written_review =TRUE then -30 else -20 end as coupon,
    CONCAT(substring(J.customer_unique_id,1,6),'@naver.com') as email
from J;


-- create or replace table ma.analytics.DescriptionLength_Sales as
-- 제품당 사진갯수, product_data,order_item_data 합침
with C as(
    select A.product_id, order_id, product_description_lenght
    from product_data A
    inner join order_item_data B on A.product_id=B.product_id
    order by A.product_id
)

-- 제대로 주문된 오더위주로 좁힘, 글자수 300개 단위로 묶어 출력
select count(D.order_id) as sales, FLOOR(C.product_description_lenght / 60) * 60 AS description_length_range
from real_order_data D
inner join C on C.order_id=D.order_id
where C.product_description_lenght is not null
group by description_length_range
order by description_length_range desc;

drop table DescriptionLength_Sales;


-- 제품당 사진갯수, product_data,order_item_data 합침
with C as(
    select A.product_id, order_id, product_photos_qty
    from product_data A
    inner join order_item_data B on A.product_id=B.product_id
)

-- 제대로 주문된 오더위주로 좁힘
select count(D.order_id) as sales, C.product_photos_qty
from real_order_data D
inner join C on C.order_id=D.order_id
where C.product_photos_qty is not null
group by C.product_photos_qty
order by product_photos_qty desc;


-- create or replace table ma.analytics.review_sales_correlation as
-- 우선 판매량이 가장 많은 제품 추출
with best as(
    select count(product_id) as c_product_id ,product_id
    from order_item_data
    group by product_id
    order by c_product_id desc
    limit 1),

-- 그 제품의 리뷰내용 전부 추출
reviews as(
    select A.order_id, A.product_id
    from order_item_data A
    join best on A.product_id=best.product_id
    order by A.product_id
    )
    
-- 시간에 따른 리뷰내용과 판매량의 관계
select B.review_creation_date,
SUM(COUNT(B.order_id)) OVER (ORDER BY B.review_creation_date) AS c_sales_count,
SUM(COUNT(B.review_comment_message)) OVER (ORDER BY B.review_creation_date) AS c_review_count
from order_review_data B

join reviews on reviews.order_id=B.order_id
group by B.review_creation_date
order by B.review_creation_date;
