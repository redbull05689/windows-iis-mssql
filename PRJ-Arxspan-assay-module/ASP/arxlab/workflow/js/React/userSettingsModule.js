function showUserSetting(requestTypeId)
{

    var notificationCodes = []
    var codeParams = {
        appName: "Workflow",
        setName: "notificationType"
    };
    notificationCodes.push(ajaxModule().getCodes(codeParams));

    Promise.all(notificationCodes).then(function(codes){
        codes = utilities().decodeServiceResponce(codes);

        var requestType = window.requestTypesArray.find(x => x.id == requestTypeId);     
        requestType['fields'] = sortFields(requestType['fields']);
        var notifications = notificationLoadingModule().getNotificationsForTableFromJSON(requestType);
        var OGnotifications = notifications;
        notifications = notificationLoadingModule().prossesNotifications(notifications);
        notifications = notificationLoadingModule().whatMattersToMe(notifications);
        notifications = splitNotifications(notifications, codes, requestType);
        
        ReactDOM.unmountComponentAtNode(document.getElementById("requestTypeNotificationUserSettings"));  
        ReactDOM.render(
            <UserOverrideCard
            notifications = {notifications}
            requestType = {requestType}
            codes = {codes}
            original = {OGnotifications}
            />
            ,
        document.getElementById("requestTypeNotificationUserSettings")); 

    });
}

class UserOverrideCard extends React.Component{

    constructor(props)
    {
        super(props);
        this.state = {
            notifications: props.notifications,
            requestType: props.requestType,
            codes: props.codes,
            original: props.original
        }
        this.updateNotificationState = this.updateNotificationState.bind(this);
        this.submitBtnClick = this.submitBtnClick.bind(this);
    }

    updateNotificationState(stateWord, keyWord, index, value, objId = null) {

        var notificationTemp = this.state.notifications;
        var theseNotifications = notificationTemp[stateWord];
        if (objId == null)
        {
            theseNotifications[index][keyWord] = value;
        }
        else
        {
            theseNotifications[objId][index][keyWord] = value;
        }
        notificationTemp[stateWord] = theseNotifications;
        
        this.setState({
            notifications: notificationTemp
        })

    }

    submitBtnClick(event){
        $(event.target).attr("disabled", true);
        submitOverrideEditor(this.state);
    }

    render(){
        return(


            <div className="card">
                <div className="card-header" data-background-color="materialblue">
                    <h4 className="title">My Notification Preferences</h4>
                </div>
                <div className="card-content">
                    <div className="table-responsive">

                        <h3 title={this.state.requestType.hoverText}>{`Notifications for:  ${this.state.requestType.displayName}`}</h3>
                        <RequestTypeAndItemsNotifications
                         codes={this.state.codes}
                         requestType = {this.state.requestType}
                         data = {this.state.notifications["requestTypeNotifications"]}
                         stateWord = {"requestTypeNotifications"}
                         updateNotificationState = {this.updateNotificationState}
                         objId= {null}
                        >
                        </RequestTypeAndItemsNotifications>


                        <NotificationTable
                        codes={this.state.codes}
                        data = {this.state.notifications["requestTypeFieldNotifications"]}
                        stateWord = {"requestTypeFieldNotifications"}
                        updateNotificationState = {this.updateNotificationState}
                        objId= {null}
                        >
                        </NotificationTable>

                        {this.state.requestType["requestItemTypes"].map(function(x){
                            var item = window.requestItemTypesArray.find(y=>y.id == x.requestItemTypeId);
                            return ( 
                                <div key={x.requestItemTypeId}>
                                    <h3 title={item.hoverText}>{`Notifications for: ${item.displayName}`}</h3>
                                    <RequestTypeAndItemsNotifications
                                    codes={this.state.codes}
                                    requestType = {this.state.requestType}
                                    data = {this.state.notifications["requestItemNotifications"][x.requestItemId]}
                                    stateWord = {"requestItemNotifications"}
                                    updateNotificationState = {this.updateNotificationState}
                                    objId = {x.requestItemId}
                                    >
                                    </RequestTypeAndItemsNotifications>

                                    <NotificationTable
                                        codes={this.state.codes}
                                        data={this.state.notifications["requestItemFieldNotifications"][x.requestItemId]}
                                        stateWord = {"requestItemFieldNotifications"}
                                        updateNotificationState = {this.updateNotificationState}
                                        objId= {x.requestItemId}
                                    /> 
                                </div>
                            )
                        }, this)} 
                    </div>
                    <button 
                    className="btn btn-success btn-sml"
                    onClick={this.submitBtnClick}
                    >Submit</button>
                </div>
            </div>


        );
    }
}

