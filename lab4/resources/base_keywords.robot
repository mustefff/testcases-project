*** Settings ***
Documentation    Keywords de base pour les tests mobiles Looma
...              Lab 4 - Automatisation avec Robot Framework
...              Évite l'utilisation de xpath pour obtenir les points bonus

Library          AppiumLibrary
Library          Collections
Library          String
Library          DateTime
Library          OperatingSystem
Library          Screenshot

Resource         variables.robot

*** Keywords ***
# =============================================================================
# KEYWORDS DE CONFIGURATION ET SETUP
# =============================================================================

Setup Mobile Test Environment
    [Documentation]    Configure l'environnement de test mobile
    [Tags]            setup
    Create Directory    ${SCREENSHOT_DIR}
    Set Screenshot Directory    ${SCREENSHOT_DIR}
    Set Appium Timeout    ${IMPLICIT_WAIT}

Connect To Appium Server
    [Documentation]    Se connecte au serveur Appium avec les capacités Android
    [Arguments]        ${use_flutter}=False
    [Tags]            setup    connection

    IF    ${use_flutter}
        Open Application    ${APPIUM_URL}    &{FLUTTER_CAPABILITIES}
    ELSE
        Open Application    ${APPIUM_URL}    &{ANDROID_CAPABILITIES}
    END

    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}
    Log    Application Looma lancée avec succès

Connect To Appium With Custom Capabilities
    [Documentation]    Se connecte avec des capacités personnalisées
    [Arguments]        &{custom_capabilities}
    [Tags]            setup    connection

    Open Application    ${APPIUM_URL}    &{custom_capabilities}
    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}

Teardown Mobile Test Environment
    [Documentation]    Nettoie l'environnement après les tests
    [Tags]            teardown

    Run Keyword If Test Failed    Capture Page Screenshot
    Close Application
    Log    Test mobile terminé

# =============================================================================
# KEYWORDS D'AUTHENTIFICATION
# =============================================================================

Login With Valid Credentials
    [Documentation]    Se connecte avec des identifiants valides
    [Arguments]        ${username}=${VALID_USERNAME}    ${password}=${VALID_PASSWORD}
    [Tags]            authentication    login

    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}
    Clear Text    id=${LOGIN_USERNAME_ID}
    Input Text    id=${LOGIN_USERNAME_ID}    ${username}

    Clear Text    id=${LOGIN_PASSWORD_ID}
    Input Text    id=${LOGIN_PASSWORD_ID}    ${password}

    Click Element    id=${LOGIN_BUTTON_ID}
    Wait Until Element Is Visible    text=${CREATE_PRODUCT_TEXT}    timeout=${EXPLICIT_WAIT}
    Log    Connexion réussie pour l'utilisateur: ${username}

Login With Invalid Credentials
    [Documentation]    Tente une connexion avec des identifiants invalides
    [Arguments]        ${username}    ${password}
    [Tags]            authentication    negative

    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}
    Clear Text    id=${LOGIN_USERNAME_ID}
    Input Text    id=${LOGIN_USERNAME_ID}    ${username}

    Clear Text    id=${LOGIN_PASSWORD_ID}
    Input Text    id=${LOGIN_PASSWORD_ID}    ${password}

    Click Element    id=${LOGIN_BUTTON_ID}
    Wait Until Element Is Visible    id=${LOGIN_ERROR_ID}    timeout=${EXPLICIT_WAIT}
    Log    Tentative de connexion échouée comme attendu

Verify Login Error Message
    [Documentation]    Vérifie que le message d'erreur de connexion est affiché
    [Tags]            authentication    verification

    ${error_text}=    Get Text    id=${LOGIN_ERROR_ID}
    Should Contain    ${error_text}    ${LOGIN_ERROR_MESSAGE}
    Log    Message d'erreur vérifié: ${error_text}

Logout From Application
    [Documentation]    Se déconnecte de l'application
    [Tags]            authentication    logout

    Click Element    accessibility_id=${LOGOUT_BUTTON_ACCESS}
    Wait Until Element Is Visible    id=${LOGIN_USERNAME_ID}    timeout=${EXPLICIT_WAIT}
    Log    Déconnexion réussie

# =============================================================================
# KEYWORDS DE NAVIGATION
# =============================================================================

Navigate To Products Menu
    [Documentation]    Navigue vers le menu des produits
    [Tags]            navigation

    Click Element    id=${MENU_PRODUCTS_ID}
    Wait Until Element Is Visible    id=${PRODUCT_LIST_ID}    timeout=${EXPLICIT_WAIT}
    Log    Navigation vers le menu produits réussie

Navigate To Create Product
    [Documentation]    Navigue vers la page de création de produit
    [Tags]            navigation    product

    Click Element    text=${CREATE_PRODUCT_TEXT}
    Wait Until Element Is Visible    id=${PRODUCT_NAME_FIELD_ID}    timeout=${EXPLICIT_WAIT}
    Log    Navigation vers la création de produit réussie

