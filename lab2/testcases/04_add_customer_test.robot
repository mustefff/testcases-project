*** Settings ***
Documentation    Test ID: 1006 - Should be able to add new customer
Resource    ../resources/crm_keywords.robot
Suite Setup    Ouvrir Le Navigateur
Suite Teardown    Fermer Le Navigateur
Variables    ../pageobject/variables.py

*** Test Cases ***
Ajout D'un Nouveau Client
    [Documentation]    Vérifie qu'un nouveau client peut être ajouté
    Aller À La Page De Connexion
    Saisir Identifiants De Test
    Cliquer Sur Bouton Submit
    Cliquer Sur Bouton New Customer
    Remplir Formulaire Client Simple
    Soumettre Formulaire Client