function RequestTypeAndItemsNotifications(props){
    var tableLength = props.data.length;
    return(
        <div>
            <ReactTable 
                data={props.data}
                showPagination={false}
                columns = {[{
                    Header: "",
                    columns: [{
                        Header: "",
                        accessor: "text",
                        Cell: row =>(<FieldNameDisplay  
                            row={row}
                        />)
                    }]},
                {
                    Header: "Notify me for all requests",
                    columns: props.codes[0].map(function(x){
                        return(
                            {
                                Header: x.codeDescription,
                                accessor: x.codeDescription,
                                Cell: row => (
                                    <NotificationTypeCheckBox 
                                        row = {row}
                                        data = {props.data[row["index"]]}
                                        keyWord = {x.codeDescription}
                                        stateWord = {props.stateWord}
                                        updateNotificationState = {props.updateNotificationState}
                                        objId= {props.objId}
                                    />
                                )
                                
                            }
                        )
                    })
                
                },
                {
                    Header: "Notify me when I am the requester",
                    columns:props.codes[0].map(function(x){
                        return(
                            {
                                Header: x.codeDescription,
                                accessor: x.codeDescription + "_Req",
                                Cell: row => (
                                    <NotificationTypeCheckBox 
                                        row = {row}
                                        data = {props.data[row["index"]]}
                                        keyWord = {x.codeDescription + "_Req"}
                                        stateWord = {props.stateWord}
                                        updateNotificationState = {props.updateNotificationState}
                                        objId= {props.objId}
                                    />
                                )
                                
                            }
                        )
                    })
                }
            ]}
            defaultPageSize = {tableLength}
            className = "-striped -highlight" 
            />
        </div>
        
    )


}

function NotificationTable(props){
		
    return(
        <div>
            <ReactTable
                data={props.data}
                showPagination = {false}
                columns = {[{
                        Header: "",
                        columns: [{
                            Header: "Fields",
                            accessor: "displayName",
                            Cell: row =>(<FieldNameDisplay  
                                row={row}
                            />)
                        }]},
                    {
                        Header: "Notify me for all requests",
                        columns:props.codes[0].map(function(x){
                            return(
                                {
                                    Header: x.codeDescription,
                                    accessor: x.codeDescription,
                                    Cell: row => (
                                        <NotificationTypeCheckBox 
                                            row = {row}
                                            data = {props.data[row["index"]]}
                                            keyWord = {x.codeDescription}
                                            stateWord = {props.stateWord}
                                            updateNotificationState = {props.updateNotificationState}
                                            objId= {props.objId}
                                        />
                                    )
                                    
                                }
                            )
                        })
                        
                    },
                    {
                        Header: "Notify me when I am the requester",
                        columns:props.codes[0].map(function(x){
                            return(
                                {
                                    Header: x.codeDescription,
                                    accessor: x.codeDescription + "_Req",
                                    Cell: row => (
                                        <NotificationTypeCheckBox 
                                            row = {row}
                                            data = {props.data[row["index"]]}
                                            keyWord = {x.codeDescription + "_Req"}
                                            stateWord = {props.stateWord}
                                            updateNotificationState = {props.updateNotificationState}
                                            objId= {props.objId}
                                        />
                                    )
                                    
                                }
                            )
                        })
                    }
                ]}
                defaultPageSize = {props.data.length}
            /*    style={{
                    height: "400px" // This will force the table body to overflow and scroll, since there is not enough room
                    }} */
                className = "-striped -highlight" 
            />
        </div>
    );
    

}

function FieldNameDisplay(props){
    return <p key={props.row.original.key}>{props.row.value}</p>
}

function NotificationTypeCheckBox(props){
    function updateCheckBox(event){

        props.updateNotificationState(props.stateWord, props.keyWord, props.row.index, event.target.checked, props.objId)
        console.log(event);
    }

    return(
        <div className="center-Align">
            <label className="switch">
                <input type="checkbox"
                    key = {props.row.original.key}
                    checked = {props.row.value}
                    onChange = {updateCheckBox}
                />
                <span className="slider round" ></span>
            </label>
        </div>
    )
}

