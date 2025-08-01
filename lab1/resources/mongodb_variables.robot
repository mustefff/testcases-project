*** Settings ***
Variables    env_loader.py

*** Variables ***
# MongoDB Connection Variables
# ${MONGODB_URI} and ${DATABASE_NAME} are now loaded from .env file via env_loader.py
# To override, create a .env file in the project root with:
# MONGODB_URI=mongodb+srv://your_username:your_password@your_cluster.mongodb.net/
# DATABASE_NAME=fakeStoreDB

# Connection timeouts (can also be set in .env file)
${CONNECT_TIMEOUT}          ${30000}
${SERVER_SELECTION_TIMEOUT}    ${30000}

# Collection Names
${PRODUCTS_COLLECTION}      products
${USERS_COLLECTION}         users
${CARTS_COLLECTION}         carts
${CATEGORIES_COLLECTION}    categories

# Test Data Variables
${TEST_PRODUCT_TITLE}       Test Product Robot Framework
${TEST_PRODUCT_PRICE}       ${29.99}
${TEST_PRODUCT_CATEGORY}    electronics
${TEST_USER_EMAIL}          test.robot@example.com
${TEST_USER_USERNAME}       testrobot
${TEST_USER_PASSWORD}       hashedPassword123
${TEST_CATEGORY_NAME}       test category

# Validation Messages
${PRODUCT_CREATED_MSG}      Product created successfully
${USER_CREATED_MSG}         User created successfully
${CART_CREATED_MSG}         Cart created successfully
${CATEGORY_CREATED_MSG}     Category created successfully

${PRODUCT_NOT_FOUND_MSG}    Product not found
${USER_NOT_FOUND_MSG}       User not found
${CART_NOT_FOUND_MSG}       Cart not found
${CATEGORY_NOT_FOUND_MSG}   Category not found

${INVALID_ID_MSG}           Invalid ObjectId format
${MISSING_FIELD_MSG}        Required field missing
${DUPLICATE_ERROR_MSG}      Duplicate key error

# Test Timeouts
${OPERATION_TIMEOUT}        10s
${DEFAULT_RETRY_COUNT}      3
${RETRY_INTERVAL}          1s

# Sample ObjectIds for testing
${INVALID_OBJECT_ID}        invalid_object_id_12345
${NON_EXISTENT_ID}         507f1f77bcf86cd799439011

# Date formats
${DATE_FORMAT}             %Y-%m-%dT%H:%M:%S.000Z
${TEST_DATE}               2024-01-15T10:00:00.000Z

# Default values
${DEFAULT_QUANTITY}         ${1}
${NEGATIVE_PRICE}          ${-50.00}
${NEGATIVE_QUANTITY}       ${-5}
${INVALID_RATING}          ${6.0}
${MAX_RATING}              ${5.0}
${MIN_RATING}              ${0.0}

# Test product data
&{TEST_PRODUCT_DATA}       title=${TEST_PRODUCT_TITLE}
...                        price=${TEST_PRODUCT_PRICE}
...                        description=This is a test product for Robot Framework
...                        category=${TEST_PRODUCT_CATEGORY}
...                        image=https://test.com/image.jpg

# Test user data
&{TEST_USER_DATA}          email=${TEST_USER_EMAIL}
...                        username=${TEST_USER_USERNAME}
...                        password=${TEST_USER_PASSWORD}
...                        phone=1-555-555-5555

# Test category data
&{TEST_CATEGORY_DATA}      name=${TEST_CATEGORY_NAME}
...                        description=Test category for automation
...                        image=https://test.com/category.jpg

# Error patterns
${VALIDATION_ERROR_PATTERN}    .*validation.*error.*
${DUPLICATE_ERROR_PATTERN}     .*duplicate.*key.*
${CONNECTION_ERROR_PATTERN}    .*connection.*failed.*
