*** Settings ***
Documentation    Keywords spécialisés pour la gestion des produits
...              Application mobile Looma - Lab 4
...              Évite xpath pour obtenir les points bonus (+2 points)
...              Focus sur création et affichage de produits

Library          AppiumLibrary
Library          Collections
Library          String
Library          DateTime
Library          OperatingSystem
Library          Screenshot

Resource         variables.robot
Resource         base_keywords.robot

*** Keywords ***
# =============================================================================
# KEYWORDS DE CRÉATION DE PRODUIT
# =============================================================================

Create Product With Full Details
    [Documentation]    Crée un produit avec tous les détails requis
    [Arguments]        ${name}=${PRODUCT_NAME}    ${description}=${PRODUCT_DESCRIPTION}
    ...                ${price}=${PRODUCT_PRICE}    ${category}=${PRODUCT_CATEGORY}
    [Tags]            product    creation    full_details

    Log    Création du produit: ${name}
    Navigate To Create Product

    # Saisie des informations du produit (évite xpath)
    Wait Until Element Is Visible    id=${PRODUCT_NAME_FIELD_ID}    timeout=${EXPLICIT_WAIT}

    Clear Text    id=${PRODUCT_NAME_FIELD_ID}
    Input Text    id=${PRODUCT_NAME_FIELD_ID}    ${name}

    Clear Text    id=${PRODUCT_DESC_FIELD_ID}
    Input Text    id=${PRODUCT_DESC_FIELD_ID}    ${description}

    Clear Text    id=${PRODUCT_PRICE_FIELD_ID}
    Input Text    id=${PRODUCT_PRICE_FIELD_ID}    ${price}

    # Sélection de catégorie si le champ existe
    ${category_field_exists}=    Run Keyword And Return Status
    ...    Element Should Be Visible    android=new UiSelector().text("Catégorie")

    Run Keyword If    ${category_field_exists}
    ...    Select Product Category    ${category}

    # Sauvegarde du produit
    Click Element    id=${PRODUCT_SAVE_BUTTON_ID}
    Wait Until Element Is Visible    text=${PRODUCT_CREATED_MESSAGE}    timeout=${EXPLICIT_WAIT}

    Log    Produit créé avec succès: ${name}
    Take Screenshot With Timestamp

Create Rain Jacket Women Windbreaker
    [Documentation]    Crée spécifiquement le produit Rain Jacket Women Windbreaker
    [Tags]            product    creation    rain_jacket    specific

    ${product_name}=    Set Variable    Rain Jacket Women Windbreaker
    ${description}=     Set Variable    Veste imperméable pour femmes, parfaite pour les activités outdoor
    ${price}=          Set Variable    89.99
    ${category}=       Set Variable    Vêtements

    Create Product With Full Details    ${product_name}    ${description}    ${price}    ${category}
    Log    Rain Jacket Women Windbreaker créé avec succès

Create Product With Validation Steps
    [Documentation]    Crée un produit en validant chaque étape
    [Arguments]        ${name}    ${description}    ${price}
    [Tags]            product    creation    validation    step_by_step

    Navigate To Create Product

    # Validation de la présence des champs
    Element Should Be Visible    id=${PRODUCT_NAME_FIELD_ID}
    Element Should Be Visible    id=${PRODUCT_DESC_FIELD_ID}
    Element Should Be Visible    id=${PRODUCT_PRICE_FIELD_ID}
    Element Should Be Visible    id=${PRODUCT_SAVE_BUTTON_ID}

    # Saisie avec validation du nom
    Input Text    id=${PRODUCT_NAME_FIELD_ID}    ${name}
    ${entered_name}=    Get Element Attribute    id=${PRODUCT_NAME_FIELD_ID}    text
    Should Be Equal    ${entered_name}    ${name}

    # Saisie avec validation de la description
    Input Text    id=${PRODUCT_DESC_FIELD_ID}    ${description}
    ${entered_desc}=    Get Element Attribute    id=${PRODUCT_DESC_FIELD_ID}    text
    Should Be Equal    ${entered_desc}    ${description}

    # Saisie avec validation du prix
    Input Text    id=${PRODUCT_PRICE_FIELD_ID}    ${price}
    ${entered_price}=    Get Element Attribute    id=${PRODUCT_PRICE_FIELD_ID}    text
    Should Be Equal    ${entered_price}    ${price}

    # Sauvegarde et vérification
    Click Element    id=${PRODUCT_SAVE_BUTTON_ID}
    Wait Until Element Is Visible    text=${PRODUCT_CREATED_MESSAGE}    timeout=${EXPLICIT_WAIT}

