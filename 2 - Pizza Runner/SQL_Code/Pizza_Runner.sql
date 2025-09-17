/*
CREATE SCHEMA pizza_runner;
GO
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  */


--select * from sys.tables


--update customer_orders SET exclusions = '' where exclusions = 'null';
--select * from customer_orders where exclusions = 'null';
--update customer_orders SET extras = '' where extras = 'null' or extras is null;
--select * from customer_orders where extras = 'null' or extras is null

--select * from runner_orders where pickup_time = 'null'
--update runner_orders SET pickup_time = '' where pickup_time = 'null'
--select * from runner_orders where distance = 'null'
--update runner_orders SET distance = '' where distance = 'null'
--select * from runner_orders where duration = 'null'
--update runner_orders SET duration = '' where duration = 'null'
--select * from runner_orders where cancellation = 'null' or cancellation is null
--update runner_orders SET cancellation = '' where cancellation = 'null' or cancellation is null
-----------------------------------------------------------------------------------------------------------

---> A. Pizza Metrics <---

--1.How many pizzas were ordered?
select count(order_id) as PizzaCount from customer_orders;

--2.How many unique customer orders were made?
Select count(distinct order_id) from customer_orders;

--3.How many successful orders were delivered by each runner?
select runner_id, count(order_id) as Successful_Orders_Count
from runner_orders
--where (cancellation not like '%Cancellation%' or cancellation is null)
where isnull(cancellation, '') not in ('Restaurant Cancellation', 'Customer Cancellation')
group by runner_id

select * from runner_orders
--4.How many of each type of pizza was delivered?

Select pizza_id, count(pizza_id) as PizzaCount
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id
and isnull(cancellation, '') not in ('Restaurant Cancellation', 'Customer Cancellation')
group by pizza_id

--5.How many Vegetarian and Meatlovers were ordered by each customer?

select customer_orders.customer_id, cast(pizza_names.pizza_name as nvarchar(20)), count(cast(pizza_names.pizza_name as nvarchar(20))) TotalCount
from customer_orders join pizza_names on customer_orders.pizza_id = pizza_names.pizza_id
group by cast(pizza_names.pizza_name as nvarchar(20)),customer_orders.customer_id;


--6.What was the maximum number of pizzas delivered in a single order?
with cust_cte as (
select customer_orders.order_id, count(customer_orders.pizza_id) pizzascount
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id
where isnull(cancellation, '') not in ('Restaurant Cancellation', 'Customer Cancellation')
group by customer_orders.order_id)

select cust_cte.order_id, cust_cte.pizzascount as MAXPizzas
from cust_cte where cust_cte.pizzascount = (select max(cust_cte.pizzascount) from cust_cte)


--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id, count(case when exclusions = '' and extras = '' then pizza_id end) as  No_Change, 
count(case when exclusions != '' or extras != '' then pizza_id end) as  Atleast_One_Change 
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id and runner_orders.duration != ''
group by customer_id


--8.How many pizzas were delivered that had both exclusions and extras?
select count(case when exclusions != '' and extras != '' then pizza_id end) as BothCount
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id and runner_orders.duration != ''


--9.What was the total volume of pizzas ordered for each hour of the day?
select datepart(hh,order_time) as Houroftheday, count(order_id) as TotalVolume from customer_orders
group by datepart(hh,order_time)

--10.What was the volume of orders for each day of the week?

select datepart(WEEKDAY,order_time) as Weekoftheday, count(order_id) as TotalVolume from customer_orders
group by datepart(WEEKDAY,order_time)

select * from customer_orders where DATEPART(dw, order_time) = 7

--------------------------------------------------------------------------------------------------------------------------------------

---> B. Runner and Customer Experience <---

--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
Select datepart(week,registration_date), count(registration_date) from runners group by datepart(week,registration_date)


--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id, AVG(DATEDIFF(minute, order_time, pickup_time)) as DIFF
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id and runner_orders.duration != ''
group by runner_id

select runner_id, round(AVG(cast(datepart(minute,pickup_time - order_time) as float)),1) AVGTime
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id and runner_orders.duration != ''
group by runner_id;

