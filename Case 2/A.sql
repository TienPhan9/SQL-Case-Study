use pizza_runner

/*This case study has LOTS of questions - they are broken up by area of focus including:
Pizza Metrics
Runner and Customer Experience
Ingredient Optimisation
Pricing and Ratings
Bonus DML Challenges (DML = Data Manipulation Language)*/ 

--Preprocessing first

--table: customer_orders
--exclusions
update customer_orders
set exclusions = null
where exclusions = 'null' or exclusions = ''

--extras
update customer_orders
set extras = null
where extras = 'null' or extras = ''
select * from customer_orders
--table: runner_orders 
--cancellation
update runner_orders
set cancellation = null
where cancellation = '' or cancellation = 'null'

--A. Pizza Metrics

--How many pizzas were ordered?
select count(pizza_id) as number_pizzas from customer_orders

--How many unique customer orders were made?
select count(distinct order_id) as unique_orders from customer_orders

--How many successful orders were delivered by each runner?
select count(order_id) from runner_orders
where cancellation is null

--How many of each type of pizza was delivered?
select pizza_id, count(pizza_id) num_pizza_each_type from customer_orders c
right join runner_orders r on c.order_id = r.order_id
where cancellation is null
group by pizza_id

--How many Vegetarian and Meatlovers were ordered by each customer?
with cte as (
select customer_id, pizza_id, count(pizza_id) as pizza_count from customer_orders
group by customer_id, pizza_id)
select customer_id, pizza_name, pizza_count from cte 
inner join pizza_names on cte.pizza_id = pizza_names.pizza_id
order by customer_id

--What was the maximum number of pizzas delivered in a single order?
select max(pizza_count) from (
select c.order_id, count(pizza_id) as pizza_count from customer_orders c
inner join runner_orders r on c.order_id = r.order_id
where cancellation is null
group by c.order_id) temp

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select * from customer_orders c
inner join runner_orders r on c.order_id = r.order_id
where cancellation is null and (exclusions is not null or extras is not null)
group by customer_id

select * from customer_orders c
inner join runner_orders r on c.order_id = r.order_id
where cancellation is null and (exclusions is null and extras is null)




