-- Accessing the database
SHOW DATABASES;
USE sakila;
SHOW FULL TABLES;

-- How many rental rate (the cost to rent the movie) categories there are?
SELECT COUNT(DISTINCT rental_rate) FROM film;

-- What are the rental rate (the cost to rent the movie) categories and how many movies are there in each one?
SELECT rental_rate, COUNT(film_id) AS number_of_films FROM film
GROUP BY rental_rate;

-- Which rating do we have the most movies in?
SELECT rating, COUNT(film_id) AS number_of_films
FROM film
GROUP BY rating
ORDER BY number_of_films DESC;

-- Which rating is most prevalent in each store (considering the total number of film copies)?
SELECT film.rating, inventory.store_id, COUNT(inventory.inventory_id) AS total_number_of_copies
FROM inventory
LEFT JOIN film
ON inventory.film_id = film.film_id
GROUP BY inventory.store_id, film.rating
ORDER BY total_number_of_copies DESC;

-- How many times each movie has been rented out?
SELECT inventory.film_id, COUNT(inventory.film_id) AS number_of_rentals
FROM rental
LEFT JOIN inventory
ON rental.inventory_id=inventory.inventory_id
GROUP BY inventory.film_id
ORDER BY 2 DESC;

-- For each movie, when was the first and the last time it was rented out?
SELECT inventory.film_id, film.title, MIN(rental.rental_date) AS rented_first_on, MAX(rental.rental_date) AS rented_last_on
FROM inventory
LEFT JOIN rental
ON rental.inventory_id=inventory.inventory_id
LEFT JOIN film
ON film.film_id=inventory.film_id
GROUP BY inventory.film_id;

-- Revenue per Movie
SELECT film.film_id, film.title, SUM(payment.amount) AS total_revenue
FROM payment
LEFT JOIN rental
ON payment.rental_id=rental.rental_id
LEFT JOIN inventory
ON rental.inventory_id=inventory.inventory_id
LEFT JOIN film
ON inventory.film_id=film.film_id
GROUP BY film.film_id
ORDER BY 3 DESC;

-- What is the last rental date of each customer?
SELECT customer_id, MAX(rental_date) AS last_rental_date
FROM rental
GROUP BY customer_id;

-- Who are the customers who have rented at least 30 times?
SELECT rental.customer_id, customer.first_name, customer.last_name, customer.email, COUNT(rental.rental_id) AS rentals_amount
FROM rental
LEFT JOIN customer
ON rental.customer_id=customer.customer_id
GROUP BY rental.customer_id
HAVING rentals_amount >= 30;

-- Who rented the most?
SELECT rental.customer_id, customer.first_name, customer.last_name, customer.email, COUNT(rental.rental_id) AS rentals_amount
FROM rental
LEFT JOIN customer
ON rental.customer_id=customer.customer_id
GROUP BY rental.customer_id
ORDER BY rentals_amount DESC
LIMIT 1;

-- What is the last rental date of active customers?
SELECT customer.customer_id, customer.first_name, customer.last_name, MAX(rental.rental_date) AS last_rental_date
FROM rental
JOIN customer
ON rental.customer_id=customer.customer_id
WHERE rental.customer_id IN (
SELECT customer.customer_id
FROM customer
WHERE customer.active = 1
)
GROUP BY rental.customer_id;

-- How much each active customer has spent on average?
SELECT customer.customer_id, customer.first_name, customer.last_name, AVG(payment.amount) AS average_spent
FROM payment
JOIN customer
ON payment.customer_id=customer.customer_id
WHERE payment.customer_id IN (
SELECT customer.customer_id
FROM customer
WHERE customer.active = 1
)
GROUP BY payment.customer_id;

-- Rentals per month
SELECT EXTRACT(MONTH FROM rental_date) AS month, COUNT(rental_id) AS rentals
FROM rental
GROUP BY month
ORDER BY month;

-- Revenue Per Month
SELECT EXTRACT(MONTH FROM payment_date) AS month, SUM(amount) AS revenue
FROM payment
GROUP BY month
ORDER BY month;