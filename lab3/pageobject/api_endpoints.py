# Endpoints et configurations pour l'API eBay Fulfillment

# Configuration des environnements
ENVIRONMENTS = {
    "sandbox": "https://api.sandbox.ebay.com/sell/fulfillment/v1",
    "production": "https://api.ebay.com/sell/fulfillment/v1"
}

# Endpoints de l'API
ENDPOINTS = {
    "get_order": "/order/{order_id}",
    "get_orders": "/order",
    "issue_refund": "/order/{order_id}/issue_refund"
}

# Headers par défaut
DEFAULT_HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer {access_token}"
}

# Paramètres de requête pour getOrders
GET_ORDERS_PARAMS = {
    "filter": "creationdate:[2024-01-01T00:00:00.000Z..2024-12-31T23:59:59.999Z]",
    "limit": "10",
    "offset": "0",
    "orderIds": None
}

# Structure de données pour issueRefund
REFUND_PAYLOAD_TEMPLATE = {
    "reasonForRefund": "BUYER_CANCELLED",
    "comment": "Customer requested refund",
    "refundItems": [
        {
            "refundAmount": {
                "currency": "USD",
                "value": "10.00"
            },
            "lineItemId": "123456789",
            "legacyReference": {
                "legacyItemId": "987654321",
                "legacyTransactionId": "111222333"
            }
        }
    ],
    "orderLevelRefundAmount": {
        "currency": "USD", 
        "value": "2.00"
    }
}