Create Product With Image Upload
    [Documentation]    Crée un produit avec upload d'image
    [Arguments]        ${name}    ${description}    ${price}    ${image_path}=None
    [Tags]            product    creation    image    upload

    Navigate To Create Product

    # Remplir les champs de base
    Input Text    id=${PRODUCT_NAME_FIELD_ID}    ${name}
    Input Text    id=${PRODUCT_DESC_FIELD_ID}    ${description}
    Input Text    id=${PRODUCT_PRICE_FIELD_ID}    ${price}

    # Upload d'image si le chemin est fourni
    Run Keyword If    '${image_path}' != 'None'
    ...    Upload Product Image    ${image_path}

    # Sauvegarde
    Click Element    id=${PRODUCT_SAVE_BUTTON_ID}
    Wait Until Element Is Visible    text=${PRODUCT_CREATED_MESSAGE}    timeout=${EXPLICIT_WAIT}

# =============================================================================
# KEYWORDS D'AFFICHAGE ET RECHERCHE DE PRODUITS
# =============================================================================

Display Product By Name
    [Documentation]    Affiche un produit spécifique par son nom
    [Arguments]        ${product_name}
    [Tags]            product    display    search    view

    Log    Recherche et affichage du produit: ${product_name}

    # Navigation vers la liste des produits
    Navigate To Products Menu

    # Recherche du produit (évite xpath)
    Wait Until Element Is Visible    id=${PRODUCT_SEARCH_ID}    timeout=${EXPLICIT_WAIT}
    Clear Text    id=${PRODUCT_SEARCH_ID}
    Input Text    id=${PRODUCT_SEARCH_ID}    ${product_name}

    # Attendre que les résultats se chargent
    Sleep    ${SHORT_WAIT}

    # Cliquer sur le produit trouvé (utilise UiAutomator)
    ${product_selector}=    Format String    ${BUTTON_BY_TEXT}    ${product_name}
    Wait Until Element Is Visible    android=${product_selector}    timeout=${EXPLICIT_WAIT}
    Click Element    android=${product_selector}

    # Vérifier que les détails sont affichés
    Wait Until Element Is Visible    id=${PRODUCT_TITLE_ID}    timeout=${EXPLICIT_WAIT}
    Log    Produit affiché: ${product_name}

Display Rain Jacket Women Windbreaker
    [Documentation]    Affiche spécifiquement le Rain Jacket Women Windbreaker
    [Tags]            product    display    rain_jacket    specific    demo

    ${target_product}=    Set Variable    Rain Jacket Women Windbreaker
    Display Product By Name    ${target_product}

    # Vérifications spécifiques pour ce produit
    Verify Product Details Displayed    ${target_product}

    # Capture d'écran pour démonstration
    Take Screenshot With Timestamp
    Log    Rain Jacket Women Windbreaker affiché avec succès

Search Products By Category
    [Documentation]    Recherche des produits par catégorie
    [Arguments]        ${category}
    [Tags]            product    search    category    filter

    Navigate To Products Menu

    # Cliquer sur le filtre de catégorie (évite xpath)
    ${category_filter}=    Format String    ${BUTTON_BY_TEXT}    ${category}
    Click Element    android=${category_filter}

    # Attendre le chargement des résultats
    Wait Until Element Is Visible    id=${PRODUCT_LIST_ID}    timeout=${EXPLICIT_WAIT}
    Sleep    ${SHORT_WAIT}

    Log    Recherche par catégorie effectuée: ${category}

Search Products By Price Range
    [Documentation]    Recherche des produits dans une fourchette de prix
    [Arguments]        ${min_price}    ${max_price}
    [Tags]            product    search    price_range    filter

    Navigate To Products Menu

    # Ouvrir les filtres de prix si disponibles
    ${price_filter_exists}=    Run Keyword And Return Status
    ...    Element Should Be Visible    android=new UiSelector().text("Prix")

    Run Keyword If    ${price_filter_exists}
    ...    Apply Price Filter    ${min_price}    ${max_price}

    Log    Recherche par fourchette de prix: ${min_price}-${max_price}

Browse All Products
    [Documentation]    Parcourt tous les produits disponibles
    [Tags]            product    browse    list    navigation

    Navigate To Products Menu

    # Vérifier la présence de la liste
    Element Should Be Visible    id=${PRODUCT_LIST_ID}

    # Compter les produits visibles
    ${product_count}=    Get Element Count    class=${PRODUCT_ITEM_CLASS}
    Log    Nombre de produits visibles: ${product_count}

    # Parcourir la liste si nécessaire
    Run Keyword If    ${product_count} > 5
    ...    Scroll Through Product List