function splitNotifications(notifications, codes, requestType){

    var requestTypeNotifications = [];
    var requestTypeFieldNotifications = [];
    var requestItemNotifications = [];
    var requestItemFieldNotifications = [];
    

    notifications.map(function(x){

        if(x.typeLvl == 1)
        {
            requestTypeNotifications.push(x);
        }
        else if(x.typeLvl == 2)
        {
            requestTypeFieldNotifications.push(x);
        }
        else if(x.typeLvl == 3)
        {
            requestItemNotifications.push(x);
        }
        else if(x.typeLvl == 4)
        {
            requestItemFieldNotifications.push(x);
        }

    });

    var requestFields = requestType['fields'].filter(x => x.disabled != 1);
    requestFields = utilities().checkPerm(requestFields);
    var requestItems = requestType['requestItemTypes'].filter(x => x.disabled != 1);

    var returnData = {
        requestTypeNotifications: getUserSettingsNotifications(requestTypeNotifications, codes),
        requestTypeFieldNotifications: getFieldSettings(requestFields, requestTypeFieldNotifications, codes),
        requestItemNotifications: getRepoItemNotifications(requestItems, requestItemNotifications, codes),
        requestItemFieldNotifications: requestItemFieldSettings(requestItems, requestItemFieldNotifications, codes)
    }

    return (returnData);
}


function sortFields(fields)
{
    var tempArr = []
    $.each(fields, function(i,item){
        var inside = tempArr.find(x => x.requestTypeFieldId == item['requestTypeFieldId']);
        if (!inside)
        {
            tempArr.push(item);
        }
    })
    
    fields = tempArr;
    fields = sortByKey(fields, "sortOrder");
    return(fields);
}

function getUserSettingsNotifications(notifications, codes)
{

    var overrides = notifications.filter(x=>x.overrideUserId == globalUserInfo["userId"])
    var natural = notifications.filter(x=>x.overrideUserId == null)

    var lvl1Triggers = natural.filter(x=>x.notificationTrigger == 1);
    var lvl3Triggers = natural.filter(x=>x.notificationTrigger == 3);

    var lvl1Overrides = overrides.filter(x=>x.notificationTrigger == 1);
    var lvl3Overrides = overrides.filter(x=>x.notificationTrigger == 3);

    //only use the user settings overrides... this is for the convert over to the new user settings page.
    var lvl1UserOverride = lvl1Overrides.filter(x => x.userType == 2)
    var lvl3UserOverride = lvl3Overrides.filter(x => x.userType == 2)
    var lvl1RequesterOverride = lvl1Overrides.filter(x => x.userType == 3)
    var lvl3RequesterOverride = lvl3Overrides.filter(x => x.userType == 3)
    


    var createOBJ = {"text": "Create", "key": "Create"}
    var reprioritizeOBJ = {"text": "Reprioritize", "key": "Reprioritize"}

    codes[0].map(function(x){
        createOBJ[x.codeDescription] = false;
        createOBJ[x.codeDescription + "_Req"] = false;
        reprioritizeOBJ[x.codeDescription] = false;
        reprioritizeOBJ[x.codeDescription + "_Req"] = false;
    });


    if (lvl1Triggers.length > 0)
    {
        lvl1Triggers.map(function(x){
            codes[0].map(function(y){
                if (x[y.codeDescription] == true && x["userType"] != 3) 
                {
                    if (x.notificationTrigger == 1)
                    {
                        createOBJ[y.codeDescription] = true;
                    }
                    else if (x.notificationTrigger == 3)
                    {
                        reprioritizeOBJ[y.codeDescription] = true;
                    }
                }
                else if (x[y.codeDescription] == true && x["userType"] == 3) 
                {
                   
                    if (x.notificationTrigger == 1)
                    {
                        createOBJ[y.codeDescription + "_Req"] = true;
                    }
                    else if (x.notificationTrigger == 3)
                    {
                        reprioritizeOBJ[y.codeDescription + "_Req"] = true;
                    }
                }
            });
        });
    }
    if (lvl3Triggers.length > 0)
    {
        lvl3Triggers.map(function(x){
            codes[0].map(function(y){
                if (x[y.codeDescription] == true && x["userType"] != 3) 
                {
                    if (x.notificationTrigger == 1)
                    {
                        createOBJ[y.codeDescription] = true;
                    }
                    else if (x.notificationTrigger == 3)
                    {
                        reprioritizeOBJ[y.codeDescription] = true;
                    }
                }
                else if (x[y.codeDescription] == true && x["userType"] == 3) 
                {
                    if (x.notificationTrigger == 1)
                    {
                        createOBJ[y.codeDescription + "_Req"] = true;
                    }
                    else if (x.notificationTrigger == 3)
                    {
                        reprioritizeOBJ[y.codeDescription + "_Req"] = true;
                    }
                }
            });
        });
    }

    if(lvl1UserOverride.length > 0)
    {
        codes[0].map(function(y){
            createOBJ[y.codeDescription] = lvl1UserOverride[0][y.codeDescription]
        })
        
    }
    if(lvl3UserOverride.length > 0)
    {
        codes[0].map(function(y){
            reprioritizeOBJ[y.codeDescription] = lvl3UserOverride[0][y.codeDescription]
        })
        
    }
    if(lvl1RequesterOverride.length > 0)
    {
        codes[0].map(function(y){
            createOBJ[y.codeDescription + "_Req"] = lvl1RequesterOverride[0][y.codeDescription]
        })
        
    }
    if(lvl3RequesterOverride.length > 0)
    {
        codes[0].map(function(y){
            reprioritizeOBJ[y.codeDescription + "_Req"] = lvl3RequesterOverride[0][y.codeDescription]
        })
        
    }
    return ([createOBJ,reprioritizeOBJ]);
}

