requestEditorModule = function() {
    /**
     * Populates the Request Fields section on a request editor.
     * @param {JSON} requestType The current request type.
     * @param {string} selectorString The selector string to build from.
     * @param {JSON} savedRequest The request for the editor we're building, if we're not making a brand new one.
     * @param {boolean} canReprioritize Can this request be reprioritized?
     * @param {JSON} versionedFields The list of fields and their configurations for the point time that savedRequest existed at.
     * @param {JSON} versionedRequestItems The list of request items and their configurations for the point time that savedRequest existed at.
     */
    var populateRequestFieldsSection = function(requestType, selectorString = ".editorSection[sectionid='requestFields']", savedRequest, canReprioritize, versionedFields, versionedRequestItems) {
        return new Promise(function (resolve, reject) {
            console.log("!!!!!!!!!!!!!!!!!!!!! populateRequestFieldsSection !!!!!!!!!!!!!!!!!!!!!!!!!");
            console.log(requestType);
            console.log(savedRequest);
            console.log(selectorString);

            var requestId = null;
            if (savedRequest && CurrentPageMode != "repeatRequest") {
                requestId = savedRequest["id"];
            }

            populateUserGroupsList().then(function() {
        
                var populateRequestFieldsSectionInterval = window.setInterval(function () {
                    console.log("looking for selectorString: ", selectorString);
                    if ($(selectorString).length == 0 || typeof versionedFields == "undefined") {
                        return;
                    }
            
                    console.log("ok, found it");
                    window.clearInterval(populateRequestFieldsSectionInterval);
                    populateRequestFieldsSectionImpl(requestType, selectorString, savedRequest, canReprioritize, versionedFields)
                    .then(function () {
                        var bindPromises = [];
                        bindPromises.push(fieldsModuleHelper.bindStructures(requestType, versionedRequestItems, versionedFields));
            
                        Promise.all(bindPromises).then(function () {
                            var anyFields = requestType.fieldsDict.sortOrder.map(x => requestType.fieldsDict[x][0].disabled).length > 0;
                            fieldsReady = anyFields ? $(".editorFieldInputContainer").length : true;
                            //Timeout with zero time so it goes to the back of the promise queue

                            if (!window.location.href.toLowerCase().includes("makenewrequest")) {
                                window.setTimeout(function(){
                                    if (fieldsReady) {
                                        finalizeRequestEditorInitialization().then(function() {
                                            $("#basicLoadingModal").modal("hide");
                                        });
                                    }
                                });
                            }
                            resolve(true);
                        });
                    });
        
                    $("body").off("click", "button.addEditorFieldInputButton");
                    
                    $('body').on('click', 'button.addEditorFieldInputButton', function (event) {
                        fieldsModule().requestField_add($(this), requestId, requestType, canReprioritize, versionedRequestItems, versionedFields, userClick = true)
                        utilities().showUnsavedChangesNotification();
                    });

                    $("body").off("click", "button.moveFilesBtn");

                    $("body").on("click", "button.moveFilesBtn", function(event) {

                        // Figure out what files to add to the modal.
                        let fileForms = $(event.target.parentElement.parentElement).find("form");
                        let fileList = [];

                        $.each(fileForms, function(i, f) {
                            let fileId = $(f).attr("fileid");

                            // Check if the file form has a fileID on its attributes and if it does,
                            // make a file object and add it to the list.
                            if (fileId && fileId > -1) {
                                let fileName = $(f).find(".currentFileLink").text();
                                let file = {
                                    id: fileId,
                                    name: fileName,
                                };
    
                                fileList.push(file);
                            }
                        });
                        
                        // If we have any files, populate the modal and display it. Otherwise,
                        // tell the user there are no files.
                        if (fileList.length > 0) {
                            populateMoveFilesModal(fileList);
                            $("#moveFilesModal").modal("show");
                        } else {
                            swal("No files to send!");
                        }
                    });

                    $("body").off("click", "button.cancel-send-btn");

                    $("body").on("click", "button.cancel-send-btn", function(event) {
                        $("#moveFilesModal").modal("hide");
                    });

                    $("body").off("click", "button.send-file-submit-btn");

                    $("body").on("click", "button.send-file-submit-btn", function(event) {
                        submitFileMoveBtnClick();
                    });

                });
            }
        )}
    )}
    
    /**
     * Clears the contents of the file sending modal and populates it with the given list of files.
     * @param {JSON[]} fileList The list of files to add to the file sending modal.
     */
    let populateMoveFilesModal = function(fileList) {
        
        // Empty the experiment search typeahead and the file section.
        $("#workflowFileExperimentSearch").select2("data", null);
        let fileSection = $("#moveFilesSelectorSection");
        fileSection.empty();

        // For every file, build a checkbox using the properties of the file.
        fileList.forEach(function(file) {
            let checkboxDiv = $("<div>")
                .addClass("fileImportRadioButton");
            let fileCheckbox = $("<input>")
                .attr("type", "checkbox")
                .addClass("defaultSettingButton")
                .attr("id", `sendFile_${file.id}`)
                .val(file.id);
            let fileLabel = $("<label>")
                .attr("for", `sendFile_${file.id}`)
                .addClass("defaultSettingLabel")
                .text(file.name);
            
            // If we only have one file, pre-check the checkbox and disable it;
            // no reason to allow this as a toggle if its the only option.
            if (fileList.length == 1) {
                fileCheckbox.prop("checked", true)
                    .prop("disabled", true);
            }

            checkboxDiv.append(fileCheckbox, fileLabel);
            fileSection.append(checkboxDiv);
        });
    }

    /**
     * Onclick handler for the file-move-submit button.
     */
    let submitFileMoveBtnClick = function() {

        // Start with validation.
        let errorMsg = "";

        // Determine if we have any files selected. If not, then we have a problem.
        let selectedFilesList = $("#moveFilesSelectorSection").find(":checked");
        let numFiles = selectedFilesList.length;
        if (numFiles == 0) {
            errorMsg = "No files selected.";
        }
        
        // Determine if the user has selected an experiment to move the file(s) to.
        let expData = $("#workflowFileExperimentSearch").select2("data");
        if (!expData) {
            errorMsg = "No experiment selected.";
        }

        // If there were any errors, halt execution and display the error message.
        if (errorMsg != "") {
            window.top.swal("error", errorMsg, "warning");
            return;
        }

        // Hide the file mover modal and show the loading one.
        $("#moveFilesModal").modal("hide");
        $("#basicLoadingModal").modal("show");

        // Now that input validation has been taken care of, pull out all of the
        // necessary data from the inputs.
        let expId = expData.id;
        let expTypeId = expData.type;
        let expOwnerId = expData.owner;

        // Make a list of file IDs, then make a promise array to send every selected file to the ELN.
        let fileIdList = selectedFilesList
            .map((arrayIndex, fileCheckbox) => $(fileCheckbox).val())
            .toArray();
        let attachmentPromiseList = fileIdList.map(fileId => ajaxModule().sendFileToELNExperiment(fileId, expId, expTypeId, expOwnerId));

        // Now wait for all of the files to be sent off.
        Promise.all(attachmentPromiseList).then(function(resArr) {
            $("#basicLoadingModal").modal("hide");

            // Check to see if any file responses were not the successful one.
            let failedRespList = resArr.filter(x => x != "Success!");
            
            // If there were no failures, set a new experiment draft and figure out the success message to display.
            if (failedRespList.length == 0) {
                ajaxModule().setExperimentDraft(expId, expTypeId).then(function(draftRes) {
                    let multipleFileStr = numFiles > 1 ? "s have" : " has";
                    window.top.swal({
                        "title": "Success!",
                        "type": "success",
                        "text": `Your attachment${multipleFileStr} been copied and a new draft has been created.`,
                        "showCancelButton": true,
                        "cancelButtonText": "OK",
                        "confirmButtonText": "Go to experiment"
                    }, function() {
                        requestFieldHelper().NavToExperement(expId, expData.index);
                    });
                });
            } else {
                // If we have failed somewhere, then instantiate a generic error message and determine what the error was.
                let errorMsg = "Error!";

                if (checkSendELNError(failedRespList, "writeError")) {
                    errorMsg = "You do not have access to this experiment.";
                } else if (checkSendELNError(failedRespList, "draftError")) {
                    errorMsg = "The experiment is locked by an active draft.";
                } else if (checkSendELNError(failedRespList, "fileExistsError")) {
                    errorMsg = "File already exists for current draft.";
                } else if (checkSendELNError(failedRespList, "fileNonexistenceError")) {
                    errorMsg = "File could not be found.";
                }
                window.top.swal("Error", errorMsg, "warning")
            }
        });
    }

    /**
     * Check the list of responses to determine if the given error message is in there.
     * @param {string[]} respList The list of responses.
     * @param {string} errorMsg The error message to check for.
     */
    var checkSendELNError = function(respList, errorMsg) {
        return respList.filter(resp => resp == errorMsg).length > 0;
    }

    /**
     * Give it a field Id, waits for it to be in the dom before returning
     */
    var waitForFieldLoading = function(fieldId){
        return new Promise(function (resolve, reject) {(
            function waitForFieldLoaded(fieldIdActual){
                result = $(`.editorField[requesttypefieldid=${fieldIdActual}]`);
                if (result.length > 0){ 
                    return resolve(result);
                }
                setTimeout(waitForFieldLoaded.bind(null, fieldId), 100);
            })(fieldId);
        });
    };

    /**
     * Populates the Request Fields section on a request editor. Not sure what "Impl" means.
     * @param {JSON} requestType The current request type.
     * @param {string} selectorString The selector string to build from.
     * @param {JSON} savedRequest The request for the editor we're building, if we're not making a brand new one.
     * @param {boolean} canReprioritize Can this request be reprioritized?
     * @param {JSON} versionedFields The list of fields and their configurations for the point time that savedRequest existed at.
     */
    var populateRequestFieldsSectionImpl = function(requestType, selectorString, savedRequest, canReprioritize, versionedFields) {
    
        return new Promise(function (resolve, reject) {
            if (window.duplicateRequestId && !savedRequest && !window.requestFieldsSectionPopulatedForDupRequest) {
                // If this is the duplicateRequest page and we haven't yet run through this function w/ the savedRequest, this is unnecessary
                resolve(false);
                return false;
            }
            else if (window.duplicateRequestId && savedRequest) {
                window.requestFieldsSectionPopulatedForDupRequest = true;
            }

            $(selectorString).empty();
            var fieldBuilderPromises = [];

            $.each((requestType['fieldsDict']['sortOrder']), function (index, requestTypeFieldId) {
                if (requestType["fields"].find(x=>x.requestTypeFieldId == requestTypeFieldId)["disabled"] == 0) {
                    fieldBuilderPromises.push(fieldsModuleHelper.makeNewEditorField(requestType, savedRequest, canReprioritize, requestTypeFieldId, versionedFields));
                }
            });

            var editorFieldPromises = [];
            Promise.all(fieldBuilderPromises).then(function (editorFields) {
                $.each(editorFields, function(editorFieldIndex, editorField) {
                    if (editorField) {
                        $(selectorString).append(editorField);
                        editorFieldPromises.push(waitForFieldLoading(editorField.attr("requestTypeFieldId")));
                    }
                });

                Promise.all(editorFieldPromises).then(function(editorFields) {
                    $.each(editorFields, function(editorFieldIndex, editorField) {
                        if (editorField) {
                            if (window.self != window.top && editorField.attr("requestfieldid") != undefined) {
                                if (window.parent.latestStatus != "6") {
    
                                    var fieldLabel = editorField.find(".fieldLabel");
                                    var fieldLabelText = $(fieldLabel).text();
                                    var numComments = $("<span></span>").attr("requestfieldid", editorField.attr('requestFieldId')).addClass("commentNotification").addClass("noComment");
                                    numComments.attr("title", "Number of Comments");
                                    fieldLabel.append(numComments);
                
                                    fieldsModuleHelper.fetchNumComments(editorField.attr('requestFieldId'));
                                    fieldLabel.on("click", function () {
                                        fieldsModuleHelper.displayCommentBox(editorField.attr("requestFieldId"), fieldLabelText);
                                    });
                                }
                            }
                        }
                    });
    
                    if (savedRequest) {
                        // Any coauthor who has saved a change to this request is not editable or removeable
                        console.log("-----------savedRequest----------------");
                        console.log(savedRequest);
                        if (savedRequest.hasOwnProperty("coauthors")) {
                            $.each(savedRequest["coauthors"], function (i, authorId) {
                                console.log("found: ", $(".editorField[datatypeid='12']").find('select option[value="' + authorId + '"]:selected'));
                                if (hasCoAuthMadeEdits(authorId)) {
                                var theSelects = $(".editorField[datatypeid='12']").find('select option[value="' + authorId + '"]:selected').parent();
                                $(theSelects).parent().find(".removeEditorFieldInputButton").css("display", "none");
                                $(theSelects).attr("disabled", "disabled");
                                }
                            });
                        }
    
                        if (requestType['restrictAccess'] == 1 && requestType['canEdit'] == 0) {
                            // Viewing an existing request and the requestType doens't allow editing - disable all fields
                            $(selectorString).closest('.dropdownEditorContainer').find('input, select, button').prop('disabled', true);
                        }
                    }
                    else {
                        // If this is a new request, go through all the editable dropdowns in the request editor w/ only 1 non-empty default option, select it
                        $.each($('.requestEditorContainer.newRequestEditor #requestFieldsEditorSection .editorField select:not([disabled])'), function () {
                            if ($(this).find('option:not([emptyDefaultOption])').length == 1) {
                                $(this).find('option:not([emptyDefaultOption])').prop('selected', true);
                            }
                        })
                    }

                    resolve(true);
    
                });
            });

        });
    };

    var populateDraftVals = function(thisRequestType, versionedRequestItems, versionedFields) {
        
        return new Promise(function(resolve, reject) {
            var editorPromises = [];

            editorPromises.push(populateDraft(versionedRequestItems, versionedFields));
    
            Promise.all(editorPromises).then(function () {
                console.log("EDITOR DONE");
                window.parent.$("#submitRow").show();
                requestEditorHelper.bindRichTextFields(versionedRequestItems, versionedFields).then(function () {
    
                    // Moving this down very slightly to make sure it happens /after/ the draft population is done because
                    // the requestFields <tr>
                    if (window.CurrentPageMode == 'custExp')
                    {
                        window.top.$("#requestFields").empty();
                    }
                    requestFieldHelper().applyDependencies(thisRequestType, versionedFields);
                    if (window.top.currApp == "ELN") {
                        window.parent.$("#basicLoadingModal").modal("hide");
                        utilities().resizeManageRequestsTable();
                        try{
                            window.parent.bindSaveShortcut();
                        } catch(e){
                            // Do nothing, we don't particularly care if this fails because we're in read-only mode.
                        }
                    }
                    utilities().resizeCustExpIframe();
    
                    resolve(true);
                });
    
    
            });
    
        });

    };

    var hasCoAuthMadeEdits = function(authorId) {
        if (window.top.currApp != "ELN") {
            return false;
        }
      
        if (window.auditTrailAuthors.length == 0) {
            ajaxModule().fetchAuditTrailAuthors().then(function () {
                return window.auditTrailAuthors.includes(authorId);
            });
        } else {
            return window.auditTrailAuthors.includes(authorId);
        }
    }
    
    var notifyELNCollaborator = function(UID) {
        if (!window.parent.coAuthors.includes(UID)) {

            var Title = "Experiment Collaborator";
            var Note = `You have been added as a Collaborator on Experiment: <a href="${window.parent.location.href}">${window.top.$("#e_name").val()}</a>`
            var noteType = 17;

            if (!isNaN(UID)) {
                $.ajax({
                    type: "POST",
                    url: "Notify.asp",
                    async: false,
                    data:
                    {
                        "UID": UID,
                        "Title": Title,
                        "Note": Note,
                        "noteType": noteType
                    }
                })
                .done(function (response) {
                    console.log(response);
                });
                if (UID != null)
                {
                    window.parent.coAuthors += "," + UID.toString();
                }
            }
        }
    }

    /**
     * Helper function to get a request field and package it for submission.
     * @param {*} editorField The JQuery selected editor field.
     * @param {number} requestId The request's ID.
     */
    var getRequestField = function(editorField, requestId=null) {
        return new Promise(function(resolve, reject) {
            var thisRequestField = {
                requestTypeFieldId: parseInt($(editorField).attr('requesttypefieldid')),
                companyId: globalUserInfo.companyId,
                sortOrder: parseInt($(editorField).attr('sortorder'))
            };
    
            if (requestId) {
                thisRequestField["requestId"] = requestId;
            }
    
            var requestFieldsId = $(editorField).attr("requestfieldid");
            if (!isNaN(requestFieldsId)) {
                thisRequestField["id"] = parseInt(requestFieldsId);
            }
            
            var dataTypeId = parseInt($(editorField).attr('datatypeid'));
    
            var requestFieldValuePromises = [];
            $(editorField).find('select, input[type="text"], input[type="number"], textarea, form.requestFieldFileAttachmentForm').each(function (requestFieldValueIndex, requestFieldEditor) {
                requestFieldValuePromises.push(fieldValuePromiseHelper(this, thisRequestField, dataTypeId, requestFieldValueIndex));
            })

            if (requestFieldValuePromises.length > 0) {    
                Promise.all(requestFieldValuePromises).then(function(requestFieldValues) {
                    thisRequestField["requestFieldValues"] = requestFieldValues.filter(x => x);
                    resolve(thisRequestField);
                });
            } else {
                var requestFieldValues = [];
                if (dataTypeId == dataTypeEnums.STRUCTURE) {
        
                    var editerDiv = $(editorField).children()[1];
                    var strDisplay = $(editerDiv).children().children().children()[1];
                    var strDataDiv = $(strDisplay).children();
                    var liveEditId = $(strDataDiv).attr('liveeditid');
        
                    thisRequestFieldValue = {}
                    thisRequestFieldValue['sortOrder'] = 1;
                    var moldata = null;
                    moldata = allStructures[liveEditId];
                    if (moldata == null || moldata == undefined) {
                        var moldata = getEmptyMolFile()
                    }
        
                    thisRequestFieldValue['structureDiagram'] = moldata;
                    requestFieldValues.push(thisRequestFieldValue);
                }
                else if (dataTypeId == dataTypeEnums.REGISTRATION || dataTypeId == dataTypeEnums.FOREIGN_LINK) {
                    var aLink = $(editorField).find("a");
        
                    var thisRequestFieldValue = {};
                    thisRequestFieldValue["textValue"] = aLink.val();
                    thisRequestFieldValue['sortOrder'] = 1;
                    requestFieldValues.push(thisRequestFieldValue);
                }
                else if (dataTypeId == dataTypeEnums.REQUEST)
                {
                    var aLink = $(editorField).find("a");
                    $.each(aLink, function(index, item){
                        var thisRequestFieldValue = {};
                        var valObj = {};
                        var key = $(item).attr('reqid');
                        var val = $(item).html();
                        if (key === undefined)
                        {
                            key = null;
                        }
                        valObj[key] = val;
                        thisRequestFieldValue["textValue"] = JSON.stringify(valObj);              
                        thisRequestFieldValue['sortOrder'] = index + 1;
                        requestFieldValues.push(thisRequestFieldValue);
                    });
                }
                else if (dataTypeId == dataTypeEnums.BIOSPIN_EDITOR) {
                    const aLink = $(editorField).find("a");
                    const value = aLink.attr("expId");

                    if (window.top != window.self && window.top.experimentJSON) {
                        if ("bioEditorIds" in window.top.experimentJSON) {
                            window.top.experimentJSON.bioEditorIds.push(value);
                        }
                        else {
                            window.top.experimentJSON.bioEditorIds = [value];
                        }
                    }

                    var thisRequestFieldValue = {};
                    thisRequestFieldValue["textValue"] = value;
                    thisRequestFieldValue['sortOrder'] = 1;
                    requestFieldValues.push(thisRequestFieldValue);

                }
                thisRequestField["requestFieldValues"] = requestFieldValues;
                resolve(thisRequestField);
            }
        })
    }

    /**
     * Fetches the value of a request field. Function is wrapped in a promise because the Experiment field has to make a call
     * to the ASP to decode some data.
     * @param {*} editorField The JQuery selected editor field.
     * @param {JSON} thisRequestField The field.
     * @param {number} dataTypeId The field's data type ID.
     * @param {number} requestFieldValueIndex The index of this request field.
     */
    var fieldValuePromiseHelper = function(editorField, thisRequestField, dataTypeId, requestFieldValueIndex) {
        return new Promise(function(resolve, reject) {

            var thisRequestFieldValue = {
                companyId: globalUserInfo.companyId,
                sortOrder: requestFieldValueIndex + 1
            };

            if (thisRequestField["id"]) {
                thisRequestFieldValue["requestFieldsId"] = thisRequestField["id"];
            }

            var fieldValuePromiseList = [];
            
            var keyToUse = "textValue";
            var fieldVal = "";
            if (dataTypeId == dataTypeEnums.INTEGER) {
                keyToUse = "intValue";
                fieldVal = $(editorField).val();
            } else if (dataTypeId == dataTypeEnums.REAL_NUMBER) {
                keyToUse = "realValue";
                fieldVal = $(editorField).val();
            } else if ([dataTypeEnums.DROP_DOWN, dataTypeEnums.USER_LIST, dataTypeEnums.CO_AUTHORS].includes(dataTypeId)) {
                keyToUse = "dropDownValue";
                fieldVal = $(editorField).find('option:selected').attr('value');
                if (isNaN(fieldVal)) {
                    fieldVal = null;
                } else {
                    fieldVal = parseInt(fieldVal);
                }
                if (window.top.thisRequestType != null) {
                    if (dataTypeId == dataTypeEnums.CO_AUTHORS && window.self != window.top && window.top.thisRequestType['notifyColabs']) {
                        notifyELNCollaborator(fieldVal);
                    }
                }
            } else if (dataTypeId == dataTypeEnums.FILE_ATTACHMENT) {
                keyToUse = "fileId";
                
                var fieldVal = $(editorField).attr('fileid');
                if (isNaN(fieldVal)) {
                    fieldVal = null;
                } else {
                    fieldVal = parseInt(fieldVal);
                } 
            } else if (dataTypeId == dataTypeEnums.DATE) {
                keyToUse = "dateValue";
                fieldVal = $(editorField).val();

                if (fieldVal !== "") {
                    fieldVal = new Date(moment.utc($(editorField).val(), "MM/DD/YYYY").unix() * 1000);
                }
            } else if (dataTypeId == dataTypeEnums.RICH_TEXT) {
                fieldVal = ckEditorInstances[$(editorField).attr("id")].getData();
                //this replaces the "zero width space" with "" since it does not prosses correctly in the asp
                fieldVal = fieldVal.replace(new RegExp("[\u200b]", 'g'), '');
                fieldVal = utilities().encodeIt(fieldVal);  
            } else if ([dataTypeEnums.NOTEBOOK, dataTypeEnums.PROJECT].includes(dataTypeId)) {
                keyToUse = "intValue";
                fieldVal = 0;

                if (["searchForNotebook", "searchForProject"].includes($(editorField).attr('id'))) {
                    var linkData = $(editorField).select2("data");
    
                    if (linkData != null) {
                        if (Object.keys(linkData).includes("id")) {
                            var linkTargetId = linkData["id"];
        
                            if (linkTargetId != -1) {
                                var linkInput = utilities().makeLinkInputModel(linkTargetId, dataTypeId);
                                thisRequestFieldValue["link"] = linkInput;  
                            }
                        }
                    }
                } else {
                    resolve(null);
                    return;
                }
            } else if (dataTypeId == dataTypeEnums.EXPERIMENT) {
                keyToUse = "intValue";
                fieldVal = 0;

                if ($(editorField).attr('id') == "searchForExperement") {
                    var linkData = $(editorField).select2('data');
    
                    if (linkData != null) {
                        if (Object.keys(linkData).includes("id")) {
                            fieldValuePromiseList.push(new Promise(function(resolve, reject) {
                                var experimentId = linkData["id"];
                                var experimentTypeName = linkData["index"];
                                ajaxModule().getAllExperimentId(experimentId, experimentTypeName).then(function(linkTargetId) {
                                    var link = utilities().makeLinkInputModel(linkTargetId, dataTypeId);
                                    thisRequestFieldValue["link"] = link;
                                    resolve(thisRequestFieldValue);
                                });
                            }))
                        }
                    }
                } else {
                    resolve(null);
                    return;
                }
            } else {
                fieldVal = $(editorField).val();
            }

            Promise.all(fieldValuePromiseList).then(() => {
                thisRequestFieldValue[keyToUse] = fieldVal;
                resolve(thisRequestFieldValue)
            });
        })
    }

    /**
     * Helper function to check if all request item tables have enough rows.
     * @param {*} thisRequestType 
     * @param {*} editor 
     */
    var checkIfAllTablesMeetMinRowCount = function(thisRequestType, editor) {
        var returnBool = true;
        $.each(editor.find('.requestItemsEditor'), function (requestItemEditorIndex, requestItemEditor) {
            var tableMeetsReq = checkIfTableMeetsMinRowCount(requestItemEditor, thisRequestType);

            if (!tableMeetsReq) {
                returnBool = false;
                return false;
            }
        });

        return returnBool;
    }
      
    /**
     * Helper function for the helper function to check if this request item table has enough rows.
     * @param {*} requestItemEditor 
     * @param {*} thisRequestType 
     */
    var checkIfTableMeetsMinRowCount = function(requestItemEditor, thisRequestType) {
        var returnBool = true;
        var nameOfItemType = "";
        var minRowCount = 0;
        var sminRowCount = 0;

        var theTable = $(requestItemEditor).find('table.requestItemEditorTable:not(.DTFC_Cloned)');
        if (window.CurrentPageMode == 'makeNewRequest') {
            minRowCount = thisRequestType.requestItemTypes.find(x => x.requestItemTypeId == $(theTable[1]).attr('requestitemtypeid')).requestItemMinimumCount;
            var numOfRows = theTable.DataTable().rows().length;

            if (numOfRows == 1) {
                var emptyRow = $($($(theTable[1]).children())[1]).children().children().hasClass("dataTables_empty");
            }

            if ((minRowCount > numOfRows) || (minRowCount == 1 && numOfRows == 1 && emptyRow)) {
                //error not enough rows
                sminRowCount = minRowCount;
                nameOfItemType = thisRequestType.requestItemTypes.find(x => x.requestItemTypeId == $(theTable[1]).attr('requestitemtypeid')).requestItemName;
                if (typeof window.upsertRequestNotification !== "undefined") {
                    window.upsertRequestNotification.update({
                        'title': `At least ${sminRowCount} row(s) required in ${nameOfItemType} table.`,
                        'message': "",
                        'type': "danger"
                    });
                }
                else {
                    window.upsertRequestNotification = $.notify({
                        'title': `At least ${sminRowCount} row(s) required in ${nameOfItemType} table.`,
                        'message': "",
                    }, {
                        delay: 0,
                        type: "danger",
                        template: utilities().notifyJSTemplates.default,
                        onClose: function () {
                            window.upsertRequestNotification = undefined;
                        }
                    });
                }
               
                returnBool = false;
            }
        }

        return returnBool;
    }
    
    /**
     * Helper function that massages request item values if necessary.
     * @param {*} val The request item field's value.
     * @param {number} requestItemFieldDataTypeId The data type of the item field.
     */
    var requestItemFieldValMapper = function(val, requestItemFieldDataTypeId) {
        var fieldVal = {
            companyId: globalUserInfo.companyId,
        }
        var keyToUse = "textValue";
        
        if (dataTypeEnums.INTEGER == requestItemFieldDataTypeId) {
            keyToUse = "intValue";
        } else if (dataTypeEnums.REAL_NUMBER == requestItemFieldDataTypeId) {
            keyToUse = "realValue";
        } else if (dataTypeEnums.DROP_DOWN == requestItemFieldDataTypeId) {
            keyToUse = "dropDownValue";
        } else if (dataTypeEnums.DATE == requestItemFieldDataTypeId) {
            keyToUse = "dateValue";
            if (val != null && val != "") {
                if (typeof(val) == "string"){
                    var date = new Date(val);
                }
                else{
                    var date = new Date(val * 1000 + new Date().getTimezoneOffset() * 60 * 1000);
                }
                val = `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()}`;
            }
        } else if (dataTypeEnums.REQUEST == requestItemFieldDataTypeId) {
            val = JSON.stringify(val);
        }
        fieldVal[keyToUse] = val;
        return fieldVal;
    }

    /**
     * Packages request item field values for submission, as promises.
     * @param {JSON} requestTypeColumn The current request type column.
     * @param {JSON[]} thisRequestTypeColumns The list of columns this request item has.
     * @param {JSON} thisRequestItem The current request item's config.
     * @param {number} rowIndex The row number.
     * @param {JSON} rowData The data this row contains, obtained using dataTables.
     * @param {number} requestId The request's ID.
     * @param {JSON} thisRequestItemType This request item's config data.
     * @param {bool} submitAllFields Do we want to submit this request?
     */
    var requestItemRowMapper = function(requestTypeColumn, thisRequestTypeColumns, thisRequestItem, rowIndex, rowData, requestId, thisRequestItemType, submitAllFields) {
        return new Promise(function(resolve, reject) {
            var requestTypeColumnIndex = thisRequestTypeColumns.indexOf(requestTypeColumn);
            var requestItemTypeFieldId = requestTypeColumn['requestItemTypeFieldId'];
    
            if (!requestItemTypeFieldId) { 
                resolve(null);
                return;
            }
    
            var thisRequestItemField = {
                requestItemId: thisRequestItem["id"],
                requestItemTypeFieldId: requestItemTypeFieldId,
                companyId: globalUserInfo.companyId,
                sortOrder: requestTypeColumnIndex
            };
    
            var thisRequestItemFieldValues = [];
            var thisRequestItemTypeField = thisRequestItemType.fields.find(x => x.requestTypeFieldId == requestItemTypeFieldId);
    
            if (requestTypeColumn["savedField"] != null && thisRequestItemTypeField) {
                var requestItemFieldDataTypeId = requestTypeColumn['savedField']['dataTypeId'];
                var lowercaseFieldName = requestTypeColumn['data'];
                var fieldDisplayName = thisRequestItemTypeField.displayName;
    
                if (rowData[lowercaseFieldName] == undefined) {
                    if (Object.keys(rowData).includes(fieldDisplayName)) {
                        rowData[lowercaseFieldName] = rowData[fieldDisplayName];
                    } else {
                        rowData[lowercaseFieldName] = {
                            dirty: false,
                            data: []
                        };
                    }
                }
    
                var valuesArray = rowData[lowercaseFieldName]["data"];
                var isDirty = rowData[lowercaseFieldName]["dirty"];
                var fetchData = isDirty || submitAllFields || duplicatingRequest;
    
                // Don't update this cell if its not a structure and it hasn't been touched.
                if (requestId && !fetchData && requestItemFieldDataTypeId != dataTypeEnums.STRUCTURE) {
                    resolve(null);
                    return;
                }

                var requestItemFieldPromises = [];
    
                if (requestItemFieldDataTypeId == dataTypeEnums.STRUCTURE) {
                                    
                    // Since we set the dirty flag and update the DT data we do not need to pull the mol out of the dom.
                    // Instead we have it already.

                    // Check if we need to update this (updating and is dirty).
                    if (requestId && !fetchData) {
                        resolve(null);
                        return;
                    }
    
                    // Prep the data to return.
                    if (molHasData(valuesArray[0])){
                        thisRequestItemFieldValues.push({
                            companyId: globalUserInfo.companyId,
                            structureDiagram: valuesArray[0],
                        });
                    }
                } else if (requestItemFieldDataTypeId == dataTypeEnums.FILE_ATTACHMENT) {
    
                    thisRequestItemFieldValues = valuesArray.map(function(val) {
                        var fileId = -1;
                        if (val) {
                            fileId = val.id;
                        } 
                        var fieldVal = {
                            companyId: globalUserInfo.companyId,
                            fileId: fileId == -1 ? null : fileId,
                        };
                        return fieldVal;
                    })
    
                } else if ([dataTypeEnums.NOTEBOOK, dataTypeEnums.PROJECT].includes(requestItemFieldDataTypeId)){

                    if (valuesArray.length == 0) {
                        var fieldVal = {
                            companyId: globalUserInfo.companyId,
                            intValue: 0
                        };
                        thisRequestItemFieldValues.push(fieldVal);
                    }
    
                    $.each(valuesArray, function(itemFieldValueIndex, itemFieldValue) {
                        // Null check for links
                        if (itemFieldValue) {
                            var linkJson = JSON.parse(itemFieldValue);
                            var linkTargetId = linkJson["id"];
                            var link = utilities().makeLinkInputModel(linkTargetId, requestItemFieldDataTypeId);
                            
                            var fieldVal = {
                                companyId: globalUserInfo.companyId,
                                intValue: 0,
                                link: link
                            };
                            thisRequestItemFieldValues.push(fieldVal);
                        }
                        else {
                            // If we are here then we dont have a value for the link so we give it this object instead.
                            thisRequestItemFieldValues.push({companyId: globalUserInfo.companyId, intValue: 0});
                        }
                    });
    
                } else if (requestItemFieldDataTypeId == dataTypeEnums.EXPERIMENT) {
                    requestItemFieldPromises.push(new Promise(function(resolve, reject) {
                        var allExpPromises = [];
                        $.each(valuesArray, function(itemFieldValueIndex, itemFieldValue) {
        
                            var linkJson = JSON.parse(itemFieldValue);
                            var experimentId = linkJson["id"];
                            var experimentTypeName = linkJson["index"];
                            allExpPromises.push(ajaxModule().getAllExperimentId(experimentId, experimentTypeName));
                        });
        
                        Promise.all(allExpPromises).then(function(allExpIds) {
                            $.each(allExpIds, function(expIdIndex, linkTargetId) {
                                var link = utilities().makeLinkInputModel(linkTargetId, requestItemFieldDataTypeId);
            
                                var fieldVal = {
                                    companyId: globalUserInfo.companyId,
                                    intValue: 0,
                                    link: link
                                };
                                thisRequestItemFieldValues.push(fieldVal);
                            });
                            resolve();
                        });
                    }));
                } else {
                    var thisRequestItemFieldValues = valuesArray.map(val => requestItemFieldValMapper(val, requestItemFieldDataTypeId));
                }
                
                Promise.all(requestItemFieldPromises).then(function() {
                    thisRequestItemField["requestItemFieldValues"] = thisRequestItemFieldValues;
                    resolve(thisRequestItemField);
                });
            } else {
                resolve(null);
            }
        })
    }

    /**
     * Packages the contents of the current request editor for submitting to the appService.
     * @param {number} requestId The request's ID.
     * @param {JSON} thisRequestType The request type.
     * @param {*} editor The HTML editor, selected with JQuery.
     * @param {bool} submitAllFields Do we want to submit all fields?
     * @param {JSON[]} versionedRequestItems The request items list.
     */
    var packageRequest = function(requestId, thisRequestType, editor, submitAllFields, versionedRequestItems) {
        return new Promise(function(resolve, reject) {

            var requestJson = {};
            requestJson["companyId"] = globalUserInfo.companyId;
            requestJson["requestorId"] = globalUserInfo.userId;
            requestJson["requestTypeId"] = thisRequestType.id;
    
            // Restrict the fields we send down to just the dirty ones IF we're editing a request.
            var dirtyDataSelector = ``;
    
            if (requestId) {
                if (typeof duplicatingRequest == "undefined" || !duplicatingRequest) {
                    requestJson["id"] = requestId;
    
                    if (!submitAllFields) {
                        dirtyDataSelector = `[dirty="true"]`;
                    }
                }
    
            }
            else {
                if (window.self != window.top) {
                    if (window.parent.$("#requestId").val() != "") {
                        requestJson["id"] = window.parent.$("#requestId").val();
    
                        if (!submitAllFields) {
                            dirtyDataSelector = `[dirty="true"]`;
                        }
                    }
                }
            }
    
            var hasGroupSelector = editor.find('[fieldid="assignedUserGroup"] select#assignedUserGroupDropdown').length > 0;
            var groupSelectDropdownStr = hasGroupSelector ? " select#assignedUserGroupDropdown option:selected" : "";
            var groupSelector = `[fieldid="assignedUserGroup"]${groupSelectDropdownStr}`;
            var assignedGroupId = parseInt(editor.find(groupSelector).attr("groupId"));
            requestJson["assignedGroupId"] = parseInt(assignedGroupId);
    
            var requestFieldPromises = [];
            requestFields = [];
            $.each(editor.find(`.editorSection[sectionid="requestFields"] > .editorField${dirtyDataSelector}`), function (requestTypeFieldIndex, editorField) {
                requestFieldPromises.push(getRequestField(editorField, requestJson["id"]));
            });
    
            Promise.all(requestFieldPromises).then(function(requestFieldsArr) {
                requestJson["requestFields"] = requestFieldsArr;
                requestJson['requestItems'] = [];

                var requestItemPromises = [];
                $.each(editor.find('.requestItemsEditor'), function (requestItemEditorIndex, requestItemEditor) {
                    requestItemPromises.push(requestItemPromiseHelper(requestItemEditor, requestJson, requestId, submitAllFields, versionedRequestItems));
                });
                
                Promise.all(requestItemPromises).then(items => resolve(requestJson))
            });
        });
    }

    /**
     * Packages request items for submission as a promise, for the field
     * @param {*} requestItemEditor The editor for the request item, fetched with JQuery.
     * @param {JSON} requestJson The in-progress request being submitted.
     * @param {number} requestId The request's ID.
     * @param {bool} submitAllFields Do we want to submit this request?
     * @param {JSON[]} versionedRequestItems The versioned config data.
     */
    var requestItemPromiseHelper = function(requestItemEditor, requestJson, requestId, submitAllFields, versionedRequestItems) {
        return new Promise(function(resolve, reject) {
            if ($(requestItemEditor).find('table.requestItemEditorTable:not(.DTFC_Cloned) > tbody > tr').length > 0) {
                var requestItemId = $(requestItemEditor).attr('requestitemid'); // Not an int... This is specific to the request type, allowing you to use this request item type more than once in a single request
                var requestItemTypeId = $(requestItemEditor).attr('requestitemtypeid'); // Not an int...
                var theTable = $(requestItemEditor).find('table.requestItemEditorTable:not(.DTFC_Cloned)');

                // Clone this array so we can do a map later.
                var thisRequestTypeColumns = [...window.requestItemTypesColumns[requestItemTypeId]];
                var thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);

                theTable.DataTable().draw(false);

                var requestItemRowPromises = [];
                $.each(theTable.DataTable().rows().data(), function(rowIndex, rowData) {
                    requestItemRowPromises.push(requestItemRowPromiseHelper(requestItemId, rowData, requestJson, thisRequestItemType, thisRequestTypeColumns, rowIndex, requestId, submitAllFields));
                });

                Promise.all(requestItemRowPromises).then(function(itemRows) {
                    if (itemRows) {
                        requestJson["requestItems"] = requestJson["requestItems"].concat(itemRows);
                    }

                    // Grab all of the row IDs flagged as deleted from this table and construct
                    // a requestItemBo to flag it as such.
                    var deletedRows = $(theTable[1]).attr("deletedrows");
                    if (deletedRows) {
                        var deletedIds = deletedRows.split(",");

                        $.each(deletedIds, function(idIndex, id) {
                            var deletedRequestItem = {
                                requestTypeRequestItemTypeId: requestItemId,
                                companyId: globalUserInfo.companyId,
                                id: id,
                                isDeleted: 1
                            };
                            requestJson["requestItems"].push(deletedRequestItem);
                        })
                    }
                    
                    resolve();
                });
            } else {
                resolve();
            }
        })
    }

    /**
     * Packages request item rows for submission, as a promise.
     * @param {number} requestItemId the Request Item's ID.
     * @param {JSON} rowData The data this row contains, obtained using dataTables.
     * @param {JSON} requestJson The in-progress request being submitted.
     * @param {JSON} thisRequestItemType This request item's config data.
     * @param {JSON[]} thisRequestTypeColumns The list of columns this request item has.
     * @param {number} rowIndex The row number.
     * @param {number} requestId The request's ID.
     * @param {bool} submitAllFields Do we want to submit this request?
     */
    var requestItemRowPromiseHelper = function(requestItemId, rowData, requestJson, thisRequestItemType, thisRequestTypeColumns, rowIndex, requestId, submitAllFields) {
        return new Promise(function(resolve, reject) {
            var thisRequestItem = {
                requestTypeRequestItemTypeId: requestItemId,
                companyId: globalUserInfo.companyId,
                sortOrder: rowData["sortOrder"]
            };

            if (requestJson["id"]) {
                thisRequestItem["requestId"] = requestJson["id"];
            }

            // If not duplicating a request, set the requestItemId
            if (typeof duplicatingRequest == "undefined" || !duplicatingRequest) {
                if (typeof rowData['requestItemId'] !== "undefined") {
                    thisRequestItem['id'] = rowData['requestItemId'];
                }
            }

            requestItemDataPromises = thisRequestTypeColumns.map(requestTypeColumn => requestItemRowMapper(requestTypeColumn, thisRequestTypeColumns, thisRequestItem, rowIndex, rowData, requestId, thisRequestItemType, submitAllFields));
            
            Promise.all(requestItemDataPromises).then(function(requestItemDataRows) {
                requestItemDataRows = requestItemDataRows.filter(x => x);
                thisRequestItem["requestItemFields"] = requestItemDataRows;
                var itemsWithData = requestItemDataRows.filter(x => x.requestItemFieldValues.length > 0);
                if (itemsWithData.length > 0){
                    resolve(thisRequestItem);
                } else {
                    resolve(null);
                }
            });
        })
    }

    /**
     * Click handler for the request submit buttons.
     * @param {number} requestId The ID of the request we're submitting. Can be null.
     * @param {JSON} thisRequestType The request type config data.
     * @param {Array} versionedRequestItems The request item config data.
     * @param {Array} versionedFields The field config data.
     */
    var clickRequestSubmitButton = async function(requestId, thisRequestType, versionedRequestItems, versionedFields) {

        var prioritizeRequest = utilities().canPrioritizeRequest(thisRequestType);
        var submitMessage = prioritizeRequest ? "Gathering prioritized request list..." : "Adding your request, please wait...";

        if (typeof window.upsertRequestNotification !== "undefined") {
            window.upsertRequestNotification.update({ 'title': submitMessage, 'message': "" });
        }
        else {
            window.upsertRequestNotification = $.notify({
                title: submitMessage,
                message: ""
            }, {
                    delay: 0,
                    type: "success",
                    template: utilities().notifyJSTemplates.default,
                    onClose: function () {
                        window.upsertRequestNotification = undefined;
                    }
                });
        }

        if (prioritizeRequest && $("[reprioritizingRequest=true]").length > 0) {
            var requestsArray = [];
            var orderType = "requestedOrder";

            if (requestId) {
                // having a requestId means PATCH.
                if (isWorkflowManager) {
                    requestsArray = await ajaxModule().getQueueableRequests(thisRequestType["id"], window.top.currApp);
                    orderType = "assignedOrder";
                } else {
                    requestsArray = await ajaxModule().getQueueableRequests(thisRequestType["id"], window.top.currApp, globalUserInfo.userId);
                }
            } else {
                // otherwise, we're only prioritizing against requestedOrder.
                requestsArray = await ajaxModule().getQueueableRequests(thisRequestType["id"], window.top.currApp, globalUserInfo.userId);
            }

            changeRowsInMyRequestsTable(requestsArray, orderType);

            if (window.upsertRequestNotification) {
                window.upsertRequestNotification.close();
            }

            $('#prioritizeThisRequestTableModal').modal('show');
            setTimeout(function () {
                $(".prioritizeThisRequestContainer").animate({ scrollTop: $('.prioritizeThisRequestContainer').prop("scrollHeight") }, 400);
            }, 500);

            $("body").off("click", 'button.requestEditorSubmitNewRequest');
            $("body").on("click", 'button.requestEditorSubmitNewRequest', function() {
                getStructuresAndSubmit(requestId, true, false, () => {}, thisRequestType=thisRequestType, versionedRequestItems=versionedRequestItems, versionedFields=versionedFields);
            });

        } else {
            getStructuresAndSubmit(requestId, true, false, function() {}, thisRequestType=thisRequestType, versionedRequestItems=versionedRequestItems, versionedFields=versionedFields);
        }
    }

    /**
     * Submits the request editor to the service to be saved.
     * @param {number} requestId The request's ID, if we have one. Null if we don't.
     * @param {boolean} checkRequiredFields Check that all required fields are being submitted.
     * @param {boolean} submitAllFields Do we want to submit every field?
     * @param {number[]} unnamedProjectList A list of projects that do not have names.
     * @param {function} saveCallbackFn The save callback for the ELN.
     * @param {JSON} thisRequestType The request type config info.
     * @param {JSON} versionedRequestItems The request item config info.
     */
    var submitRequestEditor = async function(requestId, checkRequiredFields = true, submitAllFields=false, unnamedProjectList=[], saveCallbackFn = function (saveRequestId, saveRevisionId) { }, thisRequestType, versionedRequestItems) {

        // Check if there are any maximized ckeditors on the page. If there is one, then minimize it and keep track of its ID for later.
        var maximized_id;
        if ($(".cke_maximized").length > 0) {
            $.each($(".cke_maximized"), function (i, editor) {
                maximized_id = $(editor).parent().attr("id").substring(4);
                CKEDITOR.instances[maximized_id].execCommand("maximize");
            });
        }

        var inputData = {
            checkRequiredFields: checkRequiredFields,
            recreateRequestName: false,
            appName: window.top.currApp
        };

        if (window.parent != window.self) {
            if (requestId === null && window.parent.latestStatus != "1") {
                window.parent.swal("There was an error trying to save this experiment. Please contact support.");
                return false;
            }
        }

        if (window.top != window.self) {
            window.parent.showPopup('savingDiv');
        }

        var requestIdSelectorString = "";
        if (requestId) {
            requestIdSelectorString = `[requestid=${requestId}]`;
        }
        else {
            
            if ($('[fieldid="requestType"] select#requestTypeDropdown').val() == "") {
                // User trying to submit the request without a request type
                $.notify({
                    title: "You must choose a request type.",
                    message: ""
                }, {
                        delay: 5000,
                        type: "danger"
                    });
                return false;
            }
        }

        var editor = $(`.dropdownEditorContainer${requestIdSelectorString}`);

        if (!checkIfAllTablesMeetMinRowCount(thisRequestType, editor)) {
            $('.prioritizeNewRequestButton').attr('disabled', false);
            return false;
        }

        var requestJson = await packageRequest(requestId, thisRequestType, editor, submitAllFields, versionedRequestItems);

        // Every time you submit a request, all of the user's requests need a new order...
        var orderType = $("#prioritizeThisRequestTable").attr("orderType");

        // Set the orderType to requested order by default if we didn't pull one out of the page.
        if (!orderType) { orderType = "requestedOrder" }

        var otherRequestedOrders = {};
        requestJson[orderType] = null;
        
        if (utilities().canPrioritizeRequest(thisRequestType) && $("[reprioritizingRequest=true]").length > 0) {
            $.each($('#prioritizeThisRequestTable tr'), function (requestIndex, request) {
    
                var requestId = $(request).attr('requestid');
                var requestedOrderVal = requestIndex + 1;
                
                if (requestId) {
                    otherRequestedOrders[requestId] = requestedOrderVal;
                } else {
                    requestJson[orderType] = requestedOrderVal;
                }
    
            });
        }
        inputData["request"] = requestJson;
        inputData['otherOrders'] = otherRequestedOrders;
        inputData["orderType"] = orderType;

        // 4348: For new request, there is no preSave action.
        if (requestId) {
            inputData["preSaveEndpointUrl"] = workflowServiceEndpointUrl + workflowServiceEndpoints.PRESAVE;
        }
        inputData["postSaveEndpointUrl"] = workflowServiceEndpointUrl + workflowServiceEndpoints.POSTSAVE;

        if (self == top) {
            if (requestId) {
                upsertRequestNotificationTitle = "Updating request, please wait...";
            } else {
                upsertRequestNotificationTitle = "Adding your request, please wait..."
            }

            if (typeof window.upsertRequestNotification !== "undefined") {
                window.upsertRequestNotification.update({ 'title': upsertRequestNotificationTitle, 'message': "", 'type': "yellowNotification" });
            }
            else {
                window.upsertRequestNotification = $.notify({
                    title: upsertRequestNotificationTitle,
                    message: ""
                }, {
                    delay: 0,
                    type: "yellowNotification",
                    template: utilities().notifyJSTemplates.default,
                    onClose: function () {
                        window.upsertRequestNotification = undefined;
                    }
                });
            }
        }

        //input data is the JSON object that holds the data to be saved 
        console.log(JSON.stringify(inputData))
        $('#prioritizeThisRequestTableModal').modal('hide');

        utilities().submitRequest(inputData).then(function(response) {
            requestResponseHandler(response, requestId, unnamedProjectList, saveCallbackFn);
        }).catch(function(error) {

            // If the error is too long, then the notification popup cannot be dismissed, so we'll cap its maximum length.
            if (error.length > 255) {
                error = `${error.slice(0, 255)}...`;
            }
            
            if (window.top.currApp != "ELN") {
                window.upsertRequestNotification.update({"title": "Error submitting request! Please contact support.", "message": error, "type": "danger"});
            } else {
                window.parent.swal("Error submitting request! Please contact support.", error, "error");
            }

            $(".submitButton").attr("disabled", false);
        });

        // end ajax
    }

    /**
     * Handles the request submission response.
     * @param {object} response The response from the service.
     * @param {number} requestId The request's ID, if it has one.
     * @param {number[]} unnamedProjectList A list of projects that do not have names.
     * @param {function} saveCallbackFn The save callback function for custom experiment saving.
     */
    var requestResponseHandler = async function(response, requestId, unnamedProjectList, saveCallbackFn) {
        
        console.log("upsertRequest response: ", response)
        var requestEditor = $(".requestEditorContainer");
        requestEditor.find('.editorFieldValidationErrorLabel, .editorItemFieldValidationErrorLabel').empty();

        if (window.top != window.self && (response['error'] || response['result'] == 'failed')) {
            window.parent.hidePopup('savingDiv');
        }

        if (response['error']) {
            var notificationTitle = response['error']
            if (window.top == window.self) {
                window.upsertRequestNotification.update({ 'title': notificationTitle, 'type': "danger" })
            } else {
                window.parent.swal("", notificationTitle, "error");
            }
            $('.prioritizeNewRequestButton').attr('disabled', false);
            return false;
        }

        if (response['result'] != "success") {
            $('.prioritizeNewRequestButton').attr('disabled', false);
            errorResponseHandler(requestEditor, response);

            saveCallbackFn(false, false);
            return false;
        }
        else {
            var submittedLinks = null;
            //submit queued links
            if (typeof(InterCom) != 'undefined' && response.requestId) {
                submittedLinks = window.InterCom.props.submitLinks(response.requestId);
            }

            if (unnamedProjectList.length > 0) {
                const requestNameResp = await ajaxModule().getRequestName(response.requestId);
                const requestNameJson = utilities().decodeServiceResponce(requestNameResp);
                const requestName = requestNameJson["requestName"];

                await ajaxModule().updateProjectsWithName(unnamedProjectList, requestName);
            }
            
            // if we are a cust experiement and have all required info... add the bio editor to the pdfProcQueue.
            if (window.top != window.self && window.top.experimentJSON) {
                if ("experimentId" in window.top.experimentJSON && "thisRevisionNumber" in window.top.experimentJSON && "bioEditorIds" in window.top.experimentJSON) {
                    $.each(window.top.experimentJSON.bioEditorIds, function(index,id){
                        ajaxModule().addEditorToProcQueue(window.top.experimentJSON.experimentId, window.top.experimentJSON.thisRevisionNumber, id);
                    });
                    window.top.experimentJSON.bioEditorIds = [];
                }
            }

            // It didn't fail
            $('.prioritizeNewRequestButton').attr('disabled', false);
            // Let the page know we're no longer duplicating a request.
            if (window.duplicatingRequest !== undefined && window.duplicatingRequest) {
                window.duplicatingRequest = false;

                // For some reason updating the requestId doesn't work in the next block, so set it up here too just in case.
                if (window.top != window.self) {
                    window.requestId = response.requestId;
                    window.parent.$("#requestId").val(response["requestId"]);
                    $(".dropdownEditorContainer").attr("requestid", response.requestId);

                    if (window.location.href.includes("repeatRequest.asp")) {
                        var indivReqSrc = "/arxlab/workflow/viewIndividualRequest.asp?base=false&inFrame=true&requestid=" + response["requestId"] + "&currentPageMode=custExp";
                        var iframe = window.parent.$("#tocIframe").attr("src", indivReqSrc);
                    }

                }
            }
            if (!requestId) {
                console.log("Successfully added request.")

                // If we're in an iFrame and making a new request inside an experiment page, then
                // trigger the experiment submit function from the parent.
                if (window.self != window.top) {

                    window.parent.$("#requestId").val(response["requestId"]);
                    window.parent.$("#requestRevisionId").val(response["revisionId"])
                    saveCallbackFn(response["requestId"], response["revisionId"]);

                    var indivReqSrc = "/arxlab/workflow/viewIndividualRequest.asp?base=false&inFrame=true&requestid=" + response["requestId"] + "&currentPageMode=custExp";
                    var iframe = window.parent.$("#tocIframe").attr("src", indivReqSrc);
                }
                else {
                    window.upsertRequestNotification.update({ 'title': "Successfully Submitted your Request.", 'message': "", 'type': "success" })
                    setTimeout(function () {
                        window.upsertRequestNotification.close();
                    }, 5000);
                }


                if (window.self == window.top && (window.CurrentPageMode == "makeNewRequest" || window.CurrentPageMode == "repeatRequest")) {
                    
                    // Build url for page redirect!
                    let url = `${window.location.origin}/arxlab/workflow/viewIndividualRequest.asp?requestid=${response["requestId"]}`;
                    // and then go!
                    window.location.href = url;

                } else {
                    $("#requestEditorModal").modal("hide");
                }

            }
            else {
                console.log("Successfully updated request.")
                if (window.self != window.top) {
                    try {
                        viewIndividualRequest(response["requestId"], response["revisionId"]);
                    } catch {
                        window.parent.$("#tocIframe").attr("src", window.parent.$("#tocIframe").attr("src"));
                    }

                    saveCallbackFn(response["requestId"], response["revisionId"]);
                }
                else {

                    window.upsertRequestNotification.update({ 'title': "Successfully updated your request.", 'message': "", 'type': "success" })
                    setTimeout(function () {
                        window.upsertRequestNotification.close();
                    }, 5000);

                    // look to see if we are individual request page
                    if (window.location.pathname == "/arxlab/workflow/viewIndividualRequest.asp") {
                        try {
                            // try to use this fnc to reload the section
                            viewIndividualRequest(response["requestId"], response["revisionId"]);
                        } catch {
                            // but always have a backup and just reload the page
                            window.location.href = window.location.href;
                        }
                    }
                    else {
                        requestEditor.find('.bottomButtons .requestEditorCancel').click();
                    }
                }

                // make sure we have a table to redraw 
                if ($("#manageRequestsTable").length > 0 ) {
                    $("#manageRequestsTable").DataTable().draw();
                }

                // Refresh the notifications on completed request submission.
                fetchUnreadNotifications();
            }

            // Now that we're done, fetch the count of notifications.
            // I cannot guarantee that new notifications from this request will even
            // be ready, however.
            utilities().fetchNotificationCount();

            // Would normally call utilities().closeUnsavedChangesNotification() but the editor never gets closed so it won't do anything
            if (typeof window.unsavedChangesNotification !== "undefined") {
                window.unsavedChangesNotification.close();
            }
            window.unsavedChangesNotificationOpen = false;
        }
    }

    /**
     * Injects error messages to the fields that did not pass validation and displays the appropriate error message to the user.
     * @param {object} requestEditor The JQuery selected request editor ($(".requestEditorContainer"))
     * @param {*} response The response from a request.
     */
    var errorResponseHandler = function(requestEditor, response) {
        
        var notificationTitle = "Unable to submit your request.";
        var notificationMessage = "Please correct any errors and try again."

        // Parse out the validation errors from the response.
        var validationErrors = JSON.parse(response["validationErrors"]);
        var requestValidationError = validationErrors.requestValidationError;

        // If we have an overall error (like the user doesn't have permission to touch this request type), then
        // make the top level error be the notification message and don't even bother injecting the field errors.
        if (requestValidationError) {
            notificationMessage = requestValidationError;
        } else {

            // Go through each request field error and inject the error message where it needs to go.
            $.each(validationErrors.requestFieldValidationList, function(requestFieldIndex, requestFieldError) {

                // Grab the request type field ID for each error and find the input container.
                var errorRequestTypeFieldId = requestFieldError.requestTypeFieldId;
                var editorFieldInputContainers = requestEditor.find(`.editorField[requesttypefieldid=${errorRequestTypeFieldId}] .editorFieldInputContainer`);
                
                // Add the error to each field.
                editorFieldInputContainers.each(function (inputContainerIndex, inputContainer) {
                    if (requestFieldError["errorList"][inputContainerIndex]) { // If this value has a real error...
                        $(inputContainer).find('.editorFieldValidationErrorLabel').text(requestFieldError["errorList"][inputContainerIndex]);
                    }
                });
            });

            var requestItemFieldValidationList = validationErrors.requestItemFieldValidationList;
            $.each(requestEditor.find(".requestItemsEditor"), function() {
                var requestItemId = $(this).attr("requestitemid");
                var table = $(`#requestItemTable${requestItemId}`);
                var requestItemTypeId = table.attr("requestitemtypeid");
                
                $.each(table.DataTable().rows().nodes().to$(), function(rowIndex, rowNode) {
                    var dirtyRow = false;
                    // Check for any dirty cells 
                    // Use the table data for this to account for frozen columns.
                    var rowData = table.DataTable().row(rowNode).data();
                    $.each(rowData, function(key, value) {
                        if (typeof value == "object") {
                            if ("dirty" in value && value.dirty) {
                                dirtyRow = true;
                                return false;
                            }
                        }
                    });
                    
                    // If we have a dirty cell then we have a dirty row so use use the next row validation. 
                    if (!dirtyRow && table.DataTable().rows().length > 1) {
                        return true;
                    }
                    var rowErrors = requestItemFieldValidationList.shift();
                    if (rowErrors == undefined) {
                        console.log("trying to make sure this doesn't execute I guess??");
                        return false;
                    }
                    $.each(rowErrors.requestFieldValidationList, function (requestItemFieldIndex, requestItemField) {
                        var requestItemTypeFieldId = requestItemField.requestTypeFieldId;
                        relevantCellDiv = $(rowNode).find('div[requestitemtypefieldid="' + requestItemTypeFieldId + '"]');
                        console.log(relevantCellDiv)
                        console.log(relevantCellDiv.attr('datatypeid'))
                        if (relevantCellDiv.length > 0) {
                            thisDataTypeId = parseInt(relevantCellDiv.attr('datatypeid'))

                            if (isNaN(thisDataTypeId) && $(relevantCellDiv).hasClass("structureDisplay")) {
                                thisDataTypeId = 8;
                            }

                            console.log(thisDataTypeId)
                            if (thisDataTypeId == dataTypeEnums.TEXT) {
                                var inputElement = relevantCellDiv.find('input[type="text"]');
                            }
                            else if (thisDataTypeId == dataTypeEnums.LONG_TEXT) {
                                var inputElement = relevantCellDiv.find('textarea');
                            }
                            else if (thisDataTypeId == dataTypeEnums.INTEGER || thisDataTypeId == dataTypeEnums.REAL_NUMBER) {
                                var inputElement = relevantCellDiv.find('input[type="number"]');
                            }
                            else if (thisDataTypeId == dataTypeEnums.DROP_DOWN) {
                                var inputElement = relevantCellDiv.find('select');
                            }
                            else if (thisDataTypeId == dataTypeEnums.FILE_ATTACHMENT) {
                                var inputElement = relevantCellDiv.find('form');
                            }
                            else if (thisDataTypeId == dataTypeEnums.DATE) {
                                var inputElement = relevantCellDiv.find('input[type="text"]');
                            }
                            else if (thisDataTypeId == dataTypeEnums.STRUCTURE) {
                                var inputElement = relevantCellDiv.find(".structureDisplay");
                            }

                            console.log(inputElement)
                            if (inputElement != undefined)
                            {
                                $.each(inputElement, function (inputElementIndex, thisInputElement) {
                                    var error = requestItemField["errorList"][inputElementIndex];
                                    if (error) {
                                        $(thisInputElement).next('.editorItemFieldValidationErrorLabel').text(error)
                                    }
                                })
                            }
                        }
                        else {
                            // Couldn't find a cell in the table that matches this... if it's required, this is a problem and there's no cell to tell the user nicely...
                            $.each(versionedRequestItems, function (index, requestItemType) {
                                if (requestItemType['id'] == parseInt(requestItemTypeId)) {
                                    $.each(requestItemType['fields'], function (fieldIndex, field) {
                                        if (field['requestTypeFieldId'] == requestItemTypeFieldId) {
                                            if (field['required']) {
                                                alert("Update/Submission Failed: There is a required Item Field which you don't have access to.")
                                            }
                                        }
                                    });
                                }
                            });
                        }
                    });
                });
                $(table).DataTable().draw();
            });
        }

        if (window.self == window.top) {
            window.upsertRequestNotification.update({ 'title': notificationTitle, 'message': notificationMessage, 'type': "danger" })
        }
        else {
            window.parent.swal("", notificationMessage, "warning");
            window.top.hidePopup("savingDiv");
        }

    }
    
    var findStatusFieldAndQueuedOptionId = function(thisRequestType) {
        return new Promise(function (resolve, reject) {
            // Find the Status field of the request type & its "Queued" option's ID
            var statusFieldSavedFieldId = false;
            var queuedOptionId = false;

            var foundStatusField = thisRequestType["fields"].find(x => x["filterField"] == "1");

            if (foundStatusField) {
                statusFieldSavedFieldId = foundStatusField['savedFieldId'];
                var filterVal = foundStatusField['filterValue'];

                if (foundStatusField["dataTypeId"] == dataTypeEnums.DROP_DOWN)
                {
                    var statusFieldEditorField = $(`.editorField[savedfieldid=${statusFieldSavedFieldId}]`);

                    if (statusFieldEditorField.length > 0) {
                        var requestFieldRef = $($(statusFieldEditorField).children()[1]).children()[0];
                        if (filterVal != "DYNAMIC") {
                            $.each($(requestFieldRef).children(), function () {
                                if (this.text == filterVal) {
                                    queuedOptionId = $(this).val();
                                }
                            })
                        }
                        else {
                            queuedOptionId = $(requestFieldRef).val();
                        }
                    }
                }
                else if (foundStatusField["dataTypeId"] == dataTypeEnums.TEXT) //check if datatype = 1
                {
                    //since it is 1 leave it alone unless dynamic is chosen
                    if (filterVal != "DYNAMIC") {
                        queuedOptionId = filterVal;
                    }
                    else {
                        var statusFieldEditorField = $(`.editorField[savedfieldid=${statusFieldSavedFieldId}]`);
                        if (statusFieldEditorField.length > 0) {
                            var requestFieldRef = $($(statusFieldEditorField).children()[1]).children()[0];
                            queuedOptionId = $(requestFieldRef).val();
                        }
                    }
                }
            }

            resolve({ "statusFieldSavedFieldId": statusFieldSavedFieldId, "queuedOptionId": queuedOptionId });
        });
    }

    var filterRequestsToOnlyMine = function(requestsArray) {
        myRequests = requestsArray.filter(x => x.requestorId == globalUserInfo["userId"]);
        return myRequests;
    }
    
    var orderRequestsByRequestedOrderWithNullsLast = function(requestsArray) {
        requestsArray.sort(function (a, b) {
            return (a.requestedOrder === null) - (b.requestedOrder === null) || +(a.requestedOrder > b.requestedOrder) || -(a.requestedOrder < b.requestedOrder);
        });
        return requestsArray;
    }

    /**
     * This used to populate the prioritize requests table. That functionality has been moved and all that's left here
     * is applying click handlers and hiding the loading modal.
     */
    var finalizeRequestEditorInitialization = function() {
    
        return new Promise(function (resolve, reject) {
            console.log("complete");

            $('#basicLoadingModal').modal('hide');

            // Allow datatables to be hidden when the headers are clicked.
            $(".card-header").on("click", function () {
                var reqItemDivs = $(this).parent().children();
                $.each(reqItemDivs, function (index, div) {
                    if (!$(div).hasClass("card-header")) {
                        toggleObj(div);
                    } else {
                        $.each($(div).children(), function (divIndex, child) {
                            if ($(child).hasClass("hideFields")) {
                                swapTriangles($(child).children()[0]);
                            }
                        });
                    }
                });
            });

            if ($('#basicLoadingModal').length){
                $('#basicLoadingModal').modal('hide');
            }
            
            resolve();
        });
    }
    
    var genRichText;
    window.ckEditorInstances = {};
    /**
     * Initalise a CKE 5 field.
     * @param {$object} obj Jquery object that needs to get intialised 
     */
    var initCKEFields = function (obj, index) {
        ClassicEditor.create(obj,
            {
            toolbar: {
                items: [
                    'heading',
                    '|',
                    'fontColor',
                    'fontSize',
                    'fontFamily',
                    'highlight',
                    '|',
                    'bold',
                    'italic',
                    'underline',
                    'strikethrough',
                    'link',
                    '|',
                    'bulletedList',
                    'numberedList',
                    'todoList',
                    '|',
                    'indent',
                    'alignment',
                    'outdent',
                    '|',
                    'blockQuote',
                    'insertTable',
                    '|',
                    'code',
                    'codeBlock',
                    '|',
                    'imageInsert',
                    '|',
                    'MathType',
                    'ChemType',
                    'specialCharacters',
                    'subscript',
                    'superscript',
                    '|',
                    'TimeStamp'
                   
                ]
            },
            language: 'en',
            image: {
                toolbar: [
                    'imageTextAlternative',
                    'imageStyle:full',
                    'imageStyle:side'
                ]
            },
            table: {
                contentToolbar: [
                    'tableColumn',
                    'tableRow',
                    'mergeTableCells',
                    'tableCellProperties',
                    'tableProperties'
                ]
            },
            mention: {
                feeds: [
                    {
                        marker: '#',
                        feed: getFeedItems,
                        minimumCharacters: 0
                    }
                ]
            }
        }).then(function(editor){
            var objVal = $(obj).val();
            editor.setData(objVal);
            var objId = $(obj).attr('id');

            // If we're in a custom experiment, then we're going to set draft data here because doing it with the
            // rest of the draft data gets weird.
            if (window.parent != window.self && window.top.experimentJSON) {
                var requestTypeFieldId = $("#" + objId).parent().parent().attr("requesttypefieldid");
                var draftVal = window.top.experimentJSON[requestTypeFieldId];
                if (typeof (draftVal) != "undefined") {
                    editor.setData(draftVal);
                }
            }

            editor.model.document.on( 'change:data', () => {
                // We need to do this so the time stamp finishes before getting data for draft
                window.setTimeout(function(editor){

                    // Make sure the editorField has the appropriate class.
                    // This is necessary because the maximize plugin strips the classes for some reason.
                    $(`#${objId}`).parent().parent().addClass("editorField");
                    utilities().showUnsavedChangesNotification($(`#${objId}`).parent().parent())

                    if (window.self != window.top) {
                        var requestTypeFieldId = $("#" + objId).parent().parent().attr("requesttypefieldid");
                        var ckData = editor.getData();
                        window.parent.sendAutoSave(requestTypeFieldId, ckData);
                    }

                },0,editor);

            } );

            ckEditorInstances[$(obj).attr("id")] = editor;

            if (window.top != window.self && !window.top.canWrite) {
                editor.isReadOnly = true;
            }

            $(".ck-button").on("click", function(e){
                let topVal = $(e.currentTarget).offset().top;
                document.getElementById(`wrs_modal_dialogContainer[${index}]`).style.top = `${topVal}px`;
            });
        });
        
    }

    /**
     * Returns a promise to be used by the CKE5 Mentions that gives a list of attachments matching the queryText
     * @param {String} queryText - Query to filter attachments on
     * @returns promise of array of maching attachment names
     */
    function getFeedItems(queryText) {
        //Get the list of attachments
        return new Promise((resolve) => {
            var attachmentNames = window.top.$(".fileName").toArray().map(x => {
                return {id: `#${x.innerHTML}`};
            });
            //resolve the top 10 of any matching items
            resolve(attachmentNames.filter(isItemMatching).slice(0,10));
        });

        function isItemMatching( item ) {
            // Make the search case-insensitive.
            const searchString = queryText.toLowerCase();
            return (item.id.toLowerCase().includes(searchString));
        }
    }

    var bindRichTextFields = function(versionedRequestItems, versionedFields) {
        return new Promise(function (resolve, reject) {
            clearTimeout(genRichText);
            window.preventNotification = 0;

            genRichText = setTimeout(function () {
                var ckPromises = []

                requestFieldHelper().initAllSealectFields(versionedRequestItems, versionedFields);

                $.each($(".ckEditorField"), function (i, obj) {
                    ckPromises.push(initCKEFields(obj, i));
                    // ckPromises.push(instantiateRichTextField(i, obj));
                });
                Promise.all(ckPromises).then(function (editors) {
                    //call this here because it should be the end of the loading process for a request.
                    resolve(true);
                });
            }, 1000);

        });
    }

    var populateDraft = function(versionedRequestItems, versionedFields) {

        // Populate request draft for cust experiments.
        //if (window.self != window.top) {
        return new Promise(function (resolve, reject) {
            // The requestFieldIds that have draft data are all stored in a hidden input in the parent experiment.
            var requestFieldIds = [];
            var requestFieldVal = window.parent.$("#requestFieldIds").val();
    
            var dropdownPromises = [];
    
            if (requestFieldVal && typeof requestFieldVal != "undefined")
                requestFieldIds = requestFieldVal.split(",")
    
            // Figure out what dropdowns are depended on and do those first.
            var requestTypeId = window.parent.$("#requestTypeId").val();
    
            // These lists store data types to make the if else block below easier to manage.
            var inputIds = [1, 2, 3, 4, 7];
            var selectIds = [5, 11, 12];
            var ckeditorIds = [9];
    
            $.each(requestFieldIds, function (index, requestFieldId) {
    
                // Get the draft value from the parent.
                var draftVal = window.parent.$("#" + requestFieldId).val();

                if (draftVal === undefined) {
                    return;
                }

                // Split draftVal to count how many values for later.
                var draftValArr = draftVal.split("|||");

                // Build the request selector string and use it to get the actual editorField that has this requestFieldId.
                var requestSelectorString = `[requesttypefieldid='${requestFieldId}']`;
                var editor = $(".editorField" + requestSelectorString);

                if (editor.length > 0) {

                    editor.attr("dirty", true);

                    // There should only be one match, so we're going to use the first hit.
                    var editorField = editor[0];

                    // Get the data type and figure out which bin it belongs to.
                    var dataType = $(editorField).attr("datatypeid");

                    if (inputIds.indexOf(parseInt(dataType)) >= 0) {

                        // This bin is just standard input, so we want .editorFieldInput.
                        var inputFieldContainer = $(editorField).children(".editorFieldInputContainer");
                        var inputField = inputFieldContainer.children(".editorFieldInput");
                        if (draftValArr.length > 1) {
                            if (draftValArr.length > inputFieldContainer.length) {
                                var fieldsToAdd = draftValArr.length - inputFieldContainer.length;
                                for (i = 0; i < fieldsToAdd; ++i) {
                                    $(inputFieldContainer[inputFieldContainer.length - 1]).children(".addEditorFieldInputButton")[0].click();
                                    inputFieldContainer = $(editorField).children(".editorFieldInputContainer");
                                }
                            }
                            $.each(inputFieldContainer, function (childIndex, child) {
                                $(child).children(".editorFieldInput").val(draftValArr[childIndex]);
                            })
                        } else {
                            inputField.val(draftVal);
                        }
                        window.parent.$(`#${requestFieldId}`).remove();

                    } else if (selectIds.indexOf(parseInt(dataType)) >= 0) {
                        dropdownPromises.push(populateDropdownDraft(editor, editorField, draftVal, draftValArr, requestTypeId));
                    } else if (ckeditorIds.indexOf(parseInt(dataType)) >= 0) {
                        // Do nothing, because the data doesn't get set properly.
                        // Go down a function to requestEditorHelper.bindRichTextFields() for the logic
                        // that sets draft data.
                    }

                }
            });
            
            populateRequestItemDrafts(selectIds, versionedRequestItems, versionedFields);

            Promise.all(dropdownPromises).then(function () {
                resolve(true);
            });
        });
    
    }

    var populateRequestItemDrafts = function(selectIds, versionedRequestItems, versionedFields) {
        
        if (window.top == window.self) {
            return false;
        }

        // Populate the data tables
        $.each($('table.requestItemEditorTable'), function (idx, obj) {
            if (typeof $(obj).attr('id') == "undefined")
                return true;

            var table
            try {
                table = $(obj).DataTable();
            }
            catch (err) { return true; }

            if (window.CurrentPageMode == "makeNewRequest") {
                $.each(table.rows()[0], function (rowIndex, rowCount) {
                    requestItemTableHelpers().setDefaultItemFieldValues($(obj).attr('id'), rowIndex);
                });
            }

            var tableId = $(obj).attr("id");
            var draftTable = window.top.$(`#${tableId}`).val();

            // If we have a whole-table draft, just use that.
            if (draftTable != undefined) {
                var draftVal = JSON.parse(draftTable);
    
                var table = $(`#${tableId}`).DataTable();
                table.clear();
                $.each(draftVal, function(i, row) {
                    table.row.add(row);
                })
                table.draw();
            } else {
                // Otherwise, do it the old way.
                var draftVals = window.parent.$('[id*="' + $(obj).attr('id') + '_"]');
                $.each(draftVals, function (i, o) {
                    var dataObj = {};
                    try { dataObj = JSON.parse($(o).val()); }
                    catch (err) { return true; }
    
                    if ((!dataObj.hasOwnProperty('row')) || (!dataObj.hasOwnProperty('column')) || (!dataObj.hasOwnProperty('valuesArray')))
                        return true;
    
                    while (table.rows().count() <= dataObj['row'])
                        dataTableModule().addRequestItemRow($(obj).attr('id'), versionedRequestItems, versionedFields)
    
                    var theCell = table.cell({ 'row': dataObj['row'], 'column': dataObj['column'] });
                    console.error("theCell.node() ", theCell.node());
                    theCell.data(dataObj["valuesArray"]);
    
                    // select drop-down values
                    console.error("dataTypeId: ", dataObj["dataTypeId"]);
                    if (selectIds.indexOf(parseInt(dataObj['dataTypeId'])) >= 0) {
                        console.error("found drop down");
                        valuesArray = dataObj["valuesArray"];
                        $.each($(theCell.node()).find('select'), function (cellNum, cellObj) {
                            console.error("found cellObj: ", cellObj);
                            $(cellObj).val(valuesArray["data"][cellNum]);
                        });
                    }
                });
            }

            // Apply the dependencies
            $.each(table.rows()[0], function (rowIndex, rowCount) {
                requestItemTableHelpers().applyItemDependencies($(obj).attr('id'), rowIndex, versionedRequestItems, versionedFields);
            });
        });
    }
    
    var populateDropdownDraft = function(editor, editorField, draftVal, draftValArr, requestTypeId) {
        return new Promise(function (resolve, reject) {
            // This bin is dropdowns, so we want .editorFieldDropdown.
            var inputFieldContainer = $(editorField).children(".editorFieldInputContainer");
            var inputField = inputFieldContainer.children(".editorFieldDropdown");
            if (draftValArr.length > 1) {
                if (draftValArr.length > inputFieldContainer.length) {
                    var fieldsToAdd = draftValArr.length - inputFieldContainer.length;
                    for (i = 0; i < fieldsToAdd; ++i) {
                        $(inputFieldContainer[inputFieldContainer.length - 1]).children(".addEditorFieldInputButton")[0].click();
                        inputFieldContainer = $(editorField).children(".editorFieldInputContainer");
                    }
                }
                $.each(inputFieldContainer, function (childIndex, child) {
                    $(child).children(".editorFieldDropdown").val(draftValArr[childIndex]);
                })
            } else {
                inputField.val(draftVal);
                $(inputField).trigger('change');
            }
            resolve(true);
        });
    }
    
    var generateRequestDetailsRow = function(request, parentDiv, thisRequestType=null, versionedRequestItems=null, versionedFields=null) {
        // `d` is the original data object for the row
        console.log(request);
        ajaxModule().isThisTheMostRecent(request["requestTypeId"], request["dateCreated"]).then(function(response){

            var userGroup = window.groupsList.find(x => x.id == request["assignedGroupId"]);
            var userGroupName = "";
            if (userGroup != undefined) {
                userGroupName = userGroup["name"];
            }

            $(".requestEditorContainer.card").empty();
            $("#requestEditorModal > .modal-dialog > .modal-content > .modal-footer").remove();
            $("#requestEditorModal > .modal-dialog > .modal-content > .modal-body").remove();
        
            requestEditorContainer = $('<div class="dropdownEditorContainer makeVisible requestEditorContainer card">').attr('requestid', request['id']);
            requestEditorContainer.append($("<div>").addClass("modalTitleFixed").text(request["requestName"]));
            if (window.self != window.top)
                $(requestEditorContainer).addClass('nopadding');
            
            var repeatThisRequestDiv = false;
            var viewRequestTypeDiffDiv = false;
            var requestNameElement = false;
            var requestTypeNameElement = false;
            var requestIsApprovedElement = false;
            var requestApprovalInfoElement = false;
            var requestNotebookLinkElement = false
            var requestProjectLinkElement = false;
            var requestDateCreatedElement = false;
            var requestAssignedGroupElement = false;

            if (window.duplicatingRequest == undefined){
                if (window.CurrentPageMode != "repeatRequest")
                {
                    window.duplicatingRequest = false;
                }
                else 
                {
                    window.duplicatingRequest = true;
                }
            }
            
            if (window.self == window.top) {

                if (response.value)
                {
                    if (typeof duplicatingRequest == "undefined" || !duplicatingRequest) {
                        var repeatThisRequestButton = $('<button></button>')
                            .addClass("repeatThisRequestButton basicActionButton")
                            .attr("id", "repeatRequestBTN")
                            .text("Repeat This Request");
                        repeatThisRequestDiv = $('<div></div>')
                            .addClass("repeatThisRequestButtonContainer")
                            .append(repeatThisRequestButton);
                    }
                }

                var viewRequestTypeDivButton = $("<a>")
                    .addClass("basicActionButton")
                    .attr("id", "viewRequestTypeDiffBtn")
                    .attr("href", `/arxlab/workflow/manageConfiguration/viewRequestTypeDiff.asp?id=${request["requestTypeId"]}&r=${request["dateCreated"]}`)
                    .attr("target", "_blank")
                    .text("View Request Type Diff");
                viewRequestTypeDiffDiv = $("<div>")
                    .addClass("requestTypeDiffButtonContainer")
                    .append(viewRequestTypeDivButton);
                
        
                if (request['projectCode']) {
                    requestNameElement = $('<div class="editorField">')
                        .attr('fieldid', "requestName")
                        .append($('<label class="editorFieldLabel">Request Name</label>'),
                                $('<div class="textValue"></div>')
                                    .text(request["requestName"])
                                )
                }
        
                requestTypeNameElement = $('<div class="editorField">')
                    .attr('fieldid', "requestTypeName")
                    .attr('requesttypeid', thisRequestType['id'])
                    .append($('<label class="editorFieldLabel">Request Type</label>'),
                            $('<div class="textValue"></div>')
                                .text(thisRequestType['displayName'])
                            )
        
                requestDateCreatedElement = $('<div class="editorField">')
                    .attr('fieldid', "requestDateCreated")
                    .append($('<label class="editorFieldLabel">Date Created</label>'),
                            $('<div class="textValue"></div>')
                                .text(moment(request['dateCreated']).format("MM/DD/YYYY"))
                            )
        
                requestAssignedGroupElement = $('<div class="editorField">')
                    .attr('fieldid', "assignedUserGroup")
                    .append($('<label class="editorFieldLabel">Assigned User Group</label>'),
                            $('<div class="textValue"></div>')
                                .text(userGroupName)
                            )
        
                if (request['needsApproval'] == 1) { // Assuming we don't need to show approval status stuff if approval is not needed
                    requestIsApprovedElement = $('<div class="editorField">')
                        .attr('fieldid', "requestIsApproved")
                        .append($('<label class="editorFieldLabel" for="dropdownEditor_isApproved_cb">Is Approved</label>'),
                                $('<input type="checkbox" class="editorFieldCheckbox" name="dropdownEditor_isApproved_cb">')
                                    .prop('checked', request['isApproved'])
                                );
        
                    if (requestIsApproved) { // The request is approved - show when it was approved and who approved it
                        var approvedByUser = request['approvedByUserFullName'];
                        request['dateApproved'] = request['dateCreated']; // Temporary while we don't have approval working yet(!)
        
                        requestApprovalInfoText = `Approved by ${approvedByUser} on ${moment(request['dateApproved']).format("MM/DD/YYYY")}`
                        requestApprovalInfoElement = $('<div class="editorField">')
                            .attr('fieldid', "requestApprovalInfo")
                            .append($('<span class="textValue"></span>')
                                        .text(requestApprovalInfoText)
                                    );
                    }
                }
        
                if (request['notebookId'] && (typeof inIframe == "undefined" || !inIframe)) {
                    requestNotebookLinkElement = $('<div class="editorField">')
                        .attr('fieldid', 'notebookLink')
                        .append($('<a class="notebookLink" target="_blank">View Notebook</a>')
                                    .attr('href', `/arxlab/show-notebook.asp?id=${request['notebookId']}`)
                                );
                }
        
        
                if (request['projectId'] && (typeof inIframe == "undefined" || !inIframe)) {
                    requestProjectLinkElement = $('<div class="editorField">')
                        .attr('fieldid', 'projectLink')
                        .append($('<a class="projectLink" target="_blank">View Project</a>')
                                    .attr('href', `/arxlab/show-project.asp?id=${request['projectId']}`)
                                );
                }
            }
            
            // Request Fields section...
            var requestEditorFieldsSectionElement = $('<div class="requestFieldsSection">');
        
            if (window.self == window.top)
                requestEditorFieldsSectionElement.append($('<label class="editorSectionLabel">Fields</label>'));

            requestEditorFieldsSectionElement.append($('<div class="editorSection" sectionid="requestFields">'));
            requestEditorContainer.append(repeatThisRequestDiv);

            if (isSupport) {
                requestEditorContainer.append(viewRequestTypeDiffDiv);
            }

            requestEditorContainer.append(requestNameElement);
            requestEditorContainer.append(requestTypeNameElement);
            requestEditorContainer.append(requestDateCreatedElement);
            requestEditorContainer.append(requestAssignedGroupElement);
            requestEditorContainer.append(requestIsApprovedElement);
            requestEditorContainer.append(requestApprovalInfoElement);
            requestEditorContainer.append(requestNotebookLinkElement);
            requestEditorContainer.append(requestProjectLinkElement);
            requestEditorContainer.append(requestEditorFieldsSectionElement);
            parentDiv.prepend(requestEditorContainer.append(requestEditorFieldsSectionElement));
            
            // populate the request fields
            var selectorString = ".dropdownEditorContainer[requestid='" + request['id'] + "'] .editorSection[sectionid='requestFields']";
            
            var isManager = isWorkflowManager;
            var canReprioritize = isManager || request.requestorId == globalUserInfo.userId;
            var fieldPromises = [];
            fieldPromises.push(populateRequestFieldsSection(thisRequestType, selectorString, request, canReprioritize, versionedFields, versionedRequestItems));
            fieldPromises.push(populateRequestItemsEditorSectionInRequestEditor(request, thisRequestType, requestEditorContainer, versionedRequestItems, versionedFields));
            Promise.all(fieldPromises).then(async function () {
                // Wait until the details row is in the DOM - could be done with setInterval to speed things up...
                await dataTableModule().convertSavedRequestDataForDT(request, thisRequestType, versionedRequestItems, versionedFields)
                populateDraftVals(thisRequestType, versionedRequestItems, versionedFields)
                requestEditorBottomButtonsElement = $('<div id="UpdateRequestButtons" class="bottomButtons" style="display: none;">')
                if (window.self == window.top) {
                    requestEditorBottomButtonsElement.append($('<button class="requestEditorSubmit submitButton btn btn-success">Update Request</button>'), $('<button class="requestEditorCancel workflowBtn cancelButton btn btn-danger">Cancel Changes</button>'))
                }
    
                requestEditorContainer.append(requestEditorBottomButtonsElement);
    
    
    
                if (request['canEdit'] == 0) {
                    requestEditorContainer.addClass('notEditable');
                    // Disable requestItems table inputs
                    setTimeout(function () {
                        $('.requestEditorContainer[requestid="' + request['id'] + '"] .requestItemsEditor .requestItemEditorTable > tbody').find('input, select, button').prop('disabled', true);
    
                    }, 2000)
                }
                
                $("body").off('click', '.requestEditorContainer .requestEditorSubmit');

                $('body').on('click', '.requestEditorContainer .requestEditorSubmit', function (event) {
                    if (!$(".isCheckedOut")[0]) {
            
                        //this block of code saves each table and then submits the request to update after each row is saved 
                        var requestId = $(this).closest('.requestEditorContainer').attr('requestid');
                        var IdHolder = requestId;

                        if (!isNaN(IdHolder)) {
                            requestId = parseInt(IdHolder);
                        } else {
                            requestId = null;
                        }
                        clickRequestSubmitButton(requestId, thisRequestType, versionedRequestItems, versionedFields);
                    }
                    else {
                        if (typeof window.upsertRequestNotification !== "undefined") {
                            window.upsertRequestNotification.update({ 'title': 'Error', 'message': "A structure needs to be checked in.", 'type': "danger" });
                        }
                        else {
                            window.upsertRequestNotification = $.notify({
                                title: "Error",
                                message: "A structure needs to be checked in."
                            },
                                {
                                    delay: 0,
                                    type: "danger",
                                    template: utilities().notifyJSTemplates.default,
                                    onClose: function () {
                                        window.upsertRequestNotification = undefined;
                                    }
                                });
                        }
                    }
                });
            });
        });

    }
    
    /**
     * Populates the request item editor sections in the given request editor.
     * @param {JSON} request 
     * @param {JSON} requestType 
     * @param {Object} requestEditorContainer The DOM container for the request editor.
     * @param {JSON[]} versionedRequestItems The list of versioned request items.
     * @param {JSON[]} versionedFields The list of versioned fields.
     */
    var populateRequestItemsEditorSectionInRequestEditor = function(request, requestType, requestEditorContainer, versionedRequestItems, versionedFields) {
        return new Promise(function (resolve, reject) {
            $('.requestItemsEditorSection').empty();

            // Make sure this is reset.
            requestItemTableNames = [];
            var isOldRevision = (typeof (requestRevId) != "undefined" && requestRevId != "");
            var isNewRequest = !request;

            var canWrite = requestType['restrictAccess'] == 0 || requestType['canEdit'] == 1;
            if (window.self != window.top) {
                canWrite = window.parent.canWrite;
            }

            allRequestItemTypesEditors = $('<div>');
            $.each(requestType['requestItemTypes'], function (requestItemTypeIndex, requestItemType) {
                var requestItemsEditor = $('<div class="requestItemsEditor"></div>').attr("requestitemtypeid", requestItemType['requestItemTypeId']).attr("requestitemid", requestItemType['requestItemId'])

                var cardHeader = $('<div class="card-header" data-background-color="green"></div>').append($('<h4 class="title"></h4>').text(requestItemType['requestItemName']));
                cardHeader.append($("<div class='hideFields'></div>").append($("<img class='requestItemTriangle'></img>").attr("src", "/arxlab/images/nav-down.gif")))

                var requestItemsFileUploadForm = tableFileUpload.makeRequestItemsFileUploadForm(requestItemTypeIndex, requestItemType, versionedRequestItems);

                requestItemTableNames.push(`#requestItemTable${requestItemType["requestItemId"]}`);

				var requestItemEditorTable = $("<table>")
                                            .addClass("requestItemEditorTable display")
                                            .attr("requestitemtypeid", requestItemType["requestItemTypeId"])
                                            .attr("id", `requestItemTable${requestItemType["requestItemId"]}`)
                                            .attr("deleteonedit", requestItemType["deleteOnEdit"])
                                            .attr("tablenum", requestItemTypeIndex)
                                            .attr("cellspacing", 0);
                var sdfTableContainer = $('<div class="sdfTableContainer insideSavedRequestEditor"></div>').append(requestItemEditorTable);
                var cardContent = $('<div class="fileUploadSection card-content"></div>').append(requestItemsFileUploadForm).append(sdfTableContainer);
                var cardObj = $('<div class="card"></div>').append(cardHeader, cardContent)

                if (!isOldRevision && canWrite) {
                    cardObj.append("<button class='addRequestItem btn btn-success' tableid='requestItemTable" + requestItemType['requestItemId'] + "'>Add New Row</button>");

                    // Make the request item tables support drag and drop too.

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
                        fileType: tableFileUpload.getAcceptedFileTypes(requestItemType.requestItemTypeId, versionedRequestItems).map(x => x.substring(1, x.length))
                    };

                    var fileAddedCallbackFn = async function(file, rObj) {
                        requestItemsFileUploadForm.find(".sdfUploadStatusHolder").text(file.fileName);
                    
                        var originalFileName = file.fileName;
                        var splitFile = originalFileName.split(".");
                        var fileExtension = splitFile[splitFile.length - 1].toLowerCase();
                        
                        // Don't upload SD Files to the server for this, we can read them in the front-end.
                        if (fileExtension == "sdf") {
                            tableFileUpload.displayFileImportOptions(`requestItemTable${requestItemType.requestItemId}`, "new", null, requestItemTypeIndex, `.${fileExtension}`, "", requestItemType['requestItemTypeId'], isNewRequest, file.file, versionedRequestItems, versionedFields);
                        } else {
                            $("#basicLoadingModal").show();
        
                            rObj.upload();
                        }
                    }

                    var fileSuccessCallbackFn = function(file, response, rObj) {
                        $("#basicLoadingModal").hide();
                        var responseData = JSON.parse(response);
                        
                        var originalFileName = file.fileName;
                        var newFileName = responseData.newFileName;
                        var fileExtension = responseData.fileExt.toLowerCase();

                        var requestObj = {
                            connectionId: connectionId,
                            requestItemTypeId: requestItemType['requestItemTypeId'],
                            jwt: jwt,
                            originalFileName: originalFileName,
                            newFileName: newFileName,
                            fileExtension: fileExtension,
                            appName: window.top.currApp
                        };

                        var tableId = 'requestItemTable' + requestItemType['requestItemId'];
                        
                        tableFileUpload.displayFileImportOptions(tableId, "new", requestObj, requestItemTypeIndex, fileExtension, newFileName, requestItemType['requestItemTypeId'], isNewRequest, null, versionedRequestItems, versionedFields);
                        
                        rObj.removeFile(file);

                        utilities().showUnsavedChangesNotification();
                    }

                    var resumableObject = resumableModule(resumableOptions, cardContent, requestItemsFileUploadForm.find(".resumable-browse"));
                    resumableObject.addFileCallback(fileAddedCallbackFn);
                    resumableObject.addFileSuccessCallback(fileSuccessCallbackFn);

                }

                cardObj.append("<button class='generateCSV btn btn-success' tableid='requestItemTable" + requestItemType['requestItemId'] + "'>Download CSV</button>");
                if (versionedRequestItems.find(x => x.id == requestItemType['requestItemTypeId']).fields.find(x => x['dataTypeId'] == 8) != undefined)
                {
                    cardObj.append("<button class='generateSDF btn btn-success' tableid='requestItemTable" + requestItemType['requestItemId'] + "'>Download SDF</button>");
                }

                if (Object.keys(requestItemType).indexOf("requestItemHoverText") >= 0) {
                    if (requestItemType['requestItemHoverText']) {
                        cardObj.attr("title", requestItemType['requestItemHoverText']);
                    }
                }

                requestItemsEditor.append(cardObj);
                allRequestItemTypesEditors.append(requestItemsEditor);
            });

            requestEditorContainer.append(allRequestItemTypesEditors.children());
            resolve(requestEditorContainer);
        });
    };

    var insertRequestFieldsToggle = function() {
        $("<div id='hideFields' class='hideFields'><img id='triDown' class='requestFieldTriangle' src='/arxlab/images/nav-down.gif'></div>").on("click", function () {
            var fieldObjs = $(".requestFieldsSection").children();
            $.each(fieldObjs, function (index, fieldObj) {
                if ($(fieldObj).hasClass("editorSection")) {
                    toggleObj(fieldObj);
                }
            });
            swapTriangles("#triDown");
        }).insertBefore(".editorSection");
    }
    
    var toggleObj = function(obj) {
        var divObj = $(obj);
        if ($(divObj).is(":visible")) {
            $(divObj).hide();
        } else {
            $(divObj).show();
        }

        utilities().resizeCustExpIframe();
    }

    var swapTriangles = function(div) {
        var src = $(div).attr("src");
        var down = '/arxlab/images/nav-down.gif';
        var right = '/arxlab/images/nav-right.gif';

        if (src == down) {
            $(div).attr("src", right);
        } else {
            $(div).attr("src", down);
        }
    }

    var populateUserGroupsList = function() {
        return new Promise(function (resolve, reject) {

            if ($("select#assignedUserGroupDropdown").children().length > 0) {
                resolve(true);
            } else {
                var dropdown = $('<select></select>'); // only used as a container
                $.each(window.groupsList, function () {
                    groupId = this['id']
                    groupName = this['name']
                    var groupOption = $('<option></option>').attr('value', groupId).attr('groupid', groupId).text(groupName)
                    dropdown.append(groupOption)
                });
                $('select#assignedUserGroupDropdown').html(dropdown.html())
                resolve(true);
            }
        });
    }

    /**
     * Calls to JChem to get the structure data for all structures on the page to try and register them if possible before
     * running the actual submission code.
     * @param {number} requestId The ID of the request we're submitting. Can be null.
     * @param {boolean} checkRequiredFields Check if the required fields are there on submission.
     * @param {boolean} submitAllFields Do we want to submit every field, regardless of dirty status?
     * @param {Function} saveCallbackFn The save function to run on completion of request submission. Used to trigger custom experiment saving.
     * @param {JSON} thisRequestType The request type config info.
     * @param {Array} versionedRequestItems The request item config info.
     * @param {Array} versionedFields The field config info.
     */
    var getStructuresAndSubmit = async function(requestId, checkRequiredFields = true, submitAllFields=false, saveCallbackFn = function (saveRequestId, saveRevisionId) { }, thisRequestType = null, versionedRequestItems = window.requestItemTypesArray, versionedFields = window.savedFieldsArray) {

        var structureHolders = $('.structureImageContainer');
        var promisArray = [];
        var promisKeys = [];
    
        $.each(structureHolders, function () {
    
            var thisId = $(this).find('.editStructureLink').attr('liveeditid');
            if (thisId == undefined) {
                thisId = $(this).find('.isReadOnly').attr('liveeditid');
            }
    
            promisArray.push(getChemistryEditorChemicalStructure(thisId, false));
            promisKeys.push(thisId);
    
        });

        const VALUES = await Promise.all(promisArray);

        var compoundRegPromiseArray = [];
    
        $.each(VALUES, function (index, item) {

            var liveEditId = promisKeys[index];
            if (item == null)
            {
                allStructures[liveEditId] = getEmptyMolFile();
            }
            else
            {
                allStructures[liveEditId] = item;
            }

            var registerCompound = false;

            if (liveEditId.includes("itemType")) {
                // This is a request item, so fetch the request item's setting.
                var requestItemTypeId = $("[liveeditid=" + liveEditId + "]").parents(".requestItemsEditor").attr("requestItemTypeId");
                var thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
                registerCompound = thisRequestItemType.registerNewCompounds;
            } else {
                // This is the base request type, so fetch the request type's setting.
                registerCompound = thisRequestType.registerNewCompounds;
            }
            
            var isRequestEditorLink = $("[liveeditid=" + liveEditId + "]").parents(".editorFieldInputContainer").length > 0
            var regVal;

            if (isRequestEditorLink) {
                regVal = $("[liveeditid=" + liveEditId + "]").parents(".editorSection.card").find("[datatypeid=" + dataTypeEnums.REGISTRATION + "] > div.editorFieldInputContainer > a").val();
            } else {
                regVal = $("[liveeditid=" + liveEditId + "]").closest("tr").find("[datatypeid=" + dataTypeEnums.REGISTRATION + "] > a").val();
            }

            if (registerCompound && !regVal) {
                compoundRegPromiseArray.push(promisKeys[index]);
            }

        });
        
        await registerOneStrucAtATime(compoundRegPromiseArray, versionedRequestItems, versionedFields);
        const UNNAMED_PROJECT_LIST = await autoGenerateElnObjects(versionedRequestItems, versionedFields);
        submitRequestEditor(requestId, checkRequiredFields, submitAllFields, UNNAMED_PROJECT_LIST, saveCallbackFn, thisRequestType, versionedRequestItems);

    }

    /**
     * Finds every autogenerate field and instantiates the object requested, then fills the information into the select2 field.
     * @param {Array[JSON]} versionedRequestItems The versioned request item info.
     * @param {Array[JSON]} versionedFields The versioned request field info.
     */
    var autoGenerateElnObjects = function(versionedRequestItems, versionedFields) {
        return new Promise(function(resolve, reject) {
            var autoGenPromises = [];
            $.each($("input[autogen=1]"), function(inputIndex, editor) {

                // Make sure we don't have any data in this editor before generating a new notebook or project.
                var select2Data = $(editor).select2("data");
                if (!select2Data || select2Data["id"] == -1) {
                    if ($(editor).attr("id") == "searchForNotebook") {
                        autoGenPromises.push(elnAutomation().genNotebook("", editor));
                    }
                    if ($(editor).attr("id") == "searchForProject") {
                        autoGenPromises.push(elnAutomation().genProject("", editor));
                    }
                }
            });

            Promise.all(autoGenPromises).then(function(autoGenResponses) {
                let unnamedProjectList = [];
                $.each(autoGenResponses, function(i, autoGenResponse) {
                    if (autoGenResponse["inTable"]) {
                        dataTableModule().updateRequestItemsTableDataAndRedraw(autoGenResponse["editor"], versionedRequestItems, versionedFields);
                    }

                    if (autoGenResponse["isProject"]) {
                        unnamedProjectList.push(autoGenResponse["id"])
                    }
                });
                resolve(unnamedProjectList);
            })
        })
    }

    /**
     * Alerts the user if there are any request item tables that aren't sorted by the default order.
     * Currently unused, but left here in case we want to use this.
     * @param {Function} callbackFn The saving callback function.
     */
    var unsortedTablesCheck = function(callbackFn) {
        if (!dataTableModule().allTablesSorted()) {
            window.top.swal({
                "title": "Request item table(s) are unsorted!",
                "type": "warning",
                "text": "You have at least one request item table that is not sorted in Priority order. This will irreversibly alter the Priority of your tables if submitted like this.",
                "showCancelButton": true,
                "confirmButtonText": "Submit"
            }, function() {
                callbackFn();
            });
        } else {
            callbackFn();
        }
    }

    var registerOneStrucAtATime = function(keysArr, versionedRequestItems, versionedFields) {
        return new Promise(function(resolve, reject) {
            if (keysArr.length == 0) {
                resolve(true);
            } else {
                utilities().addStructureToReg(keysArr[0], versionedRequestItems, versionedFields).then(function(resp) {
                    console.log(`Registered ${keysArr[0]}`);
                    keysArr.shift();
                    resolve(registerOneStrucAtATime(keysArr, versionedRequestItems, versionedFields));
                })
            }
        });
    }

    /**
     * Builds the prioritization table using requestsArray so the user can prioritize the request they're submitting.
     * @param {Array} requestsArray The list of requests to prioritize.
     * @param {string} orderType The order column we want to prioritize against.
     */
	var changeRowsInMyRequestsTable = function (requestsArray, orderType) {
        var myRequestsTableRows = generateMyRequestsTableRows(requestsArray);
        $('table#prioritizeThisRequestTable tbody tr:not(.thisNewRequestRow)').remove();
        $('table#prioritizeThisRequestTable tbody').prepend(myRequestsTableRows);
        $('table#prioritizeThisRequestTable').attr("orderType", orderType);
	}

    /**
     * Builds a list of table rows based on requestsArray to display in the prioritization table.
     * @param {Array} requestsArray The list of requests to prioritize.
     */
	var generateMyRequestsTableRows = function (requestsArray) {
        myRequestsTableRowsArray = [];
        var parsedRequestsArray = JSON.parse(requestsArray["data"]);

        $.each(parsedRequestsArray, function (requestIndex, request) {
            var tableRow = $('<tr></tr>').attr('requestid', request['id']);
            var reorderRowTd = $('<td>').append(
                $('<div>')
                    .text(request['requestTypeName'])
                    .addClass('requestTypeName')
            );

            if (typeof request['requestName'] !== "undefined") {
                var requestedOrderHolder = $('<div>')
                    //.text(request['requestedOrder'])
                    .text(requestIndex + 1)
                    .addClass('requestedOrder');
                var requestNameHolder = $('<div>')
                    .text(request['requestName'])
                    .addClass('requestName');
                var dateCreatedHolder = $('<div>')
                    .text(moment(request['dateCreated'])
                    .format("MM/DD/YY"))
                    .addClass('requestDate');
                var numItemsHolder = $('<div>')
                    .text(request["requestItemCount"])
                    .addClass('numberOfItems');
                var previewStructuresHolder = $('<div>')
                    .html('<i class="material-icons previewStructuresButton">chevron_right</i>')
                    .addClass('previewStructuresButtonHolder');
                var reorderRowTd = $("<td>").append(
                    requestedOrderHolder,
                    requestNameHolder,
                    dateCreatedHolder,
                    numItemsHolder,
                    previewStructuresHolder
                );
            }
            
            tableRow.append(reorderRowTd);
            myRequestsTableRowsArray.push(tableRow);
        });

        return myRequestsTableRowsArray;
    }
    
    return {
        populateRequestFieldsSection: populateRequestFieldsSection,
        populateDraftVals: populateDraftVals,
        findStatusFieldAndQueuedOptionId: findStatusFieldAndQueuedOptionId,
        filterRequestsToOnlyMine: filterRequestsToOnlyMine,
        orderRequestsByRequestedOrderWithNullsLast: orderRequestsByRequestedOrderWithNullsLast,
        finalizeRequestEditorInitialization: finalizeRequestEditorInitialization,
        bindRichTextFields: bindRichTextFields,
        generateRequestDetailsRow: generateRequestDetailsRow,
        populateRequestItemsEditorSectionInRequestEditor: populateRequestItemsEditorSectionInRequestEditor,
        insertRequestFieldsToggle: insertRequestFieldsToggle,
        populateUserGroupsList: populateUserGroupsList,
        unsortedTablesCheck: unsortedTablesCheck,
        getStructuresAndSubmit: getStructuresAndSubmit,
        clickRequestSubmitButton: clickRequestSubmitButton,
        packageRequest: packageRequest,
        errorResponseHandler: errorResponseHandler,
        initCKEFields: initCKEFields
    }
}

requestEditorHelper = requestEditorModule();
