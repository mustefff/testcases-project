# Variables pour les tests API eBay Fulfillment

# Configuration de l'API eBay
EBAY_BASE_URL = "https://api.ebay.com/sell/fulfillment/v1"
EBAY_SANDBOX_URL = "https://api.sandbox.ebay.com/sell/fulfillment/v1"

# Headers pour les requêtes API
CONTENT_TYPE = "application/json"
AUTHORIZATION_HEADER = "Bearer"

# Endpoints de l'API
GET_ORDER_ENDPOINT = "/order"
GET_ORDERS_ENDPOINT = "/order"
ISSUE_REFUND_ENDPOINT = "/order/{order_id}/issue_refund"

# Données de test pour les commandes
VALID_ORDER_ID = "12345678901234567890"
INVALID_ORDER_ID = "invalid_order_id"
NON_EXISTENT_ORDER_ID = "99999999999999999999"

# Paramètres de recherche pour getOrders
SEARCH_FILTER = "creationdate:[2024-01-01T00:00:00.000Z..2024-12-31T23:59:59.999Z]"
LIMIT = "10"
OFFSET = "0"

# Données pour issueRefund
REFUND_AMOUNT = "10.00"
REFUND_CURRENCY = "USD"
REFUND_REASON = "BUYER_CANCELLED"

# Messages d'erreur attendus
ERROR_INVALID_ORDER_ID = "Invalid order ID format"
ERROR_ORDER_NOT_FOUND = "Order not found"
ERROR_UNAUTHORIZED = "Unauthorized"
ERROR_INVALID_TOKEN = "Invalid access token"

# Codes de statut HTTP
HTTP_OK = 200
HTTP_BAD_REQUEST = 400
HTTP_UNAUTHORIZED = 401
HTTP_NOT_FOUND = 404
HTTP_INTERNAL_SERVER_ERROR = 500

# Timeouts
REQUEST_TIMEOUT = 30
RETRY_COUNT = 3
