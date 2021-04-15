import cherrypy, sys, os, json, time, re, codecs, urllib2, requests, pyodbc, hashlib, simplejson,binascii,base64,math,datetime,random
from pymongo import MongoClient
import urllib2,threading,pickle,urllib
from cherrypy.process import plugins
import xlrd,xlwt,csv
from dateutil import parser as dateParser
from bson import json_util
import pprint

#import from parent folder
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from companyConfigData import getUploadRoot

#file extensions that should be interpreted as csv
csvExtensions = ["csv","tab","txt","tsv"]

pp = pprint.PrettyPrinter(indent=2)

#queue for storing functions and running them later
#queue is a dictionary keyed by the db id and database name
#to avoid collisios
delayedDbFunctions = {}
def delayFunction(func, dbName, dbId, *args, **kwargs):
    if dbName not in delayedDbFunctions.keys():
        #if this is the first function for this dbName
        #create an object
        delayedDbFunctions[dbName] = {}
    if dbId not in delayedDbFunctions[dbName].keys():
        #if there is not already functions for this database id
        #create a list
        delayedDbFunctions[dbName][dbId] = []
    #add function onto function list for this database/database id
    delayedDbFunctions[dbName][dbId].append((func,args,kwargs))

#runs functions for the specified db/dbid pair
def runDelayedFunctions(dbName,dbId):
    if dbName in delayedDbFunctions.keys():
        if dbId in delayedDbFunctions[dbName].keys():
            for item in delayedDbFunctions[dbName][dbId]:
                func, args, kwargs = item
                func(*args, **kwargs)
            
            # After running the delayed functions, delete the ones we just ran
            del delayedDbFunctions[dbName][dbId]

#define add/edit/delete permissions
gPerms = {}
gPerms["root node"] = {}
gPerms["cbip folder"] = {}
gPerms["cbip run"] = {}
gPerms["cbip project"] = {}
gPerms["cbip assay"] = {}
gPerms["cbip protocol"] = {}
gPerms["assay"] = {}
gPerms["protocol"] = {}
gPerms["result"] = {}
gPerms["result definition"] = {}
gPerms["upload template"] = {}
gPerms["assay group"] = {}
gPerms["result set"] = {}
gPerms["recipe"] = {}
gPerms["permission"] = {}
gPerms["folder"] = {}
gPerms["analysis function"] = {}
gPerms["analytical folder"] = {}
gPerms["analytical assay group"] = {}
gPerms["analytical assay"] = {}
gPerms["analytical protocol"] = {}
gPerms["analytical result set"] = {}

