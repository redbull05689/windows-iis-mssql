var utilities = (function() {

    var notifyJSTemplates = {
        "default": '<div data-notify="container" class="col-xs-11 col-sm-3 alert alert-{0}" role="alert">' +
                    '<button type="button" aria-hidden="true" class="close" data-notify="dismiss">x</button>' +
                    '<span data-notify="icon"></span> ' +
                    '<span data-notify="title">{1}</span> ' +
                    '<span data-notify="message">{2}</span>' +
                    '<div class="progress" data-notify="progressbar">' +
                    '<div class="progress-bar progress-bar-{0}" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>' +
                    '</div>' +
                    '<a href="{3}" target="{4}" data-notify="url"></a>' +
                    '</div>',
    }

    var makeAjaxPost = function(serviceUrl, inputData, serviceObj) {
        console.log("Making POST call to: " + serviceUrl);
        return new Promise(function(resolve, reject) {
            resolve(makeAjaxCall(serviceUrl, inputData, "POST", serviceObj));
        });
    };

    var makeAjaxGet = function(serviceUrl, serviceObj) {
        console.log(`Making GET call to: ${serviceUrl}`);
        return new Promise(function(resolve, reject) {
            resolve(makeAjaxCall(serviceUrl, {}, "GET", serviceObj));
        })
    }

    var makeAjaxPatch = function(serviceUrl, inputData, serviceObj) {
        console.log(`Making PATCH call to: ${serviceUrl}`);
        return new Promise(function(resolve, reject) {
            resolve(makeAjaxCall(serviceUrl, inputData, "PATCH", serviceObj));
        })
    }

    var makeAjaxPut = function(serviceUrl, inputData, serviceObj) {
        console.log(`Making PUT call to: ${serviceUrl}`);
        return new Promise(function(resolve, reject) {
            resolve(makeAjaxCall(serviceUrl, inputData, "PUT", serviceObj));
        })
    }

    var makeAjaxCall = function(serviceUrl, inputData, verb, serviceObj) {
        return new Promise(function(resolve, reject) {
            var retries = 30;
            var timeoutMillis = 60000;
            var serialUUID = uuidv4();

            $.ajax({
                url: "/arxlab/workflow/invp.asp",
                type: 'POST',
                tryCount : 0,
                retryLimit : retries,
                timeout: timeoutMillis,
                dataType: 'json',
                serialUUID: serialUUID,
                data: {
                    //async: "async",
                    verb: verb,
                    url: serviceUrl,
                    data: JSON.stringify(inputData),
                    config: serviceObj["configService"],
                    adminService: serviceObj["adminService"],
                    appService: serviceObj["appService"],
                    notificationService: serviceObj["notificationService"],
                    linkService: serviceObj["linkService"],
                    serialUUID: serialUUID
                },
                async: true
            }).done(function(data){
                ajaxDone(data, resolve, reject);
            }).fail(function(error,textStatus, errorThrown){
                ajaxFail(error, textStatus, errorThrown, this, resolve, reject);
            });
        });
    }

    var ajaxDone = function(response, resolve, reject){
        if (response.hasOwnProperty("error")){
            if (response.error == "repeat request"){
                reject("repeat request");
                return;
            }
        }
        resolve(response);
    };

    /**
     * Handler for a failed AJAX call.
     * @param {*} error The error
     * @param {*} textStatus The status of the request.
     * @param {*} errorThrown The error thrown.
     * @param {*} ajaxObject The ajax object.
     * @param {*} resolve The resolve function of a promise.
     * @param {*} reject The reject function of a promise.
     */
    var ajaxFail = function(error, textStatus, errorThrown, ajaxObject, resolve, reject) {
        if (textStatus == 'timeout') {
            console.log("MAKE AJAX CALL, TIMEOUT. Try: " + (ajaxObject.tryCount + 1) + " UUID: " + ajaxObject.serialUUID);
            ajaxObject.tryCount++;
            if (ajaxObject.tryCount <= ajaxObject.retryLimit) {
                //try again
                ajaxObject.timeout *= 2;
                console.log("Try again new timeout: " + ajaxObject.timeout);
                $.ajax(ajaxObject).done(function(response){
                    ajaxDone(response, resolve, reject);
                }).fail(function(error,textStatus, errorThrown){
                    ajaxFail(error, textStatus, errorThrown, ajaxObject, resolve, reject);
                });
            }else{
                console.error("TIMEOUT ERROR ", error);
                swal("Timeout", "Please try your request again.", "error");
                reject(textStatus);
            }
        }else{
            console.error("ERROR", error);
            reject(error.responseText);
        }
    };

    // Makes a UUID, stolen from https://stackoverflow.com/a/2117523/3009411
    var uuidv4 = function() {
        return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
            (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
        );
    };

    var boolToInt = function(val) {
        return val ? 1 : 0;
    };


    var resetItemHover = function(table){

        setTimeout(function(){
            
            storedLargeImgs = {};

            var rows = table.children('tbody').children('tr');
            var itemTypeId = table.attr('requestItemTypeId');
            var fieldId = table.children('tbody').children('tr').find('.structureDisplay').attr('requestitemtypefieldid');
            var leftWrapperRows = table.parent().parent().siblings('div.DTFC_LeftWrapper').children(".DTFC_LeftBodyWrapper").find('tbody').children();
            $.each(rows, function(index, row){
                var liveID = "itemType_" + itemTypeId + "_" + index + "_" + fieldId;
                var activeRow = leftWrapperRows[index];

                if (activeRow != undefined)
                {
                    $($(activeRow).children().find('.structureImageContainer').children()[0]).attr('liveeditid', liveID);
                    $($(activeRow).children().find('.structureImageContainer').children()[1]).attr('liveeditid', liveID);
                    if ($(activeRow).children().find('.structureImageContainer').children().hasClass('mjs'))
                    {
                        $($(activeRow).children().find('.structureImageContainer').children()[0]).attr('onclick', "editMJSPopup('" + liveID + "');");
                    }
                    else
                    {
                        $($(activeRow).children().find('.structureImageContainer').children()[0]).attr('onclick', "editStructure('" + liveID + "');");
                    }
                    $($(activeRow).children().find('.structureImageContainer').children()[1]).attr('discardliveeditid', liveID);
                }

            
                getUpdatedLiveEditHoverImage(liveID);

            });

        },500, table);

    };

    var sortHelper = function(arr, key, callbackFn) {
        // Do this operation on a clone of arr so we don't accidentally overwrite it.
        var sortedArr = [...arr].sort(function(a,b) {
            return (callbackFn(a[key]) > callbackFn(b[key]) ? 1 : callbackFn(b[key]) > callbackFn(a[key]) ? -1 : 0);
        })
    
        return sortedArr;
    }

    /**
     * Sort an array of JSON by a specific key
     * @param {JSON[]} arr Array to sort
     * @param {String} key Key to sort on
     * @returns {JSON[]}
     */
    var sortArray = function(arr, key) {
        if (typeof arr == "object" && arr.length > 0){
            if (typeof arr[0][key] == "string")
            {
                return sortHelper(arr, key, (x) => x.toLowerCase());
            }
            else
            {
                return sortHelper(arr, key, (x) => x);
            }
        }
        return arr;
    }

    var addResumableToItem = function(versionedRequestItems, versionedFields) {
        $.each($(".requestItemFieldFileAttachmentForm").not(":has(.resumable-drop)"), function(attachmentIndex, attachmentField) {
    
            var inputField = $(attachmentField);
    
            var existingFile = inputField.find("a");

            var fileId = inputField.attr("fileid");
            var fileName = inputField.attr("filename");
            
            if (fileName.length > 40) {
                fileName = fileName.substring(0, 40);
                fileName = $.trim(fileName) + "...";
            }

            if (![undefined, "-1"].includes(fileId)) {
                existingFile.text(fileName);
                existingFile.attr("href", 'getSourceFile.asp?fileId=' + fileId)
            }
            
            var resumableCurrFile = $("<div class='currFile'></div>").append(existingFile);
            var resumableBrowse = $("<button class='resumable-browse'>Choose File</button>");
            var fileDiv = $("<div></div>").addClass("resumableFileInfo");
            fileDiv.append(resumableBrowse).append(resumableCurrFile);
    
            inputField.find(".currentFile").hide();
            inputField.find(".editorFieldInput").hide();
            inputField.find(".requestItemFieldFileAttachmentSubmitButton").hide();
    
            var fileUploadContainer = $("<div></div>").addClass("fileUploadContainer").append(fileDiv);
    
            var resumableDiv = $("<div></div>").addClass("resumable-drop").append(fileUploadContainer);
    
            var resumableOptions = {
                target: '/excel2CSV/Upload',
                query: {
                    connectionId: connectionId,
                    companyId: companyId,
                    userId: globalUserInfo.userId,
                    appName: "Workflow",
                },
                headers: {Authorization: jwt},
                generateUniqueIdentifier: resumableGenerateUniqueIdentifier,
                minFileSize: 0,
            }
    
            var fileAddedCallbackFn = function(file, rObj) {
                
                var fileDisplayText = file.fileName;
                
                if (fileDisplayText.length > 44) {
                    fileDisplayText = fileDisplayText.substring(0, 44);
                    fileDisplayText = $.trim(fileDisplayText) + "...";
                }
    
                inputField.find(".currentFileLink").text("Current file: " + fileDisplayText);
                $("#basicLoadingModal").show();
                rObj.upload();
            }
    
            var fileSuccessCallbackFn = function(file, response) {
                $("#basicLoadingModal").hide();
                var responseObj = typeof (response) == "string" ? JSON.parse(response) : response;
    
                inputField.attr("fileid", responseObj.fileId);
                inputField.attr("filename", file.fileName);
    
                if (responseObj.fileId != -1) {
                    console.log(responseObj.fileId);
                    $.notify({
                        title: "Successfully uploaded file attachment.",
                        message: ""
                    }, {
                        delay: 4000,
                        type: "success",
                        template: notifyJSTemplates.default
                    });

                    dataTableModule().updateRequestItemsTableDataAndRedraw(inputField, versionedRequestItems, versionedFields)
                        .then(function (obj) {
                            addResumableToItem(versionedRequestItems, versionedFields);
                        });
                }
            }
    
            var fileErrorCallbackFn = function(file, response) {						
                $.notify({
                    title: "Failed to upload file attachment.",
                    message: ""
                }, {
                        delay: 0,
                        type: "danger"
                    });
            }
    
            var resumableObject = resumableModule(resumableOptions, inputField, resumableBrowse, false);
            resumableObject.addFileCallback(fileAddedCallbackFn);
            resumableObject.addFileSuccessCallback(fileSuccessCallbackFn);
            resumableObject.addFileErrorCallback(fileErrorCallbackFn);
            //resumableObject.addFileProgressCallback(fileProgressCallbackFn);
    
            inputField.empty();
            inputField.append(resumableDiv);
        });
    }

    var sortDropdownlist = function(dropdown) {
        // Make sure the sorting is case insensitive /and/ ignores leading and trailing spaces.
        dropdown.html(dropdown.find('option').sort(function (x, y) {
            return $(x).text().toLowerCase().trim() > $(y).text().toLowerCase().trim() ? 1 : -1;
        }));
        dropdown.prop("selectedIndex", 0);
    };

    var showLoadingModal = function() {
        $("#basicLoadingModal").modal("show");
    }
    
    var hideLoadingModal = function() {
        $("#basicLoadingModal").modal("hide");
    }

    var resizeManageRequestsTable = function() {
        return new Promise(function(resolve, reject) {
            var heightToUse = window.top.window.innerHeight;
            var dataTableBuffer = 335;
            var windowHeightMinusOtherElements = heightToUse - dataTableBuffer;
            // This isn't great because it's applying a height to the requestItems tables too, but it gets overwritten immediately
            $('body:not(.pageWithIndividualRequestEditor) #manageRequestsTable_wrapper .dataTables_scrollBody').css('height', `${windowHeightMinusOtherElements}px`);
            $('body:not(.pageWithIndividualRequestEditor) .sdfTableContainer .dataTables_scrollBody').css('height', `${(windowHeightMinusOtherElements - 100)}px`);
            $('body.pageWithIndividualRequestEditor .sdfTableContainer .dataTables_scrollBody').css('height', `${windowHeightMinusOtherElements}px`);
            if ($.fn.DataTable.isDataTable("#manageRequestsTable")){
                $("#manageRequestsTable").DataTable().columns.adjust();
            }
            resolve();
        });
    }

    /**
     * Displays the unsaved changes notification and marks the given inputElement as dirty.
     * @param {*} inputElement The HTML element that called into this function.
     */
    var showUnsavedChangesNotification = function(inputElement) {
        console.log("SHOWING UNSAVED CHANGES NOTIFICATION");
        // In the future when we think the unsaved changes triggers are all perfect, we can implement something that uses a unique array to track which things triggered the unsaved changes
        // The array would look like this: ["Wuxi-54-G", "Wuxi-34-M", "reorderedRequests"]
        // ... Basically if it has its own call to close the unsaved changes notification, it needs a single unique item in the array
        // ... Then the close function would remove an item from the array and check the array length before closing
    
        if (window.preventNotification == 1)
        {
            return;
        }

        if (inputElement) {
            inputElement.closest(".editorField").attr("dirty", true);
            console.log(inputElement);
        }

        // If we're in an iFrame, then don't show the workflow unsaved changes message, show the ELN one.
        if (self != top) {
            if (window.top.canWrite) {
                window.parent.showOverMessage("unsavedChanges", "page");
                window.parent.unsavedChanges = true;
            } else {
                return;
            }
        } else {
            displayUnsavedChangesNotification();
        }
        $("#UpdateRequestButtons").fadeIn("slow");
    };
    
    /**
     * Closes the unsaved changes notification.
     */
    var closeUnsavedChangesNotification = function() {
        if (self != top) {
            window.parent.hideUnsavedChanges();
            window.parent.unsavedChanges = false;
        } else {
            // Need to give it enough time to make sure our count of open editors comes after the editor is actually closed
            hideUnsavedChangesNotification();
        }
    }

    /**
     * Initialize the unsaved changes notification using $.notify.
     */
    var displayUnsavedChangesNotification = function() {
        // Only run $.notify() if it's not already open
        if (!window.unsavedChangesNotificationOpen) {
            window.unsavedChangesNotification = $.notify({
                title: "You have unsaved changes.",
                message: ""
            }, {
                    delay: 0,
                    type: "unsavedChangesNotification",
                    placement: {
                        from: "top",
                        align: "center"
                    },
                    allow_dismiss: false,
                    animate: {
                        enter: 'animated fadeInDown',
                        exit: 'animated fadeOutUp'
                    }
                });
            window.unsavedChangesNotificationOpen = true;
        }
    }

    /**
     * Dismiss the unsaved changes notification if its open.
     */
    var hideUnsavedChangesNotification = function() {
        setTimeout(function () {
            if (window.unsavedChangesNotificationOpen) {
                if ($('.alert-unsavedChangesNotification.fadeInDown').length != 0) {
                    window.unsavedChangesNotification.close();
                    window.unsavedChangesNotificationOpen = false;
                }
            }
        }, 200);
    }

    /**
     * Checks if the current user is a member of a group, specified by name.
     * @param {string} groupName The name of the group to check.
     */
    var userIsMemberOfGroupByName = function(groupName) {
        var userIsMemberOfGroup = false;
        var group = window.groupsList.find(x => x["name"] == groupName);
        if (group) {
            userIsMemberOfGroup = $.inArray(group["id"], window.globalUserInfo["userGroups"]) !== -1;
        }
        return userIsMemberOfGroup;
    }

    var runOnce = false;
    var resizeCustExpIframe = function() {
        if (window.self == window.parent) {
            return false;
        }

        var heightToUse = Math.max($(".col-md-12").height(), $(".container-fluid").height());
        window.parent.$("#tocIframe").height(heightToUse);

        if (runOnce != true) {
            runOnce = true;
            setTimeout(function () {
                var tablesArray = $('.dataTables_scrollBody > .requestItemEditorTable');
                $.each(tablesArray, function () {
                    $(this).DataTable().draw();
                })
            }, 2000);
        }
    }

    var calculateOffset = function() {
        var offsetVal = 0;
    
        if (window.self != window.parent) {
    
            var iframeOffset = window.parent.$("#tocIframe")[0].getBoundingClientRect().top;
            offsetVal = iframeOffset > 0 ? 0 : iframeOffset * -1;
        }
    
        return offsetVal;
    }

    var populateRegLink = function(targetElement, dataTypeId, regIds, versionedRequestItems, versionedFields) {

        var regFields = [];
        var liveEditIdSelector = `[liveeditid=${targetElement}]`;
        var dataTypeIdSelector = `[datatypeid=${dataTypeId}]`;
        var isRequestEditorLink = $(liveEditIdSelector).parents(".editorFieldInputContainer").length > 0
        if (isRequestEditorLink) {
            regFields = $(liveEditIdSelector).parents(".editorSection.card").find(`${dataTypeIdSelector} > div.editorFieldInputContainer`);
        } else {
            regFields = $(liveEditIdSelector).closest("tr").find(dataTypeIdSelector);
        }

        $.each(regFields, function(regFieldIndex, regField) {
            var aLink = $(regField).find("a");
            //var storedId = storedRegIds[targetElement];

            $.each(regIds, function(regIdIndex, storedId) {
                var regLink = "javascript:void(0)";
                if (storedId) {

                    if (dataTypeId == dataTypeEnums.REGISTRATION) {
                        regLink = "/arxlab/registration/showReg.asp?regNumber=" + storedId
                    }

                    aLink.text(storedId);
                    aLink.attr("href", regLink);
                    aLink.attr("target", "_blank");
                    aLink.val(storedId);
                } else {
                    aLink.text("New Compound");
                    aLink.attr("href", regLink);
                    aLink.val("-1");
                }

                if (!isRequestEditorLink) {
                    dataTableModule().updateRequestItemsTableDataAndRedraw(aLink, versionedRequestItems, versionedFields);
                }
            });
        });
    }

    var addStructureToReg = function(targetElement, versionedRequestItems, versionedFields) {
        return new Promise(function(resolve, reject) {
            var structure = unescape($("[liveeditid='" + targetElement + "']").attr("moldata"));

            if (structure === undefined || getRegFieldVal(targetElement)["href"] !== undefined) {
                resolve(true);
            } else {

                convertMrvToMol(structure).then(function(response) {
    
                    if (response === undefined) {
                        resolve(true);
                    } else {
                        var molStructure = response.structure;
                        ajaxModule().registerCompound(molStructure).then(function() {
                            searchRegForStructure(targetElement, molStructure, versionedRequestItems, versionedFields);
                            resolve(true);
                        });
                    }
                })
            }
        })
    }

    var searchRegForStructure = function(targetElement, versionedRequestItems, versionedFields) {
        getChemistryEditorChemicalStructure(targetElement, false).then(function(response){
            molData = response;
            if (![getEmptyEncodedMolFile(), getEmptyMolFile()].includes(molData))
            {
                $("[liveeditid=" + targetElement + "]").closest("tr").find("[datatypeid=" + dataTypeEnums.REGISTRATION + "] > a").text("Searching...");
                confirmLiveEditFormat(molData).then(function(molDataResp) {
                    ajaxModule().searchReg(molDataResp).then(function(response) {
                        var regIds = [response['localRegNumber']];
                        //storedRegIds[targetElement] = response["localRegNumber"];
                
                        populateRegLink(targetElement, dataTypeEnums.REGISTRATION, regIds, versionedRequestItems, versionedFields);
                    });
                });
            }
        });
    }

    var parseXMLStr = function(xmlStr) {
        var xmlObj = $.parseXML(xmlStr);
        return $(xmlObj);
    }

    var searchForeignReg = function(targetElement) {
        var element = $("[liveeditid='" + targetElement + "'");
        var foreignRegLink = element.closest("tr").find("[datatypeid=" + dataTypeEnums.FOREIGN_LINK + "] > a");        
        var moldata = unescape(element.attr("moldata"));

        if (!["", "New Compound", "No link"].includes(foreignRegLink.text()) || moldata == "undefined") {
            return;
        }

        foreignRegLink.text("Searching...");            

        convertMrvToMol(moldata).then(function(structureObj) {
            var structure = structureObj.structure;

            if (isAccordCompany()) {
                doAccordSearch(structure, targetElement);
            }
        });
    }

    var isAccordCompany = function() {
        return globalUserInfo.whichClient == "SUNOVION" || globalUserInfo.whichClient == "APOLLO";
    }
    
    var confirmLiveEditFormat = function(molData) {
        return new Promise(function(resolve, reject) {
            var chemFormat = getFileFormat(molData);
            if (chemFormat == "mrv" || chemFormat == "base64:cdx") {
                convertMrvToMol(molData).then(function(response) {
                    resolve(response["structure"]);
                });
            } else {
                resolve(molData);
            }
        });
    }
    
    var convertMrvToMol = function(mrvStr) {
        return new Promise(function(resolve, reject) {
    
            var fileFormat = getFileFormat(mrvStr);
    
            if (!["mrv", "cdxml", "base64:cdx"].includes(fileFormat)) {
                resolve(mrvStr);
            }
    
            var jchemProxyLoc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport";
            var theData = {"structure": mrvStr, "inputFormat": fileFormat, "parameters": "mol:V3"};
    
            $.ajax({
                method: "POST",
                dataType: "json",
                url: jchemProxyLoc,
                data: JSON.stringify(theData)
            }).done(function(response) {
                resolve(response);
            });
        });
    }

    var searchRequestsForStructure = function(targetElement) {
        return new Promise(function(resolve, reject) {
            getChemistryEditorChemicalStructure(targetElement, false).then(function(response){
                molData = response;
                confirmLiveEditFormat(molData).then(function(molDataResp) {
                    getCDID(targetElement, molDataResp).then(function(response) {

                        var cdId = response["response"];
                        var requestTypeId = $("#requestTypeDropdown").find("option:selected").attr("requestTypeId");
                        requestTypeId = requestTypeId ? requestTypeId : thisRequestType["id"];

                        var checkCdIdEndpoint = appServiceEndpoints.CHECK_REQUESTS_BY_CDID(requestTypeId, cdId);
                        var currAppName = window.top.currApp ? window.top.currApp : "Workflow";

                        ajaxModule().getFromAppService(checkCdIdEndpoint, {appName: currAppName}).then(function(response) {
                            console.log(response)
                            if (response["result"] == "success" && response["data"] != "[]")
                            {
                                var PromiseArray = [];
                                var responseData = JSON.parse(response["data"]);

                                $.each(responseData, function(responseIndex, requestIdObj) {
                                    PromiseArray.push(new Promise(function(resolve, reject) {
                                        var retObj = {};

                                        var requestId = requestIdObj["id"];
                                        var inputParams = {
                                            appName: window.top.currApp ? window.top.currApp : "Workflow"
                                        };

                                        ajaxModule().getRequests(requestId, inputParams).then(function(requestResponse) {
                                            retObj[requestId] = requestResponse["requestName"];
                                            resolve(retObj);
                                        })

                                    }));
                                });

                                resolve(PromiseArray);
                            }
                            else
                            {
                                $(`[liveeditid=${targetElement}]`).closest("tr").find(`[datatypeid=${dataTypeEnums.REQUEST}] > a`).text("No Requests Found.");
                            } 
                        })
    
                    }).catch(function(){
                        $(`[liveeditid=${targetElement}]`).closest("tr").find(`[datatypeid=${dataTypeEnums.REQUEST}] > a`).text("No Requests Found.");
                    });
                });
            });
        });
    }


    var getCDID = function(targetElement, molData) {
        return new Promise(function(resolve, reject) {
            var fileFormat = getFileFormat(decodeURI(molData));
            var jchemProxyLoc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport";
            var theData = {"structure": decodeURIComponent(molData), "inputFormat": fileFormat, "parameters": "mol:V3"};
            $.ajax({
                method: "POST",
                dataType: "json",
                url: jchemProxyLoc,
                targetElement: targetElement,
                contentType: "application/json",
                data: JSON.stringify(theData)
            }).done(function(response) {
                $.ajax({
                    url: "getCd_IdByMolData.asp",
                    type: 'POST',
                    targetElement: this.targetElement,
                    dataType: 'json',
                    data:{mol: response["structure"]}
        
                }).done(function(response) {
                    retObj = {}
                    retObj["tElm"] = this.targetElement;
                    retObj["response"] = response;
                    resolve(retObj);
                }).fail(function(response) {
                    retObj = {}
                    retObj["tElm"] = this.targetElement;
                    retObj["response"] = response;
                    reject(retObj);
                });
            });

        });
    }

    var autoFillRequestField = function(targetElement, requestItem, versionedRequestItems, versionedFields){
        if (requestItem == true)
        {
            var field = $("[liveeditid=" + targetElement + "]").closest("tr").find("[datatypeid=" + dataTypeEnums.REQUEST + "] > a")
            if (field.length > 0)
            {
                $(field).text("Searching...");
                searchRequestsForStructure(targetElement).then(function(responce){
        
                    Promise.all(responce).then(function(Pval){
                        console.log(Pval);
                        console.log(targetElement);
                        
                        //cell.closest('table').DataTable().cells(cell).data(Pval).draw();
        
                        
                        var divRef = $("[liveeditid=" + targetElement + "]").closest("tr").find("[datatypeid=" + dataTypeEnums.REQUEST + "]")
                        $(divRef).empty()
                        $.each(Pval, function(index, val){
                            $.each(val, function(key, val){
                                var temp = $('<a class="btn btn-info btn-sm">No link</a>');
                                $(temp).attr('reqID', key);
                                $(temp).text(val);            
                                divRef.append(temp);
                            });
                        }); 
        
        
                        dataTableModule().updateRequestItemsTableDataAndRedraw(divRef.children('a'), versionedRequestItems, versionedFields,false)
                        
                    });
        
                });
            }
            
        }
        else 
        {

            var field = $("[liveeditid=" + targetElement + "]")
            .closest(".editorSection")
            .children('[datatypeid=' +  dataTypeEnums.REQUEST + ']')
            .children('div')
            .children('a');
            
            if (field.length > 0)
            {

                $(field).text("Searching...");
                searchRequestsForStructure(targetElement).then(function(responce){
        
                    Promise.all(responce).then(function(Pval){
                        console.log(Pval);
                        console.log(targetElement);
                                             
                        
                        var divRef = $("[liveeditid=" + targetElement + "]")
                        .closest(".editorSection")
                        .children('[datatypeid=' +  dataTypeEnums.REQUEST + ']')
                        .children('div');
                        $(divRef).empty('a');
                        $(divRef).not(':first-of-type').remove();
                        $.each(Pval, function(index, val){
                            $.each(val, function(key, val){
                                var temp = $('<a class="btn btn-info btn-sm">No link</a>');
                                $(temp).attr('reqID', key);
                                $(temp).attr("target", "_blank");
                                $(temp).attr("href", "JavaScript:Void(0);");
                                $(temp).attr("onClick", "utilities().showReq(" + key + ")");
                                $(temp).text(val);            
                                divRef.append(temp);
                            });
                        }); 
        
        
                     
                        
                    });
        
                });

            }

        }
        
    };

    var showReq = function(requestId)
	{
		
		var width = ($(window).width()/3)*2,
			height = ($(window).height()/3)*2 ,
			left = ($(window).width() - width) / 2,
			top = ($(window).height() - height) / 2,
			url = "viewIndividualRequest.asp?base=true&inFrame=true&requestid=" + requestId,
			opts = 'status=1' +
					',width=' + width +
					',height=' + height +
					',top=' + top +
					',left=' + left;

		window.open(url, 'twitte', opts);

    }
    
    var doAccordSearch = function(structure, targetElement) {
        ajaxModule().searchAccord(structure).then(function(response) {
            var foreignRegNumbers = [];
            var xmlResp = parseXMLStr(response);

            var resultsNode = xmlResp.find("results");
            $.each(resultsNode, function(oIndex, oNode) {
                var resultNode = $(oNode).find("result");
                $.each(resultNode, function(subIndex, subNode) {
                    var existNodes = $($(subNode).find("exists"));
                    var nodeExists = existNodes.text() == "true";

                    if (nodeExists) {
                        var hitsNode = $(subNode).find("hits");

                        if (hitsNode.length == 1) {
                            $.each(hitsNode.find("hit"), function(hitIndex, hitNode) {
                                var foreignRegNumberNode = $(hitNode).find("foreignRegNumber");
                                foreignRegNumbers.push(foreignRegNumberNode.text());
                            });
                        }
                    } else {
                        foreignRegNumbers.push("New Compound");
                    }
                });
            });        
            populateRegLink(targetElement, dataTypeEnums.FOREIGN_LINK, foreignRegNumbers);
        });
    }

    var getRegFieldVal = function(targetElement) {
        var returnObj = {};

        // Check to determine if this is a request field or a request item field.
        var isRequestEditorLink = $("[liveeditid=" + targetElement + "]").parents(".editorFieldInputContainer").length > 0;
        var regFieldElement;

        if (isRequestEditorLink) {
            regFieldElement = $("[liveeditid=" + targetElement + "]").parents(".editorSection.card").find("[datatypeid=" + dataTypeEnums.REGISTRATION + "] > div.editorFieldInputContainer > a");
        } else {
            regFieldElement = $("[liveeditid=" + targetElement + "]").closest("tr").find("[datatypeid=" + dataTypeEnums.REGISTRATION + "] > a");
        }

        // Return the text and the href of the element we found so we can check both if we need to.
        returnObj["text"] = regFieldElement.text();
        returnObj["href"] = regFieldElement.attr("href");
        return returnObj;
    }
    
    var encodeIt = function(str){
        var z
        if(!str){
            return "";
        }
         var aStr = str.split(''),
             z = aStr.length,
             aRet = [];
           while (--z>=0) {
            var iC = aStr[z].charCodeAt();
            if (iC> 255) {
              aRet.push('&#'+iC+';');
            } else {
              aRet.push(aStr[z]);
            }
          }
         return aRet.reverse().join('');
        }

	var parseJsons = function(Input){
		var tempArr = [];
		$.each(Input, function(i, item){
			if (item != "null" && item != "")
			{
				tempArr.push(JSON.parse(item));
			}
		});
		return tempArr;
    }
    
    var caseInsensitiveSort = function(arr) {
        return arr.sort((x, y) => x.value.toLowerCase().localeCompare(y.value.toLowerCase()))
    }

    /**
     * Converts either the current date or the given date to the format expected by the services.
     * @param {*} dateToUse The date to use. Optional.
     */
    var getDateForService = function(dateToUse=null) {
        var now = "";
        if (dateToUse == null)
        {
            return now;
        }
        else if (typeof dateToUse == "string") {
            return dateToUse;
        }
        else 
        {
            now = new Date(asOfDateValidator(dateToUse));
        }
        var year = now.getFullYear();
        var month = now.getMonth() + 1; // months are 0-indexed
        var day = now.getDate();
        var hours = now.getHours();
        var minutes = now.getMinutes();
        var seconds = now.getSeconds();

        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    }

    /**
     * Builds a GET url based on the given baseUrl and paramObj.
     * @param {string} baseUrl The service endpoint we want to hit.
     * @param {object} paramObj The object of parameters to build into the string.
     */
    var buildGetUrl = function(baseUrl, paramObj={}) {
        
        var queryParams = [];
        $.each(Object.keys(paramObj), function(i, paramName) {

            var paramVal = paramObj[paramName];

            if (Array.isArray(paramVal)) {
                $.each(paramVal, (index, val) => queryParams.push(`${paramName}=${val}`));
            } else {
                queryParams.push(`${paramName}=${paramObj[paramName]}`);
            }
        });

        return `${baseUrl}?${queryParams.join("&")}`;
    }

    /**
     * Checks the given submitDate to make sure its not a date from before the actual start date.
     * @param {number} submitDate The date to use, given as seconds from epoch.
     */
    var asOfDateValidator = function(submitDate) {
        
        // 6/22/2019 00:00:00 EST
        var startDate = 1561176000000
        var createDate = new Date(submitDate).getTime();

        if (isNaN(createDate)) {
            // Return the latest if we have a bad date.
            return Date.now();
        }

        return createDate < startDate ? startDate : createDate;
    }

    var stripHtml = function(html) {
        // Create a new div element
        var temporalDivElement = document.createElement("div");
        // Set the HTML content with the providen
        temporalDivElement.innerHTML = html;
        // Retrieve the text property of the element (cross-browser support)
        return temporalDivElement.textContent || temporalDivElement.innerText || "";
    }     

    /**
     * this function checks field perms
     * @param {array} fields => array of fields to check
     */
    function checkPerm(fields)
    {
        var retArray = [];
        var unrestricted = fields.filter(x => x.restrictAccess == 0);
        var restrictedFields = fields.filter(x => x.restrictAccess == 1);

        if (unrestricted.length > 0)
        {
            unrestricted.map(function(x){
                retArray.push(x);
            });
        }
        if (restrictedFields.length > 0)
        {
            
            restrictedFields.map(function(f){
                var activeSetting = undefined;
                if (f.allowedGroups.length > 0)
                {
                    activeSetting =  f.allowedGroups.find(y => globalUserInfo["userGroups"].includes(y.groupId) && y.canView == 1);
                }
                if (activeSetting == undefined)
                {
                    activeSetting = f.allowedUsers.find(y => y.userId == globalUserInfo["userId"] && y.canView == 1);
                }
                if (activeSetting != undefined)
                {
                    retArray.push(f);
                }

            });
        }
        retArray = retArray.filter(x => x.disabled == 0);
        return (retArray);
    }

    /**
     * Converts the given requestTypeFieldId to the fieldId.
     * @param {Array<RequestTypeField>} thisRequestTypeFields 
     * @param {number} requestTypeFieldId 
     */
    var requestTypeFieldIdToFieldId = function(thisRequestTypeFields, requestTypeFieldId) {
        var fieldId = -1;

        var thisRequestTypeField = thisRequestTypeFields.find(x => x.requestTypeFieldId == requestTypeFieldId);

        if (thisRequestTypeField) {
            fieldId = thisRequestTypeField.savedFieldId;
        }

        return fieldId;
    }

    var submitRequest = function(request) {
        return new Promise(function(resolve, reject) { 
            if (request["request"]["id"] != undefined) {
                resolve(ajaxModule().patchRequest(request));
            } else {
                resolve(ajaxModule().postRequest(request));
            }
        })
    }

    /**
     * This takes an array of fields and removes all duplicates by comparing request type field id
     * @param {array} requestFields 
     */
    var removeDuplicatedFields = function(requestFields){

        var retArray = [];

        requestFields.map(function(x){
            var existing = retArray.find(y => y.requestTypeFieldId == x.requestTypeFieldId);
            if (existing == undefined){
                retArray.push(x);
            }
        });
        return(retArray);
    }

	function getCookie(cname) {
		var name = cname + "=";
		var ca = document.cookie.split(';');
		for (var i = 0; i < ca.length; i++) {
			var c = ca[i];
			while (c.charAt(0) == ' ') {
				c = c.substring(1);
			}
			if (c.indexOf(name) == 0) {
				return c.substring(name.length, c.length);
			}
		}
		return "";
    }
    
    /**
     * Checks if an object is empty.
     * @param {json} obj Object to check.
     */
    function isEmpty(obj) {
        for(var key in obj) {
            if(obj.hasOwnProperty(key))
                return false;
        }
        return true;
    }

    var permCheck = function(requestItemTypeField, tableCellContentWrapper, bucket, inputField){
        if (requestItemTypeField['restrictAccess'] == 1) {
            if (requestItemTypeField['canAdd'] == 0) {
                tableCellContentWrapper.addClass('noCanAdd');
            }
            if (requestItemTypeField['canView'] == 0) {
                tableCellContentWrapper.addClass('noCanView');
            }
            if (requestItemTypeField['canEdit'] == 0) {
                tableCellContentWrapper.addClass('noCanEdit');
                if ($('.requestEditorContainer.newRequestEditor').length < 1) {
                    // If this is an existing request, don't let the user edit
                    bucket.find(inputField).prop('disabled', true);
                    if (requestItemTypeField.dataTypeId == dataTypeEnums.FILE_ATTACHMENT){
                        bucket.find("form").removeClass("resumable-drop").removeClass("requestItemFieldFileAttachmentForm").removeClass("requestFieldFileAttachmentForm");
                        bucket.find(".resumable-drop").removeClass("resumable-drop");
                        bucket.find("button").remove();
                    }
                    
                }
            }
            if (requestItemTypeField['canDelete'] == 0) {
                tableCellContentWrapper.addClass('noCanDelete');
            };
        }
        tableCellContentWrapper.append(bucket.children());
        return (tableCellContentWrapper);
    }

    var decodeServiceResponce = function(responce){
        console.log(responce)
        if (Array.isArray(responce)){
            $.each(responce, function(index, item){
                responce[index] = parseResponce(item);
            });
        }
        else 
        {
            responce = parseResponce(responce);
        }
        return responce;
    }

    var parseResponce = function(item){
        if (typeof(item) == "object"){
            if (item["result"] == "success"){
                try{
                    return JSON.parse(item['data']);
                }
                catch(err) {
                    swal("Error decoding responce", err, "error");
                }
            }
            else {
                swal("Error In Service", item['error'] , "error");
            }
        }
        else{
            swal("Error In Service", "Request Timed Out" , "error");
        }	
        return false;
    }

    /**
     * Polls the notification service on the given interval to get an up to date count of the user's notifications.
     * @param {number} pollLength The amount of time in ms to wait before polling the service again.
     */
    var pollNotificationCount = function(pollLength) {
        setInterval(function() {
            fetchNotificationCount();
        }, pollLength);
    }

    /**
     * Fetches the current number of unread notifications, then updates the notification bubble.
     */
    var fetchNotificationCount = function() {        
        ajaxModule().getUnreadNotificationsCount().then(function(resp) {
            if (resp["result"] == "success") {
                updateNotificationCount(resp["data"]);
            }
        })
    }

    /**
     * Updates the notification bubble with the current count.
     * @param {number} count The number of unread notifications.
     */
    var updateNotificationCount = function(count) {
        $("#reactNotificationCount").text(count);
        var notificationCountCss = count > 0 ? "inline" : "none";
        $("#reactNotificationCount").css("display", notificationCountCss);
    }

    /**
     * Determines if the given list of requestTypeFieldPriorityOptions has a queueable option.
     * @param {Array} requestTypeFieldPriorityOptions A request type field's list of priority options.
     */
    var hasQueueableOption = function(requestTypeFieldPriorityOptions) {
        var isQueueable = false;
        if (requestTypeFieldPriorityOptions) {
            isQueueable = requestTypeFieldPriorityOptions.length > 0 && requestTypeFieldPriorityOptions.filter(x => x.queueable).length > 0;
        }
        return isQueueable;
    }

    /**
     * Checks if a request can be prioritized based on its request type.
     * @param {JSON} requestType The request type to check.
     */
    var canPrioritizeRequest = function(requestType) {
        var requestTypeFields = requestType.fields;
        return requestType["showPrioritizationOnSubmit"] && requestTypeFields.some(x => hasQueueableOption(x.requestTypeFieldPriorityOptions));
    }

    /**
     * Helper function that creates the input model for the link service.
     * @param {number} targetId The ID of the ELN object we want to link.
     * @param {number} dataTypeId The field's data type.
     */
    var makeLinkInputModel = function(targetId, dataTypeId) {
        var entityIdCd = dataTypeIdToEntityIdCd(dataTypeId);
        var inputModel = null;

        if (entityIdCd != -1) {
            inputModel = {
                companyId: globalUserInfo.companyId,
                originIdTypeCd: 1,
                originId: 0, // this gets filled in by the appService.
                targetIdTypeCd: entityIdCd,
                targetId: targetId,
                linkTypeCd: 2,
                description: "" // this gets filled in by the appService.
            };
        }

        return inputModel;
    }

    /**
     * Infers what entity ID the target data type ID would be.
     * @param {number} dataTypeId The field's data type.
     */
    var dataTypeIdToEntityIdCd = function(dataTypeId) {
        var entityIdCd = -1;

        if (dataTypeId == dataTypeEnums.NOTEBOOK) {
            entityIdCd = 4;
        } else if (dataTypeId == dataTypeEnums.PROJECT) {
            entityIdCd = 3;
        } else if (dataTypeId == dataTypeEnums.EXPERIMENT) {
            entityIdCd = 5;
        }

        return entityIdCd;
    }
    
    /* Validates if the input string is proper JSON.
     * Taken from https://stackoverflow.com/questions/9804777/how-to-test-if-a-string-is-json-or-not
     * @param {string} str The string to check.
     */
    var hasJsonStructure = function (str) {
        if (typeof str !== "string") return false;
        try {
            const result = JSON.parse(str);
            const type = Object.prototype.toString.call(result);
            return type === "[object Object]"
                || type == "[object Array]";
        } catch (err) {
            return false;
        }
    }

    /**
     * Copy a field's value to the users clipboard.
     * @param {String} fieldId The id of the field to copy.
     */
    var copyFnc = function(fieldId) {
        // Get the text field 
        let domElement = document.getElementById(fieldId);
        let sel = getSelection();
        let range = document.createRange();
        range.selectNode(domElement);
        sel.removeAllRanges();
        sel.addRange(range);
        if(document.execCommand('copy')){
            console.log('Copied ' + domElement.value);
            window.copyNotification = $.notify({
                title: `Copied: ${domElement.value}`,
                message: ""
            }, {
                delay: 750,
                type: "success",
                template: utilities().notifyJSTemplates.default,
                onClose: function () {
                    window.copyNotification = undefined;
                }
            });
        }
        else {
            window.copyNotification = $.notify({
                title: `Failed to copy: ${domElement.value}`,
                message: ""
            }, {
                delay: 750,
                type: "danger",
                template: utilities().notifyJSTemplates.default,
                onClose: function () {
                    window.copyNotification = undefined;
                }
            });
        } 
    }

    /**
     * Check to see if val is a string and compare it to the string value "true". False in other cases.
     * @param {string} val The value to convert.
     */
    let stringToBool = function(val) {
        let returnVal = false;
        if (val && typeof val == "string") {
            returnVal = val.toLowerCase() == "true";
        }

        return returnVal;
    }

    /**
     * Gets a bio editor id based off of a few states of the experiment
     * @param {String} savedId UUIDV4 This would be the previous saved id for reference.
     * @param {String} fieldId The field id needed for draft reference 
     * @param {bool} readOnly Is read only 
     * @returns {String} The editor id to be used for the bio editor component
     */
    var getBioEditorId = function(savedId, fieldId, readOnly){
        return new Promise(function(resolve, reject) {
            
            if (window.top.experimentJSON && currApp == "ELN" && window.top.experimentJSON[fieldId]){
                //If we are in here then we have a draft value
                resolve(window.top.experimentJSON[fieldId]);
            }
            else if (!savedId) {
                resolve("");
            }
            else {
                if (readOnly) {
                    resolve(savedId);
                }
                else {
                    waitForBioInterCom(function(){
                        BioInterCom.props.forkEditor(savedId, jwt)
                        .then(function(resp){
                            if (resp.status == 200){
                                resolve(resp.data.newExperimentId);
                            }
                            else{
                                reject("Bad Response from bio service.");
                            }
                        })
                        .catch();
                    });
                }
            }
        });
    }

    /**
     * This will wait for the bio intercom to be ready and then fork the experiment.
     * @param {function} fncToRun Function to run after bio intercom is loaded.
     */
    var waitForBioInterCom = function(fncToRun){
        return new Promise(function(resolve, reject) {
            if (window.BioInterCom) {
                fncToRun()
            }
            else {
                // Note: This is going to call itself and wait for the bio editor to be fully initialized by testing every 250ms
                window.setTimeout(function(savedId){resolve(waitForBioInterCom(fncToRun));},250,fncToRun);
            }
        });
    }

    /**
     * Check if the field is read only. 
     * @param {JSON} requestTypeField The config for the field itself.
     * @param {JSON} savedRequestField The saved data for the field. 
     * @returns {bool} If the field is read only or not.
     */
    var isReadOnly = function(requestTypeField, savedRequestField ) {
        // this checks restrict access settings in config
        if ($('.requestEditorContainer.newRequestEditor').length < 1 && requestTypeField['restrictAccess'] && !requestTypeField['canEdit'] && savedRequestField) {
            return true
        }
        // this checks eln revision and permitions.
        var isOldRevision = (typeof (requestRevId) != "undefined" && requestRevId != "");
        var canWrite = true;
        if (window.self != window.top) {
            canWrite = window.parent.canWrite;
        }
        if (isOldRevision || !canWrite) {
            return true
        }
        return false
    }    

    return {
        notifyJSTemplates: notifyJSTemplates,
        makeAjaxPost: makeAjaxPost,
        makeAjaxGet: makeAjaxGet,
        makeAjaxPatch: makeAjaxPatch,
        makeAjaxPut: makeAjaxPut,
        boolToInt: boolToInt,
        resetItemHover: resetItemHover,
        addResumableToItem: addResumableToItem,
        sortHelper: sortHelper,
        sortArray: sortArray,
        sortDropdownlist: sortDropdownlist,
        showLoadingModal: showLoadingModal,
        hideLoadingModal: hideLoadingModal,
        resizeManageRequestsTable: resizeManageRequestsTable,
        showUnsavedChangesNotification: showUnsavedChangesNotification,
        closeUnsavedChangesNotification: closeUnsavedChangesNotification,
        displayUnsavedChangesNotification: displayUnsavedChangesNotification,
        hideUnsavedChangesNotification: hideUnsavedChangesNotification,
        userIsMemberOfGroupByName: userIsMemberOfGroupByName,
        resizeCustExpIframe: resizeCustExpIframe,
        calculateOffset: calculateOffset,
        populateRegLink: populateRegLink,
        addStructureToReg: addStructureToReg,
        autoFillRequestField: autoFillRequestField,
        searchRegForStructure: searchRegForStructure,
        showReq: showReq,
        parseXMLStr: parseXMLStr,
        searchForeignReg: searchForeignReg,
        getRegFieldVal: getRegFieldVal,
        parseJsons: parseJsons,
        encodeIt: encodeIt,
        caseInsensitiveSort: caseInsensitiveSort,
        getDateForService: getDateForService,
        buildGetUrl: buildGetUrl,
        asOfDateValidator: asOfDateValidator,
        stripHtml: stripHtml,
        checkPerm: checkPerm,
        requestTypeFieldIdToFieldId: requestTypeFieldIdToFieldId,
        removeDuplicatedFields: removeDuplicatedFields,
        submitRequest: submitRequest,
        getCookie: getCookie,
        isEmpty: isEmpty,
        permCheck: permCheck,
        decodeServiceResponce: decodeServiceResponce,
        pollNotificationCount: pollNotificationCount,
        fetchNotificationCount: fetchNotificationCount,
        updateNotificationCount: updateNotificationCount,
        hasQueueableOption: hasQueueableOption,
        canPrioritizeRequest: canPrioritizeRequest,
        makeLinkInputModel: makeLinkInputModel,
        hasJsonStructure: hasJsonStructure,
        copyFnc: copyFnc,
        stringToBool: stringToBool,
        getBioEditorId: getBioEditorId,
        isReadOnly: isReadOnly,
        waitForBioInterCom: waitForBioInterCom,
    };
});