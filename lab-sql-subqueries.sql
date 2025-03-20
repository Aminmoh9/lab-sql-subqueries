/* Introduction
Welcome to the SQL Subqueries lab!

In this lab, you will be working with the Sakila database on movie rentals. Specifically, you will be practicing how to perform subqueries, which are queries embedded within other queries. 
Subqueries allow you to retrieve data from one or more tables and use that data in a separate query to retrieve more specific information.
*/

-- Challenge
-- Write SQL queries to perform the following tasks using the Sakila database:
USE Sakila;

-- 1.Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
-- 1st subquery
SELECT film_id
FROM film
WHERE title ="Hunchback Impossible";

-- Final query
SELECT COUNT(film_id) AS num_of_copies
FROM inventory
WHERE film_id =( 
   SELECT film_id 
   FROM film
   WHERE title ="Hunchback Impossible") ;

-- 2.List all films whose length is longer than the average length of all the films in the Sakila database.
-- 1st subquery
SELECT AVG(length) AS AVG_lenght
FROM film;
-- Final query
SELECT title, length
FROM film
WHERE length > (
      SELECT AVG(length) AS AVG_lenght
	  FROM film
);

-- 3.Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT * FROM film;
SELECT * FROM film_actor;
SELECT * FROM actor;
-- 1st subquery
SELECT film_id, title
FROM film
WHERE title ="Alone Trip";
-- 2nd subquery
SELECT actor_id, film_id
FROM film_actor
WHERE film_id = ( 
    SELECT film_id
    FROM film
    WHERE title ="Alone Trip"
);
-- final query
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    WHERE film_id = ( 
        SELECT film_id
        FROM film
        WHERE title ="Alone Trip"
        )
    );
-- Bonus:
-- 4.Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;

-- 1st subquery
SELECT category_id
FROM category
WHERE name ='Family';

-- 2nd subquery
SELECT film_id
FROM film_category
WHERE category_id =(
     SELECT category_id
     FROM category
     WHERE name ='Family'
     );
     
-- Final query
SELECT title
FROM film
WHERE film_id IN(
     SELECT film_id
     FROM film_category
     WHERE category_id =(
          SELECT category_id
          FROM category
          WHERE name ='Family'
     )
);
-- 5.Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT * FROM customer;
SELECT * FROM country;
SELECT * FROM address;
SELECT * FROM city;

-- 1st subquery
SELECT country_id
FROM country
WHERE country ="Canada";

-- 2nd subquery
SELECT city_id
FROM city
WHERE country_id=(
      SELECT country_id
      FROM country
      WHERE country ="Canada"
);
-- 3rd subquery
SELECT address_id
FROM address
WHERE city_id IN(
   SELECT city_id
   FROM city
   WHERE country_id=(
      SELECT country_id
      FROM country
      WHERE country ="Canada"
      )
	);
    
-- Final query
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
     SELECT address_id
     FROM address
     WHERE city_id IN(
          SELECT city_id
		  FROM city
          WHERE country_id=(
              SELECT country_id
              FROM country
              WHERE country ="Canada"
        )
    )
);

-- Query with Joins
SELECT c.first_name  , c.last_name , c.email 
FROM customer c
JOIN address a on c.address_id = a.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country co ON ci.country_id= co.country_id
WHERE co.country = "Canada";
-- 6.Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films.
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT * FROM film_actor;
SELECT * FROM film;

-- 1st subquery
SELECT actor_id
FROM  film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1;

-- 2nd subquery
SELECT film_id
FROM film_actor
WHERE actor_id= (
     SELECT actor_id
     FROM  film_actor
     GROUP BY actor_id
     ORDER BY COUNT(film_id) DESC
     LIMIT 1
     );

-- Final query
SELECT * 
FROM film
WHERE film_id IN(
      SELECT film_id
      FROM film_actor
      WHERE actor_id= (
           SELECT actor_id
           FROM  film_actor
           GROUP BY actor_id
           ORDER BY COUNT(film_id) DESC
           LIMIT 1
     )
  );
-- 7.Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer,
-- i.e., the customer who has made the largest sum of payments.
SELECT * FROM customer;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT * FROM film;
SELECT * FROM inventory;

-- 1st subquery 
SELECT customer_id
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1;

-- 2nd subquery
SELECT inventory_id
FROM rental
WHERE customer_id = (
      SELECT customer_id
      FROM payment
      GROUP BY customer_id
      ORDER BY SUM(amount) DESC
      LIMIT 1
);

-- 3rd subquery
SELECT film_id
FROM inventory
WHERE inventory_id IN(
     SELECT inventory_id
     FROM rental
     WHERE customer_id = (
         SELECT customer_id
		 FROM payment
         GROUP BY customer_id
         ORDER BY SUM(amount) DESC
         LIMIT 1
    )
);

-- Final query
SELECT *
FROM film
WHERE film_id IN (
     SELECT film_id
     FROM inventory
     WHERE inventory_id IN(
           SELECT inventory_id
           FROM rental
           WHERE customer_id = (
                 SELECT customer_id
		         FROM payment
                 GROUP BY customer_id
                ORDER BY SUM(amount) DESC
                LIMIT 1
    )
   )
);
-- 8.Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.
SELECT * FROM customer;
SELECT * FROM payment;

-- 1stquery
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id;

-- 2nd subquery
SELECT AVG(total_spent) AS avg_spent
FROM ( 
     SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
    ) AS customer_totals;

-- Final query
SELECT customer_id, total_spent
FROM ( 
     SELECT customer_id, SUM(amount) AS total_spent
     FROM payment
     GROUP BY customer_id
) AS customer_totals
WHERE total_spent > (
       SELECT AVG(total_spent) AS avg_spent
       FROM ( 
             SELECT customer_id, SUM(amount) AS total_spent
             FROM payment
             GROUP BY customer_id
        ) AS customer_totals

);
