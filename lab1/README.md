# Lab 1 - Tests automatisés sur MongoDB avec Robot Framework

## Description du projet

Ce projet implémente des tests automatisés pour une base de données MongoDB hébergée sur MongoDB Atlas, simulant l'API FakeStore. Les tests couvrent toutes les opérations CRUD (Create, Read, Update, Delete) sur quatre collections principales :
- Products (Produits)
- Users (Utilisateurs)
- Carts (Paniers)
- Categories (Catégories)

## Structure du projet

```
Lab1_/
├── docs/
│   └── cahier_de_tests_mongodb.md    # Cahier de tests détaillé avec tous les scénarios
├── resources/
│   ├── mongodb_keywords.robot        # Keywords personnalisés pour MongoDB
│   ├── mongodb_variables.robot       # Variables et configurations
│   └── env_loader.py                 # Chargeur de variables d'environnement
├── tests/
│   ├── test_products.robot          # Tests CRUD pour les produits
│   ├── test_users.robot             # Tests CRUD pour les utilisateurs
│   ├── test_carts.robot             # Tests CRUD pour les paniers
│   ├── test_categories.robot        # Tests CRUD pour les catégories
│   └── test_suite_mongodb.robot     # Suite principale
├── results/                          # Répertoire pour les rapports de tests
├── requirements.txt                  # Dépendances Python
├── .env.example                      # Exemple de configuration
├── .env                              # Configuration locale (non versionné)
└── README.md                        # Ce fichier
```

## Prérequis

- Python 3.8 ou supérieur
- Accès à une instance MongoDB Atlas
- Connexion Internet pour accéder à MongoDB Atlas

## Installation

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd Lab1_
   ```

2. **Créer un environnement virtuel Python**
   ```bash
   python -m venv venv
   
   # Sur Windows
   venv\Scripts\activate
   
   # Sur Linux/Mac
   source venv/bin/activate
   ```

3. **Installer les dépendances**
   ```bash
   pip install -r requirements.txt
   ```

## Configuration

1. **Configurer la connexion MongoDB**
   
   Copiez le fichier `.env.example` vers `.env` :
   ```bash
   cp .env.example .env
   ```
   
   Puis modifiez le fichier `.env` avec vos informations MongoDB Atlas :
   ```
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/
   DATABASE_NAME=fakeStoreDB
   ```
   
   Remplacez `username`, `password` et `cluster` par vos informations MongoDB Atlas.
   
   **Note** : Les variables sont automatiquement chargées depuis le fichier `.env` grâce au module `env_loader.py`

2. **Structure de la base de données**
   
   Assurez-vous que votre base MongoDB contient les collections suivantes :
   - `products`
   - `users`
   - `carts`
   - `categories`

## Exécution des tests

### Exécuter tous les tests
```bash
robot -d results tests/test_suite_mongodb.robot
```

### Exécuter les tests par collection
```bash
# Tests des produits
robot -d results tests/test_products.robot

# Tests des utilisateurs
robot -d results tests/test_users.robot

# Tests des paniers
robot -d results tests/test_carts.robot

# Tests des catégories
robot -d results tests/test_categories.robot
```

### Exécuter des tests spécifiques par tags
```bash
# Tous les tests CREATE
robot -d results -i create tests/

# Tests passants uniquement
robot -d results -i passing tests/

# Tests non-passants uniquement
robot -d results -i non-passing tests/

# Tests d'une collection spécifique
robot -d results -i products tests/
```

## Description des tests

### Structure des tests
Chaque collection dispose de 12 tests :
- **CREATE** : 3 tests (1 passant, 2 non-passants)
- **READ** : 3 tests (1 passant, 2 non-passants)
- **UPDATE** : 3 tests (1 passant, 2 non-passants)
- **DELETE** : 3 tests (1 passant, 2 non-passants)

### Types de scénarios

#### Scénarios passants
- Vérifient le comportement normal et attendu
- Confirment que les opérations CRUD fonctionnent correctement
- Valident les données retournées

#### Scénarios non-passants
- Testent les cas d'erreur et les validations
- Vérifient la gestion des données invalides
- Contrôlent les contraintes d'intégrité

## Rapports et résultats

Après l'exécution, les rapports sont disponibles dans le dossier `results/` :
- `log.html` : Journal détaillé de l'exécution
- `report.html` : Rapport de synthèse
- `output.xml` : Résultats au format XML

### Consulter les rapports
```bash
# Ouvrir le rapport dans le navigateur (Windows)
start results/report.html

# Sur Linux/Mac
open results/report.html
```

## Cahier de tests

Le cahier de tests complet est disponible dans `docs/cahier_de_tests_mongodb.md`. Il contient :
- La description détaillée de chaque test
- Les données de test utilisées
- Les résultats attendus
- Les critères de validation

## Gestion des erreurs communes

### Erreur de connexion MongoDB
```
MongoNetworkError: failed to connect to server
```
**Solution** : Vérifiez vos identifiants MongoDB et l'adresse IP autorisée dans MongoDB Atlas.

### Module MongoDBLibrary non trouvé
```
ModuleNotFoundError: No module named 'MongoDBLibrary'
```
**Solution** : Installez les dépendances avec `pip install -r requirements.txt`

### Tests échouant avec "Collection not found"
**Solution** : Assurez-vous que les collections existent dans votre base MongoDB.

## Maintenance et extension

### Ajouter de nouveaux tests
1. Créez un nouveau fichier dans le dossier `tests/`
2. Importez les ressources nécessaires
3. Suivez la structure des tests existants

### Modifier les données de test
Les variables de test sont centralisées dans `resources/mongodb_variables.robot`
Les variables de connexion MongoDB sont chargées depuis le fichier `.env`

### Personnaliser les keywords
Ajoutez vos keywords personnalisés dans `resources/mongodb_keywords.robot`

## Bonnes pratiques

1. **Isolation des tests** : Chaque test nettoie ses données après exécution
2. **Données uniques** : Utilisation de timestamps pour éviter les conflits
3. **Gestion d'erreurs** : Les tests capturent et vérifient les erreurs attendues
4. **Documentation** : Chaque test est documenté avec son objectif

## Support et contribution

Pour toute question ou contribution :
1. Consultez d'abord le cahier de tests
2. Vérifiez les logs d'exécution
3. Créez une issue avec les détails de votre problème

## Licence

Ce projet est développé dans le cadre d'un exercice de formation sur l'automatisation des tests MongoDB.