gPerms["root node"]["Admin"] = {"add":False,"edit":False,"delete":False}
gPerms["root node"]["Power User"] = {"add":False,"edit":False,"delete":False}
gPerms["root node"]["User"] = {"add":False,"edit":False,"delete":False}
gPerms["cbip folder"]["Admin"] = {"add":False,"edit":True,"delete":True}
gPerms["cbip folder"]["Power User"] = {"add":False,"edit":True,"delete":False}
gPerms["cbip folder"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["cbip run"]["Admin"] = {"add":True,"edit":True,"delete":False}
gPerms["cbip run"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["cbip run"]["User"] = {"add":True,"edit":False,"delete":False}
gPerms["cbip project"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["cbip project"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["cbip project"]["User"] = {"add":False,"edit":False,"delete":False}
gPerms["cbip assay"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["cbip assay"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["cbip assay"]["User"] = {"add":False,"edit":False,"delete":False}
gPerms["cbip protocol"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["cbip protocol"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["cbip protocol"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["assay"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["assay"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["assay"]["User"] = {"add":False,"edit":False,"delete":False}
gPerms["protocol"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["protocol"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["protocol"]["User"] = {"add":True,"edit":False,"delete":False}
gPerms["result"]["Admin"] = {"add":True,"edit":True,"delete":False}
gPerms["result"]["Power User"] = {"add":True,"edit":False,"delete":False}
gPerms["result"]["User"] = {"add":True,"edit":False,"delete":False}
gPerms["result definition"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["result definition"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["result definition"]["User"] = {"add":False,"edit":False,"delete":False}
gPerms["upload template"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["upload template"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["upload template"]["User"] = {"add":False,"edit":False,"delete":False}
gPerms["assay group"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["assay group"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["assay group"]["User"] = {"add":False,"edit":False,"delete":False}
gPerms["result set"]["Admin"] = {"add":True,"edit":True,"delete":True,"update":True}
gPerms["result set"]["Power User"] = {"add":True,"edit":True,"delete":False,"update":True}
gPerms["result set"]["User"] = {"add":True,"edit":True,"delete":False,"update":True}
gPerms["recipe"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["recipe"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["recipe"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["permission"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["permission"]["Power User"] = {"add":False,"edit":False,"delete":False}
gPerms["permission"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["folder"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["folder"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["folder"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["analysis function"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["analysis function"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["analysis function"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["analytical folder"]["Admin"] = {"add":False,"edit":True,"delete":True}
gPerms["analytical folder"]["Power User"] = {"add":False,"edit":True,"delete":False}
gPerms["analytical folder"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["analytical assay group"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["analytical assay group"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["analytical assay group"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["analytical assay"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["analytical assay"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["analytical assay"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["analytical protocol"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["analytical protocol"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["analytical protocol"]["User"] = {"add":False,"edit":False,"delete":False}

gPerms["analytical result set"]["Admin"] = {"add":True,"edit":True,"delete":True}
gPerms["analytical result set"]["Power User"] = {"add":True,"edit":True,"delete":False}
gPerms["analytical result set"]["User"] = {"add":True,"edit":True,"delete":False}

def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""
    if isinstance(obj, datetime.datetime):
        serial = obj.isoformat()
        return serial
    raise TypeError ("Type not serializable")

server = "dev"
server = sys.argv[1]
server = server.upper()
if server.upper() == "DEV":
    client = MongoClient()
    regPath = "https://stage.arxspan.com/arxlab/registration/"
    elnServicesPath = "https://stage.arxspan.com/arxlab/services/"
    def getconnectedadm(whichClient):
        return pyodbc.connect(r"DRIVER={SQL Server};SERVER=10.10.10.192\DEV;DATABASE=ARXSPAN-DEV;UID=elnAdmin;PWD=eln##adm$17$",autocommit=True)
if server.upper() == "BETA":
    client = MongoClient()
    regPath = "https://beta.arxspan.com/arxlab/registration/"
    elnServicesPath = "https://beta.arxspan.com/arxlab/services/"
    def getconnectedadm(whichClient):
        return pyodbc.connect(r"DRIVER={SQL Server};SERVER=10.10.10.192\BETA;DATABASE=ARXSPAN-BETA;UID=elnAdmin;PWD=eln##adm$17$",autocommit=True)
if server.upper() == "MODEL":
    client = MongoClient()
    regPath = "https://model.arxspan.com/arxlab/registration/"
    elnServicesPath = "https://model.arxspan.com/arxlab/services/"
    def getconnectedadm(whichClient):
        return pyodbc.connect(r"DRIVER={SQL Server};SERVER=10.10.10.192\MODEL;DATABASE=ARXSPAN-MODEL;UID=elnAdmin;PWD=eln##adm$17$",autocommit=True)
if server.upper() == "PROD":
    client = MongoClient('10.10.10.24', 27017)
    regPath = "https://eln.arxspan.com/arxlab/registration/"
    elnServicesPath = "https://eln.arxspan.com/arxlab/services/"
    def getconnectedadm(whichClient):
        if whichClient == "BROAD":
            return pyodbc.connect(r"DRIVER={SQL Server};SERVER=10.10.10.193;DATABASE=ARXSPAN-PROD-BROAD;UID=elnAdmin;PWD=eln##adm$17$",autocommit=True)
        else:
            return pyodbc.connect(r"DRIVER={SQL Server};SERVER=10.10.10.193;DATABASE=ARXSPAN-PROD;UID=elnAdmin;PWD=eln##adm$17$",autocommit=True)

#thread to close cursors that have not received a ping
#in 60 seconds
class CursorCloser(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self._stop = threading.Event()
        
    def run(self):
        while not self._stop.isSet():
            time.sleep(5)
            cursorIds = [x for x in Cursors]
            for cursorId in cursorIds:
                if time.time() - CursorPings[cursorId] >= 60:
                    print "Removing expired cursor id:",cursorId
                    Cursors[cursorId]["cursor"].close()
                    del Cursors[cursorId]["cursor"]
                    del Cursors[cursorId]
                    del CursorPings[cursorId]

    def stop(self):
        self._stop.set()

#get the name the of the object
def getObjName(self):
    return self.title

#make a rest call.  Mainly used for calling Jchem Web Services
def restCall(url,verb="GET",data="",contentType="application/json"):
    #if Python object stringify to JSON
    if type(data) == type({}):
        data = json.dumps(data)
    #default to JSON
    if contentType == "":
        contentType = "application/json"
    #make request
    req = urllib2.Request(url)
    req.get_method = lambda: verb
    if verb in ["PUT","POST"]:
        req.add_header('Content-type', contentType)
        req.add_header("Content-length", "%d" % len(data))
        req.add_data(data)
    try:
        x = urllib2.urlopen(req).read()
        return x
    except urllib2.HTTPError, error:
        print error.read()

#holds 'session' data associated with connectionIds
connections = {}

counter = 0

#get user 'session' data by connectionId
def getUserInfo(connectionId):
    defaultUser = {}
    defaultUser["loggedIn"] = False
    if connectionId:
        if connectionId in connections.keys():
            D = connections[connectionId]
            return D
        else:
            print "connection not cached, reload"
            return loadConnection(connectionId,None,True)

    return defaultUser

#get the next number in a sequence by db and name
#sequences are stored in a collection called sequences
def getNextSequence(db,name):
    if db.sequences.find({"_id":name}).count() == 0:
        db.sequences.insert({"_id":name,"seq":1})
    return db["sequences"].find_and_modify(query={"_id":name},update= { "$inc": { "seq": 1 } },upsert=True)["seq"]

#end point wrapper to expose getNextSequence
class NextSequence():
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            return json.dumps({"seq":getNextSequence(db,str(D["seq"]))})
    index.exposed = True

#gets the next global id will return an incremental unique id
#to give ids to any object
class GetNextId:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            if db.sequences.find({"_id":"globalId"}).count() == 0:
                db.sequences.insert({"_id":"globalId","seq":100})
            return json.dumps({"id":db["sequences"].find_and_modify(query={"_id":"globalId"},update= { "$inc": { "seq": 1 } },upsert=True)["seq"]})
    index.exposed = True


connections = {}

def loadConnection(connectionId, D, loadFromDisk=False):
    cacheFileName = "session_cache/"+"ASY_"+connectionId+".txt"
	
    print "loading connection information for servicesConnectionId: ",connectionId, " loadFromDisk: ",loadFromDisk

    if loadFromDisk:
        print "doing the pickle load"
        with open(cacheFileName,"rb") as handle:
            D = pickle.loads(handle.read())
        print "D loaded from disk: ", D
        os.remove(cacheFileName)
    else:
        # cache info to disk
        with open(cacheFileName,"wb") as handle:
            pickle.dump(D,handle)

    userId = D["userId"]
    whichClient = D["whichClient"]

    ConnAdm = getconnectedadm(whichClient)
    cursor = ConnAdm.cursor()
    #make sure user is connected in ASP
    strQuery = "SELECT * FROM usersView WHERE id="+str(int(userId))+" AND servicesConnectionId='"+connectionId.replace("'","''")+"'"
    rows = cursor.execute(strQuery).fetchall()

    if len(rows) == 1:
        row = rows[0]
        #only assay users
        if row.hasAssay == 1 and row.assayRoleName in ["Admin","User","Power User"]:
            C = {}
            canAdd = True
            canEdit = True
            canMove = True
            canDelete = True
            C["whichClient"] = whichClient
            C["sendToSeurat"] = False
            #create list of users
            C["userList"] = []
            C["userList2"] = []

            usersICanSeeSql = "0"
            if D.has_key("usersICanSee") and D["usersICanSee"] not in "-1":
                usersICanSeeSql = json.dumps(D["usersICanSee"])
                usersICanSeeSql = usersICanSeeSql[1:-1]

            strQuery = "SELECT * FROM usersView WHERE companyId="+str(int(row.companyId))+" and (id in (" + usersICanSeeSql + ") or id="+str(row.id)+") ORDER BY fullName"
            rows2 = cursor.execute(strQuery).fetchall()
            for row2 in rows2:
                C["userList"].append(row2.fullName)
                C["userList2"].append([row2.id,row2.fullName])
            #set perms by role
            if row.assayRoleName != "Admin":
                canMove = False
            if row.assayRoleName not in ("Admin","Power User"):
                canAdd = False
                canEdit = False
            C["canAdd"] = canAdd
            C["canEdit"] = canEdit
            C["canMove"] = canMove
            C["canDelete"] = canDelete
            C["loggedIn"] = True
            C["roleName"] = row.assayRoleName
            #misc settings
            C["imageOnResultSet"] = False
            C["sendToSeurat"] = False
            C["appendResults"] = False
            C["resultSetOnProtocol"] = False
            C["broadCBIP"] = False

            #FT Settings
            C["sendToSearchTool"] = False
            C["hasFTLite"] = False
            C["hasFT"] = False
            C["FTDB"] = ""
            C["FTDBLite"] = ""
            if row.companyHasFTLiteAssay == 1:
                C["sendToSearchTool"]=True
                C["FTDBLite"] = row.FTDBLiteAssay
                C["hasFTLite"] = True
            if row.companyHasFT == 1:
                C["sendToSearchTool"]=True
                C["FTDB"] = row.FTDB
                C["hasFT"] = True
            #get mapping data and db data from file
            companyMapping = json.load(open('companyMapping.json'))
            oo = companyMapping[server][str(row.companyId)]
            C["database"] = oo["database"]
            C["rootTypeId"] = oo["rootTypeId"]
            C["selectListTypeId"] = oo["selectListTypeId"]
            C["resultTypeId"] = oo["resultTypeId"]
            C["resultSetTypeId"] = oo["resultSetTypeId"]

            #default search security used for all queries.  Makes sure a user can only
            #see things that have note been deleted
            C["searchSecurity"] = {'$or':[{"visible":True},{"visible":{"$exists":False}}]}

            #user settings
            C["companyId"] = row.companyId
            C["email"] = row.email
            C["userName"] = row.fullName
            C["id"] = row.id

            #make FT perms
            C["ftPerms"] = {}
            if row.assayRoleName not in ["Admin"]:
                #only non-admins are subjected to permisions
                myGroups = []
                itemsICantSee = []
                ConnAdm2 = getconnectedadm(whichClient)
                cursor2 = ConnAdm2.cursor()
                #get the groups I am a part of
                strQuery = "SELECT * FROM groupMembers WHERE userId="+str(int(userId))
                groups = cursor2.execute(strQuery).fetchall()
                for group in groups:
                    myGroups.append(group.groupId)
                db = client[C["database"]]
                collection = db["data"]
                #get all perm objects
                for item in collection.find({"name":"Permission","visible":True}):
                    #assume that I cannot see the perm object
                    canSee = False
                    item = traverse2(item,C)
                    val = item.getFieldByName("permissions")["value"]
                    #if the perm object contains my user id or the id of a group
                    #that I belong to say I can see it
                    if isinstance(val,dict):
                        if "groupIds" in val.keys():
                            for groupId in val["groupIds"]:
                                if groupId in myGroups:
                                    canSee = True
                                    break
                        if "userIds" in val.keys():
                            if int(userId) in val["userIds"]:
                                canSee = True
                    if not canSee:
                        itemsICantSee.append(item["id"])
                #create ft perms that do not allow me to see the perm objects
                #i am not allowed to see nor any of their children
                if len(itemsICantSee)>0:
                    D = {"$nin":itemsICantSee}
                    C["searchSecurity"]["parentTree"] = D
                    C["searchSecurity"]["id"] = D
                    C["ftPerms"]["parentTreeAssay"] = D
                    C["ftPerms"]["idAssay"] = D
                    print "bbb",C["searchSecurity"]
            #end invPerm
                                  
            connections[connectionId] = C
            
            if loadFromDisk:
                return C

            return json.dumps({"inventoryStructuresTable":"null","sendToSeurat":False,"hasStartRun":True,"resultTypeId":C["resultTypeId"],"resultSetTypeId":C["resultSetTypeId"]})

#gets session data for a user and stores session data in the connections object
class ElnConnection:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        return loadConnection(D["connectionId"],D)
    index.exposed = True
    
Cursors = {}
CursorPings = {}

#save a form
def saveFormF(D,userInfo):
    db = client[userInfo["database"]]
    collection = db["data"]
    doIt = True
    cursor = collection.find({"id":D["form"]["id"]})
    if cursor.count()>0:
        #editing
        form = cursor[0]
        form = traverse2(form,userInfo)
        #make sure we have permission to edit
        if "name" in form.keys():
            if form["name"].lower() in gPerms.keys():
                doIt = gPerms[form["name"].lower()][userInfo["roleName"]]["edit"]
        #set date and user updated
        D["form"]["dateUpdated"] = datetime.datetime.now().isoformat()
        D["form"]["userUpdated"] = {"id":userInfo["id"],"userName":userInfo["userName"]}
    else:
        #adding
        if "typeId" in D["form"].keys():
            #make sure we have permission to add this type
            cursor = collection.find({"id":D["form"]["typeId"]})
            if cursor.count()>0:
                row = traverse2(cursor[0],userInfo)
                theName = row.getFieldByName("name")["value"].lower()
                if theName in gPerms.keys():
                    doIt = gPerms[theName][userInfo["roleName"]]["add"]
        #add user added date and time
        if "dateAdded" not in D["form"].keys():
            D["form"]["dateAdded"] = datetime.datetime.now().isoformat()
            D["form"]["userAdded"] = {"id":userInfo["id"],"userName":userInfo["userName"]}
    #if the form does not have a parent, the parent has not been saved yet.
    #we will wait until the parent is saved and for now we will put ourselves in the
    #delayed function list
    if "parentId" in D["form"].keys():
        theParent = collection.find({"id":D["form"]["parentId"]})
        if theParent.count()==0:
            doIt = False
            delayFunction(saveFormF,userInfo["database"],D["form"]["parentId"],D,userInfo)
            
    if doIt:
        collection.remove({"id":D["form"]["id"]})
        try:
            #create parent tree by using the parent's parent tree then
            #appending the parent's id
            if "parentId" in D["form"].keys():
                x = theParent[0]
                if "parentTree" in x.keys():
                    D["form"]["parentTree"] = x["parentTree"]
                else:
                    D["form"]["parentTree"] = []
                D["form"]["parentTree"].append(D["form"]["parentId"])
        except:
            pass
           
        collection.insert(D["form"])
        #try running delayed functions
        #they will go back into delayed functions until their parent is saved
        runDelayedFunctions(userInfo["database"],D["form"]["id"])
        skip = True
        try:
            if "parentId" in D["form"].keys():
                skip = False
                try:
                    #don't send permission objects to FT
                    if D["form"]["name"].lower() == "permission":
                        skip = True
                except:
                    pass
        except:
            pass
        if not skip:
            #send form to FT
            sendToSearchTool(traverse2(collection.find({"id":D["form"]["id"]})[0],userInfo))
    else:
        print "denied save"

#end point wrapper for saveFormF
class SaveForm:
    def index(self):
        #needs user info for search security
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            saveFormF(D,userInfo)
    index.exposed = True

#deletes a form by setting visible flag to false
class DeleteForm:
    def index(self):
        #needs user info for search security
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]

            doIt = True
            #get form and make sure we have permission to delete that object tyoe
            form = traverse2(collection.find({"id":D["id"]})[0],userInfo)
            if form["name"].lower() in gPerms.keys():
                doIt = gPerms[form["name"].lower()][userInfo["roleName"]]["delete"]
            if doIt:
                #set visible flag
                collection.update({"id":D["id"]},{"$set":{"visible":False}})
                #send a delete to FT

                # get all forms whose parent id is the current id
                self.disposeChildren(int(D["id"]), userInfo, form, collection)

                searchToolDispose(D["id"],form)
            else:
                print "denied"

    def disposeChildren(self, parentId, userInfo, form, collection):
        query = makeSearch({"parentId": int(parentId)}, userInfo)
        rows = collection.find(query)
        for row in rows:
            self.disposeChildren(row['id'], userInfo, form, collection)
            searchToolDispose(row['id'], form)


    index.exposed = True


class DeleteResult:
    def index(self):
        """
        function to make POST calls. Deletes a result set by setting visible flag to false

        a copy of original form delete function, to be used with result set update
        """

        #needs user info for search security
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]

            doIt = False
            #get form and make sure we have permission to update that object tyoe
            form = traverse2(collection.find({"id":D["id"]})[0],userInfo)

            doIt = gPerms["result set"][userInfo["roleName"]]["update"]

            if doIt:
                #set visible flag
                collection.update({"id":D["id"]},{"$set":{"visible":False}})
                #send a delete to FT

                # get all forms whose parent id is the current id
                self.disposeChildren(int(D["id"]), userInfo, form, collection)

                searchToolDispose(D["id"],form)
            else:
                print "denied"

    def disposeChildren(self, parentId, userInfo, form, collection):
        """
        function to dispose all result set childern if any

        Parameters
        ----------
        parentId : int
            Id of the resultset
        userInfo : object
            user 'session' data
        form
        collection
            ref to a mongo documents collection

        """

        query = makeSearch({"parentId": int(parentId)}, userInfo)
        rows = collection.find(query)
        for row in rows:
            self.disposeChildren(row['id'], userInfo, form, collection)
            searchToolDispose(row['id'], form)


    index.exposed = True

def searchToolDispose(theId,form):
    #generate delete file for FT inbox
    print "searchToolDispose() ID: " + str(theId)
    
    # get the database name
    dbName = form.userInfo["FTDB"]
    if form.userInfo["hasFTLite"] and form.userInfo["FTDB"] != form.userInfo["FTDBLite"]:
        form.userInfo["FTDBLite"]

    #create the data to go in the JSON file
    data = {}
    data["config"] = {}
    data["config"]["dbName"] = dbName
    data["config"]["updateFieldName"] = "Assay Id"
    data["config"]["updateFieldValue"] = theId
    data["config"]["dateFields"] = []
    data["config"]["action"] = "delete"
    data["data"] = {}
    data["data"]["_recordType"] = "assay"

    filePath = "c:/INBOX-FT/delete_"+str(form.id)+"-"+randString(8)+"_"+dbName+".json"
    print str(filePath)
    file = open(filePath,"w")	    
    file.write(json.dumps(data))
    file.close()

#load a form/get form data
class LoadForm:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            #return blank if form doesn't exist or we can't access it
            try:
                query = makeSearch({"id":int(D["id"])},userInfo)
                form = collection.find(query)[0]
            except:
                form = {}
            #get rid of ugly Mongo id
            if "_id" in form.keys():
                del form["_id"]

            #set permissions on form based on object type and global permissions
            if "name" in form.keys():
                if form["name"].lower() in gPerms.keys():
                    form["canEdit"] = gPerms[form["name"].lower()][userInfo["roleName"]]["edit"]
                    form["canDelete2"] = gPerms[form["name"].lower()][userInfo["roleName"]]["delete"]
                
            return json_util.dumps({"form":form})
    index.exposed = True

#load forms/ get data for forms.  Returned as array of forms
class LoadForms:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            #get forms or return blank if they do not exist or we cannot access them
            try:
                query = makeSearch({"id":{"$in":[int(x) for x in D["ids"]]}},userInfo)
                forms = list(collection.find(query))
            except:
                forms = []
            for form in forms:
                #get rid of ugly mongo id
                if "_id" in form.keys():
                    del form["_id"]

                #set form permissions by object type and global security permissions
                if "name" in form.keys():
                    if form["name"].lower() in gPerms.keys():
                        form["canEdit"] = gPerms[form["name"].lower()][userInfo["roleName"]]["edit"]
                        form["canDelete2"] = gPerms[form["name"].lower()][userInfo["roleName"]]["delete"]
            return json_util.dumps({"forms":forms})
    index.exposed = True

#returns an array of dunder objects (as forms)
class LoadDunders:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            query = makeSearch({"id":{"$in":D["ids"]}},userInfo)
            cursor = collection.find(query)
            L = []
            for row in cursor:
                L.append(row)
            return json_util.dumps(L)
    index.exposed = True

#get the parent tree of a form
class GetParentTree:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            #start parent tree from the id of the object
            #we are going to make a backwards parentTree (bottom to top)
            parentTree = [D["id"]]
            try:
                #keep getting form parents until we reach route level
                theId = D["id"]
                while theId:
                    query = makeSearch({"id":int(theId)},userInfo)
                    form = collection.find(query)[0]
                    if "parentId" in form.keys():
                        parentTree.append(form["parentId"])
                        theId = form["parentId"]
                    else:
                        theId = False
            except:
                pass
            #make parent tree top to bottom
            parentTree.reverse()
            return json_util.dumps({"parentTree":parentTree})
    index.exposed = True

#return an array of the first level children by form id
class GetChildIds:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            theId = D["id"]
            L = []
            #get all forms whose parent id is the current id
            query = makeSearch({"parentId":int(theId)},userInfo)
            rows = collection.find(query)
            for row in rows:
                L.append(row["id"])
            return json_util.dumps({"childIds":L})
    index.exposed = True

#returns an array of objects matching the passed in type ids of the form
#[itemId,name] for making select lists that have all the items of a type in them
#e.g. result definition, recipe, analysis function
class SelectOfType:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            if D["typeIds"] == [1]:
                cursor = collection.find({"typeId":{"$in":D["typeIds"]}})
            else:
                query = makeSearch({"typeId":{"$in":D["typeIds"]}},userInfo)
                cursor = collection.find(query)
            ops = []
            for item in cursor:
                fieldName = "unnamed"
                for field in item["fields"]:
                    if "name" in field.keys():
                        if field["name"].lower() == "name":
                            fieldName = field["value"]
                ops.append([item["id"],fieldName])
            return json.dumps({"ops":ops})
    index.exposed = True

#enpoint wrapper for returning user list
class GetUserList:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            return json.dumps(userInfo["userList"])
    index.exposed = True

#enpoint wrapper for returning user list
class GetUserList2:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            return json.dumps(userInfo["userList2"])
    index.exposed = True

#determine if excel field has endSpecial
def hasEndSpecial(field):
    if "__pExcelOptions" in field.keys():
        if "endSpecial" in field["__pExcelOptions"]:
            return field["__pExcelOptions"]["endSpecial"]
    return False

#determine if excel field has startSpecial
def hasStartSpecial(field):
    if "__pExcelOptions" in field.keys():
        if "startSpecial" in field["__pExcelOptions"]:
            return field["__pExcelOptions"]["startSpecial"]
    return False

#determine if excel field has otherFile
#other file means that the field should look in a different file
#for its value
def hasOtherFile(field):
    if "__pExcelOptions" in field.keys():
        if "otherFile" in field["__pExcelOptions"]:
            return field["__pExcelOptions"]["otherFile"]
    return False

#determine if excel field has repeatFixed (zig-zag)
def hasRepeatFixed(field):
    if "__pExcelOptions" in field.keys():
        if "repeatFixed" in field["__pExcelOptions"]:
            return field["__pExcelOptions"]["repeatFixed"]
    return False

import os,re
import csv
import xlwt
import StringIO
import chardet
import codecs
import unicodedata

cd = os.getcwd()

def unicode_csv_reader(unicode_csv_data, dialect=csv.excel, **kwargs):
    """
    The csv module doesn't directly support reading and writing Unicode,
    this is a generator that wraps csv.reader to handle Unicode CSV data
    (a list of Unicode strings).\

    :param unicode_csv_data: list of unicode strings
    :param dialect: csv.py dialect, passed to csv.reader
    :param kwargs: passed to csv.reader
    :yields: unicode cells from the CSV
    """
    # csv.py doesn't do Unicode; encode temporarily as UTF-8:
    csv_reader = csv.reader(utf_8_encoder(unicode_csv_data),
                            dialect=dialect, **kwargs)
    for row in csv_reader:
        # decode UTF-8 back to Unicode, cell by cell:
        yield [unicode(cell, 'utf-8') for cell in row]

def utf_8_encoder(unicode_csv_data):
    """
    utf_8_encoder() is a generator that encodes the Unicode strings as UTF-8,
    one string (or row) at a time. The encoded strings are parsed by the CSV reader,
    and unicode_csv_reader() decodes the UTF-8-encoded cells back into Unicode

    :param unicode_csv_data: list of unicode strings
    :yields: UFT8 encoded strings
    """
    for line in unicode_csv_data:
        yield line.encode('utf-8')

# load csv/tsv data from file
def getCSVData(filepath):
    bestGuessEncoding = chardet.detect(open(filepath, "rb").read())
    csvfile = codecs.open(filepath, 'r', encoding=bestGuessEncoding['encoding']).readlines()

    # f = open(filepath, 'r')
    # csvfile = f.readlines()
    # f.close()

    # workaround for csv.py _guess_delimiter this may not always work
    # the consistency in that function may have to be reduced
    # there are a lot of non record data at the tops of these files.  The Python csv reader likes to see the separator consistent in all lines
    # not just the lines it appears in.

    #instead of trying to find delimiter, try both possible options and pick the one with more columns

    delimiters = [",", "\t"]

    # use comma dialect
    dialectComma = csv.Sniffer().sniff("\n".join(","), delimiters="".join(delimiters))
    workbookComma = prepareWorkbook(csvfile, dialectComma)

    # use tab dialect
    dialectTab = csv.Sniffer().sniff("\n".join("\t"), delimiters="".join(delimiters))    
    workbookTab = prepareWorkbook(csvfile, dialectTab)

    f = StringIO.StringIO()

    # use the file with superior number of columns
    if workbookComma["cols"] > workbookTab["cols"]:
        workbookComma["wb"].save(f)
    else:
        workbookTab["wb"].save(f)
    return f


def cleanFile(csvfile, dialect):
    cleanedFile = []
    for line in csvfile:
        # e.g. 1:  2:  3: to 1,2,3
        if re.match("^[\s]*(?:\d+:\s+)+(?:\d+[:\s]*)$", line):
            line = dialect.delimiter + re.sub(":\s+", dialect.delimiter, line)
            line = line.replace(dialect.delimiter * 2, dialect.delimiter)
        # insert delimiter for lines that prepend the first data row with a letter e.g. A:2321,23423,2343,3432 to A,2323,23,324
        cleanedFile.append(re.sub("^([A-Z]):\s+", "\\1" + dialect.delimiter, line))
    return cleanedFile;


def prepareWorkbook(csvfile, dialect):
    cleanedFile = cleanFile(csvfile, dialect)
    # read delimited file
    reader = unicode_csv_reader(cleanedFile, dialect=dialect, delimiter=dialect.delimiter)
    workbook = xlwt.Workbook(encoding='utf-8')
    worksheet = workbook.add_sheet('xlwt_default')
    jcount = 0
    for i, row in enumerate(reader):
        for j, cell in enumerate(row):
            worksheet.write(i, j, str(cell.encode('utf-8')))
            if jcount < j:
                jcount = j

    return dict(wb=workbook, cols=jcount)


#get the number of results for a result set
class GetNumResults:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            #loop through all the fields.  If any have repeat fixed (zig-zag) we will
            #use the sum total of the number of repeats for the number of results
            for field in D["rs"]["fields"]:
                if hasRepeatFixed(field):
                    numRecords = 0
                    rff = json.loads(field["__pExcelOptions"]["repeatFixedFields"])
                    for item in rff:
                        numRecords += int(item["number"])
                    return json.dumps({"num":numRecords})
            #if there are no fixed repeats, we need to have a field that does a regular
            #repeat and is required to calculate the number of results
            numRepeats = 0
            numRequired = 0
            for field in D["rs"]["fields"]:
                parseExcel = True
                if "parseExcel" in field["__pFieldOptions"].keys():
                    parseExcel = field["__pFieldOptions"]["parseExcel"]
                if not parseExcel:
                    continue
                if field["__pExcelOptions"]:
                    if field["__pExcelOptions"]["repeat"]:
                        numRepeats += 1
                if field["__pFieldOptions"]:
                    if field["__pFieldOptions"]["required"]:
                        numRequired += 1
            if numRepeats == 0:
                return json.dumps({"num":1})
            else:
                if numRequired == 0:
                    return json.dumps({"num":0,"errors":["Templates with multiple records must have at least on required field."]})

            #load the appropriate file
            db = client[userInfo["database"]]
            collection = db["data"]
            f = collection.find({"id":int(D["fileId"])})[0]
            filepath = getUploadRoot(server,userInfo["companyId"]) + "/" + str(userInfo["companyId"])+"/"+f["path"]+"/"+f["actualFilename"]
            ext = re.findall(r"(\.[a-zA-Z0-9]{2,7})$",f["actualFilename"])[0].replace(".","")
            if ext in csvExtensions:
                try:
                    workbook = xlrd.open_workbook(file_contents=getCSVData(filepath).getvalue())
                    sheet = workbook.sheet_by_index(0)
                except:
                    return json.dumps({"num":0,"errors":["Unsupported file type."]})
            else:
                try:
                    workbook = xlrd.open_workbook(filepath)
                except:
                    return json.dumps({"num":0,"errors":["Unsupported file type."]})
                try:
                    worksheet = workbook.sheet_by_name(D["tabName"])
                except:
                    return json.dumps({"num":0,"errors":["No Sheet Named "+D["tabName"]]})

            #iterate fields
            for field in D["rs"]["fields"]:
                if field["__pExcelOptions"] and field["__pFieldOptions"]:
                    if field["__pExcelOptions"]["repeat"] and field["__pFieldOptions"]["required"]:
                        #required and repeating field

                        #skip if not to be excel parsed
                        parseExcel = True
                        if "parseExcel" in field["__pFieldOptions"].keys():
                            parseExcel = field["__pFieldOptions"]["parseExcel"]
                        if not parseExcel:
                            continue
                        numRecords = 0
                        #get offsets
                        leftOffset = int(field["__pExcelOptions"]["leftOffset"])-1
                        topOffset = int(field["__pExcelOptions"]["topOffset"])-1
                        leftOffsetOffset = int(field["__pExcelOptions"]["repeatWidth"])
                        topOffsetOffset = int(field["__pExcelOptions"]["repeatHeight"])
                        #if field has start special determinst start position (r,c) for field
                        if hasStartSpecial(field):
                            #get start special offsets and steps
                            startOffsetTop = int(field["__pExcelOptions"]["startOffsetTop"])
                            startOffsetLeft = int(field["__pExcelOptions"]["startOffsetLeft"])
                            startRightStep = int(field["__pExcelOptions"]["startRightStep"])
                            startDownStep = int(field["__pExcelOptions"]["startDownStep"])
                            breakFlag = False
                            i = 0
                            while not breakFlag:
                                #loop through file
                                c = leftOffset+(startRightStep*i)
                                r = topOffset+(startDownStep*i)
                                try:
                                    #break when the regex for start special matches the current cell
                                    val = worksheet.cell_value(r+startOffsetTop, c+startOffsetLeft)
                                    if re.match(field["__pExcelOptions"]["startRegex"],val):
                                        breakFlag = True
                                except:
                                    breakFlag = True
                                if breakFlag:
                                    leftOffset = c
                                    topOffset = r
                                i += 1
                        breakFlag = False
                        while not breakFlag:
                            #loop through file by steps to get the number of records
                            c = leftOffset+(leftOffsetOffset*numRecords)
                            r = topOffset+(topOffsetOffset*numRecords)
                            if hasEndSpecial(field):
                                #if field has end special we will break if the end criteria is met
                                try:
                                    val = str(worksheet.cell_value(r+int(field["__pExcelOptions"]["endTopOffset"]), c+int(field["__pExcelOptions"]["endLeftOffset"])))
                                    if re.match(field["__pExcelOptions"]["endRegex"],val):
                                        breakFlag = True
                                except:
                                    breakFlag = True
                            else:
                                #otherwise we will be breaking when we get a null value
                                try:
                                    cell_type = worksheet.cell_type(r, c)
                                    val = worksheet.cell_value(r, c)
                                    if val == "" or cell_type == 0:
                                        breakFlag = True
                                except:
                                    breakFlag = True
                            if not breakFlag:
                                numRecords +=1
                        return json.dumps({"num":numRecords})
            
    index.exposed = True

#get tab names that match a regular expression for a specified file
class GetTabNames:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            #load file in xlrd
            f = collection.find({"id":int(D["fileId"])})[0]
            filepath = getUploadRoot(server,userInfo["companyId"]) + "/" + str(userInfo["companyId"])+"/"+f["path"]+"/"+f["actualFilename"]
            ext = re.findall(r"(\.[a-zA-Z0-9]{2,7})$",f["actualFilename"])[0].replace(".","")
            if ext in csvExtensions:
                try:
                    workbook = xlrd.open_workbook(file_contents=getCSVData(filepath).getvalue())
                except:
                    return json.dumps({"num":0,"errors":["Unsupported file type."]})
            else:
                workbook = xlrd.open_workbook(filepath)
            tabNames = []
            if not D["isRegEx"]:
                #if not regular expression pass the tab name passed in back
                tabNames.append(D["tabName"])
            else:
                #add tabs that match regular expression to return
                for sheet in workbook.sheets():
                    if re.match(D["tabName"],sheet.name):
                        tabNames.append(sheet.name)
            return json.dumps(tabNames)
    index.exposed = True                    

#return an xlrd workbook for a specified tab name in the file associated with the file id
def getWorksheet(fileId,tabName,userInfo):
    db = client[userInfo["database"]]
    collection = db["data"]
    f = collection.find({"id":int(fileId)})[0]
    filepath = getUploadRoot(server,userInfo["companyId"]) + "/" + str(userInfo["companyId"])+"/"+f["path"]+"/"+f["actualFilename"]
    ext = re.findall(r"(\.[a-zA-Z0-9]{2,7})$",f["actualFilename"])[0].replace(".","")
    if ext in csvExtensions:
        #for csv files pass back the 0th tab/worksheet, because they do not have tabs
        try:
            workbook = xlrd.open_workbook(file_contents=getCSVData(filepath).getvalue())
            worksheet = workbook.sheet_by_index(0)
        except Exception as error:
            print error
            return "Unsupported file type."
    else:
        #get the worksheet by getting the sheet by name in xlrd workbook
        workbook = xlrd.open_workbook(filepath)
        try:
            worksheet = workbook.sheet_by_name(tabName)
        except:
            return "No Sheet Named "+tabName
    return {"sheet":worksheet,"book":workbook}

#end point to parse results from excel file.  takes the correct number of blank results as a parameter and
#populates them from excel
class ParseResults:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            #build and maintain worksheets object
            #holds all files and associated work sheets
            #with the form fileKey_tabName
            worksheets = {}
            w = getWorksheet(D["fileId"],D["tabName"],userInfo)
            if type(w) == type("this is a string"):
                return json.dumps({"num":0,"errors":["Unsupported file type."]})
            else:
                worksheets["primary_arx"] = {}
                worksheets["primary_arx"]["sheet"] = w["sheet"]
                worksheets["primary_arx"]["book"] = w["book"]
            if "allFiles" in D.keys():
                for fileKey in D["allFiles"].keys():
                    for tabName in D["allFiles"][fileKey]["tabNames"]:
                        w = getWorksheet(D["allFiles"][fileKey]["fileId"],tabName,userInfo)
                        if type(w) == type("this is a string"):
                            return json.dumps({"num":0,"errors":["Unsupported file type."]})
                        else:
                            worksheets[fileKey+"_"+tabName] = {}
                            worksheets[fileKey+"_"+tabName]["sheet"] = w["sheet"]
                            worksheets[fileKey+"_"+tabName]["book"] = w["book"]
            #iterate through each result
            for i,form in enumerate(D["forms"]):
                for field in form["fields"]:
                    if field["__pExcelOptions"]:
                        #skip field if should not be excel parsed
                        parseExcel = True
                        if "parseExcel" in field["__pFieldOptions"].keys():
                            parseExcel = field["__pFieldOptions"]["parseExcel"]
                        if not parseExcel:
                            continue
                        #aggregate: for string combining different fields. can combine fields of differing dimensions
                        aggregate = False
                        if "aggregate" in field["__pFieldOptions"].keys():
                            aggregate = field["__pFieldOptions"]["aggregate"]
                        if aggregate:
                            #create an array containing the values to be combined
                            #from each field that is listed in the aggregate fields
                            fieldValues = []
                            for fieldName in field["__pFieldOptions"]["aggregateFields"]:
                                for field2 in form["fields"]:
                                    if "__pFieldOptions" in field2.keys():
                                        if "name" in field2["__pFieldOptions"].keys():
                                            if fieldName.lower() == field2["__pFieldOptions"]["name"].lower():
                                                fieldValues.append(field2["value"])
                            #make all values in array 2d arrays
                            for x in range(len(fieldValues)):
                                if type(fieldValues[x]) != type([]):
                                    fieldValues[x] = [fieldValues[x]]
                                if type(fieldValues[x][0]) != type([]):
                                    fieldValues[x] = [fieldValues[x]]
                            #get max dimensions of field values
                            maxQ = 0
                            maxR = 0
                            for item in fieldValues:
                                if len(item) > maxQ:
                                    maxQ = len(item)
                                for item2 in item:
                                    if len(item2) > maxR:
                                        maxR = len(item2)
                            #combine fields of the same index in all arrays
                            #if a field does not have a particular index, use the highest index available
                            #for that fields value
                            field["value"] = []
                            for q in range(maxQ):
                                L = []
                                for r in range(maxR):
                                    thisVal = ""
                                    for item in fieldValues:
                                        try:
                                            thisVal += str(item[q][r])
                                        except:
                                            thisVal += str(item[-1][-1])
                                    L.append(thisVal)
                                field["value"].append(L)
                            #normalize to lowest dimensionality
                            if maxR == 1 and maxQ == 1:
                                field["value"] = field["value"][0][0]
                            if maxR > 1 and maxQ == 1:
                                field["value"] = field["value"][0]                               
                            continue
                        
                        if str(field["__pExcelOptions"]["leftOffset"]) != "0":
                            if hasStartSpecial(field):
                                if field["__pExcelOptions"]["startRegex"].startswith("$"):
                                    #if field has a start special starting with $ we want to set the start special
                                    #equal to that fields value if the field in question is multi dimensional
                                    #we need to iterate for each item in the field
                                    fieldName = field["__pExcelOptions"]["startRegex"][1:].strip()
                                    for field2 in form["fields"]:
                                        if "__pFieldOptions" in field2.keys():
                                            if "name" in field2["__pFieldOptions"].keys():
                                                #if we are referring to a field that exists
                                                if fieldName.lower() == field2["__pFieldOptions"]["name"].lower():
                                                    #normalize
                                                    L = field2["value"][:]
                                                    if type(L) != type([]):
                                                        L = [L]
                                                    if type(L[0]) != type([]):
                                                        L = [L]
                                                    maxQ = 0
                                                    maxR = 0
                                                    if len(L) > maxQ:
                                                        maxQ = len(L)
                                                    for item2 in L:
                                                        if len(item2) > maxR:
                                                            maxR = len(item2)
                                                    #iterate
                                                    for q in range(maxQ):
                                                        for r in range(maxR):
                                                            #set startRegEx to field value
                                                            field["__pExcelOptions"]["startRegex"] = L[q][r]
                                                            #get value from excel loop
                                                            L[q][r] = excelLoop(form,field,worksheets,i)
                                                    field["value"] = L
                                                    #renormalize to correct dimensionality
                                                    if maxR == 1 and maxQ == 1:
                                                        field["value"] = field["value"][0][0]
                                                    if maxR > 1 and maxQ == 1:
                                                        field["value"] = field["value"][0]  
                                    continue
                            #get value from excel loop
                            thisVal = excelLoop(form,field,worksheets,i)
                            #change w to h for array
                            if "reverse" in field["__pExcelOptions"]:
                                if field["__pExcelOptions"]["reverse"]:
                                    if type(thisVal) == type([]):
                                        if type(thisVal[0]) == type([]):
                                            if len(thisVal[0]) == 1:
                                                #it is a single row
                                                L = []
                                                for item in thisVal:
                                                    L.append(item[0])
                                                thisVal = L
                                            else:
                                                #really multidimensional
                                                L = []
                                                for q in range(thisVal[0]):
                                                    M = []
                                                    for item in thisVal:
                                                        M.append(item[q])
                                                    L.append(M)
                                                thisVal = L
                                        else:
                                            #1dimensional
                                            L = []
                                            for item in thisVal:
                                                L.append([item])
                                            thisVal = L
                                            
                            field["value"] = thisVal

            return json.dumps({"forms":D["forms"]})
            
    index.exposed = True

#function that actually retreives data from excel file
def excelLoop(form,field,worksheets,i):
    #get field offset,height,header, adn skip settings
    leftOffset = int(field["__pExcelOptions"]["leftOffset"])-1
    topOffset = int(field["__pExcelOptions"]["topOffset"])-1
    leftOffsetOffset = int(field["__pExcelOptions"]["repeatWidth"])
    topOffsetOffset = int(field["__pExcelOptions"]["repeatHeight"])
    dataWidth = int(field["__pExcelOptions"]["dataWidth"])
    dataHeight = int(field["__pExcelOptions"]["dataHeight"])
    hasHeaders = field["__pExcelOptions"]["hasHeaders"]
    wSkips = []
    hSkips = []
    if "wSkips" in field["__pExcelOptions"].keys():
        wSkips = json.loads(field["__pExcelOptions"]["wSkips"])
    if "hSkips" in field["__pExcelOptions"].keys():
        hSkips = json.loads(field["__pExcelOptions"]["hSkips"])

    #establish sheet name
    sheetName = "primary_arx"
    if hasOtherFile(field):
        sheetName = field["__pExcelOptions"]["otherFileName"] + "_" + field["__pExcelOptions"]["otherFileTabName"]

    #if hast start special set offsets to the position where the excel cell value = startRegEx    
    if hasStartSpecial(field):
        startOffsetTop = int(field["__pExcelOptions"]["startTopOffset"])
        startOffsetLeft = int(field["__pExcelOptions"]["startLeftOffset"])
        startRightStep = int(field["__pExcelOptions"]["startRightStep"])
        startDownStep = int(field["__pExcelOptions"]["startDownStep"])
        breakFlag = False
        k = 0
        while not breakFlag:
            c = leftOffset+(startRightStep*k)
            r = topOffset+(startDownStep*k)
            try:
                val = str(worksheets[sheetName]["sheet"].cell_value(r+startOffsetTop, c+startOffsetLeft))
                if re.match(field["__pExcelOptions"]["startRegex"],val):
                    breakFlag = True
            except:
                breakFlag = True
                return ""
            if breakFlag:
                leftOffset = c
                topOffset = r
            k += 1
    #if has repeat fixed (zig-zag) we will start c,r at the left and top offset
    if hasRepeatFixed(field):
        c = leftOffset
        r = topOffset
        L = []
        rff = json.loads(field["__pExcelOptions"]["repeatFixedFields"])
        breakFlag = False
        counter = 0
        for item in rff:
            c += int(item["leftOffset"])
            r += int(item["topOffset"])
            for k in range(int(item["number"])):
                if counter == i:
                    breakFlag = True
                    break
                else:
                    counter += 1
                    c += int(item["repeatWidth"])
                    r += int(item["repeatHeight"])
            if breakFlag:
                #if repeat fixed has update offset, update the offsets of the specified field
                if "updateOffsets" in item.keys():
                    for item2 in item["updateOffsets"]:
                        for field2 in form["fields"]:
                            if "__pFieldOptions" in field2.keys():
                                if "name" in field2["__pFieldOptions"].keys():
                                    if item2["name"].lower() == field2["__pFieldOptions"]["name"].lower():
                                        if item2["type"] == "relative":
                                            field2["__pExcelOptions"]["adjustedLeftOffset"] = c + int(item2["leftOffset"])
                                            field2["__pExcelOptions"]["adjustedTopOffset"] = r + int(item2["topOffset"])
                                        if item2["type"] == "fixed":
                                            field2["__pExcelOptions"]["adjustedLeftOffset"] = int(item2["leftOffset"]) - 1
                                            field2["__pExcelOptions"]["adjustedTopOffset"] = int(item2["topOffset"]) - 1
                break
    else:
        #set offset
        if "adjustedLeftOffset" in field["__pExcelOptions"].keys():
            c = field["__pExcelOptions"]["adjustedLeftOffset"]
            r = field["__pExcelOptions"]["adjustedTopOffset"]
        else:                                    
            c = leftOffset+(leftOffsetOffset*i)
            r = topOffset+(topOffsetOffset*i)
                
    if hasHeaders:
        r -= 1
        dataHeight += 1
    if dataWidth == 1 and dataHeight == 1:
        #if we are a single value
        try:
            #get value by coords
            thisVal = worksheets[sheetName]["sheet"].cell_value(r, c)
            if field["__pFieldOptions"]["type"] == "date":
                #convert to date object if possible
                try:
                    year, month, day, hour, minute, second = xlrd.xldate_as_tuple(int(round(float(thisVal),0)),worksheets[sheetName]["book"].datemode)
                    thisVal = datetime.datetime(year, month, day, hour, minute, second).strftime('%m/%d/%Y')
                except Exception as inst:
                    print str(inst)
                    try:
                        if thisVal != "":
                            thisVal = dateParser.parse(thisVal).strftime('%m/%d/%Y')
                    except:
                        pass
            if field["__pDefOptions"]["type"] == "percentage":
                #times 100 for percentage
                try:
                    thisVal = float(thisVal)* 100
                except Exception as inst:
                    pass
            return thisVal
        except Exception as inst:
            return ""
    else:
        #these can pretty easily be merged into the same group
        #return 1d array
        if dataWidth == 1:
            L = []
            for j in range(dataHeight+len(hSkips)):
                #repeat until we are on a skip if we have skips
                if j+1 in hSkips:
                    continue
                try:
                    #get this value
                    thisVal = worksheets[sheetName]["sheet"].cell_value(r+j, c)
                    if field["__pFieldOptions"]["type"] == "date":
                        #parse as date if possible
                        try:
                            year, month, day, hour, minute, second = xlrd.xldate_as_tuple(int(round(float(thisVal),0)),worksheets[sheetName]["book"].datemode)
                            thisVal = datetime.datetime(year, month, day, hour, minute, second).strftime('%m/%d/%Y')
                        except Exception as inst:
                            print str(inst)
                            try:
                                if thisVal != "":
                                    thisVal = dateParser.parse(thisVal).strftime('%m/%d/%Y')
                            except:
                                pass
                    if field["__pDefOptions"]["type"] == "percentage":
                        #times 100 for percentage
                        try:
                            thisVal = float(thisVal)* 100
                        except Exception as inst:
                            pass
                    L.append(thisVal)
                except:
                    L.append("")
            return L
        else:
            #return 2d array
            K = []
            for k in range(dataWidth+len(wSkips)):
                #if we are on a col we should skip, skip it
                if k+1 in wSkips:
                    continue
                L = []
                for j in range(dataHeight+len(hSkips)):
                    #if we are on a row we should skip, skip it
                    if j+1 in hSkips:
                        continue
                    try:
                        thisVal = worksheets[sheetName]["sheet"].cell_value(r+j, c+k)
                        if field["__pFieldOptions"]["type"] == "date":
                            #parse as date
                            try:
                                year, month, day, hour, minute, second = xlrd.xldate_as_tuple(int(round(float(thisVal),0)),worksheets[sheetName]["book"].datemode)
                                thisVal = datetime.datetime(year, month, day, hour, minute, second).strftime('%m/%d/%Y')
                            except:
                                try:
                                    if thisVal != "":
                                        thisVal = dateParser.parse(thisVal).strftime('%m/%d/%Y')
                                except:
                                    pass
                        L.append(thisVal)
                    except:
                        L.append("")
                K.append(L)
            return K
#handles calls from dynatree, returns appropriate children of tree node
class GetTree:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            
            try:
                query = {"parentId":int(D["key"])}
            except:
                pass

            #get root itmes
            if D["key"] == "root":
                query = {"typeId":userInfo["rootTypeId"]}

            query = makeSearch(query,userInfo)
            if D["key"] == "root":
                #sort root items by id
                cursor = collection.find(query).sort("id")
            else:
                #sort rest name
                cursor = collection.find(query).sort([('fields.0.value',1)])
            L = []
            for item in cursor:
                #don't show results in tree
                if "typeId" in item.keys():
                    if userInfo["resultTypeId"] == item["typeId"]:
                        return json.dumps([])
                #default name
                name = "unnamed"
                x = {}
                #set name
                for field in item["fields"]:
                    if "name" in field.keys():
                        if field["name"].lower() in ["name","assay name","eln run name"]:
                            x[field["name"].lower()] = field["value"]
                if "eln run name" in x.keys():
                    name = x["eln run name"]
                else:
                    if "name" in x.keys():
                        name = x["name"]
                    else:
                        if "assay name" in x.keys():
                            name = x["assay name"]
                #set icon
                if "icon" in item.keys():
                    icon = item["icon"]
                showTable = False
                #set other properties
                if "showTable" in item.keys():
                    showTable = item["showTable"]
                canStartRun = False
                if "typeId" in item.keys():
                    if item["typeId"] == 449:
                        canStartRun = True
                canEdit = True
                if "name" in item.keys():
                    if item["name"].lower() in gPerms.keys():
                        canEdit = gPerms[item["name"].lower()][userInfo["roleName"]]["edit"]
                if "locked" in item.keys():
                    if item["locked"]:
                        icon = "lock.gif"
                        canEdit = False
                canAdd = True
                if "typeId" in item.keys():
                    if userInfo["resultSetTypeId"] == item["typeId"] or item["typeId"] in [1792,1902,1807]:
                        canAdd = False
                r = {"key":str(item["id"]),"title":name,"icon":icon,"isLazy":True,"showTable":showTable,"canAdd":canAdd,"canEdit":canEdit,"canMove":False,"canStartRun":canStartRun}
                L.append(r)
                if D["key"] != "root":
                    L=sorted(L,key = lambda l :l["title"])                
            #return tree items
            return json.dumps(L)
    index.exposed = True        

class GetAssayTree:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            
            try:
                query = {"parentId":int(D["key"])}
            except:
                pass

            #get root itmes
            if D["key"] == "root":
                query = {"typeId":userInfo["rootTypeId"]}

            query = makeSearch(query,userInfo)
            if D["key"] == "root":
                #sort root items by id
                cursor = collection.find(query).sort("id")
            else:
                #sort rest name
                cursor = collection.find(query).sort([('fields.0.value',1)])
            L = []
            for item in cursor:
                #don't show results in tree
                if "typeId" in item.keys():
                    if userInfo["resultTypeId"] == item["typeId"]:
                        return json.dumps([])
                #default name
                name = "unnamed"
                x = {}

                #set name12/8/2016
                for field in item["fields"]:
                    if "name" in field.keys():
                        if field["name"].lower() in ["name","assay name","eln run name"]:
                            x[field["name"].lower()] = field["value"]
                if "eln run name" in x.keys():
                    name = x["eln run name"]
                else:
                    if "name" in x.keys():
                        name = x["name"]
                    else:
                        if "assay name" in x.keys():
                            name = x["assay name"]
                #set icon
                if "icon" in item.keys():
                    icon = item["icon"]
                showTable = False
                #set other properties
                if "showTable" in item.keys():
                    showTable = item["showTable"]
                canStartRun = False
                if "typeId" in item.keys():
                    if item["typeId"] == 449:
                        canStartRun = True
                canEdit = True
                if "name" in item.keys():
                    if item["name"].lower() in gPerms.keys():
                        canEdit = gPerms[item["name"].lower()][userInfo["roleName"]]["edit"]
                if "locked" in item.keys():
                    if item["locked"]:
                        icon = "lock.gif"
                        canEdit = False
                canAdd = True
                if "typeId" in item.keys():
                    if userInfo["resultSetTypeId"] == item["typeId"] or item["typeId"] in [1792,1902,1807]:
                        canAdd = False
                r = {"key":str(item["id"]),"title":name,"icon":icon,"isLazy":True,"showTable":showTable,"canAdd":canAdd,"canEdit":canEdit,"canMove":False,"canStartRun":canStartRun}
                if "name" in item.keys():
                      if (item["name"] != "Assay" and item["name"] != "CBIP Assay"):
                         L.append(r)
            #return tree items
                L=sorted(L,key = lambda l :l["title"])      
            return json.dumps(L)
    index.exposed = True        


class GetProtocolTree:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            
            try:
                query = {"parentId":int(D["key"])}
            except:
                pass

            #get root itmes
            if D["key"] == "root":
                query = {"typeId":userInfo["rootTypeId"]}

            query = makeSearch(query,userInfo)
            if D["key"] == "root":
                #sort root items by id
                cursor = collection.find(query).sort("id")
            else:
                #sort rest name
                cursor = collection.find(query).sort([('fields.0.value',1)])
            L = []
            for item in cursor:
                #don't show results in tree
                if "typeId" in item.keys():
                    if userInfo["resultTypeId"] == item["typeId"]:
                        return json.dumps([])
                #default name
                name = "unnamed"
                x = {}

                #set name12/8/2016
                for field in item["fields"]:
                    if "name" in field.keys():
                        if field["name"].lower() in ["name","assay name","eln run name"]:
                            x[field["name"].lower()] = field["value"]
                if "eln run name" in x.keys():
                    name = x["eln run name"]
                else:
                    if "name" in x.keys():
                        name = x["name"]
                    else:
                        if "assay name" in x.keys():
                            name = x["assay name"]
                #set icon
                if "icon" in item.keys():
                    icon = item["icon"]
                showTable = False
                #set other properties
                if "showTable" in item.keys():
                    showTable = item["showTable"]
                canStartRun = False
                if "typeId" in item.keys():
                    if item["typeId"] == 449:
                        canStartRun = True
                canEdit = True
                if "name" in item.keys():
                    if item["name"].lower() in gPerms.keys():
                        canEdit = gPerms[item["name"].lower()][userInfo["roleName"]]["edit"]
                if "locked" in item.keys():
                    if item["locked"]:
                        icon = "lock.gif"
                        canEdit = False
                canAdd = True
                if "typeId" in item.keys():
                    if userInfo["resultSetTypeId"] == item["typeId"] or item["typeId"] in [1792,1902,1807]:
                        canAdd = False
                r = {"key":str(item["id"]),"title":name,"icon":icon,"isLazy":True,"showTable":showTable,"canAdd":canAdd,"canEdit":canEdit,"canMove":False,"canStartRun":canStartRun}
                if "name" in item.keys():
                      if (item["name"] != "Protocol" and item["name"] != "CBIP Protocol"):
                         L.append(r)
                L=sorted(L,key = lambda l :l["title"])      
            #return tree items
            return json.dumps(L)
    index.exposed = True       

# get the parent name and type of the node when pasting
class GetParentType:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            # name = " "
            # typeId = " "
            query = makeSearch({"id":int(D["key"])},userInfo)
            cursor = collection.find_one(query)
            name = cursor["name"]
            typeId = cursor["typeId"]
            D = {"name":name,"typeId":typeId}
            return json_util.dumps(D)
    index.exposed = True

# get the parent name of the node when pasting
class GetParentName:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            L=[]
            try:
              query = makeSearch({"id":int(D["key"])},userInfo)
              cursor = collection.find_one(query)
              parentTree = []
              parentTree = cursor["parentTree"]
              parentQuery = makeSearch({"id":{"$in":parentTree}},userInfo)
              parentCursors = collection.find(parentQuery)
              for row in parentCursors:
                name = row["fields"][0]["value"]
                L.append(name)
            except:
                pass
            D = {"form" :L}
            return json_util.dumps(D)
    index.exposed = True
      

#create random alpha numeric string
def randString(numChars):
    return binascii.b2a_hex(os.urandom(numChars))

#wrap global search security around mongo query
def makeSearch(query,userInfo):
    searchList = []
    searchList.append(query)
    searchList.append(userInfo["searchSecurity"])
    return {"$and":searchList}

#returns a list of results for a query along with a cursor for easy retrieval of other results
class GetList:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            if "cursorId" in D.keys():
                print D["cursorId"]
            cursorD = {}
            #if not cursor id was supplied, create a new cursor
            if "cursorId" not in D.keys():
                #run query
                db = client[userInfo["database"]]
                collection = db["data"]
                query = makeSearch(D["query"],userInfo)
                count = 0
                cursor = collection.find(query).sort('fields.0.value')
                cursorId = randString(10)
                #set cursor properties
                C = {}
                C["cursor"] = cursor
                C["count"] = cursor.count()
                if C["count"] > 0:
                    C["pages"] = int(math.ceil(float(C["count"])/D["rpp"]))
                else:
                    C["pages"] = 0
                C["cursorId"] = cursorId
                C["offset"] = 0
                C["data"] = []
                
                #add cursor to global cursors
                Cursors[cursorId] = C
                CursorPings[cursorId] = time.time()
            else:
                #otherwise use the supplied cursor
                cursorId = D["cursorId"]
                cursor = Cursors[cursorId]["cursor"]
            F = []

            #move cursor next
            if D["action"] == "next":
                start = Cursors[cursorId]["offset"]
                end = Cursors[cursorId]["offset"] + D["rpp"]
                if end > Cursors[cursorId]["count"]:
                    end = Cursors[cursorId]["count"]
            #move cursor end
            if D["action"] == "last":
                start = (Cursors[cursorId]["count"]/D["rpp"])*D["rpp"]
                if start == Cursors[cursorId]["count"]:
                    start -=D["rpp"]
                end = Cursors[cursorId]["count"]
                if end > Cursors[cursorId]["count"]:
                    end = Cursors[cursorId]["count"]
            #move cursor prev
            if D["action"] == "prev":
                if Cursors[cursorId]["offset"]==Cursors[cursorId]["count"] and Cursors[cursorId]["count"] % D["rpp"]!=0:
                    oldStart = (Cursors[cursorId]["count"]/D["rpp"])*D["rpp"]+D["rpp"]
                else:
                    oldStart = Cursors[cursorId]["offset"]
                start = oldStart-D["rpp"]*2
                if start<0:
                    start = 0
                end = oldStart-D["rpp"]
            #move cursor begining
            if D["action"] == "first":
                start = 0
                end = D["rpp"]
            Cursors[cursorId]["page"] = start/D["rpp"]+1
            #append the correct number of results to the data key on the cursor object
            while end > len(Cursors[cursorId]["data"]):
                if cursor and cursor.alive:
                    item = cursor.next()
                    if "index" in item.keys():
                        zFillNum = 2
                        if item["_type"] == "assayGroup":
                            zFillNum = 4
                        item["name"] = str(item["index"]).zfill(zFillNum) + " " + item["name"]
                    Cursors[cursorId]["data"].append(item)
            for i in range(start,end):
                item = Cursors[cursorId]["data"][i]["id"]
                F.append(item)
            #set data that will tell us where we are when we use this cursor again
            offset = end
            Cursors[cursorId]["offset"]=offset
            #set pagination options
            if offset > D["rpp"]:
                Cursors[cursorId]["hasFirst"] = True
                Cursors[cursorId]["hasPrev"] = True
            else:
                Cursors[cursorId]["hasFirst"] = False
                Cursors[cursorId]["hasPrev"] = False
            if offset < Cursors[cursorId]["count"]:
                Cursors[cursorId]["hasLast"] = True
                Cursors[cursorId]["hasNext"] = True
            else:
                Cursors[cursorId]["hasLast"] = False
                Cursors[cursorId]["hasNext"] = False
            cd = {}
            for key in Cursors[cursorId].keys():
                if key not in ["cursor","data"]:
                    cd[key] = Cursors[cursorId][key]
            D = {"forms":F,"cursorData":cd}
            return json.dumps(D,default=json_util.default)
    index.exposed = True        

#custom endpoint for broad
#Arxlab CBIPNames
#This call is made from CBIP to Arxspan. The purpose of this method is to provide the names of CBIP Projects, Assays, and Protocols for requested protocols. This method returns a JSON array of CBIP protocol objects.
#GET /arxlab/assay2/CBIPNames.asp? HTTP/1.1
#Parameters
#projectCode    4 digit left-zero-padded project code.
#assayCode      2 digit left-zero-padded assay code. (optional)
#protocolCode   2 digit left-zero-padded protocol code. (optional)
#clientId       Arxspan provided client id
#clientSecret   Arxspan provided client secret
#There are two ways to use this method. In the first, only a project code is supplied. Arxspan sends a JSON array of all protocols under that project.
#EXAMPLE 1
#GET /arxlab/assay2/cbipNames.asp?projectCode=7180&clientId=[redacted]&clientSecret=[redacted] HTTP/1.1
#HTTP/1.1 200 OK
#Content-Type: application/json; [{
#"protocolCode": "01",
#"projectName": "BHS LSD1-test",
#"projectCode": "7180",
#"assayName": "test3",
#"assayCode": "01",
#"protocolName": "my awesome prococol"
#}, {
#"protocolCode": "02",
#"projectName": "BHS LSD1-test",
#"projectCode": "7180",
#"assayName": "test3",
#"assayCode": "01",
#"protocolName": "awesome prococol 2"
#},
#...
#]
#In the second, a project code, assay code, and a protocol id are supplied. Arxspan sends a JSON array with a single object containing the name information about the specified protocol.
#EXAMPLE 2
#GET /arxlab/assay2/cbipNames.asp? projectCode=7180&assayCode=01&protocolCode=01&clientId=[redacted]&clientSecret=[redacted] HTTP/1.1
#HTTP/1.1 200 OK
#Content-Type: application/json; [{
#"projectCode": "7180",
#"projectName": "BHS LSD1-test",
#"protocolCode": "01",
#"assayName": "test3",
#"assayCode": "01",
#"protocolName": "my awesome prococol"
#}]
class GetCBIPNames:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            #get data for single protocol
            if D["projectCode"] != "" and D["assayCode"] != "" and D["protocolCode"] != "":
                r = {}
                try:
                    db = client[userInfo["database"]]
                    collection = db["data"]
                    projectCursor = collection.find({"typeId":359,"visible":True,"_sort.project_code":str(D["projectCode"]).zfill(4)})
                    if projectCursor.count()>0:
                        r["projectName"] = projectCursor[0]["_sort"]["project_short_name"]
                        r["projectCode"] = str(projectCursor[0]["_sort"]["project_code"]).zfill(4)

                        assayCursor = collection.find({"typeId":396,"_sort.index":int(D["assayCode"]),"visible":True,"parentId":projectCursor[0]["id"]})
                        if assayCursor.count()>0:
                            if "assay_name" in assayCursor[0]["_sort"].keys():
                                r["assayName"] = assayCursor[0]["_sort"]["assay_name"]
                            else:
                                r["assayName"] = assayCursor[0]["_sort"]["name"]
                                if r["assayName"].startswith(D["assayCode"].zfill(2)):
                                    r["assayName"] = r["assayName"][len(D["assayCode"].zfill(2)):].strip()
                            r["assayCode"] = str(assayCursor[0]["_sort"]["index"]).zfill(2)

                            protocolCursor = collection.find({"typeId":449,"_sort.index":int(D["protocolCode"]),"visible":True,"parentId":assayCursor[0]["id"]})
                            if protocolCursor.count()>0:
                                r["protocolName"] = protocolCursor[0]["_sort"]["protocol_name"]
                                r["protocolCode"] = str(protocolCursor[0]["_sort"]["index"]).zfill(2)
                                try:
                                    r["measurementLabels"] = "||".join(protocolCursor[0]["_sort"]["measurement_labels"])
                                except:
                                    pass
                except Exception as inst:
                    pass
                return json.dumps([r])
            #get data for all protocols on an assay
            if D["projectCode"] != "" and D["assayCode"] == "" and D["protocolCode"] == "":
                try:
                    rd = {}
                    L = []
                    db = client[userInfo["database"]]
                    collection = db["data"]
                    projectCursor = collection.find({"typeId":359,"visible":True,"_sort.project_code":str(D["projectCode"]).zfill(4)})

                    if projectCursor.count()>0:
                        projectName = projectCursor[0]["_sort"]["project_short_name"]
                        projectCode = str(projectCursor[0]["_sort"]["project_code"]).zfill(4)
                        projectId = projectCursor[0]["id"]
                        rd[projectId] = {}
                        rd[projectId]["projectName"] = projectName
                        rd[projectId]["projectCode"] = projectCode

                        assayCursor = collection.find({"typeId":396,"visible":True,"parentId":projectId})
                        for item in assayCursor:
                            assayCode = str(item["_sort"]["index"]).zfill(2)
                            if "assay_name" in item["_sort"].keys():
                                assayName = item["_sort"]["assay_name"]
                            else:
                                assayName = item["_sort"]["name"]
                                if assayName.startswith(assayCode.zfill(2)):
                                    assayName = assayName[len(assayCode.zfill(2)):].strip()                            
                            assayId = item["id"]
                            rd[assayId] = {}
                            rd[assayId]["assayName"] = assayName
                            rd[assayId]["assayCode"] = assayCode

                            protocolCursor = collection.find({"typeId":449,"visible":True,"parentId":assayId})
                            for item2 in protocolCursor:
                                protocolName = item2["_sort"]["protocol_name"]
                                protocolCode = str(item2["_sort"]["index"]).zfill(2)
                                r = {}
                                r["protocolName"] = protocolName
                                r["protocolCode"] = protocolCode
                                try:
                                    r["measurementLabels"] = "||".join(item2["_sort"]["measurement_labels"])
                                except:
                                    pass
                                r["assayName"] = assayName
                                r["assayCode"] = assayCode
                                r["projectName"] = projectName
                                r["projectCode"] = projectCode
                                L.append(r)

                except:
                    pass
                return json.dumps(L)
    index.exposed = True

#returns true if session data for the supplied connection id exists
class IsLoggedIn:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        if "cursorId" in D.keys():
            if D["cursorId"]:
                if D["cursorId"] in [x for x in Cursors]:
                    CursorPings[D["cursorId"]] = time.time()
        return json.dumps({"flag":D["connectionId"] in connections.keys()})
    index.exposed = True        

#saves history item with hash and function data
class SetHistory:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["history"]
            H = {}
            H["hash"] = D["hash"]
            H["functionData"] = D["functionData"]
            collection.find_and_modify(query={"hash":D["hash"]},update= { "$set": { "functionData": D["functionData"] } },upsert=True)
    index.exposed = True

#returns history data for the specified hash
class GetHistory:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["history"]
            cursor =  collection.find({"hash":D["hash"]},no_cursor_timeout=True).limit(1)
            if cursor.count() == 1:
                return json.dumps({"functionData":cursor[0]["functionData"]})
            else:
                return json.dumps({"functionData":""})
    index.exposed = True

#pass through wrapper so that we can assign methods to dictionaries
class WrapD(dict):
    pass
#pass through wrapper so that we can assign methods to lists
class WrapL(list):
    pass

#return field names from a fieldSet
def getFieldNames(x):
    def getFieldNamesX():
        L = []
        for item in x["fields"]:
            if item.isField:
                #should not have to do this check probably do not have to
                #for new items
                if "__pFieldOptions" in item.keys():
                    L.append(item["__pFieldOptions"]["name"])
        return L
    return getFieldNamesX

#return field names from a field set
def getFieldNamesList(x):
    def getFieldNamesListX():
        L = []
        for item in x:
            if item.isField:
                L.append(item["__pFieldOptions"]["name"])
        return L
    return getFieldNamesListX

#return field with the specified name from a fields set
def getFieldByName(x):
    def getFieldByNameX(fieldName):
        L = []
        for item in x["fields"]:
            if item.isField:
                if item["__pFieldOptions"]["name"].lower() == fieldName.lower():
                    #does this need to return the list item e.g. x["fields"][i]
                    return item
        return False
    return getFieldByNameX

#return field with the specified name from a fields set
def getFieldByNameList(x):
    def getFieldByNameListX(fieldName):
        L = []
        for item in x:
            if item.isField:
                if item["__pFieldOptions"]["name"].lower() == fieldName.lower():
                    #does this need to return the list item e.g. x["fields"][i]
                    return item
        return False
    return getFieldByNameListX

#attach functions to form object for better navigation and retrieval
def wrap(obj,userInfo,parent,root,parentKey=None):
    db = client[userInfo["database"]]
    collection = db["data"]
    if isinstance(obj,dict):
        x = WrapD(obj)
        x.isField = False
        x.isForm = False
        x.hasFields = False
        x.parent = parent
        #set has fields attribute
        if "fields" in x.keys():
            x.hasFields = True
        #we are on the root
        if parent == None:
            x.multiFieldSets = []
            x.isForm = True
            x.userInfo = userInfo
            #if we don't have an id get one
            if "id" not in x.keys():
                x["id"] = getNextSequence(db,"globalId")
            x.id = x["id"]
        if parentKey:
            #make sure we are a field, set root node of field
            if not parentKey.startswith("_"):
                x.rootNode = root
                x.isField = True

        #attach parent field
        x.parentField = None
        nextParent = x
        while nextParent.parent != None:
            nextParent = nextParent.parent
            if isinstance(nextParent,dict):
                if nextParent.isField or nextParent.isForm:
                    x.parentField = nextParent
                    break
        #attach appropiate funder source
        if "_dunderSource" in x.keys():
            dunder = collection.find({"id":obj["_dunderSource"]})[0]
            for key in dunder.keys():
                #move parent items to parent
                if key=="__parent":
                    for key2 in dunder["__parent"]:
                        x[key2] = dunder["__parent"][key2]
                else:
                    #add dunder object or merge with existing
                    if key.startswith("__"):
                        if key in obj.keys():
                            for key2 in dunder[key].keys():
                                x[key][key2] = dunder[key][key2]
                        else:
                            x[key] = dunder[key]
        #if we have fields, attach getField functions appropriately
        if x.hasFields:
            if "__pFieldOptions" in x.keys():
                if "multi" in x["__pFieldOptions"]:
                    if not x["__pFieldOptions"]["multi"]:
                        x.getFieldNames = getFieldNames(x)
                        x.getFieldByName = getFieldByName(x)
                else:
                    if len(x["fields"]) > 0:
                        if not isinstance(x["fields"][0],list):
                            x.getFieldNames = getFieldNames(x)
                            x.getFieldByName = getFieldByName(x)
            else:
                x.getFieldNames = getFieldNames(x)
                x.getFieldByName = getFieldByName(x)

        #add ourselves to multi field sets if we are a multi field set
        if "__pFieldOptions" in x.keys():
            if "type" in x["__pFieldOptions"].keys() and "multi" in x["__pFieldOptions"].keys():
                if x["__pFieldOptions"]["type"] == "fieldSet" and x["__pFieldOptions"]["multi"]:
                    try:
                        x.rootNode.multiFieldSets.append(x)
                    except:
                        pass
        return x
    if isinstance(obj,list):
        x = WrapL(obj)
        x.parent = parent

        #set parent field        
        x.parentField = None
        nextParent = x
        while nextParent.parent != None:
            nextParent = nextParent.parent
            if isinstance(nextParent,dict):
                if nextParent.isField or nextParent.isForm:
                    x.parentField = nextParent
                    break
        #add field methods as appropriate
        if x.parentField:
            if "__pFieldOptions" in x.parentField.keys():
                if "multi" in x.parentField["__pFieldOptions"]:
                    if x.parentField["__pFieldOptions"]["multi"]:
                        x.getFieldNames = getFieldNamesList(x)
                        x.getFieldByName = getFieldByNameList(x)
        x.isField = False
        return x

#iterate over all objects in a form
def traverse(obj):
    if isinstance(obj, dict):
        yield obj
        for key in obj.keys():
            for x in traverse(obj[key]):
                yield x
    elif isinstance(obj, list):
        for elem in obj:
            for x in traverse(elem):
                yield x
    else:
        return

#iterate over all objects in a form and wrap them with properties and methods as appropriate
def traverse2(obj,userInfo,parent=None,root=None,parentKey=None):
    if isinstance(obj, dict):
        obj = wrap(obj,userInfo,parent,root,parentKey=parentKey)
        if root == None:
            root = obj
        for key in obj.keys():
            obj[key] = traverse2(obj[key],userInfo,parent=obj,root=root,parentKey=key)
        return obj
    elif isinstance(obj, list):
        obj = wrap(obj,userInfo,parent,root,parentKey=parentKey)
        for i,item in enumerate(obj):
            obj[i] = traverse2(item,userInfo,parent=obj,root=root,parentKey=parentKey)
        return obj
    else:
        return obj

#remove dunder objects from a form
#remove all keys that start with __
def removeDunder(obj,userInfo,parent=None,root=None,parentKey=None):
    if isinstance(obj, dict):
        obj = wrap(obj,userInfo,parent,root,parentKey=parentKey)
        if root == None:
            root = obj
        for key in obj.keys():
            if key.startswith("__"):
                #remove key that start with __
                del obj[key]
            else:
                #keep going
                obj[key] = removeDunder(obj[key],userInfo,parent=obj,root=root,parentKey=key)
        return obj
    elif isinstance(obj, list):
        #keep going we cant have a dunder object on a list
        obj = wrap(obj,userInfo,parent,root,parentKey=parentKey)
        for i,item in enumerate(obj):
            obj[i] = removeDunder(item,userInfo,parent=obj,root=root,parentKey=parentKey)
        return obj
    else:
        return obj

#create an object called _sort at the root of the form
#{form....
# _sort:{"fieldName":"fieldVal","fieldName2","fieldVal2"}
#the purpose of this is to make a sort of view that is easier to sort than the more complicated queries of drilling down into the actual fields would be
#key names have spaces replaced with _ and are lower cased
def getSort(obj):
    s = {}
    for fieldName in obj.getFieldNames():
        field = obj.getFieldByName(fieldName)
        if field["__pFieldOptions"]["type"]!="fieldSet":
            try:
                s[re.sub("\s+","_",field["__pFieldOptions"]["name"]).lower()] = field["value"]
            except Exception as inst:
                print inst
                pass
    return s

def sendToSearchTool(form):
    if form.userInfo["hasFT"]:
        sendToSearchToolF(form,False)
    if form.userInfo["hasFTLite"] and form.userInfo["FTDB"] != form.userInfo["FTDBLite"]:
        sendToSearchToolF(form,True)

def isDateField(field):
    if "__pFieldOptions" in field.keys():
        if "validation" in field["__pFieldOptions"]:
            return "isDate" in field["__pFieldOptions"]["validation"]
    return False

def isCurve(field):
    if "__pFieldOptions" in field.keys():
        if "type" in field["__pFieldOptions"]:
            return field["__pFieldOptions"]["type"].lower() == "curve"
    return False

def isMultiValue(field):
    if "value" in field.keys():
        return isinstance(field["value"], list)
    return False

def isMultiFieldSet(field):
    if "__pFieldOptions" in field.keys():
        if "type" in field["__pFieldOptions"] and "multi" in field["__pFieldOptions"]:
            return "fieldSet" == field["__pFieldOptions"]["type"] and field["__pFieldOptions"]["multi"]
    return False


def isFieldSet(field):
    if "__pFieldOptions" in field.keys():
        if "type" in field["__pFieldOptions"]:
            return "fieldSet" == field["__pFieldOptions"]["type"]
    return False

#get a dictionary of fieldName/value key value pairs for each field in a fieldset
def getFieldDict(form):
    dateFields = []
    data = {}
    for fieldName in form.getFieldNames():
        field = form.getFieldByName(fieldName)
        if not isFieldSet(field):
            if isCurve(field):
                try:
                    imgSrc = json.loads(field["value"])["image"]
                except:
                    imgSrc = ""
                data[encodeValue(fieldName.replace(".",""))] = "<img src='"+imgSrc+"'/>"
            else:
                data[encodeValue(fieldName.replace(".",""))] = encodeValue(field["value"])
            if isDateField(field):
                dateFields.append(field["name"])
            if fieldName.lower() == "registration id":
                if not form.isLite:
                    addRegData(form,data,dateFields,field["value"])
        else:
            if not isMultiFieldSet(field):
                for fieldName2 in field.getFieldNames():
                    field2 = field.getFieldByName(fieldName2)
                    if not isFieldSet(field2):
                        if isCurve(field2):
                            try:
                                imgSrc = json.loads(field2["value"])["image"]
                            except:
                                imgSrc = ""                            
                            data[encodeValue(fieldName2.replace(".",""))] = "<img src='"+imgSrc+"'/>"
                        else:                            
                            data[encodeValue(fieldName2.replace(".",""))] = encodeValue(field2["value"])
                        if isDateField(field2):
                            dateFields.append(field2["name"])
                    if fieldName2.lower() == "registration id":
                        if not form.isLite:
                            addRegData(form,data,dateFields,field2["value"])

    D = {}
    D["data"] = data
    D["dateFields"] = dateFields
    return D

#get reg data dictionary from ELN/REg service
def addRegData(form,D,dateFields,val):
    try:
        rd = json.loads(restCall(regPath+"services/getRegJSON.asp?userId="+str(form.userInfo["id"])+"&companyId="+str(form.userInfo["companyId"])+"&regId="+str(val),verb="GET"))
        regD = rd["data"]
        dateFields2 = rd["config"]["dateFields"]
        for key in regD.keys():
            if key != "_recordType":
                #prefer already existing key in the case of duplicates, except prefer reg structure
                if key not in D.keys() or key=="Structure":
                    D[key] = regD[key]
        for df in dateFields2:
            if df not in dateFields:
                dateFields.append(df)
    except:
        pass

#get a dictionary of fieldName/value key value pairs for each field in a fieldset for a result
def getFieldDictRS(form):
    dateFields = []
    data = {}
    for fieldName in form.getFieldNames():
        field = form.getFieldByName(fieldName)
        if not isMultiValue(field):
            if isCurve(field):
                try:
                    imgSrc = json.loads(field["value"])["image"]
                except:
                    imgSrc = ""
                data[fieldName.replace(".","").encode('ascii','xmlcharrefreplace')] = "<img src='"+imgSrc+"'/>"
            else:
                data[fieldName.replace(".","").encode('ascii','xmlcharrefreplace')] = encodeValue(field["value"])
        if isDateField(field):
            dateFields.append(field["name"])
        if fieldName.lower() == "registration id":
            if not form.isLite:
                addRegData(form,data,dateFields,field["value"])
    D = {}
    D["data"] = data
    D["dateFields"] = dateFields
    return D

def encodeValue(value):
    """
    This function checks the value if it is a string, and if it is, it encodes it and returns it
    :param value: the value that should be encoded if it is a string
    :return: the encoded string if the value was a string or the value if it is not a string
    """
    if isinstance(value, basestring):
        return value.encode('ascii','xmlcharrefreplace')
    return value

def sendToSearchToolF(form,isLite):
    #send form to search tool
    form.isLite = isLite
    dateFields = []
    if form["typeId"] != form.userInfo["resultTypeId"]:
        if len(form.multiFieldSets) == 0:
            #for simple forms that do not have multi field sets create a dictionary for FT
            #with simple field name/value key pairs
            D = getFieldDict(form)
            data = D["data"]
            dateFields = D["dateFields"]
        else:
            #otherwise create a separate dictionary for each field set in a multi field set and include the field name/value key pairs for all of the fields at root level
            data = []
            D1 = getFieldDict(form)
            dateFields = D1["dateFields"]
            for fieldSetList in form.multiFieldSets:
                for fs in fieldSetList["fields"]:
                    D2 = getFieldDict(fs)
                    r = D2["data"]
                    for dateField in D2["dateFields"]:
                        if dateField not in dateFields:
                            dateFields.append(dateField)
                    for key in D1["data"].keys():
                        if key not in r:
                            r[key] = D1["data"][key]
                    data.append(r)
    else:
        #results are handled differently
        db = client[form.userInfo["database"]]
        collection = db["data"]
        defData = {}
        #add data to FT dictionary that has data from the parent assay,protocol, and result set
        resultSet = traverse2(collection.find({"id":form["parentId"]})[0],form.userInfo)
        protocol = traverse2(collection.find({"id":resultSet["parentId"]})[0],form.userInfo)
        assay = traverse2(collection.find({"id":protocol["parentId"]})[0],form.userInfo)
        defData["Result Set Id"] = resultSet["id"]
        defData["Result Set Name"] = resultSet.getFieldByName("name")["value"]
        defData["Protocol Name"] = protocol.getFieldByName("name")["value"]
        if not form.getFieldByName("Assay Name"):
            defData["Assay Name"] = assay.getFieldByName("name")["value"]
        #determine the largest dimensionality of array data
        hasMultis = False
        maxDataWidth = 1
        maxDataHeight = 1
        headersOnMulti = False
        for fieldName in form.getFieldNames():
            field = form.getFieldByName(fieldName)
            parseFT = True
            if "__ftOptions" in field.keys():
                if "send" in field["__ftOptions"].keys():
                    parseFT = field["__ftOptions"]["send"]
            if not parseFT:
                #if this field does not have parseFT set, skip it
                continue
            if "__pExcelOptions" in field.keys():
                reverse = False
                if "reverse" in field["__pExcelOptions"].keys():
                    reverse = field["__pExcelOptions"]["reverse"]
                if reverse:
                    dataWidth = int(field["__pExcelOptions"]["dataHeight"])
                    dataHeight = int(field["__pExcelOptions"]["dataWidth"])
                else:
                    dataWidth = int(field["__pExcelOptions"]["dataWidth"])
                    dataHeight = int(field["__pExcelOptions"]["dataHeight"])
                hasHeaders = field["__pExcelOptions"]["hasHeaders"]
                if hasHeaders:
                    dataHeight += 1
                    headersOnMulti = True
                skipIt = False
                try:
                    if str(field["__pFieldOptions"]["name"]) == "rawDataBlock":
                        skipIt = True
                except Exception as inst:
                    pass
                if not skipIt:                    
                    if not (dataHeight==1 and dataWidth==1):
                        hasMultis = True
                        if dataHeight > maxDataHeight:
                            maxDataHeight = dataHeight
                        if dataWidth > maxDataWidth:
                            maxDataWidth = dataWidth
        if not hasMultis:
            #if there is no array data for field values make a simple dictionary with field name/value key pairs and add all of the assay,protocol, and result set data
            D = getFieldDictRS(form)
            data = D["data"]
            data.update(defData)
            dateFields = D["dateFields"]
        else:
            D = getFieldDictRS(form)
            rsData = D["data"]
            rsData.update(defData)
            dateFields = D["dateFields"]
            data = []
            #loop through the max width and height.  add a row for each iteration.  for each iteration get the value of any non array data.  Then try to get the current index from array data
            #if the current index is out of bounds for that array, use the highest index of the array
            for i in range(maxDataHeight):
                for j in range(maxDataWidth):
                    skipIt = False
                    D2 = {}
                    for fieldName in form.getFieldNames():
                        field = form.getFieldByName(fieldName)
                        parseFT = True
                        if "__ftOptions" in field.keys():
                            if "send" in field["__ftOptions"].keys():
                                parseFT = field["__ftOptions"]["send"]
                        if not parseFT:
                            continue
                        if isMultiValue(field):
                            if headersOnMulti and i==0:
                                skipIt = True
                            if not skipIt:
                                try:
                                    if maxDataWidth == 1:
                                        D2[fieldName.replace(".","").encode('ascii','xmlcharrefreplace')] = encodeValue(field["value"][i])
                                    else:
                                        D2[fieldName.replace(".","").encode('ascii','xmlcharrefreplace')] = encodeValue(field["value"][i][j])
                                except Exception as inst:
                                    print str(inst)
                                    pass
                                #if field name is registration id get data from registration system and add it to the dictionary
                                #only for FT heavy
                                if fieldName.lower() == "registration id":
                                    if not form.isLite:
                                        addRegData(form,D2,dateFields,D2[fieldName])
                    if not skipIt:
                        for key in rsData:
                            D2[key] = rsData[key]
                        data.append(D2)

    #generate file for FT inbox
    D = {}
    D["config"] = {}
    if isLite:
        D["config"]["dbName"] = form.userInfo["FTDBLite"]
    else:
        D["config"]["dbName"] = form.userInfo["FTDB"]
    D["config"]["updateFieldName"] = "Assay Id"
    D["config"]["updateFieldValue"] = form.id
    D["config"]["dateFields"] = dateFields
    D["data"] = data
    if type(D["data"]) != type([]):
        D["data"]["_recordType"] = "assay"
        D["data"]["Assay Id"] = form.id
        D["data"]["idAssay"] = form.id
        D["data"]["Object Type Name"] = form["name"]
        D["data"]["parentTreeAssay"] = form["parentTree"]
    else:
        for i in range(len(D["data"])):
            D["data"][i]["_recordType"] = "assay"
            D["data"][i]["Assay Id"] = form.id
            D["data"][i]["idAssay"] = form.id
            D["data"][i]["Object Type Name"] = form["name"]
            D["data"][i]["parentTreeAssay"] = form["parentTree"]

    extra=""
    if isLite:
        extra = "_lite"
    file = open("c:/INBOX-FT/"+str(form.id)+"-"+randString(8)+extra+".json","w")		
    file.write(json.dumps(D))
    file.close()

class helloWorld():
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        return json.dumps(D)
                
    index.exposed = True        

class SendDataToFT():
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            #send all to FT
            db = client[userInfo["database"]]
            collection = db["data"]
            query = makeSearch({"parentId":{"$exists":"true"}},userInfo)
            cursor = collection.find(query)
            for row in cursor:
                try:
                    sendToSearchTool(traverse2(row,userInfo))
                except:
                    pass
                
    index.exposed = True        

def filterCanAdd(x,userInfo):
    #remove type names from list that your user permissions do not allow you to add
    L = []
    db = client[userInfo["database"]]
    collection = db["data"]
    for item in x:
        row = collection.find({"id":int(item)})[0]
        row = traverse2(row,userInfo)
        theName = row.getFieldByName("name")["value"].lower()
        if theName in gPerms.keys():
            if gPerms[theName][userInfo["roleName"]]["add"]:
                L.append(item)
        else:
            L.append(item)
    return L
            

def getAddTypeIds(row,userInfo):
    #get add types for a form
    if row.getFieldByName("Add Types"):
        #if form has an Add Types field use those add types
        #e.g. root nodes in inventory
        x = row.getFieldByName("Add Types")["value"]
        x = filterCanAdd(x,userInfo)
        return x
    else:
        #otherwise use the add types specified on the template
        db = client[userInfo["database"]]
        collection = db["data"]
        row = collection.find({"id":row["typeId"]})[0]
        row = traverse2(row,userInfo)
        x = row.getFieldByName("Add Types")["value"]
        x = filterCanAdd(x,userInfo)
        return x

class GetAllowedChildren():
    def index(self):
        #gets the allowed child types for the object of the specified id
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            #get the object
            row = collection.find({"id":D["id"]})[0]
            row = traverse2(row,userInfo)
            #get the objects name
            if "name" not in row.keys():
                row = collection.find({"id":row["typeId"]})[0]
                row = traverse2(row,userInfo)
            #if we are not a permisiion of folder get the add types for ourselves
            if row["name"].lower() not in ["permission","folder"]:
                return json.dumps(getAddTypeIds(row,userInfo))
            else:
                #if we are a folder or a perm object then we will inherit our permissions
                #from our first parent that has add types
                while "parentId" in row.keys():
                    row = collection.find({"id":row["parentId"]})[0]
                    row = traverse2(row,userInfo)
                    if row["name"].lower() not in ["permission","folder"]:
                        return json.dumps(getAddTypeIds(row,userInfo))
        return json.dumps([])
                        
    index.exposed = True

class IsUnique():
    def index(self):
        #determines if a project code is unique.  Used only for Broad
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            cursor = collection.find({"_sort.project_code":str(int(D["value"])).zfill(4)})
            if cursor.count()>0:
                return json.dumps({"result":False})
            else:
                return json.dumps({"result":True})
                        
    index.exposed = True


class GetFTKeys():
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]

            try:
                query = {"parentId": 351} # magic number 351 is the Data Dict ID
            except:
                pass

            query = makeSearch(query, userInfo)
            # sort rest name
            cursor = collection.find(query).sort([('fields.0.value', 1)])

            #add default fields to list
            L = []
            names = []
            L.append(["Assay Id","Assay Id","number","Assay"])
            L.append(["Object Type Name","Object Type Name","text","Assay"])

            for item in cursor:
                # don't show results in tree
                if "typeId" in item.keys():
                    if userInfo["resultTypeId"] == item["typeId"]:
                        return json.dumps([])
                # default name
                name = "unnamed"
                x = {}
                # set name
                thisType = "text"
                for field in item["fields"]:
                    if "name" in field.keys():
                        if field["name"].lower() in ["name", "assay name", "eln run name"]:
                            x[field["name"].lower()] = field["value"]
                    if "type" in field["name"].lower():
                        if "isNumber" in field["value"] or "isInteger" in field["value"] or "real number" in field["value"]:
                            thisType = "number"
                if "eln run name" in x.keys():
                    name = x["eln run name"]
                else:
                    if "name" in x.keys():
                        name = x["name"]
                    else:
                        if "assay name" in x.keys():
                            name = x["assay name"]

                if name.lower() not in names:
                    L.append([name.replace(".", "").encode('ascii', 'xmlcharrefreplace'), name.replace(".", "").encode('ascii', 'xmlcharrefreplace'), thisType, "Assay"])  # TODO: fix type
                    names.append(name.lower())

            if "protocol name" not in names:
                L.append(["Protocol Name","Protocol Name","text","Assay"])
            if "assay name" not in names:
                L.append(["Assay Name","Assay Name","text","Assay"])
            if "result set name" not in names:
                L.append(["Result Set Name","Result Set Name","text","Assay"])
            if "result set id" not in names:
                L.append(["Result Set Id","Result Set Id","number","Assay"])
            #return the list of fields and the FT permissions from the user's session info
            return json.dumps({"fields":L,"perms":userInfo["ftPerms"]})

    index.exposed = True


class GetFTKeysOLD():
    def index(self):
        #return all fields for FT
        #also return permissions
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        #only logged in users can access
        if userInfo["loggedIn"]:
            db = client[userInfo["database"]]
            collection = db["data"]
            #add default fields to list
            L = []
            L.append(["Assay Id","Assay Id","number","Assay"])
            L.append(["Object Type Name","Object Type Name","text","Assay"])
            names = []
            #get all template forms
            cursor = collection.find({"typeId":1})            
            for row in cursor:
                row = traverse2(row,userInfo)
                for d in traverse(row):
                    if "__pFieldOptions" in d.keys():
                        if "name" in d["__pFieldOptions"].keys() and "type" in d["__pFieldOptions"]:
                            if d["__pFieldOptions"]["name"].lower() == "name" and d["__pFieldOptions"]["type"] != "fieldSet":
                                if d.parent:
                                    if isinstance(d.parent, list):
                                        #we are in a field
                                        v = d["value"]
                                        if v != "":
                                            thisItem = {}
                                            #set field name
                                            thisItem["name"] = v
                                            thisType = "text"
                                            foundType = False
                                            #set field type
                                            for item in d.parent:
                                                if "__pFieldOptions" in item.keys():
                                                    if "name" in item["__pFieldOptions"].keys():
                                                        if item["__pFieldOptions"]["name"] == "validation":
                                                            if "isNumber" in item["value"] or "isInteger" in item["value"]:
                                                                thisType = "number"
                                                        if item["__pFieldOptions"]["name"] == "type":
                                                            foundType = True
                                                            if item["value"] in ["file","hidden","heading"]:
                                                                thisType = "none"
                                            thisItem["type"] = thisType
                                            if "type" in thisItem.keys() and foundType:
                                                if thisItem["type"] != "none":
                                                    if thisItem["name"].lower() not in names:
                                                        L.append([thisItem["name"].replace(".",""),thisItem["name"].replace(".",""),thisItem["type"],"Assay"])
                                                        names.append(thisItem["name"].lower())
            #get all result definitions
            cursor = collection.find({"typeId":1792})            
            for row in cursor:
                thisItem = traverse2(row,userInfo)
                #add type
                thisType = thisItem.getFieldByName("type")["value"]
                if thisType in ["percentage","integer","real number"]:
                    thisType = "number"
                if thisType not in ["date","number","text"]:
                    thisType = "text"
                thisName = thisItem.getFieldByName('name')["value"]
                #add name
                if thisName not in names:
                    L.append([thisName.replace(".",""),thisName.replace(".",""),thisType,"Assay"])
                    names.append(thisName)
            #sort fields alphabetically
            L.sort(key=lambda x: x[1].lower())
            #add default fields if they are not already in list
            if "protocol name" not in names:
                L.append(["Protocol Name","Protocol Name","text","Assay"])
            if "assay name" not in names:
                L.append(["Assay Name","Assay Name","text","Assay"])
            if "result set name" not in names:
                L.append(["Result Set Name","Result Set Name","text","Assay"])
            if "result set id" not in names:
                L.append(["Result Set Id","Result Set Id","number","Assay"])
            #return the list of fields and the FT permissions from the user's session info
            return json.dumps({"fields":L,"perms":userInfo["ftPerms"]})
    index.exposed = True

class Root:
    #define endpoints
    getParentName = GetParentName()
    getParentType = GetParentType()
    getAssayTree = GetAssayTree()
    getProtocolTree = GetProtocolTree()
    getFTKeys = GetFTKeys()
    isLoggedIn = IsLoggedIn()
    getTree = GetTree()	
    elnConnection = ElnConnection()
    getNextId = GetNextId()
    saveForm = SaveForm()
    loadForm = LoadForm()
    loadForms = LoadForms()
    getParentTree = GetParentTree()
    deleteForm = DeleteForm()
    deleteResult = DeleteResult()
    getList = GetList()
    selectOfType = SelectOfType()
    getCBIPNames = GetCBIPNames()
    setHistory = SetHistory()
    getHistory = GetHistory()
    getUserList = GetUserList()
    getUserList2 = GetUserList2()
    nextSequence = NextSequence()
    getNumResults = GetNumResults()
    parseResults = ParseResults()
    getChildIds = GetChildIds()
    getAllowedChildren = GetAllowedChildren()
    loadDunders = LoadDunders()
    isUnique = IsUnique()
    getTabNames = GetTabNames()
    sendDataToFT = SendDataToFT()
    def index(self):
        return ""
    index.exposed = True

cursorCloser = CursorCloser()

if not os.path.exists("session_cache"):
    os.makedirs("session_cache")

#set web service server settings
if __name__ == '__main__':
    if server.upper() == "DEV":
        cherrypy.config.update({'server.socket_port': 5100,
                            'server.socket_host': '10.10.10.16',
                            'response.timeout': 1600000})
    if server.upper() == "BETA":
        cherrypy.config.update({'server.socket_port': 5100,
                            'server.socket_host': '10.10.10.12',
                            'response.timeout': 1600000})
    if server.upper() == "MODEL":
        cherrypy.config.update({'server.socket_port': 5100,
                            'server.socket_host': '10.10.10.15',
                            'response.timeout': 1600000})
    if server.upper() == "PROD":
        cherrypy.config.update({'server.socket_port': 5100,
                            'server.socket_host': '10.10.10.172',
                            'response.timeout': 1600000})
    cherrypy.config.update({
        'global': {
            'engine.autoreload.on': False
        }
    })
    cherrypy.quickstart(Root())