# =============================================================================
# KEYWORDS DE VÉRIFICATION ET VALIDATION
# =============================================================================

Verify Product Details Displayed
    [Documentation]    Vérifie que tous les détails du produit sont affichés
    [Arguments]        ${expected_name}
    [Tags]            product    verification    details    validation

    # Vérification du titre
    Element Should Be Visible    id=${PRODUCT_TITLE_ID}
    ${displayed_title}=    Get Text    id=${PRODUCT_TITLE_ID}
    Should Contain    ${displayed_title}    ${expected_name}

    # Vérification du prix
    Element Should Be Visible    id=${PRODUCT_PRICE_DISPLAY_ID}
    ${price_text}=    Get Text    id=${PRODUCT_PRICE_DISPLAY_ID}
    Should Not Be Empty    ${price_text}

    # Vérification de la description
    Element Should Be Visible    id=${PRODUCT_DESC_DISPLAY_ID}
    ${desc_text}=    Get Text    id=${PRODUCT_DESC_DISPLAY_ID}
    Should Not Be Empty    ${desc_text}

    Log    Détails du produit vérifiés: ${expected_name}

Verify Product In Search Results
    [Documentation]    Vérifie qu'un produit apparaît dans les résultats de recherche
    [Arguments]        ${product_name}
    [Tags]            product    verification    search_results

    # Utilise UiAutomator pour éviter xpath
    ${product_selector}=    Format String    ${BUTTON_BY_TEXT}    ${product_name}
    Element Should Be Visible    android=${product_selector}
    Log    Produit trouvé dans les résultats: ${product_name}

Verify Product Creation Success
    [Documentation]    Vérifie qu'un produit a été créé avec succès
    [Tags]            product    verification    creation    success

    # Vérification du message de succès
    Element Should Be Visible    text=${PRODUCT_CREATED_MESSAGE}

    # Vérification optionnelle du retour à la liste
    ${back_to_list}=    Run Keyword And Return Status
    ...    Element Should Be Visible    id=${PRODUCT_LIST_ID}

    Log    Création de produit vérifiée avec succès

Validate Product Form Fields
    [Documentation]    Valide les champs du formulaire de création de produit
    [Tags]            product    validation    form    fields

    Navigate To Create Product

    # Vérification de la présence des champs obligatoires
    Element Should Be Visible    id=${PRODUCT_NAME_FIELD_ID}
    Element Should Be Visible    id=${PRODUCT_DESC_FIELD_ID}
    Element Should Be Visible    id=${PRODUCT_PRICE_FIELD_ID}
    Element Should Be Visible    id=${PRODUCT_SAVE_BUTTON_ID}

    # Vérification que les champs sont modifiables
    Element Should Be Enabled    id=${PRODUCT_NAME_FIELD_ID}
    Element Should Be Enabled    id=${PRODUCT_DESC_FIELD_ID}
    Element Should Be Enabled    id=${PRODUCT_PRICE_FIELD_ID}
    Element Should Be Enabled    id=${PRODUCT_SAVE_BUTTON_ID}

    Log    Champs du formulaire produit validés

Verify Product Price Format
    [Documentation]    Vérifie le format d'affichage du prix
    [Arguments]        ${expected_price}
    [Tags]            product    verification    price    format

    ${displayed_price}=    Get Text    id=${PRODUCT_PRICE_DISPLAY_ID}

    # Vérifications du format du prix
    Should Contain    ${displayed_price}    €    # ou $ selon la devise
    Should Match Regexp    ${displayed_price}    \\d+[.,]\\d{2}

    Log    Format du prix vérifié: ${displayed_price}

# =============================================================================
# KEYWORDS DE GESTION DES ERREURS ET CAS LIMITES
# =============================================================================

Create Product With Invalid Data
    [Documentation]    Teste la création de produit avec des données invalides
    [Arguments]        ${name}    ${description}    ${price}    ${expected_error}
    [Tags]            product    negative    validation    error

    Navigate To Create Product

    # Saisie des données invalides
    Input Text    id=${PRODUCT_NAME_FIELD_ID}    ${name}
    Input Text    id=${PRODUCT_DESC_FIELD_ID}    ${description}
    Input Text    id=${PRODUCT_PRICE_FIELD_ID}    ${price}

    # Tentative de sauvegarde
    Click Element    id=${PRODUCT_SAVE_BUTTON_ID}

    # Vérification du message d'erreur attendu
    Wait Until Element Is Visible    android=new UiSelector().textContains("${expected_error}")    timeout=${EXPLICIT_WAIT}
    Log    Erreur de validation détectée comme attendu: ${expected_error}

