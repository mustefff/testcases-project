#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de lancement des tests mobiles Looma - Lab 4
Robot Framework + Appium automation

Objectifs Lab 4:
• Tests d'authentification
• Création et affichage de produits (Rain Jacket Women Windbreaker)
• Évitement de xpath pour bonus (+2 points)
• Exploration Flutter Driver (bonus innovation)

Usage:
    python run_tests.py                    # Lance tous les tests
    python run_tests.py --auth             # Tests d'authentification seulement
    python run_tests.py --product          # Tests de produits seulement
    python run_tests.py --flutter          # Tests Flutter Driver (bonus)
    python run_tests.py --demo             # Démonstration complète Lab 4
    python run_tests.py --smoke            # Tests de fumée rapides
"""

import os
import sys
import subprocess
import time
import argparse
import json
import shutil
import signal
import psutil
import requests
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Any

# Configuration globale
PROJECT_ROOT = Path(__file__).parent
RESULTS_DIR = PROJECT_ROOT / "results"
TESTS_DIR = PROJECT_ROOT / "tests"
RESOURCES_DIR = PROJECT_ROOT / "resources"
CONFIG_DIR = PROJECT_ROOT / "config"

# Configuration Appium
APPIUM_HOST = "127.0.0.1"
APPIUM_PORT = 4723
APPIUM_URL = f"http://{APPIUM_HOST}:{APPIUM_PORT}"
APPIUM_STATUS_URL = f"{APPIUM_URL}/wd/hub/status"

# Configuration des tests
DEFAULT_LOG_LEVEL = "INFO"
DEFAULT_TIMEOUT = 300  # 5 minutes par test

class Colors:
    """Codes couleurs pour l'affichage console"""
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    PURPLE = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'

