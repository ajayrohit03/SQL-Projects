/*create database zomato;

CREATE TABLE zomato_goldusers (
    userid INTEGER,
    signup_date DATE
);

insert into zomato_goldusers(userid, signup_date) values (1, '2023-01-01'),(2, '2023-03-01');

drop table if exists users;
CREATE TABLE users (
    userid INTEGER,
    signup_date DATE
); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2023-09-02'),
(2,'2023-01-15'),
(3,'2022-04-11');

drop table if exists sales;
CREATE TABLE sales (
    userid INTEGER,
    created_date DATE,
    product_id INTEGER
); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2023-04-19',2),
(3,'2022-12-18',1),
(2,'2022-07-20',3),
(1,'2022-10-23',2),
(1,'2023-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);

drop table if exists product;
CREATE TABLE product (
    product_id INTEGER,
    product_name TEXT,
    price INTEGER
); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);*/

select * from zomato_goldusers;
select * from users;
select * from sales;
select * from product;

truncate table zomato_goldusers;

insert into zomato_goldusers(userid, signup_date) values (1, '2023-01-01'),(3, '2022-09-11');

# What is the total amount by each customer on zomato?

SELECT 
    a.userid, SUM(b.price) total_amt_spent
FROM
    sales a
        INNER JOIN
    product b ON a.product_id = b.product_id
GROUP BY a.userid;

# How many days does the customer visited zomato?

SELECT 
    userid, COUNT(DISTINCT created_date) distinct_days
FROM
    sales
GROUP BY userid;

# what was the first product purchased by each customer?

SELECT * FROM (SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) rnk FROM sales) a WHERE rnk = 1;

# what is most purchased item on menu & how many times was it purchased by all customers ?

select userid,count(product_id) cnt from sales where product_id =
(select product_id from sales group by product_id order by count(product_id) desc limit 1) 
group by userid;

# which item was most popular for each customer?

select * from
(select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk =1;

#  which item was purchased first by customer after they become a member ?

select * from
(select c.*,rank() over (partition by userid order by created_date ) rnk from
(select a.userid,a.created_date,a.product_id,b.signup_date from sales a inner join 
zomato_goldusers b on a.userid=b.userid and created_date>=signup_date) c)d where rnk=1;

# what is total orders and amount spent for each member before they become a member ?

select userid,count(created_date) order_purchased,sum(price) total_amt_spent from
(select c.*,d.price from
(select a.userid,a.created_date,a.product_id,b.signup_date from sales a inner join 
zomato_goldusers b on a.userid=b.userid and created_date<=signup_date) c inner join product d on c.product_id=d.product_id)e
group by userid;

# if buying each product generate points for eg 5rs=2 zomato point and each product has different purchasing points 

select userid,sum(total_points)*2.5  total_point_earned from 
(select e.*,amt/points total_points from 
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from 
(select c.userid,c.product_id,sum(price) amt from 
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f group by userid;

-- for eg for p1 5rs=1 zomato point,for p2 10rs=zomato point and p3 5rs=1 zomato point  2rs =1zomato point

select * from
(select * , rank() over (order by  total_point_earned desc) rnk from
(select product_id,sum(total_points)  total_point_earned from 
(select e.*,amt/points total_points from 
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from 
(select c.userid,c.product_id,sum(price) amt from 
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f group by product_id)f)g where rnk=1;

-- calculate points collected by each customers and for which product most points have been given till now.

select e.*,amt/points total_points from 
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from 
(select c.userid,c.product_id,sum(price) amt from 
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e