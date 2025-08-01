# Lab 3 : Tests d'APIs REST – Intégration avec eBay

## Description
Ce projet contient les tests d'automatisation Robot Framework pour l'intégration avec l'API Fulfillment d'eBay. Les tests couvrent les opérations principales : `getOrder`, `getOrders`, et `issueRefund`.

## Structure du Projet
```
lab3/
├── pageobject/
│   ├── variables.py          # Variables de configuration
│   └── api_endpoints.py      # Configuration des endpoints API
├── resources/
│   └── ebay_api_keywords.robot  # Mots-clés pour les tests API
├── testcases/
│   ├── 01_get_order_success_test.robot     # Tests réussis getOrder
│   ├── 02_get_order_failure_test.robot     # Tests échoués getOrder
│   ├── 03_get_orders_success_test.robot    # Tests réussis getOrders
│   ├── 04_get_orders_failure_test.robot    # Tests échoués getOrders
│   ├── 05_issue_refund_success_test.robot  # Tests réussis issueRefund
│   └── 06_issue_refund_failure_test.robot  # Tests échoués issueRefund
├── results/                  # Dossier pour les rapports de tests
├── requirements.txt          # Dépendances Python
└── README.md                # Documentation du projet
```

## Tests Implémentés

### getOrder (Test IDs: 3001-3002)
- **Scénario passant** : Récupération des détails d'une commande avec un ID valide
- **Scénarios non passants** : 
  - ID de commande invalide (erreur 400)
  - ID de commande inexistant (erreur 404)

### getOrders (Test IDs: 3003-3004)
- **Scénarios passants** : 
  - Récupération de commandes avec filtres valides
  - Pagination personnalisée
- **Scénarios non passants** :
  - Absence de filtre requis (erreur 400)
  - Format de filtre invalide (erreur 400)
  - Paramètres de pagination invalides (erreur 400)

### issueRefund (Test IDs: 3005-3006)
- **Scénarios passants** :
  - Remboursement complet avec données valides
  - Remboursement partiel
  - Différentes raisons de remboursement
- **Scénarios non passants** :
  - ID de commande invalide (erreur 400)
  - Montant de remboursement invalide (erreur 400)
  - Devise invalide (erreur 400)
  - Champs requis manquants (erreur 400)
  - Commande inexistante (erreur 404)

## Configuration Requise

### Prérequis
1. Python 3.8+
2. Robot Framework
3. Token d'accès eBay valide

### Installation
```bash
# Installer les dépendances
pip install -r requirements.txt

# Ou utiliser un environnement virtuel
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows
pip install -r requirements.txt
```

### Configuration du Token d'Accès
Avant d'exécuter les tests, vous devez configurer votre token d'accès eBay :

1. Obtenez un token d'accès depuis le [Developer Program d'eBay](https://developer.ebay.com/)
2. Modifiez la variable `ACCESS_TOKEN` dans `resources/ebay_api_keywords.robot`

```robot
${ACCESS_TOKEN}    votre_token_d_acces_ebay_ici
```

## Exécution des Tests

### Exécuter tous les tests
```bash
robot -d lab3/results lab3/testcases
```

### Exécuter des tests spécifiques par opération
```bash
# Tests getOrder seulement
robot -d lab3/results -i getOrder lab3/testcases

# Tests getOrders seulement  
robot -d lab3/results -i getOrders lab3/testcases

# Tests issueRefund seulement
robot -d lab3/results -i issueRefund lab3/testcases
```

### Exécuter des tests par type (succès/échec)
```bash
# Tests de succès seulement
robot -d lab3/results -i success lab3/testcases

# Tests d'échec seulement
robot -d lab3/results -i failure lab3/testcases
```

### Exécuter un test spécifique
```bash
robot -d lab3/results lab3/testcases/01_get_order_success_test.robot
```

## Environnements

### Sandbox (par défaut)
Les tests utilisent l'environnement sandbox d'eBay par défaut :
- URL : `https://api.sandbox.ebay.com/sell/fulfillment/v1`

### Production
Pour utiliser l'environnement de production, modifiez la variable `BASE_URL` dans `resources/ebay_api_keywords.robot` :
```robot
${BASE_URL}    ${EBAY_BASE_URL}  # Production
```

## Rapports et Logs

Après l'exécution, les rapports sont générés dans le dossier `results/` :
- `output.xml` : Résultats détaillés au format XML
- `log.html` : Log détaillé des tests
- `report.html` : Rapport de synthèse

## Bonnes Pratiques Implémentées

1. **Structure modulaire** : Séparation des variables, mots-clés et tests
2. **Gestion des erreurs** : Tests négatifs pour tous les cas d'erreur
3. **Logging détaillé** : Logs des requêtes et réponses pour le débogage
4. **Paramétrage flexible** : Variables centralisées et configurables
5. **Documentation complète** : Documentation des tests et mots-clés
6. **Tags organisés** : Classification des tests par type et opération
7. **Validation robuste** : Vérification de la structure des réponses
8. **Gestion des sessions** : Setup/Teardown appropriés

## Dépannage

### Erreurs d'authentification
- Vérifiez que votre token d'accès est valide et non expiré
- Assurez-vous d'utiliser le bon environnement (sandbox/production)

### Erreurs de réseau
- Vérifiez votre connexion internet
- Vérifiez que les URLs d'API sont correctes

### Tests qui échouent
- Consultez le fichier `log.html` pour les détails
- Vérifiez les logs des requêtes/réponses API
- Assurez-vous que les données de test sont appropriées

## Support
Pour plus d'informations sur l'API eBay Fulfillment :
- [Documentation officielle](https://developer.ebay.com/api-docs/sell/fulfillment/resources/methods)
- [Guide d'authentification eBay](https://developer.ebay.com/api-docs/static/oauth-tokens.html)
