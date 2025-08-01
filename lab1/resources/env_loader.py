import os
from pathlib import Path
from dotenv import load_dotenv


class EnvLoader:
    """
    Library for loading environment variables from .env file in Robot Framework.
    """

    def __init__(self):
        self.env_loaded = False
        self.env_file_path = None

    def load_env_file(self, env_path=None):
        """
        Load environment variables from .env file.

        Args:
            env_path: Path to .env file. If not provided, searches for .env in project root.

        Returns:
            Boolean indicating if the file was loaded successfully
        """
        if env_path:
            env_file = Path(env_path)
        else:
            # Search for .env file in current directory and parent directories
            current_dir = Path(__file__).parent.parent
            env_file = current_dir / '.env'

            if not env_file.exists():
                # Try to find .env in parent directory
                env_file = current_dir.parent / '.env'

        if env_file.exists():
            load_dotenv(env_file, override=True)
            self.env_file_path = str(env_file)
            self.env_loaded = True
            return True
        else:
            self.env_loaded = False
            return False

    def get_env_variable(self, key, default=None):
        """
        Get environment variable value.

        Args:
            key: Environment variable name
            default: Default value if variable is not found

        Returns:
            Environment variable value or default
        """
        return os.getenv(key, default)

    def get_mongodb_uri(self):
        """
        Get MongoDB URI from environment variables.

        Returns:
            MongoDB connection string
        """
        return self.get_env_variable('MONGODB_URI', 'mongodb://localhost:27017/')

    def get_database_name(self):
        """
        Get database name from environment variables.

        Returns:
            Database name
        """
        return self.get_env_variable('DATABASE_NAME', 'fakeStoreDB')

    def get_all_env_variables(self):
        """
        Get all environment variables as dictionary.

        Returns:
            Dictionary of all environment variables
        """
        return dict(os.environ)

    def set_robot_variables(self):
        """
        Set Robot Framework variables from environment variables.

        Returns:
            Dictionary of variables to be used in Robot Framework
        """
        variables = {
            'MONGODB_URI': self.get_mongodb_uri(),
            'DATABASE_NAME': self.get_database_name(),
            'CONNECT_TIMEOUT': self.get_env_variable('CONNECT_TIMEOUT', '30000'),
            'SERVER_SELECTION_TIMEOUT': self.get_env_variable('SERVER_SELECTION_TIMEOUT', '30000'),
            'TEST_ENVIRONMENT': self.get_env_variable('TEST_ENVIRONMENT', 'development'),
            'LOG_LEVEL': self.get_env_variable('LOG_LEVEL', 'INFO'),
            'TEST_USER_PASSWORD': self.get_env_variable('TEST_USER_PASSWORD', 'Test@Password123'),
            'FAKESTORE_API_URL': self.get_env_variable('FAKESTORE_API_URL', 'https://fakestoreapi.com'),
        }
        return variables


# Global instance for Robot Framework
env_loader = EnvLoader()


def get_variables():
    """
    Called by Robot Framework to get variables.
    This function is called when this file is used as a variable file.
    """
    env_loader.load_env_file()
    return env_loader.set_robot_variables()
