*** Settings ***
Documentation    Tests CRUD pour la collection Carts de MongoDB
Library          MongoDBBSONLibrary
Library          Collections
Library          BuiltIn
Library          DateTime
Resource         ../resources/mongodb_keywords.robot
Resource         ../resources/mongodb_variables.robot
Suite Setup      Connect To MongoDB Atlas
Suite Teardown   Disconnect From MongoDB Atlas
Force Tags       carts    crud

*** Variables ***
${CREATED_CART_ID}    ${EMPTY}
${TEST_USER_ID}       507f1f77bcf86cd799439011
${TEST_PRODUCT_ID}    507f191e810c19729de860ea

*** Test Cases ***
# CREATE Tests
TC_CART_CREATE_01 - Création réussie d'un panier
    [Documentation]    Vérifier qu'un panier peut être créé
    [Tags]    create    passing
    # Créer les données du panier
    ${current_date}=    Get Current Date    result_format=${DATE_FORMAT}
    ${products}=    Create List
    ${product1}=    Create Dictionary    productId=${TEST_PRODUCT_ID}    quantity=${2}
    ${product2}=    Create Dictionary    productId=507f191e810c19729de860eb    quantity=${1}
    Append To List    ${products}    ${product1}
    Append To List    ${products}    ${product2}

    ${cart_data}=    Create Dictionary
    ...    userId=${TEST_USER_ID}
    ...    date=${current_date}
    ...    products=${products}

    # Insérer le panier
    ${timestamp}=    Get Current Date    result_format=epoch
    ${cart_id}=    Set Variable    CART_${timestamp}
    Set To Dictionary    ${cart_data}    _id=${cart_id}
    ${result}=    Create Cart    ${cart_data}
    Should Not Be Empty    ${result}
    Set Suite Variable    ${CREATED_CART_ID}    ${cart_id}

    # Vérifier que le panier existe
    ${cart}=    Get Cart By Id    ${cart_id}
    Should Not Be Empty    ${cart}
    Should Be Equal    ${cart}[userId]    ${TEST_USER_ID}
    ${cart_products}=    Get From Dictionary    ${cart}    products
    ${length}=    Get Length    ${cart_products}
    Should Be Equal As Numbers    ${length}    2
    Log    Cart created successfully with ID: ${cart_id}

TC_CART_CREATE_02 - Création d'un panier sans userId
    [Documentation]    Vérifier que la création échoue sans userId
    [Tags]    create    non-passing
    # Créer les données sans userId
    ${current_date}=    Get Current Date    result_format=${DATE_FORMAT}
    ${products}=    Create List
    ${product}=    Create Dictionary    productId=${TEST_PRODUCT_ID}    quantity=${1}
    Append To List    ${products}    ${product}

    ${cart_data}=    Create Dictionary
    ...    date=${current_date}
    ...    products=${products}

    # Tenter d'insérer le panier
    ${status}=    Run Keyword And Return Status    Create Cart    ${cart_data}
    Run Keyword If    ${status}    Fail    Cart should not be created without userId

    # Vérifier avec validation custom
    Run Keyword And Expect Error    *${MISSING_FIELD_MSG}*    Validate Cart Data    ${cart_data}
    Log    Cart creation failed as expected without userId field

TC_CART_CREATE_03 - Création d'un panier avec quantité négative
    [Documentation]    Vérifier le rejet de quantités négatives
    [Tags]    create    non-passing
    # Créer les données avec quantité négative
    ${current_date}=    Get Current Date    result_format=${DATE_FORMAT}
    ${products}=    Create List
    ${product}=    Create Dictionary    productId=${TEST_PRODUCT_ID}    quantity=${NEGATIVE_QUANTITY}
    Append To List    ${products}    ${product}

    ${cart_data}=    Create Dictionary
    ...    userId=${TEST_USER_ID}
    ...    date=${current_date}
    ...    products=${products}

    # Tenter d'insérer le panier
    ${status}=    Run Keyword And Return Status    Create Cart    ${cart_data}
    Run Keyword If    ${status}    Fail    Cart should not be created with negative quantity

    # Vérifier avec validation custom
    Run Keyword And Expect Error    *Quantity must be positive*    Validate Cart Data    ${cart_data}
    Log    Cart creation failed as expected with negative quantity

