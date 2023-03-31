"""This guide helped me a lot: https://medium.com/codervlogger/python-mongodb-tutorial-using-docker-52f330852b4c"""

from pymongo import MongoClient

# Hostname of Mongo instance
mongo_host = "localhost"
# MongoDB port. Default: 27017
mongo_port = "27017"
# Create connection string
connection_string = f"mongodb://{mongo_host}:{mongo_port}/"


# Create MongoClient instance from connection_string
client = MongoClient(connection_string)


def get_db_list(mongo_client):
    """
    Takes a MongoClient connection object,
    returns a list of databases found in Mongo instance.
    """

    # Get list of databases from mongo_client
    databases = mongo_client.list_database_names()

    return databases


def check_db_exists(mongo_client, db):
    """
    Takes a MongoClient connection object,
    queries server for database 'db'.
    """
    _dblist = get_db_list(mongo_client)

    if db in _dblist:
        return True
    else:
        return False


test_db_exists = check_db_exists(client, "test")
# print(test_db_exists)


def create_db(mongo_client, db_name, collection_name, data):
    """
    Takes a MongoClient connection object, open database 'db_name',
    open collection 'collection_name', insert data 'data'.
    """
    db = mongo_client[db_name]
    collection = db[collection_name]

    data_insert = collection.insert_many(data)

    print(f"IDs for inserted data: {data_insert.inserted_ids}")


def search_db(mongo_client, db_name, collection_name):
    """
    Takes a MongoClient connection object, prints data
    in collection_name.
    """
    db = mongo_client[db_name]
    collection = db[collection_name]

    for item in collection.find():
        print(f"Item: {item}")


def create_example_customers_db(mongo_client):
    """
    Create example database 'customersDB', insert customers_list data
    into collection 'customers.' create_db() function prints IDs for created objects.
    """
    customers_list = [
        {"name": "Amy", "address": "Apple st 652"},
        {"name": "Hannah", "address": "Mountain 21"},
        {"name": "Michael", "address": "Valley 345"},
        {"name": "Sandy", "address": "Ocean blvd 2"},
        {"name": "Betty", "address": "Green Grass 1"},
        {"name": "Richard", "address": "Sky st 331"},
        {"name": "Susan", "address": "One way 98"},
        {"name": "Vicky", "address": "Yellow Garden 2"},
        {"name": "Ben", "address": "Park Lane 38"},
        {"name": "William", "address": "Central st 954"},
        {"name": "Chuck", "address": "Main Road 989"},
        {"name": "Viola", "address": "Sideway 1633"},
    ]

    create_db(client, "customersDB", "customers", customers_list)


# create_example_customers_db(client)


def print_example_customers_db(mongo_client):
    """Print data in example customerDB."""

    search_db(client, "customersDB", "customers")


# print_example_customers_db(client)


def insert_one(mongo_client, db_name, collection_name, insert_data):
    db = mongo_client[db_name]
    collection = db[collection_name]

    collection.replace_one(insert_data, insert_data, upsert=True)


new_customer = {"name": "Jack", "address": "123 Mulberry Street"}
new_customer2 = {"name": "Jordan", "address": "246 Gingerbread Way"}
insert_one(client, "customersDB", "customers", new_customer)
insert_one(client, "customersDB", "customers", new_customer2)

print_example_customers_db(client)


def delete_from_db(mongo_client, db_name, collection_name, delete_query):

    db = mongo_client[db_name]
    collection = db[collection_name]

    print(f"Removing data from db: {collection}")

    delete = collection.delete_many(delete_query)

    print(f"Results: {delete.deleted_count}")


delete_from_db(client, "customersDB", "customers", {"name": "Jack"})

print_example_customers_db(client)


def print_index(mongo_client, db_name, collection_name):

    db = mongo_client[db_name]
    collection = db[collection_name]

    index_list = sorted(list(collection.index_information()))

    return index_list


def create_initial_index(mongo_client, db_name, collection_name):

    db = mongo_client[db_name]
    collection = db[collection_name]

    index_list = sorted(list(collection.index_information()))

    return index_list
    # print("Indext created:")
    # print(index_list)


def create_new_index(mongo_client, db_name, collection_name, index_on):

    db = mongo_client[db_name]
    collection = db[collection_name]

    collection.create_index(index_on, unique=True)

    index_list = sorted(list(collection.index_information()))

    return index_list


init_index = create_initial_index(client, "customersDB", "customers")
print(init_index)


name_index = create_new_index(client, "customersDB", "customers", "name")
print(name_index)


def drop_index(mongo_client, db_name, collection_name, index_val):

    index_val = f"{index_val}_1"

    db = mongo_client[db_name]
    collection = db[collection_name]

    print(f"Dropping {index_val} from collection.")

    collection.drop_index(index_val)


drop_name = drop_index(client, "customersDB", "customers", "name")
print(print_index(client, "customersDB", "customers"))
