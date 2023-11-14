SET search_path = pagila;

-- BEGIN Exercice 01
/* Donnez le numéro, le nom et l’email (customer_id, nom, email) des clients dont le prénom est
PHYLLIS, qui sont rattachés au magasin numéro 1, ordonnés par numéro de client décroissant.*/
SELECT customer_id,
       last_name AS nom,
       email AS email
FROM customer as c
WHERE
    c.first_name = 'PHYLLIS'
    AND c.store_id = 1
ORDER BY c.customer_id DESC;
-- END Exercice 01

-- BEGIN Exercice 02
/*Donnez l’ensemble des films (titre, annee_sortie) classés (rating) R, ayant une durée de moins
de 60 minutes et dont les coûts de remplacements sont 12.99$, en les ordonnant par titre.*/
SELECT
    title AS titre,
    release_year AS annee_sortie
FROM film AS f
WHERE
    f.rating = 'R'
    AND f.length < 60
    AND f.replacement_cost = 12.99
ORDER BY f.title;
/*SEP*/
SELECT title AS titre, release_year AS annee_sortie
FROM film
WHERE rating = 'R' AND length < 60 AND replacement_cost = 12.99
ORDER BY title;
-- END Exercice 02

-- BEGIN Exercice 03
/*Listez le pays, la ville et le numéro postal (country, city, postal_code) des villes française, ainsi
que des villes dont le numéro de pays est entre 63 et 67 (bornes comprises), en les ordonnant par
pays puis par ville et finalement par code postal. N’utilisez pas de BETWEEN.*/
SELECT
    country AS pays,
    city AS ville,
    postal_code AS "numéro postal"
FROM address AS a
LEFT JOIN city AS ci
    ON a.city_id = ci.city_id
LEFT JOIN country AS co
    ON ci.country_id = co.country_id
WHERE
    co.country = 'France' OR
        (co.country_id >= 63 AND
         co.country_id <= 67)
ORDER BY
    co.country,
    ci.city,
    a.postal_code;
/*SEP*/
    SELECT country.country AS pays, city.city AS ville, address.postal_code AS code_postal
FROM country
JOIN city ON country.country_id = city.country_id
JOIN address ON city.city_id = address.city_id
WHERE country.country = 'France' OR (country.country_id >= 63 AND country.country_id <= 67)
ORDER BY country.country, city.city, address.postal_code;
-- END Exercice 03

-- BEGIN Exercice 04
/*Listez tous les clients actifs (customer_id, prenom, nom) habitant la ville 171, et rattachés au
magasin numéro 1. Triez-les par ordre alphabétique des prénoms */
SELECT
    customer_id, first_name AS prenom, last_name AS nom, c.store_id
FROM customer AS c
LEFT JOIN  address AS a
    ON  c.address_id = a.address_id
LEFT JOIN store AS s
    ON a.address_id = s.address_id
WHERE
    a.city_id = 171
    AND c.store_id = 1
    AND s.store_id IS NOT NULL
ORDER BY c.first_name;

SELECT * FROM store WHERE store_id = 1;
SELECT * FROM staff;
SELECT * FROM address WHERE city_id = 171;

SELECT
    customer_id,
    first_name AS prenom,
    last_name AS nom
FROM customer AS c
LEFT JOIN address AS a
    ON c.address_id = a.address_id
WHERE
    c.store_id = 1
    AND a.city_id = 171
ORDER BY c.first_name;

/*SELECT * FROM address WHERE address.city_id = 171 AND address.address_id IN (
SELECT address_id FROM customer WHERE customer.store_id = 1);
SELECT address_id FROM customer WHERE customer.store_id = 1 AND first_name = 'ALICE';--*/
/*SEP*/
SELECT customer.customer_id, customer.first_name AS prenom, customer.last_name AS nom
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
WHERE city.city_id = 171 AND customer.store_id = 1
ORDER BY customer.first_name;
-- END Exercice 04

-- BEGIN Exercice 05
/*Donnez le nom et le prénom (prenom_1, nom_1, prenom_2, nom_2) des clients qui ont loué au
moins une fois le même film (par exemple, si ALAN et BEN ont loué le film MATRIX, mais pas TRACY,
seuls ALAN et BEN doivent être listés)*/
SELECT count(*) FROM rental;

SELECT f.film_id, c.customer_id
FROM rental AS r
LEFT JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
LEFT JOIN film AS f
    ON i.film_id = f.film_id
LEFT JOIN customer AS c
    ON r.customer_id = c.customer_id
ORDER BY film_id, customer_id;


SELECT count(*) FROM inventory;