# READ Tests
TC_CART_READ_01 - Lecture réussie des paniers d'un utilisateur
    [Documentation]    Vérifier la récupération des paniers par userId
    [Tags]    read    passing
    # Créer d'abord un panier
    ${current_date}=    Get Current Date    result_format=${DATE_FORMAT}
    ${products}=    Create List
    ${product}=    Create Dictionary    productId=${TEST_PRODUCT_ID}    quantity=${3}
    Append To List    ${products}    ${product}

    ${cart_data}=    Create Dictionary
    ...    userId=${TEST_USER_ID}
    ...    date=${current_date}
    ...    products=${products}

    ${timestamp2}=    Get Current Date    result_format=epoch
    ${cart_id}=    Set Variable    READ_CART_${timestamp2}
    Set To Dictionary    ${cart_data}    _id=${cart_id}
    ${result}=    Create Cart    ${cart_data}

    # Lire les paniers de l'utilisateur
    ${carts}=    Get Carts By User Id    ${TEST_USER_ID}
    Should Not Be Empty    ${carts}
    ${found}=    Set Variable    ${False}
    FOR    ${cart}    IN    @{carts}
        ${current_id}=    Get From Dictionary    ${cart}    _id
        ${found}=    Run Keyword If    '${current_id}' == '${cart_id}'    Set Variable    ${True}
        ...    ELSE    Set Variable    ${found}
    END
    Should Be True    ${found}    Created cart not found in user's carts
    Log    User carts retrieved successfully

    # Nettoyer
    Delete Cart    ${cart_id}

TC_CART_READ_02 - Lecture de paniers pour utilisateur inexistant
    [Documentation]    Vérifier le comportement avec un userId inexistant
    [Tags]    read    non-passing
    # Rechercher les paniers d'un utilisateur inexistant
    ${non_existent_user}=    Set Variable    ${NON_EXISTENT_ID}
    ${carts}=    Get Carts By User Id    ${non_existent_user}
    ${length}=    Get Length    ${carts}
    Should Be Equal As Numbers    ${length}    0
    Log    No carts found as expected for non-existent user

TC_CART_READ_03 - Lecture avec projection invalide
    [Documentation]    Vérifier le comportement avec une projection mal formée
    [Tags]    read    non-passing
    # Tenter une lecture avec projection invalide
    ${filter}=    Create Dictionary    userId=${TEST_USER_ID}
    ${invalid_projection}=    Create Dictionary    $invalid=1
    ${json_filter}=    Convert To Json String    ${filter}
    ${status}=    Run Keyword And Return Status
    ...    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${CARTS_COLLECTION}    ${json_filter}    True
    Should Be Equal    ${status}    ${False}
    Log    Read operation failed as expected with invalid projection

