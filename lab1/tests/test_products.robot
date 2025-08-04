*** Settings ***
Documentation    Tests CRUD pour la collection Products de MongoDB
Library          Collections
Library          BuiltIn
Library          String
Library          DateTime
Resource         ../resources/mongodb_keywords.robot
Resource         ../resources/mongodb_variables.robot
Suite Setup      Connect To MongoDB Atlas
Suite Teardown   Disconnect From MongoDB Atlas
Force Tags       products    crud

*** Variables ***
${CREATED_PRODUCT_ID}    ${EMPTY}

*** Test Cases ***
# CREATE Tests
TC_PROD_CREATE_01 - Création réussie d'un produit
    [Documentation]    Vérifier qu'un produit peut être créé avec toutes les informations requises
    [Tags]    create    passing
    # Créer les données du produit avec un titre unique
    ${timestamp}=    Get Current Date    result_format=epoch
    ${unique_title}=    Set Variable    Test Product Robot Framework ${timestamp}
    ${product_data}=    Create Dictionary
    ...    _id=PRODUCT_${timestamp}
    ...    title=${unique_title}
    ...    price=${29.99}
    ...    description=This is a test product
    ...    category=electronics
    ...    image=https://test.com/image.jpg
    ...    rating=${{{"rate": 4.5, "count": 10}}}

    # Insérer le produit
    ${result}=    Create Product    ${product_data}
    Should Not Be Empty    ${result}
    Set Suite Variable    ${CREATED_PRODUCT_ID}    PRODUCT_${timestamp}

    # Vérifier que le produit existe
    ${product}=    Get Product By Id    PRODUCT_${timestamp}
    Should Not Be Empty    ${product}
    Should Be Equal    ${product}[title]    ${unique_title}
    Should Be Equal As Numbers    ${product}[price]    29.99
    Log    Product created successfully with ID: PRODUCT_${timestamp}

TC_PROD_CREATE_02 - Création d'un produit sans champ obligatoire
    [Documentation]    Vérifier que la création échoue sans le champ title
    [Tags]    create    non-passing
    # Créer les données sans title
    ${product_data}=    Create Dictionary
    ...    price=${29.99}
    ...    description=Product without title
    ...    category=electronics

    # Tenter d'insérer le produit
    ${status}=    Run Keyword And Return Status    Create Product    ${product_data}
    Run Keyword If    ${status}    Fail    Product should not be created without title

    # Vérifier avec validation custom
    Run Keyword And Expect Error    *${MISSING_FIELD_MSG}*    Validate Product Data    ${product_data}
    Log    Product creation failed as expected without title field

TC_PROD_CREATE_03 - Création d'un produit avec un prix invalide
    [Documentation]    Vérifier que la création échoue avec un prix négatif
    [Tags]    create    non-passing
    # Créer les données avec prix négatif
    ${product_data}=    Create Dictionary
    ...    title=Invalid Price Product
    ...    price=${NEGATIVE_PRICE}
    ...    description=Product with negative price
    ...    category=electronics

    # Tenter d'insérer le produit
    ${status}=    Run Keyword And Return Status    Create Product    ${product_data}
    Run Keyword If    ${status}    Fail    Product should not be created with negative price

    # Vérifier avec validation custom
    Run Keyword And Expect Error    *Price must be positive*    Validate Product Data    ${product_data}
    Log    Product creation failed as expected with negative price

# READ Tests
TC_PROD_READ_01 - Lecture réussie d'un produit par ID
    [Documentation]    Vérifier qu'un produit peut être lu par son ID
    [Tags]    read    passing
    # Créer d'abord un produit avec un ID unique
    ${timestamp}=    Get Current Date    result_format=epoch
    ${product_id}=    Set Variable    READ_TEST_${timestamp}
    ${product_data}=    Create Test Product Data    _id=${product_id}    title=Product to Read ${timestamp}
    ${result}=    Create Product    ${product_data}
    Should Not Be Empty    ${result}

    # Lire le produit
    ${product}=    Get Product By Id    ${product_id}
    Should Not Be Empty    ${product}
    Should Be Equal    ${product}[title]    Product to Read ${timestamp}
    Should Contain Key    ${product}    price
    Should Contain Key    ${product}    description
    Should Contain Key    ${product}    category
    Log    Product read successfully: ${product}

    # Nettoyer
    Delete Product    ${product_id}

TC_PROD_READ_02 - Lecture d'un produit avec un ID inexistant
    [Documentation]    Vérifier le comportement avec un ID inexistant
    [Tags]    read    non-passing
    # Utiliser un ObjectId valide mais inexistant
    ${non_existent_id}=    Set Variable    ${NON_EXISTENT_ID}

    # Tenter de lire le produit
    ${product}=    Get Product By Id    ${non_existent_id}
    Should Be Empty    ${product}
    Log    No product found as expected with non-existent ID

TC_PROD_READ_03 - Lecture avec un format d'ID invalide
    [Documentation]    Vérifier le comportement avec un format d'ID invalide
    [Tags]    read    non-passing
    # Utiliser un ID au format incorrect
    ${invalid_id}=    Set Variable    ${INVALID_OBJECT_ID}

    # Tenter de lire le produit
    ${status}=    Run Keyword And Return Status    Get Product By Id    ${invalid_id}
    Should Be Equal    ${status}    ${False}
    Log    Read operation failed as expected with invalid ID format

