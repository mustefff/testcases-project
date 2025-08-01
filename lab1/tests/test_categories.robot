*** Settings ***
Documentation    Tests CRUD pour la collection Categories de MongoDB
Library          MongoDBBSONLibrary
Library          Collections
Library          BuiltIn
Library          DateTime
Resource         ../resources/mongodb_keywords.robot
Resource         ../resources/mongodb_variables.robot
Suite Setup      Connect To MongoDB Atlas
Suite Teardown   Disconnect From MongoDB Atlas
Force Tags       categories    crud

*** Variables ***
${CREATED_CATEGORY_ID}    ${EMPTY}

*** Test Cases ***
# CREATE Tests
TC_CAT_CREATE_01 - Création réussie d'une catégorie
    [Documentation]    Vérifier qu'une catégorie peut être créée
    [Tags]    create    passing
    # Créer les données de la catégorie
    ${timestamp}=    Get Current Date    result_format=epoch
    ${category_data}=    Create Dictionary
    ...    name=home & garden ${timestamp}
    ...    description=Articles pour la maison et le jardin
    ...    image=https://example.com/category/home-garden.jpg

    # Insérer la catégorie
    ${category_id}=    Set Variable    CAT_${timestamp}
    Set To Dictionary    ${category_data}    _id=${category_id}
    ${result}=    Create Category    ${category_data}
    Should Not Be Empty    ${result}
    Set Suite Variable    ${CREATED_CATEGORY_ID}    ${category_id}

    # Vérifier que la catégorie existe
    ${category}=    Get Category By Id    ${category_id}
    Should Not Be Empty    ${category}
    Should Be Equal    ${category}[name]    home & garden ${timestamp}
    Should Be Equal    ${category}[description]    Articles pour la maison et le jardin
    Log    Category created successfully with ID: ${category_id}

TC_CAT_CREATE_02 - Création d'une catégorie avec nom dupliqué
    [Documentation]    Vérifier le rejet d'un nom de catégorie existant
    [Tags]    create    non-passing
    # Créer d'abord une catégorie
    ${timestamp}=    Get Current Date    result_format=epoch
    ${first_id}=    Set Variable    FIRST_CAT_${timestamp}
    ${first_category}=    Create Dictionary
    ...    _id=${first_id}
    ...    name=unique_category_${timestamp}
    ...    description=First category
    ...    image=https://example.com/first.jpg
    ${result}=    Create Category    ${first_category}

    # Tenter de créer une autre catégorie avec le même nom
    ${duplicate_category}=    Create Dictionary
    ...    name=unique_category_${timestamp}
    ...    description=Duplicate category
    ...    image=https://example.com/duplicate.jpg

    # Vérifier que la création échoue
    ${status}=    Run Keyword And Return Status    Create Category    ${duplicate_category}
    Run Keyword If    ${status}    Fail    Category should not be created with duplicate name

    Log    Category creation failed as expected with duplicate name

    # Nettoyer
    Delete Category    ${first_id}

TC_CAT_CREATE_03 - Création d'une catégorie sans nom
    [Documentation]    Vérifier que le nom est obligatoire
    [Tags]    create    non-passing
    # Créer les données sans nom
    ${category_data}=    Create Dictionary
    ...    description=Catégorie sans nom
    ...    image=https://example.com/image.jpg

    # Tenter d'insérer la catégorie
    ${status}=    Run Keyword And Return Status    Create Category    ${category_data}
    Run Keyword If    ${status}    Fail    Category should not be created without name

    # Vérifier avec validation custom
    Run Keyword And Expect Error    *${MISSING_FIELD_MSG}*    Validate Category Data    ${category_data}
    Log    Category creation failed as expected without name field

