"""
PEER LEARNING - Application Flask + SQLite
Projet universitaire L1

Lancer le site :  python app.py   puis ouvrir http://127.0.0.1:5000
La base peerlearning.db est créée automatiquement au premier lancement
(à partir de database/schema.sql et database/seed.sql).
"""

import os
import re
import sqlite3
from pathlib import Path

from flask import Flask, abort, flash, g, redirect, render_template, request, url_for

BASE_DIR = Path(__file__).resolve().parent

app = Flask(__name__)
app.config["DATABASE"] = os.environ.get("DATABASE", str(BASE_DIR / "peerlearning.db"))
# Clé utilisée pour signer les messages "flash" : à changer en production
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "dev-peer-learning")


# -----------------------------------------------------
# BASE DE DONNÉES
# -----------------------------------------------------

def init_db():
    """(Re)crée toutes les tables puis insère les données de départ."""
    connexion = sqlite3.connect(app.config["DATABASE"])
    for fichier in ("schema.sql", "seed.sql"):
        connexion.executescript((BASE_DIR / "database" / fichier).read_text(encoding="utf-8"))
    connexion.commit()
    connexion.close()


def get_db():
    """Une connexion par requête HTTP, stockée dans g et fermée à la fin."""
    if "db" not in g:
        if not Path(app.config["DATABASE"]).exists():
            init_db()
        g.db = sqlite3.connect(app.config["DATABASE"])
        # Row permet d'écrire ligne["titre"] au lieu de ligne[0]
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA foreign_keys = ON")
    return g.db


