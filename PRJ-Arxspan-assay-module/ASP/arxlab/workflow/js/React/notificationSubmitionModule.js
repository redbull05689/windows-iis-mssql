var notificationSubmitionModule = (function(){

    // Constants to define the messages and behavior of the duplicate notification notification.
    const DUPLICATE_NOTIFICATION_TITLE = "Duplicate notification settings dectected.";
    const DUPLICATE_NOTIFICATION_MSG = "Please check your current settings.";
    const DUPLICATE_NOTIFICATION_TIMEOUT = 7000;

    var submitNotificationEditor = function (state){

        if (window.CurrentPageMode == 'editRequestTypes')
        {
            submitToDom(state);
        }
        else
        {
            submitToService(state)
        } 
    }

    var submitToService = function (state){
        var requestTypeJSON = window.requestTypesArray.find(x => x.id == state['requestTypeId']);
        var notifications = state['notifications'];
        notifications = removeUnwantedSettings(notifications, state['prossesedNotificationsOriginal']);
        notifications = formatForDB(notifications, state['typeCodes'], state['requestTypeId']);
        var previousNotifications = state['preserveNotifications'];
        previousNotifications = previousNotifications.filter(x => x.overrideUserId != globalUserInfo["userId"])
        var typeLvl1Notifications = [];
        previousNotifications.filter(x => "requestTypeId" in x).map(function(z){
            typeLvl1Notifications.push(z);
        });

        var newNotifications = notifications.filter(x => x['typeLvl'] == 1);


        $.each(newNotifications, function(i, item){
             
            var exists = typeLvl1Notifications.find(x => x.groupId == this.groupId && x.notificationTrigger == this.notificationTrigger && x.overrideUserId == this.overrideUserId && x.requestTypeId == this.requestTypeId )

            if (exists == undefined)
            {
                this['overrideUserId'] = globalUserInfo['userId'];
                this['id'] = 0;
                typeLvl1Notifications.push(this);
            }
            else
            {
                if (exists['overrideUserId'] != null) 
                {
                    $.each(typeLvl1Notifications,function(n, obj)
                    {
                        if(JSON.stringify(this) == JSON.stringify(exists))
                        {
                            obj['notifyByBrowser'] = item['notifyByBrowser'];
                            obj['notifyByEmail'] = item['notifyByEmail'];
                            obj['notifyBySms'] = item['notifyBySms'];
                        }
                    });
                } 
                else 
                {
                    this['overrideUserId'] = globalUserInfo['userId'];
                    this['id'] = 0;
                    typeLvl1Notifications.push(JSON.parse(JSON.stringify(this)));                 
                }
            }
            if (globalUserInfo.userGroups.length > 0)
            {
                if ('userId' in this)
                {
                    var setting = JSON.parse(JSON.stringify(this));
                    delete setting.userId;
                    $.each(globalUserInfo.userGroups, function(i,id){
                        setting["groupId"] = id;
                        typeLvl1Notifications.push(JSON.parse(JSON.stringify(setting)));
                    })
                }
                else if ('groupId' in this)
                {
                    this["userId"] = globalUserInfo.userId;
                    delete this.groupId;
                    typeLvl1Notifications.push(JSON.parse(JSON.stringify(this)));
                }
            }

        });

        typeLvl1Notifications.map(function(y){
            if ('groupId' in y)
            {
                y['userType'] = 1;
            }
            else if ('userId' in y)
            {
                y['userType'] = 2;
            }
            else if ('userType' in y)
            {
                y['userType'] = 3;
            }
        });

        var t1NoteStr = requestTypeNotificationGrouping(typeLvl1Notifications);

        $.each(t1NoteStr, function(key, item){

            requestTypeJSON[key] = utilities().parseJsons(item.split("|||"));

        });




        var typeLvl2Notifications = [];
        previousNotifications.filter(x => "requestTypeFieldId" in x).map(function(z){
            typeLvl2Notifications.push(z);
        });
   
        var newNotifications = notifications.filter(x => x['typeLvl'] == 2);

        $.each(newNotifications, function(i, item){
             
            var exists = typeLvl2Notifications.find(x => x.groupId == this.groupId  && x.notificationTrigger == this.notificationTrigger && x.overrideUserId == this.overrideUserId && x.requestTypeId == this.requestTypeId )

            if (exists == undefined)
            {
                this['overrideUserId'] = globalUserInfo['userId'];
                this['id'] = 0;
                typeLvl2Notifications.push(this);
            }
            else
            {
                if (exists['overrideUserId'] != null) 
                {
                    $.each(typeLvl2Notifications,function(n, obj)
                    {
                        if(JSON.stringify(this) == JSON.stringify(exists))
                        {
                            obj['notifyByBrowser'] = item['notifyByBrowser'];
                            obj['notifyByEmail'] = item['notifyByEmail'];
                            obj['notifyBySms'] = item['notifyBySms'];
                        }
                    });
                } 
                else 
                {
                    this['overrideUserId'] = globalUserInfo['userId'];
                    this['id'] = 0;
                    typeLvl2Notifications.push(JSON.parse(JSON.stringify(this)));
                }
            }

            if (globalUserInfo.userGroups.length > 0)
            {
                if ('userId' in this)
                {
                    var setting = JSON.parse(JSON.stringify(this));
                    delete setting.userId;
                    $.each(globalUserInfo.userGroups, function(i,id){
                        setting["groupId"] = id;
                        typeLvl2Notifications.push(JSON.parse(JSON.stringify(setting)));
                    })
                }
                else if ('groupId' in this)
                {
                    this["userId"] = globalUserInfo.userId;
                    delete this.groupId;
                    typeLvl2Notifications.push(JSON.parse(JSON.stringify(this)));
                }
            }

        });



        typeLvl2Notifications.map(function(y){
            if ('groupId' in y)
            {
                y['userType'] = 1;
            }
            else if ('userId' in y)
            {
                y['userType'] = 2;
            }
            else if ('userType' in y)
            {
                y['userType'] = 3;
            }
        });

        var fieldsAsList = [];
        $.each(requestTypeJSON['fields'],function(){
            var hit = fieldsAsList.find(x => x.requestTypeFieldId == this.requestTypeFieldId);
            if (hit == undefined)
            {
                fieldsAsList.push(this);
            }
        
        });
        requestTypeJSON['fields'] = fieldsAsList;

        var t2NoteStr = requestTypeFieldNotificationGrouping(typeLvl2Notifications, requestTypeJSON);

        $.each(t2NoteStr, function(key, item){
            $.each(item,function(k,i){
                requestTypeJSON['fields'].find(x => x['requestTypeFieldId'] == parseInt(k))[key] = utilities().parseJsons(i.split("|||"));
            });
        });





        var typeLvl3Notifications = [];
        previousNotifications.filter(x => "requestTypeItemId" in x && !("requestItemTypeFieldId" in x)).map(function(z){
            typeLvl3Notifications.push(z);
        });
     
        var newNotifications = notifications.filter(x => x['typeLvl'] == 3);

        $.each(newNotifications, function(i, item){
             
            var exists = typeLvl3Notifications.find(x => x.groupId == this.groupId  && x.notificationTrigger == this.notificationTrigger && x.overrideUserId == this.overrideUserId && x.requestTypeId == this.requestTypeId )

            if (exists == undefined)
            {
                this['overrideUserId'] = globalUserInfo['userId'];
                this['id'] = 0;
                typeLvl3Notifications.push(this);
            }
            else
            {
                if (exists['overrideUserId'] != null) 
                {
                    $.each(typeLvl3Notifications,function(n, obj)
                    {
                        if(JSON.stringify(this) == JSON.stringify(exists))
                        {
                            obj['notifyByBrowser'] = item['notifyByBrowser'];
                            obj['notifyByEmail'] = item['notifyByEmail'];
                            obj['notifyBySms'] = item['notifyBySms'];
                        }
                    });
                } 
                else 
                {
                    this['overrideUserId'] = globalUserInfo['userId'];
                    this['id'] = 0;
                    typeLvl3Notifications.push(JSON.parse(JSON.stringify(this)));
                }
            }

            if (globalUserInfo.userGroups.length > 0)
            {
                if ('userId' in this)
                {
                    var setting = JSON.parse(JSON.stringify(this));
                    delete setting.userId;
                    $.each(globalUserInfo.userGroups, function(i,id){
                        setting["groupId"] = id;
                        typeLvl3Notifications.push(JSON.parse(JSON.stringify(setting)));
                    })
                }
                else if ('groupId' in this)
                {
                    this["userId"] = globalUserInfo.userId;
                    delete this.groupId;
                    typeLvl3Notifications.push(JSON.parse(JSON.stringify(this)));
                }
            }
        });



        typeLvl3Notifications.map(function(y){
            if ('groupId' in y)
            {
                y['userType'] = 1;
            }
            else if ('userId' in y)
            {
                y['userType'] = 2;
            }
            else if ('userType' in y)
            {
                y['userType'] = 3;
            }
        });
        var t3NoteStr = requestItemTypeNotificationGrouping(typeLvl3Notifications, requestTypeJSON);

        $.each(t3NoteStr, function(key, item){
            $.each(item,function(k,i){
                requestTypeJSON['requestItemTypes'].find(x => x['requestItemId'] == parseInt(k))[key] = utilities().parseJsons(i.split("|||"));
            });
        });




        var typeLvl4Notifications = [];
        previousNotifications.filter(x => "requestItemTypeFieldId" in x).map(function(z){
            typeLvl4Notifications.push(z);
        });

        var newNotifications = notifications.filter(x => x['typeLvl'] == 4);

        $.each(newNotifications, function(i, item){
             
            var exists = typeLvl4Notifications.find(x => x.groupId == this.groupId  && x.notificationTrigger == this.notificationTrigger && x.overrideUserId == this.overrideUserId && x.requestTypeId == this.requestTypeId )

            if (exists == undefined)
            {
                this['overrideUserId'] = globalUserInfo['userId'];
                this['id'] = 0;
                typeLvl4Notifications.push(this);
            }
            else
            {
                if (exists['overrideUserId'] != null) 
                {
                    $.each(typeLvl4Notifications,function(n, obj)
                    {
                        if(JSON.stringify(this) == JSON.stringify(exists))
                        {
                            obj['notifyByBrowser'] = item['notifyByBrowser'];
                            obj['notifyByEmail'] = item['notifyByEmail'];
                            obj['notifyBySms'] = item['notifyBySms'];
                        }
                    });
                } 
                else 
                {
                    this['overrideUserId'] = globalUserInfo['userId'];
                    this['id'] = 0;
                    typeLvl4Notifications.push(JSON.parse(JSON.stringify(this)));
                }
            }
            
            if (globalUserInfo.userGroups.length > 0)
            {
                if ('userId' in this)
                {
                    var setting = JSON.parse(JSON.stringify(this));
                    delete setting.userId;
                    $.each(globalUserInfo.userGroups, function(i,id){
                        setting["groupId"] = id;
                        typeLvl4Notifications.push(JSON.parse(JSON.stringify(setting)));
                    })
                }
                else if ('groupId' in this)
                {
                    this["userId"] = globalUserInfo.userId;
                    delete this.groupId;
                    typeLvl4Notifications.push(JSON.parse(JSON.stringify(this)));
                }
            }

        });



        typeLvl4Notifications.map(function(y){
            if ('groupId' in y)
            {
                y['userType'] = 1;
            }
            else if ('userId' in y)
            {
                y['userType'] = 2;
            }
            else if ('userType' in y)
            {
                y['userType'] = 3;
            }
        });
        var t4NoteStr = requestItemTypeFieldNotificationGrouping(typeLvl4Notifications, requestTypeJSON);

        $.each(t4NoteStr, function(key, item){
            $.each(item,function(k,i){
                requestTypeJSON['requestItemTypes'].find(x => x['requestItemId'] == parseInt(k))[key] = utilities().parseJsons(i.split("|||"));
            });
        });



        requestTypeJSON['requestTypePermissions'] = [];

        requestTypeJSON['requestTypePermissions'] = requestTypeJSON['requestTypePermissions'].concat(requestTypeJSON['allowedGroups']);
        requestTypeJSON['requestTypePermissions'] = requestTypeJSON['requestTypePermissions'].concat(requestTypeJSON['allowedUsers']);

        requestTypeJSON['requestTypeFields'] = requestTypeJSON['fields'];
        $.each(requestTypeJSON['requestTypeFields'], function(){

            this['id'] = this['requestTypeFieldId'];
            this['fieldId'] = this['savedFieldId'];
            
            //Build requestTypeFieldsPermissions for each field
            var fieldPermArray = [];
            if (this.allowedUsers) {
                $.each(this.allowedUsers, function(userIndex, allowedUser) {
                    var thisPerm = {
                        "requestTypeFieldId": requestTypeJSON.id,
                        "allowedUserId": allowedUser["userId"],
                        "allowedGroupId": null,
                        "canAdd": utilities().boolToInt(allowedUser["canAdd"]),
                        "canEdit": utilities().boolToInt(allowedUser["canEdit"]),
                        "canView": utilities().boolToInt(allowedUser["canView"]),
                        "canDelete": utilities().boolToInt(allowedUser["canDelete"]),
                        "onlyNotifyRequestor": 0
                    }
                    fieldPermArray.push(thisPerm);
                });
            }

            if (this.allowedGroups) {
                $.each(this.allowedGroups, function(userIndex, allowedGroup) {
                    var thisPerm = {
                        "requestTypeFieldId": requestTypeJSON.id,
                        "allowedUserId": null,
                        "allowedGroupId": allowedGroup["groupId"],
                        "canAdd": utilities().boolToInt(allowedGroup["canAdd"]),
                        "canEdit": utilities().boolToInt(allowedGroup["canEdit"]),
                        "canView": utilities().boolToInt(allowedGroup["canView"]),
                        "canDelete": utilities().boolToInt(allowedGroup["canDelete"])
                    }
                    fieldPermArray.push(thisPerm);
                });
            }
            this['requestTypeFieldsPermissions'] = fieldPermArray;
        });

        requestTypeJSON['requestTypeItems'] = requestTypeJSON['requestItemTypes'];
        $.each(requestTypeJSON['requestTypeItems'], function(){

            this['id'] = this['requestItemId'];
                      
        });


        delete requestTypeJSON["fields"];
        delete requestTypeJSON["requestItemTypes"];
        delete requestTypeJSON["allowedGroups"];
        delete requestTypeJSON["allowedUsers"];
        delete requestTypeJSON["canAdd"];
        delete requestTypeJSON["canBeAssigned"];
        delete requestTypeJSON["canDelete"];
        delete requestTypeJSON["canEdit"];
        delete requestTypeJSON["canView"];
        delete requestTypeJSON["fieldsDict"];
        delete requestTypeJSON["onlyNotifyRequestor"];

        console.log(requestTypeJSON);

        var data = {
            "userId": globalUserInfo.userId,
            "connectionId": connectionId,
            "defaultLevel": "Company",
            "requestType": requestTypeJSON,
            "appName": "Configuration"
        }
        
        
        var serviceObj = {
            configService: true,
        };
        utilities().makeAjaxPost("/requesttypes/upsert", data, serviceObj).then(function(response) {
            console.log(response);

			var requestTypeParams = {
                requestTypeId: parseInt(state["requestTypeId"]),
				includeDisabled: true,
				isConfigPage: true,
				appName: "Configuration",
				asOfDate: utilities().getDateForService()
            };
            
            ajaxModule().getRequestTypes(requestTypeParams).then(function(response) {
                response = utilities().decodeServiceResponce(response);
                window.requestTypesArray = window.requestTypesArray.map(obj => response.find(x => x.id == obj.id) || obj);
                console.log(response);

            });

            $('#notificationEditorModal').modal().hide();
            $('.modal-backdrop').hide();
            ReactDOM.unmountComponentAtNode(document.getElementById("requestTypeNotificationUserSettings"));
        }); 
        
        console.log(state);

    }

    /**
     * Take the notification state and add it to the dom for later submission. 
     * @param {JSON} state The state object from the notification editor. 
     */
    var submitToDom = function (state){
        var notifications = [];
        // Strip out duplicate notifications
        state.notifications.forEach( item => {
            if (notifications.length == 0) {
                notifications.push(item);
            }
            else {
                var found = notifications.find(
                    x => x.whoId == item.whoId &&
                        x.userType == item.userType &&
                        x.notificationTrigger == item.notificationTrigger &&
                        x.fieldId == item.fieldId &&
                        x.typeLvl == item.typeLvl &&
                        x.overrideUserId == item.overrideUserId
                );
                if (!found) {
                    notifications.push(item);
                }
            }
        });

        // If our final list of notifications is different than the list going in, then we had
        // duplicates, so tell the user and terminate the function.
        if (notifications.length != state.notifications.length) {
            $.notify({
                title: DUPLICATE_NOTIFICATION_TITLE,
                message: DUPLICATE_NOTIFICATION_MSG,
            }, {
                delay: DUPLICATE_NOTIFICATION_TIMEOUT,
                type: "yellowNotification",
                template: utilities().notifyJSTemplates.default,
            });

            return;
        }

        notifications = formatForDB(notifications, state['typeCodes'], state['requestTypeId']);
        notifications = notifications.concat(prossesUserTypesAndLevels(state['preserveNotifications']));

        var typeLvl1Notifications = notifications.filter(x => x['typeLvl'] == 1);
        
        var t1NoteStr = requestTypeNotificationGrouping(typeLvl1Notifications);

        $.each(t1NoteStr, function(key, item){

            $('#configRequestNotifications').attr(key, item);

        });

        var typeLvl2Notifications = notifications.filter(x => x['typeLvl'] == 2)
        var t2NoteStr = requestTypeFieldNotificationGrouping(typeLvl2Notifications);

        $.each(t2NoteStr, function(key, item){
            $.each(item,function(k,i){
                $(`tr[requesttypefieldid="${k}"]`).attr(key,i)
            });
        });


        var typeLvl3Notifications = notifications.filter(x => x['typeLvl'] == 3)
        var t3NoteStr = requestItemTypeNotificationGrouping(typeLvl3Notifications);

        $.each(t3NoteStr, function(key, item){
            $.each(item,function(k,i){
                $(`tr[requestitemid="${k}"]`).attr(key,i)
            });
        });


        var typeLvl4Notifications = notifications.filter(x => x['typeLvl'] == 4)
        var t4NoteStr = requestItemTypeFieldNotificationGrouping(typeLvl4Notifications);

        $.each(t4NoteStr, function(key, item){
            $.each(item,function(k,i){
                $(`tr[requestitemid="${k}"]`).attr(key,i)
            });
        });

        utilities().showUnsavedChangesNotification();
        $('#notificationEditorModal').modal().hide();
        $('.modal-backdrop').hide();
        ReactDOM.unmountComponentAtNode(document.getElementById("reactTest"));

    }

    var requestTypeNotificationGrouping = function(notifications){
        var t1NoteStr = {		
            requestTypeNotificationGroupSettings: "", 
            requestTypeNotificationUserSettings: "",
            requestTypeNotificationOtherUserSettings: ""
        };
        $.each(notifications, function(i,item){
            if (item['userType'] == 1)
            {
                if (t1NoteStr["requestTypeNotificationGroupSettings"] == "")
                {
                    delete item["userType"];
                    delete item["typeLvl"];
                    t1NoteStr["requestTypeNotificationGroupSettings"] = JSON.stringify(item);
                }
                else 
                {
                    delete item["userType"];
                    delete item["typeLvl"];
                    t1NoteStr["requestTypeNotificationGroupSettings"] += "|||" + JSON.stringify(item);
                }
            }
            else if (item['userType'] == 2)
            {
                if (t1NoteStr["requestTypeNotificationUserSettings"] == "")
                {
                    delete item["userType"];
                    delete item["typeLvl"];
                    t1NoteStr["requestTypeNotificationUserSettings"] = JSON.stringify(item);
                }
                else 
                {
                    delete item["userType"];
                    delete item["typeLvl"];
                    t1NoteStr["requestTypeNotificationUserSettings"] += "|||" + JSON.stringify(item);
                }
            }
            else if (item['userType'] == 3)
            {
                if (t1NoteStr["requestTypeNotificationOtherUserSettings"] == "")
                {
                    delete item["typeLvl"];
                    t1NoteStr["requestTypeNotificationOtherUserSettings"] = JSON.stringify(item);
                }
                else 
                {
                    delete item["typeLvl"];
                    t1NoteStr["requestTypeNotificationOtherUserSettings"] += "|||" + JSON.stringify(item);
                }
            }
        });

        return (t1NoteStr)

    }

    var requestTypeFieldNotificationGrouping = function(notifications, requestJSON = null){
        var t2NoteStr = {
            requestTypeFieldNotificationGroupSettings: {}, 
            requestTypeFieldNotificationUserSettings: {},
            requestTypeFieldNotificationOtherUserSettings: {}
        };

        if (requestJSON == null)
        {
            var fields = $('#requestTypeFieldsTable > tbody > tr')
        }
        else 
        {
            var fields = requestJSON['fields'];
        }

        $.each(notifications, function(i,item){

            if (item['userType'] == 1)
            {
                if (t2NoteStr["requestTypeFieldNotificationGroupSettings"][item['requestTypeFieldId']] == undefined)
                {
                    t2NoteStr["requestTypeFieldNotificationGroupSettings"][item['requestTypeFieldId']] = JSON.stringify(item);
                }
                else 
                {
                    t2NoteStr["requestTypeFieldNotificationGroupSettings"][item['requestTypeFieldId']] += "|||" + JSON.stringify(item);
                }
            }
            if (item['userType'] == 2)
            {
                if (t2NoteStr["requestTypeFieldNotificationUserSettings"][item['requestTypeFieldId']] == undefined)
                {
                    t2NoteStr["requestTypeFieldNotificationUserSettings"][item['requestTypeFieldId']] = JSON.stringify(item);
                }
                else 
                {
                    t2NoteStr["requestTypeFieldNotificationUserSettings"][item['requestTypeFieldId']] += "|||" + JSON.stringify(item);
                }
            }
            if (item['userType'] == 3)
            {
                if (t2NoteStr["requestTypeFieldNotificationOtherUserSettings"][item['requestTypeFieldId']] == undefined)
                {
                    t2NoteStr["requestTypeFieldNotificationOtherUserSettings"][item['requestTypeFieldId']] = JSON.stringify(item);
                }
                else 
                {
                    t2NoteStr["requestTypeFieldNotificationOtherUserSettings"][item['requestTypeFieldId']] += "|||" + JSON.stringify(item);
                }
            }

        });

        $.each(t2NoteStr,function(Key, item)
        {

            fields.map(function(x){
                if (requestJSON == null)
                {
                    if(!($(this).attr('requesttypefieldid') in item))
                    {
                        t2NoteStr[Key][$(this).attr('requesttypefieldid')] = "null"
                    }
                }
                else
                {
                    if(!(x['requestTypeFieldId'] in item))
                    {
                        t2NoteStr[Key][x['requestTypeFieldId']] = "null"
                    }
                }

            });
        });

        return t2NoteStr;

    }

    var requestItemTypeNotificationGrouping = function(notifications, requestJSON = null){
        var t3NoteStr = {
            requestTypeItemNotificationGroupSettings: {}, 
            requestTypeItemNotificationUserSettings: {},
            requestTypeItemNotificationOtherUserSettings: {}
        };

        if (requestJSON == null)
        {
            var itemTypes = $('#requestTypeRequestItemTypesTable > tbody > tr');
        }
        else 
        {
            var itemTypes = requestJSON["requestItemTypes"];
        }

        $.each(notifications, function(i,item){
            if (item['userType'] == 1)
            {
                if (t3NoteStr["requestTypeItemNotificationGroupSettings"][item['requestTypeItemId']] == undefined)
                {
                    t3NoteStr["requestTypeItemNotificationGroupSettings"][item['requestTypeItemId']] = JSON.stringify(item);
                }
                else 
                {
                    t3NoteStr["requestTypeItemNotificationGroupSettings"][item['requestTypeItemId']] += "|||" + JSON.stringify(item);
                }
            }
            if (item['userType'] == 2)
            {
                if (t3NoteStr["requestTypeItemNotificationUserSettings"][item['requestTypeItemId']] == undefined)
                {
                    t3NoteStr["requestTypeItemNotificationUserSettings"][item['requestTypeItemId']] = JSON.stringify(item);
                }
                else 
                {
                    t3NoteStr["requestTypeItemNotificationUserSettings"][item['requestTypeItemId']] += "|||" + JSON.stringify(item);
                }
            }
            if (item['userType'] == 3)
            {
                if (t3NoteStr["requestTypeItemNotificationOtherUserSettings"][item['requestTypeItemId']] == undefined)
                {
                    t3NoteStr["requestTypeItemNotificationOtherUserSettings"][item['requestTypeItemId']] = JSON.stringify(item);
                }
                else 
                {
                    t3NoteStr["requestTypeItemNotificationOtherUserSettings"][item['requestTypeItemId']] += "|||" + JSON.stringify(item);
                }
            }

        });

        $.each(t3NoteStr,function(Key, item)
        {

            itemTypes.map(function(x){
                if(requestJSON == null)
                {   
                    if(!($(this).attr('requestitemid') in item))
                    {
                        t3NoteStr[Key][$(this).attr('requestitemid')] = "null";
                    }
                }
                else 
                {
                    if(!(x['requestItemId'] in item))
                    {
                        t3NoteStr[Key][x['requestItemId']] = "null";
                    }
                }
            });
        });

        return t3NoteStr;
    }
    
    var requestItemTypeFieldNotificationGrouping = function(notifications, requestJSON = null){
    
        var t4NoteStr = {
            requestTypeItemFieldNotificationGroupSettings: {}, 
            requestTypeItemFieldNotificationUserSettings: {},
            requestTypeItemFieldNotificationOtherUserSettings: {}
        };
        
        if (requestJSON == null)
        {
            var itemTypes = $('#requestTypeRequestItemTypesTable > tbody > tr');
        }
        else 
        {
            var itemTypes = requestJSON["requestItemTypes"];
        }


        $.each(notifications, function(i,item){
            if (item['userType'] == 1)
            {
                if (t4NoteStr["requestTypeItemFieldNotificationGroupSettings"][item['requestTypeItemId']] == undefined)
                {
                    t4NoteStr["requestTypeItemFieldNotificationGroupSettings"][item['requestTypeItemId']] = JSON.stringify(item);
                }
                else 
                {
                    t4NoteStr["requestTypeItemFieldNotificationGroupSettings"][item['requestTypeItemId']] += "|||" + JSON.stringify(item);
                }
            }
            if (item['userType'] == 2)
            {
                if (t4NoteStr["requestTypeItemFieldNotificationUserSettings"][item['requestTypeItemId']] == undefined)
                {
                    t4NoteStr["requestTypeItemFieldNotificationUserSettings"][item['requestTypeItemId']] = JSON.stringify(item);
                }
                else 
                {
                    t4NoteStr["requestTypeItemFieldNotificationUserSettings"][item['requestTypeItemId']] += "|||" + JSON.stringify(item);
                }
            }
            if (item['userType'] == 3)
            {
                if (t4NoteStr["requestTypeItemFieldNotificationOtherUserSettings"][item['requestTypeItemId']] == undefined)
                {
                    t4NoteStr["requestTypeItemFieldNotificationOtherUserSettings"][item['requestTypeItemId']] = JSON.stringify(item);
                }
                else 
                {
                    t4NoteStr["requestTypeItemFieldNotificationOtherUserSettings"][item['requestTypeItemId']] += "|||" + JSON.stringify(item);
                }
            }

        });

        $.each(t4NoteStr,function(Key, item)
        {

            itemTypes.map(function(x){
                                
                if(requestJSON == null)
                {   
                    if(!($(this).attr('requestitemid') in item))
                    {
                        t4NoteStr[Key][$(this).attr('requestitemid')] = "null";
                    }
                }
                else 
                {
                    if(!(x['requestItemId'] in item))
                    {
                        t4NoteStr[Key][x['requestItemId']] = "null";
                    }
                }

            });
        });

        return t4NoteStr;

    }



    var formatForDB = function (notifications, typeCodes, requestTypeId)
    {
        var tempNotifications = []
        $.each(notifications, function(i,item){
        
            var temp = {};
            if("id" in item)
            {
                temp['id'] = item['id'];
            }

            if(item['userType'] == 1)
            {
                temp['groupId'] = item['whoId'];
            }
            else if(item['userType'] == 2)
            {
                temp['userId'] = item['whoId'];
            }
            else if(item['userType'] == 3)
            {
                temp['userType'] = 2
            }

            temp['notificationTrigger'] = item['notificationTrigger'];
            temp['typeLvl'] = item['typeLvl'];
            temp['userType'] = item['userType'];

            if ('overrideUserId' in item)
            {
                temp['overrideUserId'] = item['overrideUserId'];
            }
            else
            {
                temp['overrideUserId'] = null;
            }

            if(item['typeLvl'] == 1)
            {
                temp['requestTypeId'] = parseInt(requestTypeId);
            }
            else if (item['typeLvl'] == 2)
            {
                if (item['fieldId'] == -1)
                {
                    return
                }
                temp['requestTypeFieldId'] = item['fieldId'];
            }
            else if (item['typeLvl'] == 3)
            {
                if (item['fieldId'] == -1)
                {
                    return
                }
                temp['requestTypeItemId'] = item['fieldId'];
            }
            else if (item['typeLvl'] == 4)
            {
                if (item['fieldId'] == -1)
                {
                    return
                }
                temp['requestItemTypeFieldId'] = item['fieldId'];
                temp['requestTypeItemId'] = item['requestTypeItemId'];
            }


            temp["notifyByBrowser"] = item["Browser"];
            temp["notifyByEmail"] = item["Email"];    
            temp["notifyBySms"] = false;

            



            tempNotifications.push(JSON.parse(JSON.stringify(temp)));
                
            

        });
        return(tempNotifications)
    }

    var prossesUserTypesAndLevels = function(notifications)
    {
        notifications.map(function(y){
            if ('groupId' in y)
            {
                y['userType'] = 1;
            }
            else if ('userId' in y)
            {
                y['userType'] = 2;
            }
            else if ('userType' in y)
            {
                y['userType'] = 3;
            }

            if ("requestTypeId" in y)
            {
                y['typeLvl'] = 1;
            }
            else if ("requestTypeFieldId" in y)
            {
                y['typeLvl'] = 2;
               
            }
            else if ("requestTypeItemId" in y && !("requestItemTypeFieldId" in y))
            {
                y['typeLvl'] = 3;
                
            }
            else if ("requestItemTypeFieldId" in y)
            {
                y['typeLvl'] = 4;
            }

        });
        return notifications;
    }

    var removeUnwantedSettings = function(notifications, originalNotifications){

        originalNotifications = originalNotifications.filter(x=>x.overrideUserId == null);
        originalNotifications = notificationLoadingModule().whatMattersToMe(originalNotifications);
        var retOBJ = [];
        notifications.map(function(N){
            if (N.userType == 3)
            {
            	var OG = originalNotifications.find(x => x.notificationTrigger == N.notificationTrigger && x.typeLvl == N.typeLvl && x.fieldId == N.fieldId && x.userType == N.userType)
            }
			else
            {
				var OG = originalNotifications.find(x => x.notificationTrigger == N.notificationTrigger && x.typeLvl == N.typeLvl && x.fieldId == N.fieldId && x.userType != 3)
            }
			if (OG != undefined)
            {
				if (N.Email != OG.Email || N.Browser != OG.Email)
                {
					retOBJ.push(N);
                }
			}
            else 
            {
                if (N.Browser == true || N.Email == true)
                {
                    retOBJ.push(N);
                }
            }
        })

        console.log(notifications, originalNotifications)
        return (retOBJ)

    }

    return {
        submitNotificationEditor : submitNotificationEditor
    } 

});