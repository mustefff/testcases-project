import json
import logging
from typing import Any, Dict, List, Optional, Union
from datetime import datetime
import pymongo
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, OperationFailure, DuplicateKeyError
from bson import ObjectId
from bson.errors import InvalidId
from robot.api import logger
from robot.api.deco import keyword, library


@library(scope='GLOBAL', version='1.0.0')
class CustomMongoDBLibrary:
    """
    Custom MongoDB Library for Robot Framework using pymongo.

    This library provides keywords for MongoDB operations including:
    - Connection management
    - CRUD operations
    - Data validation
    - Error handling
    """

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '1.0.0'

    def __init__(self):
        self._client: Optional[MongoClient] = None
        self._db = None
        self._uri = None
        self._database_name = None

    @keyword("Connect To MongoDB")
    def connect_to_mongodb(self, uri: str, port: int = 27017, timeout: int = 30000,
                          tls: Optional[str] = None) -> None:
        """
        Connects to MongoDB server.

        Args:
            uri: MongoDB connection URI
            port: MongoDB port (default: 27017)
            timeout: Connection timeout in milliseconds
            tls: TLS/SSL configuration (optional)

        Examples:
            | Connect To MongoDB | mongodb://localhost:27017 |
            | Connect To MongoDB | mongodb+srv://user:pass@cluster.mongodb.net/ |
        """
        try:
            # Parse the URI to extract database name if present
            if '/' in uri and not uri.endswith('/'):
                parts = uri.rsplit('/', 1)
                if len(parts) > 1 and parts[1]:
                    self._database_name = parts[1].split('?')[0]

            # Create connection with timeout settings
            self._client = MongoClient(
                uri,
                serverSelectionTimeoutMS=timeout,
                connectTimeoutMS=timeout,
                socketTimeoutMS=timeout
            )

            # Test connection
            self._client.admin.command('ping')
            self._uri = uri

            logger.info(f"Successfully connected to MongoDB at {uri}")

        except ConnectionFailure as e:
            raise ConnectionFailure(f"Failed to connect to MongoDB: {str(e)}")
        except Exception as e:
            raise Exception(f"Error connecting to MongoDB: {str(e)}")

    @keyword("Disconnect From MongoDB")
    def disconnect_from_mongodb(self) -> None:
        """
        Disconnects from MongoDB server.

        Examples:
            | Disconnect From MongoDB |
        """
        if self._client:
            self._client.close()
            self._client = None
            self._db = None
            logger.info("Disconnected from MongoDB")
        else:
            logger.warn("No active MongoDB connection to close")

    @keyword("Get MongoDB Database")
    def get_mongodb_database(self, database_name: str):
        """
        Gets a MongoDB database instance.

        Args:
            database_name: Name of the database

        Returns:
            Database instance
        """
        self._ensure_connection()
        self._db = self._client[database_name]
        self._database_name = database_name
        return self._db

    @keyword("Get MongoDB Collection Count")
    def get_mongodb_collection_count(self, database_name: str, collection_name: str) -> int:
        """
        Gets the document count in a collection.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection

        Returns:
            Number of documents in the collection
        """
        self._ensure_connection()
        db = self._client[database_name]
        collection = db[collection_name]
        count = collection.count_documents({})
        logger.info(f"Collection {collection_name} has {count} documents")
        return count

    @keyword("Save MongoDB Records")
    def save_mongodb_records(self, database_name: str, collection_name: str,
                           records: Union[str, Dict, List[Dict]]) -> Union[str, List[str]]:
        """
        Inserts one or more records into a MongoDB collection.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection
            records: JSON string or dictionary/list of records to insert

        Returns:
            Inserted document ID(s)
        """
        self._ensure_connection()
        db = self._client[database_name]
        collection = db[collection_name]

        # Parse records if string
        if isinstance(records, str):
            try:
                records = json.loads(records)
            except json.JSONDecodeError as e:
                raise ValueError(f"Invalid JSON: {str(e)}")

        try:
            # Handle single document
            if isinstance(records, dict):
                # Convert _id to ObjectId if it's a valid ObjectId string
                if '_id' in records and isinstance(records['_id'], str):
                    try:
                        # Only convert if it looks like an ObjectId
                        if len(records['_id']) == 24 and all(c in '0123456789abcdef' for c in records['_id'].lower()):
                            records['_id'] = ObjectId(records['_id'])
                    except:
                        # Keep as string if conversion fails
                        pass

                result = collection.insert_one(records)
                return str(result.inserted_id)

            # Handle multiple documents
            elif isinstance(records, list):
                # Convert _id fields to ObjectId where applicable
                for record in records:
                    if '_id' in record and isinstance(record['_id'], str):
                        try:
                            if len(record['_id']) == 24 and all(c in '0123456789abcdef' for c in record['_id'].lower()):
                                record['_id'] = ObjectId(record['_id'])
                        except:
                            pass

                result = collection.insert_many(records)
                return [str(id) for id in result.inserted_ids]

        except DuplicateKeyError as e:
            raise DuplicateKeyError(f"Duplicate key error: {str(e)}")
        except Exception as e:
            raise Exception(f"Error saving records: {str(e)}")

    @keyword("Retrieve All MongoDB Records")
    def retrieve_all_mongodb_records(self, database_name: str, collection_name: str,
                                   return_as_list: bool = True) -> Union[List[Dict], str]:
        """
        Retrieves all records from a MongoDB collection.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection
            return_as_list: If True, returns list; if False, returns JSON string

        Returns:
            All documents in the collection
        """
        self._ensure_connection()
        db = self._client[database_name]
        collection = db[collection_name]

        try:
            cursor = collection.find({})
            documents = list(cursor)

            # Convert ObjectId to string
            for doc in documents:
                self._convert_objectid_to_string(doc)

            if return_as_list:
                return documents
            else:
                return json.dumps(documents, default=str)

        except Exception as e:
            raise Exception(f"Error retrieving records: {str(e)}")

    @keyword("Retrieve Some MongoDB Records")
    def retrieve_some_mongodb_records(self, database_name: str, collection_name: str,
                                    filter_query: Union[str, Dict],
                                    return_as_list: bool = True,
                                    projection: Optional[Union[str, Dict]] = None,
                                    limit: int = 0) -> Union[List[Dict], str]:
        """
        Retrieves records matching a filter from a MongoDB collection.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection
            filter_query: JSON string or dictionary filter query
            return_as_list: If True, returns list; if False, returns JSON string
            projection: Fields to include/exclude (optional)
            limit: Maximum number of documents to return (0 = no limit)

        Returns:
            Documents matching the filter
        """
        self._ensure_connection()
        db = self._client[database_name]
        collection = db[collection_name]

        # Parse filter if string
        if isinstance(filter_query, str):
            try:
                filter_query = json.loads(filter_query)
            except json.JSONDecodeError as e:
                raise ValueError(f"Invalid filter JSON: {str(e)}")

        # Parse projection if string
        if projection and isinstance(projection, str):
            try:
                projection = json.loads(projection)
            except json.JSONDecodeError as e:
                raise ValueError(f"Invalid projection JSON: {str(e)}")

        # Convert _id in filter to appropriate type
        if '_id' in filter_query:
            filter_query['_id'] = self._convert_id_value(filter_query['_id'])

        try:
            cursor = collection.find(filter_query, projection)
            if limit > 0:
                cursor = cursor.limit(limit)

            documents = list(cursor)

            # Convert ObjectId to string
            for doc in documents:
                self._convert_objectid_to_string(doc)

            if return_as_list:
                return documents
            else:
                return json.dumps(documents, default=str)

        except Exception as e:
            raise Exception(f"Error retrieving records: {str(e)}")

    @keyword("Retrieve And Update One MongoDB Record")
    def retrieve_and_update_one_mongodb_record(self, database_name: str, collection_name: str,
                                             filter_query: Union[str, Dict],
                                             update_query: Union[str, Dict],
                                             return_document: bool = False) -> Optional[Dict]:
        """
        Updates a single document matching the filter.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection
            filter_query: JSON string or dictionary filter query
            update_query: JSON string or dictionary update query
            return_document: If True, returns the updated document

        Returns:
            Updated document if return_document is True, else update result
        """
        self._ensure_connection()
        db = self._client[database_name]
        collection = db[collection_name]

        # Parse queries if strings
        if isinstance(filter_query, str):
            filter_query = json.loads(filter_query)
        if isinstance(update_query, str):
            update_query = json.loads(update_query)

        # Convert _id in filter
        if '_id' in filter_query:
            filter_query['_id'] = self._convert_id_value(filter_query['_id'])

        try:
            if return_document:
                # Use find_one_and_update to get the document
                result = collection.find_one_and_update(
                    filter_query,
                    update_query,
                    return_document=pymongo.ReturnDocument.AFTER
                )
                if result:
                    self._convert_objectid_to_string(result)
                return result
            else:
                # Use update_one for simple update
                result = collection.update_one(filter_query, update_query)
                return {
                    'matched_count': result.matched_count,
                    'modified_count': result.modified_count,
                    'acknowledged': result.acknowledged
                }

        except Exception as e:
            raise Exception(f"Error updating record: {str(e)}")

    @keyword("Update Many MongoDB Records")
    def update_many_mongodb_records(self, database_name: str, collection_name: str,
                                  filter_query: Union[str, Dict],
                                  update_query: Union[str, Dict]) -> Dict:
        """
        Updates multiple documents matching the filter.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection
            filter_query: JSON string or dictionary filter query
            update_query: JSON string or dictionary update query

        Returns:
            Update result with matched and modified counts
        """
        self._ensure_connection()
        db = self._client[database_name]
        collection = db[collection_name]

        # Parse queries if strings
        if isinstance(filter_query, str):
            filter_query = json.loads(filter_query)
        if isinstance(update_query, str):
            update_query = json.loads(update_query)

        try:
            result = collection.update_many(filter_query, update_query)
            return {
                'matched_count': result.matched_count,
                'modified_count': result.modified_count,
                'acknowledged': result.acknowledged
            }
        except Exception as e:
            raise Exception(f"Error updating records: {str(e)}")

    @keyword("Remove MongoDB Records")
    def remove_mongodb_records(self, database_name: str, collection_name: str,
                             filter_query: Union[str, Dict]) -> Dict:
        """
        Removes documents matching the filter from a MongoDB collection.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection
            filter_query: JSON string or dictionary filter query

        Returns:
            Delete result with deleted count
        """
        self._ensure_connection()
        db = self._client[database_name]
        collection = db[collection_name]

        # Parse filter if string
        if isinstance(filter_query, str):
            filter_query = json.loads(filter_query)

        # Convert _id in filter
        if '_id' in filter_query:
            filter_query['_id'] = self._convert_id_value(filter_query['_id'])

        try:
            result = collection.delete_many(filter_query)
            return {
                'deleted_count': result.deleted_count,
                'acknowledged': result.acknowledged
            }
        except Exception as e:
            raise Exception(f"Error removing records: {str(e)}")

    @keyword("Drop MongoDB Collection")
    def drop_mongodb_collection(self, database_name: str, collection_name: str) -> None:
        """
        Drops a MongoDB collection.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection to drop
        """
        self._ensure_connection()
        db = self._client[database_name]

        try:
            db.drop_collection(collection_name)
            logger.info(f"Dropped collection: {collection_name}")
        except Exception as e:
            raise Exception(f"Error dropping collection: {str(e)}")

    @keyword("Create MongoDB Index")
    def create_mongodb_index(self, database_name: str, collection_name: str,
                           keys: Union[str, List, Dict], unique: bool = False) -> str:
        """
        Creates an index on a MongoDB collection.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection
            keys: Index keys specification
            unique: Whether the index should be unique

        Returns:
            Name of the created index
        """
        self._ensure_connection()
        db = self._client[database_name]
        collection = db[collection_name]

        # Parse keys if string
        if isinstance(keys, str):
            keys = json.loads(keys)

        try:
            index_name = collection.create_index(keys, unique=unique)
            logger.info(f"Created index: {index_name}")
            return index_name
        except Exception as e:
            raise Exception(f"Error creating index: {str(e)}")

    # Helper methods
    def _ensure_connection(self) -> None:
        """Ensures MongoDB connection is established."""
        if not self._client:
            raise ConnectionFailure("No MongoDB connection established. Use 'Connect To MongoDB' first.")

    def _convert_objectid_to_string(self, document: Dict) -> None:
        """Recursively converts ObjectId instances to strings in a document."""
        for key, value in document.items():
            if isinstance(value, ObjectId):
                document[key] = str(value)
            elif isinstance(value, dict):
                self._convert_objectid_to_string(value)
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, dict):
                        self._convert_objectid_to_string(item)

    def _convert_id_value(self, id_value: Any) -> Any:
        """
        Converts ID value to appropriate type (ObjectId or string).

        Args:
            id_value: The ID value to convert

        Returns:
            Converted ID value
        """
        if isinstance(id_value, str):
            # Check if it's a valid ObjectId format (24 hex characters)
            if len(id_value) == 24 and all(c in '0123456789abcdef' for c in id_value.lower()):
                try:
                    return ObjectId(id_value)
                except InvalidId:
                    # If conversion fails, keep as string
                    pass
        return id_value

    @keyword("Validate ObjectId")
    def validate_objectid(self, object_id: str) -> bool:
        """
        Validates if a string is a valid MongoDB ObjectId.

        Args:
            object_id: String to validate

        Returns:
            True if valid ObjectId, False otherwise
        """
        try:
            ObjectId(object_id)
            return True
        except (InvalidId, TypeError):
            return False

    @keyword("Generate ObjectId")
    def generate_objectid(self) -> str:
        """
        Generates a new MongoDB ObjectId.

        Returns:
            String representation of the generated ObjectId
        """
        return str(ObjectId())

    @keyword("Get Collection Names")
    def get_collection_names(self, database_name: str) -> List[str]:
        """
        Gets list of collection names in a database.

        Args:
            database_name: Name of the database

        Returns:
            List of collection names
        """
        self._ensure_connection()
        db = self._client[database_name]
        return db.list_collection_names()

    @keyword("Collection Exists")
    def collection_exists(self, database_name: str, collection_name: str) -> bool:
        """
        Checks if a collection exists in the database.

        Args:
            database_name: Name of the database
            collection_name: Name of the collection

        Returns:
            True if collection exists, False otherwise
        """
        self._ensure_connection()
        db = self._client[database_name]
        return collection_name in db.list_collection_names()