--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
with pizza_cte as (
select customer_orders.order_id, count(customer_orders.order_id) as PizzaCount, --round(AVG(cast(datepart(minute,pickup_time - order_time) as float)),1) as PrepTime
cast(datediff(minute,order_time,pickup_time) as float) as time_taken_per_order,
datediff(minute,order_time,pickup_time)/count(customer_orders.pizza_id) as time_taken_per_pizza
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id and runner_orders.duration !=''
group by customer_orders.order_id, customer_orders.order_time, runner_orders.pickup_time
)

Select pizza_cte.PizzaCount, avg(pizza_cte.time_taken_per_order) AvgtotalTime, avg(pizza_cte.time_taken_per_pizza) Avgtimetakenperpizza
from pizza_cte
group by pizza_cte.PizzaCount 

--4.What was the average distance travelled for each customer?

Select customer_id, round(avg(cast(Trim('kmKMKm' from distance) as float)),1) as AvgDistanceTravelled
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id and runner_orders.distance != ''
group by customer_id

Select customer_id, round(avg(cast(replace(lower(distance), 'km', '') as float)),1) as AvgDistanceTravelled
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id and runner_orders.distance != ''
group by customer_id

--5.What was the difference between the longest and shortest delivery times for all orders?

Select Max(cast(trim('minutes' from duration) as float)) - Min(cast(trim('minutes' from duration) as float)) as differencedelivery
from runner_orders 
where distance != ''

--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

Select runner_id, order_id, round(sum(cast(trim('kmKMKm' from distance) as float)/cast(trim('minutes' from duration) as float)*60),2) as Speed
from runner_orders
where distance != ''
group by runner_id, order_id
order by runner_id asc


--7.What is the successful delivery percentage for each runner?

Select runner_orders.runner_id ,count(customer_orders.order_id) as Total_orders , count(case when runner_orders.distance = '' then runner_orders.order_id end) as Incomplete_orders,
(count(customer_orders.order_id) - count(case when runner_orders.distance = '' then runner_orders.order_id end))/(cast(count(customer_orders.order_id) as float))*100
from customer_orders join runner_orders on customer_orders.order_id = runner_orders.order_id
group by runner_orders.runner_id;


select 1
--------------------------------------------------------------------------------------------------------------------------------------

-----> C. Ingredient Optimisation <---
--1.What are the standard ingredients for each pizza?

--Select pizza_id, topping_name
--from pizza_recipes pr join pizza_toppings pt on (select value from string_split(cast(toppings as varchar),',')) = pt.topping_id

with pizza_cte as(
Select pizza_id, value from pizza_recipes cross apply string_split(cast(toppings as nvarchar),',')
)

Select pizza_cte.pizza_id, STRING_AGG (cast(topping_name as varchar), ', ')   
from pizza_cte join pizza_toppings on pizza_cte.value = pizza_toppings.topping_id
group by pizza_cte.pizza_id;




--2.What was the most commonly added extra?

with extra_cte as(
Select trim(value) extra, count(value) extra_count, rank () over(order by count(value) desc) as Rankofextra 
from customer_orders cross apply string_split(extras, ',') where value != ''
group by trim(value))

Select topping_name
from pizza_toppings join extra_cte on pizza_toppings.topping_id = extra_cte.extra and extra_cte.Rankofextra = 1

--3.What was the most common exclusion?

with exclusion_cte as(
select trim(value) as exclusion, count(value) as exclusion_count, rank() over(order by count(value) desc) as Rankofexclusion
from customer_orders cross apply string_split(exclusions, ',') where value != ''
group by trim(value))

Select topping_name
from pizza_toppings join exclusion_cte on pizza_toppings.topping_id = exclusion_cte.exclusion and exclusion_cte.Rankofexclusion = 1

--4.Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef 3
--Meat Lovers - Extra Bacon 1
--Meat Lovers - Exclude Cheese 4, Bacon 1 - Extra Mushroom 6, Peppers 9


with custom_orders_cte as (
select co.order_id, co.pizza_id, cast(pn.pizza_name as varchar(30)) as pizza_name, co.exclusions, co.extras, ROW_NUMBER() over(order by co.order_id, co.pizza_id) as RN
from customer_orders co
join pizza_names pn on co.pizza_id = pn.pizza_id
)

