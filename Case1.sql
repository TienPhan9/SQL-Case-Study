--What is the total amount each customer spent at the restaurant?
use dannys_dinner

select customer_id, sum(price) from sales
inner join menu on sales.product_id = menu.product_id
group by sales.customer_id

--How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as days_visited from sales
group by customer_id

--What was the first item from the menu purchased by each customer?
with cte as (
select *, dense_rank () over (partition by customer_id order by product_id) denserank from sales
where order_date = (select min(order_date) from sales))
select customer_id, product_id, count(denserank) from cte
where denserank >= 1
group by customer_id, product_id

--What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 product_id, count(product_id) as times_order from sales
group by product_id
order by count(product_id) desc

--Which item was the most popular for each customer?
with cte_1 as (
select customer_id, max(count_product) as max_count_each from (
select customer_id, product_id, count(product_id) as count_product from sales
group by customer_id, product_id) temp
group by customer_id),
cte_2 as (
select customer_id, product_id, count(product_id) as count_product from sales
group by customer_id, product_id)
select cte_1.customer_id, product_id, count_product 
from cte_1 inner join cte_2 on cte_1.customer_id = cte_2.customer_id
where max_count_each = count_product
order by cte_1.customer_id

--Which item was purchased first by the customer after they became a member?
with cte as (
select sales.customer_id, min(order_date) as min_date from sales
inner join members on sales.customer_id = members.customer_id
where order_date > join_date
group by sales.customer_id)
select sales.customer_id, product_id, order_date from sales
inner join cte on sales.customer_id = cte.customer_id
where min_date = order_date

--Which item was purchased just before the customer became a member?
with cte as (
select sales.customer_id, max(order_date) as max_date from sales
inner join members on sales.customer_id = members.customer_id
where order_date < join_date
group by sales.customer_id)
select sales.customer_id, product_id, order_date from sales
inner join cte on sales.customer_id = cte.customer_id
where max_date = order_date

--What is the total items and amount spent for each member before they became a member?
select sales.customer_id, count(sales.product_id) as total_items, sum(price) as amount from sales 
					inner join members on sales.customer_id = members.customer_id
					inner join menu on sales.product_id = menu.product_id
where order_date < join_date
group by sales.customer_id

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
--how many points would each customer have?
with cte as (
select sales.customer_id, sales.product_id, product_name, price, 
iif(product_name = 'sushi', price * 20, price * 10) as points
from sales inner join menu on sales.product_id = menu.product_id)
select customer_id, sum(points) as points from cte
group by customer_id

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January?
with cte as (
select customer_id, sum(points) as total_points from 
(
	select sales.customer_id, price * 20 as points from sales
	inner join members on sales.customer_id = members.customer_id
	inner join menu on sales.product_id = menu.product_id
	where datediff(day, join_date, order_date) between 0 and 7
) temp_1
group by customer_id
union all
select customer_id, sum(points) as total_points from 
(select sales.customer_id, iif(product_name = 'sushi', price * 20, price * 10) as points from sales
inner join members on sales.customer_id = members.customer_id
inner join menu on sales.product_id = menu.product_id
where datediff(day, join_date, order_date) < 0) temp_2
group by customer_id)

select customer_id, sum(total_points) as total_points from cte
group by customer_id




