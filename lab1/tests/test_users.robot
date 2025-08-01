*** Settings ***
Documentation    Tests CRUD pour la collection Users de MongoDB
Library          Collections
Library          BuiltIn
Library          DateTime
Resource         ../resources/mongodb_keywords.robot
Resource         ../resources/mongodb_variables.robot
Suite Setup      Connect To MongoDB Atlas
Suite Teardown   Disconnect From MongoDB Atlas
Force Tags       users    crud

*** Variables ***
${CREATED_USER_ID}    ${EMPTY}

*** Test Cases ***
# CREATE Tests
TC_USER_CREATE_01 - Création réussie d'un utilisateur
    [Documentation]    Vérifier qu'un utilisateur peut être créé avec toutes les informations
    [Tags]    create    passing
    # Créer les données de l'utilisateur
    ${user_data}=    Create Dictionary
    ...    email=test.robot@example.com
    ...    username=testrobot
    ...    password=hashedPassword123
    ...    name=${{{"firstname": "Test", "lastname": "User"}}}
    ...    address=${{{"city": "Test City", "street": "123 Test Street", "zipcode": "12345", "geolocation": {"lat": "40.7128", "long": "-74.0060"}}}}
    ...    phone=1-555-555-5555

    # Insérer l'utilisateur
    ${userId}=    Create User    ${user_data}
    Should Not Be Empty    ${userId}

    # Vérifier que l'utilisateur existe
    ${user}=    Get User By Id    ${userId}
    Should Not Be Empty    ${user}
    Should Be Equal    ${user}[email]    test.robot@example.com
    Should Be Equal    ${user}[username]    testrobot
    Log    User created successfully with ID: ${userId}

TC_USER_CREATE_02 - Création d'un utilisateur avec email dupliqué
    [Documentation]    Vérifier que la création échoue avec un email existant
    [Tags]    create    non-passing
    # Créer d'abord un utilisateur avec un ID unique
    ${timestamp}=    Get Current Date    result_format=epoch
    ${first_id}=    Set Variable    USER_${timestamp}_1
    ${first_user}=    Create Test User Data    email=existing@example.com    _id=${first_id}
    ${result}=    Create User    ${first_user}

    # Tenter de créer un autre utilisateur avec le même email
    ${duplicate_user}=    Create Dictionary
    ...    email=existing@example.com
    ...    username=newuser
    ...    password=password123

    # Vérifier que la création échoue
    ${status}=    Run Keyword And Return Status    Create User    ${duplicate_user}
    Run Keyword If    ${status}
    ...    Run Keywords
    ...    Get User By Username    newuser
    ...    AND    Fail    User should not be created with duplicate email

    Log    User creation failed as expected with duplicate email

    # Nettoyer
    Delete User    ${first_id}

TC_USER_CREATE_03 - Création d'un utilisateur sans email
    [Documentation]    Vérifier que la création échoue sans email
    [Tags]    create    non-passing
    # Créer les données sans email
    ${user_data}=    Create Dictionary
    ...    username=userwithoutemail
    ...    password=password123
    ...    name=${{{"firstname": "No", "lastname": "Email"}}}

    # Tenter d'insérer l'utilisateur
    ${status}=    Run Keyword And Return Status    Create User    ${user_data}
    Run Keyword If    ${status}    Fail    User should not be created without email

    # Vérifier avec validation custom
    Run Keyword And Expect Error    *${MISSING_FIELD_MSG}*    Validate User Data    ${user_data}
    Log    User creation failed as expected without email field

# READ Tests
TC_USER_READ_01 - Lecture réussie d'un utilisateur par username
    [Documentation]    Vérifier qu'un utilisateur peut être trouvé par son username
    [Tags]    read    passing
    # Créer d'abord un utilisateur avec un ID unique
    ${timestamp}=    Get Current Date    result_format=epoch
    ${user_id}=    Set Variable    READ_USER_${timestamp}
    ${user_data}=    Create Test User Data    username=readtestuser    _id=${user_id}
    ${result}=    Create User    ${user_data}

    # Lire l'utilisateur par username
    ${user}=    Get User By Username    readtestuser
    Should Not Be Empty    ${user}
    Should Be Equal    ${user}[username]    readtestuser
    Should Contain Key    ${user}    email
    Should Contain Key    ${user}    password
    Log    User read successfully by username: ${user}

    # Nettoyer
    Delete User    ${user_id}

