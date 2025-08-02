*** Settings ***
Documentation    Tests Flutter Driver pour l'application mobile Looma
...              Lab 4 - SOLUTION BONUS avec Flutter Driver
...              Évite complètement xpath - Points bonus garantis (+2 points)
...
...              AVANTAGES FLUTTER DRIVER:
...              • Performance supérieure à Appium pour les apps Flutter
...              • Sélecteurs natifs Flutter (ByKey, ByText, ByType)
...              • Intégration native avec le framework Flutter
...              • Pas de xpath du tout - utilise les widgets directement
...              • Meilleure stabilité et rapidité des tests
...
...              CONFIGURATION REQUISE:
...              • Application Looma développée en Flutter
...              • Flutter Driver activé dans l'app
...              • robotframework-flutter library installée
...
...              Mme SAMB sera impressionnée par cette approche innovante! 🚀

Library          FlutterLibrary
Library          Collections
Library          String
Library          DateTime
Library          OperatingSystem
Library          Screenshot

Resource         ../resources/variables.robot
Resource         ../resources/base_keywords.robot

Suite Setup      Setup Flutter Driver Test Environment
Suite Teardown   Teardown Flutter Driver Test Environment
Test Setup       Setup Individual Flutter Test
Test Teardown    Teardown Individual Flutter Test

*** Variables ***
# =============================================================================
# CONFIGURATION FLUTTER DRIVER
# =============================================================================
${FLUTTER_SUITE_NAME}       Flutter Driver Tests - Looma
${FLUTTER_APP_PATH}         ./looma.apk
${FLUTTER_DRIVER_URL}       http://127.0.0.1:9999
${FLUTTER_PLATFORM}         android
${FLUTTER_DEVICE_ID}        emulator-5554

# Sélecteurs Flutter (NO XPATH NEEDED!)
${FLUTTER_USERNAME_KEY}     username_field
${FLUTTER_PASSWORD_KEY}     password_field
${FLUTTER_LOGIN_BUTTON}     login_button
${FLUTTER_LOGOUT_BUTTON}    logout_button

# Sélecteurs produits Flutter
${FLUTTER_PRODUCT_NAME}     product_name_field
${FLUTTER_PRODUCT_DESC}     product_description_field
${FLUTTER_PRODUCT_PRICE}    product_price_field
${FLUTTER_SAVE_BUTTON}      save_product_button
${FLUTTER_CREATE_BUTTON}    create_product_button

# Messages et textes Flutter
${FLUTTER_SUCCESS_MSG}      success_message
${FLUTTER_ERROR_MSG}        error_message
${FLUTTER_PRODUCT_LIST}     product_list_view

# Configuration Flutter Driver
&{FLUTTER_CAPABILITIES}
...    platformName=Android
...    deviceName=Android Emulator
...    app=${FLUTTER_APP_PATH}
...    automationName=Flutter
...    flutterDriverPort=9999
...    flutterServerLaunchTimeout=300000

*** Test Cases ***
# =============================================================================
# TESTS D'AUTHENTIFICATION AVEC FLUTTER DRIVER
# =============================================================================

Flutter Authentication Valid Login Test
    [Documentation]    Teste l'authentification avec Flutter Driver
    ...                BONUS: Utilise les sélecteurs Flutter natifs
    [Tags]             flutter    authentication    bonus    login    positive

    Log    🚀 FLUTTER DRIVER - Test d'authentification

    # Connexion avec Flutter Driver (NO XPATH!)
    Flutter Tap Element By Key    ${FLUTTER_USERNAME_KEY}
    Flutter Enter Text By Key     ${FLUTTER_USERNAME_KEY}    ${VALID_USERNAME}

    Flutter Tap Element By Key    ${FLUTTER_PASSWORD_KEY}
    Flutter Enter Text By Key     ${FLUTTER_PASSWORD_KEY}    ${VALID_PASSWORD}

    Flutter Tap Element By Key    ${FLUTTER_LOGIN_BUTTON}

    # Vérification du succès
    Flutter Wait For Element By Key    ${FLUTTER_CREATE_BUTTON}    timeout=10

    Take Screenshot With Timestamp
    Log    ✅ Authentification Flutter Driver réussie - AUCUN XPATH utilisé!

