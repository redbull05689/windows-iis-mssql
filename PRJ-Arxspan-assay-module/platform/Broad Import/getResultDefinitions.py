import os,json,time,re,codecs
from dateutil import parser as dateParser
from pymongo import MongoClient
import datetime

client = MongoClient()
db = client["broadAssay"]
collection = db["assayItems"]

L = []

cursor = collection.find({"_type":"resultDefinition","currentVersion":True,"visible":True})
for row in cursor:
    D = {}
    D["type"] = row["type"]
    D["name"] = row["name"]
    D["dateAdded"] = row["dateAddedInitial"].isoformat()
    E = {}
    E["userName"] = row["userAddedInitial"]["userName"]
    E["id"] = row["userAddedInitial"]["id"]
    D["userAdded"] = E
    D["dateUpdated"] = row["dateAdded"].isoformat()
    E = {}
    E["userName"] = row["userAdded"]["userName"]
    E["id"] = row["userAdded"]["id"]
    D["userUpdated"] = E
    L.append(D)
json.dump(L,open('resultDefinitions.txt','w'))