-- =====================================================
-- PEER LEARNING - Données de départ
-- Données de démonstration.
-- =====================================================

INSERT INTO categories (id, nom) VALUES
    (1, 'Informatique'),
    (2, 'Mathématiques');

INSERT INTO tuteurs (id, prenom, nom, matiere, bio, icone, note) VALUES
    (1, 'Marie',  'Makasa', 'Informatique',  'Étudiante en Master Informatique, passionnée par l''enseignement et l''open source.',         'fa-laptop-code',         4.8),
    (2, 'Pierre', 'Mbulu',  'Mathématiques', 'Doctorant en mathématiques appliquées, spécialisé en algorithmique et théorie des graphes.', 'fa-chalkboard-teacher',  4.6),
    (3, 'Sophie', 'Bena',   'Informatique',  'Développeuse full-stack avec 5 ans d''expérience. Experte en bases de données.',              'fa-user-tie',            4.9),
    (4, 'Lucas',  'Mponge', 'Informatique',  'Développeur web freelance et créateur de contenu éducatif sur YouTube.',                     'fa-code',                4.7),
    (5, 'Emma',   'Leka',   'Mathématiques', 'Étudiante en Master de Data Science, adepte de la pédagogie par l''exemple.',                'fa-chart-pie',           4.4),
    (6, 'Thomas', 'Moka',   'Physique',      'Étudiant en physique fondamentale, passionné par la vulgarisation scientifique.',           'fa-atom',                4.5);

INSERT INTO cours (id, titre, description, categorie_id, tuteur_id, duree_heures, niveau, note, nb_etudiants, prerequis, icone) VALUES
    (1, 'Introduction à la Programmation', 'Apprenez les bases de la programmation avec Python. Variables, boucles, fonctions et structures de données.', 1, 1, 12, 'Débutant',      4.8, 145, 'Aucun prérequis nécessaire',                       'fa-laptop-code'),
    (2, 'Mathématiques pour l''Informatique', 'Logique, ensembles, graphes et probabilités. Les mathématiques essentielles pour tout informaticien.',     2, 2, 15, 'Intermédiaire', 4.6,  98, 'Niveau Diplôme d''État (section scientifique) recommandé', 'fa-ruler-combined'),
    (3, 'Bases de Données SQL', 'Conception et manipulation de bases de données relationnelles avec le langage SQL.',                                    1, 3, 10, 'Débutant',      4.9, 203, 'Connaissances de base en informatique',            'fa-database'),
    (4, 'Développement Web Frontend', 'Créez des sites web interactifs avec HTML5, CSS3 et JavaScript moderne.',                                        1, 4, 18, 'Intermédiaire', 4.7, 312, 'Notions de HTML/CSS de base',                      'fa-globe'),
    (5, 'Algorithmes et Complexité', 'Analyse d''algorithmes, structures de données avancées et optimisation.',                                          1, 2, 20, 'Avancé',        4.5,  67, 'Programmation de base + mathématiques',            'fa-cogs'),
    (6, 'Statistiques Appliquées', 'Analyse de données, tests statistiques et interprétation des résultats.',                                           2, 5, 14, 'Intermédiaire', 4.4, 156, 'Probabilités de base',                             'fa-chart-bar');

