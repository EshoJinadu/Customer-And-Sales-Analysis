CREATE TABLE customer (
  customer_key     int,
  customer_id      int,
  customer_number  text,
  first_name       text,
  last_name        text,
  country          text,
  marital_status   text,
  gender           text,
  birthdate        date,
  create_date      date
);

select * from customer;

Create table products (
	product_key 	int,
	product_id		int,
	product_number 	text,
	product_name 	text,
	category_id 	text,
	category		text,
	subcategory		text,
	maintenance		text,
	cost 			int,
	product_line	text,
	start_date		date
);

select * from products;

create table sales (
	order_number	text,
	product_key		int,
	customer_key	int,
	order_date		date,
	shipping_date	date,
	due_date		date,
	sales_amount	int,
	quantity		int,
	price			int
	
);

select * from sales;

/* Task 1 Analyse sales performance overtime */

select * from sales;

select
extract(year from order_date) as order_year,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from sales
where order_date is not null
group by extract(year from order_date)
order by extract(year from order_date);

--- Task 2. Calculate the total sales per month 
---- and the running total cost of sales overtime

select 
order_date,
total_sales,
sum(total_sales) over (order by order_date) as running_total_sales,
round (avg(avg_price) over (order by order_date):: numeric,0) as average_moving_price
from 

(
select
extract (year from order_date) as order_date, 
sum(sales_amount) as total_sales,
Avg(price) as avg_price
from sales
where order_date is not null
group by extract (year from order_date)

)t;

--- Task 3. Analyse the yearly performance of each product by
--- comparing their sales to both the average sales performance of the product
---- and the previous year's sales.

with yearly_product_sales as 
(
select 
extract(year from s.order_date) as order_year,
p.product_name,
sum(s.sales_amount) as current_sales
from sales s
left join products p 
on s.product_key = p.product_key
where order_date is not null
group by extract(year from s.order_date),
p.product_name)

select 
order_year,
product_name,
current_sales, 
round(avg(current_sales) over (partition by product_name)::numeric,0) avg_sales,
current_sales - round(avg(current_sales) over (partition by product_name)::numeric,0) avg_difference,

case when current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above Avg'
	 when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below Avg'
	 Else 'Avg'
	 End Avg_change,
	 
--- year over year analysis

lag (current_sales) over (partition by product_name order by order_year) previous_year_sales,
current_sales - lag (current_sales) over (partition by product_name order by order_year)
as diff_previous_year_sales,

case when current_sales - lag (current_sales) over (partition by product_name order by order_year) > 0 then 'Increase'
	 when current_sales - lag (current_sales) over (partition by product_name order by order_year) < 0 then 'Decrease'
	 Else 'No Change'
	 End Previous_year_change
from yearly_product_sales
order by product_name, order_year;

--- Which category contribute the most to overall sales?

with category_sales as (
select
category,
sum(sales_amount) as total_sales
from sales f
left join products p on 
p.product_key = f.product_key
group by category
)
select
category,
total_sales,
sum(total_sales) over () overall_sales,
concat(round((cast(total_sales as numeric )/ sum(total_sales) over ()*100), 2), '%') as percentage_total
from category_sales
order by total_sales desc;

--- Segment products into cost ranges and 
--- count how many products fall into each segment

with product_segment as ( 
select 
product_key,
product_name,
cost,
case when cost < 100 then 'Below 100'
	 when cost between 100 and 500 then '100-500'
	 when cost between 500 and 1000 then '500-100'
	 else 'Above 100'
	 end cost_range
from products)

select
cost_range,
count(product_key) as total_products
from product_segment
group by cost_range
order by total_products desc;

/* Group customers into three segments based on their spending behaviour:
- VIP: Customers with at least 12 months of history and spending more than £5,000
- Regular: Customers with at least 12 months of history but spending £5,000 or less.
- New: Customers with a lifespan less than 12 months
And find the total number of customers by each group */


with customer_spending as (

select 
    c.customer_key,
    sum(s.sales_amount) as total_spending,
    min(order_date) as first_order,
    max(order_date) as last_order,
	(extract('year' from age(max(order_date), min(order_date))) * 12 ) +
    extract('month' from age(max(order_date), min(order_date))) as lifespan
from sales s
left join customer c
    on s.customer_key = c.customer_key
group by c.customer_key)

select
customer_segment,
count(customer_key) as total_customers
from (

select 
customer_key,
case when lifespan >= 12 and total_spending > 5000 then 'VIP_Member'
	 when lifespan >= 12 and total_spending <= 5000 then 'Regular_Member'
	 else 'New_Member'
end customer_segment
from customer_spending) t

group by customer_segment
order by total_customers desc;


/* ============================================================================================================================================
Objectives:
			
		--- This reports consolidates key customer metrics and behaviors

Hightlights: 
		1. Gather essential fields such as names, ages and transaction details.
		2. Segment customers into categories (VIP, Regular, New Member) and age group.
		3. Aggregates customer-level metrics:
			- total orders
			- total sales
			- total quantity purchased
			- total products
			- lifespan (in months)
		4. Calculates valuable KPIs:
			- recency (month since last order)
			- average order value
			- average monthly spend
 
================================================================================================================================================*/

With base_query as (
---------------------------------------------------------------
/* 1 Base query: Retrieve the core columns from query */
---------------------------------------------------------------
select 
s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as customer_name,
extract ('year' from age(c.birthdate)) as age
from sales s
left join customer c
on c.customer_key = s.customer_key
where order_date is not null 
),

customer_aggregation as ( 
/* -------------------------------------------------------------------
2 Customer Aggregations: Summarizes key metrics at the customer level
-----------------------------------------------------------------------*/
select 
	customer_key,
	customer_number,
	customer_name,
	age,
	count(distinct order_number) as total_orders,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity,
	count(distinct product_key) as total_products,
	max(order_date) as last_order_date,
	(extract('year' from age(max(order_date), min(order_date))) * 12 ) +
    extract('month' from age(max(order_date), min(order_date))) as lifespan
from base_query
group by
	customer_key,
	customer_number,
	customer_name,
	age 
	)

select 
customer_key,
customer_number,
customer_name,
age,
Case
	when age <20 then 'under 20'
	when age between 20 and 29 then '20-29'
	when age between 30 and 39 then '30-39'
	when age between 40 and 49 then '40-49'
	Else '50 and above'
End as Age_group,

Case 
	when lifespan >= 6 and total_sales > 5000 then 'VIP_Member'
	when lifespan >= 6 and total_sales < 5000 then 'Regular_Member'
	else 'New_Member'
end as customer_segment,
last_order_date,
round ((current_date - last_order_date)/30.44) as Recensy,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,

--- Compute Average Order Value (AVO)
Case when total_sales = 0 then 0
	else total_sales / total_orders
	end as Average_order_value,

--- Compute Average Monthly Spend
round
	(Case when lifespan = 0 then total_sales
	else total_sales / lifespan
	end, 0 ) as Average_Monthly_Spend
from customer_aggregation;