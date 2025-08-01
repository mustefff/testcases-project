# Projet de Tests avec Robot Framework

Ce projet contient des exemples de tests automatisés utilisant Robot Framework avec SeleniumLibrary, RequestsLibrary et d'autres bibliothèques pour tester des applications web et des API.

![Robot Framework](https://img.shields.io/badge/Robot%20Framework-7.2.2-blue)
![Selenium](https://img.shields.io/badge/Selenium-4.16.0-green)
![Python](https://img.shields.io/badge/Python-3.13.1-yellow)

## Prérequis

- Python 3.13.1
- Robot Framework 7.2.2
- SeleniumLibrary 6.7.1
- RequestsLibrary 2.0.0
- Selenium 4.16.0
- Appium-Python-Client 3.2.1

## Structure du projet

Le projet est organisé en plusieurs laboratoires et exemples de tests :

- `example.robot` : Exemple simple de test web
- `lab2/` : Tests d'interface utilisateur pour une application CRM
- `lab3/` : Tests d'API pour une plateforme e-commerce
- `petstore_basic/` : Tests pour l'application Swagger Petstore
- `form/` : Tests de formulaires web
- `fakestore/` : Tests pour l'API FakeStore

## Lab2 - Tests d'Interface Utilisateur CRM

Le dossier `lab2` contient des tests automatisés pour une application CRM (Customer Relationship Management) utilisant le modèle Page Object.

### Structure de Lab2

```
lab2/
├── pageobject/
│   ├── locators.py       # Sélecteurs CSS et XPath pour les éléments de l'interface
│   └── variables.py      # Variables globales (URL, identifiants, etc.)
├── resources/
│   └── crm_keywords.robot # Mots-clés personnalisés pour les tests CRM
├── results/              # Dossier pour les rapports de test générés
└── testcases/
    ├── 01_home_test.robot       # Test de la page d'accueil
    ├── 02_login_fail_test.robot # Test d'échec de connexion
    ├── 03_login_test.robot      # Test de connexion réussie
    └── 04_add_customer_test.robot # Test d'ajout de client
```

### Scénarios de Test Lab2

1. **Test de la Page d'Accueil** : Vérifie que la page d'accueil se charge correctement
2. **Test d'Échec de Connexion** : Vérifie le comportement lors d'une tentative de connexion avec des identifiants incorrects
3. **Test de Connexion Réussie** : Vérifie qu'un utilisateur peut se connecter avec des identifiants valides
4. **Test d'Ajout de Client** : Vérifie qu'un utilisateur connecté peut ajouter un nouveau client

### Exécution des Tests Lab2

```bash
# Exécuter tous les tests de lab2
robot lab2/testcases/

# Exécuter un test spécifique
robot lab2/testcases/01_home_test.robot
```

## Lab3 - Tests d'API E-commerce

Le dossier `lab3` contient des tests d'API pour une plateforme e-commerce, utilisant RequestsLibrary pour tester différents endpoints REST.

### Structure de Lab3

```
lab3/
├── README.md            # Documentation spécifique à lab3
├── pageobject/
│   ├── api_endpoints.py # Définition des endpoints de l'API
│   └── variables.py     # Variables globales (URLs, tokens, etc.)
├── requirements.txt     # Dépendances Python spécifiques
├── resources/           # Ressources partagées pour les tests
├── results/             # Dossier pour les rapports de test générés
├── robot.yaml           # Configuration Robot Framework
└── testcases/
    ├── 01_getOrder_success.robot    # Test réussi de récupération de commande
    ├── 02_getOrder_failure.robot    # Test d'échec de récupération de commande
    ├── 03_getOrders_success.robot   # Test réussi de récupération de commandes
    ├── 04_getOrders_failure.robot   # Test d'échec de récupération de commandes
    ├── 05_issueRefund_success.robot # Test réussi de remboursement
    └── 06_issueRefund_failure.robot # Test d'échec de remboursement
```

### Scénarios de Test Lab3

1. **Récupération de Commande (Succès)** : Vérifie qu'une commande peut être récupérée avec un ID valide
2. **Récupération de Commande (Échec)** : Vérifie le comportement avec un ID de commande invalide
3. **Récupération de Commandes (Succès)** : Vérifie que toutes les commandes peuvent être récupérées
4. **Récupération de Commandes (Échec)** : Vérifie le comportement avec des paramètres invalides
5. **Remboursement (Succès)** : Vérifie qu'un remboursement peut être effectué pour une commande valide
6. **Remboursement (Échec)** : Vérifie le comportement lors d'une tentative de remboursement invalide

### Exécution des Tests Lab3

```bash
# Installer les dépendances spécifiques à lab3
pip install -r lab3/requirements.txt

# Exécuter tous les tests de lab3
robot lab3/testcases/

# Exécuter un test spécifique
robot lab3/testcases/01_getOrder_success.robot
```

## Comment exécuter les tests

1. Activez l'environnement virtuel :
   ```bash
   source /Users/papidiaw/selenium_env/bin/activate
   ```

2. Pour exécuter un test spécifique :
   ```bash
   robot chemin/vers/test.robot
   ```

3. Pour exécuter tous les tests d'un dossier :
   ```bash
   robot chemin/vers/dossier/
   ```

4. Pour générer des rapports personnalisés :
   ```bash
   robot --outputdir results --name "Mon Test Suite" chemin/vers/test.robot
   ```

## Bonnes Pratiques Implémentées

- **Modèle Page Object** : Séparation des localisateurs et de la logique de test
- **Mots-clés Personnalisés** : Création de mots-clés réutilisables pour simplifier les tests
- **Variables Externalisées** : Configuration stockée dans des fichiers séparés
- **Tests Indépendants** : Chaque test peut être exécuté de manière autonome
- **Gestion des Rapports** : Utilisation des capacités de reporting de Robot Framework

## Notes importantes

- Pour les tests web avec SeleniumLibrary, vous aurez besoin d'installer les WebDrivers correspondants aux navigateurs que vous souhaitez utiliser (Chrome, Firefox, etc.)
- Pour les tests d'API, assurez-vous que les endpoints sont accessibles depuis votre environnement
- Les tests utilisent parfois des services externes comme jsonplaceholder.typicode.com pour les démonstrations