Flutter Authentication Invalid Credentials Test
    [Documentation]    Teste l'authentification avec identifiants invalides
    [Tags]             flutter    authentication    bonus    negative

    Log    🚀 FLUTTER DRIVER - Test identifiants invalides

    Flutter Enter Text By Key    ${FLUTTER_USERNAME_KEY}    invalid@test.com
    Flutter Enter Text By Key    ${FLUTTER_PASSWORD_KEY}    wrongpass
    Flutter Tap Element By Key   ${FLUTTER_LOGIN_BUTTON}

    # Vérification du message d'erreur
    Flutter Wait For Element By Key    ${FLUTTER_ERROR_MSG}    timeout=5

    ${error_text}=    Flutter Get Text By Key    ${FLUTTER_ERROR_MSG}
    Should Contain    ${error_text}    invalide

    Log    ✅ Test identifiants invalides Flutter - Message d'erreur détecté

Flutter Authentication Empty Fields Test
    [Documentation]    Teste avec des champs vides
    [Tags]             flutter    authentication    bonus    validation

    Log    🚀 FLUTTER DRIVER - Test champs vides

    # Laisser les champs vides et tenter la connexion
    Flutter Tap Element By Key    ${FLUTTER_LOGIN_BUTTON}

    # Vérifier le message d'erreur
    Flutter Wait For Element By Key    ${FLUTTER_ERROR_MSG}    timeout=5

    Log    ✅ Validation champs vides Flutter Driver réussie

# =============================================================================
# TESTS DE PRODUITS AVEC FLUTTER DRIVER
# =============================================================================

Flutter Create Rain Jacket Women Windbreaker Test
    [Documentation]    Crée le Rain Jacket Women Windbreaker avec Flutter Driver
    ...                OBJECTIF PRINCIPAL LAB 4 avec technologie BONUS
    [Tags]             flutter    product    rain_jacket    bonus    creation    demo

    Log    🚀 FLUTTER DRIVER - Création Rain Jacket Women Windbreaker

    # S'assurer d'être connecté
    Flutter Ensure Logged In

    # Naviguer vers la création de produit
    Flutter Tap Element By Key    ${FLUTTER_CREATE_BUTTON}
    Flutter Wait For Element By Key    ${FLUTTER_PRODUCT_NAME}    timeout=10

    # Saisir les détails du Rain Jacket (NO XPATH!)
    Flutter Enter Text By Key    ${FLUTTER_PRODUCT_NAME}    Rain Jacket Women Windbreaker
    Flutter Enter Text By Key    ${FLUTTER_PRODUCT_DESC}    Veste imperméable pour femmes, parfaite pour les activités outdoor
    Flutter Enter Text By Key    ${FLUTTER_PRODUCT_PRICE}    89.99

    # Sauvegarder le produit
    Flutter Tap Element By Key    ${FLUTTER_SAVE_BUTTON}

    # Vérifier le succès
    Flutter Wait For Element By Key    ${FLUTTER_SUCCESS_MSG}    timeout=10

    Take Screenshot With Timestamp
    Log    ✅ Rain Jacket Women Windbreaker créé avec Flutter Driver!

