
USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM film
WHERE title = "HUNCHBACK IMPOSSIBLE"; -- film_id = 439

SELECT COUNT(film_id) FROM sakila.inventory
WHERE film_id = 439;
-- Answer: 6

-- 2. List all films whose length is longer than the average of all the films.
SELECT * FROM film;
SELECT film_id, title FROM sakila.film
WHERE length > (
  SELECT avg(length)
  FROM sakila.film
);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM film
where title = "ALONE TRIP"; -- film_id = 17
SELECT actor_id, first_name, last_name 
FROM   sakila.actor 
WHERE  actor_id IN 
  (SELECT film_actor.actor_id 
    FROM sakila.film_actor
    WHERE film_id = 17);

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT DISTINCT name, category_id FROM category; -- Family
SELECT f.film_id, f.title, fc.category_id, c.name FROM sakila.film AS f
JOIN sakila.film_category AS fc
ON f.film_id = fc.film_id
LEFT JOIN sakila.category AS c
ON fc.category_id = c.category_id
WHERE c.name = "Family";

-- 5. Get name and email from customers from Canada using subqueries. 
-- Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT * FROM customer;    
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country; -- Canada country_id = 20

-- Here is the subquery:
SELECT customer.customer_id, concat(customer.first_name," ", customer.last_name) AS customer_name, customer.email FROM sakila.customer
WHERE address_id IN(SELECT address_id FROM address
WHERE city_id IN(
SELECT city_id FROM city
WHERE country_id = 20
));

-- Here is with JOIN
SELECT c.customer_id, concat(c.first_name," ", c.last_name) AS customer_name, c.email FROM sakila.customer AS c
JOIN sakila.address AS a
ON c.address_id = a.address_id 
LEFT JOIN sakila.city AS ci
ON a.city_id = ci.city_id 
WHERE ci.country_id = 20; 

-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
-- Gina Degeneres actor_id: 107
/* Code I used to find the prolific actor:*/

SELECT fa.actor_id, a.first_name, a.last_name, COUNT(fa.actor_id) AS total_films FROM film_actor AS fa
JOIN sakila.actor AS a
ON fa.actor_id = a.actor_id
GROUP by a.actor_id
ORDER BY total_films DESC;

/*to find the different films that he/she starred*/
SELECT film_id, title FROM sakila.film
WHERE film_id IN(
SELECT film_id FROM film_actor
WHERE actor_id = 107);

-- 7. Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
-- First find out most profitable customer
SELECT customer_id , SUM(amount) FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1; -- customer_id = 526

SELECT film_id, title FROM sakila.film;
-- These are the films rented by customer_id 526 who is alsom the most profitable customer
SELECT film_id, title FROM sakila.film
WHERE film_id IN(
SELECT film_id FROM sakila.inventory
WHERE inventory_id IN(
SELECT inventory_id FROM sakila.rental
WHERE customer_id = 107));

-- 8. Clients who spent more than the average payments.
SELECT COUNT(customer_id) FROM sakila.payment;
SELECT customer_id, first_name,last_name FROM sakila.customer
WHERE customer_id IN(
SELECT customer_id FROM sakila.payment
WHERE amount > (SELECT AVG(amount) FROM sakila.payment));