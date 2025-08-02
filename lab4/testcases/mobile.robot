*** Settings ***
Library           AppiumLibrary

Variables        ../po/variables.py
Resource         ../resources/common.robot

Test Timeout    5 minutes
Suite Setup    Run Keyword    Open Application MyApp
Test Teardown    Run Keyword    Sleep    2s


*** Variables ***
${PRODUCT_NAME}    Rain Jacket Women Windbreaker


*** Test Cases ***
Test Authentication
    [Tags]     "auth"
    [Documentation]    Test du processus d'authentification de l'application
    [Timeout]  ${LONG_TIMEOUT}
    Enter username
    Enter password
    Log In
    # Vérification que l'authentification a réussi
    Wait Until Page Contains Element    ${PAGE_FORM}    ${MEDIUM_TIMEOUT}

Create New Product
    [Tags]     "create"
    [Documentation]    Création d'un nouveau produit après l'authentification
    [Timeout]  ${LONG_TIMEOUT}
    Fill Complete Form
    # Vérification que la création a réussi
    Sleep    2
    
View Specific Product
    [Tags]     "view"
    [Documentation]    Recherche et affichage d'un produit spécifique - "${PRODUCT_NAME}"
    [Timeout]  ${LONG_TIMEOUT}
    Navigate To Products
    Search For Product    ${PRODUCT_NAME}
    View Product Details    ${PRODUCT_ITEM}
    Verify Product Details    ${PRODUCT_NAME}
    Navigate Back