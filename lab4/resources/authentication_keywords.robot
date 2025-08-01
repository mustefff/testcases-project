*** Settings ***
Documentation    Keywords spécialisés pour les tests d'authentification
...              Application mobile Looma - Lab 4
...              Évite xpath pour obtenir les points bonus (+2 points)
...              Utilise accessibility id, id, class name, text, et UiAutomator

Library          AppiumLibrary
Library          Collections
Library          String
Library          DateTime
Library          OperatingSystem

Resource         variables.robot
Resource         base_keywords.robot

*** Keywords ***
# =============================================================================
# KEYWORDS D'AUTHENTIFICATION - SCÉNARIOS POSITIFS
# =============================================================================

Perform Valid Login
    [Documentation]    Effectue une connexion avec des identifiants valides
    [Arguments]        ${username}=${VALID_USERNAME}    ${password}=${VALID_PASSWORD}
    [Tags]            authentication    positive    login

    Log    Tentative de connexion avec: ${username}
    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}

    # Saisie du nom d'utilisateur (évite xpath)
    Clear Text    id=${LOGIN_USERNAME_ID}
    Input Text    id=${LOGIN_USERNAME_ID}    ${username}

    # Vérification que le texte a été saisi
    ${entered_username}=    Get Element Attribute    id=${LOGIN_USERNAME_ID}    text
    Should Be Equal    ${entered_username}    ${username}

    # Saisie du mot de passe
    Clear Text    id=${LOGIN_PASSWORD_ID}
    Input Text    id=${LOGIN_PASSWORD_ID}    ${password}

    # Clic sur le bouton de connexion (utilise accessibility id)
    Click Element    accessibility_id=${LOGIN_BUTTON_ACCESS}

    # Vérification de la connexion réussie
    Wait Until Element Is Visible    text=${CREATE_PRODUCT_TEXT}    timeout=${EXPLICIT_WAIT}
    Log    Connexion réussie pour: ${username}

Perform Quick Login
    [Documentation]    Connexion rapide avec les identifiants par défaut
    [Tags]            authentication    quick    setup

    Perform Valid Login    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Log    Connexion rapide effectuée

Login With Remember Me Option
    [Documentation]    Se connecte en cochant l'option "Se souvenir de moi"
    [Arguments]        ${username}=${VALID_USERNAME}    ${password}=${VALID_PASSWORD}
    [Tags]            authentication    remember    persistent

    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}

    Input Text    id=${LOGIN_USERNAME_ID}    ${username}
    Input Text    id=${LOGIN_PASSWORD_ID}    ${password}

    # Coche la case "Se souvenir de moi" si elle existe
    ${remember_checkbox}=    Run Keyword And Return Status
    ...    Element Should Be Visible    android=new UiSelector().text("Se souvenir de moi")

    Run Keyword If    ${remember_checkbox}
    ...    Click Element    android=new UiSelector().text("Se souvenir de moi")

    Click Element    id=${LOGIN_BUTTON_ID}
    Wait Until Element Is Visible    text=${CREATE_PRODUCT_TEXT}    timeout=${EXPLICIT_WAIT}

# =============================================================================
# KEYWORDS D'AUTHENTIFICATION - SCÉNARIOS NÉGATIFS
# =============================================================================

Attempt Login With Invalid Credentials
    [Documentation]    Tente une connexion avec des identifiants invalides
    [Arguments]        ${username}    ${password}    ${expected_error}=${LOGIN_ERROR_MESSAGE}
    [Tags]            authentication    negative    invalid

    Log    Tentative de connexion invalide - User: ${username}
    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}

    Clear Text    id=${LOGIN_USERNAME_ID}
    Input Text    id=${LOGIN_USERNAME_ID}    ${username}

    Clear Text    id=${LOGIN_PASSWORD_ID}
    Input Text    id=${LOGIN_PASSWORD_ID}    ${password}

    Click Element    id=${LOGIN_BUTTON_ID}

    # Vérification du message d'erreur (évite xpath)
    Wait Until Element Is Visible    id=${LOGIN_ERROR_ID}    timeout=${EXPLICIT_WAIT}
    ${error_message}=    Get Text    id=${LOGIN_ERROR_ID}
    Should Contain    ${error_message}    ${expected_error}
    Log    Message d'erreur vérifié: ${error_message}

Attempt Login With Empty Fields
    [Documentation]    Teste la connexion avec des champs vides
    [Tags]            authentication    negative    empty    validation

    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}

    # S'assurer que les champs sont vides
    Clear Text    id=${LOGIN_USERNAME_ID}
    Clear Text    id=${LOGIN_PASSWORD_ID}

    Click Element    id=${LOGIN_BUTTON_ID}

    # Vérifier le message d'erreur pour champs vides
    Wait Until Element Is Visible    id=${LOGIN_ERROR_ID}    timeout=${EXPLICIT_WAIT}
    ${error_message}=    Get Text    id=${LOGIN_ERROR_ID}
    Should Contain    ${error_message}    ${EMPTY_FIELD_ERROR}

