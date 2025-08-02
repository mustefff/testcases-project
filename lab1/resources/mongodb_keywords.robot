*** Settings ***
Library    ../library/CustomMongoDBLibrary.py
Library    Collections
Library    DateTime
Library    String
Library    BuiltIn
Resource   mongodb_variables.robot

*** Keywords ***
# Connection Keywords
Connect To MongoDB Atlas
    [Documentation]    Connects to MongoDB Atlas using the CustomMongoDBLibrary
    Connect To MongoDB    ${MONGODB_URI}    ${27017}    ${CONNECT_TIMEOUT}    None
    Log    Connected to MongoDB Atlas successfully

Disconnect From MongoDB Atlas
    [Documentation]    Disconnects from MongoDB Atlas
    Disconnect From MongoDB
    Log    Disconnected from MongoDB Atlas

# Product Keywords
Create Product
    [Documentation]    Creates a new product in the products collection
    [Arguments]    ${product_data}
    ${json_data}=    Convert To Json String    ${product_data}
    ${result}=    Save MongoDB Records    ${DATABASE_NAME}    ${PRODUCTS_COLLECTION}    ${json_data}
    RETURN    ${result}

Get Product By Id
    [Documentation]    Retrieves a product by its ObjectId
    [Arguments]    ${product_id}
    ${query}=    Create Dictionary    _id=${product_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${PRODUCTS_COLLECTION}    ${json_query}    True
    ${product}=    Run Keyword If    ${result}    Get From List    ${result}    0    ELSE    Set Variable    ${EMPTY}
    RETURN    ${product}

Get Product By Title
    [Documentation]    Retrieves a product by its title
    [Arguments]    ${title}
    ${query}=    Create Dictionary    title=${title}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${PRODUCTS_COLLECTION}    ${json_query}    True
    ${product}=    Run Keyword If    ${result}    Get From List    ${result}    0    ELSE    Set Variable    ${EMPTY}
    RETURN    ${product}

Get All Products
    [Documentation]    Retrieves all products
    ${result}=    Retrieve All MongoDB Records    ${DATABASE_NAME}    ${PRODUCTS_COLLECTION}    True
    RETURN    ${result}

Update Product
    [Documentation]    Updates a product document
    [Arguments]    ${product_id}    ${update_data}
    ${query}=    Create Dictionary    _id=${product_id}
    ${json_query}=    Convert To Json String    ${query}
    ${json_update}=    Create Update Document    ${update_data}
    ${result}=    Retrieve And Update One MongoDB Record    ${DATABASE_NAME}    ${PRODUCTS_COLLECTION}    ${json_query}    ${json_update}    False
    RETURN    ${result}

Delete Product
    [Documentation]    Deletes a product by its ObjectId
    [Arguments]    ${product_id}
    ${query}=    Create Dictionary    _id=${product_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Remove MongoDB Records    ${DATABASE_NAME}    ${PRODUCTS_COLLECTION}    ${json_query}
    RETURN    ${result}

# User Keywords
Create User
    [Documentation]    Creates a new user in the users collection
    [Arguments]    ${user_data}
    ${json_data}=    Convert To Json String    ${user_data}
    ${result}=    Save MongoDB Records    ${DATABASE_NAME}    ${USERS_COLLECTION}    ${json_data}
    RETURN    ${result}

Get User By Id
    [Documentation]    Retrieves a user by ObjectId
    [Arguments]    ${user_id}
    ${query}=    Create Dictionary    _id=${user_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${USERS_COLLECTION}    ${json_query}    True
    ${user}=    Run Keyword If    ${result}    Get From List    ${result}    0    ELSE    Set Variable    ${EMPTY}
    RETURN    ${user}

Get User By Username
    [Documentation]    Retrieves a user by username
    [Arguments]    ${username}
    ${query}=    Create Dictionary    username=${username}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${USERS_COLLECTION}    ${json_query}    True
    ${user}=    Run Keyword If    ${result}    Get From List    ${result}    0    ELSE    Set Variable    ${EMPTY}
    RETURN    ${user}

Get User By Email
    [Documentation]    Retrieves a user by email
    [Arguments]    ${email}
    ${query}=    Create Dictionary    email=${email}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${USERS_COLLECTION}    ${json_query}    True
    ${user}=    Run Keyword If    ${result}    Get From List    ${result}    0    ELSE    Set Variable    ${EMPTY}
    RETURN    ${user}

Update User
    [Documentation]    Updates a user document
    [Arguments]    ${user_id}    ${update_data}
    ${query}=    Create Dictionary    _id=${user_id}
    ${json_query}=    Convert To Json String    ${query}
    ${json_update}=    Create Update Document    ${update_data}
    ${result}=    Retrieve And Update One MongoDB Record    ${DATABASE_NAME}    ${USERS_COLLECTION}    ${json_query}    ${json_update}    False
    RETURN    ${result}

Delete User
    [Documentation]    Deletes a user by ObjectId
    [Arguments]    ${user_id}
    ${query}=    Create Dictionary    _id=${user_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Remove MongoDB Records    ${DATABASE_NAME}    ${USERS_COLLECTION}    ${json_query}
    Log To Console    User with ID ${user_id} deleted successfully
    RETURN    ${result['deleted_count']}

# Cart Keywords
Get Carts By User Id
    [Documentation]    Retrieves all carts for a specific user
    [Arguments]    ${user_id}
    ${query}=    Create Dictionary    userId=${user_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${CARTS_COLLECTION}    ${json_query}    True
    RETURN    ${result}

Create Cart
    [Documentation]    Creates a new cart
    [Arguments]    ${cart_data}
    ${json_data}=    Convert To Json String    ${cart_data}
    ${result}=    Save MongoDB Records    ${DATABASE_NAME}    ${CARTS_COLLECTION}    ${json_data}
    RETURN    ${result}

Get Cart By Id
    [Documentation]    Retrieves a cart by ObjectId
    [Arguments]    ${cart_id}
    ${query}=    Create Dictionary    _id=${cart_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${CARTS_COLLECTION}    ${json_query}    True
    ${cart}=    Run Keyword If    ${result}    Get From List    ${result}    0    ELSE    Set Variable    ${EMPTY}
    RETURN    ${cart}

Get All Carts
    [Documentation]    Retrieves all carts
    ${result}=    Retrieve All MongoDB Records    ${DATABASE_NAME}    ${CARTS_COLLECTION}    True
    RETURN    ${result}

Update Cart
    [Documentation]    Updates a cart document
    [Arguments]    ${cart_id}    ${update_data}
    ${query}=    Create Dictionary    _id=${cart_id}
    ${json_query}=    Convert To Json String    ${query}
    ${json_update}=    Create Update Document    ${update_data}
    ${result}=    Retrieve And Update One MongoDB Record    ${DATABASE_NAME}    ${CARTS_COLLECTION}    ${json_query}    ${json_update}    False
    RETURN    ${result}

Add Product To Cart
    [Documentation]    Adds a product to an existing cart
    [Arguments]    ${cart_id}    ${product_data}
    ${cart}=    Get Cart By Id    ${cart_id}
    ${products}=    Get From Dictionary    ${cart}    products
    Append To List    ${products}    ${product_data}
    &{update_data}=    Create Dictionary    products=${products}
    ${result}=    Update Cart    ${cart_id}    ${update_data}
    RETURN    ${result}

Delete Cart
    [Documentation]    Deletes a cart by ObjectId
    [Arguments]    ${cart_id}
    ${query}=    Create Dictionary    _id=${cart_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Remove MongoDB Records    ${DATABASE_NAME}    ${CARTS_COLLECTION}    ${json_query}
    RETURN    ${result}

# Category Keywords
Create Category
    [Documentation]    Creates a new category
    [Arguments]    ${category_data}
    ${json_data}=    Convert To Json String    ${category_data}
    ${result}=    Save MongoDB Records    ${DATABASE_NAME}    ${CATEGORIES_COLLECTION}    ${json_data}
    RETURN    ${result}

Get Category By Id
    [Documentation]    Retrieves a category by ObjectId
    [Arguments]    ${category_id}
    ${query}=    Create Dictionary    _id=${category_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${CATEGORIES_COLLECTION}    ${json_query}    True
    ${category}=    Run Keyword If    ${result}    Get From List    ${result}    0    ELSE    Set Variable    ${EMPTY}
    RETURN    ${category}

Get Category By Name
    [Documentation]    Retrieves a category by name
    [Arguments]    ${name}
    ${query}=    Create Dictionary    name=${name}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Retrieve Some MongoDB Records    ${DATABASE_NAME}    ${CATEGORIES_COLLECTION}    ${json_query}    True
    ${category}=    Run Keyword If    ${result}    Get From List    ${result}    0    ELSE    Set Variable    ${EMPTY}
    RETURN    ${category}

Get All Categories
    [Documentation]    Retrieves all categories
    ${result}=    Retrieve All MongoDB Records    ${DATABASE_NAME}    ${CATEGORIES_COLLECTION}    True
    RETURN    ${result}

Update Category
    [Documentation]    Updates a category document
    [Arguments]    ${category_id}    ${update_data}
    ${query}=    Create Dictionary    _id=${category_id}
    ${json_query}=    Convert To Json String    ${query}
    ${json_update}=    Create Update Document    ${update_data}
    ${result}=    Retrieve And Update One MongoDB Record    ${DATABASE_NAME}    ${CATEGORIES_COLLECTION}    ${json_query}    ${json_update}    False
    RETURN    ${result}

Delete Category
    [Documentation]    Deletes a category by ObjectId
    [Arguments]    ${category_id}
    ${query}=    Create Dictionary    _id=${category_id}
    ${json_query}=    Convert To Json String    ${query}
    ${result}=    Remove MongoDB Records    ${DATABASE_NAME}    ${CATEGORIES_COLLECTION}    ${json_query}
    RETURN    ${result['deleted_count']}

# Validation Keywords
Validate Product Data
    [Documentation]    Validates product data structure
    [Arguments]    ${product_data}
    Dictionary Should Contain Key    ${product_data}    title    ${MISSING_FIELD_MSG}: title
    Dictionary Should Contain Key    ${product_data}    price    ${MISSING_FIELD_MSG}: price
    ${price}=    Get From Dictionary    ${product_data}    price
    Should Be True    ${price} > 0    Price must be positive

Validate User Data
    [Documentation]    Validates user data structure
    [Arguments]    ${user_data}
    Dictionary Should Contain Key    ${user_data}    email    ${MISSING_FIELD_MSG}: email
    Dictionary Should Contain Key    ${user_data}    username    ${MISSING_FIELD_MSG}: username
    Dictionary Should Contain Key    ${user_data}    password    ${MISSING_FIELD_MSG}: password

Validate Cart Data
    [Documentation]    Validates cart data structure
    [Arguments]    ${cart_data}
    Dictionary Should Contain Key    ${cart_data}    userId    ${MISSING_FIELD_MSG}: userId
    Dictionary Should Contain Key    ${cart_data}    date    ${MISSING_FIELD_MSG}: date
    Dictionary Should Contain Key    ${cart_data}    products    ${MISSING_FIELD_MSG}: products
    ${products}=    Get From Dictionary    ${cart_data}    products
    FOR    ${product}    IN    @{products}
        ${quantity}=    Get From Dictionary    ${product}    quantity
        Should Be True    ${quantity} > 0    Quantity must be positive
    END

Validate Category Data
    [Documentation]    Validates category data structure
    [Arguments]    ${category_data}
    Dictionary Should Contain Key    ${category_data}    name    ${MISSING_FIELD_MSG}: name

# Helper Keywords
Convert To Json String
    [Documentation]    Converts a dictionary to JSON string
    [Arguments]    ${dict}
    ${json_string}=    Evaluate    json.dumps(${dict})    json
    RETURN    ${json_string}

Create Update Document
    [Documentation]    Creates an update document with $set operator
    [Arguments]    ${update_data}
    ${update_doc}=    Create Dictionary    $set=${update_data}
    ${json_string}=    Convert To Json String    ${update_doc}
    RETURN    ${json_string}

Parse Json Result
    [Documentation]    Parses JSON result from MongoDB operation
    [Arguments]    ${json_result}
    ${result}=    Evaluate    json.loads('''${json_result}''')    json
    RETURN    ${result}

# Utility Keywords
Should Contain Key
    [Documentation]    Verifies that dictionary contains the given key
    [Arguments]    ${dictionary}    ${key}    ${msg}=${EMPTY}
    Dictionary Should Contain Key    ${dictionary}    ${key}    ${msg}

Verify Operation Result
    [Documentation]    Verifies the result of a MongoDB operation
    [Arguments]    ${result}    ${expected_count}=${1}
    Should Not Be Empty    ${result}
    Log    Operation result: ${result}

Clean Test Data
    [Documentation]    Cleans test data from collection
    [Arguments]    ${collection}    ${filter}
    ${json_filter}=    Convert To Json String    ${filter}
    ${result}=    Remove MongoDB Records    ${DATABASE_NAME}    ${collection}    ${json_filter}
    Log    Cleaned test data from ${collection} with filter ${filter}

Generate Test Email
    [Documentation]    Generates a unique test email
    ${timestamp}=    Get Current Date    result_format=epoch
    ${email}=    Set Variable    test.${timestamp}@example.com
    RETURN    ${email}

Generate Test Username
    [Documentation]    Generates a unique test username
    ${timestamp}=    Get Current Date    result_format=epoch
    ${username}=    Set Variable    testuser${timestamp}
    RETURN    ${username}

Create Test Product Data
    [Documentation]    Creates test product data with optional overrides
    [Arguments]    &{overrides}
    &{product}=    Create Dictionary
    ...    title=${TEST_PRODUCT_TITLE}
    ...    price=${TEST_PRODUCT_PRICE}
    ...    category=${TEST_PRODUCT_CATEGORY}
    ...    description=A test product created by Robot Framework
    ...    image=https://via.placeholder.com/640x480.png/09f/fff
    ...    rating=${{{"rate": 4.5, "count": 10}}}
    FOR    ${key}    ${value}    IN    &{overrides}
        Set To Dictionary    ${product}    ${key}=${value}
    END
    RETURN    ${product}

Create Test User Data
    [Documentation]    Creates test user data with optional overrides
    [Arguments]    &{overrides}
    ${unique_email}=    Generate Test Email
    ${unique_username}=    Generate Test Username
    &{user}=    Create Dictionary
    ...    email=${unique_email}
    ...    username=${unique_username}
    ...    password=${TEST_USER_PASSWORD}
    ...    name=${{{"firstname": "Test", "lastname": "User"}}}
    ...    phone=555-1234
    ...    address=${{{"city": "Test City", "street": "123 Test Street", "zipcode": "12345", "geolocation": {"lat": "40.7128", "long": "-74.0060"}}}}
    FOR    ${key}    ${value}    IN    &{overrides}
        Set To Dictionary    ${user}    ${key}=${value}
    END
    RETURN    ${user}

Create Test Cart Data
    [Documentation]    Creates test cart data
    [Arguments]    ${user_id}    @{products}
    ${current_date}=    Get Current Date    result_format=%Y-%m-%d
    &{cart}=    Create Dictionary    userId=${user_id}    date=${current_date}    products=@{products}
    RETURN    ${cart}

Create Test Category Data
    [Documentation]    Creates test category data
    [Arguments]    &{overrides}
    &{category}=    Create Dictionary
    ...    name=${TEST_CATEGORY_NAME}
    ...    description=A test category created by Robot Framework
    ...    image=https://test.com/category.jpg
    FOR    ${key}    ${value}    IN    &{overrides}
        Set To Dictionary    ${category}    ${key}=${value}
    END
    RETURN    ${category}

Verify Product Exists
    [Documentation]    Verifies that a product exists in the collection
    [Arguments]    ${product_id}
    ${product}=    Get Product By Id    ${product_id}
    Should Not Be Empty    ${product}    ${PRODUCT_NOT_FOUND_MSG}

Verify Product Does Not Exist
    [Documentation]    Verifies that a product does not exist
    [Arguments]    ${product_id}
    ${product}=    Get Product By Id    ${product_id}
    Should Be Empty    ${product}
