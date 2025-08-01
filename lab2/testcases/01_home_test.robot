*** Settings ***
Documentation    Test ID: 1001 - Home page should load
Resource    ../resources/crm_keywords.robot
Suite Setup    Ouvrir Le Navigateur
Suite Teardown    Fermer Le Navigateur
Variables    ../pageobject/variables.py

*** Test Cases ***
Vérification Du Chargement De La Page D'Accueil
    [Documentation]    Vérifie que la page d'accueil se charge correctement
    Vérifier Chargement Page Accueil
    Examiner Contenu Page Accueil