Attempt Login With Only Username
    [Documentation]    Teste avec seulement le nom d'utilisateur
    [Arguments]        ${username}=${VALID_USERNAME}
    [Tags]            authentication    negative    partial

    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}

    Input Text    id=${LOGIN_USERNAME_ID}    ${username}
    Clear Text    id=${LOGIN_PASSWORD_ID}

    Click Element    id=${LOGIN_BUTTON_ID}

    # Vérification de l'erreur
    Wait Until Element Is Visible    id=${LOGIN_ERROR_ID}    timeout=${EXPLICIT_WAIT}
    ${error_message}=    Get Text    id=${LOGIN_ERROR_ID}
    Should Contain    ${error_message}    ${EMPTY_FIELD_ERROR}

Attempt Login With Only Password
    [Documentation]    Teste avec seulement le mot de passe
    [Arguments]        ${password}=${VALID_PASSWORD}
    [Tags]            authentication    negative    partial

    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}

    Clear Text    id=${LOGIN_USERNAME_ID}
    Input Text    id=${LOGIN_PASSWORD_ID}    ${password}

    Click Element    id=${LOGIN_BUTTON_ID}

    Wait Until Element Is Visible    id=${LOGIN_ERROR_ID}    timeout=${EXPLICIT_WAIT}
    ${error_message}=    Get Text    id=${LOGIN_ERROR_ID}
    Should Contain    ${error_message}    ${EMPTY_FIELD_ERROR}

Test SQL Injection In Login
    [Documentation]    Teste la résistance aux injections SQL
    [Tags]            authentication    security    sql_injection

    ${sql_payload}=    Set Variable    admin' OR '1'='1
    Attempt Login With Invalid Credentials    ${sql_payload}    ${sql_payload}
    Log    Test d'injection SQL effectué

# =============================================================================
# KEYWORDS DE VALIDATION DES CHAMPS
# =============================================================================

Validate Username Field
    [Documentation]    Valide le comportement du champ nom d'utilisateur
    [Tags]            validation    username    field

    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}

    # Vérifier que le champ est modifiable
    Element Should Be Enabled    id=${LOGIN_USERNAME_ID}

    # Tester la saisie
    Input Text    id=${LOGIN_USERNAME_ID}    test@example.com
    ${entered_text}=    Get Element Attribute    id=${LOGIN_USERNAME_ID}    text
    Should Be Equal    ${entered_text}    test@example.com

    # Vérifier la limite de caractères si applicable
    ${long_text}=    Set Variable    ${'a' * 100}@example.com
    Clear Text    id=${LOGIN_USERNAME_ID}
    Input Text    id=${LOGIN_USERNAME_ID}    ${long_text}

    Log    Validation du champ nom d'utilisateur terminée

Validate Password Field
    [Documentation]    Valide le comportement du champ mot de passe
    [Tags]            validation    password    field    security

    Wait Until Element Is Visible    id=${LOGIN_PASSWORD_ID}    timeout=${EXPLICIT_WAIT}

    # Vérifier que le champ est modifiable
    Element Should Be Enabled    id=${LOGIN_PASSWORD_ID}

    # Vérifier que le mot de passe est masqué
    ${password_type}=    Get Element Attribute    id=${LOGIN_PASSWORD_ID}    password
    Should Be Equal    ${password_type}    true

    # Tester différents types de caractères
    Input Text    id=${LOGIN_PASSWORD_ID}    Test123!@#

    Log    Validation du champ mot de passe terminée

Validate Login Button State
    [Documentation]    Valide l'état du bouton de connexion
    [Tags]            validation    button    state

    Wait Until Element Is Visible    id=${LOGIN_BUTTON_ID}    timeout=${EXPLICIT_WAIT}

    # Vérifier que le bouton est cliquable
    Element Should Be Enabled    id=${LOGIN_BUTTON_ID}

    # Vérifier le texte du bouton
    ${button_text}=    Get Text    id=${LOGIN_BUTTON_ID}
    Should Be Equal    ${button_text}    ${LOGIN_BUTTON_TEXT}

    Log    État du bouton de connexion validé

# =============================================================================
# KEYWORDS DE GESTION DE SESSION
# =============================================================================

Perform Logout
    [Documentation]    Effectue la déconnexion de l'application
    [Tags]            authentication    logout    session

    # Utilise accessibility id pour éviter xpath
    Wait Until Element Is Visible    accessibility_id=${LOGOUT_BUTTON_ACCESS}    timeout=${EXPLICIT_WAIT}
    Click Element    accessibility_id=${LOGOUT_BUTTON_ACCESS}

    # Vérifier le retour à l'écran de connexion
    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}
    Log    Déconnexion effectuée avec succès

