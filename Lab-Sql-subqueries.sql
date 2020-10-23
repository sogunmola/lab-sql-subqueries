USE sakila;

/* Lab SQL Subqueries
*/
/* 1) How many copies of the film Hunchback Impossible exist in the inventory system?
*/
-- Finding which tables to use
SELECT * FROM inventory;
SELECT * FROM film;

-- Child Query
SELECT film_id, title FROM film
WHERE title = 'Hunchback Impossible';

-- Final Query
SELECT film_id, count(film_id) AS inv_count FROM inventory
WHERE film_id in (
	SELECT film_id FROM film
	WHERE title = 'Hunchback Impossible'
    )  
   GROUP BY film_id ;
   
/* 2) List all films longer than the average.
*/
-- Child query
SELECT round(avg(length),2) AS ttl_avg FROM film;

-- Final Query
SELECT * FROM (
	SELECT film_id, title, length 
	FROM film
	GROUP BY film_id) as sub1
WHERE length > (SELECT round(avg(length),2) AS ttl_avg FROM film)
ORDER BY length; 

/* 3)Use subqueries to display all actors who appear in the film Alone Trip.
*/
-- Child Query
SELECT * FROM film
WHERE title = 'Alone Trip'; 

SELECT * FROM film_actor
WHERE film_id = 17;

-- Final Query
SELECT actor_id, film_id FROM film_actor
WHERE film_id = (SELECT film_id FROM film
WHERE title = 'Alone Trip')
; 

/* 4) Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
*/
-- Picking tables to use
-- 1st Query
SELECT name FROM category
WHERE name = 'Family';

-- 2nd Query
SELECT category_id FROM (
SELECT * FROM category
WHERE name = 'Family') as sub1;

-- 3rd Query
SELECT * FROM film_category
WHERE category_id IN (
SELECT category_id FROM category
WHERE name = 'Family');

-- Final Query
SELECT * FROM film 
WHERE film_id IN (
SELECT film_id FROM film_category
WHERE category_id IN (
SELECT category_id FROM category
WHERE name = 'Family'));

/* 5.1) Get name and email from customers from Canada using subqueries.
*/
-- Getting tables to use
SELECT * FROM country; -- To get country
SELECT * FROM city; -- To get country_id
SELECT * FROM address; -- To get city_id
SELECT * FROM customer; -- To get address_id 

-- Child query
SELECT country_id FROM (SELECT country_id FROM country 
WHERE country = 'Canada') as sub1;

-- 2nd query
SELECT city_id FROM city 
WHERE country_id = (
SELECT country_id FROM (SELECT country_id FROM country 
WHERE country = 'Canada') as sub1);

-- 3rd query
(SELECT address_id FROM address
WHERE city_id IN (SELECT city_id FROM city 
WHERE country_id = (
SELECT country_id FROM (SELECT country_id FROM country 
WHERE country = 'Canada') as sub1)));

-- Final subquery  
SELECT (CONCAT(first_name,' ', last_name)) AS Name, email FROM customer
WHERE address_id IN (SELECT address_id FROM address
WHERE city_id IN (SELECT city_id FROM city 
WHERE country_id = (
SELECT country_id FROM (SELECT country_id FROM country 
WHERE country = 'Canada') as sub1)))
;

/* 5.2) Get name and email from customers from Canada using joins.
*/
-- tables to join
SELECT * FROM customer; -- to get email, name, and address_id
SELECT * FROM address; -- to get city_id
SELECT * FROM city; -- to get country_id
SELECT * FROM country; -- to get country with country_id

-- Query using Join
SELECT CONCAT(c.first_name,' ',c.last_name) AS name, c.email, co.country FROM customer c
JOIN address a ON a.address_id = c.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country co ON co.country_id = ci.country_id
WHERE co.country = 'Canada';

/* 6) Which are films starred by the most prolific actor?
*/
-- Tables to be used
SELECT * FROM film_actor;
SELECT * FROM film;

-- 1st Query
SELECT actor_id, MAX(num_movies) FROM (
SELECT actor_id, film_id, COUNT(*) AS num_movies from film_actor
GROUP BY actor_id
ORDER BY num_movies desc) as sub1;

-- 2nd Query
SELECT actor_id FROM
(SELECT actor_id, MAX(num_movies) FROM (
SELECT actor_id, film_id, COUNT(*) AS num_movies from film_actor
GROUP BY actor_id
ORDER BY num_movies desc) as sub1
) as sub2;

--  Final Query
SELECT f.film_id, f.title FROM film f
JOIN (SELECT * FROM film_actor
WHERE actor_id IN (SELECT actor_id FROM
(SELECT actor_id, MAX(num_movies) FROM (
SELECT actor_id, film_id, COUNT(*) AS num_movies from film_actor
GROUP BY actor_id
ORDER BY num_movies desc) as sub1
) as sub2
)
) sub2 ON sub2.film_id = f.film_id;

/* 7) Films rented by most profitable customer
*/
-- Tables to be used
SELECT * FROM payment; -- to get customer_id of most profitable customer
SELECT * FROM rental; -- to get inventory_id from customer_id
SELECT * FROM inventory; -- to get film_id
SELECT * FROM film; -- to get list of films

-- 1st Query
SELECT customer_id, SUM(amount) AS ttl_paid FROM payment
GROUP BY customer_id
ORDER BY ttl_paid DESC;

-- 2nd Query
SELECT customer_id, MAX(ttl_paid) FROM (SELECT customer_id, SUM(amount) AS ttl_paid FROM payment
GROUP BY customer_id
ORDER BY ttl_paid DESC) AS sub1;

-- 3rd Query
SELECT customer_id FROM (SELECT customer_id, MAX(ttl_paid) FROM (SELECT customer_id, SUM(amount) AS ttl_paid FROM payment
GROUP BY customer_id
ORDER BY ttl_paid DESC) AS sub1
) AS sub2;

-- 4th Query
SELECT inventory_id FROM rental
WHERE customer_id IN (
SELECT customer_id FROM (SELECT customer_id, MAX(ttl_paid) FROM (SELECT customer_id, SUM(amount) AS ttl_paid FROM payment
GROUP BY customer_id
ORDER BY ttl_paid DESC) AS sub1
) AS sub2
);

-- Final Query
SELECT i.film_id, f.title FROM inventory i
JOIN (SELECT inventory_id FROM rental
WHERE customer_id IN (
SELECT customer_id FROM (SELECT customer_id, MAX(ttl_paid) FROM (SELECT customer_id, SUM(amount) AS ttl_paid FROM payment
GROUP BY customer_id
ORDER BY ttl_paid DESC
) AS sub1
) AS sub2
) 
) sub3 ON sub3.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id;

/* 8) Customers who spent more than the average.
*/
-- Tables to be used
SELECT * FROM payment;
SELECT * FROM customer;

--  Query
SELECT customer_id, Average FROM (
SELECT customer_id, round(avg(amount),2) AS Average FROM payment
GROUP BY customer_id) AS sub1
WHERE Average > (SELECT round(avg(amount),2) FROM payment);

