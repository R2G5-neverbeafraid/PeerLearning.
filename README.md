# Peer Learning

Plateforme d'apprentissage collaboratif : des étudiants qui enseignent aux étudiants.
Projet universitaire L1 — Université Protestante au Congo.
Un projet **by 25 Labs**, studio de Kinshasa.

**Technologies :** HTML5, CSS3, Bootstrap 5 (grille), Font Awesome, **Python / Flask** et **SQLite**.

## Lancer le site

Il faut [Python 3.10+](https://www.python.org/downloads/).

```bash
# 1. Créer un environnement virtuel (une seule fois)
python -m venv venv
source venv/bin/activate        # Windows : venv\Scripts\activate

# 2. Installer les dépendances
pip install -r requirements.txt

# 3. Lancer le serveur
python app.py
```

Ouvrez ensuite <http://127.0.0.1:5000>.

Au premier lancement, la base `peerlearning.db` est créée toute seule à partir de
`database/schema.sql` (les tables) et `database/seed.sql` (les données).
Pour la remettre à zéro : `flask --app app init-db`.

## Mettre le site en ligne (Render)

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/R2G5-neverbeafraid/PeerLearning.)

Le fichier `render.yaml` contient toute la configuration : Render installe les
dépendances, crée la base SQLite puis lance le site avec `gunicorn`.
Chaque `git push` sur la branche suivie redéploie le site automatiquement.

Limites de l'offre gratuite :
- le site se met en veille après 15 minutes sans visite (la visite suivante prend ~30 s) ;
- la base est recréée à chaque redémarrage : les messages et candidatures envoyés
  par les visiteurs ne sont pas conservés.

## Organisation des fichiers

```
app.py                  Le serveur : une fonction Python par page + les requêtes SQL
render.yaml             Configuration du déploiement sur Render
database/
  schema.sql            Création des tables (CREATE TABLE)
  seed.sql              Données de départ (INSERT INTO)
  exercices.sql         10 exercices SQL corrigés sur la base du site
templates/              Pages HTML (gabarits Jinja)
  base.html             Menu + pied de page communs à toutes les pages
  macros.html           Morceaux réutilisables (carte de cours, étoiles...)
static/
  style.css             Feuille de style
  ressources/           Fichiers téléchargeables
tests/test_app.py       Tests automatiques (python -m pytest)
```

## La base de données

| Table          | Contenu                                    | Relations                       |
|----------------|--------------------------------------------|---------------------------------|
| `categories`   | Matières (Informatique, Mathématiques)     |                                 |
| `tuteurs`      | Étudiants tuteurs                          |                                 |
| `cours`        | Cours du catalogue                         | → `categories`, → `tuteurs`     |
| `chapitres`    | Programme de chaque cours                  | → `cours`                       |
| `ressources`   | Documents téléchargeables                  | → `cours` (facultatif)          |
| `faq`          | Questions fréquentes                       |                                 |
| `messages`     | Messages envoyés depuis la page Contact    |                                 |
| `candidatures` | Candidatures « Devenir tuteur »            |                                 |

Les nombres affichés (statistiques de l'accueil, nombre de cours et d'étudiants
par tuteur) sont **calculés en SQL** avec `COUNT` et `SUM` : ils restent toujours
cohérents avec les données.

### Explorer la base

Avec l'outil en ligne de commande [`sqlite3`](https://sqlite.org/download.html)
ou une application graphique comme [DB Browser for SQLite](https://sqlitebrowser.org/) :

```bash
sqlite3 peerlearning.db
sqlite> .headers on
sqlite> .mode box
sqlite> SELECT titre, niveau FROM cours;
```

Pour apprendre, suivez `database/exercices.sql` (du `SELECT` simple aux jointures),
et gardez `static/ressources/aide-memoire-sqlite.sql` sous la main.
Envoyez un message depuis la page Contact, puis retrouvez-le avec
`SELECT * FROM messages;` !

### Bonne pratique de sécurité

Dans `app.py`, les valeurs saisies par les visiteurs sont toujours passées avec
des `?` :

```python
db.execute("SELECT * FROM cours WHERE id = ?", (cours_id,))
```

Ne jamais construire une requête en collant du texte saisi par l'utilisateur
(`"... WHERE titre = '" + recherche + "'"`) : c'est la porte ouverte à
l'**injection SQL**. Un test le vérifie dans `tests/test_app.py`.

## Tests

```bash
python -m pytest
```
