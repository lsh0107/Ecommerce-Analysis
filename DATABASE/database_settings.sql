

CREATE DATABASE ma;

CREATE SCHEMA ma.raw_data;
CREATE SCHEMA ma.analytics;

--각각의 테이블 생성

CREATE OR REPLACE TABLE ma.raw_data.product_data(
    product_id varchar(50) primary key,
    product_category_name varchar(100),
    product_name_lenght int,
    product_description_lenght int,
    product_photos_qty int,
    product_weight_g int,
    product_length_cm int,
    product_height_cm int,
    product_width_cm int
);

CREATE OR REPLACE TABLE ma.raw_data.category_english(
    product_category_name varchar(100),
    product_category_name_english varchar(100)
);

CREATE OR REPLACE TABLE ma.raw_data.seller_data(
    seller_id varchar(50) primary key,
    seller_zip_code_prefix int,
    seller_city varchar(50),
    seller_state varchar(10)
);

CREATE OR REPLACE TABLE ma.raw_data.order_data(
    order_id varchar(50) primary key,
    customer_id varchar(50) unique,
    order_status varchar(20),
    order_purchase_timestamp timestamp,
    order_approved_at timestamp,
    order_delivered_carrier_date timestamp,
    order_delivered_customer_date timestamp,
    order_estimated_deliver_date timestamp
);

CREATE OR REPLACE TABLE ma.raw_data.customer_data(
    customer_id varchar(50) primary key,
    customer_unique_id varchar(50),
    customer_zip_code_prefix int,
    customer_city varchar(50),
    customer_state varchar(10)
);

CREATE OR REPLACE TABLE ma.raw_data.order_item_data(
    order_id varchar(50) primary key,
    order_item_id int,
    product_id varchar(50) unique,
    seller_id varchar(50) unique,
    shipping_limit_date timestamp,
    price float,
    freight_value float
);

CREATE OR REPLACE TABLE ma.raw_data.order_payment_data(
    order_id varchar(50) primary key,
    payment_sequential int,
    payment_type varchar(20),
    payment_installments int,
    payment_value float
);

CREATE OR REPLACE TABLE ma.raw_data.order_review_data(
    review_id varchar(50) primary key,
    order_id varchar(50) unique,
    review_score int,
    review_comment_title varchar(100),
    review_comment_message varchar(1000),
    review_creation_date timestamp,
    review_answer_timestamp timestamp
);

CREATE OR REPLACE TABLE ma.raw_data.geolocation_data(
    geolocation_zip_code_prefix int,
    geolocation_lat float,
    geolocation_lng float,
    geolocation_city varchar(50),
    geolocation_state varchar(10)
);

--S3에서 테이블로 벌크 업데이트 실행
--category_english, customer_data, order_data, order_item_data, order_payment_data, product_data, seller_data

COPY INTO ma.raw_data.product_data
FROM 's3://****/olist_products_dataset.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO ma.raw_data.category_english
FROM 's3://****/product_category_name_translation.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO ma.raw_data.customer_data
FROM 's3://****/olist_customers_dataset.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO ma.raw_data.order_data
FROM 's3://****/olist_orders_dataset.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO ma.raw_data.order_item_data
FROM 's3://****/olist_order_items_dataset.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO ma.raw_data.order_payment_data
FROM 's3://****/olist_order_payments_dataset.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO ma.raw_data.seller_data
FROM 's3://****/olist_sellers_dataset.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO ma.raw_data.order_review_data
FROM 's3://****/olist_order_reviews_dataset.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO ma.raw_data.geolocation_data
FROM 's3://****/olist_geolocation_dataset.csv'
credentials = (AWS_KEY_ID='****' AWS_SECRET_KEY='****+****')
FILE_FORMAT = (type = 'CSV' skip_header=1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