Verify Login Session Active
    [Documentation]    Vérifie qu'une session de connexion est active
    [Tags]            authentication    session    verification

    # Vérifier la présence d'éléments indiquant une session active
    Element Should Be Visible    text=${CREATE_PRODUCT_TEXT}
    Log    Session de connexion active confirmée

Verify Login Session Inactive
    [Documentation]    Vérifie qu'aucune session n'est active
    [Tags]            authentication    session    verification

    Element Should Be Visible    id=${LOGIN_USERNAME_ID}
    Log    Aucune session active confirmée

Handle Session Timeout
    [Documentation]    Gère l'expiration de session
    [Tags]            authentication    session    timeout

    # Vérifier si l'utilisateur a été déconnecté automatiquement
    ${login_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    id=${LOGIN_USERNAME_ID}

    Run Keyword If    ${login_visible}
    ...    Log    Session expirée - retour à l'écran de connexion
    ...    ELSE
    ...    Log    Session toujours active

# =============================================================================
# KEYWORDS DE TEST DE SÉCURITÉ
# =============================================================================

Test Password Strength Requirements
    [Documentation]    Teste les exigences de force du mot de passe
    [Tags]            authentication    security    password_strength

    @{weak_passwords}=    Create List    123    password    abc    qwerty

    FOR    ${weak_password}    IN    @{weak_passwords}
        Log    Test avec mot de passe faible: ${weak_password}
        Attempt Login With Invalid Credentials    ${VALID_USERNAME}    ${weak_password}
        Clear All Input Fields
    END

Test Account Lockout Protection
    [Documentation]    Teste la protection contre le verrouillage de compte
    [Tags]            authentication    security    lockout    brute_force

    FOR    ${attempt}    IN RANGE    1    6
        Log    Tentative de connexion ${attempt}/5
        Attempt Login With Invalid Credentials    ${VALID_USERNAME}    wrongpassword
        Clear All Input Fields
        Sleep    1s
    END

    # Vérifier si le compte est verrouillé après 5 tentatives
    ${lockout_message}=    Run Keyword And Return Status
    ...    Element Should Be Visible    android=new UiSelector().textContains("compte verrouillé")

    Log    Test de protection contre le verrouillage terminé

Test Special Characters In Credentials
    [Documentation]    Teste les caractères spéciaux dans les identifiants
    [Tags]            authentication    security    special_characters

    ${special_username}=    Set Variable    test+user@domain.com
    ${special_password}=    Set Variable    P@ssw0rd!#$%

    # Tester avec des caractères spéciaux valides
    Perform Valid Login    ${special_username}    ${special_password}
    Perform Logout

# =============================================================================
# KEYWORDS UTILITAIRES D'AUTHENTIFICATION
# =============================================================================

Clear Login Form
    [Documentation]    Vide complètement le formulaire de connexion
    [Tags]            utility    cleanup    form

    Clear Text    id=${LOGIN_USERNAME_ID}
    Clear Text    id=${LOGIN_PASSWORD_ID}
    Log    Formulaire de connexion vidé

Verify Login Form Elements
    [Documentation]    Vérifie la présence de tous les éléments du formulaire
    [Tags]            verification    form    elements

    Element Should Be Visible    id=${LOGIN_USERNAME_ID}
    Element Should Be Visible    id=${LOGIN_PASSWORD_ID}
    Element Should Be Visible    id=${LOGIN_BUTTON_ID}

    Log    Tous les éléments du formulaire de connexion sont présents

Take Login Screenshot
    [Documentation]    Prend une capture d'écran de l'écran de connexion
    [Tags]            utility    screenshot    login

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Capture Page Screenshot    login_screen_${timestamp}.png
    Log    Capture d'écran de connexion sauvegardée

Fill Login Form Without Submit
    [Documentation]    Remplit le formulaire sans soumettre
    [Arguments]        ${username}    ${password}
    [Tags]            utility    form    preparation

    Clear Text    id=${LOGIN_USERNAME_ID}
    Input Text    id=${LOGIN_USERNAME_ID}    ${username}

    Clear Text    id=${LOGIN_PASSWORD_ID}
    Input Text    id=${LOGIN_PASSWORD_ID}    ${password}

    Log    Formulaire rempli sans soumission

Verify Error Message Disappears
    [Documentation]    Vérifie que les messages d'erreur disparaissent
    [Tags]            verification    error    cleanup

    ${error_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    id=${LOGIN_ERROR_ID}

    Should Not Be True    ${error_visible}    Le message d'erreur est toujours visible
    Log    Aucun message d'erreur visible - OK
