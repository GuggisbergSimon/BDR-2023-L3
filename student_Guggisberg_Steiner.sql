SET search_path = pagila;

-- BEGIN Exercice 01
SELECT
	customer_id,
	last_name AS nom,
	email AS email
FROM customer AS c
WHERE c.first_name = 'PHYLLIS'
  AND c.store_id = 1
ORDER BY c.customer_id DESC;
-- END Exercice 01

-- BEGIN Exercice 02
SELECT
	title AS titre,
	release_year AS annee_sortie
FROM film AS f
WHERE f.rating = 'R'
  AND f.length < 60
  AND f.replacement_cost = 12.99
ORDER BY f.title;
-- END Exercice 02

-- BEGIN Exercice 03
SELECT
	country AS country,
	city AS city,
	postal_code AS postal_code
FROM address AS a
	LEFT JOIN city AS ci
		ON a.city_id = ci.city_id
	LEFT JOIN country AS co
		ON ci.country_id = co.country_id
WHERE co.country = 'France'
   OR (co.country_id >= 63 AND
	   co.country_id <= 67)
ORDER BY co.country,
		 ci.city,
		 a.postal_code;
-- END Exercice 03

-- BEGIN Exercice 04
SELECT
	cu.customer_id,
	cu.first_name AS prenom,
	cu.last_name AS nom
FROM customer AS cu
	JOIN address AS a
		ON cu.address_id = a.address_id
WHERE a.city_id = 171
  AND cu.store_id = 1
ORDER BY cu.first_name;
-- END Exercice 04

-- BEGIN Exercice 05
SELECT
	c1.first_name AS prenom_1,
	c1.last_name AS nom_1,
	c2.first_name AS prenom_2,
	c2.last_name AS nom_2
FROM customer AS c1
	JOIN rental AS r1
		ON c1.customer_id = r1.customer_id
	JOIN inventory AS i1
		ON r1.inventory_id = i1.inventory_id
	JOIN film AS f
		ON i1.film_id = f.film_id
	JOIN inventory AS i2
		ON f.film_id = i2.film_id
	JOIN rental AS r2
		ON i2.inventory_id = r2.inventory_id
	JOIN customer AS c2
		ON r2.customer_id = c2.customer_id
WHERE c1.customer_id < c2.customer_id
  AND r1.rental_id != r2.rental_id
  AND f.film_id = i1.film_id
GROUP BY prenom_1,
		 nom_1,
		 prenom_2,
		 nom_2
ORDER BY prenom_1,
		 nom_1,
		 prenom_2,
		 nom_2;
-- END Exercice 05

-- BEGIN Exercice 06
SELECT DISTINCT
	actor.last_name AS nom,
	actor.first_name AS prenom
FROM actor
WHERE actor_id IN (
	SELECT
		actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT
			film_id
		FROM film_category
		WHERE category_id IN (
			SELECT
				category_id
			FROM category
			WHERE name = 'Horror'
		)
	)
)
  AND (actor.first_name LIKE 'K%' OR actor.last_name LIKE 'D%');
-- END Exercice 06

-- BEGIN Exercice 07a
SELECT
	f.film_id AS id,
	f.title AS titre,
	f.rental_rate / f.rental_duration AS prix_de_location_par_jour
FROM film AS f
	LEFT JOIN inventory AS i
		ON f.film_id = i.film_id
	LEFT JOIN rental AS r
		ON i.inventory_id = r.inventory_id
GROUP BY f.film_id,
		 rental_rate,
		 rental_duration
HAVING COUNT(r.rental_id) = 0
   AND rental_rate / rental_duration <= 1.00;
-- END Exercice 07a

-- BEGIN Exercice 07b
SELECT
	film_id AS id,
	title AS titre,
	rental_rate / rental_duration AS prix_de_location_par_jour
FROM film
WHERE rental_rate / rental_duration <= 1.00
  AND NOT EXISTS (
	SELECT
		1
	FROM inventory
		JOIN rental
			ON inventory.inventory_id = rental.inventory_id
	WHERE inventory.film_id = film.film_id
);
-- END Exercice 07b

-- BEGIN Exercice 08a
SELECT
	customer.customer_id AS id,
	customer.last_name AS nom,
	customer.first_name AS prenom
FROM customer
	JOIN address
		ON customer.address_id = address.address_id
	JOIN city
		ON address.city_id = city.city_id
	JOIN country
		ON city.country_id = country.country_id
WHERE country.country = 'Spain'
  AND EXISTS (
	SELECT
		1
	FROM rental
	WHERE rental.customer_id = customer.customer_id
	  AND rental.return_date IS NULL
);
-- END Exercice 08a

-- BEGIN Exercice 08b
SELECT
	customer.customer_id AS id,
	customer.last_name AS nom,
	customer.first_name AS prenom
