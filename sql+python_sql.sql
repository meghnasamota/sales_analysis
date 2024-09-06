show databases;
create database orders_database;
use orders_database;

create table df_orders(
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(30),      
country varchar(15),
city varchar(20),
state varchar(20),
postal_code  varchar(10),
region varchar(10),
category varchar(20),
sub_category  varchar(20),
product_id varchar(20),
quantity int,
discount decimal(7,2),
sales_price decimal(7,2),
profit decimal(7,2));

select * from df_orders; 
drop table df_orders; 

#top 10 highest revenue generating product
select product_id,sum(sales_price*quantity) as sp
from df_orders
group by product_id
order by sp desc
limit 10;

#find top 5 highest selling product in each region
with rank_table as(
select region,product_id,sum(sales_price) as total_sales,
dense_rank() over(partition by region order by sum(sales_price) desc) as sp
from df_orders
group by region,product_id
) 
select region,product_id,total_sales,sp
from rank_table
where sp<=5
;

#find month over month growth comparison for 2022 and 2023 sales,eg:jan 2022 vs jan 2023
with comparison as( 
select substring(order_date,1,4) as order_year,
substring(order_date,6,2) as order_month,sum(sales_price) as sp
from df_orders
group by order_year,order_month
order by order_month,order_year asc)
select order_month,
sum(case when order_year=2022 then sp else 0 end ) as year_2022,
sum(case when order_year=2023 then sp else 0 end) as year_2023
from comparison
group by order_month
order by order_month;


#for each category which month has highest sales
with cte as(
select category,substring(order_date,6,2) as order_month ,max(sales_price) as highest_sales,
rank() over(partition by category order by max(sales_price)  desc) as category1
from df_orders
group by category,order_month)
select category,order_month,highest_sales
from cte
where category1<=1;

#which sub category had highest growth by profit in 2023 compare to 2022
with cte as(
select sub_category ,sum(sales_price) as sum_sales,substring(order_date,1,4) as order_year
from df_orders
group by sub_category,order_year),
cte1 as (
select sub_category,
sum(case when order_year=2022 then sum_sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sum_sales else 0 end) as sales_2023
from cte
group by sub_category)
select  sub_category,sales_2022,sales_2023,(sales_2023-sales_2022)*100/sales_2022 as profit
from cte1
order by profit desc
;