Navigate To Product Details
    [Documentation]    Navigue vers les détails d'un produit spécifique
    [Arguments]        ${product_name}
    [Tags]            navigation    product

    # Utilise UiAutomator au lieu de xpath
    ${product_selector}=    Format String    ${BUTTON_BY_TEXT}    ${product_name}
    Click Element    android=${product_selector}
    Wait Until Element Is Visible    id=${PRODUCT_TITLE_ID}    timeout=${EXPLICIT_WAIT}
    Log    Navigation vers les détails du produit: ${product_name}

# =============================================================================
# KEYWORDS DE CRÉATION DE PRODUIT
# =============================================================================

Create New Product
    [Documentation]    Crée un nouveau produit avec les informations fournies
    [Arguments]        ${name}=${PRODUCT_NAME}    ${description}=${PRODUCT_DESCRIPTION}    ${price}=${PRODUCT_PRICE}
    [Tags]            product    creation

    Navigate To Create Product

    # Saisie des informations du produit (évite xpath)
    Clear Text    id=${PRODUCT_NAME_FIELD_ID}
    Input Text    id=${PRODUCT_NAME_FIELD_ID}    ${name}

    Clear Text    id=${PRODUCT_DESC_FIELD_ID}
    Input Text    id=${PRODUCT_DESC_FIELD_ID}    ${description}

    Clear Text    id=${PRODUCT_PRICE_FIELD_ID}
    Input Text    id=${PRODUCT_PRICE_FIELD_ID}    ${price}

    # Sauvegarde le produit
    Click Element    id=${PRODUCT_SAVE_BUTTON_ID}
    Wait Until Element Is Visible    text=${PRODUCT_CREATED_MESSAGE}    timeout=${EXPLICIT_WAIT}
    Log    Produit créé avec succès: ${name}

Create Product With Validation
    [Documentation]    Crée un produit en validant chaque étape
    [Arguments]        ${name}    ${description}    ${price}
    [Tags]            product    creation    validation

    Navigate To Create Product

    # Validation des champs obligatoires
    Element Should Be Visible    id=${PRODUCT_NAME_FIELD_ID}
    Element Should Be Visible    id=${PRODUCT_DESC_FIELD_ID}
    Element Should Be Visible    id=${PRODUCT_PRICE_FIELD_ID}

    # Saisie avec validation
    Input Text    id=${PRODUCT_NAME_FIELD_ID}    ${name}
    Input Text    id=${PRODUCT_DESC_FIELD_ID}    ${description}
    Input Text    id=${PRODUCT_PRICE_FIELD_ID}    ${price}

    # Vérification des valeurs saisies
    ${entered_name}=    Get Element Attribute    id=${PRODUCT_NAME_FIELD_ID}    text
    Should Be Equal    ${entered_name}    ${name}

    # Sauvegarde
    Click Element    id=${PRODUCT_SAVE_BUTTON_ID}
    Wait Until Element Is Visible    text=${PRODUCT_CREATED_MESSAGE}    timeout=${EXPLICIT_WAIT}

# =============================================================================
# KEYWORDS DE RECHERCHE ET AFFICHAGE
# =============================================================================

Search For Product
    [Documentation]    Recherche un produit par son nom
    [Arguments]        ${product_name}
    [Tags]            product    search

    Navigate To Products Menu
    Clear Text    id=${PRODUCT_SEARCH_ID}
    Input Text    id=${PRODUCT_SEARCH_ID}    ${product_name}

    # Attendre que les résultats se chargent
    Sleep    ${SHORT_WAIT}
    Log    Recherche effectuée pour: ${product_name}

Verify Product Exists In List
    [Documentation]    Vérifie qu'un produit existe dans la liste
    [Arguments]        ${product_name}
    [Tags]            product    verification

    # Utilise UiAutomator pour trouver le produit dans la liste
    ${product_selector}=    Format String    ${BUTTON_BY_TEXT}    ${product_name}
    Element Should Be Visible    android=${product_selector}
    Log    Produit trouvé dans la liste: ${product_name}

Display Product Details
    [Documentation]    Affiche les détails d'un produit spécifique
    [Arguments]        ${product_name}
    [Tags]            product    display

    Search For Product    ${product_name}
    Navigate To Product Details    ${product_name}

    # Vérification que les détails sont affichés
    Element Should Be Visible    id=${PRODUCT_TITLE_ID}
    Element Should Be Visible    id=${PRODUCT_PRICE_DISPLAY_ID}
    Element Should Be Visible    id=${PRODUCT_DESC_DISPLAY_ID}

    ${displayed_title}=    Get Text    id=${PRODUCT_TITLE_ID}
    Should Contain    ${displayed_title}    ${product_name}
    Log    Détails du produit affichés: ${displayed_title}