FROM customer
	JOIN address
		ON customer.address_id = address.address_id
	JOIN city
		ON address.city_id = city.city_id
	JOIN country
		ON city.country_id = country.country_id
WHERE country.country = 'Spain'
  AND customer.customer_id IN (
	SELECT DISTINCT
		rental.customer_id
	FROM rental
	WHERE rental.return_date IS NULL
);
-- END Exercice 08b

-- BEGIN Exercice 08c
SELECT
	customer.customer_id AS id,
	customer.last_name AS nom,
	customer.first_name AS prenom
FROM rental,
	 customer
	 JOIN address
			 ON customer.address_id = address.address_id
	 JOIN city
			 ON address.city_id = city.city_id
	 JOIN country
			 ON city.country_id = country.country_id
WHERE country.country = 'Spain'
  AND customer.customer_id = rental.customer_id
  AND rental.return_date IS NULL;
-- END Exercice 08c

-- BEGIN Exercice 09 (Bonus)
WITH filmIds AS (
	SELECT
		film_id
	FROM film_actor AS fa
		JOIN actor AS a
			ON fa.actor_id = a.actor_id
	WHERE a.first_name = 'EMILY'
	  AND a.last_name = 'DEE'
)
SELECT
	c.customer_id,
	c.first_name AS prenom,
	c.last_name AS nom
FROM customer AS c
	JOIN rental AS r
		ON c.customer_id = r.customer_id
	JOIN inventory AS i
		ON r.inventory_id = i.inventory_id
	JOIN filmIds AS e
		ON i.film_id = e.film_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT e.film_id) = (
	SELECT COUNT(*)
	FROM filmIds
);
-- END Exercice 09 (Bonus)

-- BEGIN Exercice 10
SELECT
	f.title AS titre,
	COUNT(fa.actor_id) AS nb_acteurs
FROM film AS f
	JOIN film_category AS fc
		ON f.film_id = fc.film_id
	JOIN film_actor AS fa
		ON f.film_id = fa.film_id
	JOIN category AS c
		ON fc.category_id = c.category_id
WHERE c.name = 'Drama'
GROUP BY f.film_id
HAVING COUNT(fa.actor_id) < 5
ORDER BY nb_acteurs DESC;
-- END Exercice 10

-- BEGIN Exercice 11
SELECT
	c.category_id AS id,
	c.name AS nom,
	COUNT(fc.film_id) AS nb_films
FROM category AS c
	JOIN film_category AS fc
		ON c.category_id = fc.category_id
GROUP BY c.category_id,
		 c.name
HAVING COUNT(fc.film_id) > 65
ORDER BY nb_films;
-- END Exercice 11


-- BEGIN Exercice 12
SELECT
	f.film_id AS id,
	f.title AS titre,
	f.length AS duree
FROM film f
	JOIN (
	SELECT
		MIN(length) AS min_length
	FROM film
) AS min_duration
		ON f.length = min_duration.min_length;
-- END Exercice 12


-- BEGIN Exercice 13a
SELECT
	film.film_id AS id,
	film.title AS titre
FROM film
WHERE film.film_id IN (
	SELECT
		film_actor.film_id
	FROM film_actor
	WHERE film_actor.actor_id IN
		  (
			  SELECT
				  actor.actor_id
			  FROM actor
				  JOIN film_actor
					  ON actor.actor_id = film_actor.actor_id
			  GROUP BY actor.actor_id
			  HAVING COUNT(film_actor.film_id) > 40
		  )
)
ORDER BY film.title;
-- END Exercice 13a


-- BEGIN Exercice 13b
SELECT DISTINCT
	f.film_id AS id,
	f.title AS titre
FROM film AS f
	JOIN film_actor AS fa
		ON f.film_id = fa.film_id
	JOIN (
	SELECT
		a.actor_id
	FROM actor AS a
		JOIN film_actor
			ON a.actor_id = film_actor.actor_id
	GROUP BY a.actor_id
	HAVING COUNT(film_actor.film_id) > 40
) AS famous_actors
		ON fa.actor_id = famous_actors.actor_id
ORDER BY f.title;
-- END Exercice 13b

-- BEGIN Exercice 14
SELECT
	CEIL(SUM(length) / (60 * 8)) AS nb_jours
FROM film;
-- END Exercice 14


-- BEGIN Exercice 15
WITH clientStats AS (
	SELECT
		cu.customer_id AS id,
		cu.last_name AS nom,
		cu.email AS email,
		co.country AS pays,
		COUNT(r.rental_id) AS nb_locations,
		SUM(p.amount) AS depense_totale,
		AVG(p.amount) AS depense_moyenne
	FROM customer AS cu
		JOIN address AS a
			ON cu.address_id = a.address_id
		JOIN city AS ci
			ON a.city_id = ci.city_id
		JOIN country AS co
			ON ci.country_id = co.country_id
		LEFT JOIN rental AS r
			ON cu.customer_id = r.customer_id
		LEFT JOIN payment AS p
			ON r.rental_id = p.rental_id
	WHERE co.country IN ('Switzerland', 'France', 'Germany')
	GROUP BY cu.customer_id, co.country
)
SELECT
	id,
	nom,
	email,
	pays,
	nb_locations,
	depense_totale,
	depense_moyenne