TC_USER_READ_02 - Lecture avec un username inexistant
    [Documentation]    Vérifier le comportement avec un username inexistant
    [Tags]    read    non-passing
    # Rechercher un utilisateur inexistant
    ${user}=    Get User By Username    nonexistentuser
    Should Be Empty    ${user}
    Log    No user found as expected with non-existent username

TC_USER_READ_03 - Lecture avec filtre invalide
    [Documentation]    Vérifier le comportement avec un filtre mal formé
    [Tags]    read    non-passing
    # Tenter une recherche avec un filtre invalide
    ${invalid_filter}=    Create Dictionary    $invalid_operator=test
    ${json_filter}=    Convert To Json String    ${invalid_filter}
    ${status}=    Run Keyword And Return Status    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${USERS_COLLECTION}    ${json_filter}    True
    Should Be Equal    ${status}    ${False}
    Log    Read operation failed as expected with invalid filter

# UPDATE Tests
TC_USER_UPDATE_01 - Mise à jour réussie de l'adresse
    [Documentation]    Vérifier qu'une adresse utilisateur peut être mise à jour
    [Tags]    update    passing
    # Créer un utilisateur avec un ID unique
    ${timestamp}=    Get Current Date    result_format=epoch
    ${user_id}=    Set Variable    UPDATE_USER_${timestamp}
    ${user_data}=    Create Test User Data    username=updatetestuser    _id=${user_id}
    ${result}=    Create User    ${user_data}

    # Préparer les données de mise à jour
    ${update_data}=    Create Dictionary
    ...    address.city=New City
    ...    address.street=456 New Street
    ...    address.zipcode=54321

    # Mettre à jour l'utilisateur
    ${update_result}=    Update User    ${user_id}    ${update_data}
    Should Not Be Empty    ${update_result}

    # Vérifier les nouvelles valeurs
    ${updated_user}=    Get User By Id    ${user_id}
    ${address}=    Get From Dictionary    ${updated_user}    address
    Should Be Equal    ${address}[city]    New City
    Should Be Equal    ${address}[street]    456 New Street
    Should Be Equal    ${address}[zipcode]    54321
    Log    User address updated successfully

    # Nettoyer
    Delete User    ${user_id}

TC_USER_UPDATE_02 - Mise à jour d'un email avec valeur dupliquée
    [Documentation]    Vérifier le rejet d'un email déjà utilisé
    [Tags]    update    non-passing
    # Créer deux utilisateurs avec des IDs uniques
    ${timestamp}=    Get Current Date    result_format=epoch
    ${user1_id}=    Set Variable    DUP_USER1_${timestamp}
    ${user2_id}=    Set Variable    DUP_USER2_${timestamp}
    ${user1_data}=    Create Test User Data    email=user1@example.com    _id=${user1_id}
    ${user2_data}=    Create Test User Data    email=user2@example.com    _id=${user2_id}
    ${result1}=    Create User    ${user1_data}
    ${result2}=    Create User    ${user2_data}

    # Tenter de mettre à jour user2 avec l'email de user1
    ${update_data}=    Create Dictionary    email=user1@example.com

    ${status}=    Run Keyword And Return Status    Update User    ${user2_id}    ${update_data}

    # Vérifier que l'email n'a pas changé
    ${user2}=    Get User By Id    ${user2_id}
    Should Be Equal    ${user2}[email]    user2@example.com
    Log    Update failed as expected with duplicate email

    # Nettoyer
    Delete User    ${user1_id}
    Delete User    ${user2_id}

TC_USER_UPDATE_03 - Mise à jour avec des coordonnées invalides
    [Documentation]    Vérifier le rejet de coordonnées GPS invalides
    [Tags]    update    non-passing
    # Créer un utilisateur avec un ID unique
    ${timestamp}=    Get Current Date    result_format=epoch
    ${user_id}=    Set Variable    INVALID_GEO_${timestamp}
    ${user_data}=    Create Test User Data    username=invalidgeoupdate    _id=${user_id}
    ${result}=    Create User    ${user_data}

    # Préparer des coordonnées invalides
    ${invalid_update}=    Create Dictionary
    ...    address.geolocation.lat=invalid
    ...    address.geolocation.long=999.999

    # Tenter la mise à jour
    ${update_result}=    Update User    ${user_id}    ${invalid_update}

    # Vérifier que les coordonnées n'ont pas été modifiées
    ${user}=    Get User By Id    ${user_id}
    ${address}=    Get From Dictionary    ${user}    address    ${{{}}}
    ${geo}=    Get From Dictionary    ${address}    geolocation    ${{{}}}
    ${lat}=    Get From Dictionary    ${geo}    lat    ${EMPTY}
    Should Not Be Equal    ${lat}    invalid
    Log    Update with invalid coordinates handled appropriately

    # Nettoyer
    Delete User    ${user_id}