Verify Rain Jacket Women Windbreaker
    [Documentation]    Vérifie spécifiquement le produit Rain Jacket Women Windbreaker
    [Tags]            product    verification    specific

    ${target_product}=    Set Variable    Rain Jacket Women Windbreaker
    Display Product Details    ${target_product}

    # Vérifications spécifiques pour ce produit
    ${title}=    Get Text    id=${PRODUCT_TITLE_ID}
    Should Be Equal    ${title}    ${target_product}

    # Vérifier que le prix est affiché
    Element Should Be Visible    id=${PRODUCT_PRICE_DISPLAY_ID}

    Log    Produit Rain Jacket Women Windbreaker vérifié avec succès

# =============================================================================
# KEYWORDS UTILITAIRES
# =============================================================================

Wait For Element And Click
    [Documentation]    Attend qu'un élément soit visible puis clique dessus
    [Arguments]        ${locator}    ${timeout}=${EXPLICIT_WAIT}
    [Tags]            utility

    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Click Element    ${locator}

Wait For Element By UiAutomator
    [Documentation]    Attend un élément en utilisant UiAutomator
    [Arguments]        ${ui_selector}    ${timeout}=${EXPLICIT_WAIT}
    [Tags]            utility    uiautomator

    Wait Until Element Is Visible    android=${ui_selector}    timeout=${timeout}

Scroll To Element
    [Documentation]    Fait défiler jusqu'à un élément spécifique
    [Arguments]        ${element_text}
    [Tags]            utility    scroll

    ${scroll_selector}=    Format String    ${BUTTON_BY_TEXT}    ${element_text}
    Scroll Down    android=${scroll_selector}

Take Screenshot With Timestamp
    [Documentation]    Prend une capture d'écran avec timestamp
    [Tags]            utility    screenshot

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${screenshot_name}=    Set Variable    screenshot_${timestamp}.png
    Capture Page Screenshot    ${screenshot_name}
    Log    Capture d'écran sauvegardée: ${screenshot_name}

Verify Element Text Contains
    [Documentation]    Vérifie qu'un élément contient le texte spécifié
    [Arguments]        ${locator}    ${expected_text}
    [Tags]            verification

    ${actual_text}=    Get Text    ${locator}
    Should Contain    ${actual_text}    ${expected_text}
    Log    Texte vérifié - Attendu: ${expected_text}, Trouvé: ${actual_text}

Clear All Input Fields
    [Documentation]    Vide tous les champs de saisie de la page courante
    [Tags]            utility    cleanup

    # Liste des champs communs à vider
    @{common_fields}=    Create List
    ...    ${LOGIN_USERNAME_ID}
    ...    ${LOGIN_PASSWORD_ID}
    ...    ${PRODUCT_NAME_FIELD_ID}
    ...    ${PRODUCT_DESC_FIELD_ID}
    ...    ${PRODUCT_PRICE_FIELD_ID}

    FOR    ${field}    IN    @{common_fields}
        ${is_visible}=    Run Keyword And Return Status    Element Should Be Visible    id=${field}
        Run Keyword If    ${is_visible}    Clear Text    id=${field}
    END

# =============================================================================
# KEYWORDS DE GESTION D'ERREURS
# =============================================================================

Handle Unexpected Error
    [Documentation]    Gère les erreurs inattendues pendant les tests
    [Tags]            error    handling

    Log    Erreur inattendue détectée
    Take Screenshot With Timestamp

    # Tenter de revenir à l'écran principal
    ${is_logged_in}=    Run Keyword And Return Status    Element Should Be Visible    text=${CREATE_PRODUCT_TEXT}
    Run Keyword Unless    ${is_logged_in}    Login With Valid Credentials

Verify No Error Messages
    [Documentation]    Vérifie qu'aucun message d'erreur n'est affiché
    [Tags]            verification    error

    ${error_present}=    Run Keyword And Return Status    Element Should Be Visible    id=${LOGIN_ERROR_ID}
    Should Not Be True    ${error_present}    Un message d'erreur inattendu est affiché

# =============================================================================
# KEYWORDS SPÉCIFIQUES FLUTTER (BONUS)
# =============================================================================

Flutter Wait For Element
    [Documentation]    Attend un élément Flutter spécifique
    [Arguments]        ${key}    ${timeout}=${FLUTTER_WAIT_TIMEOUT}
    [Tags]            flutter    utility

    Wait Until Element Is Visible    flutter:${key}    timeout=${timeout}

Flutter Tap Element
    [Documentation]    Tape sur un élément Flutter
    [Arguments]        ${key}
    [Tags]            flutter    interaction

    Click Element    flutter:${key}

Flutter Enter Text
    [Documentation]    Saisit du texte dans un champ Flutter
    [Arguments]        ${key}    ${text}
    [Tags]            flutter    input

    Input Text    flutter:${key}    ${text}
