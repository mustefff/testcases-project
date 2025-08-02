# Tests Automatisés pour Applications Mobiles avec Robot Framework

Framework de tests automatisés pour applications mobiles Android utilisant Robot Framework et Appium. Ce projet est conçu pour tester une application mobile Android avec une structure bien organisée suivant le modèle Page Object.

## Structure du projet

```
test_mobile/
├── docs/                  # Documentation du projet
├── po/                    # Page Objects
│   ├── locator.py         # Sélecteurs XPath pour les éléments de l'interface
│   └── variables.py       # Variables de configuration (URL Appium, infos appareil)
├── resources/             # Ressources réutilisables
│   └── common.robot       # Mots-clés communs pour les actions fréquentes
├── results/               # Rapports d'exécution des tests
└── testcases/             # Cas de test
    └── mobile.robot       # Tests d'authentification et de formulaire
```

## Fonctionnalités testées

1. **Authentification**
   - Saisie du nom d'utilisateur et mot de passe
   - Validation de la connexion

2. **Remplissage de formulaire**
   - Ajout d'un nouveau produit
   - Saisie des champs (titre, prix, description, catégorie, URL)
   - Validation du formulaire

## Configuration technique

- **Plateforme cible** : Android 16.0
- **Appareil émulé** : Pixel a3
- **Serveur Appium** : Local (http://127.0.0.1:4723)
- **Application testée** : `sn.sonatel.dsi.moussa.wade.moussawade`

## Prérequis

- Python 3.6+
- Robot Framework (`pip install robotframework`)
- Appium Library pour Robot Framework (`pip install robotframework-appiumlibrary`)
- Serveur Appium installé et configuré
- Android SDK et émulateur Android ou appareil physique
- Application à tester installée sur l'émulateur/appareil

## Installation

1. Cloner le dépôt
```bash
git clone https://github.com/mustefff/TestCases-Roboframework-for-mobile.git
cd TestCases-Roboframework-for-mobile
```

2. Installer les dépendances
```bash
pip install -r requirements.txt  # Si un fichier requirements.txt est présent
```

3. Configurer les variables dans `po/variables.py` selon votre environnement
```python
REMOTE_URL = "http://127.0.0.1:4723"  # URL du serveur Appium
PLATFORM_NAME = "Android"
PLATFORM_VERSION = "16.0"  # Version Android de votre émulateur/appareil
DEVICE_NAME = "Pixel a3"  # Nom de votre émulateur/appareil
APP_PACKAGE = "sn.sonatel.dsi.moussa.wade.moussawade"  # Package de l'application à tester
APP_ACTIVITY = ".MainActivity"  # Activité principale de l'application
```

## Exécution des tests

1. Démarrer le serveur Appium
```bash
appium
```

2. Démarrer l'émulateur Android ou connecter un appareil physique

3. Exécuter les tests
```bash
robot -d results testcases/mobile.robot
```

4. Pour exécuter des tests spécifiques par tags
```bash
robot -d results -i "init" testcases/mobile.robot  # Exécute uniquement les tests avec le tag "init"
robot -d results -i "form" testcases/mobile.robot  # Exécute uniquement les tests avec le tag "form"
```

## Rapports

Après l'exécution des tests, les rapports sont générés dans le dossier `results/`:
- `log.html` : Journal détaillé de l'exécution des tests
- `report.html` : Rapport de synthèse des tests
- `output.xml` : Données brutes de l'exécution au format XML

## Approche de test

Ce projet utilise une approche structurée avec séparation des responsabilités :
- **Page Objects** : Séparation des localisateurs (po/locator.py)
- **Configuration** : Séparation des variables de configuration (po/variables.py)
- **Mots-clés réutilisables** : Actions communes regroupées (resources/common.robot)
- **Cas de test de haut niveau** : Tests lisibles et maintenables (testcases/mobile.robot)

## Bonnes pratiques implémentées

- Utilisation du modèle Page Object pour une meilleure maintenabilité
- Séparation des localisateurs et de la logique de test
- Utilisation de mots-clés réutilisables pour éviter la duplication de code
- Documentation claire des cas de test avec tags et descriptions
- Gestion des attentes explicites pour la stabilité des tests

## Contributeurs

- Mustapha Diaw - Développeur principal

## Licence

Ce projet est sous licence MIT.
