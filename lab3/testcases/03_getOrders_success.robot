*** Settings ***
Documentation    Test getOrders - Scénario passant
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    https://api.ebay.com/sell/fulfillment/v1
${TOKEN}       my_token_here

*** Test Cases ***
Test getOrders Success
    [Documentation]    Test simple qui doit passer
    Create Session    ebay    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    ebay    /order?limit=10    headers=${headers}    expected_status=any
    Log    Réponse: ${response.status_code}
    Should Be Equal As Integers    ${response.status_code}    200