/*SEP*/
SELECT c1.first_name AS prenom_1, c1.last_name AS nom_1, c2.first_name AS prenom_2, c2.last_name AS nom_2
FROM rental r1
JOIN rental r2 ON r1.inventory_id = r2.inventory_id AND r1.rental_id < r2.rental_id
JOIN customer c1 ON r1.customer_id = c1.customer_id
JOIN customer c2 ON r2.customer_id = c2.customer_id
WHERE c1.customer_id < c2.customer_id
ORDER BY prenom_1, nom_1, prenom_2, nom_2;
-- END Exercice 05

-- BEGIN Exercice 06
/*Donnez le nom et le prénom des acteurs (nom, prenom) ayant joué dans un film d’horreur, dont le
prénom commence par K, ou dont le nom de famille commence par D sans utiliser le mot clé
JOIN.*/
SELECT * FROM film AS f;
SELECT * FROM film_category AS fc;
SELECT category_id FROM category WHERE name = 'Horror';
SELECT last_name AS nom, first_name AS prenom FROM actor;
/*SEP*/
SELECT DISTINCT actor.last_name AS nom, actor.first_name AS prenom
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    WHERE film_id IN (
        SELECT film_id
        FROM film
        WHERE genre_id IN (
            SELECT genre_id
            FROM genre
            WHERE name = 'Horror'
        )
    )
) AND (actor.first_name LIKE 'K%' OR actor.last_name LIKE 'D%');
-- END Exercice 06

-- BEGIN Exercice 07a
SELECT film_id AS id, title AS titre, rental_rate AS prix_de_location_par_jour
FROM film
WHERE rental_rate <= 1.00
AND film_id NOT IN (
    SELECT DISTINCT inventory.film_id
    FROM inventory
    JOIN rental ON inventory.inventory_id = rental.inventory_id
);
-- END Exercice 07a

-- BEGIN Exercice 07b
SELECT film_id AS id, title AS titre, rental_rate AS prix_de_location_par_jour
FROM film
WHERE rental_rate <= 1.00
AND NOT EXISTS (
    SELECT 1
    FROM inventory
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    WHERE inventory.film_id = film.film_id
);
-- END Exercice 07b

-- BEGIN Exercice 08a
SELECT customer.customer_id AS id, customer.last_name AS nom, customer.first_name AS prenom
FROM customer
WHERE customer.country_id = (
    SELECT country_id
    FROM country
    WHERE country = 'Spain'
)
AND EXISTS (
    SELECT 1
    FROM rental
    WHERE rental.customer_id = customer.customer_id
    AND rental.return_date IS NULL
);
-- END Exercice 08a

-- BEGIN Exercice 08b
SELECT customer.customer_id AS id, customer.last_name AS nom, customer.first_name AS prenom
FROM customer
WHERE customer.country_id = (
    SELECT country_id
    FROM country
    WHERE country = 'Spain'
)
AND customer.customer_id IN (
    SELECT DISTINCT rental.customer_id
    FROM rental
    WHERE rental.return_date IS NULL
);
-- END Exercice 08b

-- BEGIN Exercice 08c
SELECT DISTINCT customer.customer_id AS id, customer.last_name AS nom, customer.first_name AS prenom
FROM customer, rental
WHERE customer.country_id = (
    SELECT country_id
    FROM country
    WHERE country = 'Spain'
)
AND customer.customer_id = rental.customer_id
AND rental.return_date IS NULL;
-- END Exercice 08c

-- BEGIN Exercice 09 (Bonus)
SELECT customer.customer_id, customer.first_name AS prenom, customer.last_name AS nom
FROM customer
WHERE customer.customer_id IN (
    SELECT rental.customer_id
    FROM rental
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film_actor ON inventory.film_id = film_actor.film_id
    JOIN actor ON film_actor.actor_id = actor.actor_id
    WHERE actor.first_name = 'EMILY' AND actor.last_name = 'DEE'
)
AND customer.customer_id NOT IN (
    SELECT customer.customer_id
    FROM rental
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film_actor ON inventory.film_id = film_actor.film_id
    JOIN actor ON film_actor.actor_id = actor.actor_id
    WHERE actor.first_name = 'EMILY' AND actor.last_name = 'DEE'
    AND rental.return_date IS NULL
);
-- END Exercice 09 (Bonus)

-- BEGIN Exercice 10
SELECT film.title AS titre, COUNT(film_actor.actor_id) AS nb_acteurs
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Drama'
GROUP BY film.film_id, film.title
HAVING COUNT(film_actor.actor_id) < 5
ORDER BY nb_acteurs DESC;
-- END Exercice 10

-- BEGIN Exercice 11
SELECT category.category_id AS id, category.name AS nom, COUNT(film_category.film_id) AS nb_films
FROM category
JOIN film_category ON category.category_id = film_category.category_id
GROUP BY category.category_id, category.name
HAVING COUNT(film_category.film_id) > 65
ORDER BY nb_films;
-- END Exercice 11