INSERT INTO chapitres (cours_id, ordre, titre) VALUES
    (1, 1, 'Variables et types de données'),
    (1, 2, 'Structures conditionnelles (if/else)'),
    (1, 3, 'Boucles (for, while)'),
    (1, 4, 'Fonctions et portée'),
    (1, 5, 'Listes et dictionnaires'),
    (1, 6, 'Introduction aux fichiers'),

    (2, 1, 'Logique propositionnelle'),
    (2, 2, 'Théorie des ensembles'),
    (2, 3, 'Relations et fonctions'),
    (2, 4, 'Graphes et arbres'),
    (2, 5, 'Combinatoire'),
    (2, 6, 'Probabilités de base'),

    (3, 1, 'Modèle relationnel'),
    (3, 2, 'Création de tables (CREATE)'),
    (3, 3, 'Requêtes de sélection (SELECT)'),
    (3, 4, 'Jointures (JOIN)'),
    (3, 5, 'Agrégations (GROUP BY)'),
    (3, 6, 'Contraintes et clés'),

    (4, 1, 'Structure HTML5 sémantique'),
    (4, 2, 'CSS3 : Flexbox et Grid'),
    (4, 3, 'Sélecteurs et spécificité'),
    (4, 4, 'JavaScript ES6+'),
    (4, 5, 'Manipulation du DOM'),
    (4, 6, 'Événements et formulaires'),

    (5, 1, 'Notations asymptotiques (O, Ω, Θ)'),
    (5, 2, 'Structures de données avancées'),
    (5, 3, 'Algorithmes de tri'),
    (5, 4, 'Parcours de graphes (BFS, DFS)'),
    (5, 5, 'Programmation dynamique'),
    (5, 6, 'Problèmes NP-complets'),

    (6, 1, 'Statistiques descriptives'),
    (6, 2, 'Distributions de probabilité'),
    (6, 3, 'Estimation par intervalle'),
    (6, 4, 'Tests d''hypothèses'),
    (6, 5, 'Régression linéaire'),
    (6, 6, 'Analyse de variance (ANOVA)');

-- Seul l'aide-mémoire SQLite est un vrai fichier (static/ressources/).
-- Les autres ressources sont fictives : fichier = NULL.
INSERT INTO ressources (titre, description, format, taille, fichier, cours_id) VALUES
    ('Aide-mémoire SQLite',      'Les commandes SQL essentielles, avec des exemples sur la base de ce site', 'SQL', '4 KB',   'aide-memoire-sqlite.sql', 3),
    ('Cheat Sheet Python',       'Résumé des commandes et syntaxes Python essentielles',                    'PDF', '245 KB', NULL, 1),
    ('Guide SQL Complet',        'Guide de référence pour toutes les commandes SQL',                        'PDF', '1.2 MB', NULL, 3),
    ('Exercices d''Algorithmes', '50 exercices corrigés de niveau débutant à avancé',                       'PDF', '890 KB', NULL, 5),
    ('Template HTML/CSS',        'Template responsive pour démarrer un projet web',                         'ZIP', '156 KB', NULL, 4),
    ('Formules de Probabilités', 'Récapitulatif des lois de probabilités usuelles',                         'PDF', '320 KB', NULL, 6),
    ('Projet Mini-Jeu JS',       'Code source d''un jeu en JavaScript pour s''entraîner',                   'ZIP', '45 KB',  NULL, 4);

INSERT INTO faq (question, reponse, ordre) VALUES
    ('Qu''est-ce que le peer learning ?',
     'C''est l''apprentissage entre pairs : des étudiants plus avancés expliquent une matière à d''autres étudiants, avec leurs mots et leurs propres astuces.', 1),
    ('Les cours sont-ils gratuits ?',
     'Oui. Tous les cours et toutes les ressources de Peer Learning sont gratuits.', 2),
    ('Comment suivre un cours ?',
     'Choisissez un cours dans le catalogue, consultez son programme puis contactez-nous via la page Contact pour connaître les prochaines séances.', 3),
    ('Comment devenir tuteur ?',
     'Remplissez le formulaire de la page « Devenir tuteur ». Nous étudions chaque candidature et revenons vers vous par email.', 4),
    ('Faut-il un niveau particulier pour être tuteur ?',
     'Il faut maîtriser la matière que vous souhaitez enseigner (en général avoir validé le cours) et avoir envie de partager.', 5),
    ('Puis-je proposer une nouvelle ressource ?',
     'Bien sûr ! Envoyez-la-nous via la page Contact avec le sujet « Suggestion ».', 6);