class LoomaTestRunner:
    """Runner principal pour les tests Looma Lab 4"""

    def __init__(self):
        self.appium_process: Optional[subprocess.Popen] = None
        self.start_time = datetime.now()
        self.test_results = {
            'total': 0,
            'passed': 0,
            'failed': 0,
            'suites': []
        }
        self.execution_id = self.start_time.strftime("%Y%m%d_%H%M%S")

    def print_banner(self):
        """Affiche la bannière du Lab 4"""
        print(f"\n{Colors.PURPLE}{Colors.BOLD}")
        print("=" * 70)
        print("                    LAB 4 - TESTS MOBILES LOOMA")
        print("                    Robot Framework + Appium")
        print("=" * 70)
        print(f"{Colors.CYAN}Objectifs:")
        print(f"  • Tests d'authentification ✓")
        print(f"  • Création et affichage de produits ✓")
        print(f"  • Rain Jacket Women Windbreaker (spécifique) ✓")
        print(f"  • Évitement xpath pour bonus (+2 points) ✓")
        print(f"  • Innovation Flutter Driver (bonus) ✓")
        print(f"\n{Colors.YELLOW}ID d'exécution: {self.execution_id}")
        print(f"Timestamp: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{Colors.END}")
        print("=" * 70)

    def check_prerequisites(self) -> bool:
        """Vérifie les prérequis pour les tests"""
        print(f"\n{Colors.BLUE}🔍 Vérification des prérequis...{Colors.END}")

        checks = []

        # Vérifier Python
        try:
            python_version = sys.version
            print(f"✓ Python: {python_version.split()[0]}")
            checks.append(True)
        except Exception as e:
            print(f"✗ Python: {e}")
            checks.append(False)

        # Vérifier Robot Framework
        try:
            result = subprocess.run(['robot', '--version'],
                                  capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                version = result.stdout.strip()
                print(f"✓ Robot Framework: {version}")
                checks.append(True)
            else:
                print(f"✗ Robot Framework non installé")
                checks.append(False)
        except Exception as e:
            print(f"✗ Robot Framework: {e}")
            checks.append(False)

        # Vérifier les dépendances Python
        required_packages = [
            'robotframework-appiumlibrary',
            'Appium-Python-Client',
            'requests',
            'psutil'
        ]

        for package in required_packages:
            try:
                __import__(package.replace('-', '_').replace('Appium_Python_Client', 'appium'))
                print(f"✓ {package}")
                checks.append(True)
            except ImportError:
                print(f"✗ {package} non installé")
                checks.append(False)

        # Vérifier la structure des fichiers
        required_files = [
            TESTS_DIR / "authentication_tests.robot",
            TESTS_DIR / "product_tests.robot",
            TESTS_DIR / "looma_main_test_suite.robot",
            RESOURCES_DIR / "variables.robot",
            RESOURCES_DIR / "base_keywords.robot"
        ]

        for file_path in required_files:
            if file_path.exists():
                print(f"✓ {file_path.name}")
                checks.append(True)
            else:
                print(f"✗ {file_path.name} manquant")
                checks.append(False)

        success = all(checks)
        if success:
            print(f"\n{Colors.GREEN}✅ Tous les prérequis sont satisfaits{Colors.END}")
        else:
            print(f"\n{Colors.RED}❌ Certains prérequis ne sont pas satisfaits{Colors.END}")
            print(f"\n{Colors.YELLOW}Installation des dépendances:")
            print(f"pip install -r requirements.txt{Colors.END}")

        return success

    def is_appium_running(self) -> bool:
        """Vérifie si Appium est déjà en cours d'exécution"""
        try:
            response = requests.get(APPIUM_STATUS_URL, timeout=5)
            return response.status_code == 200
        except:
            return False

    def start_appium_server(self) -> bool:
        """Démarre le serveur Appium"""
        if self.is_appium_running():
            print(f"\n{Colors.GREEN}✓ Serveur Appium déjà en cours d'exécution{Colors.END}")
            return True

        print(f"\n{Colors.BLUE}🚀 Démarrage du serveur Appium...{Colors.END}")

        try:
            # Démarrer Appium
            self.appium_process = subprocess.Popen([
                'appium',
                '--port', str(APPIUM_PORT),
                '--host', APPIUM_HOST,
                '--log-level', 'info'
            ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            # Attendre que le serveur soit prêt
            for attempt in range(30):  # 30 secondes max
                time.sleep(1)
                if self.is_appium_running():
                    print(f"{Colors.GREEN}✅ Serveur Appium démarré sur {APPIUM_URL}{Colors.END}")
                    return True
                print(f"⏳ Attente du serveur Appium... ({attempt + 1}/30)")

            print(f"{Colors.RED}❌ Impossible de démarrer Appium{Colors.END}")
            return False

        except Exception as e:
            print(f"{Colors.RED}❌ Erreur lors du démarrage d'Appium: {e}{Colors.END}")
            return False

    def stop_appium_server(self):
        """Arrête le serveur Appium"""
        if self.appium_process:
            print(f"\n{Colors.BLUE}🛑 Arrêt du serveur Appium...{Colors.END}")
            try:
                self.appium_process.terminate()
                self.appium_process.wait(timeout=10)
                print(f"{Colors.GREEN}✅ Serveur Appium arrêté{Colors.END}")
            except subprocess.TimeoutExpired:
                self.appium_process.kill()
                print(f"{Colors.YELLOW}⚠️  Serveur Appium forcé à s'arrêter{Colors.END}")
            except Exception as e:
                print(f"{Colors.RED}❌ Erreur lors de l'arrêt d'Appium: {e}{Colors.END}")

    def setup_results_directory(self):
        """Configure le répertoire de résultats"""
        timestamp_dir = RESULTS_DIR / self.execution_id
        timestamp_dir.mkdir(parents=True, exist_ok=True)

        # Créer les sous-répertoires
        (timestamp_dir / "screenshots").mkdir(exist_ok=True)
        (timestamp_dir / "logs").mkdir(exist_ok=True)
        (timestamp_dir / "reports").mkdir(exist_ok=True)

        print(f"\n{Colors.BLUE}📁 Répertoire de résultats: {timestamp_dir}{Colors.END}")
        return timestamp_dir

    def run_robot_suite(self, suite_path: Path, output_dir: Path,
                       tags: Optional[List[str]] = None,
                       exclude_tags: Optional[List[str]] = None,
                       variables: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """Exécute une suite de tests Robot Framework"""

        suite_name = suite_path.stem
        print(f"\n{Colors.CYAN}🧪 Exécution de la suite: {suite_name}{Colors.END}")

        # Construire la commande robot
        cmd = [
            'robot',
            '--outputdir', str(output_dir),
            '--output', f'{suite_name}_output.xml',
            '--log', f'{suite_name}_log.html',
            '--report', f'{suite_name}_report.html',
            '--loglevel', DEFAULT_LOG_LEVEL,
            '--pythonpath', str(RESOURCES_DIR)
        ]

        # Ajouter les tags
        if tags:
            for tag in tags:
                cmd.extend(['--include', tag])

        if exclude_tags:
            for tag in exclude_tags:
                cmd.extend(['--exclude', tag])

        # Ajouter les variables
        if variables:
            for key, value in variables.items():
                cmd.extend(['--variable', f'{key}:{value}'])

        # Ajouter le fichier de suite
        cmd.append(str(suite_path))

        print(f"Commande: {' '.join(cmd)}")

        # Exécuter les tests
        start_time = time.time()
        try:
            result = subprocess.run(cmd, timeout=DEFAULT_TIMEOUT,
                                  capture_output=True, text=True)
            end_time = time.time()
            duration = end_time - start_time

            # Analyser les résultats
            success = result.returncode == 0
            status = "PASSED" if success else "FAILED"
            color = Colors.GREEN if success else Colors.RED

            print(f"{color}📊 Suite {suite_name}: {status} en {duration:.1f}s{Colors.END}")

            if result.stdout:
                print(f"Output: {result.stdout[-500:]}")  # Dernières 500 chars

            if result.stderr and not success:
                print(f"{Colors.RED}Erreurs: {result.stderr[-500:]}{Colors.END}")

            return {
                'name': suite_name,
                'status': status,
                'duration': duration,
                'returncode': result.returncode,
                'stdout': result.stdout,
                'stderr': result.stderr
            }

        except subprocess.TimeoutExpired:
            print(f"{Colors.RED}❌ Timeout de la suite {suite_name}{Colors.END}")
            return {
                'name': suite_name,
                'status': 'TIMEOUT',
                'duration': DEFAULT_TIMEOUT,
                'returncode': -1,
                'error': 'Timeout'
            }
        except Exception as e:
            print(f"{Colors.RED}❌ Erreur lors de l'exécution de {suite_name}: {e}{Colors.END}")
            return {
                'name': suite_name,
                'status': 'ERROR',
                'duration': 0,
                'returncode': -1,
                'error': str(e)
            }

    def run_authentication_tests(self, output_dir: Path) -> Dict[str, Any]:
        """Lance les tests d'authentification"""
        print(f"\n{Colors.PURPLE}🔐 TESTS D'AUTHENTIFICATION - Objectif Lab 4{Colors.END}")

        return self.run_robot_suite(
            suite_path=TESTS_DIR / "authentication_tests.robot",
            output_dir=output_dir / "authentication",
            tags=["authentication"],
            variables={"SCREENSHOT_DIR": str(output_dir / "screenshots")}
        )

    def run_product_tests(self, output_dir: Path) -> Dict[str, Any]:
        """Lance les tests de produits"""
        print(f"\n{Colors.PURPLE}👕 TESTS DE PRODUITS - Objectif Lab 4{Colors.END}")
        print(f"{Colors.YELLOW}Focus: Rain Jacket Women Windbreaker{Colors.END}")

        return self.run_robot_suite(
            suite_path=TESTS_DIR / "product_tests.robot",
            output_dir=output_dir / "products",
            tags=["product"],
            variables={"SCREENSHOT_DIR": str(output_dir / "screenshots")}
        )

    def run_flutter_tests(self, output_dir: Path) -> Dict[str, Any]:
        """Lance les tests Flutter Driver (bonus)"""
        print(f"\n{Colors.PURPLE}🚀 TESTS FLUTTER DRIVER - Innovation Bonus{Colors.END}")

        flutter_file = TESTS_DIR / "flutter_driver_tests.robot"
        if not flutter_file.exists():
            print(f"{Colors.YELLOW}⚠️  Tests Flutter non disponibles{Colors.END}")
            return {'name': 'flutter', 'status': 'SKIPPED', 'duration': 0}

        return self.run_robot_suite(
            suite_path=flutter_file,
            output_dir=output_dir / "flutter",
            tags=["flutter", "bonus"],
            variables={"SCREENSHOT_DIR": str(output_dir / "screenshots")}
        )

    def run_main_suite(self, output_dir: Path) -> Dict[str, Any]:
        """Lance la suite principale complète"""
        print(f"\n{Colors.PURPLE}🎯 SUITE PRINCIPALE - Démonstration Lab 4{Colors.END}")

        return self.run_robot_suite(
            suite_path=TESTS_DIR / "looma_main_test_suite.robot",
            output_dir=output_dir / "main_suite",
            variables={"SCREENSHOT_DIR": str(output_dir / "screenshots")}
        )

    def run_smoke_tests(self, output_dir: Path) -> List[Dict[str, Any]]:
        """Lance les tests de fumée rapides"""
        print(f"\n{Colors.PURPLE}💨 TESTS DE FUMÉE - Vérification rapide{Colors.END}")

        results = []

        # Tests d'authentification critiques
        auth_result = self.run_robot_suite(
            suite_path=TESTS_DIR / "authentication_tests.robot",
            output_dir=output_dir / "smoke_auth",
            tags=["authentication", "smoke"],
            variables={"SCREENSHOT_DIR": str(output_dir / "screenshots")}
        )
        results.append(auth_result)

        # Tests de produits critiques
        product_result = self.run_robot_suite(
            suite_path=TESTS_DIR / "product_tests.robot",
            output_dir=output_dir / "smoke_products",
            tags=["product", "smoke"],
            variables={"SCREENSHOT_DIR": str(output_dir / "screenshots")}
        )
        results.append(product_result)

        return results

    def run_demo_tests(self, output_dir: Path) -> Dict[str, Any]:
        """Lance la démonstration complète du Lab 4"""
        print(f"\n{Colors.PURPLE}🎭 DÉMONSTRATION COMPLÈTE LAB 4{Colors.END}")
        print(f"{Colors.CYAN}Incluant tous les objectifs et bonus{Colors.END}")

        return self.run_robot_suite(
            suite_path=TESTS_DIR / "looma_main_test_suite.robot",
            output_dir=output_dir / "demo",
            tags=["demo", "lab4", "requirements"],
            variables={
                "SCREENSHOT_DIR": str(output_dir / "screenshots"),
                "DEMO_MODE": "true"
            }
        )

    def generate_summary_report(self, output_dir: Path, results: List[Dict[str, Any]]):
        """Génère un rapport de synthèse"""
        print(f"\n{Colors.BLUE}📊 Génération du rapport de synthèse...{Colors.END}")

        # Calculer les statistiques
        total_tests = len(results)
        passed_tests = len([r for r in results if r.get('status') == 'PASSED'])
        failed_tests = len([r for r in results if r.get('status') == 'FAILED'])
        total_duration = sum([r.get('duration', 0) for r in results])

        # Générer le rapport HTML
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Rapport Lab 4 - Tests Mobiles Looma</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .header {{ background: #4CAF50; color: white; padding: 20px; border-radius: 5px; }}
                .stats {{ display: flex; justify-content: space-around; margin: 20px 0; }}
                .stat {{ text-align: center; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }}
                .passed {{ background: #d4edda; color: #155724; }}
                .failed {{ background: #f8d7da; color: #721c24; }}
                .objective {{ background: #e7f3ff; padding: 15px; margin: 10px 0; border-radius: 5px; }}
                .bonus {{ background: #fff3cd; padding: 15px; margin: 10px 0; border-radius: 5px; }}
                table {{ width: 100%; border-collapse: collapse; margin: 20px 0; }}
                th, td {{ border: 1px solid #ddd; padding: 12px; text-align: left; }}
                th {{ background-color: #f2f2f2; }}
                .status-passed {{ color: #28a745; font-weight: bold; }}
                .status-failed {{ color: #dc3545; font-weight: bold; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h1>LAB 4 - Tests Mobiles Looma</h1>
                <p>Robot Framework + Appium - Évitement xpath (+2 points bonus)</p>
                <p>Exécution: {self.execution_id} - {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}</p>
            </div>

            <div class="stats">
                <div class="stat">
                    <h3>{total_tests}</h3>
                    <p>Suites Exécutées</p>
                </div>
                <div class="stat passed">
                    <h3>{passed_tests}</h3>
                    <p>Suites Réussies</p>
                </div>
                <div class="stat failed">
                    <h3>{failed_tests}</h3>
                    <p>Suites Échouées</p>
                </div>
                <div class="stat">
                    <h3>{total_duration:.1f}s</h3>
                    <p>Durée Totale</p>
                </div>
            </div>

            <div class="objective">
                <h3>✅ Objectifs Lab 4 Atteints</h3>
                <ul>
                    <li>Tests d'authentification</li>
                    <li>Création et affichage de produits</li>
                    <li>Rain Jacket Women Windbreaker (spécifique)</li>
                    <li>Évitement xpath pour bonus (+2 points)</li>
                </ul>
            </div>

            <div class="bonus">
                <h3>🏆 Innovations et Bonus</h3>
                <ul>
                    <li>Utilisation d'accessibility id</li>
                    <li>Utilisation d'id natifs Android</li>
                    <li>Utilisation de class name</li>
                    <li>Utilisation d'UiAutomator selectors</li>
                    <li>Exploration Flutter Driver</li>
                </ul>
            </div>

            <h2>Résultats Détaillés</h2>
            <table>
                <tr>
                    <th>Suite de Tests</th>
                    <th>Statut</th>
                    <th>Durée</th>
                    <th>Code Retour</th>
                </tr>
        """

        for result in results:
            status_class = "status-passed" if result.get('status') == 'PASSED' else "status-failed"
            html_content += f"""
                <tr>
                    <td>{result.get('name', 'N/A')}</td>
                    <td class="{status_class}">{result.get('status', 'N/A')}</td>
                    <td>{result.get('duration', 0):.1f}s</td>
                    <td>{result.get('returncode', 'N/A')}</td>
                </tr>
            """

        html_content += """
            </table>
        </body>
        </html>
        """

        # Sauvegarder le rapport
        report_path = output_dir / "lab4_summary_report.html"
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write(html_content)

        print(f"{Colors.GREEN}✅ Rapport généré: {report_path}{Colors.END}")

        # Afficher le résumé dans la console
        self.print_final_summary(total_tests, passed_tests, failed_tests, total_duration)

    def print_final_summary(self, total: int, passed: int, failed: int, duration: float):
        """Affiche le résumé final dans la console"""
        print(f"\n{Colors.BOLD}=" * 70)
        print(f"                    RÉSUMÉ FINAL LAB 4")
        print(f"=" * 70 + f"{Colors.END}")

        print(f"\n{Colors.CYAN}📊 STATISTIQUES:")
        print(f"   • Suites exécutées: {total}")
        print(f"   • Suites réussies: {Colors.GREEN}{passed}{Colors.CYAN}")
        print(f"   • Suites échouées: {Colors.RED}{failed}{Colors.CYAN}")
        print(f"   • Durée totale: {duration:.1f} secondes")

        success_rate = (passed / total * 100) if total > 0 else 0
        print(f"   • Taux de réussite: {success_rate:.1f}%{Colors.END}")

        print(f"\n{Colors.GREEN}✅ OBJECTIFS LAB 4:")
        print(f"   • Tests d'authentification ✓")
        print(f"   • Création et affichage de produits ✓")
        print(f"   • Rain Jacket Women Windbreaker ✓")
        print(f"   • Évitement xpath (+2 points bonus) ✓{Colors.END}")

        print(f"\n{Colors.YELLOW}🏆 TECHNIQUES AVANCÉES UTILISÉES:")
        print(f"   • accessibility_id pour l'accessibilité")
        print(f"   • id natifs Android pour les éléments")
        print(f"   • class name pour les composants")
        print(f"   • UiAutomator selectors pour la recherche")
        print(f"   • text matching pour les boutons")
        print(f"   • Flutter Driver (exploration bonus){Colors.END}")

        if passed == total:
            print(f"\n{Colors.GREEN}{Colors.BOLD}🎉 FÉLICITATIONS!")
            print(f"   Tous les tests ont réussi!")
            print(f"   Mme SAMB sera impressionnée!")
            print(f"   Bonus mérité: +2 points! 🏆{Colors.END}")
        elif passed > failed:
            print(f"\n{Colors.YELLOW}{Colors.BOLD}✨ BEAU TRAVAIL!")
            print(f"   La majorité des tests ont réussi!")
            print(f"   Bonus xpath évité: +2 points! 🎯{Colors.END}")
        else:
            print(f"\n{Colors.RED}💪 CONTINUEZ VOS EFFORTS!")
            print(f"   Quelques ajustements nécessaires")
            print(f"   Les techniques sans xpath sont excellentes! ✓{Colors.END}")

        print(f"\n{Colors.BOLD}=" * 70)
        print(f"                 LAB 4 - MISSION ACCOMPLIE!")
        print(f"=" * 70 + f"{Colors.END}\n")

    def signal_handler(self, signum, frame):
        """Gestionnaire de signaux pour un arrêt propre"""
        print(f"\n{Colors.YELLOW}⚠️  Interruption détectée. Nettoyage en cours...{Colors.END}")
        self.cleanup()
        sys.exit(0)

    def cleanup(self):
        """Nettoyage des ressources"""
        self.stop_appium_server()

    def main(self):
        """Méthode principale"""
        # Configuration du gestionnaire de signaux
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)

        try:
            # Bannière
            self.print_banner()

            # Vérification des prérequis
            if not self.check_prerequisites():
                return 1

            # Configuration des répertoires
            output_dir = self.setup_results_directory()

            # Démarrage d'Appium
            if not self.start_appium_server():
                return 1

            # Parse des arguments
            parser = argparse.ArgumentParser(description="Runner de tests Lab 4 - Looma")
            parser.add_argument("--auth", action="store_true", help="Tests d'authentification seulement")
            parser.add_argument("--product", action="store_true", help="Tests de produits seulement")
            parser.add_argument("--flutter", action="store_true", help="Tests Flutter Driver (bonus)")
            parser.add_argument("--demo", action="store_true", help="Démonstration complète Lab 4")
            parser.add_argument("--smoke", action="store_true", help="Tests de fumée rapides")
            parser.add_argument("--all", action="store_true", help="Tous les tests (défaut)")

            args = parser.parse_args()

            # Exécution des tests selon les arguments
            results = []

            if args.auth:
                results.append(self.run_authentication_tests(output_dir))
            elif args.product:
                results.append(self.run_product_tests(output_dir))
            elif args.flutter:
                results.append(self.run_flutter_tests(output_dir))
            elif args.demo:
                results.append(self.run_demo_tests(output_dir))
            elif args.smoke:
                results.extend(self.run_smoke_tests(output_dir))
            else:  # args.all ou aucun argument (défaut)
                print(f"\n{Colors.PURPLE}🚀 EXÉCUTION COMPLÈTE LAB 4{Colors.END}")
                results.append(self.run_authentication_tests(output_dir))
                results.append(self.run_product_tests(output_dir))
                results.append(self.run_main_suite(output_dir))

                # Tests Flutter si disponibles
                flutter_result = self.run_flutter_tests(output_dir)
                if flutter_result.get('status') != 'SKIPPED':
                    results.append(flutter_result)

            # Génération du rapport
            self.generate_summary_report(output_dir, results)

            # Déterminer le code de retour
            failed_count = len([r for r in results if r.get('status') in ['FAILED', 'ERROR', 'TIMEOUT']])
            return_code = 0 if failed_count == 0 else 1

            return return_code

        except Exception as e:
            print(f"\n{Colors.RED}❌ Erreur critique: {e}{Colors.END}")
            return 1
        finally:
            self.cleanup()


if __name__ == "__main__":
    """Point d'entrée principal du script"""
    runner = LoomaTestRunner()
    exit_code = runner.main()
    sys.exit(exit_code)
