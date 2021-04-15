$.ajaxSetup({
    headers: {"Authorization": jwt}
});

var ajaxModule = (function(){

    /**
     * Function to fetch all request types, process them and set up the resulting list as a global variable.
     */
    var processRequestTypesArray = function() {
        return new Promise(function (resolve, reject) {

            var requestTypeParams = {
                appName: window.top.currApp,
                includeDisabled: window.top.currApp == "Configuration",
                AsOfDate: utilities().getDateForService()
            }
            
            getRequestTypes(requestTypeParams).then(function (response) {
                if (typeof response !== "undefined") {
                    response = utilities().decodeServiceResponce(response);
                    window.requestTypesArray = response.map(function(x){
						x.fields = utilities().sortArray(x.fields, "sortOrder");
						return x;
                    });

                    var showMakeNewRequest = false;
    
                    $.each(requestTypesArray, function (index, requestType) {
                        requestType.fieldsDict = makeFieldsDict(requestType.fields);
    
                        if (requestType['canAdd'] || !requestType['restrictAccess']) {
                            showMakeNewRequest = true;
                        }
                    });

                    if (showMakeNewRequest) {
                        $('body').addClass('canMakeNewRequest');
                    }
                }

                resolve(window.requestTypesArray);
            })
        })
    }
    
    var fetchAuditTrailAuthors = function() {
        return new Promise(function (resolve, reject) {
            $.ajax({
                url: "../_inclds/experiments/cust/asp/get-co-authors.asp",
                type: 'POST',
                data: { "id": window.top.$("#experimentId").val() }
            }).done(function (response) {
                window.auditTrailAuthors = response.split(",");
                window.auditTrailAuthors.pop();
                resolve(true);
            });
        });
    }

    /**
     * Fetches a list of requests of the given request type ID to prioritize. A user ID can be optionally passed
     * in to get a list of only their requests.
     * @param {number} requestTypeId The request type ID we want to prioritize.
     * @param {string} appName The application name.
     * @param {number} userId Optional: If we want to prioritize one user's requests, then pass in their ID.
     */
    var getQueueableRequests = function(requestTypeId=null, appName="Workflow", userId=null) {
        return new Promise(function(resolve, reject) {

            // Fallback if somehow we end up here without a request type ID.
            if (requestTypeId == null) {
                resolve({"data":"[]"});
                return;
            }

            var serviceUrl = appServiceEndpoints.QUEUEABLE_REQUESTS(requestTypeId);
            var serviceObj = {appName: appName};

            if (userId) {
                serviceObj["userId"] = userId;
            }

            resolve(getFromAppService(serviceUrl, serviceObj));
        });
    }

    /**
     * Fetch a specific request from the manage requests table.
     * @param {*} request The request data from the manage requests table.
     * @param {*} rowId The row this request was on for the manage requests page.
     */
    var fetchSpecificRequest = function(request, rowId) {

        if (requestItemTableNames != undefined) {
            requestItemTableNames = [];
        }
        $('#basicLoadingModal').modal('show');
    
        var asOfDate = request["dateCreated"];
        asOfDate = utilities().asOfDateValidator(asOfDate);

        var inputParams = {
            getFieldData: true,
            getItemData: true,
            appName: "Workflow"
        }
        
        getRequests(request.id, inputParams).then(function(response) {
            window.preventNotification = 1;
            var thisRequest = response;
            ajaxModule().getAllLinksForRequest(request.id).then(function(){
                getVersionedConfigData(thisRequest["requestTypeId"], false, asOfDate).then(function(configResponses) {
                    thisRequestType = configResponses[2][0];
                    requestItemTypes = configResponses[1];
                    fields = configResponses[0];
                    
                    requestEditorHelper.generateRequestDetailsRow(thisRequest, $('#requestEditorModal .modal-content'), thisRequestType, requestItemTypes, fields);
                    $('#requestEditorModal .modal-content .dropdownEditorContainer').prepend($('<div class="modalTitleFixed">').text(thisRequest['requestName']));
                    $('#requestEditorModal .modal-content .dropdownEditorContainer').attr("rowId", rowId)
                    $('#basicLoadingModal').modal('hide');
                    $('#requestEditorModal').modal('show');        
                });
            });
        });
    }

    var getStructureImagesByRequestId = function(requestId) {
        return new Promise(function(resolve, reject) {

            var currAppName = window.top.currApp ? window.top.currApp : "Workflow";
            var inputParams = {
                requestId: requestId,
                width: 280,
                height: 140,
                appName: currAppName
            };

            resolve(getFromAppService(appServiceEndpoints.REQUEST_STRUCTURES, inputParams));
        })
    }
    
    var loadRequestPreviewStructureImages = function(requestId) {
        getStructureImagesByRequestId(requestId).then(function(response) {
            console.log("success");
            console.log(response);

            var structureImageStrings = response['structureImageStrings'];
            var structureImageLiArray = [
                $("<li>").addClass("card noStructurePreviewText").text("No structures found.")
            ];
            if (Object.keys(structureImageStrings).includes(requestId.toString())) {
                structureImageLiArray = structureImageStrings[requestId].map(x => $("<li>").addClass("card").append($(x)));
            }

            $('ul.requestItemStructurePreviewList').removeClass('loadingStructureImages');
            $('ul.requestItemStructurePreviewList').append(structureImageLiArray);
        }).catch(function () {
            console.log("error");
        });
    }
    
    var populateRequestItemTypesList = function() {
        return new Promise(function (resolve, reject) {
            if (typeof window.requestItemTypesArray != "undefined") {
                resolve(true);
                return;
            }
    
            window.requestItemTypesArray = [];
            $('select#savedDropdownsListDropdown').empty();

            var requestItemTypesParams = {
                includeDisabled: true,
                isConfigPage: true,
                appName: "Configuration",
                asOfDate: utilities().getDateForService()
            }
    
            getRequestItemTypes(requestItemTypesParams)
                .then(function (response) {
                    console.log("populateRequestItemTypesList() - success");
        
                    if (typeof response !== "undefined") {
                        response = utilities().decodeServiceResponce(response);
                        window.requestItemTypesArray = response.map(function(x){
                            x.fields = utilities().sortArray(x.fields, "sortOrder")
                            return x
                        })
                        var dropdown = $('<select></select>'); // only used as a container
                        $.each(window.requestItemTypesArray, function (index, requestItemType) {
        
                            requestItemType.fieldsDict = makeFieldsDict(requestItemType.fields);
        
                            var requestItemType = $('<option></option>').attr('value', index).attr('requestitemtypeid', requestItemType['id']).text(requestItemType['displayName'])
                            dropdown.append(requestItemType)
                        });
                        utilities().sortDropdownlist(dropdown);
                        window.requestItemTypesOptionsHTML = dropdown.html();
                    }
        
                    console.log("set requestItemTypesArray");
                    console.log(window.requestItemTypesArray);
                    resolve(true);
                })
                .catch(function () {
                    reject();
                    console.log("error");
                });
        });
    }
    

    var populateSavedFieldsList = function() {
        return new Promise(function (resolve, reject) {
            if (typeof window.savedFieldsArray != "undefined") {
                resolve(true);
                return;
            }
    
            $('select#savedDropdownsListDropdown').empty();
    
            var fieldParams = {
                isConfigPage: false,
                appName: "Workflow"
            };

            getFields(fieldParams).then(function (response) {
                if (typeof response !== "undefined") {

                    // subtask 7817 of 5580-Update to disallow the new BioSpin data type from being added to the request item type
                    if (window.requestTypePageMode === "requestItemTypes") {
                        const responseArray = JSON.parse(response.data);
                        const filteredArray =  responseArray.filter((element) => element.dataTypeId !== dataTypeEnums.BIOSPIN_EDITOR) //filter out bio data type(id = 20)
                        window.savedFieldsArray = filteredArray;
                    } else {
                        window.savedFieldsArray = JSON.parse(response.data);
                    }
                    var dropdown = $('<select></select>'); // only used as a container
                    var sortedDropdowns = utilities().sortArray(window.savedFieldsArray, "displayName");
                    
                    $.each(sortedDropdowns, function (index, field) {
                        if (field.disabled != 1) {
                            var savedField = $('<option></option>').attr('value', index).attr('savedfieldid', field['id']).text(field['displayName']);
                            dropdown.append(savedField);
                        }
                    });
                    window.savedFieldsOptionsHTML = dropdown.html();
                }
    
                resolve(true);
            }).catch(function (error) {
                console.log("error", error);
                reject(false);
            });
        });
    }

    var makeFieldsDict = function(fields) {
        // Converts a fields array into a fieldsDict.
        var fieldsDict = {};
        var sortOrder = [];
        console.log(fields);
    
        $.each(fields, function (index, field) {
            var existingKeys = Object.keys(fieldsDict);
            var fieldId = field.requestTypeFieldId.toString();
            if (existingKeys.indexOf(fieldId) < 0) {
                fieldsDict[fieldId] = []
                sortOrder.push(fieldId);
            }
            fieldsDict[fieldId].push(field);
        });
    
        fieldsDict['sortOrder'] = sortOrder;
        return fieldsDict;
    }

    var processCDX = function(cdxmlStr, requestItemId, fileUploadSetting, tableId, versionedRequestItems, versionedFields) {
        $.ajax({
            url: "/excel2csv/CDXConv",
            type: "POST",
            data: {
                "cdxml": cdxmlStr,
                "jwt": jwt,
                "appName": currApp
            }
        }).done(function (response) {
            console.log(response);
            tableFileUpload.addFragmentsToTable(response[0], requestItemId, fileUploadSetting, tableId, versionedRequestItems, versionedFields);
        });
    }

    var processCDXML = function(requestObj, requestItemId, fileUploadSetting, tableId, versionedRequestItems, versionedFields) {
        $.ajax({
            url: "/excel2csv/CDXMLConv",
            type: "POST",
            data: requestObj
        }).done(function (response) {
            console.log(response);
            tableFileUpload.addFragmentsToTable(response[0], requestItemId, fileUploadSetting, tableId, versionedRequestItems, versionedFields);
        });
    }

    var CDXToCDXML = function(filename, requestItemId, fileUploadSetting, tableId, versionedRequestItems, versionedFields) {
        $.ajax({
            url: "/arxlab/accint/getXMLStr.asp",
            type: "POST",
            data: { "file": filename }
        }).done(function (response) {
            processCDX(response, requestItemId, fileUploadSetting, tableId, versionedRequestItems, versionedFields);
        });
    }
    
    var checkCache = function() {
        
        var serviceObj = {
            configService: false,
        };
        utilities().makeAjaxPost("/workflowCache/", {}, serviceObj).then(function (response) {
            console.log(response)
        })
    }

    var searchReg = function(structure) {
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: "/arxlab/registration/services/searchStructureInReg.asp",
                type: "POST",
                dataType: 'json',
                data: {"structure": structure}
            }).done(function(response) {
                resolve(response);
            });
        });
    }

    var registerCompound = function(structure) {

        var theData = {
            "addStructureSubmit": 1,
            "lastSaltNumber": 1,
            "salt_1_cdid": 0,
            "salt_1_multiplicity": 1.0,
            "addBatch": 0,
            "stereochemistry": -1,
            "addStructureCdxmlData": structure
        };

        return new Promise(function(resolve, reject) {
            $.ajax({
                url: "/arxlab/registration/addStructure.asp",
                type: "POST",
                data: theData
            }).done(function(response) {
                resolve(response);
            })
        });
    }

    var searchAccord = function(structure) {
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: "/arxlab/registration/services/searchAccordStructures.asp",
                type: "POST",
                data: {"structure": structure}
            }).done(function(response) {
                resolve(response);
            });
        });
    }
    
    var submitField = function(data) {
        return new Promise(function(resolve, reject) {
            var serviceObj = {
                configService: true,
            };
            utilities().makeAjaxPost("/fields/upsert", data, serviceObj).then(function(response) {
                resolve(response);
            });
        })
    }

    var submitDropdown = function(data) {
        return new Promise(function(resolve, reject) {
            var serviceObj = {
                configService: true,
            };
            utilities().makeAjaxPost("/dropdowns/upsert", data, serviceObj).then(function(response) {
                resolve(response);
            });
        })
    }

    var fetchFileUploadSetting = function(companyId, userId) {
        return new Promise(function(resolve, reject) {

            var inputData = {
                companyId: companyId,
                userId: userId
            };

            $.ajax({
                url: "manageConfiguration/fetchFileUploadSetting.asp",
                data: inputData,
                verb: "GET"
            }).done(function(response) {
                resolve(response);
            })
        });
    }

    var storeFileUploadSetting = function(companyId, userId, fileUploadSetting, confirmMsg) {
        return new Promise(function(resolve, reject) {
            var inputData = {
                companyId: companyId,
                userId: userId,
                fileUploadSetting: fileUploadSetting
            };

            $.ajax({
                url: "manageConfiguration/storeFileUploadSetting.asp",
                data: inputData,
                verb: "PUT"
            }).done(function(response) {
                resolve(confirmMsg);
            })
        });
    }

    var notificationServiceHealthCheck = function() {
        return new Promise(function(resolve, reject) {
            resolve(getFromNotificationService(notificationServiceEndpoints.HEALTH_CHECK));
        });
    }

    var getUnreadNotifications = function() {
        return new Promise(function(resolve, reject) {

            if (window.top != window.self) {
                resolve([]);
            } else {
                var baseUrl = notificationServiceEndpoints.UNREAD_NOTIFICATIONS;
                var paramObj = {
                    //AsOfDate: utilities().getDateForService(),
                    AsOfDate: "",
                    appName: "Workflow"
                };
    
                resolve(getFromNotificationService(baseUrl, paramObj));
            }
        });
    }

    /**
     * Gets the count of unread notifications.
     */
    var getUnreadNotificationsCount = function() {
        return new Promise(function(resolve, reject) {

            if (window.top != window.self) {
                resolve([]);
            } else {
                var baseUrl = notificationServiceEndpoints.UNREAD_NOTIFICATIONS_COUNT;
                var paramObj = {
                    AsOfDate: "",
                    appName: "Workflow"
                };
    
                resolve(getFromNotificationService(baseUrl, paramObj));
            }
        });
    }

    var patchNotification = function(inputData) {
        return new Promise(function(resolve, reject) {
            var serviceUrl = `/BrowserNotifications`;
            
            var serviceObj = {
                configService: true,
                notificationService: true,
            }
            resolve(utilities().makeAjaxPatch(serviceUrl, inputData, serviceObj));
        });
    }

    var patchNotificatonReadDate = function(inputData) {
        return new Promise(function(resolve, reject) {
            var serviceUrl = `/BrowserNotifications/read-date`;
            
            var serviceObj = {
                configService: true,
                notificationService: true,
            }
            resolve(utilities().makeAjaxPatch(serviceUrl, inputData, serviceObj));
        });
    }

    /**
     * Get a list of requests from the appService.
     * @param {*} inputParams The parameters to search by.
     */
    var getRequests = function(requestId, inputParams) {
        return new Promise(function(resolve, reject) {

            resolve(getFromAppService(appServiceEndpoints.GET_REQUESTS(requestId), inputParams));
        });
    }

    /**
     * Gets a specific request revision.
     * @param {number} requestId 
     * @param {number} revisionId 
     * @param {*} inputParams 
     */
    var getRequestRevision = function(requestId, revisionId, inputParams) {
        return new Promise(function(resolve, reject) {
            if (revisionId == "") {
                resolve(getRequests(requestId, inputParams));
            } else {
                getFromAppService(appServiceEndpoints.GET_REQUESTS_REVISION(requestId, revisionId), inputParams).then(revResp =>                    
                    resolve(utilities().decodeServiceResponce(revResp))
                );
            }
        });        
    }

    var postBrowserNotification = function(inputData) {
        return new Promise(function(resolve, reject) {
            var serviceUrl = `/BrowserNotifications`

            var serviceObj = {
                configService: true,
                notificationService: true,
            }
            resolve(utilities().makeAjaxPost(serviceUrl, inputData, serviceObj));
        });
    }

    /**
     * Fetches request types based on the given parameters.
     * @param {object} paramObj The query string parameters.
     */
    var getRequestTypes = function(paramObj) {
        return new Promise(function(resolve, reject) {
            resolve(getFromConfigService(configServiceEndpoints.REQUEST_TYPES, paramObj));
        });
    }

    /**
     * Fetches request item types based on the given parameters.
     * @param {object} paramObj The query string parameters.
     */
    var getRequestItemTypes = function(paramObj) {
        return new Promise(function(resolve, reject) {
            resolve(getFromConfigService(configServiceEndpoints.REQUEST_ITEM_TYPES, paramObj));
        });
    }

    /**
     * Fetches fields based on the given parameters.
     * @param {object} paramObj The query string parameters.
     */
    var getFields = function(paramObj) {
        return new Promise(function(resolve, reject) {
            resolve(getFromConfigService(configServiceEndpoints.FIELDS, paramObj));
        });
    }

    /**
     * Fetches dropdowns based on the given parameters.
     * @param {object} paramObj The query string parameters.
     */
    var getDropdowns = function(paramObj) {
        return new Promise(function (resolve, reject) {
            resolve(getFromConfigService(configServiceEndpoints.DROPDOWNS, paramObj));
        });
    }

    /**
     * Fetches codes based on the given parameters.
     * @param {object} paramObj The query string parameters.
     */
    var getCodes = function(paramObj) {
        return new Promise(function(resolve, reject) {
            resolve(getFromConfigService(configServiceEndpoints.CODES, paramObj));
        });
    }

    /**
     * Builds a GET url from the given baseUrl and paramObj, then makes a GET call to the service defined by serviceObj with it.
     * @param {string} baseUrl The service endpoint to hit.
     * @param {object} paramObj The query string parameters.
     * @param {*} serviceObj The object that defines which service to hit.
     */
    var getFromService = function(baseUrl, paramObj, serviceObj) {
        return new Promise(function(resolve, reject) {

            var serviceUrl = utilities().buildGetUrl(baseUrl, paramObj);

            resolve(utilities().makeAjaxGet(serviceUrl, serviceObj))
        });
    }

    /**
     * Makes a GET call to the config service at the given baseUrl with the given parameters.
     * @param {string} baseUrl The service endpoint to hit.
     * @param {object} paramObj The query string parameters.
     */
    var getFromConfigService = function(baseUrl, paramObj={}) {
        return new Promise(function(resolve, reject) {

            var serviceObj = {
                configService: true,
            };

            resolve(getFromService(baseUrl, paramObj, serviceObj));
        });
    }

    /**
     * Makes a GET call to the app service at the given baseUrl with the given parameters.
     * @param {string} baseUrl The service endpoint to hit.
     * @param {object} paramObj The query string parameters.
     */
    var getFromAdminService = function(baseUrl, paramObj={}) {
        return new Promise(function(resolve, reject) {
            
            var serviceObj = {
                configService: true,
                adminService: true
            };

            resolve(getFromService(baseUrl, paramObj, serviceObj));
        })
    }

    /**
     * Makes a GET call to the app service at the given baseUrl with the given parameters.
     * @param {string} baseUrl The service endpoint to hit.
     * @param {object} paramObj The query string parameters.
     */
    var getFromAppService = function(baseUrl, paramObj={}) {
        return new Promise(function(resolve, reject) {
            
            var serviceObj = {
                configService: true,
                appService: true
            };

            resolve(getFromService(baseUrl, paramObj, serviceObj));
        })
    }

    /**
     * Makes a GET call to the notification service at the given baseUrl with the given parameters.
     * @param {string} baseUrl The service endpoint to hit.
     * @param {object} paramObj The query string parameters.
     */
    var getFromNotificationService = function(baseUrl, paramObj={}) {
        return new Promise(function(resolve, reject) {

            var serviceObj = {
                configService: true,
                notificationService: true
            };

            resolve(getFromService(baseUrl, paramObj, serviceObj));
        })
    }

    /**
     * Get versioned config data for the given request type ID at the given date, if we don't want the current version
     * @param {*} requestTypeId 
     * @param {*} currVersion 
     * @param {*} dateCreated 
     */
    var getVersionedConfigData = function(requestTypeId, currVersion = true, dateCreated = "") {        
        return new Promise(function(resolve, reject) {
            var versionedData = [];

            var configPromises = [];

            var asOfDate = currVersion ? "" : utilities().getDateForService(dateCreated);

            var currAppName = window.top.currApp ? window.top.currApp : "Workflow";
    
            var configParams = {
                appName: currAppName,
                asOfDate: asOfDate
            }
    
            configPromises.push(getFields(configParams));
            configParams.requestTypeId = requestTypeId;
            configPromises.push(getRequestTypes(configParams));

    
            Promise.all(configPromises).then(function(configResponses) {
                configResponses = utilities().decodeServiceResponce(configResponses);

                var fields = configResponses[0];
                var requestType = configResponses[1];

                // Check to make sure any requests came back.
                if (requestType.length == 0) {
                    window.top.swal({
                        title: `Request Type Not Found`,
                        type: `warning`,
                        text: `This request type was not found. Check to make sure it was not disabled.`
                    }, function() {
                        if (window.top != window.self) {
                            window.top.location = "/arxlab/dashboard.asp";
                        } else if (window.CurrentPageMode == "manageRequests") {
                            window.top.location.reload();
                        } else {
                            window.top.location = "/arxlab/workflow/";
                        }
                    });
                    return;
                }

                requestType[0].fields = utilities().sortArray(requestType[0].fields, "sortOrder");

                var priorityOptionPromises = [];
                priorityOptionPromises.push(new Promise(function(resolve, reject) {
                    getRequestTypeFieldPrioritizationOptions(requestTypeId).then(function(priorityResponse) {
                        var priorityOptions = utilities().decodeServiceResponce(priorityResponse);
                        if (priorityOptions.length > 0) {
                            var requestTypeFieldId = priorityOptions[0]["requestTypeFieldId"];
                            var requestTypeField = requestType[0].fields.find(x => x.requestTypeFieldId == requestTypeFieldId);
    
                            if (requestTypeField) {
                                requestTypeField.requestTypeFieldPriorityOptions = priorityOptions;
                            }
                        }

                        resolve();
                    });
                }));
                
                Promise.all(priorityOptionPromises).then(function() {
                    requestType[0].fieldsDict = makeFieldsDict(requestType[0].fields);
    
                    var reqItemParams = {
                        appName: currAppName,
                        asOfDate: asOfDate,
                        requestItemTypeIds: requestType[0].requestItemTypes.map(x => x.requestItemTypeId)
                    };
    
                    getRequestItemTypes(reqItemParams).then(function(requestItemTypes) {
                        requestItemTypes = utilities().decodeServiceResponce(requestItemTypes);
                        requestItemTypes = requestItemTypes.map(function(x){
                            x.fields = utilities().sortArray(x.fields, "sortOrder")
                            return x
                        })
                        requestItemTypes = requestItemTypes.map(function(requestItem) {
                            requestItem.fieldsDict = makeFieldsDict(requestItem.fields);
                            return requestItem;
                        });
    
                        versionedData.push(fields);
                        versionedData.push(requestItemTypes);
                        versionedData.push(requestType);
                        resolve(versionedData);
                    });
                })
            });
        })
    }

    /**
     * Helper function to make an AJAX POST to one of the services, defined by serviceObj.
     * @param {string} baseUrl 
     * @param {*} inputData 
     * @param {*} serviceObj 
     */
    var postToService = function(baseUrl, inputData, serviceObj) {
        return new Promise(function(resolve, reject) {
            resolve(utilities().makeAjaxPost(baseUrl, inputData, serviceObj));
        });
    }

    /**
     * Makes a POST to the App Service at the given baseUrl.
     * @param {string} baseUrl 
     * @param {*} inputData 
     */
    var postToAppService = function(baseUrl, inputData={}) {
        return new Promise(function(resolve, reject) {
            var serviceObj = {
                configService: true,
                appService: true
            };
            resolve(postToService(baseUrl, inputData, serviceObj));
        })
    }

    /**
     * Helper function to make an AJAX PUT to one of the services, defined by serviceObj.
     * @param {*} baseUrl 
     * @param {*} inputData 
     * @param {*} serviceObj 
     */
    var putToService = function(baseUrl, inputData, serviceObj) {
        return new Promise(function(resolve, reject) {
            resolve(utilities().makeAjaxPut(baseUrl, inputData, serviceObj));
        });
    }

    /**
     * Makes a PUT to the App Service at the given baseUrl.
     * @param {string} baseUrl 
     * @param {*} inputData 
     */
    var putToAppService = function(baseUrl, inputData={}) {
        return new Promise(function(resolve, reject) {
            var serviceObj = {
                configService: true,
                appService: true
            };
            resolve(putToService(baseUrl, inputData, serviceObj));
        })
    }

    /**
     * Helper function to make an AJAX PATCH to one of the services, defined by serviceObj.
     * @param {*} baseUrl 
     * @param {*} inputData 
     * @param {*} serviceObj 
     */
    var patchToService = function(baseUrl, inputData={}, serviceObj) {
        return new Promise(function(resolve, reject) {
            resolve(utilities().makeAjaxPatch(baseUrl, inputData, serviceObj));
        })
    }

    /**
     * Makes a PATCH to the App Service at the given baseUrl.
     * @param {string} baseUrl 
     * @param {*} inputData 
     */
    var patchToAppService = function(baseUrl, inputData={}) {
        return new Promise(function(resolve, reject) {
            var serviceObj = {
                configService: true,
                appService: true
            };
            resolve(patchToService(baseUrl, inputData, serviceObj));
        })
    }

    /**
     * Checks if the given request type ID is the most recent version as of the asOfDate.
     * @param {number} reqTypeId The ID of the request type to check.
     * @param {number} asOfDate The date of the version to check.
     * @param {boolean} returnJson Debug param; sends the JSONs of the two versions if set to true.
     */
    var isThisTheMostRecent = function(reqTypeId, asOfDate, returnJson = false){
        return new Promise(function(resolve, reject) {
            var inputData = {
                appName: window.top.currApp,
                requestTypeId: reqTypeId,
                AsOfDate: utilities().getDateForService(asOfDate),
                returnJson: returnJson
            }
            var serviceObj = {
                configService: true,
            };

            resolve(getFromConfigService(configServiceEndpoints.IS_CURRENT_TYPE, inputData));
        })
    }

    var getUsersWhoCanSeeThisExp = function() {
        return new Promise(function(resolve, reject) {
            if (window.top != window.self) {
                $.ajax({
                    url: "../ajax_loaders/getUsersWhoCanViewThisExperiment.asp",
                    data: {experimentId: window.top.experimentId, experimentType: 5},
                    verb: "GET",
                    dataType: "text"
                }).done(function(resp) {
                    resolve(JSON.parse(resp))
                }).fail(function(resp) {
                    reject(resp);
                });
            } else {
                resolve(window.usersList);
            }
        })
    }

    var getUsersWhoCanSeeThisExp = function() {
        return new Promise(function(resolve, reject) {
            if (window.top != window.self) {
                $.ajax({
                    url: "../ajax_loaders/getUsersWhoCanViewThisExperiment.asp",
                    data: {experimentId: window.top.experimentId, experimentType: 5},
                    verb: "GET",
                    dataType: "text"
                }).done(function(resp) {
                    var userList = JSON.parse(resp);

                    // Make sure that the current user is in the list.
                    userList.push(window.usersList.find(x => x.id == globalUserInfo.userId));
                    resolve(userList);
                }).fail(function(resp) {
                    reject(resp);
                });
            } else {
                resolve(window.usersList);
            }
        })
    }

    /**
     * Posts the given request to the app service, inserting a new one.
     * @param {*} request 
     */
    var postRequest = function(request) {
        return new Promise(function(resolve, reject) {
            resolve(postToAppService(appServiceEndpoints.REQUESTS, request));
        })
    }

    /**
     * Puts the given request to the app service, updating the given one. This one replaces all fields.
     * @param {*} request 
     */
    var putRequest = function(request) {
        return new Promise(function(resolve, reject) {
            resolve(putToAppService(appServiceEndpoints.REQUESTS, request));
        })
    }

    /**
     * Puts the given request to the app service, updating the given one. This one replaces only the given fields.
     * @param {*} request 
     */
    var patchRequest = function(request) {
        return new Promise(function(resolve, reject) {
            resolve(patchToAppService(appServiceEndpoints.REQUESTS, request));
        })
    }

    /**
     * This sends over the patch request for updating trans. orders depending on page.
     * @param {JSON} inputObj object to be sent to service.
     * @param {string} endpoint assigned or requested endpoint.
     */
    var updateTransientRecords = function(inputObj, endpoint){
        return new Promise(function(resolve, reject) {
            
            if (endpoint == "assigned") {
                endpoint = appServiceEndpoints.TRANS_ASSIGNED_ORDER
            }
            else if (endpoint == "requested"){
                endpoint = appServiceEndpoints.TRANS_REQUESTED_ORDER
            }

            inputObj['appName'] = 'Workflow';
            resolve(patchToAppService(endpoint, inputObj));
        });
    }

    /**
     * This commits the current request reorder for the request type id currently selected.
     * @param {string} endpoint assigned or requested endpoint.
     */
    var commitOrder = function(endpoint){
        return new Promise(function(resolve, reject){
            if (endpoint == "assigned"){
                endpoint = appServiceEndpoints.COMMIT_DRAFT_ASSIGNED_ORDER;
            }
            else if (endpoint == "requested"){
                endpoint = appServiceEndpoints.COMMIT_DRAFT_REQUESTED_ORDER;
            }
            
            var requestTypeId = parseInt($("#manageRequestsTable_requestTypeDropdown").find('option:selected').attr('requesttypeid'));

            var inputObj = {
                appName: 'Workflow',
                requestTypeId: requestTypeId       
                };
            resolve(patchToAppService(endpoint, inputObj));
        });
    }

    /**
     * Cancel the current reorder for the selected request type id.
     * @param {string} endpoint assigned or requested endpoint.
     */
    var cancelReorder = function(endpoint){
        return new Promise(function(resolve, reject){
            if (endpoint == "assigned"){
                endpoint = appServiceEndpoints.CLEAR_ASSIGNED_ORDER;
            }
            else if (endpoint == "requested"){
                endpoint = appServiceEndpoints.CLEAR_REQUESTED_ORDER;
            }
            
            var requestTypeId = parseInt($("#manageRequestsTable_requestTypeDropdown").find('option:selected').attr('requesttypeid'));

            var inputObj = {
                appName: 'Workflow',
                requestTypeId: requestTypeId       
                };
            resolve(patchToAppService(endpoint, inputObj));
        });
    }

    /**
     * check if the draft columns are locked by current user or another user.
     * @param {json} inputObj object to send to servcice.
     */
    var checkAssignedOrderLock = function(inputObj){
        return new Promise(function(resolve, reject) {
            inputObj['appName'] = 'Workflow';
            resolve(getFromAppService(appServiceEndpoints.CHECK_ASSIGNED_ORDER_LOCK, inputObj));
        });
    }
    /**
     * Add a mapping between notebook and request if we don't have it
     * automatically generating notebooks, but we do want the bidirectional
     * linking.
     * @param {number} itemId The ELN notebook/project ID.
     * @param {number} requestId The request to link to.
     * @param {number} dataType The datatype of the current field. Only 13/14 (notebook/project) are valid.
     */
    var upsertRequestMap = function(itemId, requestId, dataType) {
        return new Promise(function(resolve, reject) {
            var paramObj = {
                "itemId": itemId,
                "requestId": requestId,
                "dataType": dataType
            };
            var url = utilities().buildGetUrl("/arxlab/workflow/upsertRequestMap.asp", paramObj);

            resolve($.ajax({
                url: url
            }));
        });
    }

    /**
     * Adds generated ELN data to the workflow database.
     * @param {*} inputObj The input model for the elnFieldUpdate endpoint.
     */
    var elnFieldUpdate = function(inputObj) {
        return new Promise(function(resolve, reject) {
            resolve(patchToAppService(appServiceEndpoints.ELN_FIELD_UPDATE, inputObj));
        });
    }

    var getRequestName = function(requestId) {
        return new Promise(function(resolve, reject) {
            var nameUrl = appServiceEndpoints.REQUEST_NAME(requestId);
            var inputObj = {appName: window.top.currApp};
            resolve(getFromAppService(nameUrl, inputObj));
        });
    }

    var checkIfUserHasMadeRequests = function() {
        var sendObj = {appName: window.currApp ? window.currApp : "Workflow"};
        ajaxModule().getFromAppService(appServiceEndpoints.GET_HAS_USER_MADE_REQUESTS, sendObj).then(function(res){
            if (res["result"] == "success"){
                if (res['hasUserMadeRequests']){
                    $('body').addClass('showMyRequests');
                }
            }
        });
    }

    /**
     * 
     * @param {Number[]} experimentIdList A list of experiment IDs to link.
     * @param {Number} requestId The request to link.
     * @param {String} requestName The name of the request.
     */
    var insertRequestExperimentLink = function(experimentIdList, requestId) {
        return new Promise(function(resolve, reject) {

            var sendObj = {
                experimentIdList: JSON.stringify(experimentIdList),
                requestId: requestId
            };

            resolve($.ajax({
                url: "/arxlab/workflow/insertRequestExperimentLink.asp",
                type: "POST",
                data: sendObj
            }));
        });
    }

    /**
     * Fetches a list of request types that the current user has canAdd permissions for.
     */
    var getRequestTypesICanAdd = function() {
        return new Promise(function(resolve, reject) {            
            var requestTypeParams = {
                appName: window.top.currApp ? window.top.currApp : "Workflow",
                permissionType: "canAdd"
            }
            resolve(getFromConfigService(configServiceEndpoints.REQUEST_TYPES_BY_PERMISSION_TYPE, requestTypeParams));
        });
    }
    
    /**
     * Fetches a list of request types that the current user has canAdd permissions for.
     */
    var getRequestTypesICanAdd = function() {
        return new Promise(function(resolve, reject) {
            resolve(getRequestTypesByPermission("canAdd"));
        });
    }

    /**
     * Fetches a list of request types that the current user has canEdit permissions for.
     */
    var getRequestTypesICanEdit = function() {
        return new Promise(function(resolve, reject) {
            resolve(getRequestTypesByPermission("canEdit"));
        });
    }

    /**
     * Fetches a list of request types that the current user has canView permissions for.
     */
    var getRequestTypesICanView = function() {
        return new Promise(function(resolve, reject) {
            resolve(getRequestTypesByPermission("canView"));
        });
    }

    /**
     * Fetches a list of request types filtered down by a given permission name.
     * @param {string} permissionName The name of the permission to filter request types down by.
     */
    var getRequestTypesByPermission = function(permissionName) {
        return new Promise(function(resolve, reject) {            
            var requestTypeParams = {
                appName: window.top.currApp ? window.top.currApp : "Workflow",
                permissionType: permissionName,
            }
            resolve(getFromConfigService(configServiceEndpoints.REQUEST_TYPES_BY_PERMISSION_TYPE, requestTypeParams));
        });
    }

    /**
     * Checks if there is a draft requested order.
     * @param {number} requestTypeId The request type ID to check.
     */
    var checkDraftRequestedOrder = function(requestTypeId) {
        return new Promise(function(resolve, reject) {
            var url = appServiceEndpoints.CHECK_DRAFT_REQUESTED_ORDER(requestTypeId);
            var paramObj = {
                appName: window.currApp ? window.currApp : "Workflow"
            };
            resolve(getFromAppService(url, paramObj));
        })
    }

    /**
     * Fetches request type field prioritization options for the given requestTypeId.
     * @param {number} requestTypeId The ID of the request type to get priority options for.
     */
    var getRequestTypeFieldPrioritizationOptions = function(requestTypeId) {
        return new Promise(function(resolve, reject) {
            var url = configServiceEndpoints.GET_REQUEST_TYPE_FIELD_PRIORITY_OPTIONS(requestTypeId);
            var paramObj = {
                appName: window.currApp ? window.currApp : "Workflow"
            }
            resolve(getFromConfigService(url, paramObj));
        });
    }

    /**
     * Makes an Ajax call to convert an ELN legacy ID into an allExperiments ID.
     * @param {number} experimentId The experiment's legacy ID.
     * @param {string} experimentTypeName The abbreviation of the experiment type.
     */
    var getAllExperimentId = async function(experimentId, experimentTypeName) {
        return await $.ajax({
            url: `/arxlab/ajax_checkers/getAllExperimentId.asp?id=${experimentId}&prefix=${experimentTypeName}`
        });
    }

    /**
     * Make a get call to the link service
     * @param {String} baseUrl URL of the request that is being sent. 
     * @param {JSON} paramObj JSON obj of params to be sent over in the request. 
     */
    var getFromLinkService = function(baseUrl, paramObj={}){
        return new Promise(function(resolve, reject) {
            var serviceObj = {
                linkService: true,
                configService: true
            };
            resolve(getFromService(baseUrl, paramObj, serviceObj));
        });
    }

    /**
     * Fetch a single link by ID.
     * @param {number} linkId The ID of the link to fetch.
     */
    var getLinkById = async function(linkId) {
        if (!linkId) {
            return false;
        }
        const url = linkServiceEndpoints.GET_LINK(linkId);
        const paramObj = {
            appName: currApp ? currApp : "Workflow"
        };
        return await getFromLinkService(url, paramObj);
    }

    /**
     * Get all parent links for a specific request id.
     * @param {number} requestId The request id that we are getting the parents of.
     */
    var getRequestParentLinks = async function(requestId) {
        return await getLinksHelper(requestId, applicationEnum.REQUEST);
    }

    /**
     * Get all parent links for a specific request field id.
     * @param {number} requestId The request field id that we are getting the parents of.
     */
    var getRequestFieldParentLinks = async function(requestFieldId) {
        return await getLinksHelper(requestFieldId, applicationEnum.REQUEST_FIELD);
    }

    /**
     * Get all parent links for a specific request item field id.
     * @param {number} requestId The request item field id that we are getting the parents of.
     */
    var getRequestItemFieldParentLinks = async function(requestItemFieldId) {
        return await getLinksHelper(requestItemFieldId, applicationEnum.REQUEST_ITEM_FIELD);
    }

    /**
     * Helper function for getting parent links from the link svc.
     * @param {number} originId The origin ID of the links to fetch.
     * @param {number} originCd The type of object originId is.
     */
    var getLinksHelper = async function(originId, originCd) {
        const url = linkServiceEndpoints.GET_PARENT_LINKS(originCd, originId);
        const paramObj = {
            depth: 1,
            appName: window.currApp ? window.currApp : "Workflow"
        };
        return await getFromLinkService(url, paramObj);
    }

    /**
     * Get an array of links by there ids.
     * @param {String[]} linkIdList Ids that are to be fetched from the service. 
     */
    var getLinksByIds = function(linkIdList) {        
        return new Promise(function(resolve, reject) {
            // Validate input
            if (!linkIdList || !Array.isArray(linkIdList) || linkIdList.length == 0){
                reject("Invalid Input");
            }
             // url param obj
            var paramObj = {
                appName: window.currApp ? window.currApp : "Workflow",
            };
            var promArray = []
            linkIdList.forEach(link => {
                // Setup base Url
                let baseUrl = linkServiceEndpoints.GET_LINK(link); 
                promArray.push(getFromLinkService(baseUrl, paramObj));
            });
           
            Promise.all(promArray).then(function(resp) {
                var decodedLinks = [];
                resp.forEach(response => {
                    decodedLinks.push(utilities().decodeServiceResponce(response));
                });
                resolve(decodedLinks);
            });
            
            
        });
    }

    /**
     * Takes in a array of links to be sent over to the decoder.
     * @param {JSON[]} linkList Links to be decoded.
     */
    var decodeLinks = function(linkList) {
        //Request links can only be a origin for the time being 
        //So we are decoding the targets 
        return new Promise(function(resolve, reject) {
            if (!linkList || !Array.isArray(linkList) || linkList.length == 0){
                reject("Invalid Input");
            }
            // Filter out nulls (due to bad data)
            linkList = linkList.filter(x => x);
            //Seperate everything out for decoding
            var typeCdObj = {};
            linkList.forEach( function(link) {
                var targetCd =  link.targetIdTypeCd ;
                // Add an empty array to the type code object if we don't have one for this targetCd.
                if (!Object.keys(typeCdObj).includes(targetCd.toString())) {
                    typeCdObj[targetCd.toString()] = [];
                }
                // Add this list to the array for this targetCd.
                typeCdObj[targetCd.toString()].push(link);
            });

            //Send the links off to get decoded
            resolve(sendToLinkDecoder(typeCdObj));
        });
    }


    /**
     * Get all links for a specific request id.
     * NOTE: all of the links get stored as a global var (linkData) and will be sent back.
     * @param {number} requestId The request id we are getting links for. 
     */
    var getAllLinksForRequest = function(requestId) {
        return new Promise(function(resolve, reject){
            
            getRequestParentLinks(requestId).then(function(x){
                var data = utilities().decodeServiceResponce(x);

                // Build a JSON so we can organize our link arrays by the type codes we want.
                var typeCdObj = {};

                $.each(data, function(i, link) {
                    var targetCd = link.targetIdTypeCd;

                    // Add an empty array to the type code object if we don't have one for this targetCd.
                    if (!Object.keys(typeCdObj).includes(targetCd.toString())) {
                        typeCdObj[targetCd.toString()] = [];
                    }

                    // Add this list to the array for this targetCd.
                    typeCdObj[targetCd.toString()].push(link);
                });

                resolve(sendToLinkDecoder(typeCdObj));
             
            })
        });
    }

    /**
     * Send links to the decoder and then set them into a global var.
     * @param {JSON} linkObj Json object of links seperated by type.
     */
    var sendToLinkDecoder = function(linkObj) {
        return new Promise(function(resolve, reject){
            if (!linkObj) {
                reject("Invalid input.");
            }
            //Go through all typed cds and send them to the docoder.
            var linkPromises = [];
            $.each(Object.keys(linkObj), function(i, type) {
                var linkList = linkObj[type];
                linkPromises.push(decodeLink(linkList, type));
            })

            // When we're done, flatten the array so its one array of objects, rather than an array of array of objects.
            Promise.all(linkPromises).then( function(links) {
                if (window.top.linkData && Array.isArray(window.top.linkData)) {
                    window.top.linkData = window.top.linkData.concat(links.flat()); 
                }
                else {
                    window.top.linkData = links.flat();
                }
                resolve(window.top.linkData);
            });
        });
    }
    

    /**
     * Sends the entity IDs in the given list of links to the decoder page to fetch metadata so that links can be displayed.
     * @param {JSON[]} linkList The list of links to send for the given type code.
     * @param {number} typeCd The type code of the entities to decode.
     */
    var decodeLink = function(linkList, typeCd) {
        // We only care about translating information for targetIds.
        var entityIdList = linkList.map(x => x.targetId);

        return new Promise(function(resolve,reject){
            $.ajax({
                url: `../entityDecode/decode.asp`,
                type: 'POST',
                data: {
                    objectTypeCd: typeCd,
                    objectIdList: JSON.stringify(entityIdList)
                },
                tryCount : 0,
                dataType: 'json',
            }).done(function(resp){

                // For every entity decoded, add the link's ID and description to the object.
                $.each(resp, function(i, respData) {
                    link = linkList[i];
                    // Let's make sure we don't overwrite the important item in this object.
                    respData["linkSvcId"] = link.id;
                    respData["description"] = link.description;
                });
                resolve(resp);
            }).fail(function(error,textStatus, errorThrown){
                reject();
            });            
        });
    }

    /**
     * Sends a request name to an ASP endpoint to update the names of the requested projects.
     * @param {number[]} unnamedProjectList The list of unnamed project IDs.
     * @param {string} requestName The name of the request that generated the projects.
     */
    var updateProjectsWithName = function(unnamedProjectList, requestName) {
        return new Promise(function(resolve, reject) {
            const postObj = {
                projectIds: JSON.stringify(unnamedProjectList),
                name: requestName,
            };
    
            $.ajax({
                url: "/arxlab/projects/updateProjectNames.asp",
                type: 'POST',
                data: postObj,
            }).done(function(resp) {resolve(resp)});
        });
    }

    /**
     * Send the given workflow file to the attachments table of the given experiment.
     * @param {number} fileId The ID of the file to send to the attachments table.
     * @param {number} experimentId The ID of the experiment.
     * @param {number} experimentTypeId The ID of the experiment type.
     * @param {number} experimentOwnerId The ID of the owner of the experiment.
     */
    var sendFileToELNExperiment = function(fileId, experimentId, experimentTypeId, experimentOwnerId) {
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: "/arxlab/ajax_doers/copyWorkflowFileToExperiment.asp",
                data: {
                    "fileId": fileId,
                    "id": experimentId,
                    "type": experimentTypeId,
                    "ownerId": experimentOwnerId,
                }
            }).done(function(resp) {
                resolve(resp);
            });
        });
    }

    /**
     * Helper function to set a new experiment draft for the given id/type combo.
     * @param {number} experimentId The experiment's ID
     * @param {number} experimentTypeId The experiment's type ID
     */
    var setExperimentDraft = function(experimentId, experimentTypeId) {
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: `/arxlab/experiments/ajax/do/saveDraft.asp?experimentId=${experimentId}&experimentType=${experimentTypeId}&c=true`,
                data: {
                    thePairs: JSON.stringify([{"theKey": "experimentId", "theVal": experimentId}])
                },
                type: "POST",
            }).done(function() {
                resolve(true);
            });
        });
    }

    /**
     * Reaches out to the config service to retrieve a list of allowed applications.
     */
    let getAllowedApps = async function() {
        let paramObj = {
            appName: "configuration"
        };
        let appList = await getFromConfigService(configServiceEndpoints.GET_ALLOWED_APPS, paramObj);
        return utilities().decodeServiceResponce(appList);
    }

    /**
     * Reaches out to the config service to retrieve a list of custom attribute definitions
     * for the given applicationTypeId, if one exists.
     * @param {number} applicationTypeId The ID of the application we want to get custom data for.
     */
    let getVendorEndpointData = async function(applicationTypeId) {
        let paramObj = {
            appName: "configuration"
        };
        let endpointResp = await getFromConfigService(configServiceEndpoints.GET_VENDOR_ENDPOINT(applicationTypeId), paramObj);

        if (endpointResp.result == "error") {
            console.error(endpointResp.error);
            return [];
        }

        return utilities().decodeServiceResponce(endpointResp);
    }

    /**
     * Loads the Bio Editor
     */
    const loadBioEditorComponent = function() {
        return new Promise(function(resolve, reject) {
            // check to see if we already have the bio componant set up 
            if (!window.BioInterCom) {
                $.ajax({
                    url: "/node/BioEditorPopup",
                    verb: "GET"
                })
                .done(function(resp) {
                    resolve($('#BioDiv').html(resp));
                })
                .fail(function(error) {
                    reject(error)
                })
            }
        })
    }

    /**
     * Send a ajax call to an asp endpoint to add the bio eidior to the pdfProcQueue.
     * @param {String} expId The ELN experiment id. 
     * @param {Number} revisionNumber The revision the ediotr is tied to.
     * @param {String} editorId The uuid of the bio editor. 
     */
    var addEditorToProcQueue = function(expId, revisionNumber, editorId) {
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: "/arxlab/ajax_doers/addBioEditorToPdfProcQueue.asp",
                type: 'POST',
                data: {
                    expId: expId,
                    revisionNumber: revisionNumber,
                    editorId: editorId
                }
            }).then(function(resp){
                if (resp == "Done") {
                    resolve(resp);
                }
                else {
                    reject(resp)
                }
            }).fail(function(resp){
                reject(resp);
            });
        });
    }

    return{
        processRequestTypesArray: processRequestTypesArray,
        fetchAuditTrailAuthors: fetchAuditTrailAuthors,
        getQueueableRequests: getQueueableRequests,
        fetchSpecificRequest: fetchSpecificRequest,
        loadRequestPreviewStructureImages: loadRequestPreviewStructureImages,
        populateRequestItemTypesList: populateRequestItemTypesList,
        populateSavedFieldsList: populateSavedFieldsList,
        makeFieldsDict: makeFieldsDict,
        processCDXML: processCDXML,
        CDXToCDXML: CDXToCDXML,
        searchReg: searchReg,
        registerCompound: registerCompound,
        searchAccord: searchAccord,
        getDropdowns: getDropdowns,
        submitField: submitField,
        submitDropdown: submitDropdown,
        fetchFileUploadSetting: fetchFileUploadSetting,
        storeFileUploadSetting: storeFileUploadSetting,
        notificationServiceHealthCheck: notificationServiceHealthCheck,
        getUnreadNotifications: getUnreadNotifications,
        getUnreadNotificationsCount: getUnreadNotificationsCount,
        patchNotification: patchNotification,
        patchNotificatonReadDate: patchNotificatonReadDate,
        getRequests: getRequests,
        getRequestRevision: getRequestRevision,
        postBrowserNotification: postBrowserNotification,
        getUsersWhoCanSeeThisExp: getUsersWhoCanSeeThisExp,
        getRequestTypes: getRequestTypes,
        getRequestItemTypes: getRequestItemTypes,
        getFields: getFields,
        getCodes: getCodes,
        getVersionedConfigData: getVersionedConfigData,
        isThisTheMostRecent: isThisTheMostRecent,
        getFromAppService: getFromAppService,
        getFromAdminService: getFromAdminService,
        postToAppService: postToAppService,
        putToAppService: putToAppService,
        postRequest: postRequest,
        putRequest: putRequest,
        patchRequest: patchRequest,
        updateTransientRecords: updateTransientRecords,
        commitOrder: commitOrder,
        checkAssignedOrderLock: checkAssignedOrderLock,
        cancelReorder: cancelReorder,
        upsertRequestMap: upsertRequestMap,
        elnFieldUpdate: elnFieldUpdate,
        getRequestName: getRequestName,
        checkIfUserHasMadeRequests: checkIfUserHasMadeRequests,
        insertRequestExperimentLink: insertRequestExperimentLink,
        getRequestTypesICanAdd: getRequestTypesICanAdd,
        getRequestTypesICanEdit: getRequestTypesICanEdit,
        getRequestTypesICanView: getRequestTypesICanView,
        checkDraftRequestedOrder: checkDraftRequestedOrder,
        getLinkById: getLinkById,
        getAllLinksForRequest: getAllLinksForRequest,
        getRequestFieldParentLinks: getRequestFieldParentLinks,
        getRequestItemFieldParentLinks: getRequestItemFieldParentLinks,
        decodeLink: decodeLink,
        getAllExperimentId: getAllExperimentId,
        getLinksByIds: getLinksByIds,
        decodeLinks: decodeLinks,
        updateProjectsWithName: updateProjectsWithName,
        sendFileToELNExperiment: sendFileToELNExperiment,
        setExperimentDraft: setExperimentDraft,
        getAllowedApps: getAllowedApps,
        getVendorEndpointData: getVendorEndpointData,
        loadBioEditorComponent: loadBioEditorComponent,
        addEditorToProcQueue: addEditorToProcQueue,
    }

});// ajaxModule().