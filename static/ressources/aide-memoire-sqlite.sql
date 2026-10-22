-- =====================================================
-- AIDE-MÉMOIRE SQLite - Peer Learning
-- Toutes les requêtes fonctionnent sur la base du site
-- (fichier peerlearning.db). Pour les essayer :
--     sqlite3 peerlearning.db
-- puis copiez-collez une requête.
-- =====================================================

-- ---------- Commandes de l'outil sqlite3 (pas du SQL) ----------
-- .tables              liste les tables
-- .schema cours        affiche la structure d'une table
-- .headers on          affiche le nom des colonnes
-- .mode box            affichage en tableau lisible
-- .quit                quitter

-- ---------- Lire des données : SELECT ----------
SELECT * FROM cours;                               -- toutes les colonnes
SELECT titre, niveau FROM cours;                   -- certaines colonnes
SELECT titre FROM cours WHERE niveau = 'Débutant'; -- filtrer
SELECT titre FROM cours WHERE titre LIKE '%SQL%';  -- recherche partielle
SELECT titre, note FROM cours ORDER BY note DESC;  -- trier
SELECT titre FROM cours ORDER BY nb_etudiants DESC LIMIT 3; -- les 3 premiers

-- ---------- Fonctions d'agrégation ----------
SELECT COUNT(*) FROM cours;                        -- nombre de lignes
SELECT SUM(nb_etudiants) FROM cours;               -- somme
SELECT AVG(note) FROM cours;                       -- moyenne
SELECT MIN(duree_heures), MAX(duree_heures) FROM cours;

-- Regrouper : nombre de cours par niveau
SELECT niveau, COUNT(*) AS nb FROM cours GROUP BY niveau;

-- ---------- Jointures : relier plusieurs tables ----------
-- INNER JOIN : chaque cours avec le nom de son tuteur
SELECT cours.titre, tuteurs.prenom, tuteurs.nom
FROM cours
JOIN tuteurs ON tuteurs.id = cours.tuteur_id;

-- LEFT JOIN : tous les tuteurs, même ceux sans cours
SELECT tuteurs.prenom, COUNT(cours.id) AS nb_cours
FROM tuteurs
LEFT JOIN cours ON cours.tuteur_id = tuteurs.id
GROUP BY tuteurs.id;

-- ---------- Modifier des données ----------
INSERT INTO faq (question, reponse, ordre)
VALUES ('Ma question ?', 'Ma réponse.', 10);

UPDATE faq SET reponse = 'Réponse corrigée.' WHERE question = 'Ma question ?';

DELETE FROM faq WHERE question = 'Ma question ?';

-- Attention : un UPDATE ou un DELETE sans WHERE touche TOUTES les lignes !