# UPDATE Tests
TC_PROD_UPDATE_01 - Mise à jour réussie du prix d'un produit
    [Documentation]    Vérifier qu'un produit peut être mis à jour
    [Tags]    update    passing
    # Créer un produit
    ${timestamp}=    Get Current Date    result_format=epoch
    ${product_id}=    Set Variable    UPDATE_TEST_${timestamp}
    ${product_data}=    Create Test Product Data    _id=${product_id}    title=Product to Update    price=${19.99}
    ${result}=    Create Product    ${product_data}

    # Préparer les données de mise à jour
    ${update_data}=    Create Dictionary
    ...    price=${39.99}
    ...    rating.count=${150}

    # Mettre à jour le produit
    ${update_result}=    Update Product    ${product_id}    ${update_data}
    Should Not Be Empty    ${update_result}

    # Vérifier les nouvelles valeurs
    ${updated_product}=    Get Product By Id    ${product_id}
    Should Be Equal As Numbers    ${updated_product}[price]    39.99
    Log    Product updated successfully

    # Nettoyer
    Delete Product    ${product_id}

TC_PROD_UPDATE_02 - Mise à jour d'un produit inexistant
    [Documentation]    Vérifier le comportement lors de la mise à jour d'un ID inexistant
    [Tags]    update    non-passing
    # Utiliser un ObjectId inexistant
    ${non_existent_id}=    Set Variable    ${NON_EXISTENT_ID}

    # Préparer les données de mise à jour
    ${update_data}=    Create Dictionary    price=${39.99}

    # Tenter la mise à jour
    ${status}=    Run Keyword And Return Status    Update Product    ${non_existent_id}    ${update_data}
    Should Be Equal    ${status}    ${False}
    Log    No document updated as expected

TC_PROD_UPDATE_03 - Mise à jour avec des données invalides
    [Documentation]    Vérifier le rejet de données invalides
    [Tags]    update    non-passing
    # Créer un produit
    ${timestamp}=    Get Current Date    result_format=epoch
    ${product_id}=    Set Variable    INVALID_UPDATE_${timestamp}
    ${product_data}=    Create Test Product Data    _id=${product_id}    title=Product Invalid Update
    ${result}=    Create Product    ${product_data}

    # Préparer des données invalides
    ${invalid_update}=    Create Dictionary
    ...    price=not a number
    ...    rating.rate=${INVALID_RATING}

    # Tenter la mise à jour
    ${status}=    Run Keyword And Return Status    Update Product    ${product_id}    ${invalid_update}

    # Vérifier que le produit n'a pas été modifié
    ${product}=    Get Product By Id    ${product_id}
    Should Not Be Equal    ${product}[price]    not a number
    Log    Update failed as expected with invalid data

    # Nettoyer
    Delete Product    ${product_id}

# DELETE Tests
TC_PROD_DELETE_01 - Suppression réussie d'un produit
    [Documentation]    Vérifier qu'un produit peut être supprimé
    [Tags]    delete    passing
    # Créer un produit
    ${timestamp}=    Get Current Date    result_format=epoch
    ${product_id}=    Set Variable    DELETE_TEST_${timestamp}
    ${product_data}=    Create Test Product Data    _id=${product_id}    title=Product to Delete
    ${result}=    Create Product    ${product_data}

    # Vérifier que le produit existe
    ${product}=    Get Product By Id    ${product_id}
    Should Not Be Empty    ${product}

    # Supprimer le produit
    ${delete_result}=    Delete Product    ${product_id}
    Should Not Be Empty    ${delete_result}

    # Vérifier que le produit n'existe plus
    ${product}=    Get Product By Id    ${product_id}
    Should Be Empty    ${product}
    Log    Product deleted successfully

TC_PROD_DELETE_02 - Suppression d'un produit inexistant
    [Documentation]    Vérifier le comportement lors de la suppression d'un ID inexistant
    [Tags]    delete    non-passing
    # Utiliser un ObjectId inexistant
    ${non_existent_id}=    Set Variable    ${NON_EXISTENT_ID}

    # Tenter la suppression
    ${result}=    Delete Product    ${non_existent_id}
    Should Be Equal As Numbers    ${result}[deleted_count]    0
    Log    No document deleted as expected

TC_PROD_DELETE_03 - Suppression avec un ID invalide
    [Documentation]    Vérifier le comportement avec un format d'ID invalide
    [Tags]    delete    non-passing
    # Utiliser un ID au format incorrect
    ${invalid_id}=    Set Variable    ${INVALID_OBJECT_ID}

    # Tenter la suppression
    ${result}=    Delete Product    ${invalid_id}
    Should Be Equal As Numbers    ${result}[deleted_count]    0
    Log    Delete operation failed as expected with invalid ID format

*** Keywords ***
[Teardown] Clean Test Products
    [Documentation]    Nettoie les produits de test créés
    ${filter}=    Create Dictionary    title=Test Product Robot Framework
    Clean Test Data    ${PRODUCTS_COLLECTION}    ${filter}
    ${filter}=    Create Dictionary    title=Product to Read
    Clean Test Data    ${PRODUCTS_COLLECTION}    ${filter}
    ${filter}=    Create Dictionary    title=Product to Update
    Clean Test Data    ${PRODUCTS_COLLECTION}    ${filter}
    ${filter}=    Create Dictionary    title=Product Invalid Update
    Clean Test Data    ${PRODUCTS_COLLECTION}    ${filter}
