use pizza_runner

/*B. Runner and Customer Experience
How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Is there any relationship between the number of pizzas and how long the order takes to prepare?
What was the average distance travelled for each customer?
What was the difference between the longest and shortest delivery times for all orders?
What was the average speed for each runner for each delivery and do you notice any trend for these values?
What is the successful delivery percentage for each runner?*/

--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
with cte as (
SELECT 
	runner_id,
	registration_date, 
	datediff(day, min(registration_date) OVER (ORDER BY runner_id), registration_date) AS days_differ
FROM runners)
select week_differ, count(week_differ) as count_of_runners from (
select runner_id, 
registration_date, 
datediff(week, min(days_differ) OVER (ORDER BY runner_id), days_differ)+1 AS week_differ
from cte) temp
group by week_differ

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
with cte as (
select runner_id, duration, 
cast(iif(b=0, substring(duration, 1, len(duration)),substring(duration, 1, b-1)) as int) as time
from (select runner_id, duration, patindex('%[a-z]%',duration) as b from runner_orders
		where cancellation is null) temp)
select runner_id, sum(time) / count(runner_id) from cte
group by runner_id

--Is there any relationship between the number of pizzas and how long the order takes to prepare?
--preprocess
update runner_orders
set pickup_time = null
where pickup_time = 'null'
update runner_orders
set duration = null
where duration = 'null'
update runner_orders
set distance = null
where distance = 'null'
----------
with cte as (
select c.order_id, pizza_id, order_time, pickup_time, 
datediff(minute, order_time, cast(pickup_time as datetime)) as preparation_time
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where cancellation is null)
select order_id, preparation_time, count(order_id) from cte
group by order_id, preparation_time
order by preparation_time
/*=> conclusion: there is a relationship between the number of pizzas, but some cases do not have the relationship (just
relied on the speed of runners (my opinion)*/

--What was the average distance travelled for each customer?
with cte as (
select customer_id, distance,  
patindex('%[a-z]%', distance) as indexing
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where cancellation is null)
select customer_id, 
round(avg(cast(iif(indexing=0, distance, left(distance, patindex('%[a-z]%', distance)-1)) as float)),2) from cte
group by customer_id

--What was the difference between the longest and shortest delivery times for all orders?
with cte as (
select duration,  
patindex('%[a-z]%', duration) as indexing
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where cancellation is null)
select 
max(cast(iif(indexing=0, duration, left(duration, patindex('%[a-z]%', duration)-1)) as float))
- min(cast(iif(indexing=0, duration, left(duration, patindex('%[a-z]%', duration)-1)) as float))
from cte

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
with cte as (
select runner_id, order_id,
cast(iif(patindex('%[a-z]%', distance)=0, distance, left(distance, patindex('%[a-z]%', distance)-1)) as float) as distance, 
cast(iif(patindex('%[a-z]%', duration)=0, duration, left(duration, patindex('%[a-z]%', duration)-1)) as float) as duration
from runner_orders
where cancellation is null)
select runner_id, order_id, round(avg(distance / duration),2) as avg_speed from cte
group by runner_id, order_id

--What is the successful delivery percentage for each runner?

select target.runner_id, concat(cast((cast(total_actual as float) / cast(total_estimated as float)) * 100 as nvarchar),'%') as successful_percentage from (
(select runner_id, count(order_id) as total_estimated from runner_orders
group by runner_id) as target inner join

(select runner_id, count(order_id) as total_actual from runner_orders
where cancellation is null
group by runner_id) as actual
on target.runner_id = actual.runner_id)









