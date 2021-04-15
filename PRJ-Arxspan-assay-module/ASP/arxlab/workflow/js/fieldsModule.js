var fieldsModule = function() {

    /**
     * Creates a new editor field for a request editor.
     * @param {JSON} requestType The request type config data.
     * @param {JSON} savedRequest The request we're building fields for.
     * @param {boolean} canReprioritize Can we reprioritize this request?
     * @param {number} requestTypeFieldId The request type field ID for the field we want to build.
     * @param {Array} fields The list of field config data.
     */
    var makeNewEditorField = function(requestType, savedRequest, canReprioritize, requestTypeFieldId, fields) {
        return new Promise(function (resolve, reject) {

            var requestId = null;
            if (savedRequest && CurrentPageMode != "repeatRequest") {
                requestId = savedRequest["id"];
            }
            var requestTypeField = requestType['fieldsDict'][requestTypeFieldId][0];
    
            if (requestType['fieldsDict'][requestTypeFieldId].length > 1) {
                var groupId;
    
                if ($("#assignedUserGroupDropdown").val()) {
                    groupId = $("#assignedUserGroupDropdown").val();
                } else {
                    groupId = globalUserInfo.userGroups[0];
                }
    
                // Are we in editDefaults?
                if ($(".userDropdown").length > 0) {
                    var userId = $("#userDropdown").val();
                } else {
                    var userId = window.globalUserInfo.userId;
                }

                // Filter this down to remove fields we don't care about: namely, the defaults set
                // for groups and users that are empty, other groups' defaults and other users' defaults.
                var userRequestTypeField = requestType["fieldsDict"][requestTypeFieldId].find(
                    x => (x.groupId == groupId && x.groupDefaultValue) ||
                    (x.userId == userId && x.userDefaultValue) ||
                    (x.groupId != null && x.userId != null)
                );

                if (userRequestTypeField) {
                    requestTypeField = userRequestTypeField;
                }
            } else {
                requestTypeField = requestType['fieldsDict'][requestTypeFieldId][0]
            }
            
            var skipThisRequestTypeField = false;
    
            var editorField = $('<div class="editorField"></div>');
    
            editorField.attr('requesttypefieldid', requestTypeField['requestTypeFieldId']);
            editorField.attr('allowmultiple', requestTypeField['allowMultiple']);
            editorField.attr('fieldgroup', requestTypeField['fieldGroup']);
            editorField.attr('clearWhenDuplicate', requestTypeField['clearWhenDuplicate'])
    
            if (requestTypeField['disabled'] == true) {
                editorField.addClass('disabledField');
            }
            if (requestTypeField['required'] == true) {
                editorField.addClass('requiredField');
            }
            editorField.attr('savedfieldid', requestTypeField['savedFieldId']);
            editorField.attr("sortorder", requestTypeField["sortOrder"]);
    
            var savedFieldData = null;
            $.each(fields, function (savedFieldIndex, savedField) {
                if (savedField['id'] == requestTypeField['savedFieldId']) {
                    savedFieldData = { 'index': savedFieldIndex, 'field': savedField };
                    return false;
                }
            });
    
            new Promise(function (resolve, reject) {
                if (savedFieldData == null || (!savedFieldData.hasOwnProperty('index')) || (!savedFieldData.hasOwnProperty('field'))) {
                    resolve(false);
                }
                else {
                    savedField = savedFieldData['field'];
                    savedFieldIndex = savedFieldData['index'];
                }
    
                // Permissions...
                if (requestTypeField['restrictAccess'] == 1) {
                    if (requestTypeField['canView'] == 0) {
                        //console.error("Something may be wrong with API - this field (" + savedField['displayName'] + ") shouldn't have been in the request object because this user doesn't have the right to see it...")
                        skipThisRequestTypeField = true;
                        resolve(false);
                    }
                    else if ((!savedRequest || duplicatingRequest) && requestTypeField['canAdd'] == 0) {
                        // User is making a new request/duplicating one and doesn't have the right to add this field
                        skipThisRequestTypeField = true;
                        resolve(false);
                    }
    
                    editorField.addClass('restrictedAccessField');
                    if (requestTypeField['canAdd'] == 0) {
                        editorField.addClass('noCanAdd');
                    }
                    if (requestTypeField['canView'] == 0) {
                        editorField.addClass('noCanView');
                    }
                    if (requestTypeField['canEdit'] == 0) {
                        editorField.addClass('notEditable');
                        editorField.addClass('noCanEdit');
                    }
                    if (requestTypeField['canDelete'] == 0) {
                        editorField.addClass('noCanDelete');
                    }
                }
    
                savedRequestField = false;
                if (savedRequest) {
                    var thisRequestField = savedRequest["requestFields"].find(x => x["requestTypeFieldId"] == requestTypeFieldId);
                    if (thisRequestField) {
                        savedRequestField = thisRequestField;
                        editorField.attr('requestfieldid', thisRequestField['id']);
                    }
                }
    
                editorField.attr('datatypeid', savedField['dataTypeId']);
                if (savedField["hoverText"]) {
                    editorField.attr("title", savedField["hoverText"]);
                }
                var fieldLabel = $('<label class="editorFieldLabel"></label>');
                var fieldLabelText = $("<span></span>").addClass("fieldLabel").text(savedField['displayName']);
                fieldLabel.append(fieldLabelText);
    
                // Add instructions for how to use the file upload.
                if (savedField["dataTypeId"] == 6) {
                    fieldLabel.append($("<br>")).append($("<span></span>").addClass("attachment-instructions").text("Drop files to upload or browse for a file."));
                }
    
                fieldLabel.attr("requestfieldid", editorField.attr('requestFieldId'))

                console.log("SAVED FIELD INDEX: ", savedFieldIndex);
                addRequestEditorField(savedField, savedRequestField, requestTypeField, requestId, canReprioritize).then(function (fieldInputElementContainer) {
                    editorField.append(fieldLabel, fieldInputElementContainer);
                    console.log("RETURN SAVED FIELD INDEX: ", savedFieldIndex);
                    resolve(editorField);
                }).then(function (editorField) {
                    if (!skipThisRequestTypeField && !requestTypeField["disabled"]) {
                        resolve(editorField);
                    } else {
                        resolve(false);
                    }
                });
            }).then((editorField) => resolve(editorField))
        })
    }

    /**
     * Adds a request editor field to the page.
     * @param {JSON} savedField The configuration settings for this field.
     * @param {JSON} savedRequestField The request data for this field.
     * @param {JSON} requestTypeField The configuration settings for this request type field.
     * @param {number} requestId The ID of the request we're building, if we have one.
     * @param {boolean} canReprioritize Can the request we're building be reprioritized?
     */
    var addRequestEditorField = function(savedField, savedRequestField, requestTypeField, requestId, canReprioritize) {
        return new Promise(function (resolve, reject) {
            // Text, Long Text, Integer, Real Number
            valuesArray = [false] // Just making an array to work with the $.each() loop
            var editorFieldPromises = [];
            if (!window.duplicateRequestId && savedRequestField) {
                valuesArray = savedRequestField['requestFieldValues'].map(x => x == null ? 
                    {
                        "textValue": "",
                        "intValue": "",
                        "realValue": "",
                        "dropDownValue": "",
                    } :
                    x
                )
            }
            else {
    
                var isDuplicatePage = window.location.href.indexOf("repeatRequest") >= 0;
                var clearWhenDuplicate = requestTypeField["clearWhenDuplicate"] == 1
    
                // I can't believe NAND can be implemented in javascript so simply.
                // The following corresponds to: A AND B NAND C
                // A /\ ~(B /\ C)
                if (savedRequestField && !(isDuplicatePage && clearWhenDuplicate)) {
                    valuesArray = savedRequestField['requestFieldValues'];
                    console.log(valuesArray);
                }
                if (($('.requestEditorContainer.newRequestEditor').length > 0 || isDuplicatePage) && !valuesArray[0]) {
                    console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  globalUesrInfo.userGroups = ", globalUserInfo.userGroups);
                    // If this is a new request, fill in w/ default values
                    console.log("processing default values for: ", requestTypeField);
                    console.log("SavedFieldId: ", savedField)
                    if (savedField['dataTypeId'] == 11) {
                        requestTypeField['defaultValue'] = globalUserInfo.userId;
                    }
                    if (requestTypeField['defaultValue']) {
                        var defaultValueObject;
                        if (savedField['dataTypeId'] == 5) {
                            requestTypeField['defaultValue'] = parseInt(requestTypeField['defaultValue'])
                            defaultValueObject = { 'dropDownValue': requestTypeField['defaultValue'] }
                        }
                        else if (savedField['dataTypeId'] == 11) {
                            requestTypeField['defaultValue'] = parseInt(requestTypeField['defaultValue'])
                            defaultValueObject = { 'dropDownValue': requestTypeField['defaultValue'] }
                        }
                        else {
                            defaultValueObject = {
                                "textValue": requestTypeField['defaultValue'],
                                "intValue": requestTypeField['defaultValue'],
                                "realValue": requestTypeField['defaultValue']
                            }
                        }

                        if (defaultValueObject) {
                            valuesArray = [defaultValueObject]
                            console.log(valuesArray);
                        }

                    }
                }
            }
    
            var fieldInputElementsContainer = $('<div>');
            if (valuesArray.length == 0 )
            {
                valuesArray.push(false)
            }
            $.each(valuesArray, function (requestFieldValueIndex, requestFieldValue) {
                editorFieldPromises.push(buildRequestEditorField(
                    requestFieldValueIndex,
                    requestFieldValue,
                    savedField,
                    requestTypeField,
                    requestId,
                    canReprioritize
                ));
            })

            Promise.all(editorFieldPromises).then(function(editorFields) {
                $.each(editorFields, function(editorFieldIndex, editorField) {
                    fieldInputElementsContainer.append(editorField);
                });
                resolve(fieldInputElementsContainer.children());
            })
        });
    }

    /**
     * Builds the request editor field to be added to the page.
     * @param {number} requestFieldValueIndex The index of this request editor field.
     * @param {JSON} requestFieldValue The current request field's value.
     * @param {JSON} savedField The configuration settings for this field.
     * @param {JSON} requestTypeField The configuration settings for this request type field.
     * @param {number} requestId The ID of the request we're building, if we have one.
     * @param {boolean} canReprioritize Can the request we're building be reprioritized?
     */
    var buildRequestEditorField = function(requestFieldValueIndex, requestFieldValue, savedField, requestTypeField, requestId, canReprioritize) {
        return new Promise(function(resolve, reject) {

            if (requestFieldValue == null) {
                requestFieldValue = {};
            }

            var fieldPromises = [];
            
            console.log(requestFieldValueIndex)
            if (savedField['dataTypeId'] == dataTypeEnums.TEXT ) {
                var fieldInputElement = requestTypeTextGenerator(requestFieldValue["textValue"]);
            }
            else if (savedField["dataTypeId"] == dataTypeEnums.LONG_TEXT) {
                var fieldInputElement = requestTypeLongTextGenerator(requestFieldValue["textValue"]);
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.INTEGER){
                var fieldInputElement = requestTypeIntGenerator(requestFieldValue["intValue"]);
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.REAL_NUMBER){
                var fieldInputElement = requestTypeNumberGenerator(requestFieldValue["realValue"]);
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.DROP_DOWN) {
                // If this is an existing request, then we'll handle the relational dropdowns further down.
                // Otherwise, check this dropdown's dependencies and see if it's dependent on something else.
                var fieldInputElement = requestTypeDropdownGenerator(savedField, requestTypeField, requestFieldValue["dropDownValue"], requestId, canReprioritize);
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.FILE_ATTACHMENT) { // File Attachment
                var fieldInputElement = $('<form class="requestFieldFileAttachmentForm" onsubmit="return false;">');
                fieldInputElement.append('<input type="file" class="editorFieldInput" style="display:none">');
                fieldInputElement.append('<button type="submit" class="requestFieldFileAttachmentSubmitButton btn btn-sm" style="display:none">Confirm Upload</button>');

                // Using resumable.js for attachments.
                var uploadBar = $("<div></div>").addClass("myBar");

                var resumableCurrFile = $("<div class='currFile'></div>").append($("<a href='#'></a>").addClass("currentFileLink").text("No file chosen"));
                var resumableBrowse = $("<button class='resumable-browse'>Choose File</button>");
                var fileDiv = $("<div></div>").addClass("resumableFileInfo");
                fileDiv.append(resumableBrowse).append(resumableCurrFile);

                var btnDiv = $("<div></div>").addClass("resumableBtns");
                var pauseBtn = $("<button></button>").addClass("resumablePause");
                var resumeBtn = $("<button></button>").addClass("resumableGo");
                btnDiv.append(pauseBtn).append(resumeBtn);

                var fileUploadContainer = $("<div></div>").addClass("fileUploadContainer").append(fileDiv).append(btnDiv);
                //var resumableTest = $("<div></div>").addClass("resumable-drop").addClass("progress").append(resumableBrowse).append(resumableCurrFile);
                var resumableTest = $("<div></div>").addClass("resumable-drop").append(uploadBar.append(fileUploadContainer));
                //var resumableTest = $("<div></div>").addClass("resumable-drop").append(resumableBrowse).append(resumableCurrFile).append(uploadBar);

                // Set up the resumable object. Target is currently excel2CSV because it was built off the one API call so it should be renamed at some point.
                var resumableOptions = {
                    target: '/excel2CSV/Upload',
                    query: {
                        connectionId: connectionId,
                        companyId: companyId,
                        userId: globalUserInfo.userId,
                        appName : "Workflow",
                    },
                    headers: {"Authorization": jwt},
                    generateUniqueIdentifier: resumableGenerateUniqueIdentifier,
                }

                var fileAddedCallbackFn = function(file, rObj) {
                    fieldInputElement.find(".currentFileLink").text(file.fileName);
                    uploadBar.css("width", "0%");
                    removeProgressClasses(uploadBar);
                    utilities().showUnsavedChangesNotification(uploadBar);
                    uploadBar.addClass("myBar-upload");
                    btnDiv.css('display', 'flex');
                    $("#basicLoadingModal").show();
                    rObj.upload();
                }

                var pauseCallbackFn = function(rObj) {
                    rObj.pause();
                    removeProgressClasses(uploadBar);
                    uploadBar.addClass("myBar-pause");
                }

                var resumeCallbackFn = function(rObj) {
                    rObj.upload();
                    removeProgressClasses(uploadBar);
                    uploadBar.addClass("myBar-upload");
                }

                var fileSuccessCallbackFn = function(file, response) {
                    $("#basicLoadingModal").hide();
                    removeProgressClasses(uploadBar);
                    uploadBar.addClass("myBar-success");
                    btnDiv.hide();

                    var responseObj = typeof (response) == "string" ? JSON.parse(response) : response;

                    fieldInputElement.attr("fileid", responseObj.fileId);

                    if (responseObj.fileId != -1) {
                        console.log(responseObj.fileId);
                        $.notify({
                            title: "Successfully uploaded file attachment.",
                            message: ""
                        }, {
                                delay: 4000,
                                type: "success",
                                template: utilities().notifyJSTemplates.default
                            });
                    }
                }

                var fileErrorCallbackFn = function(file, response) {
                    removeProgressClasses(uploadBar);
                    uploadBar.addClass("myBar-error");
                    uploadBar.css("width", "100%");
                    btnDiv.hide();

                    $.notify({
                        title: "Failed to upload file attachment.",
                        message: ""
                    }, {
                            delay: 0,
                            type: "danger"
                        });
                }

                var fileProgressCallbackFn = function(file, ratio) {
                    var progress = file.progress() * 100;
                    progress = Math.floor(progress);
                    uploadBar.css("width", progress + "%");
                }

                var resumableObject = resumableModule(resumableOptions, resumableTest, resumableTest.find(".resumable-browse"));
                resumableObject.addFileCallback(fileAddedCallbackFn);
                resumableObject.addPauseButtonCallback(pauseBtn, pauseCallbackFn);
                resumableObject.addResumeButtonCallback(resumeBtn, resumeCallbackFn);
                resumableObject.addFileSuccessCallback(fileSuccessCallbackFn);
                resumableObject.addFileErrorCallback(fileErrorCallbackFn);
                resumableObject.addFileProgressCallback(fileProgressCallbackFn);

                fieldInputElement.append(resumableTest);

            }
            else if (savedField['dataTypeId'] == dataTypeEnums.DATE) { // Date

                if (requestFieldValue){
                    var fieldInputElement = requestTypeDateGenerator(requestFieldValue["dateValue"]);
                }
                else{
                    var fieldInputElement = requestTypeDateGenerator("");
                }
                            
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.STRUCTURE) {
                // for now creat the div but do not populate it
                var fieldInputElement = $('<div class="structureDisplay"></div>').attr('requestitemtypefieldid', savedField['id']);
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.RICH_TEXT) {
                // CKEditor field.
                var ckeId = randomString(32, '#aA');
                var fieldInputElement = requestTypeCKEditorGenerator(ckeId, requestFieldValue["textValue"]);
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.USER_LIST || savedField['dataTypeId'] == dataTypeEnums.CO_AUTHORS) {
                // User List
                var fieldInputElement = $('<select class="editorFieldDropdown requestFieldDropdown"></select>').append('<option value="" selected emptyDefaultOption>-- Make a Selection --</option>');

                // Figure out what users go in this dropdown, then put in a focus handler so
                // that the user list recalculation is done every time the dropdown is clicked.                    
                
                fieldPromises.push(new Promise(function(resolve, reject) {
                    ajaxModule().getUsersWhoCanSeeThisExp().then(function(userList) {
                        resolve(populateUserDropdown(userList, fieldInputElement));
                    })}));
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.NOTEBOOK) // Notebook
            {
                var randomFieldValue = Math.random().toString(36).substring(7);
                var fieldInputElement = $("<input></input>").attr("type", "text");
                fieldInputElement.addClass("searchForNotebook").addClass("select2-offscreen");
                fieldInputElement.attr("id", "searchForNotebook");
                fieldInputElement.attr("name", "searchForNotebook");
                fieldInputElement.attr("title", "Search for Notebook");
                fieldInputElement.attr("requesttypefieldid", requestTypeField["requestTypeFieldId"]);
                fieldInputElement.attr("fieldid", randomFieldValue);
                fieldInputElement.attr("autogen", requestTypeField["autoGenerateNotebook"]);
                fieldInputElement.attr("bidirectionallink", requestTypeField["bidirectionalRequestLinking"]);

                if (requestTypeField["autoGenerateNotebook"] == "1") {
                    fieldInputElement.attr("disabled", true);
                }
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.PROJECT) // project
            {
                var randomFieldValue = Math.random().toString(36).substring(7);
                var fieldInputElement = $("<input></input>").attr("type", "text");
                fieldInputElement.addClass("searchForProject").addClass("select2-offscreen");
                fieldInputElement.attr("id", "searchForProject");
                fieldInputElement.attr("name", "searchForProject");
                fieldInputElement.attr("title", "Search for Project");
                fieldInputElement.attr("requesttypefieldid", requestTypeField["requestTypeFieldId"]);
                fieldInputElement.attr("fieldid", randomFieldValue);
                fieldInputElement.attr("autogen", requestTypeField["autoGenerateProject"]);
                fieldInputElement.attr("bidirectionallink", requestTypeField["bidirectionalRequestLinking"]);
                if (requestTypeField["autoGenerateProject"] == "1") {
                    fieldInputElement.attr("disabled", true);
                }
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.EXPERIMENT) // experement
            {
                var randomFieldValue = Math.random().toString(36).substring(7);
                var fieldInputElement = $("<input></input>").attr("type", "text");
                fieldInputElement.addClass("searchForExperement").addClass("select2-offscreen");
                fieldInputElement.attr("id", "searchForExperement");
                fieldInputElement.attr("name", "searchForExperement");
                fieldInputElement.attr("title", "Search for Experiment");
                fieldInputElement.attr("requesttypefieldid", requestTypeField["requestTypeFieldId"]);
                fieldInputElement.attr("fieldid", randomFieldValue);
                fieldInputElement.attr("autogen", requestTypeField["autoGenerateExperement"]);
                fieldInputElement.attr("bidirectionallink", requestTypeField["bidirectionalRequestLinking"]);
                if (requestTypeField["autoGenerateExperement"] == "1") {
                    fieldInputElement.attr("disabled", true);
                }
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.REGISTRATION || savedField['dataTypeId'] == dataTypeEnums.FOREIGN_LINK) // Registration
            {
                var fieldInputElement = requestTypeRegLinkGenerator(savedField, requestFieldValue["textValue"]);
                fieldInputElement.attr("name", savedField["displayName"]);
                fieldInputElement.attr("title", savedField["hoverText"]);
                fieldInputElement.attr("requesttypefieldid", requestTypeField["requestTypeFieldId"]);
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.REQUEST) // Registration
            {
                var fieldInputElement = $("<a></a>");
                fieldInputElement.addClass("searchForRequests").addClass("btn").addClass("btn-info").addClass("btn-sm");
                fieldInputElement.attr("id", "searchForRequests");
                fieldInputElement.attr("name", savedField["displayName"]);
                fieldInputElement.attr("title", savedField["hoverText"]);
                fieldInputElement.attr("requesttypefieldid", requestTypeField["requestTypeFieldId"]);
                fieldInputElement.text("No link.");
            }
            else if (savedField['dataTypeId'] == dataTypeEnums.UNIQUE_ID){ // auto generated ref. ID
                console.warn("we are in the new dt!")
                var fieldInputElement = requestAutoGeneratedField(requestFieldValue["textValue"]);
            } 
            else if (savedField['dataTypeId'] == dataTypeEnums.BIOSPIN_EDITOR) { // React bio editor component
                ajaxModule().loadBioEditorComponent();
                var fieldInputElement = $('<a/ href="javascript:void(0)">');
                    //Note: this is a place holder img just to start with
                    fieldInputElement.append("<img style='height: 300px; width:300px' src='js/bio-editor.jpg'/>");
                    fieldInputElement.attr("id", savedField['id']);
                    fieldInputElement.attr("name", savedField["displayName"]);
                    fieldInputElement.css("min-height", "100px");
                    fieldInputElement.css("min-width", "100px");
                    fieldInputElement.css("cursor", "pointer");
                   
                    // Get bio editor id 
                    utilities().getBioEditorId(
                        requestFieldValue ? requestFieldValue["textValue"] : "",
                        requestTypeField.requestTypeFieldId,
                        utilities().isReadOnly(requestTypeField, savedRequestField)
                    ).then(function(editorId){
                        //Then use it to add attributes to the dom and get imgs
                        fieldInputElement.attr("expId", editorId);
                        if (editorId) {
                            utilities().waitForBioInterCom(function(){ 
                                window.BioInterCom.props.getEditorImg(editorId, jwt, "sequence")
                                .then(function(response){
                                    if (response.status == 200){
                                        fieldInputElement.empty();
                                        fieldInputElement.append( response.data );
                                    }
                                    else{
                                        console.error("Bad Response from bio service.");
                                    }
                                });
                            });
                        }
                    });
                    // setup on click
                    fieldInputElement.on("click", function () {
                        // check if we have intercom... checks to make sure we have a loaded component.
                        if (window.BioInterCom) {
                            // open the editor 
                            window.BioInterCom.props.openBioEditor(
                                jwt,
                                globalUserInfo.companyId,
                                globalUserInfo.userId,
                                savedField["displayName"], 
                                fieldInputElement.attr("expId"), 
                                utilities().isReadOnly(requestTypeField, savedRequestField),
                                function(newId){
                                    fieldInputElement.attr("expId", newId);
                                    window.BioInterCom.props.getEditorImg(newId, jwt, "sequence")
                                        .then(function(response){
                                            if (response.status == 200){
                                                fieldInputElement.empty();
                                                fieldInputElement.append( response.data );
                                            }
                                            else{
                                                console.error("Bad Response from bio service.");
                                            }
                                        });
                                }, 
                                function(expId){
                                    utilities().showUnsavedChangesNotification(fieldInputElement);
                                    // eln check for draft
                                    if (currApp == "ELN"){
                                        window.parent.sendAutoSave(requestTypeField.requestTypeFieldId, expId);
                                    }
                                }
                            );
                        }
                    })
            } else {
                alert("Error adding request editor field.")
                console.error("Error adding request editor field with data type: " + String(savedField['dataTypeId']))
            }
            // If we're loading values from a saved request field

            Promise.all(fieldPromises).then(async function() {
                var editorFieldInputContainerElement = $('<div class="editorFieldInputContainer"></div>');
                if (requestFieldValue) {
                    // Data types 1-5, 9 are already covered above.
                    if (savedField['dataTypeId'] == dataTypeEnums.FILE_ATTACHMENT) { // File Attachment
                        if (requestFieldValue["fileId"]) {
                            fieldInputElement.attr('fileid', requestFieldValue['fileId']);
                            fieldInputElement.find('.currentFileLink')
                                .text('Current file: ' + requestFieldValue['fileName'])
                                .attr('href', 'getSourceFile.asp?fileId=' + requestFieldValue['fileId']);
                        }
                    }
                    else if (savedField['dataTypeId'] == 7) { // Date
                        // Moved this a few lines above to where the fieldInputElement is created - needed the value to init pikaday
                    }
                    else if (savedField['dataTypeId'] == 8) { // Structure
                        fieldInputElement.val(requestFieldValue['textValue'])
                    }
                    else if (savedField['dataTypeId'] == 11 || savedField['dataTypeId'] == 12) { // User list    
                        //Add the option that needs to be selected as a place holder untill full list is built
                        if(requestFieldValue["collaboratorName"] == undefined){
                            requestFieldValue["collaboratorName"] = '-- Make a Selection --';
                        }                       
                        if(usersList.length > 0 && requestFieldValue["dropDownValue"] != null)
                        {
                            var user = usersList.find(x => x.id == requestFieldValue["dropDownValue"]);
                            if (user)
                            {
                                requestFieldValue["collaboratorName"] = user["fullName"];
                            }
                            else 
                            {
                                requestFieldValue["collaboratorName"] = "Disabled User";
                            }
                        }
                        else 
                        {
                            requestFieldValue["collaboratorName"] = '-- Make a Selection --';
                        }
                    
                        if (requestFieldValue["dropDownValue"]) {
                            $(fieldInputElement).append(`<option value="${requestFieldValue["dropDownValue"]}">${requestFieldValue["collaboratorName"]}</option>`)
                            fieldInputElement.find(`option[value='${requestFieldValue["dropDownValue"]}']`).prop('selected', true);
                        }
                    }
                    else if (savedField['dataTypeId'] == dataTypeEnums.NOTEBOOK) {
                      
                        const linkList = await getLinkDataForField(requestFieldValue["intValue"], applicationEnum.NOTEBOOK, $(fieldInputElement).attr("fieldId"));
                        const optList = convertFieldLinkToSelect2Option(linkList, $(fieldInputElement).attr("fieldId"));
                        optList.forEach(linkOpt => $(editorFieldInputContainerElement).append(linkOpt));
                        
                        if (window.top.linkData) {

                            var link = window.top.linkData.find(x => x.linkSvcId == requestFieldValue['intValue']);
                            if (link) {
                                var noteText = link["linkName"] ? link["linkName"] : "";
                                var opt = $('<option style="display:none;" fieldId = "' + $(fieldInputElement).attr("fieldId") + '" id="' + link['objectId'] + '" selected="selected">' + noteText + '</option>');
                                $(editorFieldInputContainerElement).append(opt);
                            }
                        }
                    }
                    else if (savedField['dataTypeId'] == dataTypeEnums.PROJECT) {
                        
                        const linkList = await getLinkDataForField(requestFieldValue["intValue"], applicationEnum.PROJECT, $(fieldInputElement).attr("fieldId"));
                        const optList = convertFieldLinkToSelect2Option(linkList, $(fieldInputElement).attr("fieldId"));
                        optList.forEach(linkOpt => $(editorFieldInputContainerElement).append(linkOpt));
                        
                        if (window.top.linkData) {

                            var link = window.top.linkData.find(x => x.linkSvcId == requestFieldValue['intValue']);
                            if (link) {
                                var projText = link["linkName"] ? link["linkName"] : "";
                                var opt = $('<option style="display:none;" fieldId = "' + $(fieldInputElement).attr("fieldId") + '" id="' + link['objectId'] + '" selected="selected">' + projText + '</option>');
                                $(editorFieldInputContainerElement).append(opt);
                            }
                        }     
                    }
                    else if (savedField['dataTypeId'] == dataTypeEnums.EXPERIMENT) {
                        const linkList = await getLinkDataForField(requestFieldValue["intValue"], applicationEnum.EXPERIMENT, $(fieldInputElement).attr("fieldId"));
                        const optList = convertFieldLinkToSelect2Option(linkList, $(fieldInputElement).attr("fieldId"));
                        optList.forEach(linkOpt => $(editorFieldInputContainerElement).append(linkOpt));
                        
                        if (window.top.linkData) {

                            var link = window.top.linkData.find(x => x.linkSvcId == requestFieldValue['intValue']);
                            if (link) {
                                var expText = link["linkName"] ? link["linkName"] : "";
                                var opt = $('<option style="display:none;" fieldId = "' + $(fieldInputElement).attr("fieldId") + '" id="' + link['linkId'] + '" index="' + link["abr"] + '" selected="selected">' + expText + '</option>');
                                $(editorFieldInputContainerElement).append(opt);
                            }
                        }     
                    }
                    else if (savedField['dataTypeId'] == dataTypeEnums.REQUEST) {
                        if (requestFieldValue['textValue'] != null)
                        {
                            var data = JSON.parse(requestFieldValue['textValue']);
                            $.each(data, function(key,data){
                                fieldInputElement.attr("reqid", key);
                                fieldInputElement.text(data);
                            })
                        }
                    }
                }
    
                // If this request already exists and the user doesn't have the right to edit...
                if ($('.requestEditorContainer.newRequestEditor').length < 1 && requestTypeField['restrictAccess'] && !requestTypeField['canEdit'] && savedRequestField) {
                    fieldInputElement.prop('disabled', true);
                }
    
    
                var isOldRevision = (typeof (requestRevId) != "undefined" && requestRevId != "");
                var canWrite = true;
                if (window.self != window.top) {
                    canWrite = window.parent.canWrite;
                }
                if (isOldRevision || !canWrite) {
                    fieldInputElement.prop("disabled", "disabled");
                }
    
                console.log(fieldInputElement)
    
                var removeEditorFieldInputButton = $('<button class="removeEditorFieldInputButton btn btn-danger btn-sm">Remove Value</button>');
                var addEditorFieldInputButton = $('<button class="addEditorFieldInputButton btn btn-success btn-sm">New Value</button>');
                var editorFieldValidationErrorLabel = $('<label class="editorFieldValidationErrorLabel"></label>');
                var navlink = $('<button class="navigateLink btn btn-info btn-sm" style="display:none">Open Notebook</button>');
                var clearlink = $('<button href="JavaScript:void(0);" class="clearLink btn btn-danger btn-sm" style="display:none">Clear</button>');
                // Add class to distinguish new field values from existing ones
                if (savedRequestField) {
                    editorFieldInputContainerElement.addClass('existingEditorFieldInputContainer');
                }
                editorFieldInputContainerElement.append(fieldInputElement);
                if (!isOldRevision && canWrite && savedField['dataTypeId'] != dataTypeEnums.REQUEST) {
                    editorFieldInputContainerElement.append(removeEditorFieldInputButton, addEditorFieldInputButton);
                }

                if (savedField["dataTypeId"] == dataTypeEnums.FILE_ATTACHMENT && requestTypeField["sendToELN"]) {
                    var moveFilesToELNBtn = $("<button>")
                        .addClass("moveFilesBtn")
                        .addClass("btn")
                        .addClass("btn-sm")
                        .text("Send to ELN");
                    editorFieldInputContainerElement.append(moveFilesToELNBtn);
                }

                if (savedField['dataTypeId'] == 13 || savedField['dataTypeId'] == 14 || savedField['dataTypeId'] == 15) {
                    $(navlink).attr("fieldId", $(editorFieldInputContainerElement).children().attr('fieldId'))
                    $(clearlink).attr("fieldId", $(editorFieldInputContainerElement).children().attr('fieldId'))
                    if (savedField['dataTypeId'] == 14) {
                        $(navlink).text("Open Project");
                    }
                    else if (savedField['dataTypeId'] == 15) {
                        $(navlink).text("Open Experiment");
                    }
                    editorFieldInputContainerElement.append(navlink);
                    editorFieldInputContainerElement.append(clearlink);
                }
                editorFieldInputContainerElement.append(editorFieldValidationErrorLabel);
                var inputElm = "input"
                if (savedField['dataTypeId'] == dataTypeEnums.DROP_DOWN){
                    inputElm = 'select'
                }

                utilities().permCheck(requestTypeField, editorFieldInputContainerElement, editorFieldInputContainerElement, inputElm);
                resolve(editorFieldInputContainerElement);
            });
        

        });
    }

    /**
     * Gets a link by ID and decodes the target data so it can be used.
     * @param {number} linkId The ID of the link to fetch.
     * @param {number} targetCd The target type code of the link.
     */
    var getLinkDataForField = async function(linkId, targetCd) {
        
        let decodedLinksList = [];
        if (linkId) {    
            const fieldLinkResp = await ajaxModule().getLinkById(linkId);
            const fieldLink = utilities().decodeServiceResponce(fieldLinkResp);

            if (fieldLink) {
                decodedLinksList = await ajaxModule().decodeLink([fieldLink], targetCd);
            }
        }
        return decodedLinksList;
    }

    /**
     * Converts a list of decoded links into a list of select2 options.
     * @param {JSON[]} decodedLinksList The list of decoded links.
     * @param {number} fieldId The field's ID.
     */
    var convertFieldLinkToSelect2Option = function(decodedLinksList, fieldId) {
        return decodedLinksList.map((link) =>
            $("<option>")
                .attr("fieldId", fieldId)
                .attr("id", link["linkId"])
                .attr("selected", "selected")
                .prop("selected", "selected")
                .attr("index", link["abr"])
                .text(link["linkName"])
        );
    }
    
    var checkExistingCoAuthors = function(coAuthId) {
        // Helper function to check already-selected co-authors.
        var returnVal = false;
        $.each($(".editorField[dataTypeId='12']").children(".editorFieldInputContainer"), function (coauthIndex, coauthDiv) {
            $.each($(coauthDiv).children(".editorFieldDropdown"), function (dropdownIndex, dropdown) {
                if ($(dropdown).val() == coAuthId) {
                    returnVal = true;
                }
            });
        });
        return returnVal;
    }

    var getExistingCoAuthors = function() {
        var returnArr = [];

        $.each($(".editorField[dataTypeId='12']").children(".editorFieldInputContainer"), function (coauthIndex, coauthDiv) {
            $.each($(coauthDiv).children(".editorFieldDropdown"), function (dropdownIndex, dropdown) {
                var dropdownId = $(dropdown).val();

                if (dropdownId != "" && dropdownId != null && dropdownId != "null" && dropdownId != undefined) {
                    var dropdownText = $(dropdown).find(`[value=${dropdownId}]`);

                    var userObj = {
                        name: dropdownText[0]["text"],
                        id: dropdownId
                    };

                    returnArr.push(userObj);
                }
            });
        })

        return returnArr;
    }

    var calculateUserDropdown = function(dropdown, userList) {
        // This fires off both on-creation of and on-focus for any co-author dropdowns.
        // This checks the page for any existing co-authors and removes them from the
        // provided dropdown.
        var existingVal = $(dropdown).val();
        $(dropdown).empty();
        $(dropdown).append('<option value="" selected emptyDefaultOption>-- Make a Selection --</option>');
        //make sure name exists in user list to solve discrepancy from workflow to custom experiments
        userList = userList.map(function(u){
            if(u.name === undefined){
                u.name = u.fullName;
            }
            return(u)
        })

        $.each(userList, function (dropdownOptionIndex, dropdownOption) {
            if (!checkExistingCoAuthors(dropdownOption['id'])) {
                var option = $('<option></option>').attr('value', dropdownOption['id']).text(dropdownOption['name']);
                if (window.top != window.self) {
                    if (dropdownOption['id'] != window.parent.ownerId) {
                        $(dropdown).append(option);
                    }
                } else {
                    $(dropdown).append(option);
                }
            }
        });
        utilities().sortDropdownlist($(dropdown));

        $(dropdown).val(existingVal);
    }

    /**
     * Adds a new request field on-demand.
     * @param {*} buttonElement The element that was triggered.
     * @param {number} requestId The request's ID, if we're working from an existing request.
     * @param {JSON} thisRequestType The request type config data.
     * @param {boolean} canReprioritize Can this request be reprioritized?
     * @param {JSON} versionedRequestItems The list of request item config data from a specific date in time.
     * @param {JSON} versionedFields The list of field config data from a specific date in time.
     * @param {boolean} userClick Did the user click on a button to trigger this?
     */
    var requestField_add = function(buttonElement, requestId, thisRequestType, canReprioritize, versionedRequestItems, versionedFields, userClick = false) {
        var wholeEditorField = buttonElement.parent().parent();
        var thisSavedFieldId = parseInt(wholeEditorField.attr('savedfieldid'));
        var thisFieldInput = buttonElement.parent();
        $.each(versionedFields, function (savedFieldIndex, savedField) {
            if (savedField['id'] == thisSavedFieldId) {

                var thisRequestTypeField = thisRequestType["fields"].find(x => x.savedFieldId == savedField["id"]);
    
                var thisFieldInputPromise = new Promise(function (resolve, reject) {
                    if (userClick && typeof wholeEditorField.attr('fieldgroup') !== "undefined" && wholeEditorField.attr('fieldgroup') !== "") {
                        // Make sure each field in this group qualifies for new values
                        var fieldMissingAllowMultiple = false;
                        var fieldMissingCanAdd = false;
                        $.each(wholeEditorField.siblings('.editorField[fieldgroup="' + wholeEditorField.attr('fieldgroup') + '"]'), function () {
                            if ($(this).attr('allowmultiple') !== "1") {
                                fieldMissingAllowMultiple = true;
                            }
                            if ($(this).hasClass('noCanAdd')) {
                                fieldMissingCanAdd = true;
                            }
                        });
    
                        if (fieldMissingAllowMultiple || fieldMissingCanAdd) {
                            if (fieldMissingAllowMultiple) {
                                var notifyTitle = "Error adding values to field group: Not all fields in group allow multiple values."
                            }
                            else {
                                var notifyTitle = "Error adding values to field group: Insufficient permissions to add values to all fields in group."
                            }
                            $.notify({
                                title: notifyTitle,
                                message: ""
                            }, {
                                    delay: 5000,
                                    type: "danger"
                                });
                        }
                        else {
                            requestField_add(wholeEditorField.find('.editorFieldInputContainer:last-of-type .addEditorFieldInputButton'), requestId, thisRequestType, canReprioritize, versionedRequestItems, versionedFields, userClick = false);
                            $.each(wholeEditorField.siblings('.editorField[fieldgroup="' + wholeEditorField.attr('fieldgroup') + '"]'), function () {
                                var buttonElement = $(this).find('.editorFieldInputContainer:last-of-type .addEditorFieldInputButton');
                                requestField_add(buttonElement, requestId, thisRequestType, canReprioritize, versionedRequestItems, versionedFields, userClick = false);
                            });
                        }
                        resolve(true);
                    }
                    else {
                        addRequestEditorField(savedField, savedRequestField = undefined, thisRequestTypeField, requestId, canReprioritize)
                            .then(function (fieldInputElementContainer) {
                                thisFieldInput.after(fieldInputElementContainer);
                                requestFieldHelper().initAllSealectFields(versionedRequestItems, versionedFields);
                                resolve(true);
                            });
                    }
                })
                    .then(function () {
                        thisFieldInput.next().find("input[type='text'], select").focus();
                    });
            }
        });
    }
    
    var requestField_remove = function(buttonElement, userClick = false) {
        var wholeEditorField = buttonElement.parent().parent();
        var thisFieldInput = buttonElement.parent();

        if (userClick && typeof wholeEditorField.attr('fieldgroup') !== "undefined" && wholeEditorField.attr('fieldgroup') !== "") {
            var fieldMissingAllowMultiple = false;
            var fieldMissingCanDelete = false;
            $.each(wholeEditorField.siblings('.editorField[fieldgroup="' + wholeEditorField.attr('fieldgroup') + '"]'), function () {
                // Make sure each field has allowmultiple="1" and doesn't have .noCanAdd
                if ($(this).attr('allowmultiple') !== "1") {
                    fieldMissingAllowMultiple = true;
                }

                if ($(this).hasClass('noCanDelete') && $(this).find('.editorFieldInputContainer:last-of-type').hasClass('existingEditorFieldInputContainer')) {
                    fieldMissingCanDelete = true;
                }
            });
            if (fieldMissingAllowMultiple || fieldMissingCanDelete) {
                if (fieldMissingAllowMultiple) {
                    var notifyTitle = "Error removing values from field group: Not all fields in group allow multiple values."
                }
                else {
                    var notifyTitle = "Error removing values from field group: Insufficient permissions to remove values from all fields in group."
                }
                $.notify({
                    title: notifyTitle,
                    message: ""
                }, {
                        delay: 5000,
                        type: "danger"
                    });
            }
            else {
                // All fields in this group qualify for new values - add a value to each
                $.each(wholeEditorField.siblings('.editorField[fieldgroup="' + wholeEditorField.attr('fieldgroup') + '"]').find('.editorFieldInputContainer:last-of-type'), function () {
                    $(this).remove();
                });
                wholeEditorField.find('.editorFieldInputContainer:last-of-type').remove();
            }
        }
        else {
            buttonElement.parent().remove();
        }
    }

    var displayCommentBox = function(savedFieldId, displayName) {
        $("#commentsModal").attr("savedFieldId", savedFieldId);
        $("#commentsModal").attr("dispName", displayName);
        $("#commentsModal").find("h3").text("Comments for: ").append($("<div>").addClass("modal-title").text(displayName));
    
        $("#comment-body").empty();
    
        $.ajax({
            type: "POST",
            url: "getRequestComments.asp",
            data: {
                expId: window.parent.id,
                expType: 5,
                reqField: savedFieldId
            }
        })
            .done(function (response) {
                var comments = response.split("|||||");
                comments.pop();
                $.each(comments, function (index, comment) {
                    var commentList = comment.split(",,,,,");
                    var user = commentList[0];
                    var date = commentList[1];
                    var text = window.top.decodeDoubleByteString(commentList[2]);
    
                    var commentDiv = $("<div>").addClass("comment");
                    var userDiv = $("<h4>").addClass("modal-title").text(user);
                    var dateDiv = $("<sub>").addClass('modal-title').text(date);
                    var textDiv = $("<div>").addClass('comment-body').text(text);
                    commentDiv.append(userDiv).append(dateDiv).append(textDiv);
                    $("#comment-body").append(commentDiv);
                })
            });
    
        $("#commentsModal").modal('show');
    
        $("#commentsModal").click(function (ev) {
            if (ev.target != this) return;
            $('#commentsModal').modal('hide');
        });
    }
    
    var submitComment = function() {
        var savedFieldId = $("#commentsModal").attr("savedFieldId");
        var displayName = $("#commentsModal").attr("dispName");
        var commentBody = $("#comment-field").val();
    
        var commentUrl = "../experiments/add-comment.asp"
        commentUrl += "?experimentId=" + window.parent.id;
        commentUrl += "&experimentType=" + 5;
        commentUrl += "&parentCommentId=" + 0;
        commentUrl += "&comment=" + commentBody;
        commentUrl += "&r=" + savedFieldId;
    
        $.ajax({
            type: "GET",
            url: commentUrl
        }).done(function () {
            $("#comment-field").val("");
            fetchNumComments(savedFieldId);
            displayCommentBox(savedFieldId, displayName);
        });
        //  swal("test");
    }
    
    var fetchNumComments = function(savedFieldId) {
        $.ajax({
            type: "POST",
            url: "getRequestComments.asp",
            data: {
                expId: window.parent.id,
                expType: 5,
                reqField: savedFieldId
            }
        })
        .done(function (response) {
            console.log(response);
            var comments = response.split("|||||");
            comments.pop();
            var commentCount = $("span[requestfieldid='" + savedFieldId + "']");
            commentCount.text(comments.length);
            if (comments.length > 0) {
                commentCount.removeClass("noComment");
            }
        });
    }

    var bindStructures = function(requestType, versionedRequestItems, versionedFields) {

        var doRegSearchOnSubmit = requestType.searchRegForExistingCompound;

        return new Promise(function (resolve, reject) {
            var fieldsInRequest = $('.editorSection > .editorField');
    
            $.each(fieldsInRequest, function (index, item) {
    
                if ($(item).attr('datatypeid') == 8) {
                    console.log(item);
                    var structureHolder = $(item).children()[1];
                    structureHolder = $(structureHolder).children()[0];
    
    
                    var structureId = "Field_" + index + "_" + $(structureHolder).attr("requestitemtypefieldid");
                    if (typeof thisRequest != "undefined") {
                        var startingMolData = thisRequest["requestFields"][index]["values"][0]['structureMolData_hidden'];
                    }
                    else {
                        var startingMolData = "";
                    }
                    var readOnlyStructure = false;
                    console.log(structureId)

                    var callBack = function(){
                        utilities().autoFillRequestField(structureId, false, versionedRequestItems, versionedFields);

                        if (doRegSearchOnSubmit) {
                            utilities().searchRegForStructure(structureId, versionedRequestItems, versionedFields);
                            utilities().searchForeignReg(structureId, versionedRequestItems, versionedFields);
                        }

                        $(`[liveEditId="${structureImageId}"]`).closest("div.editorField").attr("dirty", true);
                    };
    
                    getChemistryEditorMarkup(structureId, "", startingMolData, 280, 140, readOnlyStructure, callBack, null, null, null, null, null, true).then(function(structureEditorHtml) {
						$(structureHolder).html(structureEditorHtml);
                    });
                    if (window.CurrentPageMode == "repeatRequest")
                    {
                        utilities().autoFillRequestField(structureId, true, versionedRequestItems, versionedFields);
                    }
                    utilities().searchForeignReg(structureId);
    
                }
    
            });
            resolve(true);
        });
    }
    
    var removeProgressClasses = function(uploadBar) {
        uploadBar.removeClass("myBar-upload");
        uploadBar.removeClass("myBar-pause");
        uploadBar.removeClass("myBar-success");
        uploadBar.removeClass("myBar-error");
    }

    var populateUserDropdown = function(userList, fieldInputElement) {
        return new Promise(function(resolve, reject) {
            var existingCollabs = getExistingCoAuthors();
            $.each(existingCollabs, function(i, collab) {
                if (userList.filter(x => x.id == collab.id).length == 0) {
                    userList.push(collab);
                }
            });
            
            calculateUserDropdown(fieldInputElement, userList);
            $(fieldInputElement).focus(() => calculateUserDropdown(fieldInputElement[0], userList));

            resolve(true);
        })
    }

    var documentReadyFunction = function() {

        $('body').on('click', 'button.removeEditorFieldInputButton', function (event) {
            requestField_remove($(this), userClick = true)
            utilities().showUnsavedChangesNotification();
        });

        $('body').on('click', 'button.comment-submit', function (event) {
            submitComment();
        });
    
    }

    //#region Input Field Generators

    /**
     * Creates a text input element to be returned and used in the form 
     * @param {string} className The class name(s) for this textarea; request fields and request item fields have different CSS.
     * @param {string} value The text to insert.
     */
    var createTextInput = function(className, value){
        var textInput = $('<input type="text">').attr('value', value);
        textInput.addClass(className);
        return textInput
    }


    /**
     * Creates a <textarea> element for request types and request item types.
     * @param {string} className The class name(s) for this textarea; request fields and request item fields have different CSS.
     * @param {number} value The text to insert.
     */
    var createLongTextInput = function(className, value) {
        if (value == null){
            value = ""
        }
        return $(`<textarea>${value}</textarea>`).addClass(className);
    }

    /**
     * Creates a int input element to be returned and used in the form 
     * @param {string} className The class name(s) for this int field; request fields and request item fields have different CSS.
     * @param {int} value The int to insert.
     */
    var createIntegerInput = function(className, value){
        if (!isNaN(parseInt(value)))
        {
            return $("<input type='number'>").addClass(className).attr("value", value);
        }
        else 
        {
            return $("<input type='number'>").addClass(className);
        }
    }

    /**
    * Creates a int input element to be returned and used in the form 
    * @param {string} className The class name(s) for this float field; request fields and request item fields have different CSS.
    * @param {decimal} value The number to insert.
    */
    var createRealNumberInput = function(className, value){
        return $("<input type='number' step='0.1'>").addClass(className).attr("value", value);
    }


    /**
     * Creates a <select> element for request types and request item types.
     * @param {string} className The class name(s) for this dropdown; request fields and request item fields have different CSS.
     * @param {object} field The field used to construct this dropdown's options.
     * @param {object} requestTypeField The request type field config info.
     * @param {number} value The dropdown value to select.
     * @param {number} requestId Does this request already exist? i.e. are we updating.
     * @param {bool} canReprioritize Can this user reprioritize this request?
     */
    var createDropDownSelectInput = function(className, field, requestTypeField, value, requestId, canReprioritize) {

        if (value == undefined) {
            value = "";
        }

        var dropdownInput = $("<select>").addClass(className);
        var emptyInput = createDropDownOption("", "-- Make a Selection --");
        dropdownInput.append(emptyInput);

        $.each(field["options"], function(i, option) {
            if (option.disabled != 1) {
                var thisOption = createDropDownOption(option["dropdownOptionId"], option["displayName"]);

                if (requestId) {
                    var disabledFilterOption = (!canReprioritize && utilities().hasQueueableOption(requestTypeField["requestTypeFieldPriorityOptions"]));
                    
                    if (disabledFilterOption) {
                        disabledFilterOption = option["dropdownOptionId"] != value;
                    }

                    thisOption.attr("disabled", disabledFilterOption);
                }

                dropdownInput.append(thisOption);
            }
        });

        utilities().sortDropdownlist(dropdownInput);

        // Using .attr to set a selected option seems to only work in Chrome
        // so use .prop instead  - IDQ4923 & 4924
        dropdownInput.find(`option[value="${value}"]`).prop("selected", "selected");

        // Chrome needs attr.
        dropdownInput.find(`option[value="${value}"]`).attr("selected", true);

        var queueableOptionIds = requestTypeField["requestTypeFieldPriorityOptions"] ? requestTypeField["requestTypeFieldPriorityOptions"]
            .filter(x => x.queueable)
            .map(x => x.dropDownOptionId) : [];

        var reprioritizingRequest = requestId ? false : canReprioritize && queueableOptionIds.includes(value);
        dropdownInput.attr("reprioritizingRequest", reprioritizingRequest);

        dropdownInput.on("change", function() {
            var selectedValue = parseInt($(this).find("option:selected").val());
            var reprioritizingRequest = canReprioritize &&
                queueableOptionIds.includes(selectedValue) &&
                !(queueableOptionIds.includes(value) && requestId);
            $(this).attr("reprioritizingRequest", reprioritizingRequest);
        });

        return dropdownInput;
    }

    /**
     * Helper function for createDropDownSelectInput that builds an <option> element.
     * @param {*} value The value of this <option>
     * @param {string} text The <option> text.
     */
    var createDropDownOption = function(value, text) {
        return $("<option>").val(value).text(text);
    }

    /**
     * Creates a <div> element for structure fields.
     * @param {string} className The class name(s) for this structure field.
     * @param {number} requestItemTypeFieldId The request item type field id of this structure.
     * @param {string} value Currently unused because the value could be fetched in an ajax call.
     */
    var createStructureInput = function(className, requestItemTypeFieldId, value) {
        return $("<div>").addClass(className).attr('requestitemtypefieldid', requestItemTypeFieldId);
    }

    /**
     * Creates a date field.
     * @param {*} className The class names to be attached to the fiedl
     * @param {*} value The value to be used
     */
    var createDateInput = function(className, value){

        var fieldInputElement = $('<input type="text">').addClass(className).attr('value', value).attr("initVal", value);

        pikadaySettingsObject = {
            firstDay: 1,
            minDate: new Date(1990, 0, 1),
            maxDate: new Date(2040, 12, 31),
            yearRange: [1990, 2040],
            format: 'MM/DD/YYYY'
        };

        if (value) {
            // Moment can localize incoming time strings so let's leverage that.
            var previousValueFormatted = moment.utc(value).format("MM/DD/YYYY");
            pikadaySettingsObject['defaultDate'] = moment(previousValueFormatted).toDate();
            pikadaySettingsObject['setDefaultDate'] = true;
            var picker = fieldInputElement.pikaday(pikadaySettingsObject);
        }
        else {
            var picker = fieldInputElement.pikaday(pikadaySettingsObject);
        }

        return picker;
    }



    var createRegLink = function(savedField, value) {
        
        var color = "btn-info";
        var foreignLink = ""
        if ([dataTypeEnums.FOREIGN_LINK].includes(savedField['dataTypeId'])) {
            color = "btn-success";
            foreignLink = "foreignLinkBtn";
        }

        var className = `btn btn-sm ${color} ${foreignLink}`;

        var linkText = value;
        var linkVal = value;
        var linkHref = "javascript:void(0)";
        if (value != "" && value !== null && value !== undefined) {
            if (value == -1) {
                linkText = "New Compound";
            } else {
                if (savedField["dataTypeId"] == dataTypeEnums.REGISTRATION) {
                    linkHref = `/arxlab/registration/showReg.asp?regNumber=${value}`;
                }
            }
        } else {
            linkText = "No link";
        }

        var regLink = $("<a>")
            .addClass(className)
            .text(linkText)
            .val(linkVal)
            .attr("target", "_blank")
            .attr("href", linkHref);

        return regLink;
    }

    /**
     * Creates a field that is used to display read only data and to be auto generated on the back end.
     * @param {string} className The class name(s) for this field; request fields and request item fields have different CSS.
     * @param {string} value The text to insert.
     */
    var createAutoGeneratedField = function(className, value){

        var randomId = Math.random().toString(36).substring(2);

        let textInput = $(`<input id=${randomId} disabled type="text">`).attr('value', value ? value : "");
        let btn = $(`<button" onclick="utilities().copyFnc('${randomId}')"class="navigateLink btn btn-info btn-sm">Copy</button>`);

        textInput.addClass(className);
        
        let retField = $("<div>").append(textInput);
        if (value ) {
            retField.append(btn);
        }

        return retField
    }


    //#endregion

    //#region Editor Field Generators

    /**
     * Creates a request type text input.
     * @param {string} value The text to insert into this textarea.
     */
    var requestTypeTextGenerator = function(value) {
        return createTextInput("editorFieldInput", value);
    }

    /**
     * Creates a request item type text input.
     * @param {string} value The text to insert into this textarea.
     */
    var requestItemTypeTextGenerator = function(value) {
        return createTextInput("dataTableCellTextInput", value);
    }
 
    /**
     * Creates a request type textarea.
     * @param {string} value The text to insert into this textarea.
     */
    var requestTypeLongTextGenerator = function(value) {
        return createLongTextInput("editorFieldInput", value);
    }

    /**
     * Creates a request item type textarea.
     * @param {string} value The text to insert into this textarea.
     */
    var requestItemTypeLongTextGenerator = function(value) {
        return createLongTextInput("dataTableCellTextarea", value);
    }

    /**
     * Creates a request type text input.
     * @param {int} value The int to insert into this textarea.
     */
    var requestTypeIntGenerator = function(value) {
        return createIntegerInput("editorFieldInput", value);
    }

    /**
    * Creates a request item type text input.
    * @param {int} value The int to insert into this textarea.
    */
    var requestItemTypeIntGenerator = function(value) {
        return createIntegerInput("dataTableCellTextInput", value);
    }


    /**
    * Creates a request type text input.
    * @param {decimal} value The decimal to insert into this textarea.
    */
    var requestTypeNumberGenerator = function(value) {
        return createRealNumberInput("editorFieldInput", value);
    }

    /**
    * Creates a request item type text input.
    * @param {decimal} value The decimal to insert into this textarea.
    */
    var requestItemTypeNumberGenerator = function(value) {
        return createRealNumberInput("dataTableCellTextInput", value);
    }

    /**
     * Creates a request type dropdown.
     * @param {object} field The field used to construct this dropdown's options.
     * @param {object} requestTypeField The request type field config info.
     * @param {number} value The dropdown value to select.
     * @param {number} requestId Does this request already exist? i.e. are we updating.
     * @param {bool} canReprioritize Can this user reprioritize this request?
     */
    var requestTypeDropdownGenerator = function(field, requestTypeField, value, requestId, canReprioritize) {
        return createDropDownSelectInput("editorFieldDropdown requestFieldDropdown", field, requestTypeField, value, requestId, canReprioritize);
    }
    
    /**
     * Creates a request item type dropdown.
     * @param {object} field The field used to construct this dropdown's options.
     * @param {object} requestTypeField The request item type field config info.
     * @param {number} value The dropdown value to select.
     */
    var requestItemTypeDropdownGenerator = function(field, requestItemTypeField, value) {
        return createDropDownSelectInput("dataTableCellDropdown", field, requestItemTypeField, value, null, null);
    }

    /**
     * Creates a structure editor.
     * @param {number} requestItemTypeFieldId The request item type field id of this structure.
     * @param {string} value Currently unused because the value could be fetched in an ajax call.
     */
    var requestTypeStructureGenerator = function(requestItemTypeFieldId, value) {
        return createStructureInput("structureDisplay", requestItemTypeFieldId, value);
    }
 
   /**
     * Creates a request type date field.
     * @param {number} value The date value.
     */
    var requestTypeDateGenerator = function(value) {
        return createDateInput("editorFieldInput", value);
    }
    
    /**
     * Creates a request item type date field.
     * @param {number} value The date value.
     */
    var requestItemTypeDateGenerator = function(value) {
        return createDateInput("dataTableCellDateInput", value);
    }

    /**
     * Creates a text input to be converted to a CK Editor field.
     * @param {string} ckeId The ID of this CK Editor.
     * @param {string} value The value to insert into this editor.
     */
    var requestTypeCKEditorGenerator = function(ckeId, value) {
        var ckeditorInput = createLongTextInput("editorFieldInput ckEditorField", value);
        ckeditorInput.attr("id", ckeId);
        return ckeditorInput;
    }

    var requestTypeRegLinkGenerator = function(savedField, value) {
        return createRegLink(savedField, value);
    }

    var requestItemTypeRegLinkGenerator = function(savedField, value) {
        return createRegLink(savedField, value);
    }

    /**
     * Creates a field that is used to store the auto generated value.
     * @param {string} value The text to insert into this textarea.
     */
    var requestAutoGeneratedField = function(value) {
        return createAutoGeneratedField("editorFieldInput", value);
    }

    //#endregion
    
    return {
        makeNewEditorField: makeNewEditorField,
        fetchNumComments: fetchNumComments,
        displayCommentBox: displayCommentBox,
        bindStructures: bindStructures,
        requestField_add: requestField_add,
        getLinkDataForField: getLinkDataForField,
        documentReadyFunction: documentReadyFunction,
        requestItemTypeLongTextGenerator: requestItemTypeLongTextGenerator,
        requestItemTypeDropdownGenerator: requestItemTypeDropdownGenerator,
        requestTypeTextGenerator: requestTypeTextGenerator,
        requestItemTypeTextGenerator: requestItemTypeTextGenerator,
        requestTypeStructureGenerator: requestTypeStructureGenerator,
        requestItemTypeIntGenerator: requestItemTypeIntGenerator,
        requestItemTypeNumberGenerator: requestItemTypeNumberGenerator,
        requestItemTypeRegLinkGenerator: requestItemTypeRegLinkGenerator,
        requestItemTypeDateGenerator: requestItemTypeDateGenerator,
        requestAutoGeneratedField: requestAutoGeneratedField,
    }
}

var fieldsModuleHelper = fieldsModule();

$(document).ready(function() {
    fieldsModuleHelper.documentReadyFunction();
});