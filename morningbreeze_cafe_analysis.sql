#Report and Analysis

# Q1 Coffee Consumers Count
# How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT city_name, population, cast(population *0.25 as signed) as population_consumes_cofee
FROM city
order by 2 desc;

# Q2 Total Revenue from Coffee Sales
# What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select ci.city_name, sum(s.total) as total_revenue_Q4_2023
from sales s
left join customers c
	on s.customer_id = c.customer_id
left join city ci
	on ci.city_id = c.city_id
where year(s.sale_date)=2023 and  quarter(s.sale_date)=4
group by ci.city_name
order by total_revenue_Q4_2023 desc;

# Q3 Sales Count for Each Product
# How many units of each coffee product have been sold?

select s.product_id, p.product_name, count(s.product_id) as item_sold
from sales s
left join products p
	on s.product_id = p.product_id
group by s.product_id, p.product_name
order by 3 desc;

# Q4 Average Sales Amount per City
# What is the average sales amount per customer in each city?

select ci.city_name, sum(total) as total_sale, count(distinct c.customer_id) as total_customer, round((sum(total)/count(distinct c.customer_id)),2) as average_sale_per_person_city
from sales s
left join customers c
	on s.customer_id = c.customer_id
left join city ci
	on ci.city_id = c.city_id
group by 1
order by 2 desc;

# Q5 City Population and Coffee Consumers
# Provide a list of cities along with their  estimated coffee consumers (25% of population) and unique customer 

with cte1 as
(select city_name, round((population*0.25),0) as coffee_consumer
from city),

cte2 as
(select ci.city_name, count(distinct c.customer_id) as unique_customers 
from sales s
left join customers c
	on s.customer_id = c.customer_id
left join city ci
	on ci.city_id = c.city_id
group by 1)

select c1.city_name, c1.coffee_consumer, c2.unique_customers
from cte1 as c1
left join cte2 as c2
	on c1.city_name = c2.city_name;
    
# Q6 Top Selling Products by City
# What are the top 3 selling products in each city based on sales volume?

with cte as
(select ci.city_name, p.product_name, count(sale_id) as total_sales,
	dense_rank()over(partition by ci.city_name order by count(s.sale_id) desc) as rnk
from sales s
left join products p
	on s.product_id =p.product_id
left join customers c
	on s.customer_id = c.customer_id
left join city ci
	on ci.city_id = c.city_id
group by 1,2 
order by 1,3 desc)

select city_name, product_name, total_sales
from cte
where rnk<=3;

# Q7 Customer Segmentation by City
# How many unique customers are there in each city who have purchased coffee products?
# coffee products are product_id 1-14

select ci.city_name, count(distinct s.customer_id) as unique_customer
from sales s 
left join products p
	on s.product_id =p.product_id
left join customers c
	on c.customer_id = s.customer_id
left join city ci
	on ci.city_id = c.city_id
where s.product_id <=14
group by 1;

# Q8 Average Sale vs Rent
# Find each city and their average sale per customer and avg rent per customer

with cte as
(select ci.city_name, sum(total) as total_sale, count(distinct c.customer_id) as total_customer, round((sum(total)/count(distinct c.customer_id)),2) as average_sale_per_person_city
from sales s
left join customers c
	on s.customer_id = c.customer_id
left join city ci
	on ci.city_id = c.city_id
group by 1
order by 2 desc),

cte2 as
(select city_name, estimated_rent
from city)

select 
	c2.city_name, estimated_rent, c1.total_customer, c1. average_sale_per_person_city,
	round((estimated_rent/c1. c1.total_customer),2)as avg_rent_per_customer
from cte2 c2
left join cte c1
	on c2.city_name = c1.city_name
order by 5 desc