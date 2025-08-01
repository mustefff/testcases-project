*** Settings ***
Documentation    Test ID: 1002 - Login should succeed with valid credentials
Resource    ../resources/crm_keywords.robot
Suite Setup    Ouvrir Le Navigateur
Suite Teardown    Fermer Le Navigateur
Variables    ../pageobject/variables.py

*** Test Cases ***
Connexion Réussie Avec Identifiants Valides
    [Documentation]    Vérifie que la connexion réussit avec des identifiants valides
    Cliquer Sur Lien Login
    Saisir Identifiants Valides
    Cliquer Sur Bouton Submit
    Vérifier Tentative De Connexion
