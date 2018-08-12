use sakila;
/*1a. Display the first and last names of all actors from the table actor.*/

SELECT FIRST_NAME,LAST_NAME FROM actor;
##1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select CONCAT(FIRST_NAME, ' ', LAST_NAME) AS "ACTOR NAME" FROM actor;
##2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
##What is one query would you use to obtain this information?
select actor_Id,first_name, last_name FROM actor WHERE first_name = "Joe";
##2b. Find all actors whose last name contain the letters GEN:
select * FROM actor WHERE last_name LIKE "%GEN%";
##2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * FROM actor WHERE last_name LIKE "%LI%" order by last_name, first_name;
##2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select Country_id,Country FROM country where country IN ("Afghanistan","Bangladesh","China");
##3a. You want to keep a description of each actor. You do not think you will be performing queries on a description, so create a column in the table actor named description and ##use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor add COLUMN description blob;
##3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor DROP COLUMN description;
##4a. List the last names of actors, as well as how many actors have that last name.
select LAST_NAME, Count(LAST_NAME) as Count_of_LastNames FROM actor group by LAST_NAME;
##4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select LAST_NAME, Count(LAST_NAME) as Count_of_LastNames FROM actor group by LAST_NAME HAVING Count(LAST_NAME) >= '2';
##4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
select First_Name, LAST_NAME FROM actor WHERE First_Name = "GROUCHO" AND LAST_NAME = "Williams";
UPDATE actor SET First_Name = "HARPO" WHERE First_Name = "GROUCHO" AND LAST_NAME = "Williams";
##4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is ##currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES=0;
UPDATE actor SET First_Name = "GROUCHO" WHERE First_Name = "HARPO";
#select First_Name, LAST_NAME FROM actor WHERE LAST_NAME = "Williams";
##5a. You cannot locate the schema of the address table. Which query would you use to re#create it?
##Hint: https://dev.mysql.com/doc/refman/5.7/en/show#create#table.html
SHOW CREATE TABLE address;

##6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
##SELECT * FROM STAFF;
SELECT STAFF.First_Name, STAFF.LAST_NAME, ADDRESS.address FROM STAFF JOIN ADDRESS ON Staff.Address_ID = ADDRESS.address_ID;
##6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT Staff.Staff_Id, Staff.first_name, Staff.last_name, SUM(Payment.amount) AS Payment_Total
FROM STAFF INNER JOIN Payment ON STAFF.staff_id = Payment.Staff_ID WHERE payment_date >= '2005-08-01' AND payment_date <= '2005-08-30'
GROUP BY Staff.Staff_Id, Staff.first_name, Staff.last_name;
##6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT FILM.FILM_ID, FILM.Title, FILM.Description, count(FILM_ACTOR.ACtor_ID) as NumberofActors FROM FILM INNER JOIN FILM_ACTOR ON FILM.FILM_ID = FILM_ACTOR.FILM_ID GROUP BY FILM.FILM_ID, FILM.Title, FILM.Description;
##6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(*) FROM inventory WHERE FILM_ID IN (SELECT FILM_ID FROM FILM WHERE TITLE LIKE '%Hunchback Impossible%');
##6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.customer_id, customer.first_name,customer.last_name, sum(payment.amount) as Total
FROM customer INNER JOIN Payment ON customer.Customer_ID = payment.Customer_ID group by customer.customer_id, customer.first_name,customer.last_name order by customer.last_name,customer.first_name;
##7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in ##popularity. 
##Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT Title, language_Id FROM Film WHERE Language_Id IN (SELECT Language_Id FROM Language WHERE NAME = "ENGLISH") AND Title LIKE "K%" OR TITLE LIKE "Q%" ORDER BY TITLE;
##7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM actor where actor_ID IN (SELECT actor_ID FROM film_actor WHERE FILM_ID IN (SELECT FILM_ID FROM FILM WHERE TITLE LIKE "%Alone Trip%")) order by last_name, first_name;
##7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name,customer.email,Country.Country FROM Customer 
INNER JOIN address ON Customer.address_ID = address.address_ID
INNER JOIN city ON address.city_id = city.city_Id
INNER JOIN Country ON country.country_Id = city.country_Id
WHERE Country.country = "CANADA";

##7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT FILM.FILM_ID, FILM.title, Category.NAME FROM Category 
INNER JOIN FILM_Category ON Category.Category_ID = FILM_Category.Category_ID
INNER JOIN FILM ON FILM.FILM_ID = FILM_Category.FILM_ID
WHERE Category.NAME = "Family" order by FILM.title;

##7e. Display the most frequently rented movies in descending order.
SELECT FILM.title, count(INVENTORY.FILM_ID) as Total_Rentals
FROM RENTAL INNER JOIN INVENTORY ON INVENTORY.inventory_id = RENTAL.inventory_ID
INNER JOIN FILM ON INVENTORY.FILM_ID = FILM.FILM_ID
GROUP BY FILM.title ORDER BY count(INVENTORY.FILM_ID) desc;
##7f. Write a query to display how much business, in dollars, each store brought in.
SELECT Customer.store_Id, (sum(PAYMENT.amount)) as Total FROM PAYMENT 
INNER JOIN RENTAL ON RENTAL.rental_id = PAYMENT.rental_id
INNER JOIN Customer ON Customer.Customer_ID = PAYMENT.Customer_ID
GROUP BY Customer.store_Id;

##7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_Id, address.address,city.City,Country.Country
FROM store 
INNER JOIN address ON address.address_ID = store.address_id
INNER JOIN City ON address.city_Id = City.city_ID
INNER JOIN Country on City.Country_Id = Country.Country_ID;
##7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select category.name, sum(payment.amount) as gross_revenue FROM category
INNER JOIN film_category ON category.category_id = film_category.category_ID
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
group by category.name
order by sum(payment.amount) desc LIMIT 5;

##8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create  
##view. If you haven't solved 7h, you can substitute another query to create a view.
create view top5_gross_revenue_by_category
as
select category.name, sum(payment.amount) as gross_revenue FROM category
INNER JOIN film_category ON category.category_id = film_category.category_ID
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
group by category.name
order by sum(payment.amount) desc LIMIT 5;
##8b. How would you display the view that you created in 8a?
SELECT * FROM top5_gross_revenue_by_category;
##8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top5_gross_revenue_by_category;