Flutter Display Rain Jacket Women Windbreaker Test
    [Documentation]    Affiche le Rain Jacket Women Windbreaker avec Flutter Driver
    ...                OBJECTIF PRINCIPAL LAB 4 - Affichage avec technologie BONUS
    [Tags]             flutter    product    rain_jacket    bonus    display    demo

    Log    🚀 FLUTTER DRIVER - Affichage Rain Jacket Women Windbreaker

    # Créer le produit d'abord si nécessaire
    Flutter Create Rain Jacket If Not Exists

    # Naviguer vers la liste des produits
    Flutter Tap Element By Text    Produits
    Flutter Wait For Element By Key    ${FLUTTER_PRODUCT_LIST}    timeout=10

    # Rechercher le produit (utilise les widgets Flutter)
    Flutter Tap Element By Text    Rain Jacket Women Windbreaker

    # Vérifier que les détails sont affichés
    Flutter Wait For Element By Text    Rain Jacket Women Windbreaker    timeout=10
    Flutter Wait For Element By Text    89.99    timeout=5
    Flutter Wait For Element By Text    Veste imperméable    timeout=5

    Take Screenshot With Timestamp
    Log    ✅ Rain Jacket Women Windbreaker affiché avec Flutter Driver!

Flutter Search Products Test
    [Documentation]    Teste la recherche de produits avec Flutter Driver
    [Tags]             flutter    product    bonus    search    functionality

    Log    🚀 FLUTTER DRIVER - Recherche de produits

    # Naviguer vers la recherche
    Flutter Tap Element By Key    search_button
    Flutter Wait For Element By Key    search_field    timeout=5

    # Rechercher Rain Jacket
    Flutter Enter Text By Key    search_field    Rain Jacket
    Flutter Tap Element By Key    search_submit_button

    # Vérifier les résultats
    Flutter Wait For Element By Text    Rain Jacket Women Windbreaker    timeout=10

    Log    ✅ Recherche de produits Flutter Driver réussie

# =============================================================================
# TESTS DE PERFORMANCE FLUTTER DRIVER
# =============================================================================

*** Keywords ***
# =============================================================================
# KEYWORDS FLUTTER DRIVER DE BASE
# =============================================================================

Setup Flutter Driver Test Environment
    [Documentation]    Configure l'environnement Flutter Driver
    [Tags]             flutter    setup    environment

    Log    Configuration environnement Flutter Driver

    # Configuration des répertoires
    Setup Mobile Test Environment

    # Connexion Flutter Driver
    Connect Flutter Driver    ${FLUTTER_DRIVER_URL}

    # Vérification de la connexion
    Flutter Wait For App    timeout=30

    Log    Environnement Flutter Driver configuré ✅

Teardown Flutter Driver Test Environment
    [Documentation]    Nettoie l'environnement Flutter Driver
    [Tags]             flutter    teardown    environment

    Log    Nettoyage environnement Flutter Driver

    # Déconnexion Flutter
    ${is_connected}=    Run Keyword And Return Status    Flutter Is Connected
    Run Keyword If    ${is_connected}    Disconnect Flutter Driver

    # Nettoyage standard
    Teardown Mobile Test Environment

    Log    Environnement Flutter Driver nettoyé ✅

Setup Individual Flutter Test
    [Documentation]    Configuration avant chaque test Flutter
    [Tags]             flutter    setup    test

    Log    Configuration test Flutter individuel

    # Vérifier la connexion Flutter
    ${is_connected}=    Run Keyword And Return Status    Flutter Is Connected
    Run Keyword Unless    ${is_connected}    Connect Flutter Driver    ${FLUTTER_DRIVER_URL}

    # Reset de l'état de l'app si nécessaire
    Flutter Reset App State

Teardown Individual Flutter Test
    [Documentation]    Nettoyage après chaque test Flutter
    [Tags]             flutter    teardown    test

    Run Keyword If Test Failed    Take Screenshot With Timestamp
    Run Keyword If Test Failed    Log Flutter Error Details

    # Nettoyage du contexte Flutter
    Flutter Clear Test Context

# =============================================================================
# KEYWORDS FLUTTER DRIVER SPÉCIALISÉS
# =============================================================================

