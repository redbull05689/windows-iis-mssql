import os,json,time,re,codecs
from dateutil import parser as dateParser
from pymongo import MongoClient
import datetime

client = MongoClient()
db = client["broadAssayPlatform"]
collection = db["data"]

cursor = collection.find({"visible":False})
for row in cursor:
	cursor1 = collection.find({"parentId":row["id"]})
	print "children",cursor1.count()
	collection.remove({"parentId":row["id"]})
	cursor2 = collection.find({"parentTree":row["id"]})
	print "decendents",cursor2.count()
	collection.remove({"parentTree":row["id"]})
	collection.remove({"id":row["id"]})