FROM clientStats
WHERE depense_moyenne > 3.0
ORDER BY pays,
		 nom;
-- END Exercice 15


-- BEGIN Exercice 16a
SELECT
	COUNT(*) AS nb_paiements_inf_ou_egaux_a_9
FROM payment
WHERE amount <= 9;
-- END Exercice 16a

/* -------------------------------------------------------------------------------------------------
   Les requêtes ci-dessous éditent la DB !
   -------------------------------------------------------------------------------------------------
 */

-- BEGIN Exercice 16b
DELETE
FROM payment
WHERE amount <= 9;
-- END Exercice 16b

-- BEGIN Exercice 16c
SELECT
	COUNT(*) AS nb_paiements_apres_effacement
FROM payment
WHERE amount <= 9;
-- END Exercice 16c


-- BEGIN Exercice 17
--SELECT COUNT(*) FROM payment WHERE amount > 4; -- 7746
--SELECT COUNT(*) FROM payment WHERE amount > 4 * 1.5; -- 2651

UPDATE payment
SET payment_date = CASE
		WHEN amount > 4.0
			THEN CURRENT_TIMESTAMP
		ELSE payment_date
	END,
	amount = CASE
			WHEN amount > 4.0
				THEN amount * 1.5 -- Augmentation de 50% pour les paiements de plus de 4$
			ELSE amount
		END;

--SELECT COUNT(*) FROM payment WHERE amount > 4; -- 7746
--SELECT COUNT(*) FROM payment WHERE amount > 4 * 1.5; -- 7746
-- END Exercice 17


-- BEGIN Exercice 18

-- a)
--SELECT * FROM city WHERE city = 'Nyon'; -- n'existe pas il faut l'ajouter
/*INSERT INTO city (city, country_id, last_update)
VALUES ('Nyon',
		(
			SELECT
				country_id
			FROM country
			WHERE country = 'Switzerland'
			LIMIT 1
		),
		CURRENT_TIMESTAMP); -- ok

INSERT INTO address (address, address2, district, city_id, postal_code, phone, last_update)
VALUES ('Rue du centre',
		'?num?',
		'Vaud',
		(
			SELECT
				city_id
			FROM city
			WHERE city = 'Nyon'
			LIMIT 1
		),
		'1260',
		'021/360.00.00',
		CURRENT_TIMESTAMP);

INSERT INTO customer (store_id, first_name, last_name, email, address_id, active, create_date, last_update)
VALUES (1,
		'Guillaume',
		'Ransome',
		'gr@bluewin.ch',
		(
			SELECT
				address_id
			FROM address
			WHERE postal_code = '1260'
			LIMIT 1
		),
		TRUE,
		CURRENT_TIMESTAMP,
		CURRENT_TIMESTAMP);
-- attention si plusieurs villes ont le même postal_code peut provoquer des erreurs
--SELECT * FROM address Where city_id IN (SELECT city_id FROM city WHERE country_id IN (SELECT country_id FROM country WHERE country = 'Switzerland'));
 */

--b) Car il est géré par la base de donnée, c'est un serial, afin qu'il n'y en ai pas deux identique

--c)
WITH new_city AS (
	INSERT INTO city (city, country_id, last_update)
		VALUES ('Nyon', (
			SELECT country_id
			FROM country
			WHERE country = 'Switzerland'
		), CURRENT_TIMESTAMP)
		RETURNING city_id
),
	 new_address AS (
		 INSERT INTO address (address, address2, district, city_id, postal_code, phone, last_update)
			 VALUES ('Rue du centre', '?num?', 'Vaud', (
				 SELECT city_id
				 FROM new_city
			 ), '1260', '021/360.00.00',
					 CURRENT_TIMESTAMP)
			 RETURNING address_id
	 )
INSERT
INTO customer (store_id, first_name, last_name, email, address_id, active, create_date, last_update)
VALUES (1, 'Guillaume', 'Ransome', 'gr@bluewin.ch', (
	SELECT address_id
	FROM new_address
), TRUE, CURRENT_TIMESTAMP,
		CURRENT_TIMESTAMP)
RETURNING customer_id;
-- pas nécessaire mais nous renvoie son id

-- END Exercice 18

-- BEGIN Exercice 18d
SELECT *
FROM customer
WHERE first_name = 'Guillaume'
  AND last_name = 'Ransome';
-- END Exercice 18d
