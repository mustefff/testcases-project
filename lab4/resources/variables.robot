*** Variables ***
# =============================================================================
# Variables globales pour les tests mobiles Looma
# Lab 4 - Tests automatisés avec Robot Framework
# =============================================================================

# Configuration Appium Server
${APPIUM_HOST}              127.0.0.1
${APPIUM_PORT}              4723
${APPIUM_URL}               http://${APPIUM_HOST}:${APPIUM_PORT}/wd/hub

# Configuration de l'application
${APP_PATH}                 ./looma.apk
${APP_PACKAGE}              com.looma.app
${APP_ACTIVITY}             com.looma.MainActivity

# Configuration des capacités Android
&{ANDROID_CAPABILITIES}
...    platformName=Android
...    platformVersion=11.0
...    deviceName=Android Emulator
...    automationName=UiAutomator2
...    app=${APP_PATH}
...    appPackage=${APP_PACKAGE}
...    appActivity=${APP_ACTIVITY}
...    noReset=false
...    fullReset=false
...    newCommandTimeout=300
...    implicitWaitTimeout=10000
...    enableScreenshots=true
...    screenshotOnFailure=true

# Configuration Flutter (pour bonus points)
&{FLUTTER_CAPABILITIES}
...    platformName=Android
...    platformVersion=11.0
...    deviceName=Android Emulator
...    automationName=Flutter
...    app=${APP_PATH}
...    flutterSystemPort=9999
...    flutterServerLaunchTimeout=300000
...    noReset=false
...    newCommandTimeout=300
...    implicitWaitTimeout=10000

# Timeouts
${IMPLICIT_WAIT}            10
${EXPLICIT_WAIT}            30
${PAGE_LOAD_TIMEOUT}        60
${SHORT_WAIT}               3
${MEDIUM_WAIT}              15
${LONG_WAIT}                30

# Données d'authentification
${VALID_USERNAME}           testuser@looma.com
${VALID_PASSWORD}           Test123!
${INVALID_USERNAME}         invalid@test.com
${INVALID_PASSWORD}         wrongpass
${EMPTY_VALUE}              ${EMPTY}

# Données de produit pour les tests
${PRODUCT_NAME}             Rain Jacket Women Windbreaker
${PRODUCT_CATEGORY}         Clothing
${PRODUCT_DESCRIPTION}      High-quality waterproof jacket for women
${PRODUCT_PRICE}            89.99
${PRODUCT_BRAND}            Looma Outdoor
${PRODUCT_SIZE}             M
${PRODUCT_COLOR}            Navy Blue

# Localisateurs d'éléments (éviter xpath pour bonus)
# Écran de connexion
${LOGIN_USERNAME_ID}        com.looma.app:id/edittext_username
${LOGIN_PASSWORD_ID}        com.looma.app:id/edittext_password
${LOGIN_BUTTON_ID}          com.looma.app:id/button_login
${LOGIN_ERROR_ID}           com.looma.app:id/textview_error

# Localisateurs par accessibility id
${LOGIN_USERNAME_ACCESS}    username_field
${LOGIN_PASSWORD_ACCESS}    password_field
${LOGIN_BUTTON_ACCESS}      login_button
${LOGOUT_BUTTON_ACCESS}     logout_button

# Localisateurs par text (évite xpath)
${LOGIN_BUTTON_TEXT}        Se connecter
${LOGOUT_BUTTON_TEXT}       Se déconnecter
${CREATE_PRODUCT_TEXT}      Créer un produit
${SAVE_BUTTON_TEXT}         Enregistrer
${CANCEL_BUTTON_TEXT}       Annuler

# Menu principal
${MENU_PRODUCTS_ID}         com.looma.app:id/menu_products
${MENU_CREATE_ID}           com.looma.app:id/menu_create
${MENU_PROFILE_ID}          com.looma.app:id/menu_profile

# Création de produit
${PRODUCT_NAME_FIELD_ID}    com.looma.app:id/edittext_product_name
${PRODUCT_DESC_FIELD_ID}    com.looma.app:id/edittext_description
${PRODUCT_PRICE_FIELD_ID}   com.looma.app:id/edittext_price
${PRODUCT_SAVE_BUTTON_ID}   com.looma.app:id/button_save_product

# Liste des produits
${PRODUCT_LIST_ID}          com.looma.app:id/recyclerview_products
${PRODUCT_ITEM_CLASS}       androidx.recyclerview.widget.RecyclerView
${PRODUCT_SEARCH_ID}        com.looma.app:id/edittext_search

# Détails du produit
${PRODUCT_TITLE_ID}         com.looma.app:id/textview_product_title
${PRODUCT_PRICE_DISPLAY_ID} com.looma.app:id/textview_product_price
${PRODUCT_DESC_DISPLAY_ID}  com.looma.app:id/textview_product_description

# Localisateurs UiAutomator (alternative à xpath)
${BUTTON_BY_TEXT}           new UiSelector().text("%s")
${FIELD_BY_HINT}            new UiSelector().textContains("%s")
${ELEMENT_BY_CLASS}         new UiSelector().className("%s")
${ELEMENT_BY_DESCRIPTION}   new UiSelector().description("%s")

# Messages d'erreur attendus
${LOGIN_ERROR_MESSAGE}      Nom d'utilisateur ou mot de passe incorrect
${EMPTY_FIELD_ERROR}        Ce champ est obligatoire
${PRODUCT_CREATED_MESSAGE}  Produit créé avec succès
${PRODUCT_SAVED_MESSAGE}    Produit enregistré

# Configuration des captures d'écran
${SCREENSHOT_DIR}           ./results/screenshots
${SCREENSHOT_ON_FAILURE}    true

# Données de test multiples
@{VALID_USERS}              testuser1@looma.com    testuser2@looma.com
@{INVALID_USERS}            invalid@test.com       wrong@user.com
@{PRODUCT_CATEGORIES}       Clothing    Electronics    Sports    Home

# Données pour tests de validation
@{INVALID_EMAILS}           invalid-email    @missing-local.com    missing-at-sign.com
@{WEAK_PASSWORDS}           123    short    password

# Configuration des rapports
${REPORT_DIR}               ./results
${LOG_LEVEL}                INFO
${REPORT_TITLE}             Tests Mobiles Looma - Lab 4

# Variables d'environnement
${TEST_ENV}                 development
${DEBUG_MODE}               false
${HEADLESS_MODE}            false

# Flutter-specific variables (si l'app est en Flutter)
${FLUTTER_DRIVER_PORT}      9999
${FLUTTER_APP_KEY}          flutter_app
${FLUTTER_WAIT_TIMEOUT}     30000
