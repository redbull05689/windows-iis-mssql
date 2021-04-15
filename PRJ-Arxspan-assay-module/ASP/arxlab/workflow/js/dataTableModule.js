var dataTableModule = (function(){

    // Priority column config information.
    var priorityCol = {
        "data": "sortOrder",
        "title": "Priority",
        "savedField": null,
        "sType": "sortOrder",
        "render": function(data, type, row, meta) {

            if (type != "display") {
                return data;
            }

            var holderDiv = $("<div>");

            var canWrite = true;
            if (window.self != window.top) {
                canWrite = window.parent.canWrite;
            }
            
            var thisTable = $(meta.settings.nTable);
            var thisTableOrder = thisTable.DataTable().order();

            var isDefaultSort = dataTableModule().isDefaultSort(thisTableOrder);

            if (canWrite && isDefaultSort) {
                // Add the drag handle
                var requestItemDragHandle = $('<div title="Drag Handle" class="requestItemDragHandle">').append($('<i class="material-icons">').text("reorder"));
                var requestItemDragToReorder = $('<button class="requestItemDragToReorder btn">');
                requestItemDragToReorder.append(requestItemDragHandle);
                holderDiv.append(requestItemDragToReorder);
            }
            var tableId = thisTable.attr("id");

            var contentPaste = $('<i class="material-icons">content_paste</i>');
            var copyButton = $("<button>")
                .attr("title", "Copy/Paste")
                .attr("id", data)
                .attr("tableid", tableId)
                .addClass("btn requestCopyPaste copyRequestItemButton")
                .append(contentPaste);
            holderDiv.append(copyButton);
    
            if ((thisTable.closest(".requestEditorContainer").hasClass("newRequestEditor") || thisTable.attr("deleteonedit") == "true" || !row.requestItemId) && canWrite) {
                var contentCancel = $('<i class="material-icons">cancel</i>')
                var removeRequestItemButton = $("<button>")
                    .attr("title", "Remove Row")
                    .attr("id", data)
                    .attr("tableid", tableId)
                    .addClass("btn btn-danger btn-sm removeRequestItemButton")
                    .append(contentCancel)
                    holderDiv.append(removeRequestItemButton);
            }

            return holderDiv.html();
        }
    };
    
    // Request Item name column config information.
    const NAME_COL = {
        "data": "requestItemName",
        "title": "Name",
        "savedField": null,
    };

    // Do we want to add the name column to the columns array?
    const ADD_NAME_COL = (
        (typeof window.duplicatingRequest == "undefined" || !window.duplicatingRequest) &&
        window.top == window.self &&
        !["makeNewRequest"].includes(CurrentPageMode)
    );
    
    /**
     * Creates the field column settings data for this field.
     * @param {JSON} savedField The field configuration info.
     * @param {number} fieldIndex The index of this field relative to its request item.
     * @param {number} fieldIndexOffset The number of disabled fields we've counted up to this point.
     * @param {JSON} requestItemTypeField The request item type field config info.
     * @param {boolean} isOldRevision Is this an older revision of a request?
     * @param {boolean} canWrite Can we write to this request?
     */
    var makeFieldColumnSettings = function(savedField, fieldIndex, fieldIndexOffset, requestItemTypeField, isOldRevision, canWrite) {
        
        // Unfortunately, we have to use array index to figure out where these columns are, so we calculate that by combining the
        // sortOrder of the field and the offset, which is a count of how many fields are disabled.
        let targetIndex = (fieldIndex + fieldIndexOffset);

        // Then if we have the name column, add an extra 1 to the targetIndex.
        if (ADD_NAME_COL) {
            targetIndex += 1;
        }

        var thisColumnDefSetting = {
            "targets": targetIndex,
            "orderable": savedField["dataTypeId"] != dataTypeEnums.STRUCTURE
        };

        thisColumnDefSetting["render"] = function (data, type, row) {
            console.log(data)

            if (Array.isArray(data)) {
                data = {dirty: false, data: data};
            }

            if (typeof data == "undefined" || data == null || data["data"].length == 0) { // Undefined or just an empty array...
                data = {dirty: false, data: [null]};
            }

            var tableCellContentWrapper = fnc_tableCellContentWrapper(savedField, requestItemTypeField);
            var originalDataArrayLength = getOriginalRequestItemDataArrayLength(row, savedField);


            tableCellContentWrapper.attr('originaldataarraylength', originalDataArrayLength.toString());
            if (originalDataArrayLength < data.length) {
                // User has added values to the request item
                tableCellContentWrapper.addClass('hasNewlyAddedValues')
            }
            else {
                // User has not added values - no need for _add button to be visible (unless the user has canRemove, but CSS handles that)
                tableCellContentWrapper.removeClass('hasNewlyAddedValues')
            }

            var inputFieldsBucket = $('<div></div>');
            if (!data["data"]) {
                data = {dirty: false, data: data};
            }
            $.each(data["data"], function (cellValueIndex, cellValue) {

                var navlink = null;

                if (cellValue == "|||||") {
                    cellValue = ""; //this is to convert the blanks ("|||||") back into ("")
                }
                
                if (savedField['dataTypeId'] == dataTypeEnums.TEXT)
                {
                    var inputField = fieldsModule().requestItemTypeTextGenerator(cellValue);
                }
                else if (savedField['dataTypeId'] == dataTypeEnums.LONG_TEXT)
                { 
                    var inputField = fieldsModule().requestItemTypeLongTextGenerator(cellValue);
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.INTEGER)
                { 
                    var inputField = fieldsModule().requestItemTypeIntGenerator(parseInt(cellValue));
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.REAL_NUMBER)
                {
                    var inputField = fieldsModule().requestItemTypeNumberGenerator(cellValue);
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.DROP_DOWN)
                { 
                    var inputField = fieldsModule().requestItemTypeDropdownGenerator(savedField, requestItemTypeField, cellValue);
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.FILE_ATTACHMENT)
                { 
                    var inputField = $('<form class="requestItemFieldFileAttachmentForm resumable-drop" onsubmit="return false;">').attr("fileid", -1);
                    var currentFileElement = $("<a href='#'></a>").addClass("currentFileLink").text("No file chosen");

                    var fileId = "-1";
                    var fileName = "";

                    if (cellValue !== null && cellValue !== "") {

                        fileId = cellValue["id"];
                        fileName = cellValue["name"] ? cellValue["name"].substring(0, 44) : "Undefined";
                        var fileDisplayText = $.trim(fileName) + "...";
                        currentFileElement.find('.currentFileLink')
                            .text('Current file: ' + fileDisplayText)
                            .attr('href', `getSourceFile.asp?fileId=${fileId}`);
                    }
                    inputField.attr('fileid', fileId);
                    inputField.attr("filename", fileName);                    
                    inputField.append(currentFileElement);
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.DATE)
                { 
                    var inputField = $(`<input class="dataTableCellDateInput" style="display:none;"></input>`).attr("initVal", cellValue);
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.STRUCTURE)
                { 
                    var structureDisplay = fieldsModuleHelper.requestTypeStructureGenerator(requestItemTypeField["requestTypeFieldId"]);
                    $(structureDisplay).attr('dataTypeId', "8");
                    $(structureDisplay).attr("title", savedField["hoverText"]);

                    var structureVal = cellValue;
                    var fileFormat;

                    if (structureVal == null)
                    {
                        structureVal = getEmptyMolFile();
                        fileFormat = "cdx";
                    }
                    if (typeof structureVal != "string") {
                        if (Object.keys(structureVal).includes("data")) {
                            structureVal = structureVal["data"][0];
                        }
                    }

                    if (!fileFormat)
                    {
                        fileFormat = getFileFormat(structureVal);
                    }
                    // if this is not CDX or CDXML, convert it to CDX in jchem
                    if (fileFormat != "cdx" && fileFormat != "cdxml"){
                        var jchemProxyLoc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport";
                        if (structureVal == undefined) {
                            structureVal = getEmptyMolFile();
                        }
                        $.ajax({
                            method: "POST",
                            structureDisplay: structureDisplay,
                            url: jchemProxyLoc,
                            data: JSON.stringify({"structure": structureVal.replace(/\\"/g, '"').replace(/<\?[^>]+\?><!DOCTYPE[^>]+>/g,""), //jchem doesn't like the doctype def, so remove it,
                                                    "parameters": "cdx"}),
                            dataType: "json",
                            contentType: "application/json",
                            async: false //Sorry
                            }).done(function(msg) {
                                $(this.structureDisplay).attr('startingMolData', msg['binaryStructure']);
                            }).fail(function() {
                                $(this.structureDisplay).attr('startingMolData', structureVal);
                            });
                    }else{
                        structureDisplay.attr('startingMolData', structureVal);
                    }
                    var inputField = structureDisplay;
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.NOTEBOOK)
                { 
                    var randomFieldValue = Math.random().toString(36).substring(7);
                    var inputField = $("<input></input>").attr("type", "text");
                    inputField.addClass("searchForNotebook").addClass("select2-offscreen").addClass("initItem");
                    inputField.attr("id", "searchForNotebook");
                    inputField.attr("name", "searchForNotebook");
                    inputField.attr("title", "Search for Notebook");
                    inputField.attr("requesttypefieldid", requestItemTypeField["requestTypeFieldId"]);
                    inputField.attr("fieldid", randomFieldValue);
                    inputField.attr("autogen", requestItemTypeField["autoGenerateNotebook"]);
                    inputField.attr("bidirectionallink", requestItemTypeField["bidirectionalRequestLinking"]);

                    navlink = $('<a href="JavaScript:void(0);" class="navigateLink btn btn-info btn-sm" style="display:none">Open Notebook</button>')
                        .attr('fieldId', randomFieldValue);

                    if (cellValue != null && cellValue != "" && cellValue != "null") {
                        cellValue = JSON.parse(cellValue)
                        try {
                            cellValue = JSON.parse(cellValue)
                        } catch (error) {
                        }
                        try {
                            if (cellValue.id == null){
                                cellValue = JSON.parse(cellValue.text)
                            }
                        } catch (error) {
                        }

                        if (cellValue != -1)
                        {	
                            if ('id' in cellValue && cellValue['id'] != -1) {
                                var opt = $('<option id="' + cellValue['id'] + '" selected="selected">' + cellValue['text'] + '</option>');
                                opt.attr("fieldid", randomFieldValue);
                                $(inputFieldsBucket).append(opt);
                            }
                        }
                    }

                    if (requestItemTypeField["autoGenerateNotebook"] == "1") {
                        inputField.attr("disabled", true);
                    }
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.PROJECT)
                { 
                    var randomFieldValue = Math.random().toString(36).substring(7);
                    var inputField = $("<input></input>").attr("type", "text");
                    inputField.addClass("searchForProject").addClass("select2-offscreen").addClass("initItem");
                    inputField.attr("id", "searchForProject");
                    inputField.attr("name", "searchForProject");
                    inputField.attr("title", "Search for Project");
                    inputField.attr("requesttypefieldid", requestItemTypeField["requestTypeFieldId"]);
                    inputField.attr("fieldid", randomFieldValue);
                    inputField.attr("autogen", requestItemTypeField["autoGenerateProject"]);
                    inputField.attr("bidirectionallink", requestItemTypeField["bidirectionalRequestLinking"]);
                    
                    navlink = $('<a href="JavaScript:void(0);" class="navigateLink btn btn-info btn-sm" style="display:none">Open Project</button>')
                        .attr('fieldId', randomFieldValue);

                    if (cellValue != null && cellValue != "" && cellValue != "null") {
                        cellValue = JSON.parse(cellValue)
                        try {
                            cellValue = JSON.parse(cellValue)
                        } catch (error) {
                            console.log(error)
                        }
                        try {
                            if (cellValue.id == null){
                                cellValue = JSON.parse(cellValue.text)
                            }
                        } catch (error) {
                        }
                        if (cellValue != -1)
                        {	
                            if ('id' in cellValue && cellValue['id'] != -1) {
                                var opt = $('<option id="' + cellValue['id'] + '" selected="selected">' + cellValue['text'] + '</option>');
                                opt.attr("fieldid", randomFieldValue);
                                $(inputFieldsBucket).append(opt);
                            }
                        }
                    }
                    
                    if (requestItemTypeField["autoGenerateProject"] == "1") {
                        inputField.attr("disabled", true);
                    }
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.EXPERIMENT)
                { 
                    var randomFieldValue = Math.random().toString(36).substring(7);
                    var inputField = $("<input></input>").attr("type", "text");
                    inputField.addClass("searchForExperement").addClass("select2-offscreen").addClass("initItem");
                    inputField.attr("id", "searchForExperement");
                    inputField.attr("name", "searchForExperement");
                    inputField.attr("title", "Search for Experiment");
                    inputField.attr("requesttypefieldid", requestItemTypeField["requestTypeFieldId"]);
                    inputField.attr("fieldid", randomFieldValue);
                    inputField.attr("autogen", requestItemTypeField["autoGenerateExperement"]);
                    inputField.attr("bidirectionallink", requestItemTypeField["bidirectionalRequestLinking"]);
                    
                    navlink = $('<a href="JavaScript:void(0);" class="navigateLink btn btn-info btn-sm" style="display:none">Open Experiment</button>')
                        .attr('fieldId', randomFieldValue);

                    if (cellValue != null && cellValue != "" && cellValue != "null") {
                        cellValue = JSON.parse(cellValue)
                        try {
                            cellValue = JSON.parse(cellValue)
                        } catch (error) {
                        }
                        try {
                            if (cellValue.id == null){
                                cellValue = JSON.parse(cellValue.text)
                            }
                        } catch (error) {
                        }

                        if (cellValue != -1)
                        {		
                            if ('id' in cellValue && cellValue['id'] != -1  && cellValue != "null") {
                                var opt = $('<option id="' + cellValue['id'] + '" index="' + cellValue['index'] + '"selected="selected">' + cellValue['text'] + '</option>');
                                opt.attr("fieldid", randomFieldValue);
                                $(inputFieldsBucket).append(opt);
                            }
                        }
                    }

                    console.log("hello");

                    if (requestItemTypeField["autoGenerateExperement"] == "1") {
                        inputField.attr("disabled", true);
                    }
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.REGISTRATION)
                { 
                    var inputField = fieldsModuleHelper.requestItemTypeRegLinkGenerator(savedField, cellValue);
                    if (cellValue != "" && cellValue !== null) {
                        if (cellValue == -1) {
                            inputField.text("New Compound");
                        } else {

                            var regLink = "javascript:void(0)";

                            if (savedField["dataTypeId"] == dataTypeEnums.REGISTRATION) {
                                regLink = "/arxlab/registration/showReg.asp?regNumber=" + cellValue;
                            }

                            inputField.text(cellValue);
                            inputField.attr("target", "_blank");
                            inputField.attr("href", regLink);
                            inputField.val(cellValue);
                        }
                    } else {
                        inputField.text("No link");
                    }
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.REQUEST)
                { 
                    if (cellValue != null)
                    {   
                        if (typeof cellValue == "string")
                        {
                            cellValue = JSON.parse(cellValue);
                        }
                        $.each(cellValue,function(key,val){

                    
                            var inputField = $("<a></a>").val(key);
                            inputField.addClass("btn");
                            inputField.addClass("btn-info");
                            inputField.addClass("btn-sm");
                            
                            if (key != "" && key !== null) {
                            
                                    inputField.text(val);
                                    inputField.attr("reqID", key)
                                    inputField.attr("target", "_blank");
                                    inputField.attr("href", "JavaScript:Void(0);");
                                    inputField.attr("onClick", "utilities().showReq(" + key + ")");
                                    inputField.val(key);
                                
                            } else {
                                inputField.text("No link");
                            }
                            inputFieldsBucket.append(inputField);
                        })
                    }
                    else 
                    {
                        var inputField = $("<a></a>");
                        inputField.addClass("btn");
                        inputField.addClass("btn-info");
                        inputField.addClass("btn-sm");
                        inputField.text("No link");
                        inputFieldsBucket.append(inputField);
                    }
                
                } 
                else if (savedField['dataTypeId'] == dataTypeEnums.FOREIGN_LINK)
                { 
                    var inputField = fieldsModuleHelper.requestItemTypeRegLinkGenerator(savedField, cellValue);
                    if (cellValue != "" && cellValue !== null) {
                        if (cellValue == -1) {
                            inputField.text("New Compound");
                        } else {

                            var regLink = "javascript:void(0)";

                            if (savedField["dataTypeId"] == dataTypeEnums.REGISTRATION) {
                                regLink = "/arxlab/registration/showReg.asp?regNumber=" + cellValue;
                            }

                            inputField.text(cellValue);
                            inputField.attr("target", "_blank");
                            inputField.attr("href", regLink);
                            inputField.val(cellValue);
                        }
                    } else {
                        inputField.text("No link");
                    }
                }
                else if (savedField['dataTypeId'] == dataTypeEnums.UNIQUE_ID)
                {
                    var inputField = fieldsModule().requestAutoGeneratedField(cellValue);
                } 
              
                var errorLabel = $('<label class="editorItemFieldValidationErrorLabel">');
                if (isOldRevision || !canWrite) {
                    inputField.attr("disabled", true);
                }
                if (savedField['dataTypeId'] != dataTypeEnums.REQUEST){
                    if (navlink == null) {
                        inputFieldsBucket.append(inputField, errorLabel);
                    } else {
                        inputFieldsBucket.append(inputField, navlink, errorLabel);
                    }
                }
            });

            var removeButton = $('<button class="dataTableCellSmallButton_remove btn btn-sm btn-danger">-</button>');
            var addButton = $('<button class="dataTableCellSmallButton_add btn btn-sm btn-success">+</button>');

            if (!isOldRevision && canWrite) {
                if (savedField['dataTypeId'] == dataTypeEnums.DROP_DOWN){
                    inputFieldsBucket.append($("<br>"));
                }

                inputFieldsBucket.append(removeButton, addButton);

                if (savedField["dataTypeId"] == dataTypeEnums.FILE_ATTACHMENT && requestItemTypeField["sendToELN"]) {
                    var moveFilesToELNBtn = $("<button>")
                        .addClass("moveFilesBtn")
                        .addClass("moveFilesBtnTable")
                        .addClass("btn")
                        .addClass("btn-sm")
                        .text("Send to ELN");
                        inputFieldsBucket.append(moveFilesToELNBtn);
                }
            }
            tableCellContentWrapper = utilities().permCheck(requestItemTypeField, tableCellContentWrapper, inputFieldsBucket, 'input')

            var returnHTML = $('<div>').append(tableCellContentWrapper).html();
            return returnHTML;
        }

        var sType = "";
        if (savedField["dataTypeId"] == dataTypeEnums.TEXT) {
            sType = "text";
        } else if (savedField["dataTypeId"] == dataTypeEnums.LONG_TEXT) {
            sType = "longText";
        } else if (savedField["dataTypeId"] == dataTypeEnums.INTEGER ||
                    savedField["dataTypeId"] == dataTypeEnums.REAL_NUMBER) {
            sType = "number";
        } else if (savedField["dataTypeId"] == dataTypeEnums.DROP_DOWN) {
            sType = "dropDown";
        } else if (savedField["dataTypeId"] == dataTypeEnums.FILE_ATTACHMENT) {
            sType = "file";
        } else if (savedField["dataTypeId"] == dataTypeEnums.DATE) {
            sType = "workflow-date";
        } else if (savedField["dataTypeId"] == dataTypeEnums.NOTEBOOK ||
                    savedField["dataTypeId"] == dataTypeEnums.PROJECT ||
                    savedField["dataTypeId"] == dataTypeEnums.EXPERIMENT) {
            sType = "link";
        } else if (savedField["dataTypeId"] == dataTypeEnums.REQUEST ||
                    savedField["dataTypeId"] == dataTypeEnums.REGISTRATION ||
                    savedField["dataTypeId"] == dataTypeEnums.FOREIGN_LINK) {
            sType = "reg";
        }

        if (sType != "") {
            thisColumnDefSetting["sType"] = sType;
        }

        return thisColumnDefSetting;
          
    }

    var getOriginalRequestItemDataArrayLength = function(row, savedField) {
        if (typeof row['uniqueIdentifier_hidden'] !== "undefined") {
            var requestItemIdentifierKey = "uniqueIdentifier_hidden";
        }
        else if (typeof row['requestItemId'] !== "undefined") {
            var requestItemIdentifierKey = "requestItemId";
        }
        var requestItemIdentifier = row[requestItemIdentifierKey].toString();
        if (typeof window.requestItemsTableMetaData[requestItemIdentifier] !== "undefined" && typeof window.requestItemsTableMetaData[requestItemIdentifier]['originalDataArrayLengths'][savedField['displayName'].toLowerCase()] !== "undefined") {
            dataArrayLength = window.requestItemsTableMetaData[requestItemIdentifier]['originalDataArrayLengths'][savedField['displayName'].toLowerCase()];
            return dataArrayLength;
        }
        else {
            return 100;
        }
    }

    /**
     * Returns a full live edit id for request item structures.
     * @param {Number} requestItemTypeId request item type id.
     * @param {Number} rowNumber row number.
     * @param {Number} fieldNumber request item type field id.
     */
    var getStructureImageId = function(requestItemTypeId, rowNumber, fieldNumber) {
        return "itemType_" + requestItemTypeId + "_" + rowNumber + "_" + fieldNumber;
    }

    var checkForStructure = function(field) {
        // Helper function to find fields of dataType 8.
        if (field.savedField) {
            return field.savedField.dataTypeId == 8;
        } else {
            return false;
        }
    }

    /**
     * Initializes the request item table.
     * @param {JSON} tableData The data we want to populate this table with.
     * @param {number} requestItemTypeId The request item's type ID.
     * @param {string} tableSelectorString The selector string used to help locate this table in the DOM.
     * @param {JSON} thisRequestType The request type that pertains to this request.
     * @param {JSON[]} versionedRequestItems The list of request item config data.
     * @param {JSON[]} versionedFields The list of field config data.
     */
    var initRequestItemTable = function(tableData, requestItemTypeId, tableSelectorString = "", thisRequestType = null, versionedRequestItems = null, versionedFields = null) {
        var isOldRevision = (typeof (requestRevId) != "undefined" && requestRevId != "");
        var canWrite = true;
        if (window.self != window.top) {
            canWrite = window.parent.canWrite;
        }

        if (typeof window.requestItemTypesColumns == "undefined") {
            window.requestItemTypesColumns = {}
        }
    
        if (window.CurrentPageMode == "manageRequests") {
            window.CurrentPageMode = "editRequests";
        }
    
        if ($.fn.DataTable.isDataTable(tableSelectorString + 'table.requestItemEditorTable[requestitemtypeid="' + requestItemTypeId + '"]')) {

            // BUG 2837 - When adding a CSV or excel file to a table with no current rows the upload fails in workflow experiments
            // The selector above breaks when the table is emptied and will never work again, so I'm fetching an ID that works.

            var tableId = "#" + $($('table.requestItemEditorTable[requestitemtypeid="' + requestItemTypeId + '"]')[1]).attr('id');
            $(tableId).DataTable().destroy();
            $(tableId).empty();            
        }
    
    
        var fieldIndexOffset = 2;
        if (window.self != window.top || tableSelectorString == "" || CurrentPageMode == "repeatRequest") {
            fieldIndexOffset = 1;
        }
    
        // Hack to intercept the table construction and add a field to the row data where the name matches the column header
        // for structures.
        var structureField = tableData["columns"].find(checkForStructure);
        if (structureField) {
            var struc_name = structureField.data;
            if (tableData.data.length > 0) {
    
                if ('structure' in tableData.data[0]) {
                    tableData.data.map(x => x[struc_name] = x["structure"]);
                }
    
            }
        }
    
        window.requestItemTypesColumns[requestItemTypeId.toString()] = tableData['columns'];
    
        // Keep record of how many values were in each request item field at the time of load...
        window.requestItemsTableMetaData = {};
        $.each(tableData['data'], function (requestItemIndex, requestItem) {
            if (typeof requestItem['uniqueIdentifier_hidden'] !== "undefined") {
                var requestItemIdentifierKey = "uniqueIdentifier_hidden";
            }
            else if (typeof requestItem['requestItemId'] !== "undefined") {
                var requestItemIdentifierKey = "requestItemId";
            }
            else {
                console.error("No unique ID for request item - stopped initializing request item table.");
                return false;
            }
            var requestItemIdentifier = requestItem[requestItemIdentifierKey].toString();
    
            window.requestItemsTableMetaData[requestItemIdentifier] = {}
            window.requestItemsTableMetaData[requestItemIdentifier]['originalDataArrayLengths'] = {};
            $.each(requestItem, function (requestItemDataKey, requestItemData) {
                if ($.isArray(requestItemData)) {
                    window.requestItemsTableMetaData[requestItemIdentifier]['originalDataArrayLengths'][requestItemDataKey] = requestItemData.length;
                }
            });
        });
    
        // Need to go through all the fields in this requestItemType and generate columnDefs for DT - it will need to be rendered based on the field's dataTypeId
        let columnDefsSettingsArray = [];
        var thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
        var fieldsList = thisRequestItemType['fields'].filter(x => x.userId == null || x.userId == globalUserInfo.userId || x.userId == "");
        fieldsList = fieldsList.filter(x => x.groupId == null || x.groupId == "" || window.globalUserInfo.userGroups.indexOf(x.groupId) > 0);
        console.log(fieldsList);

        var fieldIdSet = new Set(fieldsList.map(x => x.requestTypeFieldId));
        var fieldIds = [...fieldIdSet];

        var additionalCols = 0;
        //frozen columns 
        if (["makeNewRequest", "repeatRequest"].includes(CurrentPageMode))// add an aditinal frozen column for new requests/ cust experements 
        {
            additionalCols = 1;
        }
        else if (["manageRequests", "editRequests"].includes(CurrentPageMode))// add 2 aditinal columns for manage requests
        {
            additionalCols = 2;
        }

        thisRequestItemType['frozenColumnsLeftuse'] = getNumOfAdditionalCols() + thisRequestItemType["frozenColumnsLeft"];

        let sortColumnDefSetting = {
            "targets": 'sortOrder',
            "visible": true,
            "className": "sortOrder"
        }
        columnDefsSettingsArray.push(sortColumnDefSetting)

        let nameColumnDefSetting = {
            "targets": 'requestItemName',
            "visible": true,
            "className": "requestItemName"
        }
        columnDefsSettingsArray.push(nameColumnDefSetting)

        $.each(fieldIds, function (fieldIndex, id) {
            var fields = fieldsList.filter(x => x.requestTypeFieldId == id);
            var requestItemTypeField = fields.find(x => x.userId == globalUserInfo.userId);

            if (requestItemTypeField === undefined) {
                requestItemTypeField = fields.find(x => globalUserInfo.userGroups.indexOf(x.groupId) >= 0);
                if (requestItemTypeField === undefined) {
                    requestItemTypeField = fields.find(x => x.groupId == null || x.groupId == "");
                }
            }

            var savedField = versionedFields.find(x => x.id == requestItemTypeField["savedFieldId"]);
            if (requestItemTypeField['disabled'] == 1 || (requestItemTypeField.restrictAccess == 1 && requestItemTypeField.canView == 0)) {//skip over disabled columns 
                fieldIndexOffset -= 1;
            } else {
                fieldColumnDefSetting = makeFieldColumnSettings(savedField, fieldIndex, fieldIndexOffset, requestItemTypeField, isOldRevision, canWrite);
                columnDefsSettingsArray.push(fieldColumnDefSetting);
            }
        });
    
        pageLength = 25;
        rowReorder = {
            dataSrc: 'sortOrder',
            update: true,
            selector: 'td:first-child .requestItemDragToReorder'
        }
    
        if (thisRequestItemType) {
            
            let requestItemTable = $(`${tableSelectorString} table.requestItemEditorTable[requestitemtypeid='${requestItemTypeId}']`).DataTable({
                "data": tableData['data'],
                "columns": tableData['columns'],
                "columnDefs": columnDefsSettingsArray,
                "order": [0, 'asc'],
                "pageLength": pageLength,
                "searching": false,
                "autoWidth": false,
                "bAutoWidth": false,
                "drawCallback": function (settings) {
                    dataTableDrawCallback.call(this, requestItemTypeId, thisRequestType, canWrite, tableSelectorString ,versionedRequestItems, versionedFields)
                },
                "scrollY": 300,
                "scrollX": true,
                "rowReorder": rowReorder,
                fixedColumns: {
                    leftColumns: thisRequestItemType['frozenColumnsLeftuse']
                }
            });
    
            // Loading should be finished by now so it's safe to do this, but on Duplicate Request page,
            // one of the modals is improperly hidden, hiding whatever modal it is but leaving the backdrop visible
            if (window.duplicatingRequest) {
                $('.modal-backdrop').remove();
            }
    
            SDF = null;
            allReqItemTbls.push(requestItemTable);
    
            clearTimeout(drawTimeout);
            drawTimeout = setTimeout(function () {
    
                $.each(allReqItemTbls, function () {
                    this.draw();
                });
                
                var winPos = $('.main-panel').scrollTop();
                var winPos2 = $('#requestEditorModal > .modal-dialog > .modal-content').scrollTop();
                var topPos = $(window.top).scrollTop();
                $('.main-panel').scrollTop(winPos);
                $('#requestEditorModal > .modal-dialog > .modal-content').scrollTop(winPos2);
                $(window.top).scrollTop(topPos);
                allReqItemTbls = [];
            }, 500);
    
            $('.dataTableCellTextarea').resize(function () {
                console.log('size');
            });

            requestItemTable.on('row-reorder', function (e, diff, edit) {
                console.log('The rows to be saved: ' + diff);
                utilities().showUnsavedChangesNotification();
                setTimeout(function () { SaveTable(e.target); }, 500);
            });

            requestItemTable.on("order.dt", function() {
                if (isDefaultSort(requestItemTable.order())) {
                    $(".requestItemDragToReorder").show();
                    //$(".submitButton").show();
                } else {
                    $(".requestItemDragToReorder").hide();
                    //$(".submitButton").hide();
                }
            })

            utilities().resizeManageRequestsTable().then(function () {
            });
    
            // Find the tableId so we can apply defaults and the dependencies.
            var requestItemTableId = $($(tableSelectorString + 'table.requestItemEditorTable[requestitemtypeid="' + requestItemTypeId + '"]')[1]).attr("id")
            $.each(requestItemTable.rows().toArray(), function (rowIndex, rowCount) {
                
                // Always run the dependency check.
                requestItemTableHelpers().applyItemDependencies(requestItemTableId, rowIndex, versionedRequestItems, versionedFields);

                // Then if we're in a new request, set default values, then check dependencies again.
                // This ensures that there are no values that are set mistakenly.
                if (CurrentPageMode == "makeNewRequest" || CurrentPageMode == "repeatRequest") {
                    requestItemTableHelpers().setDefaultItemFieldValues(requestItemTableId, rowIndex, versionedRequestItems).then(function () {
                        requestItemTableHelpers().applyItemDependencies(requestItemTableId, rowIndex, versionedRequestItems, versionedFields);
                    });
                }
            });
        
        }
    
        utilities().addResumableToItem(versionedRequestItems, versionedFields);
        
        $("body").off("click", ".copyRequestItemButton");
        $("body").on("click", ".copyRequestItemButton", function (event) {
            copyPasteRow(event, this, versionedRequestItems, versionedFields);
        });

        $("body").off("click", "button.generateCSV");
        $("body").on("click", "button.generateCSV", function (event) {
            var csv = makeCSV($(this).attr("tableid"), versionedRequestItems, versionedFields);
    
            if (!csv) {
                window.parent.swal("No data could be found!");
            }
        });        

        $('body').off('click', '.generateSDF');
        $('body').on('click', '.generateSDF', function (e) {
            makeSDF($(e.target).attr('tableId'), versionedRequestItems, versionedFields);
        });

        $('body').off('click', 'button.addRequestItem');
        $('body').on('click', 'button.addRequestItem', function (event) {
            addRequestItemRow($(event.target).attr("tableid"), versionedRequestItems, versionedFields);
        });

        $('body').off('click', '.removeRequestItemButton');
        $('body').on('click', '.removeRequestItemButton', function (event) {
            deleteRow(this);
        });

        $('body').off('change', 'select.dataTableCellDropdown, input.dataTableCellTextInput, textarea.dataTableCellTextarea, input.dataTableCellDateInput:not(.avoidTriggeringChangeListener)');
        $('body').on('change', 'select.dataTableCellDropdown, input.dataTableCellTextInput, textarea.dataTableCellTextarea, input.dataTableCellDateInput:not(.avoidTriggeringChangeListener)', function (event) {
            var inputType = $(this).prop("nodeName");
            updateRequestItemsTableDataAndRedraw(this, versionedRequestItems, versionedFields)
            .then(function (obj) {
                // Force a redraw here for the dependency stuff if we edited a select.

                if (inputType.toLowerCase() == "select") {
                    $(`#${obj}`).DataTable().draw(false);
                }
            });
        });

        $('body').off('click', 'button.dataTableCellSmallButton_add');
        $('body').on('click', 'button.dataTableCellSmallButton_add', function (event) {
            requestItemField_add($(this), versionedRequestItems, versionedFields, userClick = true);
            utilities().showUnsavedChangesNotification();
        });
    
        $('body').off('click', 'button.dataTableCellSmallButton_remove');
        $('body').on('click', 'button.dataTableCellSmallButton_remove', function (event) {
            requestItemField_remove($(this), versionedRequestItems, versionedFields, userClick = true);
            utilities().showUnsavedChangesNotification();
        });


    }//end initRequestItemTable()

    /**
     * Helper function to get the number of additional frozen columns needed for a table.
     */
    var getNumOfAdditionalCols = function() {
        var additionalCols = 0;
        //frozen columns 
        if (["makeNewRequest", "repeatRequest", "custExp"].includes(CurrentPageMode))// add an additional frozen column for new requests/ cust experements 
        {
            additionalCols = 1;
        }
        else if (["manageRequests", "editRequests"].includes(CurrentPageMode))// add 2 additional columns for manage requests
        {
            additionalCols = 2;
        }

        return additionalCols;
    }
    
    var SaveTable =function(table, structureOnly = false) {
        utilities().showUnsavedChangesNotification();

        var tableId = $(table).attr("id");
        var $table = $(`#${tableId}`).DataTable();

        var tableDraft = {
            "theKey": tableId,
            "theVal": JSON.stringify($table.rows().data().toArray())
        };

        if (window.self != window.parent) {
            window.parent.saveRow(`[${JSON.stringify(tableDraft)}]`).then(() => console.log("RowSave"));
        }
    }
    
    var updateRequestItemsTableDataAndRedraw = function(inputElement, versionedRequestItems, versionedFields, skipRedraw = false) {
        return new Promise(function (resolve, reject) {
            var theTableElement = $(inputElement).closest('table.requestItemEditorTable');

            // Hacky way of figuring out this table ID which is really only used for dropdown dependencies.
            var requestItemEditorInParent = $(inputElement).parents(".requestItemEditorTable");
            var tableId = "";
            
            if (requestItemEditorInParent.length > 0) {
                tableId = requestItemEditorInParent.attr("aria-describedby").split("_info")[0];
            }

            //this is for things in fixed columns ---> normalise table refrence
            var redrawRef = $($(`[requestitemtypefieldid='${$(inputElement).parent().attr('requestitemtypefieldid')}']`)[0]).closest('table.requestItemEditorTable');
            var thisTableRow = $(inputElement).closest('tr');
            var thisTableCell = $(inputElement).closest('td');
            var thisTableCellDiv = $(inputElement).closest('div');
            var thisTableCellDataTypeId = parseInt(thisTableCellDiv.attr('datatypeid'));
            
            thisTableCell.attr("dirty", true);
    
            var valuesArray = []
            if ([dataTypeEnums.TEXT, dataTypeEnums.STRUCTURE].includes(thisTableCellDataTypeId)) { // Text, Structure
                textInputs = thisTableCellDiv.find('input[type="text"]');
                if (textInputs.length > 0) {
                    $.each(textInputs, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(thisValue);
                    });
                }
            }
            else if (thisTableCellDataTypeId == dataTypeEnums.LONG_TEXT) { // Long Text
                textareas = thisTableCellDiv.find('textarea');
                if (textareas.length > 0) {
                    $.each(textareas, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(thisValue);
                    });
                }
            }
            else if ([dataTypeEnums.INTEGER, dataTypeEnums.REAL_NUMBER].includes(thisTableCellDataTypeId)) { // Integer, Real Number
                textInputs = thisTableCellDiv.find('input[type="number"]');
                if (textInputs.length > 0) {
                    $.each(textInputs, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(thisValue); // Purposely not converting to int/float here - handled server-side
                    });
                }
            }
            else if (thisTableCellDataTypeId == dataTypeEnums.DROP_DOWN) { // Dropdown
                dropdowns = thisTableCellDiv.find('select');
                if (dropdowns.length > 0) {
                    $.each(dropdowns, function () {
                        thisValue = $(this).val();
                        if (thisValue == "" || isNaN(thisValue)) {
                            thisValue = null;
                        }
                        valuesArray.push(parseInt(thisValue));
                    });
                }
            }
            else if (thisTableCellDataTypeId == dataTypeEnums.FILE_ATTACHMENT) { // File Attachment
                fileAttachmentForms = thisTableCellDiv.find('form.requestItemFieldFileAttachmentForm');
                if (fileAttachmentForms.length > 0) {
                    $.each(fileAttachmentForms, function () {
                        var thisFileId = $(this).attr("fileId");
                        var thisFileName = $(this).attr("fileName");
                        console.log(thisFileId);
                        if (typeof thisFileId !== "undefined") {
                            var thisFile = {
                                id: thisFileId,
                                name: thisFileName,
                            };
                            valuesArray.push(thisFile);
                        }
                    });
                }
            }
            else if (thisTableCellDataTypeId == dataTypeEnums.DATE) { // Date
                textInputs = thisTableCellDiv.find('input[type="text"]');
                if (textInputs.length > 0) {
                    $.each(textInputs, function () {
                        thisValue = $(this).val();
                        var thisValueMoment = moment.utc(thisValue, "MM/DD/YYYY");
                        if (thisValue == "" || !thisValueMoment.isValid()) {
                            thisValue = null;
                        }
                        else {
                            thisValue = thisValueMoment.unix()
                        }
                        console.log(thisValue)
                        valuesArray.push(thisValue); // Get the date text and turn it into GMT/UTC timestamp
                    });
                }
            }
            else if (thisTableCellDataTypeId == dataTypeEnums.RICH_TEXT) {
                textareas = thisTableCellDiv.find('textarea');
                if (textareas.length > 0) {
                    $.each(textareas, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(thisValue);
                    });
                }
            }
            else if ([dataTypeEnums.NOTEBOOK, dataTypeEnums.PROJECT, dataTypeEnums.EXPERIMENT].includes(thisTableCellDataTypeId)) {
                inputs = thisTableCellDiv.find('input.initItem');
                if (inputs.length > 0) {
                    $.each(inputs, function () {
    
                        if ($(this).attr('initialized') != "true") {
                            thisValue = { "id": -1, "text": "" };
                            if (thisTableCellDataTypeId == 15) {
                                thisValue['index'] = "";
                            }
                        }
                        else {
                            thisValue = $(this).select2('data');
                        }
    
                        valuesArray.push(JSON.stringify(thisValue));
                    });
                }
            } else if ([dataTypeEnums.REGISTRATION, dataTypeEnums.FOREIGN_LINK].includes(thisTableCellDataTypeId)) {
                inputs = thisTableCellDiv.find("a");
                $.each(inputs, function(inputIndex, input) {
                    thisValue = $(input).val();
                    valuesArray.push(thisValue);
                });
            }else if (thisTableCellDataTypeId == dataTypeEnums.REQUEST) {
                inputs = thisTableCellDiv.find("a");
                $.each(inputs, function(inputIndex, input) {
                    var valObj = {}
                    valObj[$(input).attr("reqID")] = $(input).text();
                    valuesArray.push(valObj);
                });
            }
            else { // CATCH-ALL
                textInputs = thisTableCellDiv.find('input[type="text"]');
                if (textInputs.length > 0) {
                    $.each(textInputs, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(thisValue);
                    });
                }
            }
            
            var theCellData = {
                dirty: true,
                data: valuesArray
            };

            thisTableCell.attr("dirty", true);

            var theCell = redrawRef.DataTable().cell(thisTableCell);
            try {    
                theCell.data(theCellData);
            }
            catch (er) // this is just to make sure the function keeps going on error
            {
                
            }
    
            /*
            if (valuesArray.length > 1) {
                $.each(valuesArray, function (ind, val) {
                    if (val == null) {
                        valuesArray[ind] = "|||||";
                    }
                });
            }
            */
    
    
            if (theTableElement[0] == undefined) {
                return (false);
            }
    
            //var cellIndex = theCell.index();
            var Rows = theTableElement[0].rows;
            var rowIndex = $(Rows).index(thisTableRow);
            var colls = theTableElement[0].rows[rowIndex].cells;
            var collsIndex = $(colls).index(thisTableCell);
            rowIndex -= 1;
    
    
            dataObj = {};
            //dataObj['row'] = cellIndex['row'];
            dataObj['row'] = rowIndex;
            dataObj['column'] = collsIndex;
            dataObj['valuesArray'] = theCellData;
            dataObj['dataTypeId'] = thisTableCellDataTypeId;
    
            console.log(rowIndex, collsIndex);
    
            if (!skipRedraw) {
                redrawRef.DataTable().draw(false);
            }
    
            if (thisTableCellDataTypeId == dataTypeEnums.DROP_DOWN) {
    
                // Make sure the dependencies stay applied for this cell - This event handler wipes
                // the existing event listeners so it needs to be reapplied.
                requestItemTableHelpers().applyItemDependencies(tableId, rowIndex, versionedRequestItems, versionedFields);
            }
    
            if (window.self != window.top) {
                //window.parent.sendAutoSave(theTableElement.attr('id') + "_" + cellIndex['row'] + "_" + cellIndex['column'], JSON.stringify(dataObj));
                window.parent.sendAutoSave(`${theTableElement.attr('id')}_${rowIndex}_${collsIndex}`, JSON.stringify(dataObj))
                    .then(function (obj) {
                        console.log("save requested")
    
                        resolve(tableId);
                    });
            } else {
                resolve(tableId);
            }
        });
    }
    
    /**
     * Converts saved request item data into a format that DataTables can use.
     * @param {JSON} request The request data, fetched from the server.
     * @param {JSON} thisRequestType The request type config info.
     * @param {JSON[]} versionedRequestItems The list of request item configs for this request.
     * @param {JSON[]} versionedFields The list of field configs.
     */
    var convertSavedRequestDataForDT = function(request, thisRequestType, versionedRequestItems, versionedFields) {
        return new Promise(async function(resolve, reject) {
            requestItemTypesWithData = {}
        
            $.each(request['requestItems'], function (requestItemIndex, requestItem) {
                if (!(requestItem['requestTypeRequestItemTypeId'].toString() in requestItemTypesWithData)) {
                    requestItemTypesWithData[requestItem['requestTypeRequestItemTypeId'].toString()] = []
                }
                requestItemTypesWithData[requestItem['requestTypeRequestItemTypeId'].toString()].push(requestItem);
            });
        
            var requestItemPromiseArray = thisRequestType.requestItemTypes.map(
                requestItem => convertRequestItemForDt(request, requestItem.requestItemTypeId, requestItem.requestItemId, thisRequestType, versionedRequestItems, versionedFields)
            );
            
            await Promise.all(requestItemPromiseArray);
            resolve();
        });
    }

    /**
     * Helper function for convertSavedRequestDataForDT that operates on one item table at a time so the whole
     * process can be promisized and that function can resolve after all of these tables have populated.
     * @param {JSON} request The request data, fetched from the server.
     * @param {number} requestItemTypeId The request item type ID of the request item we want to convert.
     * @param {number} requestItemId The request item ID of the request item we want to convert.
     * @param {JSON} thisRequestType The request type config info.
     * @param {JSON[]} versionedRequestItems The list of request item configs for this request.
     * @param {JSON[]} versionedFields The list of field configs.
     */
    var convertRequestItemForDt = function(request, requestItemTypeId, requestItemId, thisRequestType, versionedRequestItems, versionedFields) {
        return new Promise(async function(resolve, reject) {
            let columnsArray = makeColumnsArray(requestItemTypeId, versionedRequestItems, versionedFields);
    
            let rowPromiseArray = [];

            if (requestItemId in requestItemTypesWithData) {
                rowPromiseArray = requestItemTypesWithData[requestItemId].map(requestItem => requestItemFieldRowPromiseHelper(requestItem, requestItemTypeId, columnsArray, versionedRequestItems));
            }
            
            let rowsArray = await Promise.all(rowPromiseArray);
            let tableData = {
                "data": rowsArray,
                "columns": columnsArray,
            };
    
            let selectorString = "";
            if ($('.duplicateRequestEditor').length > 0) {
                selectorString = `.dropdownEditorContainer[requestid='${request['id']}']`;
            }
            initRequestItemTable(
                tableData,
                requestItemTypeId,
                selectorString,
                thisRequestType,
                versionedRequestItems,
                versionedFields
            );
            resolve();
        });
    }

    /**
     * Helper function to process request item rows.
     * @param {JSON} requestItem The saved data for the current request item.
     * @param {number} requestItemTypeId The ID of the request item type.
     * @param {JSON[]} columnsArray The array of columns for this table.
     * @param {JSON[]} versionedRequestItems The list of request item config data.
     */
    var requestItemFieldRowPromiseHelper = async function(requestItem, requestItemTypeId, columnsArray, versionedRequestItems) {
        return new Promise(async function(resolve, reject) {

            // Build a row for each requestItem
            var thisRow = {
                "requestItemId": requestItem["id"],
                "sortOrder": requestItem["sortOrder"],
                "requestItemName": requestItem["requestItemName"] ? requestItem["requestItemName"] : "",
            };
            
            let colPromiseArray = columnsArray.map(column => requestItemFieldColumnPromiseHelper(column, thisRow, requestItem, requestItemTypeId, versionedRequestItems));

            await Promise.all(colPromiseArray);
            resolve(thisRow);
        })
    }

    /**
     * Helper function to process columns for each request item row.
     * @param {JSON} column The column config data.
     * @param {JSON} thisRow The row data being built up.
     * @param {JSON} requestItem The saved data for the current request item.
     * @param {number} requestItemTypeId The ID of the request item type.
     * @param {JSON[]} versionedRequestItems The list of request item config data.
     */
    var requestItemFieldColumnPromiseHelper = async function(column, thisRow, requestItem, requestItemTypeId, versionedRequestItems) {
        return new Promise(async function(resolve, reject) {
                
            var thisSavedField = column['savedField'];
            if (!thisSavedField) {
                resolve();
                return;
            }
            
            let thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
            
            let requestItemField = requestItem["requestItemFields"].find(
                x => utilities().requestTypeFieldIdToFieldId(thisRequestItemType["fields"], x["requestItemTypeFieldId"]) == thisSavedField["id"]
            );
            if (!requestItemField) {
                resolve();
                return;
            }
            if ([
                dataTypeEnums.TEXT,
                dataTypeEnums.LONG_TEXT,
                dataTypeEnums.REGISTRATION,
                dataTypeEnums.FOREIGN_LINK,
                dataTypeEnums.UNIQUE_ID,
            ].includes(thisSavedField['dataTypeId'])) {
                valKey = "textValue";
            }
            else if ([
                dataTypeEnums.INTEGER,
                dataTypeEnums.NOTEBOOK,
                dataTypeEnums.PROJECT,
                dataTypeEnums.EXPERIMENT
            ].includes(thisSavedField['dataTypeId'])) {
                valKey = "intValue";
            }
            else if (thisSavedField['dataTypeId'] == dataTypeEnums.REAL_NUMBER) {
                valKey = "realValue";
            }
            else if (thisSavedField['dataTypeId'] == dataTypeEnums.DROP_DOWN) {
                valKey = "dropDownValue";
            }
            else if (thisSavedField['dataTypeId'] == dataTypeEnums.FILE_ATTACHMENT) {
                valKey = "fileId";
            }
            else if (thisSavedField['dataTypeId'] == dataTypeEnums.DATE) {
                valKey = "dateValue";
            }
            else if (thisSavedField['dataTypeId'] == dataTypeEnums.STRUCTURE) { // Structure
                valKey = "structureDiagram";
            }

            let valPromiseArray = requestItemField["requestItemFieldValues"].map(fieldValues => 
                requestItemFieldCellPromiseHelper(fieldValues, thisSavedField, valKey)
            );
            
            let valuesArray = await Promise.all(valPromiseArray);
            var rowData = {
                dirty: false,
                data: column.clearWhenDuplicate && window.CurrentPageMode == "repeatRequest"? [] : valuesArray
            };

            thisRow[requestItemField.requestItemTypeFieldId] = rowData;
            resolve();                        
        });
    }

    /**
     * Helper function to process cells for each request item row.
     * @param {JSON} fieldValues The object carrying the values for this request item cell.
     * @param {JSON} thisSavedField The field config data.
     * @param {string} valKey The key that the value for this cell is being stored under in fieldValues.
     */
    var requestItemFieldCellPromiseHelper = async function(fieldValues, thisSavedField, valKey) {
        return new Promise(async function(resolve, reject) {
    
            let pushValPromise = new Promise(async function(resolve, reject) {
                let thisVal = fieldValues[valKey];
                if ([dataTypeEnums.NOTEBOOK, dataTypeEnums.PROJECT, dataTypeEnums.EXPERIMENT].includes(thisSavedField['dataTypeId'])) {
                    let appEnum = 0;
                    if (thisSavedField["dataTypeId"] == dataTypeEnums.NOTEBOOK) {
                        appEnum = applicationEnum.NOTEBOOK;
                    }
                    if (thisSavedField["dataTypeId"] == dataTypeEnums.PROJECT) {
                        appEnum = applicationEnum.PROJECT;
                    }
                    if (thisSavedField["dataTypeId"] == dataTypeEnums.EXPERIMENT) {
                        appEnum = applicationEnum.EXPERIMENT;
                    }
                    if (thisVal == 0) {
                        resolve(null);
                    }
                    const linkList = await fieldsModule().getLinkDataForField(thisVal, appEnum);
                    linkList.forEach((link) => {
                        thisVal = {"id": link["linkId"], "text": link["linkName"]};

                        if (thisSavedField['dataTypeId'] == dataTypeEnums.EXPERIMENT){
                            thisVal["index"] = link['abr'];
                        }

                        thisVal = JSON.stringify(thisVal);
                        fieldValues[valKey] = thisVal;
                        resolve(thisVal);
                    });

                    if (window.top.linkData && window.top.linkData.length > 0) {
                        var link = window.top.linkData.find(x => x.linkId == fieldValues['intValue']);
                        if (link){
                            thisVal = { "id": link['objectId'], 'text': link['linkName'] };

                            if (thisSavedField['dataTypeId'] == dataTypeEnums.EXPERIMENT){
                                thisVal["index"] = link['abr'];
                            }

                            thisVal = JSON.stringify(thisVal);
                            fieldValues[valKey] = thisVal;
                        }
                        else {
                            thisVal = JSON.stringify({});
                        }
                        resolve(thisVal);
                    }
                    
                }
                else if (thisSavedField["dataTypeId"] == dataTypeEnums.FILE_ATTACHMENT) {
                    resolve({id: thisVal, name: fieldValues["fileName"]});
                }
                else {
                    resolve(thisVal);
                }
            });

            let pushVal = await pushValPromise;
            resolve(pushVal);
            return;
        });
    }
    
    var requestItemField_add = function(buttonElement, versionedRequestItems, versionedFields, userClick = false) {
        var fieldDiv = $(buttonElement).parent();
        dataTypeId = parseInt(fieldDiv.attr('datatypeid'));
        allowMultiple = parseInt(fieldDiv.attr('allowmultiple'));
        var requestItemRow = fieldDiv.closest('tr');
        if (allowMultiple) { // Multiple values are allowed
            if (userClick && typeof fieldDiv.attr('fieldgroup') !== "undefined" && fieldDiv.attr('fieldgroup') !== "") {
                var fieldGroup = parseInt(fieldDiv.attr('fieldgroup'));
                var fieldMissingAllowMultiple = false;
                var fieldMissingCanAdd = false;
                // Loop through fields of this tr in the same field group
                $.each(requestItemRow.children('td').children('div[fieldgroup="' + fieldGroup + '"]'), function () {
                    // Make sure each field has allowmultiple="1" and doesn't have .noCanAdd
                    if ($(this).attr('allowmultiple') != "1") {
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
                    // All fields in this group qualify for new values - add a value to each
                    $.each(requestItemRow.children('td').children(`div[fieldgroup="${fieldGroup}"]`), function () {
                        requestItemField_add($(this).find('.dataTableCellSmallButton_add'), versionedRequestItems, versionedFields, userClick = false);
                    });
                }
            }
            else {
                if (dataTypeId == 1 || dataTypeId == 8) { // Text, Structure
                    inputElement = $('<input type="text" class="dataTableCellTextInput">');
                    fieldDiv.find('input[type="text"]:last-of-type').after(inputElement);
                }
                else if (dataTypeId == 2) { // Long Text
                    textareaElement = $('<textarea class="dataTableCellTextarea">');
                    fieldDiv.find('textarea:last-of-type').after(textareaElement);
                }
                else if (dataTypeId == dataTypeEnums.INTEGER) {
                    inputElement = fieldsModule().requestItemTypeIntGenerator("");
                    fieldDiv.find("input[type='number']:last-of-type").after(inputElement);
                }
                else if (dataTypeId == dataTypeEnums.REAL_NUMBER) {
                    inputElement = fieldsModule().requestItemTypeNumberGenerator("");
                    fieldDiv.find("input[type='number']:last-of-type").after(inputElement);
                }
                else if (dataTypeId == 5) { // Dropdown
                    clonedDropdown = fieldDiv.find('select.dataTableCellDropdown:last-of-type').clone();
                    clonedDropdown.find('option:first-of-type').prop('selected', true);
                    fieldDiv.find('select:last-of-type').after(clonedDropdown);
                    buttonElement.blur();
                }
                else if (dataTypeId == 6) { // File Attachment
                    inputElement = fieldDiv.find('form.requestItemFieldFileAttachmentForm:last-of-type').clone();
                    inputElement.find('.currentFileLink').empty();
                    inputElement.attr('fileid', -1);
                    fieldDiv.find('form.requestItemFieldFileAttachmentForm:last-of-type').after(inputElement);
                }
                else if (dataTypeId == 7) { // Date
                    inputElement = $('<input type="text" class="dataTableCellDateInput">');
                    pikadaySettingsObject = {
                        firstDay: 1,
                        minDate: new Date(1990, 0, 1),
                        maxDate: new Date(2040, 12, 31),
                        yearRange: [1990, 2040],
                        format: 'MM/DD/YYYY'
                    }
                    $(inputElement).pikaday(pikadaySettingsObject);
                    fieldDiv.find('input[type="text"]:last-of-type').after(inputElement);
                }
                else if (dataTypeId == 13 || dataTypeId == 14 || dataTypeId == 15) {
                    inputElement = fieldDiv.find('input.initItem')[0].outerHTML;
                    $(inputElement).attr('initialized', false);
                    $(fieldDiv.find('input.initItem:last-of-type')[0]).after(inputElement);
                }
    
                // The _remove button might need to be shown - evaluate .attr('originaldataarraylength') vs. the number of input elements...
                if (fieldDiv.attr('originaldataarraylength') && parseInt(fieldDiv.attr('originaldataarraylength')) !== 0) {
                    var currentNumberOfValues = fieldDiv.find('input[type="text"], textarea, select, form.requestItemFieldFileAttachmentForm').length;
                    if (currentNumberOfValues > parseInt(fieldDiv.attr('originaldataarraylength'))) {
                        fieldDiv.addClass('hasNewlyAddedValues');
                    }
                }
            }
        }
        updateRequestItemsTableDataAndRedraw(buttonElement, versionedRequestItems, versionedFields)
    }

    var requestItemField_remove = function(buttonElement, versionedRequestItems, versionedFields, userClick = false) {
        var fieldDiv = buttonElement.parent();
        dataTypeId = parseInt(fieldDiv.attr('datatypeid'));
        allowMultiple = parseInt(fieldDiv.attr('allowmultiple'));
        var requestItemRow = fieldDiv.closest('tr');
        if (allowMultiple) { // Multiple values are allowed
            if (userClick && typeof fieldDiv.attr('fieldgroup') !== "undefined" && fieldDiv.attr('fieldgroup') !== "") {
                var fieldGroup = parseInt(fieldDiv.attr('fieldgroup'));
                var fieldMissingAllowMultiple = false;
                var fieldMissingCanDelete = false;
                var newRequest = ["makeNewRequest", "repeatRequest"].includes(CurrentPageMode);

                var theTableElement = fieldDiv.closest('table.requestItemEditorTable');
                // Loop through fields of this tr in the same field group
                $.each(requestItemRow.children('td').children('div[fieldgroup="' + fieldGroup + '"]'), function () {
                    // Make sure each field has allowmultiple="1" and doesn't have .noCanAdd
                    if ($(this).attr('allowmultiple') !== "1") {
                        fieldMissingAllowMultiple = true;
                    }
                    if ($(this).hasClass('noCanDelete') && !$(this).hasClass('hasNewlyAddedValues')) {
                        fieldMissingCanDelete = true;
                    }
                });
    
                if ((fieldMissingAllowMultiple || fieldMissingCanDelete) && !newRequest) {
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
                    $.each(requestItemRow.children('td').children('div[fieldgroup="' + fieldGroup + '"]'), function () {
                        requestItemField_remove($(this).find('.dataTableCellSmallButton_remove'), versionedRequestItems, versionedFields, userClick = false);
                    });
                }
                theTableElement.DataTable().draw(false);
            }
            else {
                if ([dataTypeEnums.TEXT, dataTypeEnums.STRUCTURE].includes(dataTypeId)) {
                    fieldDiv.find('input[type="text"]:last-of-type').remove();
                }
                else if (dataTypeId == dataTypeEnums.LONG_TEXT) {
                    fieldDiv.find('textarea:last-of-type').remove();
                }
                else if (dataTypeId == dataTypeEnums.INTEGER) {
                    fieldDiv.find("input[type='number']:last-of-type").remove();
                }
                else if (dataTypeId == dataTypeEnums.REAL_NUMBER) {
                    fieldDiv.find("input[type='number']:last-of-type").remove();
                }
                else if (dataTypeId == dataTypeEnums.DROP_DOWN) {
                    fieldDiv.find('select:last-of-type').remove();
                }
                else if (dataTypeId == dataTypeEnums.FILE_ATTACHMENT) {
                    fieldDiv.find('form.requestItemFieldFileAttachmentForm:last-of-type').remove();
                }
                else if (dataTypeId == dataTypeEnums.DATE) {
                    fieldDiv.find('input[type="text"]:last-of-type').remove();
                }
                else if ([dataTypeEnums.NOTEBOOK, dataTypeEnums.PROJECT, dataTypeEnums.EXPERIMENT].includes(dataTypeId)) {
                    fieldDiv.find('input.initItem').last().remove()
                }
                updateRequestItemsTableDataAndRedraw(buttonElement, versionedRequestItems, versionedFields, skipRedraw = false)
                .then(function (obj) {
                });
            }
        }
        buttonElement.blur();
    }

    // Flag to wait for editor markup call completes before proceeding while adding a new row.
    var waitForEditorMarkup = false;
    var addRequestItemRow = function(tableId, versionedRequestItems, versionedFields) {

        // Set the global flag to true so the draw callback knows not to adjust for height.
        addingRow = true;
    
        var tableObj = tableId;
        var requestItemTypeId = $("#" + tableObj).attr("requestitemtypeid");
        var table = $("#" + tableObj).DataTable();
    
        var sortOrder = table.rows().count() == 0 ? 1 : table.rows(table.rows().count()-1).data()[0]['sortOrder'] + 1;
    
        var newRow = {
            "requestItemId": 0,
            "sortOrder": sortOrder,
            "requestItemName": ""
        }
    
        $.each(versionedRequestItems, function (requestItemTypeIndex, requestItemType) {
            if (requestItemType['id'] == requestItemTypeId) {
                var fields = requestItemType.fields;
    
                $.each(fields, function (fieldIndex, field) {
                    newRow[field.displayName] = {
                        dirty: true,
                        data: []
                    };
                });
    
                return false;
            }
        });

        table.row.add(newRow).draw(false);

        // Make sure that the Editor Markup function is completed before setting the field values.
        // Use a window interval here since I was unable to use async function/promise on table.row.add().
        var waitInterval = window.setInterval(function () {
            if (waitForEditorMarkup) 
                return;

            requestItemTableHelpers().setDefaultItemFieldValues(tableId, table.rows().count() - 1, versionedRequestItems, true).then(function () {
                requestItemTableHelpers().applyItemDependencies(tableId, table.rows().count() - 1, versionedRequestItems, versionedFields)
            });

            utilities().addResumableToItem(versionedRequestItems, versionedFields);

            var scrollBody = $(table.table().node()).parent();
            scrollBody.scrollTop(scrollBody.get(0).scrollHeight);

            if (table.rows().count() <= 5) {
                table.draw();
            }

            window.clearInterval(waitInterval);
        }, 50);
    }
    
    var copyRow = function(table, thisTable, rowOn, colCount, TypeKey, useDropdownNames, versionedRequestItems, versionedFields) {
        valuesArray = [];
        for (i = 1; i < colCount; i++) {
    
            //cell to mess with
            var cellInteract = table.rows[rowOn].cells[i];
            var UD = $(cellInteract).children().children()[0];
            var thisTableCellDiv = $(UD).closest('div');
            var thisTableCellDataTypeId = parseInt(thisTableCellDiv.attr('datatypeid'));
    
            if (isNaN(thisTableCellDataTypeId)) {
                if (i == 1 && window.parent == window.self) { //Assume the first column of an actual workflow request is a name?
                    thisTableCellDataTypeId = "Name";
                }
                if (thisTableCellDiv.hasClass("liveEditStructureHolder")) {
                    thisTableCellDataTypeId = 8;
                };
            }
    
            var requestItemTypeFieldId = thisTableCellDiv.attr("requestitemtypefieldid");
            // Hack to get the parent table's requestItemTypeId.
            var requestItemTypeId = $(table).closest("table").attr("requestitemtypeid")
            var requestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
            var fields = requestItemType.fieldsDict;
    
            TypeKey.push(thisTableCellDataTypeId);
    
            if (thisTableCellDataTypeId == 1) { // Text
                textInputs = thisTableCellDiv.find('input[type="text"]');
                if (textInputs.length > 0) {
                    var trackNum = 0
                    $.each(textInputs, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(trackNum + "," + i.toString() + "," + thisValue);
                        trackNum += 1;
                    });
                }
            }
            else if (thisTableCellDataTypeId == 2) { // Long Text
                textareas = thisTableCellDiv.find('textarea');
                if (textareas.length > 0) {
                    var trackNum = 0
                    $.each(textareas, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(trackNum + "," + i.toString() + "," + thisValue);
                        trackNum += 1;
                    });
                }
            }
            else if (thisTableCellDataTypeId == 3 || thisTableCellDataTypeId == 4) { // Integer, Real Number
                textInputs = thisTableCellDiv.find('input[type="number"]');
                if (textInputs.length > 0) {
                    var trackNum = 0
                    $.each(textInputs, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(trackNum + "," + i.toString() + "," + thisValue);
                        trackNum += 1; // Purposely not converting to int/float here - handled server-side
                    });
                }
            }
            else if (thisTableCellDataTypeId == 5) { // Dropdown
                dropdowns = thisTableCellDiv.find('select');
                if (dropdowns.length > 0) {
                    var trackNum = 0
                    $.each(dropdowns, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
    
                        if (useDropdownNames && thisValue !== null) {
                            var savedFieldId = fields[requestItemTypeFieldId][0].savedFieldId;
                            var savedFieldOptions = versionedFields.find(x => x.id == savedFieldId).options;
                            thisValue = savedFieldOptions.find(x => x.dropdownOptionId == thisValue).displayName;
                        }
    
                        valuesArray.push(trackNum + "," + i.toString() + "," + thisValue);
                        trackNum += 1;
                    });
                }
            }
            else if (thisTableCellDataTypeId == 6) { // File Attachment
             /*    fileAttachmentForms = thisTableCellDiv.find('form.requestItemFieldFileAttachmentForm');
                if (fileAttachmentForms.length > 0) {
                    var trackNum = 0
                    $.each(fileAttachmentForms, function () {
                        console.log($(this).attr('fileid'))
                        if (typeof $(this).attr('fileid') !== "undefined") {
                            valuesArray.push(trackNum + "," + i.toString() + "," + parseInt($(thisTable).attr('fileid')));
                            trackNum += 1;
                        }
                    });
                } */
                valuesArray.push("0" + "," + i.toString() + undefined);
            }
            else if (thisTableCellDataTypeId == 7) { // Date
                textInputs = thisTableCellDiv.find('input[type="text"]');
                if (textInputs.length > 0) {
                    var trackNum = 0
                    $.each(textInputs, function () {
                        thisValue = $(this).val();
                        /*   var thisValueMoment = moment.utc(thisValue, "MM/DD/YY");
                                if(thisValue == "" || !thisValueMoment.isValid()){
                                        thisValue = null;
                                }
                                else{
                                        thisValue = thisValueMoment.unix()
                                } */
                        console.log(thisValue)
                        valuesArray.push(trackNum + "," + i.toString() + "," + thisValue);
                        trackNum += 1; // Get the date text and turn it into GMT/UTC timestamp
                    });
                }
            }
            else if (thisTableCellDataTypeId == 8) { // Structure
                textInputs = thisTableCellDiv[0].children[0].children[1];
                var md = decodeURIComponent(thisTableCellDiv.find("a").attr("moldata"));
                valuesArray.push(0 + "," + i.toString() + "," + md);
            }
            else if (thisTableCellDataTypeId == 9) { // Long Text
                textareas = thisTableCellDiv.find('textarea');
                if (textareas.length > 0) {
                    var trackNum = 0
                    $.each(textareas, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(trackNum + "," + i.toString() + "," + thisValue);
                        trackNum += 1;
                    });
                }
            }
            else if (thisTableCellDataTypeId == "Name") { // Name
                thisValue = $(cellInteract).text();
                valuesArray.push(0 + "," + i.toString() + "," + thisValue);
            }
            else { // CATCH-ALL
                textInputs = thisTableCellDiv.find('input[type="text"]');
                if (textInputs.length > 0) {
                    var trackNum = 0
                    $.each(textInputs, function () {
                        thisValue = $(this).val();
                        if (thisValue == "") {
                            thisValue = null;
                        }
                        valuesArray.push(trackNum + "," + i.toString() + "," + thisValue);
                        trackNum += 1;
                    });
                }
            }
    
        }
        return valuesArray;
    }
    
    /**
     * Takes a request item type and returns an array of its columns, in sort order.
     * @param {*} requestItemType The request item type to make a column array from.
     */
    var getRequestItemColumns = function(requestItemType) {
        var fieldsDict = requestItemType.fieldsDict;
        var sortOrder = fieldsDict.sortOrder;
        sortOrder = sortOrder.filter(x => fieldsDict[x][0].disabled == 0);
        colNames = sortOrder.map(x => fieldsDict[x][0].displayName);
    
        if (colNames.includes("Name")) {
            colNames.splice(colNames.indexOf("Name"), 1);
        }
    
        return colNames;
    }

    /**
     * Makes a CSV from a request item table.
     * @param {string} tableId The ID of the table to pull data from.
     * @param {JSON[]} versionedRequestItems The versioned request item config info.
     * @param {JSON[]} versionedFields The versioned field config info.
     */
    var makeCSV = function(tableId, versionedRequestItems, versionedFields) {

        var requestItemId = tableId.split("requestItemTable")[1];
        var requestItemTypeId = $(".requestItemsEditor[requestitemid='" + requestItemId + "']").attr("requestitemtypeid");
        var requestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
    
        if (requestItemType === undefined) {
            return false;
        }

        var colNames = getRequestItemColumns(requestItemType);
        var formattedColNames = colNames.map(x => `"${x.trim()}"`).join(",");
        
        formattedColNames = `"Name",` + formattedColNames;
        colNames.unshift("requestItemName");

        var tableName = requestItemType.displayName;
    
        var tableData = $(`#${tableId}`).DataTable().rows().data().toArray();
        var tableArray = [];

        // Go through all of the rows and pull the data out in the format we want.
        $.each(tableData, function(rowIndex, row) {
            tableArray.push([]);
            
            $.each(colNames, function(colIndex, colName) {

                var cellData = [];
                if (colName == "requestItemName") {
                    cellData.push(row[colName]);
                } else {

                    var thisRequestItemField = requestItemType.fields.find(x => x.displayName == colName);
                    var cellData = row[thisRequestItemField.requestTypeFieldId];

                    if (!cellData) {
                        cellData = [""];
                    } else {
                        if (cellData["data"].length == 0) {
                            cellData["data"].push("");
                        }
                        cellData = cellData["data"];

                        if (thisRequestItemField.dataTypeId == dataTypeEnums.DROP_DOWN) {
                            var thisField = versionedFields.find(x => x.id == thisRequestItemField.savedFieldId);
                            var thisFieldOptions = thisField.options;
                            cellData = cellData.map(x => x ? thisFieldOptions.find(option => option.dropdownOptionId == x).displayName : "");
                        } else if ([dataTypeEnums.NOTEBOOK, dataTypeEnums.PROJECT, dataTypeEnums.EXPERIMENT].includes(thisRequestItemField.dataTypeId)) {
                            for (i = 0; i < cellData.length; ++i) {
                                var val = cellData[i];
                                if (utilities().hasJsonStructure(val)) {
                                    var valJson = JSON.parse(val);
                                    cellData[i] = valJson["text"];
                                }
                            }
                        }
                    }
                }

                // Make sure x is a valid value and normalize it if it isn't.
                cellData = cellData.map(x => x && (x != "undefined" || x != "null") ? x : "");
                tableArray[rowIndex].push(cellData);
            });
        });

        // Now go through all of those rows, pad each cell so they're uniform in length, then build the CSV rows.
        var csvData = "";
        $.each(tableArray, function(rowIndex, row) {
            var numSubCells = Math.max(...row.map(x => x.length));

            var paddedRow = [];
            $.each(row, function(cellIndex, cell) {

                // If this cell doesn't have as many subrows as the cell with the max subrows, then
                // pad it out with empty strings. Otherwise, we can just use the cell as is.
                if (cell.length < numSubCells) {
                    paddedRow.push(cell.concat([...Array(numSubCells - cell.length)].map(x => "")));
                } else {
                    paddedRow.push(cell);
                }
            });

            for (i = 0; i < numSubCells; ++i) {
                csvData += paddedRow.map(cell => `"${cell[i]}"`).join(",") + "\r\n";
            }
        });

        var csvContent = `${formattedColNames}\r\n${csvData}`;
    
        // Base 64 encode the CSV string so firefox doesn't have a heart attack for "#" characters.
        var blob = new Blob(["\uFEFF"+csvContent], { type: "text/html; charset=utf-8" });
    
        var link = document.createElement("a");
        link.setAttribute("href", window.URL.createObjectURL(blob, { type: "text/plain" }));
        link.setAttribute("download", tableName + ".csv");
        link.classList.add("csvdownload");
        link.style.visibility = "hidden";
        link.innerHTML = "Click Here to download";
        document.body.appendChild(link); // Required for FF
        link.click();
        document.body.removeChild(link);
    
        return true;
    }

    var makeSDF = function(tableId, versionedRequestItems, versionedFields)
    {
        return new Promise(function(resolve, reject) {

            if (!tableId)
            {
                reject(false);
            }
            else 
            {

                var $table = $("#" + tableId).children();
    
                var table = $table[1];
                var rowLength = table.rows.length;
                var typeKey = [];
            
                var valuesArr = [];
                var colCount = table.rows[0].cells.length;
            
                for (rowOn = 0; rowOn < rowLength; ++rowOn) {
                    valuesArr.push(copyRow(table, null, rowOn, colCount, typeKey, true, versionedRequestItems, versionedFields));
                }
            
                var tableArray = [];
                $.each(valuesArr, function (rowIndex, row) {
                    tableArray[rowIndex] = [];
            
                    $.each(row, function (cellIndex, cell) {
                        var splitCell = cell.split(",");
                        var subrow = splitCell.shift();
                        var col = parseInt(splitCell.shift()) - 1;
            
                        if (tableArray[rowIndex][0] === undefined) {
                            tableArray[rowIndex][0] = []
                        }
            
            
                        var rowVal = splitCell.join();
                     
                        if(tableArray[rowIndex][0][col] == undefined)
                        {
                            tableArray[rowIndex][0][col] = [rowVal];
                        }
                        else
                        {
                            tableArray[rowIndex][0][col].push(rowVal);
                        }
            
                    });
                });
            

                var itemFields = versionedRequestItems.find(x => x.id == parseInt( $(`#${tableId}`).attr('requestitemtypeid')))['fields'];
                itemFields = itemFields.filter(x => x.disabled == 0);

                var promArray = [];
                $.each(tableArray, function(index, item){
                    promArray.push(compileSDFRow(itemFields, item[0]));
                });
                Promise.all(promArray).then(function(response){

                    console.log(response);

                    var out = response.join("\n" + "$$$$" + "\n")

                    console.log(out);


                    var blob = new Blob([out], { type: "text/sdf" });
    
                    var link = document.createElement("a");
                    link.setAttribute("href", window.URL.createObjectURL(blob, { type: "text/plain" }));
                    link.setAttribute("download", tableId + ".sdf");
                    link.classList.add("csvdownload");
                    link.style.visibility = "hidden";
                    link.innerHTML = "Click Here to download";
                    document.body.appendChild(link); // Required for FF
                    link.click();
                    document.body.removeChild(link);



                });               
            }
        }); 
    }

    var compileSDFRow = function(itemFields, tableData)
    {
        return new Promise(function(resolve, reject) { 

            var linkedFields = itemFields.map( function(field, index){
                if (window.CurrentPageMode == "editRequests")
                {
                    field['value'] = tableData[index + 1];
                }
                else
                {
                    field['value'] = tableData[index];
                }
                return(field);
            });
            console.log(linkedFields);

            var prossesItems = linkedFields.filter(x => x.dataTypeId != 8);
            var structure = linkedFields.find(x => x.dataTypeId == 8)


            var fileFormat = getFileFormat(decodeURI(structure['value']));
            var jchemProxyLoc = window.location.origin + "/arxlab/_inclds/experiments/chem/asp/jchemProxy.asp?searchtype=util/calculate/molExport";
            var theData = {"structure": decodeURIComponent(structure['value']), "inputFormat": fileFormat, "parameters": "mol:V2"};
            $.ajax({
                method: "POST",
                dataType: "json",
                url: jchemProxyLoc,
                contentType: "application/json",
                data: JSON.stringify(theData),
                prossesItems: prossesItems

            }).done(function(response){
                console.log(response);

                var retVal = "";

                retVal = response['structure'];

                $.each(this.prossesItems, function(index, item){

                    retVal += ">  <" + item['displayName'] + ">" + "\r\n";
                    $.each(item['value'],function(ind, val){
                        if (val == null || val == 'null')
                        {
                            val = "";
                        }
                        retVal += val + "\r\n";
                    });
                });
                
                resolve(retVal);
            });
        });
    }

    /**
     * Creates an array of datatable column configs for datatables.
     * @param {number} requestItemId The ID of this request item.
     * @param {JSON[]} versionedRequestItems The list of request item configs for this request.
     * @param {JSON[]} versionedFields The list of field configs.
     */
    var makeColumnsArray = function(requestItemId, versionedRequestItems, versionedFields) {
        let columnsArray = [];
        columnsArray.push(priorityCol)
        if (ADD_NAME_COL) {
            columnsArray.push(NAME_COL);
        }
        
        var requestItemType = versionedRequestItems.find(x => x.id == requestItemId);

        if (requestItemType) {
            var fieldsList = requestItemType["fields"].filter(x => x.userId == null || x.userId == globalUserInfo.userId);
            fieldsList = fieldsList.filter(x => x.groupId === null || window.globalUserInfo.userGroups.indexOf(x.groupId) >= 0);
            fieldIdSet = new Set(fieldsList.map(x => x.requestTypeFieldId));
            fieldIds = [...fieldIdSet];

            $.each(fieldIds, function (index, id) {
                var fields = fieldsList.filter(x => x.requestTypeFieldId == id);
                var requestItemTypeField = fields.find(x => x.userId == globalUserInfo.userId);

                if (requestItemTypeField === undefined) {
                    requestItemTypeField = fields.find(x => globalUserInfo.userGroups.indexOf(x.groupId) >= 0);
                    if (requestItemTypeField === undefined) {
                        requestItemTypeField = fields.find(x => x.groupId == null);
                    }
                }

                // if the user cannot view the field... dont show it...
                if (requestItemTypeField.restrictAccess && !requestItemTypeField.canView) {
                    return;
                }

                var savedField = versionedFields.find(x => x.id == requestItemTypeField.savedFieldId);
                if (savedField) {
                    if (requestItemTypeField['disabled'] == 0) {
                        var thisSavedField = savedField;
                        console.log(requestItemTypeField)
                        var columnTitle = thisSavedField['displayName'];
                        if (requestItemTypeField['required']) {
                            columnTitle += "*";
                        }

                        var columnObject = {
                            "data": requestItemTypeField['requestTypeFieldId'],
                            "title": columnTitle,
                            "savedField": thisSavedField,
                            "requestItemTypeFieldId": requestItemTypeField['requestTypeFieldId']
                        }
                        if (requestItemType['restrictAccess'] == 1) {
                            columnObject['canEdit'] = requestItemType['canEdit'];
                            columnObject['canDelete'] = requestItemType['canDelete'];
                        }
                        columnObject["clearWhenDuplicate"] = requestItemTypeField['clearWhenDuplicate'];
                        // Add the column with DT-standard data & title, plus the savedFieldId which DT ignores but will help efficiently find this column while building rowsArray
                        columnsArray.push(columnObject);
                        console.log(columnObject);
                    }

                }
            });
        }
    
        return columnsArray;
    }
    
    var copyPasteRow = function(event, thisTable, versionedRequestItems, versionedFields) {


        $.ajax(
            {
                type: "POST",
                url: "cpRequest.asp",
                async: false,
                data: { "msg": "02" }
            })
            .done(function (response) {
                console.log(response)
    
                console.log("copybtn Request start:");
                var ID = $(thisTable).attr("id");
    
                var $tableId = "#" + $(thisTable).attr('tableid');
                var $table = $($tableId).children();
    
                var table = $table[1];
                var rowLength = table.rows.length;
                var rowOn;
    
    
                var canWrite = true;
                if (window.self != window.top) {
                    canWrite = window.parent.canWrite;
                }
    
                var btnIndex = canWrite ? 1 : 0;
    
                for (i = 0; i < rowLength; i++) {
                    var hold = $(table.rows[i].cells[0]).children()[btnIndex];// the [0] refrances the btns the [1] refrances the second btn
                    var comp = $(hold).attr("id");
                    if (comp == ID) {
                        rowOn = i;
                        break;
                    }
                }
                console.log("Row: " + rowOn + 1);
    
                var colCount = table.rows[rowOn].cells.length;
                var TypeKey = [];
    
                if (response != "" && canWrite) {
    
                    PasteRequest("02", rowOn, table)
    
                }
                else {
    
    
                    var valuesArray = copyRow(table, thisTable, rowOn, colCount, TypeKey, false, versionedRequestItems, versionedFields)
    
                    //all values from the table are now in the values array... turn that into csv string here: 
    
                    var parse = [];
                    var numOfSubRows = 0;
                    for (i = 0; i < valuesArray.length; i++) {
                        var splitting = valuesArray[i].split(',');
                        if (splitting[0] > numOfSubRows) {
                            numOfSubRows = splitting[0];
                        }
                    }
    
    
                    //the value array is set up as such: 
                    //the subrow, column, value 
    
                    for (i = 0; i <= numOfSubRows; i++) {
                        for (p = 1; p < colCount; p++) {
                            var setval = "null";
                            for (n = 0; n < valuesArray.length; n++) {
                                var splitting = valuesArray[n].split(',');
                                if (splitting[0] == i && splitting[1] == p) {
                                    if (splitting[2] != "null") {
                                        setval = splitting[2];
                                    }
                                    else {
                                        if (i != 0) {
                                            setval = "|||||"
                                        }
                                    }
                                }
                            }
                            if (setval != "null") {
                                parse.push(setval);
                            }
                            else {
                                parse.push("");
                            }
                        }
                        parse.push(String.fromCharCode(10))
                    }
                    var msg = parse.join();
    
    
    
    
                    $.ajax(
                        {
                            type: "POST",
                            url: "cpRequest.asp",
                            async: false,
                            data: { "msg": "01" + msg }
                        })
                        .done(function (response) {
                            //copy 
                            //for now no internal copy to external paste
                            rowOn += 1;
                            var popMsg = "Row: " + rowOn;
    
                            if (window.upsertRequestNotification == undefined) {
    
                                window.upsertRequestNotification = $.notify({
                                    title: "Copy",
                                    message: popMsg
                                }, {
                                        delay: 0,
                                        type: "success",
                                        template: utilities().notifyJSTemplates.default,
                                        onClose: function () {
                                            window.upsertRequestNotification = undefined;
                                        }
                                    });
    
    
                            }
    
                            window.upsertRequestNotification.update({ 'title': "Copy", 'message': popMsg, 'type': "success" })
                            setTimeout(function () {
                                window.upsertRequestNotification.close();
                            }, 5000);
    
                            console.log("copy:" + response);
                        });
    
                }//end of else 
    
            });
    
    
    
    
        console.log("copybtn Request end:");
    }
    
    var deleteRow = function(thisTable) {
        var $table = $(thisTable).closest('tbody');
        var table = $table[0];
        var find = $(thisTable).attr("tableid");
        var tableID = "#" + find.toString();
        var TRef = $(tableID);
        var rowLength = table.rows.length;
        //table.rows[rowOn].remove();
        
        var dtRow = $(tableID).DataTable().row($(thisTable).closest('tr'));
        var rowData = dtRow.data();
        
        // If this row was saved in the database, make a record of it on the table so we know
        // to tell the services that this row is now "deleted"
        if (Object.keys(rowData).includes("requestItemId") && !duplicatingRequest) {
            addRequestItemToDeletedAttr(tableID, rowData.requestItemId);
        }

        dtRow.remove().draw(false);
        //call editcheck2 function to call asp file to remove a row from the db
        //this also needs to update all rows after the delete to change there values 
        //do this by removing the last row
        //then resave the entire table with the save table function 
    
    
        if (window.self != window.top) {
            rowLength -= 1;
            window.parent.RemoveRow(find, rowLength)
                .then(function (obj) {
                    SaveTable(TRef[0])
                    console.log("RowRemoved");
                });
        }
        else {
            SaveTable(TRef[0], true)
        }

        // Bad hack to make sure the frozen column data updates correctly.
        setTimeout(() => $(tableID).DataTable().fixedColumns().update(), 500);
    
    }
    
    var resizeRequestItemsTableInRequest = function() {
        var containerTableWidth = $('table.manageRequestsTable > tbody').width();
        // Originally subtracted 50px, but now subtracting an extra 120 after putting requestItems table into card
        // Then changed it back to just 50px more (100 total)
        $('table.manageRequestsTable .requestItemsEditor .dataTables_scroll').css('width', (containerTableWidth - 100));
    }

    var PasteRequest = function(msg, rowOn, table) {

        //var msg ="02";
        $.ajax(
            {
                type: "POST",
                url: "cpRequest.asp",
                async: false,
                data: { "msg": msg }
            })
            .done(function (response) {
                //paste
    
                if (response == "") {
                    console.log("Nothing to paste.");
                }
                else {
                    console.log("paste:" + response);
                    var Pout = response.split(',');
                    var pCol = 1;
                    var item;
                    var subRow = 0;
    
    
                    //loop through row to get datatype id and then add data based off of 
    
                    $.each(Pout, function (index, item) {
                        index += 1;
                        console.log(index + ":" + item);
    
                        var cellInteract = table.rows[rowOn].cells[index];
                        var thisTableCellDiv = $(cellInteract).children()[0];
                        var thisTableCellDataTypeId = parseInt($(thisTableCellDiv).attr('datatypeid'));
    
    
                        if (!isNaN(thisTableCellDataTypeId)) {
    
                            if (thisTableCellDataTypeId == 1) { // Text
                                textInputs = $(thisTableCellDiv).find('input[type="text"]');
                                $(textInputs).val(item);
                                $(textInputs).change();
    
                            }
                            else if (thisTableCellDataTypeId == 2) { // Long Text
                                textareas = $(thisTableCellDiv).find('textarea');
                                $(textareas).val(item);
                                $(textareas).change();
                            }
                            else if (thisTableCellDataTypeId == 3 || thisTableCellDataTypeId == 4) { // Integer, Real Number
                                textInputs = $(thisTableCellDiv).find('input[type="number"]');
    
                                $(textInputs).val(item);
                                $(textInputs).change();
    
                            }
                            else if (thisTableCellDataTypeId === 5) { // Dropdown
                                var dropdowns = $(thisTableCellDiv).find('select');
                                if (dropdowns.length > 0) {
                                    $.each(dropdowns, function () {
                                        $(this).val(item);
                                        $(this).change();
                                    });
                                }
    
    
                            }
                            else if (thisTableCellDataTypeId == 6) { // File Attachment
    
                            }
                            else if (thisTableCellDataTypeId == 7) { // Date
                                if (item != "") {
                                    textInputs = $(thisTableCellDiv).find('input[type="text"]');
                                    $(textInputs).val(moment.utc(item, "MM/DD/YYYY"));
                                    $(textInputs).val(moment(item).format('MM/DD/YYYY'));
                                    $(textInputs).change();
                                }
                            }
                            else if (thisTableCellDataTypeId == 8) {// structure 
                                var imageContainer = $(thisTableCellDiv).find('.structureImageContainer');
                                var structure = $(imageContainer).children()[0];
                                var ID = $(structure).attr("liveeditid");
                                var format = getFileFormat(item);
                                updateLiveEditStructureData( ID, item, format, false);
                            }
                            else if (thisTableCellDataTypeId == 9) { // Long Text
                                textareas = $(thisTableCellDiv).find('textarea');
                                $(textareas).val(item);
                                $(textareas).change();
                            }
                            else { // CATCH-ALL
                                textInputs = $(thisTableCellDiv).find('input[type="text"]');
    
                                $(textInputs).val(item);
                                $(textInputs).change();
    
                            }
    
                        }
                    });//end $.else()
    
    
    
                }                

                $(table).DataTable().draw();
    
                $.ajax(
                    {
                        type: "POST",
                        url: "cpRequest.asp",
                        async: false,
                        data: { "msg": "01" }
                    });
    
                utilities().showUnsavedChangesNotification();
            });
    }

    /**
     * Checks if the given table is empty.
     * @param {string} tableId The table's HTML ID.
     * @param {JSON[]} versionedRequestItems The list of request item type configs.
     */
    var checkIfTableIsEmpty = function(tableId, versionedRequestItems) {

        var returnObj = true;
        
        var requestItemTypeId = $(`#${tableId}`).attr("requestitemtypeid");
        var requestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);

        var table = $(`#${tableId}`).DataTable();
        var tableRows = table.rows();

        if (tableRows.count() > 0) {
            $.each(Array(tableRows.count()), function(rowNum, rowPlaceholder) {
                if (!checkIfRowIsEmpty(table, rowNum, requestItemType)) {
                    returnObj = false;
                    return false;
                }
            });
        }

        return returnObj;
    }

    /**
     * Checks if the given row number of the given table object is empty.
     * @param {Object} tableObj The table we want to inspect.
     * @param {number} rowNumber The row we're looking at.
     * @param {JSON} requestItemType The request item type config.
     */
    var checkIfRowIsEmpty = function(tableObj, rowNumber, requestItemType) {
        
        var returnObj = true;

        var keysToIgnore = [
            "sortOrder",
            "sortorder"
        ];
        
        var structureKeys = [
            "uniqueIdentifier_hidden",
            "Structure",
            "structure"
        ];

        var requestItemIdKey = [
            "requestItemId",
            "requestitemid"
        ]

        var rowData = JSON.parse(JSON.stringify(tableObj.row(rowNumber).data()));

        $.each(keysToIgnore, function(i, key) {
            delete rowData[key];
        });

        var rowKeys = Object.keys(rowData);

        $.each(rowKeys, function(i, key) {
            if (structureKeys.includes(key)) {

                var rowHtml = $(tableObj.row(rowNumber).node());
                var rowMoldata = rowHtml.find(".editStructureLink").attr("moldata");
                if (rowMoldata != undefined) {
                    if (unescape(rowMoldata) != getEmptyMolFile()) {
                        if (rowMoldata != getEmptyEncodedMolFile()) {
                            returnObj = false;
                            return false;
                        }
                    }
                }

            } else if (requestItemIdKey.includes(key)) {

                if (rowData[key] != 0) {
                    returnObj = false;
                    return false;
                }

            } else {
                if (Array.isArray(rowData[key]["data"])) {
                    // key has been updated to be the request item type field ID, so there is no need to do a reverse look-up of the ID.
                    if (rowData[key]["data"].some(x => x && x != getDefaultValueOfItemField(requestItemType, key))) {
                        returnObj = false;
                        return false;
                    }
                }
            }
        });

        return returnObj;
    }

    /**
     * Determines the default value for a request item type field, or null if there isn't one.
     * @param {JSON} requestItemType The request item type that the field we're processing belongs to.
     * @param {number} requestTypeFieldId The ID of the field we want to process.
     */
    var getDefaultValueOfItemField = function(requestItemType, requestTypeFieldId) {
        var defaultVal = null;

        if (requestTypeFieldId > -1) {
            var groupId;
            var fieldSettings = requestItemType['fieldsDict'][requestTypeFieldId];
            if ($("#assignedUserGroupDropdown").val()) {
                groupId = $("#assignedUserGroupDropdown").val();
            } else {
                groupId = globalUserInfo.userGroups[0];
            }
            var userId;
            if ($(".userDropdown").length > 0) {
                var userId = $("#userDropdown").val();
            } else {
                var userId = window.globalUserInfo.userId;
            }
            
            // Get the defaults that pertain to this user.
            // General company default... there is only 1;
            var companyOption = fieldSettings.find(x => x.defaultValue != null);
            // Group default where the group id is one of my groups.
            var groupSettings = fieldSettings.find(x => x.groupId == groupId);
            var myGroupSettings = fieldSettings.filter(x => globalUserInfo.userGroups.includes(x.groupId));
            // Grab my user default.
            var userSetting = fieldSettings.find(x => userId == x.userId);

            var theField;
            // Check for default in this order: user => group => myGroup => company.
            if (userSetting) {
                theField = userSetting;
            }
            else if (groupSettings) {
                theField = groupSettings;
            } 
            else if (myGroupSettings.length > 0) {
                theField = myGroupSettings[0];
            }
            else if (companyOption) {
                theField = companyOption;
            }
            else {
                // If we don't have a default, then return null.
                return null;
            }
            defaultVal = theField["defaultValue"];
        }
        return defaultVal;
    }

    var fnc_tableCellContentWrapper = function(savedField, requestItemTypeField){
        var bucket = $('<div></div>');
        bucket.attr('datatypeid', savedField['dataTypeId'])
        bucket.attr('allowmultiple', requestItemTypeField['allowMultiple'])
        bucket.attr('clearWhenDuplicate', requestItemTypeField['clearWhenDuplicate'])
        bucket.attr('requestitemtypefieldid', requestItemTypeField['requestTypeFieldId'])
        bucket.attr('fieldgroup', requestItemTypeField['fieldGroup'])
        bucket.attr('title', savedField['hoverText'])
        return (bucket);
    }

    var dataTableDrawCallback = function(requestItemTypeId, thisRequestType, canWrite, tableSelectorString, versionedRequestItems, versionedFields){

        var isOldRevision = (typeof (requestRevId) != "undefined" && requestRevId != "");
        var scrollPos = $(this).parent().scrollTop();
        var tblRef = this.parent();

        if (typeof window.itemTypesRendering == "undefined")
            window.itemTypesRendering = {};

        window.itemTypesRendering[requestItemTypeId.toString()] = Math.random(); // This table is being reinitialized - this will stop it from trying to load any more structure images from other inits
        var renderingIteration = window.itemTypesRendering[requestItemTypeId.toString()];

        var api = this.api();
        var theTable = $(this[0]);

        $.each(theTable.find('tr'), function (rowNum, theRow) {
            if (renderingIteration != window.itemTypesRendering[requestItemTypeId]){
                return false;
            }
                
            $(this).find('.dataTableCellDateInput').toArray().map(function(x){
                var val = $(x).val();
                if (!val) {
                    val = $(x).attr("initVal");
                    if (!isNaN(val)) {
                        val = parseInt(val) * 1000;
                    }
                }

                var newDateField = fieldsModule().requestItemTypeDateGenerator(val);
                if (isOldRevision || !canWrite || (!isOldRevision && $(x).parent().hasClass("noCanEdit"))){
                    $(newDateField).attr("disabled", true);
                }

                $(x).replaceWith(newDateField);
            
            });

            var rowData = api.row(theRow).data();
            var structureFields = $(this).find('.structureDisplay');
            if (structureFields.length > 0 && renderingIteration === window.itemTypesRendering[requestItemTypeId]) {

                $.each(structureFields, function (fieldNumber, structureField) {
                    if ($(this).find(".liveEditStructureHolder").length)
                        return;

                    // If the current page hasn't changed & table hasn't been reinitialized
                    var structureImageId = getStructureImageId(requestItemTypeId, (rowNum - 1), $(structureField).attr('requestItemTypeFieldId'));
                    //This is where structure editor is added to the tables
                    //This happens on each redraw of the table 

                    if (!hasMarvin || $("[liveEditId=" + structureImageId + "]").length == 0) {
                        var startingMolData = $(this).attr('startingMolData');
                        $(this).removeAttr('startingMolData');

                        // Newly created rows, regardless of request status, all have requestItemId == 0
                        // Rows in makeNewRequest page from SDF upload have typeof requestItemId == undefined
                        var readOnlyStructure = true;
                        if (typeof rowData['requestItemId'] == "undefined" || (rowData['requestItemId'] == 0 && !$(structureField).hasClass('noCanEdit')) || (!$(structureField).hasClass('noCanAdd'))) {
                            readOnlyStructure = false;
                        }

                        var thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
                        var doRegSearchOnSubmit = thisRequestItemType.searchRegForExistingCompound;
                        var drawCallback = async function(){
                            utilities().autoFillRequestField(structureImageId, true, versionedRequestItems, versionedFields);

                            var res = await getChemistryEditorChemicalStructure(structureImageId);

                            if (molHasData(res)) {
                                var structureField = thisRequestItemType.fields.find(x => x.dataTypeId == dataTypeEnums.STRUCTURE);
                                var data = $(".dataTables_scrollBody > .requestItemEditorTable.display.dataTable.no-footer").DataTable().row(rowNum - 1).data();
                                data[structureField.requestTypeFieldId] = {data: [res], dirty: true};
                                $(".dataTables_scrollBody > .requestItemEditorTable.display.dataTable.no-footer").DataTable().row(rowNum - 1).data(data);

                                if (window.top.boeh) {
                                    BIModule().getAllBiDataForSingleRow(rowNum - 1, "arxItem", res)
                                }
                            }

                            if (doRegSearchOnSubmit) {
                                utilities().searchRegForStructure(structureImageId, versionedRequestItems, versionedFields);
                                utilities().searchForeignReg(structureImageId, versionedRequestItems, versionedFields);
                            }

                            $(`[liveEditId="${structureImageId}"]`).closest("td").attr("dirty", true);
                        }
                        
                        // Set the flag so if we are adding a new row it waits until the editor markup function is completed.
                        waitForEditorMarkup = true;
                        // Construct an ID for this structure by using the row number.
                        var structureId = "structureDisplay_" + rowNum;
                        $(this).attr("id", structureId);
                        getChemistryEditorMarkup(structureImageId, "", startingMolData, 280, 140, readOnlyStructure, drawCallback, null, null, null, null, true, true).then(function (structureEditorHtml) {
                            if ($('#' + structureId).html() == '') {
                                $('#' + structureId).html(structureEditorHtml);
                                waitForEditorMarkup = false;
                            }
                        });
 
                        var structureImageIdInterval = window.setInterval(function () {
                            console.log("looking for: ", structureImageId);
                            if ($("[liveEditId=" + structureImageId + "]").length == 0)
                                return;

                            console.log("found it, canceling interval");
                            $("[liveEditId=" + structureImageId + "]").attr("requestitemtypeid", requestItemTypeId);
                            window.clearInterval(structureImageIdInterval);
                            
                            utilities().searchRegForStructure(structureImageId, versionedRequestItems, versionedFields);
                            utilities().searchForeignReg(structureImageId, versionedRequestItems, versionedFields);
                            utilities().autoFillRequestField(structureImageId, true, versionedRequestItems, versionedFields);
                            setTimeout(function () {
                                $("[liveEditId=" + structureImageId + "]").bind({
                                    mouseenter: function (e) {
                                        // Hover event handler
                                        if (getLargeImg($(e.currentTarget).attr('liveeditid'))) {
                                            $('#modalDialog > div > div').empty();
                                            $('#modalDialog > div > div:first-of-type').append(getLargeImg($(e.currentTarget).attr('liveeditid')));
                                            var $position = $(e.currentTarget).offset();
                                            var $Width = $(e.currentTarget).width();
                                            $("#modalDialog").css({ top: ($position.top), left: ($position.left + $Width), position: 'absolute' });
                                            $('#modalDialog').show();
                                        }
                                    },
                                    mouseleave: function (e) {
                                        // Hover event handler
                                        $('#modalDialog > div > div').empty();
                                        $('#modalDialog').hide();
                                    }
                                });
                            }, 500);
                        }, 100);
                    }//end marvin check
                });
            }
        });

        if (tableSelectorString == "" || window.top != window.self) {
            var tableWidth = theTable.css('width');
            tableWidth = tableWidth.substring(0, tableWidth.length - 2);
            if (tableWidth < (window.innerWidth - 50))
                theTable.parent().css('width', tableWidth);
        } else {
            resizeRequestItemsTableInRequest();
        }

        requestFieldHelper().initAllSealectFields(versionedRequestItems, versionedFields);

        //utilities().resetItemHover(this); // we should not need this any more but i am leaving it here just in case we do
        utilities().addResumableToItem(versionedRequestItems, versionedFields);
        $(tblRef).scrollTop(scrollPos);
    }

    /**
     * Adds the rows of dataArray to the table at tableId, redraws the table and sets the draft.
     * @param {string} tableId The ID of the table to add to.
     * @param {Array} dataArray The rows to add.
     * @param {Array} versionedRequestItems The versioned request item data.
     * @param {Array} versionedFields The versioned field data.
     * @param {Array} invalidCells The cells that have been flagged as invalid on data import. Default is an empty array, the format for each item is {"column": y, "row": x}.
     */
    var bulkAddRows = function(tableId, dataArray, versionedRequestItems, versionedFields, invalidCells=[]) {
        var dt = $(`#${tableId}`).DataTable();
        dt.clear().draw(false);
        dt.rows.add(dataArray).draw(false);

        // Apply the dependencies
        for(var i = 0; i < dataArray.length; ++i) {
            requestItemTableHelpers().applyItemDependencies(tableId, i, versionedRequestItems, versionedFields);
        }

        if (window.top.boeh) {
            BIModule().bulkLookup(dataArray);
        }
        
        dt.draw();
        SaveTable($(`#${tableId}`)[0]);
        utilities().resizeCustExpIframe();

        // Flag any cells that have invalid data.
        $.each(invalidCells, function(i, cell) {
            var row = dt.row(cell["row"]).node();
            var invCell = $(row).find("td")[cell["column"]];
            if (invCell == undefined) {
                return;
            }

            $(invCell).find(".editorItemFieldValidationErrorLabel").text("Invalid data.");
        });
    }

    /**
     * Adds the given request item id to the table's list of deleted items.
     * @param {string} tableId The table we're deleting from.
     * @param {number} requestItemId The row's ID.
     */
    var addRequestItemToDeletedAttr = function(tableId, requestItemId) {

        if (requestItemId == 0) {
            return;
        }

        var table = $(tableId);
        var deletedItems = table.attr("deletedrows");

        if (deletedItems) {
            table.attr("deletedrows", deletedItems + "," + requestItemId);
        } else {
            table.attr("deletedrows", requestItemId);
        }
    }

    /**
     * Determines if the given table sort array is the default sort.
     * @param {Array} sortArr The datatables sort array.
     */
    var isDefaultSort = function(sortArr) {
        var col = sortArr[0];

        if (Array.isArray(col)) {
            return isDefaultSort(col);
        } else {
            return col == 0 && sortArr[1] == "asc";
        }
    }

    /**
     * Checks if all request item tables are sorted.
     */
    var allTablesSorted = function() {
        var requestItemIds = window.top.thisRequestType["requestItemTypes"].map(x => x["requestItemId"]);
        var tablesSorted = requestItemIds.map(x => isDefaultSort($(`#requestItemTable${x}`).DataTable().order()));

        return tablesSorted.every(x => x);
    }


    return{
        priorityCol: priorityCol,
        checkForStructure: checkForStructure,
        initRequestItemTable: initRequestItemTable,
        getNumOfAdditionalCols: getNumOfAdditionalCols,
        updateRequestItemsTableDataAndRedraw: updateRequestItemsTableDataAndRedraw,
        convertSavedRequestDataForDT: convertSavedRequestDataForDT,
        addRequestItemRow: addRequestItemRow,
        makeCSV: makeCSV,
        makeColumnsArray: makeColumnsArray,
        copyPasteRow: copyPasteRow,
        resizeRequestItemsTableInRequest: resizeRequestItemsTableInRequest,
        PasteRequest: PasteRequest,
        makeSDF: makeSDF,
        checkIfTableIsEmpty: checkIfTableIsEmpty,
        bulkAddRows: bulkAddRows,        
        isDefaultSort: isDefaultSort,
        allTablesSorted: allTablesSorted,
    };

}); // dataTableModule(). 