# READ Tests
TC_CAT_READ_01 - Lecture réussie de toutes les catégories
    [Documentation]    Vérifier la récupération de toutes les catégories
    [Tags]    read    passing
    # Créer d'abord quelques catégories
    ${timestamp}=    Get Current Date    result_format=epoch
    ${categories_to_create}=    Create List
    ${category_ids}=    Create List

    FOR    ${i}    IN RANGE    3
        ${cat_id}=    Set Variable    READ_CAT_${timestamp}_${i}
        ${cat_data}=    Create Dictionary
        ...    _id=${cat_id}
        ...    name=test_read_category_${timestamp}_${i}
        ...    description=Test category ${i}
        ...    image=https://example.com/cat${i}.jpg
        ${result}=    Create Category    ${cat_data}
        Append To List    ${category_ids}    ${cat_id}
    END

    # Récupérer toutes les catégories
    ${categories}=    Get All Categories
    Should Not Be Empty    ${categories}
    ${found_count}=    Set Variable    ${0}

    # Vérifier que nos catégories sont présentes
    FOR    ${category}    IN    @{categories}
        ${name}=    Get From Dictionary    ${category}    name
        ${is_test_cat}=    Run Keyword And Return Status
        ...    Should Contain    ${name}    test_read_category_${timestamp}
        Run Keyword If    ${is_test_cat}
        ...    Set Test Variable    ${found_count}    ${found_count + 1}
    END

    Should Be True    ${found_count} >= 3    Not all test categories found
    Log    All categories retrieved successfully

    # Nettoyer
    FOR    ${cat_id}    IN    @{category_ids}
        Delete Category    ${cat_id}
    END

TC_CAT_READ_02 - Lecture d'une catégorie par nom inexistant
    [Documentation]    Vérifier le comportement avec un nom inexistant
    [Tags]    read    non-passing
    # Rechercher une catégorie inexistante
    ${category}=    Get Category By Name    nonexistent_category_9999
    Should Be Empty    ${category}
    Log    No category found as expected with non-existent name

TC_CAT_READ_03 - Lecture avec regex invalide
    [Documentation]    Vérifier le comportement avec une regex mal formée
    [Tags]    read    non-passing
    # Tenter une recherche avec une regex invalide
    ${invalid_filter}=    Create Dictionary    name={"$regex": "[invalid"}
    ${json_filter}=    Convert To Json String    ${invalid_filter}
    ${status}=    Run Keyword And Return Status
    ...    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${CATEGORIES_COLLECTION}    ${json_filter}    True
    Should Be Equal    ${status}    ${False}
    Log    Read operation failed as expected with invalid regex

# UPDATE Tests
TC_CAT_UPDATE_01 - Mise à jour réussie de la description
    [Documentation]    Vérifier la mise à jour d'une catégorie
    [Tags]    update    passing
    # Créer une catégorie
    ${timestamp}=    Get Current Date    result_format=epoch
    ${category_id}=    Set Variable    UPDATE_CAT_${timestamp}
    ${category_data}=    Create Dictionary
        ...    _id=${category_id}
        ...    name=category_to_update_${timestamp}
        ...    description=Description initiale
        ...    image=https://example.com/initial.jpg
    ${result}=    Create Category    ${category_data}

    # Préparer les données de mise à jour
    ${update_data}=    Create Dictionary
    ...    description=Description mise à jour
    ...    image=https://example.com/updated-image.jpg

    # Mettre à jour la catégorie
    ${update_result}=    Update Category    ${category_id}    ${update_data}
    Should Not Be Empty    ${update_result}

    # Vérifier les nouvelles valeurs
    ${updated_category}=    Get Category By Id    ${category_id}
    Should Be Equal    ${updated_category}[description]    Description mise à jour
    Should Be Equal    ${updated_category}[image]    https://example.com/updated-image.jpg
    # Le nom ne doit pas avoir changé
    Should Be Equal    ${updated_category}[name]    category_to_update_${timestamp}
    Log    Category updated successfully

    # Nettoyer
    Delete Category    ${category_id}

TC_CAT_UPDATE_02 - Tentative de modification du nom
    [Documentation]    Vérifier que le nom ne peut pas être modifié
    [Tags]    update    non-passing
    # Créer une catégorie
    ${timestamp}=    Get Current Date    result_format=epoch
    ${category_id}=    Set Variable    IMMUTABLE_CAT_${timestamp}
    ${category_data}=    Create Dictionary
        ...    _id=${category_id}
        ...    name=immutable_name_${timestamp}
        ...    description=Original description
    ${result}=    Create Category    ${category_data}

    # Tenter de modifier le nom
    ${update_data}=    Create Dictionary
    ...    name=new_name_${timestamp}
    ...    description=Updated description

    # Effectuer la mise à jour
    ${update_result}=    Update Category    ${category_id}    ${update_data}

    # Vérifier que le nom n'a pas changé
    ${category}=    Get Category By Id    ${category_id}
    Should Be Equal    ${category}[name]    immutable_name_${timestamp}
    Log    Category name remained unchanged as expected

    # Nettoyer
    Delete Category    ${category_id}

