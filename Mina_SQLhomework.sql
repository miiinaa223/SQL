-- Mina SQL Homework
Use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
-- note first_name and last_name did not work
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
-- note concat function is to join multiple columns
select upper(concat(first_name,' ',last_name)) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, 
-- and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
-- =: perfect match / like: partial match ??
select actor_id, first_name, last_name from actor where last_name like '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
-- in: multiple conditions search
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor add column description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
alter table actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as 'Count Actors' from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(*) as 'Count Actors' from actor group by last_name having count(*) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name = 'GROUCHO' where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. 
-- Which query would you use to re-create it?
show create table address; 
-- create the table referring the return above: 'address', 'CREATE TABLE `address` (\n  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,\n  `address` varchar(50) NOT NULL,\n  `address2` varchar(50) DEFAULT NULL,\n  `district` varchar(20) NOT NULL,\n  `city_id` smallint(5) unsigned NOT NULL,\n  `postal_code` varchar(10) DEFAULT NULL,\n  `phone` varchar(20) NOT NULL,\n  `location` geometry NOT NULL,\n  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n  PRIMARY KEY (`address_id`),\n  KEY `idx_fk_city_id` (`city_id`),\n  SPATIAL KEY `idx_location` (`location`),\n  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE\n) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8'
-- should be able to use describe as well

-- 6a. Use JOIN to display the first and last names,as well as the address, of each staff member. 
-- Use the tables staff and address:
select first_name, last_name, address from staff s join address a on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
-- Use tables staff and payment.
-- note: date shows time as well so % helps the select search.

select payment.staff_id, staff.first_name, staff.last_name, payment.amount, payment.payment_date
from staff inner join payment on staff.staff_id = payment.staff_id and payment_date like '2005-08%';

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, (select count(*) from inventory where film.film_id = inventory.film_id) as 'number of inventories'
from film
where title = 'Hunchback Impossible';


-- 6e. Using the tables payment and customer and the JOIN command,
-- list the total paid by each customer. List the customers alphabetically by last name:
-- select both columns in group-by
select customer.last_name, customer.first_name, sum(payment.amount) as 'payment amount'
from payment join customer on (customer.customer_id = payment.customer_id) 
group by customer.last_name, customer.first_name
order by customer.last_name, customer.first_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select * from language; -- 1 = English
select title from film where title like 'K%' or 'Q%' and title in (select title from film where language_id = 1);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor where actor_id in 
(select actor_id from film_actor where film_id in
(select film_id from film where title = 'Alone Trip'
)); 

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
-- customer -> address -> city -> country
select customer.first_name, customer.last_name, customer.email from customer
join address on (customer.address_id = address.address_id)
join city on (address.city_id = city.city_id)
join country on (city.country_id = country.country_id) where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
-- select category_id, name from category; -- 8 = Family
select film.title from film
join film_category on (film.film_id = film_category.film_id)
join category on (film_category.category_id = category.category_id) where category.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select title, count(rental.rental_id) as 'times rented' from rental
join inventory on (rental.inventory_id = inventory.inventory_id)
join film on (inventory.film_id = film.film_id) group by film.title order by 'times rented' desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- store.store_id -> inventory.store_id -> rental.inventory_id -> rental_id -> payment
select store.store_id, sum(amount) as 'Revenue' from payment
join rental on (payment.rental_id = rental.rental_id)
join inventory on (rental.inventory_id = inventory.inventory_id)
join store on (inventory.store_id = store.store_id) group by store.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country from store
join address on (store.address_id = address.address_id)
join city on (address.city_id = city.city_id)
join country on (city.country_id = country.country_id);


-- 7h. List the top five genres in gross revenue in descending order.  
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name, sum(payment.amount) as 'Revenue' from category
join film_category on (category.category_id = film_category.category_id) 
join inventory on (film_category.film_id = inventory.film_id)
join rental on (inventory.inventory_id = rental.inventory_id)
join payment on (rental.rental_id = payment.rental_id) group by category.name order by Revenue desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
create view genre_revenue as 
select category.name, sum(payment.amount) as 'Revenue' from category
join film_category on (category.category_id = film_category.category_id) 
join inventory on (film_category.film_id = inventory.film_id)
join rental on (inventory.inventory_id = rental.inventory_id)
join payment on (rental.rental_id = payment.rental_id) group by category.name order by Revenue desc limit 5;


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM genre_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW genre_revenue;
