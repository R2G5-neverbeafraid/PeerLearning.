"""Tests du site : lancer avec  python -m pytest"""

import sqlite3

import pytest

from app import app, init_db


@pytest.fixture
def client(tmp_path):
    # Chaque test travaille sur une base neuve, dans un dossier temporaire
    app.config.update(TESTING=True, DATABASE=str(tmp_path / "test.db"))
    with app.app_context():
        init_db()
    with app.test_client() as client:
        yield client


def compter(table):
    connexion = sqlite3.connect(app.config["DATABASE"])
    nombre = connexion.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    connexion.close()
    return nombre


@pytest.mark.parametrize("url", [
    "/", "/cours", "/cours/1", "/tuteurs", "/ressources", "/faq", "/contact", "/devenir-tuteur",
])
def test_pages_accessibles(client, url):
    assert client.get(url).status_code == 200


def test_accueil_affiche_les_statistiques(client):
    page = client.get("/").get_data(as_text=True)
    assert "981" in page  # somme des étudiants inscrits
    assert "Développement Web Frontend" in page  # cours le plus suivi


def test_recherche_et_filtres(client):
    page = client.get("/cours?q=SQL").get_data(as_text=True)
    assert "Bases de Données SQL" in page
    assert "Statistiques Appliquées" not in page

    page = client.get("/cours?categorie=Mathématiques&niveau=Intermédiaire").get_data(as_text=True)
    assert "2 cours trouvés" in page


def test_recherche_resiste_a_l_injection_sql(client):
    page = client.get("/cours?q=' OR 1=1 --").get_data(as_text=True)
    assert "0 cours trouvé" in page


def test_tuteurs_coherents_avec_les_cours(client):
    page = client.get("/cours/1").get_data(as_text=True)
    assert "Marie Makasa" in page
    page = client.get("/tuteurs").get_data(as_text=True)
    assert "Cours en préparation" in page  # Thomas Moka n'a pas encore de cours


def test_cours_inexistant_renvoie_404(client):
    reponse = client.get("/cours/999")
    assert reponse.status_code == 404
    assert "Page introuvable" in reponse.get_data(as_text=True)


def test_anciennes_adresses_redirigees(client):
    assert client.get("/course-3.html").headers["Location"] == "/cours/3"
    assert client.get("/tutors.html").headers["Location"] == "/tuteurs"


def test_contact_enregistre_le_message(client):
    reponse = client.post("/contact", data={
        "nom": "Awa", "email": "awa@exemple.cd",
        "sujet": "Suggestion", "message": "Ajoutez un cours de physique !",
    }, follow_redirects=True)
    assert "bien été enregistré" in reponse.get_data(as_text=True)
    assert compter("messages") == 1


def test_contact_refuse_un_formulaire_invalide(client):
    reponse = client.post("/contact", data={
        "nom": "A", "email": "pas-un-email", "sujet": "?", "message": "court",
    })
    page = reponse.get_data(as_text=True)
    assert "Adresse email invalide" in page
    assert compter("messages") == 0


def test_candidature_tuteur(client):
    client.post("/devenir-tuteur", data={
        "nom": "Jean Kabongo", "email": "jean@exemple.cd", "matiere": "Physique",
        "niveau_etude": "L3", "motivation": "J'aime expliquer la mécanique à mes camarades.",
    })
    assert compter("candidatures") == 1