@app.teardown_appcontext
def close_db(exception=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()


@app.cli.command("init-db")
def init_db_command():
    """flask --app app init-db : remet la base à zéro."""
    init_db()
    print("Base de données initialisée.")


# Requête commune : un cours avec sa catégorie et son tuteur (jointures)
SELECT_COURS = """
    SELECT cours.*,
           categories.nom AS categorie,
           tuteurs.prenom || ' ' || tuteurs.nom AS tuteur
    FROM cours
    JOIN categories ON categories.id = cours.categorie_id
    JOIN tuteurs ON tuteurs.id = cours.tuteur_id
"""

NIVEAUX = ("Débutant", "Intermédiaire", "Avancé")
EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


# -----------------------------------------------------
# PAGES
# -----------------------------------------------------

@app.route("/")
def index():
    db = get_db()
    stats = db.execute("""
        SELECT (SELECT COUNT(*) FROM cours)                   AS nb_cours,
               (SELECT COUNT(*) FROM tuteurs)                 AS nb_tuteurs,
               (SELECT COALESCE(SUM(nb_etudiants), 0) FROM cours) AS nb_etudiants,
               (SELECT COUNT(*) FROM ressources)              AS nb_ressources
    """).fetchone()
    populaires = db.execute(SELECT_COURS + " ORDER BY cours.nb_etudiants DESC LIMIT 3").fetchall()
    # Programme du cours le plus suivi, affiché dans l'aperçu du bandeau d'accueil
    chapitres_vedette = []
    if populaires:
        chapitres_vedette = db.execute(
            "SELECT titre FROM chapitres WHERE cours_id = ? ORDER BY ordre LIMIT 4",
            (populaires[0]["id"],),
        ).fetchall()
    categories = db.execute("""
        SELECT categories.nom, COUNT(cours.id) AS nb_cours
        FROM categories
        LEFT JOIN cours ON cours.categorie_id = categories.id
        GROUP BY categories.id
        ORDER BY categories.nom
    """).fetchall()
    return render_template(
        "index.html", stats=stats, populaires=populaires,
        chapitres_vedette=chapitres_vedette, categories=categories,
    )


@app.route("/cours")
def courses():
    db = get_db()
    recherche = request.args.get("q", "").strip()
    categorie = request.args.get("categorie", "")
    niveau = request.args.get("niveau", "")

    # On construit la clause WHERE au fur et à mesure.
    # Les valeurs passent TOUJOURS par des "?" : jamais de concaténation
    # de texte saisi par l'utilisateur (protection contre l'injection SQL).
    conditions, parametres = [], []
    if recherche:
        conditions.append("(cours.titre LIKE ? OR cours.description LIKE ?)")
        parametres += [f"%{recherche}%", f"%{recherche}%"]
    if categorie:
        conditions.append("categories.nom = ?")
        parametres.append(categorie)
    if niveau in NIVEAUX:
        conditions.append("cours.niveau = ?")
        parametres.append(niveau)

    sql = SELECT_COURS
    if conditions:
        sql += " WHERE " + " AND ".join(conditions)
    sql += " ORDER BY cours.id"

    liste = db.execute(sql, parametres).fetchall()
    categories = db.execute("SELECT nom FROM categories ORDER BY nom").fetchall()
    return render_template(
        "courses.html", cours=liste, categories=categories, niveaux=NIVEAUX,
        recherche=recherche, categorie=categorie, niveau=niveau,
    )


@app.route("/cours/<int:cours_id>")
def course(cours_id):
    db = get_db()
    c = db.execute(SELECT_COURS + " WHERE cours.id = ?", (cours_id,)).fetchone()
    if c is None:
        abort(404)
    chapitres = db.execute(
        "SELECT titre FROM chapitres WHERE cours_id = ? ORDER BY ordre", (cours_id,)
    ).fetchall()
    tuteur = db.execute("SELECT * FROM tuteurs WHERE id = ?", (c["tuteur_id"],)).fetchone()
    ressources = db.execute(
        "SELECT * FROM ressources WHERE cours_id = ? ORDER BY id", (cours_id,)
    ).fetchall()
    similaires = db.execute(
        SELECT_COURS + " WHERE cours.categorie_id = ? AND cours.id != ? ORDER BY cours.note DESC LIMIT 3",
        (c["categorie_id"], cours_id),
    ).fetchall()
    precedent = db.execute(
        "SELECT id, titre FROM cours WHERE id < ? ORDER BY id DESC LIMIT 1", (cours_id,)
    ).fetchone()
    suivant = db.execute(
        "SELECT id, titre FROM cours WHERE id > ? ORDER BY id LIMIT 1", (cours_id,)
    ).fetchone()
    return render_template(
        "course.html", c=c, tuteur=tuteur, chapitres=chapitres, ressources=ressources,
        similaires=similaires, precedent=precedent, suivant=suivant,
    )


@app.route("/tuteurs")
def tutors():
    db = get_db()
    # LEFT JOIN : on garde aussi les tuteurs qui n'ont encore aucun cours
    tuteurs = db.execute("""
        SELECT tuteurs.*,
               COUNT(cours.id) AS nb_cours,
               COALESCE(SUM(cours.nb_etudiants), 0) AS nb_etudiants
        FROM tuteurs
        LEFT JOIN cours ON cours.tuteur_id = tuteurs.id
        GROUP BY tuteurs.id
        ORDER BY tuteurs.id
    """).fetchall()
    cours_par_tuteur = {}
    for ligne in db.execute("SELECT id, titre, tuteur_id FROM cours ORDER BY id"):
        cours_par_tuteur.setdefault(ligne["tuteur_id"], []).append(ligne)
    return render_template("tutors.html", tuteurs=tuteurs, cours_par_tuteur=cours_par_tuteur)


@app.route("/ressources")
def resources():
    ressources = get_db().execute("""
        SELECT ressources.*, cours.titre AS cours_titre
        FROM ressources
        LEFT JOIN cours ON cours.id = ressources.cours_id
        ORDER BY ressources.fichier IS NULL, ressources.id
    """).fetchall()
    return render_template("resources.html", ressources=ressources)


@app.route("/faq")
def faq():
    questions = get_db().execute("SELECT * FROM faq ORDER BY ordre").fetchall()
    return render_template("faq.html", questions=questions)


# -----------------------------------------------------
# FORMULAIRES
# Schéma "Post / Redirect / Get" : après un envoi réussi on redirige,
# pour que l'actualisation de la page ne renvoie pas le formulaire.
# -----------------------------------------------------

SUJETS = ("Question sur un cours", "Suggestion", "Signaler un problème", "Autre")


def verifier_texte(form, erreurs, champ, libelle, minimum):
    valeur = form.get(champ, "").strip()
    if len(valeur) < minimum:
        erreurs[champ] = f"{libelle} : au moins {minimum} caractères."
    return valeur


def verifier_email(form, erreurs):
    email = form.get("email", "").strip()
    if not EMAIL_REGEX.match(email):
        erreurs["email"] = "Adresse email invalide."
    return email


@app.route("/contact", methods=["GET", "POST"])
def contact():
    erreurs = {}
    if request.method == "POST":
        nom = verifier_texte(request.form, erreurs, "nom", "Nom", 2)
        email = verifier_email(request.form, erreurs)
        sujet = request.form.get("sujet", "")
        if sujet not in SUJETS:
            erreurs["sujet"] = "Choisissez un sujet."
        message = verifier_texte(request.form, erreurs, "message", "Message", 10)

        if not erreurs:
            db = get_db()
            db.execute(
                "INSERT INTO messages (nom, email, sujet, message) VALUES (?, ?, ?, ?)",
                (nom, email, sujet, message),
            )
            db.commit()
            flash("Merci ! Votre message a bien été enregistré, nous vous répondrons rapidement.")
            return redirect(url_for("contact"))

    return render_template("contact.html", sujets=SUJETS, erreurs=erreurs, form=request.form)


NIVEAUX_ETUDE = ("L1", "L2", "L3", "Master", "Doctorat")


@app.route("/devenir-tuteur", methods=["GET", "POST"])
def become_tutor():
    erreurs = {}
    if request.method == "POST":
        nom = verifier_texte(request.form, erreurs, "nom", "Nom", 2)
        email = verifier_email(request.form, erreurs)
        matiere = verifier_texte(request.form, erreurs, "matiere", "Matière", 2)
        niveau_etude = request.form.get("niveau_etude", "")
        if niveau_etude not in NIVEAUX_ETUDE:
            erreurs["niveau_etude"] = "Choisissez votre niveau d'études."
        motivation = verifier_texte(request.form, erreurs, "motivation", "Motivation", 30)

        if not erreurs:
            db = get_db()
            db.execute(
                "INSERT INTO candidatures (nom, email, matiere, niveau_etude, motivation) VALUES (?, ?, ?, ?, ?)",
                (nom, email, matiere, niveau_etude, motivation),
            )
            db.commit()
            flash("Merci pour votre candidature ! Nous l'étudions et revenons vers vous par email.")
            return redirect(url_for("become_tutor"))

    return render_template(
        "become_tutor.html", niveaux_etude=NIVEAUX_ETUDE, erreurs=erreurs, form=request.form
    )


# -----------------------------------------------------
# ANCIENNES ADRESSES (site statique) ET ERREURS
# -----------------------------------------------------

ANCIENNES_PAGES = {
    "index": "index", "courses": "courses", "tutors": "tutors",
    "resources": "resources", "contact": "contact",
}


@app.route("/<page>.html")
def ancienne_page(page):
    if page.startswith("course-") and page[7:].isdigit():
        return redirect(url_for("course", cours_id=int(page[7:])), code=301)
    if page in ANCIENNES_PAGES:
        return redirect(url_for(ANCIENNES_PAGES[page]), code=301)
    abort(404)


@app.errorhandler(404)
def page_introuvable(erreur):
    return render_template("404.html"), 404


if __name__ == "__main__":
    app.run(debug=True)
