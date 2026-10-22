-- =====================================================
-- PEER LEARNING - Schéma de la base SQLite
-- Exécuté automatiquement au premier lancement de app.py,
-- ou à la demande avec : flask --app app init-db
-- Chaque table est supprimée puis recréée : relancer ce script
-- remet la base à zéro.
-- =====================================================

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS candidatures;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS faq;
DROP TABLE IF EXISTS ressources;
DROP TABLE IF EXISTS chapitres;
DROP TABLE IF EXISTS cours;
DROP TABLE IF EXISTS tuteurs;
DROP TABLE IF EXISTS categories;

-- Matières (Informatique, Mathématiques, ...)
CREATE TABLE categories (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    nom  TEXT    NOT NULL UNIQUE
);

-- Étudiants qui donnent des cours
CREATE TABLE tuteurs (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    prenom   TEXT    NOT NULL,
    nom      TEXT    NOT NULL,
    matiere  TEXT    NOT NULL,
    bio      TEXT    NOT NULL,
    icone    TEXT    NOT NULL DEFAULT 'fa-user',
    note     REAL    NOT NULL CHECK (note BETWEEN 0 AND 5)
);

-- Un cours appartient à une catégorie et est donné par un tuteur
CREATE TABLE cours (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    titre         TEXT    NOT NULL,
    description   TEXT    NOT NULL,
    categorie_id  INTEGER NOT NULL REFERENCES categories(id),
    tuteur_id     INTEGER NOT NULL REFERENCES tuteurs(id),
    duree_heures  INTEGER NOT NULL CHECK (duree_heures > 0),
    niveau        TEXT    NOT NULL CHECK (niveau IN ('Débutant', 'Intermédiaire', 'Avancé')),
    note          REAL    NOT NULL CHECK (note BETWEEN 0 AND 5),
    nb_etudiants  INTEGER NOT NULL DEFAULT 0,
    prerequis     TEXT    NOT NULL,
    icone         TEXT    NOT NULL DEFAULT 'fa-book'
);

-- Programme d'un cours : plusieurs chapitres par cours (relation 1-N)
CREATE TABLE chapitres (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    cours_id  INTEGER NOT NULL REFERENCES cours(id) ON DELETE CASCADE,
    ordre     INTEGER NOT NULL,
    titre     TEXT    NOT NULL
);

-- Documents téléchargeables (fichier NULL = pas encore disponible)
CREATE TABLE ressources (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    titre        TEXT    NOT NULL,
    description  TEXT    NOT NULL,
    format       TEXT    NOT NULL,
    taille       TEXT    NOT NULL,
    fichier      TEXT,
    cours_id     INTEGER REFERENCES cours(id) ON DELETE SET NULL
);

CREATE TABLE faq (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    question  TEXT    NOT NULL,
    reponse   TEXT    NOT NULL,
    ordre     INTEGER NOT NULL DEFAULT 0
);

-- Messages envoyés depuis la page Contact
CREATE TABLE messages (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    nom      TEXT    NOT NULL,
    email    TEXT    NOT NULL,
    sujet    TEXT    NOT NULL,
    message  TEXT    NOT NULL,
    cree_le  TEXT    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Candidatures envoyées depuis la page Devenir tuteur
CREATE TABLE candidatures (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    nom           TEXT    NOT NULL,
    email         TEXT    NOT NULL,
    matiere       TEXT    NOT NULL,
    niveau_etude  TEXT    NOT NULL,
    motivation    TEXT    NOT NULL,
    cree_le       TEXT    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
