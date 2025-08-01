*** Settings ***
Documentation    Test ID: 1003 - Login should fail with missing credentials
Resource    ../resources/crm_keywords.robot
Suite Setup    Ouvrir Le Navigateur
Suite Teardown    Fermer Le Navigateur
Variables    ../pageobject/variables.py

*** Test Cases ***
Connexion Échouée Avec Identifiants Manquants
    [Documentation]    Vérifie que la connexion échoue avec des identifiants vides
    Cliquer Sur Lien Login
    Laisser Champs Identifiants Vides
    Cliquer Sur Bouton Submit
    Vérifier Utilisateur Toujours Sur Page Login
