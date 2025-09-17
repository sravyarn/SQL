/*

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

*/



--1.What is the total amount each customer spent at the restaurant?
Select customer_id as 'Customer', sum(price) as 'Total Amount'
from sales join menu on sales.product_id = menu.product_id
group by customer_id

--2.How many days has each customer visited the restaurant?
Select customer_id as 'Customer', count(distinct order_date) as 'Count'
from sales
group by customer_id

--3.What was the first item from the menu purchased by each customer?
/*Select customer_id as 'Customer',order_date, product_id, DENSE_RANK () over ( partition by customer_id order by order_date asc) as Rank
from sales */

with sales_cte as(
Select customer_id as 'Customer', min(order_date) as firstorderdate
from sales
group by customer_id)

select sales_cte.customer, sales.product_id, menu.product_name
from sales_cte join sales on sales_cte.customer = sales.customer_id and sales_cte.firstorderdate = sales.order_date
join menu on sales.product_id = menu.product_id

--4.What is the most purchased item on the menu and how many times was it purchased by all customers?

with sales_cte as(
Select product_name, count(sales.product_id) most_purchased 
from sales join menu on sales.product_id = menu.product_id group by product_name) 

select * from sales_cte where most_purchased = (select max(most_purchased) from sales_cte)


--5.Which item was the most popular for each customer?

with sales_cte as(
select customer_id, product_id, count(product_id) productcount
from sales group by customer_id, product_id
--order by customer_id asc
), cte2 as (

Select *, RANK () over (
partition by customer_id order by productcount desc) as productrank from sales_cte)

select customer_id, product_id from cte2 where productrank = 1

--6.Which item was purchased first by the customer after they became a member?
with sales_cte as(
Select sales.customer_id, order_date, product_id, RANK() over(partition by sales.customer_id order by order_date asc) as daterank
from sales 
join members on sales.customer_id = members.customer_id and sales.order_date >= members.join_date)

select sales_cte.customer_id, menu.product_name from sales_cte join menu on sales_cte.product_id = menu.product_id where daterank = 1

--7.Which item was purchased just before the customer became a member?
with sales_cte as(
Select sales.customer_id, order_date, product_id, RANK() over(partition by sales.customer_id order by order_date desc) as daterank
from sales join members on sales.customer_id = members.customer_id and sales.order_date < members.join_date)

select sales_cte.customer_id, menu.product_name , order_date from sales_cte join menu on sales_cte.product_id = menu.product_id where daterank = 1


--8.What is the total items and amount spent for each member before they became a member?
Select sales.customer_id, count(sales.product_id) as 'Total items', sum(menu.price) as 'Amount spent'
from sales join members on sales.customer_id = members.customer_id and sales.order_date < members.join_date 
join menu on sales.product_id = menu.product_id
group by sales.customer_id

--9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select sales.customer_id, --sales.product_id, menu.product_name, menu.price, 
sum(case when menu.product_name = 'sushi' then menu.price*2*10
else menu.price*10 
end) as Points
from sales join menu on sales.product_id = menu.product_id
group by sales.customer_id

--10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--not just sushi - how many points do customer A and B have at the end of January?
select sales.customer_id, sum(case 
when sales.order_date between members.join_date and dateadd(day, 7, members.join_date) then menu.price*2*10
when sales.order_date > members.join_date or sales.order_date < members.join_date and menu.product_name = 'sushi' then menu.price*2*10
else menu.price*10
end)as Points
from sales 
join members on sales.customer_id = members.customer_id  
join menu on sales.product_id = menu.product_id
where sales.order_date <= '2021-01-31'--EOMONTH(
group by sales.customer_id

----------------
/*
customer_id	order_date	product_name	price	member
A	2021-01-01	curry	15	N
A	2021-01-01	sushi	10	N
A	2021-01-07	curry	15	Y
A	2021-01-10	ramen	12	Y
A	2021-01-11	ramen	12	Y
A	2021-01-11	ramen	12	Y
B	2021-01-01	curry	15	N
B	2021-01-02	curry	15	N
B	2021-01-04	sushi	10	N
B	2021-01-11	sushi	10	Y
B	2021-01-16	ramen	12	Y
B	2021-02-01	ramen	12	Y
C	2021-01-01	ramen	12	N
C	2021-01-01	ramen	12	N
C	2021-01-07	ramen	12	N
*/

Select sales.customer_id, sales.order_date, menu.product_name, menu.price, 
case when sales.order_date >= members.join_date then 'Y' else 'N' end as member
from sales join menu on sales.product_id = menu.product_id left join members on sales.customer_id = members.customer_id

/*
customer_id	order_date	product_name	price	member	ranking
A	2021-01-01	curry	15	N	null
A	2021-01-01	sushi	10	N	null
A	2021-01-07	curry	15	Y	1
A	2021-01-10	ramen	12	Y	2
A	2021-01-11	ramen	12	Y	3
A	2021-01-11	ramen	12	Y	3
B	2021-01-01	curry	15	N	null
B	2021-01-02	curry	15	N	null
B	2021-01-04	sushi	10	N	null
B	2021-01-11	sushi	10	Y	1
B	2021-01-16	ramen	12	Y	2
B	2021-02-01	ramen	12	Y	3
C	2021-01-01	ramen	12	N	null
C	2021-01-01	ramen	12	N	null
C	2021-01-07	ramen	12	N	null */

with sales_cte as(
Select sales.customer_id, sales.order_date, menu.product_name, menu.price, 
case when sales.order_date >= members.join_date then 'Y' else 'N' end as member
from sales join menu on sales.product_id = menu.product_id left join members on sales.customer_id = members.customer_id)

select *,  
case when sales_cte.member = 'Y' then rank () over (partition by sales_cte.customer_id,
case when sales_cte.member = 'Y' then 1 else null end
order by sales_cte.order_date asc) end as ranking from sales_cte


SELECT 3
