# RobotFrameWork Installation On Mobile
# (1) Installation Android Studio
# Rôle: IDE Officiel pour le développement d'application  Android

# Android studio tools
### Téléchargement: https://developer.android.com/studio?gad_source=1&gad_campaignid=21831783744&gbraid=0AAAAAC-IOZnXPw344KG6NyyKgMbXpkGtR&gclid=CjwKCAjwmenCBhA4EiwAtVjzmk77gHB7_N5OdHaNxEXX5tmoUarLqvGrgXzYW01Wm8av7DUIuO-Y3hoCq8sQAvD_BwE&gclsrc=aw.ds 

## Récupère le chemin d'installation
## In Android Studio, click File > Project Structure.
## Select SDK Location in the left pane. The path is shown under Android SDK location.

## apkanalyzer
### Fournit un aperçu de la composition de votre APK une fois le processus de construction terminé.

## avdmanager
### Permet de créer et de gérer des appareils virtuels Android (AVD) à partir de la ligne de commande.

## lint
### Analyse le code pour vous aider à identifier et à corriger les problèmes de qualité structurelle de votre code.

### retrace
### Pour les applications compilées par R8, retrace décode une trace de pile obscurcie qui renvoie à votre code source d'origine.

## sdkmanager
### Permet d'afficher, d'installer, de mettre à jour et de désinstaller les paquets pour le SDK Android.


# (2) Install Appium librairie

```
pip install robotframework-appiumlibrary
pip show robotframework-appiumlibrary
```

# (3) Install Appium Server
## Rôle: Appium est un projet open-source et un écosystème de logiciels connexes, conçu pour faciliter l'automatisation de l'interface
## utilisateur sur de nombreuses plateformes d'applications, y compris mobiles (iOS, Android, Tizen), navigateur (Chrome, Firefox, Safari), 
## bureau (macOS, Windows), TV (Roku, tvOS, Android TV, Samsung), et bien plus encore !

## URL: https://appium.io/docs/en/latest/ 
## Prérequis: https://appium.io/docs/en/latest/quickstart/requirements/ 
## (3-1) Installation URL: https://appium.io/docs/en/latest/quickstart/install/ (Utilisant npm)
 #   ## - Mac :  brew install appium
 #   ## - Windows: suivre la procédure décrite dans la documentation
## (3-2) Installation driver UiAutomator
## URL: https://appium.io/docs/en/latest/quickstart/uiauto2-driver/
## (3-3) Installtion JDK
## (3-4) Installation Driver uiautomator2
## (Option) : Installation via Androi SDK
```
appium driver install uiautomator2
```

## Vérification de l'installation
```
appium driver doctor uiautomator2
```

# (4) Installation Appium Inspector
## Rôle: Appium Inspector est un outil d'assistance graphique pour Appium, qui permet d'inspecter visuellement l'application en cours de test. 
## Il peut afficher une capture d'écran de la page de l'application ainsi que la source de la page, et comprend diverses fonctionnalités 
## permettant d'interagir avec l'application.

## Prérequis
## (4-1): JAVA HOME $JAVA_HOME 
## (4-1): Android HOME $ANDROID_HOME
## URL Appium Inspector: https://github.com/appium/appium-desktop/releases 
## URL Installation: Assets
## Lancer Appium Inspector
## Configurer la session dans Appium Inspector

### Remote Host: localhost or 127.0.0.1
### Port: 4723

## Set Up a New Session on Appium Inspector
## For instance, adding our virtual device

```
{
  "appium:automationName": "uiautomator2",
  "platformName": "Android",
  "appium:platformVersion": "16",
  "appium:deviceNme": "Pixel a3"
}
```