function getFieldSettings(fields, notifications, codes){

    var natural = notifications.filter(x => x.overrideUserId == null);
    var overrides = notifications.filter(x => x.overrideUserId == globalUserInfo["userId"]);
    var userNat = natural.filter(x => x.userType != 3 );
    var userOverride = overrides.filter(x => x.userType != 3);
    var reqNat = natural.filter(x => x.userType == 3);
    var reqOverride = overrides.filter(x => x.userType == 3);


    var userSettings = [];

    fields.map(function(x){

        var object = {
            "displayName": x.displayName,
            "fieldId": x.requestTypeFieldId,
            "requestTypeFieldId": x.requestTypeFieldId,
            "key": x.requestTypeFieldId,
            "sortOrder": x.sortOrder,
        }
        codes[0].map(function(x){
            object[x.codeDescription] = false;
            object[x.codeDescription + "_Req"] = false;
        });
        userSettings.push(object);
    });

    userSettings = userSettings.map(function(x){

        var active = userNat.filter(p => p.fieldId == x.fieldId)
        if (active.length > 0)
        {
            codes[0].map(function(y){
                var found = active.find(p => p[y.codeDescription] == true);
                if(found != undefined)
                {
                    x[y.codeDescription] = true;
                }   
                else
                {
                    x[y.codeDescription] = false;
                }
            });
        }



        var active = userOverride.filter(p => p.fieldId == x.fieldId)
        if (active.length > 0)
        {
            codes[0].map(function(y){
                var found = active.find(p => p[y.codeDescription] == true);
                if(found != undefined)
                {
                    x[y.codeDescription] = true;
                }   
                else
                {
                    x[y.codeDescription] = false;
                }
            });
        }


        var active = reqNat.filter(p => p.fieldId == x.fieldId)
        if (active.length > 0)
        {
            codes[0].map(function(y){
                var found = active.find(p => p[y.codeDescription] == true);
                if(found != undefined)
                {
                    x[y.codeDescription + "_Req"] = true;
                }   
                else
                {
                    x[y.codeDescription + "_Req"] = false;
                }
            });
        }


        var active = reqOverride.filter(p => p.fieldId == x.fieldId)
        if (active.length > 0)
        {
            codes[0].map(function(y){
                var found = active.find(p => p[y.codeDescription] == true);
                if(found != undefined)
                {
                    x[y.codeDescription + "_Req"] = true;
                }   
                else
                {
                    x[y.codeDescription + "_Req"] = false;
                }
            });
        }

        return (x);

    });

    return sortFields(userSettings);
}

