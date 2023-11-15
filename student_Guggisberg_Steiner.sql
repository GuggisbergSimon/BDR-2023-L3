SET search_path = pagila;

-- BEGIN Exercice 01
SELECT customer_id,
       last_name AS nom,
       email     AS email
FROM customer as c
WHERE c.first_name = 'PHYLLIS'
  AND c.store_id = 1
ORDER BY c.customer_id DESC;
-- END Exercice 01

-- BEGIN Exercice 02
SELECT title        AS titre,
       release_year AS annee_sortie
FROM film AS f
WHERE f.rating = 'R'
  AND f.length < 60
  AND f.replacement_cost = 12.99
ORDER BY f.title;
-- END Exercice 02

-- BEGIN Exercice 03
/* JOIN marche aussi à la place de LEFT JOIN */
SELECT country     AS pays,
       city        AS ville,
       postal_code AS "numéro postal"
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
SELECT customer.customer_id,
       customer.first_name AS prenom,
       customer.last_name  AS nom
FROM customer
         JOIN address ON customer.address_id = address.address_id
         JOIN city ON address.city_id = city.city_id
WHERE city.city_id = 171
  AND customer.store_id = 1
ORDER BY customer.first_name;
-- END Exercice 04

-- BEGIN Exercice 05
SELECT c1.first_name AS prenom_1,
       c1.last_name  AS nom_1,
       c2.first_name AS prenom_2,
       c2.last_name  AS nom_2
FROM rental r1
         JOIN rental r2 ON r1.inventory_id = r2.inventory_id AND r1.rental_id < r2.rental_id
         JOIN customer c1 ON r1.customer_id = c1.customer_id
         JOIN customer c2 ON r2.customer_id = c2.customer_id
WHERE c1.customer_id < c2.customer_id
ORDER BY prenom_1, nom_1, prenom_2, nom_2;
-- END Exercice 05

-- BEGIN Exercice 06
SELECT DISTINCT actor.last_name  AS nom,
                actor.first_name AS prenom
FROM actor
WHERE actor_id IN (SELECT actor_id
                   FROM film_actor
                   WHERE film_id IN (SELECT film_id
                                     FROM film_category
                                     WHERE category_id IN (SELECT category_id
                                                           FROM category
                                                           WHERE name = 'Horror')))
  AND (actor.first_name LIKE 'K%' OR actor.last_name LIKE 'D%');
-- END Exercice 06

-- BEGIN Exercice 07a
/* rental_rate est le prix pour une rental_duration. rental_duration est en jour */
SELECT film.film_id                            AS id,
       film.title                              AS titre,
       film.rental_rate / film.rental_duration AS prix_de_location_par_jour
FROM film
         LEFT JOIN (SELECT DISTINCT inventory.film_id
                    FROM inventory
                             JOIN rental ON inventory.inventory_id = rental.inventory_id) AS rented_films
                   ON film.film_id = rented_films.film_id
WHERE film.rental_rate / film.rental_duration <= 1.00
  AND rented_films.film_id IS NULL;
-- END Exercice 07a

-- BEGIN Exercice 07b
SELECT film_id                       AS id,
       title                         AS titre,
       rental_rate / rental_duration AS prix_de_location_par_jour
FROM film
WHERE rental_rate / rental_duration <= 1.00
  AND NOT EXISTS (SELECT 1
                  FROM inventory
                           JOIN rental ON inventory.inventory_id = rental.inventory_id
                  WHERE inventory.film_id = film.film_id);
-- END Exercice 07b

-- BEGIN Exercice 08a
SELECT customer.customer_id AS id,
       customer.last_name   AS nom,
       customer.first_name  AS prenom
FROM customer
         JOIN address ON customer.address_id = address.address_id
         JOIN city ON address.city_id = city.city_id
         JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Spain'
  AND EXISTS (SELECT 1
              FROM rental
              WHERE rental.customer_id = customer.customer_id
                AND rental.return_date IS NULL);
-- END Exercice 08a

-- BEGIN Exercice 08b
SELECT customer.customer_id AS id,
       customer.last_name   AS nom,
       customer.first_name  AS prenom
FROM customer
         JOIN address ON customer.address_id = address.address_id
         JOIN city ON address.city_id = city.city_id
         JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Spain'
  AND customer.customer_id IN (SELECT DISTINCT rental.customer_id
                               FROM rental
                               WHERE rental.return_date IS NULL);
-- END Exercice 08b

-- BEGIN Exercice 08c
SELECT customer.customer_id AS id,
       customer.last_name   AS nom,
       customer.first_name  AS prenom
FROM rental,
     customer
         JOIN address ON customer.address_id = address.address_id
         JOIN city ON address.city_id = city.city_id
         JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Spain'
  AND customer.customer_id = rental.customer_id
  AND rental.return_date IS NULL;
-- END Exercice 08c

-- BEGIN Exercice 09 (Bonus)
/* TODO retourne vide */
SELECT customer.customer_id,
       customer.first_name AS prenom,
       customer.last_name  AS nom
