CREATE TABLE sales (
customer_id varchar(50),
order_date date,
product_id int
)

CREATE TABLE menu (
product_id int,
product_name varchar(50),
price int
)

CREATE TABLE members (
customer_id varchar(50),
join_date date,
)

INSERT INTO sales VALUES
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
 
 INSERT INTO menu VALUES
 (1, 'sushi', 10),
 (2, 'curry', 15),
 (3, 'ramen', 12);

 INSERT INTO members VALUES
 ('A', '2021-01-07'),
 ('B', '2021-01-09');

 SELECT * FROM members
 --sales, menu, members 

--TOTAL AMOUNT EACH CUSTOMER SPENT AT THE DINER

SELECT sales.customer_id, SUM(menu.price) AS Total_sales
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id

--TOTAL DAYS PER CUSTOMER VISIT THE DINER

SELECT customer_id
, COUNT(DISTINCT order_date) AS Visit_Count FROM sales
GROUP BY customer_id

--First item from the menu purchased by each customer (USING CTE,DENSE RANK)

WITH ordered_menu AS ( 
    SELECT 
    sales.customer_id, 
	sales.order_date,
	menu.product_name,
	DENSE_RANK() OVER (PARTITION BY sales.customer_id 
	ORDER BY sales.order_date) AS rank 
	FROM sales
	JOIN menu
	ON sales.product_id = menu.product_id
	)
SELECT customer_id, product_name FROM ordered_menu
WHERE rank = 1
GROUP BY customer_id, product_name


--The most purchased item on the menu and 
--how many times was it purchased by all customers

SELECT menu.product_name, COUNT(sales.product_id) AS top_purchased
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY top_purchased DESC
OFFSET 0 ROWS
FETCH NEXT 1 ROWS ONLY


--The most popular items for each customer

WITH popular_item AS (
     SELECT sales.customer_id, 
	 menu.product_name, 
	 COUNT(menu.product_id) AS order_count,
	 DENSE_RANK() OVER (PARTITION BY sales.customer_id 
	 ORDER BY COUNT(sales.customer_id) DESC) AS rank 
     FROM sales
     JOIN menu
     ON sales.product_id = menu.product_id
	 GROUP BY sales.customer_id, menu.product_name
	 )
SELECT customer_id, product_name, order_count FROM 
popular_item
WHERE rank = 1


--First item purchased by the customer after became member

WITH as_member AS (
     SELECT members.customer_id, 
	 sales.product_id, 
	 ROW_NUMBER() OVER (PARTITION BY members.customer_id 
	 ORDER BY sales.order_date) AS row_num
     FROM members
     JOIN sales
     ON members.customer_id = sales.customer_id
	 AND sales.order_date > members.join_date
	 )
SELECT customer_id, product_name FROM as_member
JOIN menu
ON as_member.product_id = menu.product_id
WHERE row_num = 1
ORDER BY customer_id 

--Items purchased by the customer before became member

WITH before_member AS (
     SELECT members.customer_id, 
	 sales.product_id, 
	 ROW_NUMBER() OVER (PARTITION BY members.customer_id 
	 ORDER BY sales.order_date DESC) AS row_num
     FROM members
     JOIN sales
     ON members.customer_id = sales.customer_id
	 AND sales.order_date < members.join_date
	 )
SELECT customer_id, product_name FROM before_member
JOIN menu
ON before_member.product_id = menu.product_id
WHERE row_num = 1
ORDER BY customer_id 

--Total items and amount spent for each member before they became member

SELECT sales.customer_id, COUNT(sales.product_id) AS total_items,
SUM(menu.price) AS total_sales
FROM sales
JOIN members
ON sales.customer_id = members.customer_id
 AND sales.order_date < members.join_date
JOIN menu
ON sales.product_id = menu.product_id  
GROUP BY sales.customer_id
ORDER BY sales.customer_id

--USING CASE: calculate total points which each $1 = 10 points, sushi(product_id =1) = 2x points

WITH points_cte AS (
     SELECT menu.product_id,
	 CASE 
	 WHEN product_id = 1 THEN price * 20
	 ELSE price * 10
	 END AS points FROM menu
)
SELECT sales.customer_id, SUM(points_cte.points) AS total_points
FROM sales
JOIN points_cte
ON sales.product_id = points_cte.product_id
GROUP BY sales.customer_id
	 