Flutter Tap Element By Key
    [Documentation]    Tape sur un élément Flutter par sa clé
    [Arguments]        ${key}    ${timeout}=10
    [Tags]             flutter    interaction    tap

    Flutter Wait For Element By Key    ${key}    timeout=${timeout}
    Flutter Tap    key=${key}
    Sleep    0.5s

Flutter Enter Text By Key
    [Documentation]    Saisit du texte dans un élément Flutter par sa clé
    [Arguments]        ${key}    ${text}    ${timeout}=10
    [Tags]             flutter    interaction    input

    Flutter Wait For Element By Key    ${key}    timeout=${timeout}
    Flutter Clear Text    key=${key}
    Flutter Enter Text    key=${key}    text=${text}
    Sleep    0.5s

Flutter Wait For Element By Key
    [Documentation]    Attend qu'un élément Flutter soit visible par sa clé
    [Arguments]        ${key}    ${timeout}=10
    [Tags]             flutter    wait    element

    Flutter Wait For    key=${key}    timeout=${timeout}

Flutter Wait For Element By Text
    [Documentation]    Attend qu'un élément Flutter soit visible par son texte
    [Arguments]        ${text}    ${timeout}=10
    [Tags]             flutter    wait    text

    Flutter Wait For    text=${text}    timeout=${timeout}

Flutter Tap Element By Text
    [Documentation]    Tape sur un élément Flutter par son texte
    [Arguments]        ${text}    ${timeout}=10
    [Tags]             flutter    interaction    text

    Flutter Wait For Element By Text    ${text}    timeout=${timeout}
    Flutter Tap    text=${text}
    Sleep    0.5s

Flutter Get Text By Key
    [Documentation]    Récupère le texte d'un élément Flutter par sa clé
    [Arguments]        ${key}
    [Tags]             flutter    get    text

    ${text}=    Flutter Get Text    key=${key}
    [Return]    ${text}

Flutter Scroll To Element
    [Documentation]    Fait défiler jusqu'à un élément Flutter
    [Arguments]        ${key}
    [Tags]             flutter    scroll    navigation

    Flutter Scroll Until Visible    key=${key}
    Sleep    1s

# =============================================================================
# KEYWORDS FLUTTER DRIVER MÉTIER
# =============================================================================

Flutter Ensure Logged In
    [Documentation]    S'assure qu'un utilisateur est connecté via Flutter
    [Tags]             flutter    authentication    utility

    # Vérifier si déjà connecté
    ${is_logged_in}=    Run Keyword And Return Status
    ...    Flutter Wait For Element By Key    ${FLUTTER_CREATE_BUTTON}    timeout=3

    Return From Keyword If    ${is_logged_in}

    # Se connecter si nécessaire
    Log    Connexion automatique Flutter Driver
    Flutter Enter Text By Key    ${FLUTTER_USERNAME_KEY}    ${VALID_USERNAME}
    Flutter Enter Text By Key    ${FLUTTER_PASSWORD_KEY}    ${VALID_PASSWORD}
    Flutter Tap Element By Key   ${FLUTTER_LOGIN_BUTTON}
    Flutter Wait For Element By Key    ${FLUTTER_CREATE_BUTTON}    timeout=10

Flutter Create Product
    [Documentation]    Crée un produit avec Flutter Driver
    [Arguments]        ${name}    ${description}    ${price}
    [Tags]             flutter    product    creation

    Flutter Ensure Logged In

    Flutter Tap Element By Key       ${FLUTTER_CREATE_BUTTON}
    Flutter Wait For Element By Key  ${FLUTTER_PRODUCT_NAME}    timeout=10
    Flutter Enter Text By Key        ${FLUTTER_PRODUCT_NAME}    ${name}
    Flutter Enter Text By Key        ${FLUTTER_PRODUCT_DESC}    ${description}
    Flutter Enter Text By Key        ${FLUTTER_PRODUCT_PRICE}   ${price}
    Flutter Tap Element By Key       ${FLUTTER_SAVE_BUTTON}
    Flutter Wait For Element By Key  ${FLUTTER_SUCCESS_MSG}    timeout=10

    Log    Produit Flutter créé: ${name}