function getRepoItemNotifications(requestItems, requestItemNotifications, codes){

    var retNotifications = {};

    requestItems.map(function(item){
        var settingsForItem = requestItemNotifications.filter(x => x.fieldId == item.requestItemId);
        var natural = settingsForItem.filter(x => x.overrideUserId == null);
        var overrides = settingsForItem.filter(x => x.overrideUserId == globalUserInfo["userId"]);
        var userNat = natural.filter(x => x.userType != 3 );
        var userOverride = overrides.filter(x => x.userType != 3);
        var reqNat = natural.filter(x => x.userType == 3);
        var reqOverride = overrides.filter(x => x.userType == 3);

        var notificationOut = {
            "text": "Reprioritize",
            "key" : "Reprioritize"
        };

        if (userNat.length > 0)
        {
            codes[0].map(function(y){
                var found = userNat.find(x => x[y.codeDescription] == true)
                
                if (found != undefined)
                {
                    notificationOut[y.codeDescription] = true;
                }
                else 
                {
                    notificationOut[y.codeDescription] = false;
                }
            });
        }

        if (userOverride.length > 0)
        {
            codes[0].map(function(y){
                var found = userOverride.find(x => x[y.codeDescription] == true)
                
                if (found != undefined)
                {
                    notificationOut[y.codeDescription] = true;
                }
                else 
                {
                    notificationOut[y.codeDescription] = false;
                }
            });
        }

        if (reqNat.length > 0)
        {
            codes[0].map(function(y){
                var found = reqNat.find(x => x[y.codeDescription] == true)
                
                if (found != undefined)
                {
                    notificationOut[y.codeDescription + "_Req"] = true;
                }
                else 
                {
                    notificationOut[y.codeDescription + "_Req"] = false;
                }
            });
        }

        if (reqOverride.length > 0)
        {
            codes[0].map(function(y){
                var found = reqOverride.find(x => x[y.codeDescription] == true)
                
                if (found != undefined)
                {
                    notificationOut[y.codeDescription + "_Req"] = true;
                }
                else 
                {
                    notificationOut[y.codeDescription + "_Req"] = false;
                }
            });
        }

        retNotifications[item.requestItemId] = [notificationOut];
    });

    return(retNotifications);
}

function requestItemFieldSettings(requestItems, requestItemNotifications, codes){

    var retNotifications = {};
    requestItems.map(function(item){
        retNotifications[item.requestItemId] = [];
        var settingsForItem = requestItemNotifications.filter(x => x.requestTypeItemId == item.requestItemId);
        var natural = settingsForItem.filter(x => x.overrideUserId == null);
        var overrides = settingsForItem.filter(x => x.overrideUserId == globalUserInfo["userId"]);
        var userNat = natural.filter(x => x.userType != 3 );
        var userOverride = overrides.filter(x => x.userType != 3);
        var reqNat = natural.filter(x => x.userType == 3);
        var reqOverride = overrides.filter(x => x.userType == 3);

        var activeItem = window.requestItemTypesArray.find(x => x.id == item.requestItemTypeId);
        var itemFields = activeItem["fields"].filter(x => x.disabled != 1);
        itemFields = sortFields(itemFields); 
        itemFields = utilities().checkPerm(itemFields);
        itemFields = sortFields(itemFields);// we run it 2 times 1st to remove duplicates 2nd to make sure it is in the right order

        itemFields.map(function(field){
            var notificationOut = {
                "displayName": field["displayName"],
                "fieldId": field["requestTypeFieldId"],
                "key": field["requestTypeFieldId"]
            };

            codes[0].map(function(y){
            
                var active = userNat.find(z => z['fieldId'] == field["requestTypeFieldId"]);
                if (active != undefined)
                {
                    notificationOut[y.codeDescription] = active[y.codeDescription];
                }
                else
                {
                    notificationOut[y.codeDescription] = false;
                }

                var active = userOverride.find(z => z['fieldId'] == field["requestTypeFieldId"]);
                if (active != undefined)
                {
                    notificationOut[y.codeDescription] = active[y.codeDescription];
                }
               

                var active = reqNat.find(z => z[y.codeDescription] == true && z['fieldId'] == field["requestTypeFieldId"]);
                if (active != undefined)
                {
                    notificationOut[y.codeDescription + "_Req"] = true;
                }
                else
                {
                    notificationOut[y.codeDescription + "_Req"] = false;
                }

                var active = reqOverride.find(z => z['fieldId'] == field["requestTypeFieldId"]);
                if (active != undefined)
                {
                    notificationOut[y.codeDescription + "_Req"] = active[y.codeDescription];
                }
              

            });
            
            retNotifications[item.requestItemId].push(notificationOut);
        })
    });
    return(retNotifications);
}