-- BEGIN Exercice 12
SELECT film.film_id AS id, film.title AS titre, film.length AS duree
FROM film
WHERE film.length = (
    SELECT MIN(length)
    FROM film
);
-- END Exercice 12


-- BEGIN Exercice 13a
SELECT film.film_id AS id, film.title AS titre
FROM film
WHERE film.film_id IN (
    SELECT DISTINCT film_actor.film_id
    FROM film_actor
    JOIN actor ON film_actor.actor_id = actor.actor_id
    GROUP BY film_actor.actor_id
    HAVING COUNT(film_actor.film_id) > 40
)
ORDER BY film.title;
-- END Exercice 13a

-- BEGIN Exercice 13b
SELECT DISTINCT film.film_id AS id, film.title AS titre
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
JOIN (
    SELECT film_actor.actor_id
    FROM film_actor
    GROUP BY film_actor.actor_id
    HAVING COUNT(film_actor.film_id) > 40
) AS prolific_actors ON actor.actor_id = prolific_actors.actor_id
ORDER BY film.title;
-- END Exercice 13b

-- BEGIN Exercice 14
SELECT CEIL(SUM(length) / 8) AS nb_jours
FROM film;
-- END Exercice 14


-- BEGIN Exercice 15
-- Requête pour obtenir le montant total dépensé et le nombre de locations pour chaque client
WITH ClientStats AS (
    SELECT
        customer.customer_id AS id,
        customer.last_name AS nom,
        customer.email,
        country.country AS pays,
        COUNT(rental.rental_id) AS nb_locations,
        SUM(payment.amount) AS depense_totale,
        AVG(payment.amount) AS depense_moyenne
    FROM
        customer
    JOIN address ON customer.address_id = address.address_id
    JOIN city ON address.city_id = city.city_id
    JOIN country ON city.country_id = country.country_id
    LEFT JOIN rental ON customer.customer_id = rental.customer_id
    LEFT JOIN payment ON rental.rental_id = payment.rental_id
    WHERE
        country.country IN ('Switzerland', 'France', 'Germany')
    GROUP BY
        customer.customer_id, country.country
)

-- Requête principale pour obtenir les clients dont la dépense moyenne par location est supérieure à 3.0
SELECT
    id,
    nom,
    email,
    pays,
    nb_locations,
    depense_totale,
    depense_moyenne
FROM
    ClientStats
WHERE
    depense_moyenne > 3.0
ORDER BY
    pays,
    nom;
-- END Exercice 15



-- BEGIN Exercice 16a
SELECT COUNT(*) AS nb_paiements_inf_ou_egaux_a_9
FROM payment
WHERE amount <= 9;
-- END Exercice 16a

-- BEGIN Exercice 16b
DELETE FROM payment
WHERE amount <= 9;
-- END Exercice 16b

-- BEGIN Exercice 16c
SELECT COUNT(*) AS nb_paiements_apres_effacement
FROM payment
WHERE amount <= 9;
-- END Exercice 16c


-- BEGIN Exercice 17
UPDATE payment
SET
    amount = amount * 1.5,  -- Augmentation de 50% pour les paiements de plus de 4$
    payment_date = CURRENT_TIMESTAMP;  -- Mise à jour de la date de paiement avec la date courante du serveur
WHERE
    amount > 4;
-- END Exercice 17


-- BEGIN Exercice 18
INSERT INTO customer (store_id, first_name, last_name, email, address_id, active)
VALUES (
    1,  -- Magasin 1
    'Guillaume',  -- Prénom
    'Ransome',  -- Nom
    'gr@bluewin.ch',  -- E-mail
    (
        -- Sous-requête pour récupérer l'identifiant de l'adresse ou l'insérer si elle n'existe pas
        INSERT INTO address (address, city_id, phone)
        VALUES (
            'Rue du centre, 1260 Nyon',  -- Adresse
            (
                -- Sous-requête pour récupérer l'identifiant de la ville ou l'insérer si elle n'existe pas
                INSERT INTO city (city, country_id)
                VALUES (
                    'Nyon',  -- Ville
                    (
                        -- Sous-requête pour récupérer l'identifiant du pays ou l'insérer si elle n'existe pas
                        INSERT INTO country (country)
                        VALUES ('Switzerland')
                        ON CONFLICT (country) DO NOTHING
                        RETURNING country_id
                    )
                )
                ON CONFLICT (city, country_id) DO NOTHING
                RETURNING city_id
            ),
            '021/360.00.00'  -- Téléphone
        )
        ON CONFLICT (address, city_id, phone) DO NOTHING
        RETURNING address_id
    ),
    1  -- Actif
);
-- END Exercice 18

-- BEGIN Exercice 18d
SELECT * FROM customer WHERE first_name = 'Guillaume' AND last_name = 'Ransome';
-- END Exercice 18d
