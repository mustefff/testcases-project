*** Settings ***
Documentation    Test issueRefund - Scénario passant
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    https://api.ebay.com/sell/fulfillment/v1
${TOKEN}       my_token_here
${ORDER_ID}    12345

*** Test Cases ***
Test issueRefund Success
    [Documentation]    Test simple qui doit passer
    Create Session    ebay    ${BASE_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}    Content-Type=application/json
    ${data}=    Create Dictionary    reasonForRefund=BUYER_CANCELLED    comment=Test
    ${response}=    POST On Session    ebay    /order/${ORDER_ID}/issue_refund    json=${data}    headers=${headers}    expected_status=any
    Log    Réponse: ${response.status_code}
    Should Be Equal As Integers    ${response.status_code}    200