function submitOverrideEditor(state){
    console.log(state);

    var codes = state["codes"];
    var notifications = state["notifications"];
    var original = state["original"];
    var requestType = state["requestType"];
    var prossedNotifications = [];

    

    $.each(notifications,function(key,val){

        if(key == "requestItemNotifications")
        {
            $.each(val, function(k,q){
                var temp = {
                    Browser:false,
                    Email:false,
                    fieldId: parseInt(k) ,
                    id:-1,
                    notificationTrigger:3,
                    overrideUserId:null,
                    typeLvl:3,
                    userType: 2,
                    whoId: globalUserInfo["userId"]
                }
                var reqTemp = JSON.parse(JSON.stringify(temp));
                reqTemp["userType"] = 3;
                reqTemp["whoId"] = 1;

                codes[0].map(function(y){
                    temp[y.codeDescription] = q[0][y.codeDescription];
                    reqTemp[y.codeDescription] = q[0][y.codeDescription + "_Req"];
                });
                prossedNotifications.push(JSON.parse(JSON.stringify(temp)));
                prossedNotifications.push(JSON.parse(JSON.stringify(reqTemp)));
            })
            
        }
        else if(key == "requestItemFieldNotifications")
        { 
            $.each(val, function(k,q){
                q.map(function(z){
                    var temp = {
                        Browser:false,
                        Email:false,
                        fieldId:z.fieldId,
                        id:-1,
                        notificationTrigger:2,
                        overrideUserId:null,
                        requestTypeItemId:parseInt(k),
                        typeLvl:4,
                        userType: 2,
                        whoId: globalUserInfo["userId"]
                    }
                    var reqTemp = JSON.parse(JSON.stringify(temp));
                    reqTemp["userType"] = 3;
                    reqTemp["whoId"] = 1;
    
                    codes[0].map(function(y){
                        temp[y.codeDescription] = z[y.codeDescription];
                        reqTemp[y.codeDescription] = z[y.codeDescription + "_Req"];
                    });
                    prossedNotifications.push(JSON.parse(JSON.stringify(temp)));
                    prossedNotifications.push(JSON.parse(JSON.stringify(reqTemp)));
                })
            });
            
        }
        else 
        {
            val.map(function(x){

                if(key == "requestTypeNotifications")
                {
                    var temp = {
                        Browser:false,
                        Email:false,
                        fieldId:-1,
                        id:-1,
                        notificationTrigger:-1,
                        overrideUserId:null,
                        typeLvl:1,
                        userType: 2,
                        whoId: globalUserInfo["userId"]
                    }  
                    
                    var reqTemp = JSON.parse(JSON.stringify(temp));
                    reqTemp["userType"] = 3;
                    reqTemp["whoId"] = 1;
                    
                    
                    if (x.key == "Create")
                    {
                        temp["notificationTrigger"] = 1;
                        reqTemp["notificationTrigger"] = 1;
                    }
                    else if (x.key == "Reprioritize")
                    {
                        temp["notificationTrigger"] = 3;
                        reqTemp["notificationTrigger"] = 3;
                    }
                    codes[0].map(function(y){
                        temp[y.codeDescription] = x[y.codeDescription];
                        reqTemp[y.codeDescription] = x[y.codeDescription + "_Req"];
                    });
    
                    prossedNotifications.push(JSON.parse(JSON.stringify(temp)));
                    prossedNotifications.push(JSON.parse(JSON.stringify(reqTemp)));
                }
                else if(key == "requestTypeFieldNotifications")
                {
                    var temp = {
                        Browser:false,
                        Email:false,
                        fieldId: x.fieldId,
                        id:-1,
                        notificationTrigger:2,
                        overrideUserId:null,
                        typeLvl:2,
                        userType: 2,
                        whoId: globalUserInfo["userId"]
                    }  
                    var reqTemp = JSON.parse(JSON.stringify(temp));
                    reqTemp["userType"] = 3;
                    reqTemp["whoId"] = 1;
    
                    codes[0].map(function(y){
                        temp[y.codeDescription] = x[y.codeDescription];
                        reqTemp[y.codeDescription] = x[y.codeDescription + "_Req"];
                    });
    
                    prossedNotifications.push(JSON.parse(JSON.stringify(temp)));
                    prossedNotifications.push(JSON.parse(JSON.stringify(reqTemp)));
    
                }
                
    
            })
        }
       
    })
    var outOBJ = {
        typeCodes: codes[0],
        notifications: prossedNotifications,
        requestTypeId: requestType["id"],
        preserveNotifications: original,
        prossesedNotificationsOriginal: notificationLoadingModule().prossesNotifications(original)
    }
    notificationSubmitionModule().submitNotificationEditor(outOBJ);
    console.log(prossedNotifications);

} 