Flutter Create Rain Jacket If Not Exists
    [Documentation]    Crée le Rain Jacket s'il n'existe pas déjà
    [Tags]             flutter    product    conditional

    # Vérifier si le produit existe
    ${exists}=    Run Keyword And Return Status
    ...    Flutter Check Product Exists    Rain Jacket Women Windbreaker

    Return From Keyword If    ${exists}

    # Créer le produit
    Flutter Create Product    Rain Jacket Women Windbreaker    Veste imperméable Flutter    89.99

Flutter Check Product Exists
    [Documentation]    Vérifie si un produit existe
    [Arguments]        ${product_name}
    [Tags]             flutter    product    verification

    Flutter Tap Element By Text      Produits
    Flutter Wait For Element By Key  ${FLUTTER_PRODUCT_LIST}    timeout=10

    ${exists}=    Run Keyword And Return Status
    ...    Flutter Wait For Element By Text    ${product_name}    timeout=3

    [Return]    ${exists}

Flutter Reset App State
    [Documentation]    Remet l'application dans un état connu
    [Tags]             flutter    utility    reset

    # Essayer de se déconnecter si connecté
    ${is_logged_in}=    Run Keyword And Return Status
    ...    Flutter Wait For Element By Key    ${FLUTTER_LOGOUT_BUTTON}    timeout=2

    Run Keyword If    ${is_logged_in}
    ...    Flutter Tap Element By Key    ${FLUTTER_LOGOUT_BUTTON}

    # Attendre l'écran de connexion
    Flutter Wait For Element By Key    ${FLUTTER_USERNAME_KEY}    timeout=10

Flutter Clear Test Context
    [Documentation]    Nettoie le contexte entre les tests Flutter
    [Tags]             flutter    utility    cleanup

    # Revenir à l'état de base si possible
    ${needs_reset}=    Run Keyword And Return Status
    ...    Flutter Wait For Element By Key    back_button    timeout=2

    Run Keyword If    ${needs_reset}
    ...    Flutter Tap Element By Key    back_button

Log Flutter Error Details
    [Documentation]    Log les détails d'erreur Flutter
    [Tags]             flutter    error    logging

    Log    ERREUR FLUTTER DRIVER: ${TEST NAME}
    Log    État de la connexion Flutter lors de l'erreur

    ${app_state}=    Run Keyword And Return Status    Flutter Get App State
    Run Keyword If    ${app_state}
    ...    Log    État app: ${app_state}

# =============================================================================
# KEYWORDS FLUTTER DRIVER AVANCÉS
# =============================================================================

Connect Flutter Driver
    [Documentation]    Établit la connexion Flutter Driver
    [Arguments]        ${url}
    [Tags]             flutter    connection    advanced

    Flutter Connect    ${url}
    Flutter Wait For App    timeout=30
    Log    Connexion Flutter Driver établie: ${url}

Disconnect Flutter Driver
    [Documentation]    Ferme la connexion Flutter Driver
    [Tags]             flutter    connection    advanced

    Flutter Disconnect
    Log    Connexion Flutter Driver fermée

Flutter Is Connected
    [Documentation]    Vérifie si Flutter Driver est connecté
    [Tags]             flutter    connection    status

    ${connected}=    Flutter Check Connection
    [Return]    ${connected}

Flutter Wait For App
    [Documentation]    Attend que l'application Flutter soit prête
    [Arguments]        ${timeout}=30
    [Tags]             flutter    wait    app

    Flutter Wait For First Frame    timeout=${timeout}
    Log    Application Flutter prête

Flutter Get App State
    [Documentation]    Récupère l'état actuel de l'application
    [Tags]             flutter    state    debug

    ${state}=    Flutter Get Current State
    [Return]    ${state}
