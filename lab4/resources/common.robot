*** Settings ***
Library           AppiumLibrary    timeout=45s    run_on_failure=Capture Page Screenshot

Variables        ../po/variables.py
Variables        ../po/locator.py




*** Keywords ***
Open Application MyApp
    Open Application       ${REMOTE_URL}   platformName=${PLATFORM_NAME}    deviceName=${DEVICE_NAME}    automationName=${AUTOMATION_NAME}    appPackage=${APP_PACKAGE}    appActivity=${APP_ACTIVITY}    noReset=true    newCommandTimeout=120    fullReset=false
    
Enter username
    Wait Until Element Is Visible    ${USERNAME}    ${SHORT_TIMEOUT}
    Click Element    ${USERNAME}
    Input Text    ${USERNAME}    johnd
    
Enter password
    Wait Until Element Is Visible    ${PASSWORD}    ${SHORT_TIMEOUT}
    Click Element    ${PASSWORD}
    Input Password    ${PASSWORD}    m38rmF$

Log In
    Wait Until Element Is Visible    ${LOGIN}    ${SHORT_TIMEOUT}
    Click Element    ${LOGIN}
    Wait Until Page Contains Element    ${PAGE_FORM}    ${MEDIUM_TIMEOUT}

Fill Form Title
    Wait Until Element Is Visible    ${FORM_TITLE}    ${MEDIUM_TIMEOUT}
    Click Element    ${FORM_TITLE}
    Input Text    ${FORM_TITLE}    Nouveau Produit Test

Fill Form Price
    Wait Until Element Is Visible    ${FORM_PRICE}    ${SHORT_TIMEOUT}
    Click Element    ${FORM_PRICE}
    Input Text    ${FORM_PRICE}    1999.99

Fill Form Description
    Wait Until Element Is Visible    ${FORM_DESCRIPTION}    ${SHORT_TIMEOUT}
    Click Element    ${FORM_DESCRIPTION}
    Input Text    ${FORM_DESCRIPTION}    Ceci est une description de test pour le nouveau produit

Fill Form Category
    Wait Until Element Is Visible    ${FORM_CATEGORIE}    ${SHORT_TIMEOUT}
    Click Element    ${FORM_CATEGORIE}
    Input Text    ${FORM_CATEGORIE}    Électronique

Fill Form URL
    Wait Until Element Is Visible    ${FORM_URL}    ${SHORT_TIMEOUT}
    Click Element    ${FORM_URL}
    Input Text    ${FORM_URL}    https://example.com/product-image.jpg

Submit Form
    Wait Until Element Is Visible    ${FORM_BUTTON_ADD}    ${SHORT_TIMEOUT}
    Click Element    ${FORM_BUTTON_ADD}
    Sleep    3    # Attendre que le formulaire soit soumis

Fill Complete Form
    Fill Form Title
    Fill Form Price
    Fill Form Description
    Fill Form Category
    Fill Form URL
    Submit Form
    
Navigate To Products
    Wait Until Element Is Visible    ${PRODUCTS_TAB}    ${MEDIUM_TIMEOUT}
    Click Element    ${PRODUCTS_TAB}
    Wait Until Page Contains Element    ${SEARCH_BAR}    ${MEDIUM_TIMEOUT}
    
Search For Product
    [Arguments]    ${product_name}
    Wait Until Element Is Visible    ${SEARCH_BAR}    ${MEDIUM_TIMEOUT}
    Click Element    ${SEARCH_BAR}
    Input Text    ${SEARCH_BAR}    ${product_name}
    Press Keycode    4    # Keycode 4 correspond à la touche retour pour masquer le clavier
    Sleep    2    # Attendre les résultats de recherche
    
View Product Details
    [Arguments]    ${product_locator}
    Wait Until Element Is Visible    ${product_locator}    ${MEDIUM_TIMEOUT}
    Click Element    ${product_locator}
    Wait Until Page Contains Element    ${PRODUCT_DETAILS}    ${MEDIUM_TIMEOUT}
    
Verify Product Details
    [Arguments]    ${product_name}
    Page Should Contain Text    ${product_name}    ${MEDIUM_TIMEOUT}
    
Navigate Back
    Wait Until Element Is Visible    ${BACK_BUTTON}    ${SHORT_TIMEOUT}
    Click Element    ${BACK_BUTTON}
    