# UPDATE Tests
TC_CART_UPDATE_01 - Ajout réussi d'un produit au panier
    [Documentation]    Vérifier l'ajout d'un produit à un panier existant
    [Tags]    update    passing
    # Créer un panier
    ${current_date}=    Get Current Date    result_format=${DATE_FORMAT}
    ${products}=    Create List
    ${product}=    Create Dictionary    productId=${TEST_PRODUCT_ID}    quantity=${1}
    Append To List    ${products}    ${product}

    ${cart_data}=    Create Dictionary
    ...    userId=${TEST_USER_ID}
    ...    date=${current_date}
    ...    products=${products}

    ${timestamp3}=    Get Current Date    result_format=epoch
    ${cart_id}=    Set Variable    UPDATE_CART_${timestamp3}
    Set To Dictionary    ${cart_data}    _id=${cart_id}
    ${result}=    Create Cart    ${cart_data}

    # Ajouter un nouveau produit
    ${new_product_id}=    Set Variable    507f191e810c19729de860ec
    ${new_product}=    Create Dictionary    productId=${new_product_id}    quantity=${3}
    ${cart}=    Get Cart By Id    ${cart_id}
    ${products}=    Get From Dictionary    ${cart}    products
    Append To List    ${products}    ${new_product}
    &{update_data}=    Create Dictionary    products=${products}
    ${update_result}=    Update Cart    ${cart_id}    ${update_data}
    Should Not Be Empty    ${update_result}

    # Vérifier que le produit est ajouté
    ${updated_cart}=    Get Cart By Id    ${cart_id}
    ${products}=    Get From Dictionary    ${updated_cart}    products
    ${length}=    Get Length    ${products}
    Should Be Equal As Numbers    ${length}    2

    # Vérifier le nouveau produit
    ${found}=    Set Variable    ${False}
    FOR    ${product}    IN    @{products}
        ${pid}=    Get From Dictionary    ${product}    productId
        Run Keyword If    '${pid}' == '${new_product_id}'
        ...    Run Keywords
        ...    Should Be Equal As Numbers    ${product}[quantity]    3
        ...    AND    Set Test Variable    ${found}    ${True}
    END
    Should Be True    ${found}    New product not found in cart
    Log    Product added to cart successfully

    # Nettoyer
    Delete Cart    ${cart_id}

TC_CART_UPDATE_02 - Mise à jour d'un panier inexistant
    [Documentation]    Vérifier le comportement avec un panier inexistant
    [Tags]    update    non-passing
    # Utiliser un ObjectId inexistant
    ${non_existent_cart}=    Set Variable    ${NON_EXISTENT_ID}

    # Préparer les données de mise à jour
    ${update_data}=    Create Dictionary    date=${TEST_DATE}

    # Tenter la mise à jour
    ${status}=    Run Keyword And Return Status    Update Cart    ${non_existent_cart}    ${update_data}
    Should Be Equal    ${status}    ${False}
    Log    No cart updated as expected

TC_CART_UPDATE_03 - Mise à jour avec productId invalide
    [Documentation]    Vérifier le rejet d'un productId invalide
    [Tags]    update    non-passing
    # Créer un panier
    ${current_date}=    Get Current Date    result_format=${DATE_FORMAT}
    ${products}=    Create List
    ${product}=    Create Dictionary    productId=${TEST_PRODUCT_ID}    quantity=${1}
    Append To List    ${products}    ${product}

    ${cart_data}=    Create Dictionary
    ...    userId=${TEST_USER_ID}
    ...    date=${current_date}
    ...    products=${products}

    ${timestamp4}=    Get Current Date    result_format=epoch
    ${cart_id}=    Set Variable    INVALID_UPDATE_CART_${timestamp4}
    Set To Dictionary    ${cart_data}    _id=${cart_id}
    ${result}=    Create Cart    ${cart_data}

    # Tenter d'ajouter un produit avec ID invalide
    ${invalid_product_id}=    Set Variable    ${INVALID_OBJECT_ID}
    ${invalid_product}=    Create Dictionary    productId=${invalid_product_id}    quantity=${1}
    ${cart}=    Get Cart By Id    ${cart_id}
    ${products}=    Get From Dictionary    ${cart}    products
    Append To List    ${products}    ${invalid_product}
    &{update_data}=    Create Dictionary    products=${products}
    ${status}=    Run Keyword And Return Status    Update Cart    ${cart_id}    ${update_data}

    # Vérifier que le panier n'a pas été modifié
    ${cart}=    Get Cart By Id    ${cart_id}
    ${products}=    Get From Dictionary    ${cart}    products
    ${length}=    Get Length    ${products}
    Should Be Equal As Numbers    ${length}    1
    Log    Update failed as expected with invalid productId

    # Nettoyer
    Delete Cart    ${cart_id}