, exc_cte as (
select STRING_AGG(cast(pt.topping_name as varchar),',')  as Exclusions_Name, co.RN
from custom_orders_cte co 
cross apply string_split(co.exclusions,',') exc 
--cross apply string_split(co.extras, ',') ex
left join pizza_toppings pt on trim(exc.value) = pt.topping_id --or trim(ex.value) = pt.topping_id
group by co.RN
)

, extra_cte as (
select STRING_AGG(cast(pt.topping_name as varchar),',')  as Extras_Name, co.RN
from custom_orders_cte co 
cross apply string_split(co.extras, ',') ex
left join pizza_toppings pt on trim(ex.value) = pt.topping_id
group by co.RN
)

Select c1.order_id, c1.pizza_id, c1.pizza_name, c1.exclusions, c1.extras,-- c2.Exclusions_Name, c3.Extras_Name,
c1.pizza_name + isnull(' - Exclude ' + c2.Exclusions_Name, '') + isnull(' - Extra ' + c3.Extras_Name, '') as OrderItems
from custom_orders_cte c1
left join exc_cte c2 on c1.RN = c2.RN
left join extra_cte c3 on c1.RN = c3.RN


--5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

with customer_orders_cte as(
select ROW_NUMBER() over (order by co.order_id, co.pizza_id) as RN, co.order_id, co.pizza_id, co.exclusions, cast(pn.pizza_name as varchar) as pizza_name, cast(pr.toppings as varchar) +',' + isnull(co.extras,'') as toppingswithextras
--,replace(cast(pr.toppings as varchar) +',' + isnull(co.extras,'') ,co.exclusions , '')as toppingswithextras
from customer_orders co join pizza_names pn on co.pizza_id = pn.pizza_id
join pizza_recipes pr on co.pizza_id = pr.pizza_id
)

,allextras_cte as (
select co.RN, co.order_id, co.pizza_name, trim(value) as extralist
from customer_orders_cte co cross apply string_split(trim(',' from co.toppingswithextras),',')
)

,exclusions_cte as(
select cocte.RN, cocte.order_id, trim(value) as exclusionlist
from customer_orders_cte cocte cross apply string_split(cocte.exclusions, ',')
where len(trim(value)) > 0 
)

, cte4 as(
Select rn, order_id , pizza_name, extralist, replace(cast(count(*) as varchar(30)) + 'X '+ cast(topping_name as varchar(30)), '1X ', '') as topping_name
--, string_agg(cast(pt.topping_name as varchar(40)),',') as all_toppings
from allextras_cte c2 
inner join pizza_toppings pt on pt.topping_id = extralist
where not exists ( select * from exclusions_cte c3 where c2.RN = c3.RN and c2.extralist = c3.exclusionlist)
group by RN, order_id , pizza_name, extralist, cast(topping_name as varchar(30))
)

Select cte4.RN, cte4.order_id, cte4.pizza_name + ': '+ STRING_AGG(cte4.topping_name, ', ') within group(order by cte4.topping_name) as IngList
from cte4 
group by cte4.rn, cte4.order_id,cte4.pizza_name;

--6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

with toppwithextras_cte as(
Select ROW_NUMBER() over (order by co.order_id, co.pizza_id) as RN,co.order_id, co.pizza_id, trim(',' from cast(pr.toppings as varchar(30))+','+ co.extras) as toppwithextras, co.exclusions
from runner_orders ro join customer_orders co on ro.order_id = co.order_id and ro.duration != ''
join pizza_recipes pr on co.pizza_id = pr.pizza_id
)

, ingwithextralist_cte as(
Select c1.RN, c1.order_id, c1.pizza_id, trim(value) as ingwithextralist
from toppwithextras_cte c1 cross apply string_split(c1.toppwithextras, ','))

,ingwithexcludelist_cte as(
Select c1.RN, c1.order_id, c1.pizza_id, trim(value) as ingwithexcludelist
from toppwithextras_cte c1 cross apply string_split(c1.exclusions, ',')
where len(trim(value)) > 0)
 
 Select cast(pt.topping_name as varchar(30)) as Ingredient, count(*) as counting
 from ingwithextralist_cte e1
 join pizza_toppings pt on pt.topping_id = e1.ingwithextralist
 where not exists (select * from ingwithexcludelist_cte e2 where e2.RN = e1.RN and e2.ingwithexcludelist = e1.ingwithextralist)
 group by cast(pt.topping_name as varchar(30))
 order by 2 desc