FROM customer
WHERE customer.customer_id IN (SELECT rental.customer_id
                               FROM rental
                                        JOIN inventory ON rental.inventory_id = inventory.inventory_id
                                        JOIN film_actor ON inventory.film_id = film_actor.film_id
                                        JOIN actor ON film_actor.actor_id = actor.actor_id
                               WHERE actor.first_name = 'EMILY'
                                 AND actor.last_name = 'DEE')
  AND customer.customer_id NOT IN (SELECT customer.customer_id
                                   FROM rental
                                            JOIN inventory ON rental.inventory_id = inventory.inventory_id
                                            JOIN film_actor ON inventory.film_id = film_actor.film_id
                                            JOIN actor ON film_actor.actor_id = actor.actor_id
                                   WHERE actor.first_name = 'EMILY'
                                     AND actor.last_name = 'DEE'
                                     AND rental.return_date IS NULL);
-- END Exercice 09 (Bonus)

-- BEGIN Exercice 10
SELECT film.title                 AS titre,
       COUNT(film_actor.actor_id) AS nb_acteurs
FROM film
         JOIN film_actor ON film.film_id = film_actor.film_id
         JOIN actor ON film_actor.actor_id = actor.actor_id
         JOIN film_category ON film.film_id = film_category.film_id
         JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Drama'
GROUP BY film.film_id,
         film.title
HAVING COUNT(film_actor.actor_id) < 5
ORDER BY nb_acteurs DESC;
-- END Exercice 10

-- BEGIN Exercice 11
SELECT category.category_id         AS id,
       category.name                AS nom,
       COUNT(film_category.film_id) AS nb_films
FROM category
         JOIN film_category ON category.category_id = film_category.category_id
GROUP BY category.category_id,
         category.name
HAVING COUNT(film_category.film_id) > 65
ORDER BY nb_films;
-- END Exercice 11

-- BEGIN Exercice 12
SELECT film.film_id AS id,
       film.title   AS titre,
       film.length  AS duree
FROM film
WHERE film.length = (SELECT MIN(length)
                     FROM film);
-- END Exercice 12


-- BEGIN Exercice 13a
SELECT film.film_id AS id,
       film.title   AS titre
FROM film
WHERE film.film_id IN (SELECT film_actor.film_id
                       FROM film_actor
                       WHERE film_actor.actor_id IN
                             (SELECT actor.actor_id
                              FROM actor
                                       JOIN film_actor ON actor.actor_id = film_actor.actor_id
                              GROUP BY actor.actor_id
                              HAVING COUNT(film_actor.film_id) > 40))
ORDER BY film.title;
-- END Exercice 13a


-- BEGIN Exercice 13b
SELECT DISTINCT film.film_id AS id,
                film.title   AS titre
FROM film
         JOIN film_actor ON film.film_id = film_actor.film_id
         JOIN (SELECT actor.actor_id
               FROM actor
                        JOIN film_actor ON actor.actor_id = film_actor.actor_id
               GROUP BY actor.actor_id
               HAVING COUNT(film_actor.film_id) > 40) AS famous_actors
              ON film_actor.actor_id = famous_actors.actor_id
ORDER BY film.title;
-- END Exercice 13b

-- BEGIN Exercice 14
/* length est en minutes. la conversion minutes->jours est divisé par 60 * 8 car uniquement 8h par jour (petit joueur) */
SELECT CEIL(SUM(length) / (60 * 8)) AS nb_jours
FROM film;
-- END Exercice 14


-- BEGIN Exercice 15
-- Requête pour obtenir le montant total dépensé et le nombre de locations pour chaque client
WITH ClientStats AS (SELECT customer.customer_id    AS id,
                            customer.last_name      AS nom,
                            customer.email,
                            country.country         AS pays,
                            COUNT(rental.rental_id) AS nb_locations,
                            SUM(payment.amount)     AS depense_totale,
                            AVG(payment.amount)     AS depense_moyenne
                     FROM customer
                              JOIN address ON customer.address_id = address.address_id
                              JOIN city ON address.city_id = city.city_id
                              JOIN country ON city.country_id = country.country_id
                              LEFT JOIN rental ON customer.customer_id = rental.customer_id
                              LEFT JOIN payment ON rental.rental_id = payment.rental_id
                     WHERE country.country IN ('Switzerland', 'France', 'Germany')
                     GROUP BY customer.customer_id, country.country)

-- Requête principale pour obtenir les clients dont la dépense moyenne par location est supérieure à 3.0
SELECT id,
       nom,
       email,
       pays,
       nb_locations,
       depense_totale,
       depense_moyenne
FROM ClientStats
WHERE depense_moyenne > 3.0
ORDER BY pays,
         nom;
-- END Exercice 15


-- BEGIN Exercice 16a
SELECT COUNT(*) AS nb_paiements_inf_ou_egaux_a_9
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
SELECT COUNT(*) AS nb_paiements_apres_effacement
FROM payment
WHERE amount <= 9;
-- END Exercice 16c


-- BEGIN Exercice 17
UPDATE payment
SET amount       = amount * 1.5, -- Augmentation de 50% pour les paiements de plus de 4$
    payment_date = CURRENT_TIMESTAMP; -- Mise à jour de la date de paiement avec la date courante du serveur
WHERE
    amount > 4;
-- END Exercice 17


-- BEGIN Exercice 18
INSERT INTO customer (store_id, first_name, last_name, email, address_id, active)
VALUES (1, -- Magasin 1
        'Guillaume', -- Prénom
        'Ransome', -- Nom
        'gr@bluewin.ch', -- E-mail
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
        1 -- Actif
       );
-- END Exercice 18

-- BEGIN Exercice 18d
SELECT *
FROM customer
WHERE first_name = 'Guillaume'
  AND last_name = 'Ransome';
-- END Exercice 18d
