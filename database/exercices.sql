-- =====================================================
-- EXERCICES SQL sur la base Peer Learning
-- Lancez : sqlite3 peerlearning.db
-- puis tapez .headers on et .mode box pour un affichage lisible.
-- Essayez d'écrire chaque requête vous-même avant de lire la solution.
-- =====================================================

-- 1. Afficher le titre et la durée de tous les cours.
SELECT titre, duree_heures FROM cours;

-- 2. Afficher les cours de niveau « Intermédiaire ».
SELECT titre FROM cours WHERE niveau = 'Intermédiaire';

-- 3. Afficher les cours qui durent plus de 14 heures, du plus long au plus court.
SELECT titre, duree_heures FROM cours
WHERE duree_heures > 14
ORDER BY duree_heures DESC;

-- 4. Combien d'étudiants au total sont inscrits ?
SELECT SUM(nb_etudiants) AS total FROM cours;

-- 5. Afficher chaque cours avec le nom de sa catégorie.
SELECT cours.titre, categories.nom AS categorie
FROM cours
JOIN categories ON categories.id = cours.categorie_id;

-- 6. Combien de cours donne chaque tuteur ? (y compris ceux qui n'en ont aucun)
SELECT tuteurs.prenom || ' ' || tuteurs.nom AS tuteur,
       COUNT(cours.id) AS nb_cours
FROM tuteurs
LEFT JOIN cours ON cours.tuteur_id = tuteurs.id
GROUP BY tuteurs.id
ORDER BY nb_cours DESC;

-- 7. Afficher le programme (chapitres dans l'ordre) du cours « Bases de Données SQL ».
SELECT chapitres.ordre, chapitres.titre
FROM chapitres
JOIN cours ON cours.id = chapitres.cours_id
WHERE cours.titre = 'Bases de Données SQL'
ORDER BY chapitres.ordre;

-- 8. Note moyenne des cours par catégorie, arrondie à 1 décimale.
SELECT categories.nom, ROUND(AVG(cours.note), 1) AS note_moyenne
FROM cours
JOIN categories ON categories.id = cours.categorie_id
GROUP BY categories.id;

-- 9. Lire les messages reçus via la page Contact (les plus récents d'abord).
SELECT nom, sujet, cree_le FROM messages ORDER BY cree_le DESC;

-- 10. Lire les candidatures de tuteurs.
SELECT nom, matiere, niveau_etude, cree_le FROM candidatures;

-- Bonus : ajouter un nouveau cours de physique pour Thomas Moka (tuteur n°6),
-- puis rechargez la page /cours du site pour le voir apparaître !
-- INSERT INTO categories (nom) VALUES ('Physique');
-- INSERT INTO cours (titre, description, categorie_id, tuteur_id, duree_heures,
--                    niveau, note, nb_etudiants, prerequis, icone)
-- VALUES ('Mécanique du point', 'Cinématique, lois de Newton et énergie.',
--         3, 6, 12, 'Débutant', 4.5, 0, 'Aucun prérequis nécessaire', 'fa-atom');
