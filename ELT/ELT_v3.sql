-- CREATE TABLE ma.analytics.review_category_correlation AS

with delivery_time as(
    select order_id, 
    customer_id, datediff('day',order_purchase_timestamp,order_delivered_customer_date) as delivery_date
    from order_data
    where order_status = 'delivered'
), order_has_food as(
    select order_id
    from order_item_data
    where product_id in (
        select product_id
        from product_data
        where product_category_name in ('alimentos_bebidas', 'bebidas', 'la_cuisine', 'alimentos')
    )
)

-- //배송시간과 리뷰 점수 관계
-- select case when t1.delivery_date < 100 then ceil(t1.delivery_date/10)*10 else 100 end as delivery, 
-- count(t2.review_score) as order_volume, 
-- avg(t2.review_score) as avg_review_score
-- from delivery_time t1 join order_review_data t2
-- on t1.order_id = t2.order_id
-- group by delivery
-- order by delivery;

-- //신선 식품 배송시간과 리뷰 점수 관계
-- select case when t1.delivery_date < 100 then ceil(t1.delivery_date/5)*5 else 100 end as delivery, count(t2.review_score) as order_volume, 
-- avg(t2.review_score) as avg_review_score
-- from delivery_time t1 join order_review_data t2
-- on t1.order_id = t2.order_id
-- where t1.order_id in (
--     select order_id 
--     from order_has_food)
-- group by delivery
-- order by delivery;

-- //재구매 고객과 리뷰 점수간의 연관성 : 유의미한 결과 X
-- with order_cnt as(
--     select t1.customer_unique_id, 
--     t1.customer_id,
--     t2.order_id,
--     count(t2.order_id) over (partition by t1.customer_unique_id) as order_count
--     from customer_data t1 join order_data t2
--     on t1.customer_id=t2.customer_id
-- )

-- select 
-- t1.order_count,
-- avg(t2.review_score) as avg_review_score
-- from (
--     select distinct customer_unique_id,
--     customer_id,
--     order_count,
--     order_id
--     from order_cnt
-- ) t1 join order_review_data t2
-- on t1.order_id = t2.order_id
-- group by order_count;

//category별 리뷰점수
with product_category as(
    select o.order_id, o.product_id, p.product_category_name
    from order_item_data o join product_data p
    on o.product_id = p.product_id
)

select oc.product_category_name as product_category,
avg(r.review_score) as avg_review_score
from product_category oc join order_review_data r
on oc.order_id=r.order_id
group by oc.product_category_name
order by avg_review_score desc
limit 10;

-- //비행기 운임/상품가격과 리뷰점수 관계
-- select t2.review_score,avg(case t1.price when 0 then 0 else coalesce(t1.freight_value,0)/t1.price end) as qoutient
-- from order_item_data t1 join order_review_data t2
-- on t1.order_id=t2.order_id
-- group by t2.review_score
-- order by t2.review_score;

-- //비행기 운임과 리뷰점수 관계
-- select t2.review_score,avg(t1.freight_value)
-- from order_item_data t1 join order_review_data t2
-- on t1.order_id=t2.order_id
-- group by t2.review_score
-- order by t2.review_score;