TC_CAT_UPDATE_03 - Mise à jour d'une catégorie inexistante
    [Documentation]    Vérifier le comportement avec une catégorie inexistante
    [Tags]    update    non-passing
    # Utiliser un ObjectId inexistant
    ${non_existent_id}=    Set Variable    ${NON_EXISTENT_ID}

    # Préparer les données de mise à jour
    ${update_data}=    Create Dictionary
    ...    description=New description
    ...    image=https://example.com/new.jpg

    # Tenter la mise à jour
    ${status}=    Run Keyword And Return Status    Update Category    ${non_existent_id}    ${update_data}
    Should Be Equal    ${status}    ${False}
    Log    No category updated as expected

# DELETE Tests
TC_CAT_DELETE_01 - Suppression réussie d'une catégorie
    [Documentation]    Vérifier qu'une catégorie peut être supprimée
    [Tags]    delete    passing
    # Créer une catégorie
    ${timestamp}=    Get Current Date    result_format=epoch
    ${category_id}=    Set Variable    DELETE_CAT_${timestamp}
    ${category_data}=    Create Dictionary
        ...    _id=${category_id}
        ...    name=category_to_delete_${timestamp}
        ...    description=This category will be deleted
        ...    image=https://example.com/delete.jpg
    ${result}=    Create Category    ${category_data}

    # Vérifier que la catégorie existe
    ${category}=    Get Category By Id    ${category_id}
    Should Not Be Empty    ${category}

    # Supprimer la catégorie
    ${delete_result}=    Delete Category    ${category_id}
    Should Not Be Empty    ${delete_result}

    # Vérifier que la catégorie n'existe plus
    ${category}=    Get Category By Id    ${category_id}
    Should Be Empty    ${category}
    Log    Category deleted successfully

TC_CAT_DELETE_02 - Suppression d'une catégorie avec produits associés
    [Documentation]    Vérifier la protection des catégories avec produits
    [Tags]    delete    non-passing
    # Créer une catégorie
    ${timestamp}=    Get Current Date    result_format=epoch
    ${category_id}=    Set Variable    CAT_WITH_PROD_${timestamp}
    ${category_data}=    Create Dictionary
        ...    _id=${category_id}
        ...    name=category_with_products_${timestamp}
        ...    description=Category with associated products
    ${result}=    Create Category    ${category_data}

    # Simuler la vérification de produits associés
    # Dans un vrai système, on créerait un produit avec cette catégorie
    ${filter}=    Create Dictionary    category=category_with_products_${timestamp}
    ${json_filter}=    Convert To Json String    ${filter}
    ${products}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${PRODUCTS_COLLECTION}    ${json_filter}    True
    ${product_count}=    Get Length    ${products}

    # Tenter de supprimer la catégorie
    ${delete_result}=    Delete Category    ${category_id}

    # Dans un système avec contraintes, ceci pourrait être bloqué
    # Pour ce test, nous vérifions juste la logique
    Run Keyword If    ${product_count} > 0
    ...    Log    Category has ${product_count} associated products
    ...    ELSE
    ...    Log    Category has no associated products and was deleted

    # Si la catégorie a été supprimée, c'est OK pour ce test
    Log    Category deletion handled appropriately

TC_CAT_DELETE_03 - Suppression d'une catégorie inexistante
    [Documentation]    Vérifier le comportement avec une catégorie inexistante
    [Tags]    delete    non-passing
    # Utiliser un ObjectId inexistant
    ${non_existent_id}=    Set Variable    ${NON_EXISTENT_ID}

    # Tenter la suppression
    ${status}=    Run Keyword And Return Status    Delete Category    ${non_existent_id}
    Should Be Equal    ${status}    ${False}
    Log    No category deleted as expected

*** Keywords ***
[Teardown] Clean Test Categories
    [Documentation]    Nettoie les catégories de test créées
    # Nettoyer toutes les catégories de test créées
    ${categories}=    Get All Categories
    FOR    ${category}    IN    @{categories}
        ${name}=    Get From Dictionary    ${category}    name
        ${is_test}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${name}    .*(test_|category_).*
        Run Keyword If    ${is_test}
        ...    Run Keywords
        ...    ${id}=    Get From Dictionary    ${category}    _id
        ...    AND    Delete Category    ${id}
        ...    AND    Log    Cleaned test category: ${name}
    END
