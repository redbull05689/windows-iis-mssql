import os,json,time,re,codecs
from dateutil import parser as dateParser
from pymongo import MongoClient
import datetime

client = MongoClient()
db = client["broadAssayPlatform"]
collection = db["sequences"]

cursor = collection.find()
for row in cursor:
	try:
		a = int(row["_id"])
		print "deleting",row["_id"]
		collection.remove({"_id":row["_id"]})		
	except:
		print "not deleting",row["_id"]