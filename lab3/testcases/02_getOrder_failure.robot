*** Settings ***
Documentation    Test getOrder - Scénario non passant
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    https://api.ebay.com/sell/fulfillment/v1
${TOKEN}       my_token_here
${BAD_ORDER_ID}    invalid123

*** Test Cases ***
Test getOrder Failure
    [Documentation]    Test simple qui doit échouer
    Create Session    ebay    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    ebay    /order/${BAD_ORDER_ID}    headers=${headers}    expected_status=any
    Log    Réponse: ${response.status_code}
    Should Be Equal As Integers    ${response.status_code}    400