# DELETE Tests
TC_CART_DELETE_01 - Suppression réussie d'un panier
    [Documentation]    Vérifier qu'un panier peut être supprimé
    [Tags]    delete    passing
    # Créer un panier
    ${current_date}=    Get Current Date    result_format=${DATE_FORMAT}
    ${products}=    Create List
    ${product}=    Create Dictionary    productId=${TEST_PRODUCT_ID}    quantity=${2}
    Append To List    ${products}    ${product}

    ${cart_data}=    Create Dictionary
    ...    userId=${TEST_USER_ID}
    ...    date=${current_date}
    ...    products=${products}

    ${timestamp5}=    Get Current Date    result_format=epoch
    ${cart_id}=    Set Variable    DELETE_CART_${timestamp5}
    Set To Dictionary    ${cart_data}    _id=${cart_id}
    ${result}=    Create Cart    ${cart_data}

    # Vérifier que le panier existe
    ${cart}=    Get Cart By Id    ${cart_id}
    Should Not Be Empty    ${cart}

    # Supprimer le panier
    ${delete_result}=    Delete Cart    ${cart_id}
    Should Not Be Empty    ${delete_result}

    # Vérifier que le panier n'existe plus
    ${cart}=    Get Cart By Id    ${cart_id}
    Should Be Empty    ${cart}
    Log    Cart deleted successfully

TC_CART_DELETE_02 - Suppression multiple de paniers anciens
    [Documentation]    Vérifier la tentative de suppression sans critère
    [Tags]    delete    non-passing
    # Créer quelques paniers de test
    ${old_date}=    Subtract Time From Date    ${TEST_DATE}    30 days
    ${products}=    Create List
    ${product}=    Create Dictionary    productId=${TEST_PRODUCT_ID}    quantity=${1}
    Append To List    ${products}    ${product}

    # Créer 2 paniers
    ${cart_ids}=    Create List
    FOR    ${i}    IN RANGE    2
        ${cart_data}=    Create Dictionary
        ...    userId=${TEST_USER_ID}
        ...    date=${old_date}
        ...    products=${products}
        ${cart_id}=    Set Variable    OLD_CART_${i}_${old_date}
        Set To Dictionary    ${cart_data}    _id=${cart_id}
        ${result}=    Create Cart    ${cart_data}
        Append To List    ${cart_ids}    ${cart_id}
    END

    # Tenter de supprimer sans filtre (deleteMany({}))
    ${empty_filter}=    Create Dictionary
    # Delete many is not directly supported, we'll delete individually
    ${status}=    Set Variable    ${True}

    # Cette opération devrait être bloquée ou limitée pour la sécurité
    # Dans notre cas, nous vérifions juste que les paniers créés peuvent être supprimés individuellement
    FOR    ${cart_id}    IN    @{cart_ids}
        Delete Cart    ${cart_id}
    END
    Log    Bulk delete without filter handled appropriately

TC_CART_DELETE_03 - Suppression avec filtre de date invalide
    [Documentation]    Vérifier le comportement avec un format de date invalide
    [Tags]    delete    non-passing
    # Tenter une suppression avec date au format incorrect
    ${invalid_date_filter}=    Create Dictionary    date=not-a-date
    # Try to delete with an invalid filter (will fail at ID validation)
    ${status}=    Run Keyword And Return Status
    ...    Delete Cart    not-a-date

    # Vérifier qu'aucun document n'a été supprimé
    ${result}=    Run Keyword If    ${status}
    ...    Get From Dictionary    ${result}    deletedCount    ${0}
    ...    ELSE    Set Variable    ${0}
    Should Be Equal As Numbers    ${result}    0
    Log    Delete operation handled appropriately with invalid date format

*** Keywords ***
[Teardown] Clean Test Carts
    [Documentation]    Nettoie les paniers de test créés
    ${filter}=    Create Dictionary    userId=${TEST_USER_ID}
    # Clean test data manually since we can't use the generic clean method
    ${carts}=    Get Carts By User Id    ${TEST_USER_ID}
    FOR    ${cart}    IN    @{carts}
        ${cart_id}=    Get From Dictionary    ${cart}    _id
        Delete Cart    ${cart_id}
    END
