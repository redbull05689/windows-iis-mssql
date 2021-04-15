class AddEditObjectType:
    def index(self):
        D = json.loads(cherrypy.request.body.read(cherrypy.request.headers['Content-Length']))
        userInfo = getUserInfo(D["connectionId"])
        if userInfo["roleName"] in ["Admin"]:
            errors = []
            db = client[userInfo["database"]]
            #print db
            collection = db["objectTypes"]
            if "id" not in D.keys():
                newId = getNextSequence(db,"objectTypes_seq")
                D2 = {"object":D["object"],"id":newId}
                collection.insert(D2)
            else:
                # This is not a new inventory type
                # First, if the name has name/_invType has changed, it must be updated in the previously created inventory items of this type
                cursor = collection.find({"id":D["id"]})
                for item in cursor:
                    oldInvType = item["object"]["name"]
                    newInvType = D["object"]["name"]
                    # check if _invType has changed & update old Inventory items matching the oldInvType... Need to make sure the user isn't renaming something with a name that precisely matches a hardcoded invType b/c this would have a disastrous effect on the hardcoded containers matching the oldInvType... INV-248
                    if oldInvType <> newInvType and oldInvType not in ["site","partition","tray","inventoryItems","units","inventory","room","shelf","hood","freezer","bench","cabinet","dryBox","bin","refrigerator","bottle","vial","cylinder","tube","box","bag","reagent","lot","preparation","gridBox","building","plate","well","compound","rack","perm","slot","space","tier"]:
                        invItemsCollection = db["inventoryItems"]
                        invItemsCollection.update({'_invType':oldInvType},{"$set":{'_invType':newInvType}},multi=True) # Find and update containers with the oldInvType
                collection.update({"id":D["id"]},{"$set":{"object":D["object"]}},multi=True)
                
            return json.dumps({"errors":errors})
    index.exposed = True  