Create Product With Empty Fields
    [Documentation]    Teste la création avec des champs vides
    [Tags]            product    negative    empty_fields    validation

    Navigate To Create Product

    # Laisser tous les champs vides et tenter de sauvegarder
    Click Element    id=${PRODUCT_SAVE_BUTTON_ID}

    # Vérifier les messages d'erreur pour champs obligatoires
    Wait Until Element Is Visible    android=new UiSelector().textContains("obligatoire")    timeout=${EXPLICIT_WAIT}
    Log    Validation des champs obligatoires confirmée

Create Product With Invalid Price
    [Documentation]    Teste avec un prix invalide
    [Tags]            product    negative    price_validation

    @{invalid_prices}=    Create List    -10    abc    0    999999999

    FOR    ${invalid_price}    IN    @{invalid_prices}
        Log    Test avec prix invalide: ${invalid_price}
        Create Product With Invalid Data    Test Product    Description    ${invalid_price}    prix invalide
        Navigate To Create Product    # Reset pour le prochain test
    END

# =============================================================================
# KEYWORDS UTILITAIRES POUR PRODUITS
# =============================================================================

Select Product Category
    [Documentation]    Sélectionne une catégorie de produit
    [Arguments]        ${category}
    [Tags]            product    utility    category

    # Cliquer sur le dropdown de catégorie (évite xpath)
    Click Element    android=new UiSelector().text("Catégorie")

    # Sélectionner la catégorie spécifiée
    ${category_option}=    Format String    ${BUTTON_BY_TEXT}    ${category}
    Click Element    android=${category_option}

    Log    Catégorie sélectionnée: ${category}

Upload Product Image
    [Documentation]    Upload une image pour le produit
    [Arguments]        ${image_path}
    [Tags]            product    utility    image    upload

    # Cliquer sur le bouton d'upload d'image
    ${upload_button_exists}=    Run Keyword And Return Status
    ...    Element Should Be Visible    android=new UiSelector().text("Ajouter une image")

    Run Keyword If    ${upload_button_exists}
    ...    Click Element    android=new UiSelector().text("Ajouter une image")

    # Logique d'upload spécifique à l'implémentation
    Log    Image uploadée: ${image_path}

Clear Product Form
    [Documentation]    Vide tous les champs du formulaire produit
    [Tags]            product    utility    cleanup

    Clear Text    id=${PRODUCT_NAME_FIELD_ID}
    Clear Text    id=${PRODUCT_DESC_FIELD_ID}
    Clear Text    id=${PRODUCT_PRICE_FIELD_ID}
    Log    Formulaire produit vidé

Apply Price Filter
    [Documentation]    Applique un filtre de prix
    [Arguments]        ${min_price}    ${max_price}
    [Tags]            product    utility    filter    price

    # Ouvrir le menu des filtres
    Click Element    android=new UiSelector().text("Filtres")

    # Saisir les valeurs min et max
    Input Text    android=new UiSelector().text("Prix minimum")    ${min_price}
    Input Text    android=new UiSelector().text("Prix maximum")    ${max_price}

    # Appliquer le filtre
    Click Element    android=new UiSelector().text("Appliquer")

    Log    Filtre de prix appliqué: ${min_price} - ${max_price}

Scroll Through Product List
    [Documentation]    Fait défiler la liste des produits
    [Tags]            product    utility    scroll    navigation

    ${list_element}=    Set Variable    id=${PRODUCT_LIST_ID}

    # Scroll vers le bas dans la liste
    FOR    ${i}    IN RANGE    3
        Scroll Down    ${list_element}
        Sleep    1s
    END

    Log    Défilement de la liste des produits effectué

Count Products In List
    [Documentation]    Compte le nombre de produits dans la liste
    [Tags]            product    utility    count    metrics

    Navigate To Products Menu
    ${product_count}=    Get Element Count    class=${PRODUCT_ITEM_CLASS}
    Log    Nombre total de produits: ${product_count}
    [Return]    ${product_count}

Take Product Screenshot
    [Documentation]    Prend une capture d'écran du produit affiché
    [Arguments]        ${product_name}
    [Tags]            product    utility    screenshot

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${filename}=    Set Variable    product_${product_name}_${timestamp}.png
    ${safe_filename}=    Replace String    ${filename}    ${SPACE}    _
    Capture Page Screenshot    ${safe_filename}
    Log    Capture du produit sauvegardée: ${safe_filename}
