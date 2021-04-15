var notificationLoadingModule = (function(){
    var whatMattersToMe = function(notifications)
    {
        var tempNotifications = [];
        if (notifications.length > 0)
        {
            notifications.filter(x => x.whoId == globalUserInfo['userId'] && x.overrideUserId == null).map(function(y){
                tempNotifications.push(y);
            })
            
            $.each(globalUserInfo["userGroups"], function(index, groupId)
            {
                notifications.filter(x => x.whoId == groupId  && x.overrideUserId == null).map(function(y){
                    tempNotifications.push(y);
                });
            });

            notifications.filter(x => x.userType == 3 && x.overrideUserId == null).map(function(y){
                tempNotifications.push(y);
            });


            var myOverreids = notifications.filter(x => x.overrideUserId == globalUserInfo['userId'])


            tempNotifications = tempNotifications.map(obj => myOverreids.find(x => x.fieldId == obj.fieldId && x.notificationTrigger == obj.notificationTrigger && x.typeLvl == obj.typeLvl && x.userType == obj.userType&& x.whoId == obj.whoId) || obj);
            myOverreids.map(function(x){if(tempNotifications.find(z => JSON.stringify(z) == JSON.stringify(x)) == undefined){tempNotifications.push(x)}});
           

            var blank = {
                id: 0,
                whoId: -1,
                userType: -1,
                notificationTrigger: -1,
                typeLvl: -1,
                fieldId: -1,
                }
         
            tempNotifications.push(JSON.parse(JSON.stringify(blank)));

            notifications = tempNotifications;
        }
        return notifications;
    }

    var removeUserSettings = function(notifications, retUserSettings)
    {
        var userSettings = [];
        var originalSettings = [];
        $.each(notifications, function(){

            if (this['overrideUserId'] == null)
            {
                originalSettings.push(this);  
            }
            else 
            {
                userSettings.push(this);  
            }

        });

        if (retUserSettings == true)
        {
            return(userSettings);
        }
        else
        {
            return(originalSettings);
        } 

    }

    var getNotificationsForTableFromDOM = function (requestType)
    {

        var notifications = {
            requestTypeNotificationGroupSettings: [],
            requestTypeNotificationUserSettings: [],
            requestTypeNotificationOtherUserSettings: [],
            requestTypeFieldNotificationGroupSettings: [],
            requestTypeFieldNotificationUserSettings : [],
            requestTypeFieldNotificationOtherUserSettings : [],
            requestTypeItemFieldNotificationGroupSettings : [],
            requestTypeItemFieldNotificationUserSettings : [],
            requestTypeItemFieldNotificationOtherUserSettings : [],
            requestTypeItemNotificationGroupSettings : [],
            requestTypeItemNotificationUserSettings : [],
            requestTypeItemNotificationOtherUserSettings : [],
        };

        if ($('#configRequestNotifications').attr('requestTypeNotificationGroupSettings') != "null")
        {
            notifications['requestTypeNotificationGroupSettings'] = $('#configRequestNotifications').attr('requestTypeNotificationGroupSettings').split("|||");
        }
        if ($('#configRequestNotifications').attr('requestTypeNotificationUserSettings') != "null")
        {
            notifications['requestTypeNotificationUserSettings'] = $('#configRequestNotifications').attr('requestTypeNotificationUserSettings').split("|||");
        }
        if ($('#configRequestNotifications').attr('requestTypeNotificationOtherUserSettings') != "null")
        {
            notifications['requestTypeNotificationOtherUserSettings'] = $('#configRequestNotifications').attr('requestTypeNotificationOtherUserSettings').split("|||");
        }
        

        
        var fieldRows = $('#requestTypeFieldsTable > tbody > tr');

        $.each(fieldRows, function(i, item){
            var settings = $(item).attr("requestTypeFieldNotificationGroupSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeFieldNotificationGroupSettings'].push(x);
                });
            }

            var settings = $(item).attr("requestTypeFieldNotificationUserSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeFieldNotificationUserSettings'].push(x);
                });
            }
            
            var settings = $(item).attr("requestTypeFieldNotificationOtherUserSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeFieldNotificationOtherUserSettings'].push(x);
                });
            }

        }); 

        var itemRows = $('#requestTypeRequestItemTypesTable > tbody > tr');
        $.each(itemRows, function(i, item){
            var settings = $(item).attr("requestTypeItemFieldNotificationGroupSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeItemFieldNotificationGroupSettings'].push(x);
                });
            }

            var settings = $(item).attr("requestTypeItemFieldNotificationUserSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeItemFieldNotificationUserSettings'].push(x);
                });
            }
            
            var settings = $(item).attr("requestTypeItemFieldNotificationOtherUserSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeItemFieldNotificationOtherUserSettings'].push(x);
                });
            }

            var settings = $(item).attr("requestTypeItemNotificationGroupSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeItemNotificationGroupSettings'].push(x);
                });
            }

            var settings = $(item).attr("requestTypeItemNotificationUserSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeItemNotificationUserSettings'].push(x);
                });
            }

            var settings = $(item).attr("requestTypeItemNotificationOtherUserSettings");
            if(settings != "null" && settings != undefined)
            {
                var temp = settings.split("|||");
                temp.map(function(x){
                    notifications['requestTypeItemNotificationOtherUserSettings'].push(x);
                });
            }

        }); 

        var tempNotifications = [];

        $.each(notifications, function(key, item)
        {
            $.each(item,function(index,str)
            {
                if (str != "")
                {
                    tempNotifications.push(JSON.parse(str));
                } 
            });
        });

        notifications = tempNotifications;

        return (notifications)

    }


    var getNotificationsForTableFromJSON = function(requestType){


        var notifications = {};

        notifications["requestTypeNotificationGroupSettings"] = requestType["requestTypeNotificationGroupSettings"];
        notifications["requestTypeNotificationOtherUserSettings"] = requestType["requestTypeNotificationOtherUserSettings"];
        notifications["requestTypeNotificationUserSettings"] = requestType["requestTypeNotificationUserSettings"];

        var requestTypeFields = requestType["fields"];

        var fieldGroupSettings = requestTypeFields.map(function(x){
            return(x["requestTypeFieldNotificationGroupSettings"])
        }).filter(function(y) {
            if (y.length == 0) {
                return false; // skip
            }
            return true;
        });

        notifications["requestTypeFieldNotificationGroupSettings"] = [];
        $.each(fieldGroupSettings, function(){
             
            var exists = notifications["requestTypeFieldNotificationGroupSettings"].find(x => JSON.stringify(x) === JSON.stringify(this))

            if (exists == undefined)
            {
                notifications["requestTypeFieldNotificationGroupSettings"].push(this);
            }

        });

        var fieldGroupSettings = requestTypeFields.map(function(x){
            return(x["requestTypeFieldNotificationOtherUserSettings"])
        }).filter(function(y) {
            if (y.length == 0) {
                return false; // skip
            }
            return true;
        });
        notifications["requestTypeFieldNotificationOtherUserSettings"] = [];
        $.each(fieldGroupSettings, function(){
             
            var exists = notifications["requestTypeFieldNotificationOtherUserSettings"].find(x => JSON.stringify(x) === JSON.stringify(this))

            if (exists == undefined)
            {
                notifications["requestTypeFieldNotificationOtherUserSettings"].push(this);
            }

        });

        
        var fieldGroupSettings = requestTypeFields.map(function(x){
            return(x["requestTypeFieldNotificationUserSettings"])
        }).filter(function(y) {
            if (y.length == 0) {
                return false; // skip
            }
            return true;
        });
        notifications["requestTypeFieldNotificationUserSettings"] = []

        $.each(fieldGroupSettings, function(){
             
            var exists = notifications["requestTypeFieldNotificationUserSettings"].find(x => JSON.stringify(x) === JSON.stringify(this))

            if (exists == undefined)
            {
                notifications["requestTypeFieldNotificationUserSettings"].push(this);
            }

        });


        notifications["requestTypeItemFieldNotificationGroupSettings"] = [];
        notifications["requestTypeItemFieldNotificationOtherUserSettings"] = [];
        notifications["requestTypeItemFieldNotificationUserSettings"] = [];
        notifications["requestTypeItemNotificationGroupSettings"] = [];
        notifications["requestTypeItemNotificationOtherUserSettings"] = [];
        notifications["requestTypeItemNotificationUserSettings"] = [];

        $.each(requestType["requestItemTypes"], function(index, Item){

            //concat
            notifications["requestTypeItemFieldNotificationGroupSettings"] = notifications["requestTypeItemFieldNotificationGroupSettings"].concat(Item["requestTypeItemFieldNotificationGroupSettings"]);
            notifications["requestTypeItemFieldNotificationOtherUserSettings"] = notifications["requestTypeItemFieldNotificationOtherUserSettings"].concat(Item["requestTypeItemFieldNotificationOtherUserSettings"]);
            notifications["requestTypeItemFieldNotificationUserSettings"] = notifications["requestTypeItemFieldNotificationUserSettings"].concat(Item["requestTypeItemFieldNotificationUserSettings"]);
            notifications["requestTypeItemNotificationGroupSettings"] = notifications["requestTypeItemNotificationGroupSettings"].concat(Item["requestTypeItemNotificationGroupSettings"]);
            notifications["requestTypeItemNotificationOtherUserSettings"] = notifications["requestTypeItemNotificationOtherUserSettings"].concat(Item["requestTypeItemNotificationOtherUserSettings"]);
            notifications["requestTypeItemNotificationUserSettings"] = notifications["requestTypeItemNotificationUserSettings"].concat(Item["requestTypeItemNotificationUserSettings"]);

        })

        var tempNotifications = [];
        $.each(notifications["requestTypeFieldNotificationGroupSettings"], function(index, Item){
            tempNotifications = tempNotifications.concat(Item);
        });
        notifications["requestTypeFieldNotificationGroupSettings"] = tempNotifications;

        var tempNotifications = [];
        $.each(notifications["requestTypeFieldNotificationOtherUserSettings"], function(index, Item){
            tempNotifications = tempNotifications.concat(Item);
        });
        notifications["requestTypeFieldNotificationOtherUserSettings"] = tempNotifications;

        var tempNotifications = [];
        $.each(notifications["requestTypeFieldNotificationUserSettings"], function(index, Item){
            tempNotifications = tempNotifications.concat(Item);
        });
        notifications["requestTypeFieldNotificationUserSettings"] = tempNotifications;

        var tempNotifications = [];
        $.each(notifications, function(index, Item){
            tempNotifications = tempNotifications.concat(Item);
        });
        notifications = tempNotifications;

        return(notifications);

    }

    var prossesNotifications = function(notifications)
    {
        
        var blank = {
            id: 0,
            whoId: -1,
            userType: -1,
            notificationTrigger: -1,
            typeLvl: -1,
            fieldId: -1,
            }


        var tempNotifications = [];
        $.each(notifications, function(index, Item){

            var temp = JSON.parse(JSON.stringify(blank));

            if('overrideUserId' in Item)
            {
                temp['overrideUserId'] = Item['overrideUserId'];
            }
            else 
            {
                temp['overrideUserId'] = null;
            }

            if ('groupId' in Item)
            {
                temp['id'] = Item['id'];
                temp['whoId'] = Item['groupId'];
                temp['userType'] = 1;
                temp['notificationTrigger'] = Item['notificationTrigger'];
                
                if ("requestTypeId" in Item)
                {
                    temp['typeLvl'] = 1;
                }
                else if ("requestTypeFieldId" in Item)
                {
                    temp['typeLvl'] = 2;
                    temp['fieldId'] = Item['requestTypeFieldId'];
                }
                else if ("requestTypeItemId" in Item && !("requestItemTypeFieldId" in Item))
                {
                    temp['typeLvl'] = 3;
                    temp['fieldId'] = Item['requestTypeItemId'];
                }
                else if ("requestItemTypeFieldId" in Item)
                {
                    temp['typeLvl'] = 4;
                    temp['fieldId'] = Item['requestItemTypeFieldId'];
                    temp['requestTypeItemId'] = Item['requestTypeItemId'];
                }
                
                if ("notifyByBrowser" in Item)
                {
                    temp["Browser"] = Item["notifyByBrowser"];
                }
                 
                if ("notifyByEmail" in Item)
                {
                    temp["Email"] = Item["notifyByEmail"];    
                } 

            }
            else if ('userType' in Item && !('userId' in Item))
            {
                temp['id'] = Item['id'];
                temp['whoId'] = 1;
                temp['userType'] = 3;
                temp['notificationTrigger'] = Item['notificationTrigger'];
                
                if ("requestTypeId" in Item)
                {
                    temp['typeLvl'] = 1;
                }
                else if ("requestTypeFieldId" in Item)
                {
                    temp['typeLvl'] = 2;
                    temp['fieldId'] = Item['requestTypeFieldId'];
                }
                else if ("requestTypeItemId" in Item && !("requestItemTypeFieldId" in Item))
                {
                    temp['typeLvl'] = 3;
                    temp['fieldId'] = Item['requestTypeItemId'];
                }
                else if ("requestItemTypeFieldId" in Item)
                {
                    temp['typeLvl'] = 4;
                    temp['fieldId'] = Item['requestItemTypeFieldId'];
                    temp['requestTypeItemId'] = Item['requestTypeItemId'];
                }
                
                
                if ("notifyByBrowser" in Item)
                {
                    temp["Browser"] = Item["notifyByBrowser"];
                }
                 
                if ("notifyByEmail" in Item)
                {
                    temp["Email"] = Item["notifyByEmail"];    
                } 
            }
            else if ('userId' in Item)
            {
                temp['id'] = Item['id'];
                temp['whoId'] = Item['userId'];
                temp['userType'] = 2;
                temp['notificationTrigger'] = Item['notificationTrigger'];
                
                if ("requestTypeId" in Item)
                {
                    temp['typeLvl'] = 1;
                }
                else if ("requestTypeFieldId" in Item)
                {
                    temp['typeLvl'] = 2;
                    temp['fieldId'] = Item['requestTypeFieldId'];
                }
                else if ("requestTypeItemId" in Item && !("requestItemTypeFieldId" in Item))
                {
                    temp['typeLvl'] = 3;
                    temp['fieldId'] = Item['requestTypeItemId'];
                }
                else if ("requestItemTypeFieldId" in Item)
                {
                    temp['typeLvl'] = 4;
                    temp['fieldId'] = Item['requestItemTypeFieldId'];
                    temp['requestTypeItemId'] = Item['requestTypeItemId'];
                }
                
                if ("notifyByBrowser" in Item)
                {
                    temp["Browser"] = Item["notifyByBrowser"];
                }
                 
                if ("notifyByEmail" in Item)
                {
                    temp["Email"] = Item["notifyByEmail"];    
                }         

            }


            tempNotifications.push(temp);
            
        });
        tempNotifications.push(blank);
        notifications = tempNotifications;
        
        return(notifications);

    }



    return {
        whatMattersToMe: whatMattersToMe,
        getNotificationsForTableFromDOM: getNotificationsForTableFromDOM,
        getNotificationsForTableFromJSON: getNotificationsForTableFromJSON,
        prossesNotifications: prossesNotifications,
        removeUserSettings: removeUserSettings
    };



});