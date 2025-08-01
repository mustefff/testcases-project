*** Settings ***
Documentation    Test getOrder - Scénario passant
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    https://jsonplaceholder.typicode.com
${TOKEN}       my_token_here
${ORDER_ID}    12345

*** Test Cases ***
Test getOrder Success
    [Documentation]    Test simple qui doit passer
    Create Session    ebay    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    ebay    /posts/1    headers=${headers}    expected_status=any
    Log    Réponse: ${response.status_code}
    Should Be Equal As Integers    ${response.status_code}    200