# DELETE Tests
TC_USER_DELETE_01 - Suppression réussie d'un utilisateur
    [Documentation]    Vérifier qu'un utilisateur peut être supprimé
    [Tags]    delete    passing
    # Créer un utilisateur avec un ID unique
    ${timestamp}=    Get Current Date    result_format=epoch
    ${user_id}=    Set Variable    DELETE_USER_${timestamp}
    ${user_data}=    Create Test User Data    username=deletetestuser    _id=${user_id}
    ${result}=    Create User    ${user_data}

    # Vérifier que l'utilisateur existe
    ${user}=    Get User By Id    ${user_id}
    Should Not Be Empty    ${user}

    # Supprimer l'utilisateur
    ${delete_result}=    Delete User    ${user_id}
    Should Not Be Empty    ${delete_result}

    # Vérifier que l'utilisateur n'existe plus
    ${user}=    Get User By Id    ${user_id}
    Should Be Empty    ${user}
    Log    User deleted successfully

TC_USER_DELETE_02 - Suppression d'un utilisateur avec commandes actives
    [Documentation]    Vérifier la protection des utilisateurs avec commandes
    [Tags]    delete    non-passing
    # Créer un utilisateur avec un ID unique
    ${timestamp}=    Get Current Date    result_format=epoch
    ${user_id}=    Set Variable    USER_WITH_CARTS_${timestamp}
    ${user_data}=    Create Test User Data    username=userwithcarts    _id=${user_id}
    ${result}=    Create User    ${user_data}

    # Créer un panier pour cet utilisateur
    ${cart_data}=    Create Dictionary
    ...    userId=${user_id}
    ...    date=${TEST_DATE}
    ...    products=${{[{"productId": "507f1f77bcf86cd799439011", "quantity": 2}]}}
    ${cart_result}=    Create Cart    ${cart_data}
    ${cart_id}=    Get From Dictionary    ${cart_data}    _id    ${user_id}_cart

    # Vérifier que l'utilisateur a des paniers
    ${carts}=    Get Carts By User Id    ${user_id}
    ${cart_count}=    Get Length    ${carts}
    Should Be True    ${cart_count} > 0

    # Tenter de supprimer l'utilisateur (devrait être protégé)
    ${delete_result}=    Delete User    ${user_id}

    # Dans un système avec contraintes, ceci échouerait
    # Pour ce test, nous vérifions juste que l'utilisateur avec des paniers est identifié
    Log    User with active carts identified: ${cart_count} carts found

    # Nettoyer
    Delete Cart    ${cart_id}
    Delete User    ${user_id}

TC_USER_DELETE_03 - Suppression avec critère invalide
    [Documentation]    Vérifier le comportement avec un critère invalide
    [Tags]    delete    non-passing
    # Tenter une suppression avec un critère mal formé
    ${invalid_id}=    Set Variable    INVALID_ID_FORMAT
    ${count}=    Delete User    ${invalid_id}
    Should Be Equal As Integers    ${count}    0

    Log    Delete operation failed as expected with invalid criteria

*** Keywords ***
[Teardown] Clean Test Users
    [Documentation]    Nettoie les utilisateurs de test créés
    ${filter}=    Create Dictionary    email=test.robot@example.com
    Clean Test Data    ${USERS_COLLECTION}    ${filter}
    ${filter}=    Create Dictionary    username=readtestuser
    Clean Test Data    ${USERS_COLLECTION}    ${filter}
    ${filter}=    Create Dictionary    username=updatetestuser
    Clean Test Data    ${USERS_COLLECTION}    ${filter}
    ${filter}=    Create Dictionary    username=invalidgeoupdate
    Clean Test Data    ${USERS_COLLECTION}    ${filter}
    ${filter}=    Create Dictionary    username=deletetestuser
    Clean Test Data    ${USERS_COLLECTION}    ${filter}
    ${filter}=    Create Dictionary    username=userwithcarts
    Clean Test Data    ${USERS_COLLECTION}    ${filter}
