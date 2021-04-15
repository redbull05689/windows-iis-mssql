var tableFileUploadModule = function() {
    
    /**
     * Combines csvRows into a list of rows with subrows.
     * @param {Array} csvRows The rows to join.
     * @param {Array} requestItemFields The request item field config info.
     * @param {string} rowHeader The subcolumn row identifier.
     * @param {string} orphanedDataHeader The identifier for orphaned data.
     * @param {string} suppressedDataHeader The identifier for suppressed data.
     */
    var joinCSVRows = function(csvRows, requestItemFields, rowHeader, orphanedDataHeader, suppressedDataHeader) {
        var joinedRows = [];

        if (csvRows.filter(x => Object.keys(x).includes(rowHeader) && x[rowHeader] != "").length > 0) {
            // We'll organize all of the rows into the final row groups.
            var rowGroups = [];

            // Walk through csvRows and organize them based on whether or not the row contains data in the subrow column.
            $.each(csvRows, function(i, row) {
                if (row[rowHeader] == "") {
                    // This row does not have anything in the subrow column, so it belongs to the last group in rowGroups.

                    // If we don't yet have anything, then make a row group, and flag the first row in as an orphaned one.
                    if (rowGroups.length == 0) {
                        rowGroups.push([]);
                        row[orphanedDataHeader] = true;
                    }

                    // Add this row to the last rowGroup.
                    rowGroups[rowGroups.length - 1].push(row);
                } else {
                    // This row has something in the subrow column, so it makes a new group.
                    rowGroups.push([row]);
                }
            });

            // Now finish by running joinCSVRowGroup on each row.
            joinedRows = rowGroups.map(x => joinCSVRowGroup(x, requestItemFields, suppressedDataHeader));
        } else {
            // If we can't join any rows though, then just return csvRows.
            joinedRows = csvRows;
        }

        return joinedRows;
    }

    /**
     * Combines all of the rows in rowGroup into one super row object.
     * @param {Array} rowGroup A list of rows to be joined into one.
     * @param {Array} itemFields The request item field config info.
     * @param {string} suppressedDataHeader The suppressed data header.
     */
    var joinCSVRowGroup = function(rowGroup, itemFields, suppressedDataHeader) {
        var rowObj = {};

        // We'll do a double loop to walk through each row, and each column of each row.
        $.each(rowGroup, function(i, subRow) {
            $.each(Object.keys(subRow), function(j, rowKey) {
                // If our super row doesn't contain the current column, add it.
                if (!Object.keys(rowObj).includes(rowKey)) {
                    rowObj[rowKey] = [];
                }

                // Figure out if we have this field in the config info.
                var field = itemFields.find(x => x.displayName == rowKey);

                if (field) {
                    // If we do, then check to see if we allow multiple subrows for this field.
                    var allowMultiple = field["allowMultiple"];

                    if (allowMultiple || rowObj[rowKey].length < 1) {
                        // We can add this data to the subrows if we either don't have anything there yet
                        // or we allow multiple rows.
                        rowObj[rowKey].push(subRow[rowKey]);
                    } else {
                        // Otherwise, mark this super-row so we know that there will be data that will be lost in the upload.
                        rowObj[suppressedDataHeader] = true;
                    }
                } else {
                    // Otherwise, just assume we can do multiple subrows.
                    rowObj[rowKey].push(subRow[rowKey]);
                }
            });
        });

        return rowObj;
    }

    /**
     * Display a sweet alert to the user if the data they've uploaded would have lost data in the conversion process
     * and allow them to back out if they want to reformat their input data.
     * @param {string} tableId The table's ID.
     * @param {string} fileUploadSetting The setting for how we want to process the CSVData rows.
     * @param {Array} convertedCSVData The rows to add to the table.
     * @param {Array} versionedRequestItems The request item config info.
     * @param {Array} versionedFields The field config info.
     * @param {JSON} CSVValidation Object that holds potential validation errors.
     */
    var displaySuppressedDataWarning = function(tableId, fileUploadSetting, convertedCSVData, versionedRequestItems, versionedFields, CSVValidation) {
        $("#basicLoadingModal").modal("hide");

        var warningMsgs = [];
        
        if (CSVValidation["anyOrphanedData"]) {
            warningMsgs.push("There are subrows that did not have a designated parent, so the system has marked the first inputted row as the first parent row.");
        }

        if (CSVValidation["anySuppressedRows"]) {
            warningMsgs.push("There are subrows that will not be displayed because they belong to field rows that do not allow multiple values.");
        }

        if (CSVValidation["anyInvalidValues"]) {
            warningMsgs.push("There were invalid values submitted to the system. Please check your data for any inconsistencies.");
        }

        window.top.swal({
            "title": "Are you sure?",
            "text": warningMsgs.join("\r\n\r\n"),
            "type": "warning",
            "showCancelButton": true,
            "confirmButtonText": "Yes, proceed.",
            //"cancelButtonText": ""
        }, function() {
            addCSVDataToTable(tableId, fileUploadSetting, convertedCSVData, versionedRequestItems, versionedFields, CSVValidation["invalidCells"]);
        });
    }

    /**
     * Processes convertedCSVData into the data structure that datatables is expecting and adds them to the table.
     * @param {string} tableId The table's ID.
     * @param {string} fileUploadSetting The setting for how we want to process the CSVData rows.
     * @param {Array} convertedCSVData The rows to add to the table.
     * @param {Array} versionedRequestItems The request item config info.
     * @param {Array} versionedFields The field config info.
     * @param {Array} invalidCells The cells that have been flagged as invalid on data import. Default is an empty array, the format for each item is {"column": y, "row": x}.
     */
    var addCSVDataToTable = function(tableId, fileUploadSetting, convertedCSVData, versionedRequestItems, versionedFields, invalidCells=[]) {
        buildUploadTableRows(tableId, fileUploadSetting, convertedCSVData, versionedRequestItems, versionedFields).then(function(dataArray) {
            dataTableModule().bulkAddRows(tableId, dataArray, versionedRequestItems, versionedFields, invalidCells);
        });
    }

    /**
     * Imports a CSV to the table with id tableId.
     * @param {string} tableId The table's ID.
     * @param {string} fileUploadSetting The setting for how we want to process the CSVData rows.
     * @param {Array} convertedCSVData The rows to add to the table.
     * @param {Array} versionedRequestItems The request item config info.
     * @param {Array} versionedFields The field config info.
     */
    var csvToTable = function(tableId, fileUploadSetting, CSVData, versionedRequestItems, versionedFields) {

        // Fetch the row header from the admin svc.
        var rowHeader = excelImportParentRow;

        var requestItemTypeId = $(`#${tableId}`).attr("requestitemtypeid");
        var requestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
        var requestItemFields = requestItemType.fields;

        // These are special internal JSON column headers used to flag possible errors.
        var orphanedDataHeader = "_______orphanedData";
        var suppressedDataHeader = "_______suppressedData";

        $("#basicLoadingModal").modal("hide");

        // Don't do anything if there is no data.
        if (CSVData === undefined) {
            window.parent.swal("Please upload a file");
            return;
        }

        // Convert the CSVData into an array of objects, then join the rows if possible.
        var convertedCSVData = $.csv.toObjects(CSVData);
        convertedCSVData = joinCSVRows(convertedCSVData, requestItemFields, rowHeader, orphanedDataHeader, suppressedDataHeader);

        var CSVValidation = validateCSVData(tableId, convertedCSVData, orphanedDataHeader, suppressedDataHeader, requestItemFields, versionedFields);

        if (Object.values(CSVValidation).some(x => Array.isArray(x) ? x.length : x)) {
            displaySuppressedDataWarning(tableId, fileUploadSetting, convertedCSVData, versionedRequestItems, versionedFields, CSVValidation);
        } else {
            addCSVDataToTable(tableId, fileUploadSetting, convertedCSVData, versionedRequestItems, versionedFields);
        }
    }

    /**
     * Validate convertedCSVData.
     * @param {string} tableId The table's ID.
     * @param {Array} convertedCSVData The rows to validate.
     * @param {boolean} orphanedDataHeader The orphaned data header.
     * @param {boolean} suppressedDataHeader The suppressed data header.
     * @param {Array} requestItemFields The request item's field info.
     * @param {Array} versionedFields The field config info.
     */
    var validateCSVData = function(tableId, convertedCSVData, orphanedDataHeader, suppressedDataHeader, requestItemFields, versionedFields) {
        var validationObj = {};

        // If there are any rows that have lost data or there are any orphaned rows, then display the warning to the user, otherwise just go.
        validationObj["anyOrphanedData"] = convertedCSVData.filter(x => x[orphanedDataHeader]).length > 0;
        validationObj["anySuppressedRows"] = convertedCSVData.filter(x => x[suppressedDataHeader]).length > 0;

        var affectedCells = [];
        validationObj["anyInvalidValues"] = validateCSVValues(tableId, convertedCSVData, requestItemFields, affectedCells, versionedFields);
        validationObj["invalidCells"] = affectedCells;

        return validationObj;
    }

    /**
     * Validate convertedCSVData's values.
     * @param {string} tableId The table's ID.
     * @param {Array} convertedCSVData The rows to validate.
     * @param {Array} requestItemFields The request item field config info.
     * @param {Array} affectedCells A list of cells that will be marked as invalid.
     * @param {Array} versionedFields The field config info.
     */
    var validateCSVValues = function(tableId, convertedCSVData, requestItemFields, affectedCells, versionedFields) {
        var validationArr = [];

        // Do a double loop to go through each row's cells.
        $.each(convertedCSVData, function(i, row) {
            var rowValidationArr = [];
            $.each(Object.keys(row), function(j, key) {
                var cell = row[key];
                var field = requestItemFields.find(x => x.displayName == key && x.disabled == 0);
                var invalid = false;

                // If we have a field, then we can check the data. Otherwise, the field submitted doesn't match anything
                // and the data won't go into the table.
                if (field) {
                    if (Array.isArray(cell)) {
                        invalid = cell.some(x => isCSVValueInvalid(x, field, versionedFields));
                    } else {
                        invalid = isCSVValueInvalid(cell, field, versionedFields);
                    }

                    // Remove the offending data.
                    if (invalid) {
                        affectedCells.push({
                            column: field.sortOrder + dataTableModule().getNumOfAdditionalCols() - 1, // -1 for the always present left column.
                            row: $(`#${tableId}`).DataTable().rows().count() + i
                        });
                    }
                }

                rowValidationArr.push(invalid);
            });

            validationArr.push(rowValidationArr.some(x => x));
        })

        return validationArr.some(x => x);
    }

    /**
     * Check if the input value is invalid.
     * @param {*} value The value to check.
     * @param {JSON} field The request item field we're checking against.
     * @param {Array} versionedFields The field config info.
     */
    var isCSVValueInvalid = function(value, field, versionedFields) {
        var invalidValue = false;
        var dataTypeId = field.dataTypeId;
        var savedFieldId = field.savedFieldId;

        // The validation rules.
        if (["", null, undefined].includes(value)) {
            // We don't care about empty values, so push em through.
            invalidValue = false;
        } else if ([dataTypeEnums.INTEGER, dataTypeEnums.REAL_NUMBER].includes(dataTypeId)) {
            // Number fields should validate that the incoming value is a number.
            invalidValue = isNaN(Number(value));
        } else if ([dataTypeEnums.DROP_DOWN].includes(dataTypeId)) {
            // Dropdowns should check to make sure that the incoming value is an actual dropdown option.
            var savedField = versionedFields.find(x => x.id == savedFieldId);
            if (!savedField) {
                invalidValue = true;
            } else {
                invalidValue = savedField.options.find(x => x.displayName == value) == undefined;
            }
        } else if ([dataTypeEnums.DATE].includes(dataTypeId)) {
            // Dates should check to make sure that the incoming value is an actual date of some kind.
            var date = new Date(value);
            invalidValue = isNaN(date.getTime());
        } else if ([dataTypeEnums.USER_LIST, dataTypeEnums.CO_AUTHORS].includes(dataTypeId)) {
            // User lists should check to make sure that the incoming name exists in the user list.
            // Not sure we support this as of right now (10/21), but it's probably good to have this here anyway.
            if (usersList != undefined) {
                invalidValue = usersList.find(x => x.fullName == value);
            }
        }

        return invalidValue;
    }

    /**
     * Displays the file import settings modal if there isn't a valid setting stored
     * or if this is a new request with data already in the table.
     * @param {string} tableId The DOM ID of the table.
     * @param {string} uploadType The type of file being uploaded.
     * @param {JSON} requestObj The metadata of the object to send to coreServices.
     * @param {number} tableNum The index of the request item in the request type.
     * @param {string} fileExtension The file extension of the uploaded file.
     * @param {string} newFileName The name of the file on the server.
     * @param {number} requestItemTypeId The ID of the request item type.
     * @param {boolean} newRequest Is this a new request?
     * @param {File} sdFile The SD File being uploaded. Can be null if we're not processing an SD File.
     * @param {JSON[]} versionedRequestItems The versioned list of request items.
     * @param {JSON[]} versionedFields The versioned list of fields.
     */
    var displayFileImportOptions = function(tableId, uploadType, requestObj, tableNum, fileExtension, newFileName, requestItemTypeId, newRequest, sdFile, versionedRequestItems, versionedFields) {

        // Define this over here so we can pass in the versioned request information.
        $("body").off("click", "button.file-upload-setting-submit")
        $("body").on("click", "button.file-upload-setting-submit", function (event) {
            fileUploadSubmitCallback(sdFile, versionedRequestItems, versionedFields)
        });

        if (dataTableModule().checkIfTableIsEmpty(tableId, versionedRequestItems)) {
            processTableUpload(tableId, requestObj, fileExtension, newFileName, requestItemTypeId, "Delete", sdFile, versionedRequestItems, versionedFields);
        } else {
            
            ajaxModule().fetchFileUploadSetting(companyId, globalUserInfo.userId).then(function(response) {
                var fileUploadSetting = response;
        
                if (fileUploadSetting === "" && newRequest) {
                    $("#fileImportModal").attr("tableid", tableId);
                    $("#fileImportModal").attr("tablenum", tableNum);
                    $("#fileImportModal").attr("uploadType", uploadType !== undefined ? uploadType : "");
                    $("#fileImportModal").attr("fileextension", fileExtension);
                    $("#fileImportModal").attr("requestobj", JSON.stringify(requestObj));
                    $("#fileImportModal").attr("newfilename", newFileName);
                    $("#fileImportModal").attr("requestitemtypeid", requestItemTypeId);
        
                    window.requestCSVData = requestObj;

                    $("#fileImportModal").modal("show");
                } else {
        
                    fileUploadSetting = newRequest ? fileUploadSetting : "After";
                    processTableUpload(tableId, requestObj, fileExtension, newFileName, requestItemTypeId, fileUploadSetting, sdFile, versionedRequestItems, versionedFields);
                }
            })
        }
    }

    /**
     * Processes the uploaded file and figures out what process needs to look at it to format the data for datatables.
     * @param {string} tableId The table's DOM ID.
     * @param {JSON} requestObj The object being built up for the data POST.
     * @param {string} fileExtension The file extension.
     * @param {string} newFileName The name of the uploaded file on the server.
     * @param {number} requestItemTypeId The request type's ID.
     * @param {string} fileUploadSetting The setting that determines where to place the imported data in the table.
     * @param {File} sdFile The SD file being uploaded. Can be null if we're not processing an SD File.
     * @param {JSON[]} versionedRequestItems The list of request item config data.
     * @param {JSON[]} versionedFields The list of field config data.
     */
    var processTableUpload = function(tableId, requestObj, fileExtension, newFileName, requestItemTypeId, fileUploadSetting, sdFile, versionedRequestItems, versionedFields) {

        var thisItem = versionedRequestItems.find(x => x.id == requestItemTypeId);
        
        var allowedGroups = thisItem['allowedGroups'];
        var allowedUsers = thisItem['allowedUsers'];

        var myPermsGroups = allowedGroups == null ? [true] : allowedGroups.filter(x => globalUserInfo["userGroups"].includes(x.groupId) && x.canAdd == 1);
        var myPermsUsers = allowedUsers == null ? [true] : allowedUsers.filter(x => globalUserInfo['userId'] == x.userId && x.canAdd == 1);
        
        if (myPermsGroups.length == 0 && myPermsUsers.length == 0)
        {
            window.parent.swal("Cannot Upload File", "You currently don't have permission to add request items of this type!", "error");
            return
        }

        // Excel files go to the c# api.
        if (["csv", ".csv", "xls", ".xls", "xlsx", ".xlsx"].includes(fileExtension)) {
            uploadExcel(tableId, requestObj, fileUploadSetting, versionedRequestItems, versionedFields);
        }
        // CDX files go back to C#.
        else if (["cdx", ".cdx"].includes(fileExtension)) {
            ajaxModule().CDXToCDXML(newFileName, requestItemTypeId, fileUploadSetting, tableId, versionedRequestItems, versionedFields)
        }
        else if (["cdxml", ".cdxml"].includes(fileExtension)) {
            ajaxModule().processCDXML(requestObj, requestItemTypeId, fileUploadSetting, tableId, versionedRequestItems, versionedFields);
        }
        else if (["sdf", ".sdf"].includes(fileExtension)) {
            readSDFile(sdFile, fileUploadSetting, tableId, versionedRequestItems, versionedFields);
        }
        // No support for the other filetypes.
        else {
            window.parent.swal("Filetype not supported.");
        }
    }
    
    /**
     * Reads the incoming SD file and uploads the table data to the given dataTable found at tableId.
     * @param {File} file The SD file to process.
     * @param {string} fileUploadSetting The setting that determines where to place the imported data in the table.
     * @param {string} tableId The table's DOM ID.
     * @param {JSON[]} versionedRequestItems The list of request item config data.
     * @param {JSON[]} versionedFields The list of field config data.
     */
    var readSDFile = async function(file, fileUploadSetting, tableId, versionedRequestItems, versionedFields) {

        window.sdfUploadProgressNotification = $.notify({
            title: "Processing your SDF File...",
            message: ""
        }, {
            delay: 0,
            type: "yellowNotification",
            template: utilities().notifyJSTemplates.default
        });

        const sd = await SDFileModule(file);

        const table = $(`#${tableId}`)
        const requestItemTypeId = table.attr("requestitemtypeid");
        const requestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);

        const columnsArray = dataTableModule().makeColumnsArray(requestItemTypeId, versionedRequestItems, versionedFields);
        const dataArray = sd.molDictList.map((mol, index) => makeMolRow(mol, index, columnsArray, requestItemType, versionedFields));

        const returnObj = {
            status: "success",
            result: {
                data: dataArray,
                columns: columnsArray,
            },
        };

        processSDFile(returnObj, fileUploadSetting, tableId, versionedRequestItems, versionedFields);
    }

    /**
     * Creates a datatable row based on the given mol object.
     * @param {JSON} mol The mol object we want to make a data table row out of.
     * @param {number} molIndex The index of this mol.
     * @param {JSON[]} columnsArray The list of columns for the table.
     * @param {JSON} requestItemType The request type config data.
     * @param {JSON[]} versionedFields The list of field config data.
     */
    var makeMolRow = function(mol, molIndex, columnsArray, requestItemType, versionedFields) {
        let dataObj = {};
        
        // Iterate through each key in the mol.
        for(key in mol) {

            // If this key is the molData key, then check for a structure field. If we have one, then set its value to the molData.
            if (key == "molData") {
                const structureField = requestItemType.fields.find(x => x.dataTypeId == dataTypeEnums.STRUCTURE);
                if (structureField) {
                    dataObj[structureField.displayName.toLowerCase()] = [mol[key]];
                }
            } else {
                // Otherwise, figure out which request item field this is...
                const requestItemField = requestItemType.fields.find(x => x.displayName.toLowerCase() == key.toLowerCase() && x.disabled != 1);

                if (requestItemField) {
                    const dataTypeId = requestItemField["dataTypeId"];

                    // If this field is a drop down, then we need to map the text value from the SD File to an option ID and set that to be the value.
                    if (dataTypeId == dataTypeEnums.DROP_DOWN) {
                        const savedField = versionedFields.find(x => x.id == requestItemField.savedFieldId);
                        if (savedField) {
                            const options = savedField.options;
                            const selectedOption = options.find(x => x.displayName == mol[key]);
                            if (selectedOption) {
                                dataObj[requestItemField.displayName.toLowerCase()] = [selectedOption["dropdownOptionId"]];
                            }
                        }
                    } else {
                        // Otherwise, we can set the value as the value from the SD File.
                        dataObj[requestItemField.displayName.toLowerCase()] = [mol[key]];
                    }
                }
            }
        }

        // Now that we're done iterating through this mol, figure out what columns we didn't hit on the first pass and apply default values.
        const colsNotInSd = columnsArray.filter(col => !(col.title.toLowerCase() in dataObj));
        colsNotInSd.forEach((column) => {
            // Find the field...
            const requestItemField = requestItemType.fields.filter(x => x.requestTypeFieldId == column.requestItemTypeFieldId && x.disabled != 1);

            // We need to make sure we're looking at the correct field.
            if (requestItemField.length > 0) {
                const userId = globalUserInfo.userId;
                const groupId = $("#assignedUserGroupDropdown").val();

                const userField = requestItemField.find(x => x.userId == userId && x.userDefaultValue);
                const groupField = requestItemField.find(x => x.groupId == groupId && x.groupDefaultValue);
                const companyField = requestItemField.find(x => x.groupId == null && x.userId == null);
                let defaultValue = "";

                // If we have a field config for the current user specifically, then check if they have a default.
                if (userField) {
                    if (userField["userDefaultValue"]) {
                        defaultValue = userField["userDefaultValue"];
                    }
                }

                // If the user did not have a default, check if there is a group default for the current group.
                if (groupField && !defaultValue) {
                    if (groupField["groupDefaultValue"]) {
                        defaultValue = groupField["groupDefaultValue"];
                    }
                }
                
                // If there was not a group default, check if there's a company default.
                if (companyField["defaultValue"] && !defaultValue) {
                    defaultValue = companyField["defaultValue"];
                }

                // If there was a default value for any of those tiers, set that as the field value.
                if (defaultValue) {
                    dataObj[companyField.displayName.toLowerCase()] = [defaultValue];
                }
            }
        });

        // Now add some more metadata and we're done.
        dataObj["uniqueIdentifier_hidden"] = randomString(32, '#A');
        dataObj["assignedOrder"] = molIndex + 1;
        dataObj["sortOrder"] = molIndex + 1;
        return dataObj;
    }
    
    /**
     * 
     * @param {JSON} response The response from the SD File endpoint of workflowApi.py
     * @param {string} fileUploadSetting The file upload setting that determines where the uploaded fields belong.
     * @param {string} tableId The request item table's HTML ID.
     * @param {JSON[]} versionedRequestItems The list of request item configs for the current request.
     * @param {JSON[]} versionedFields The list of field configs.
     */
    var processSDFile = function(response, fileUploadSetting, tableId, versionedRequestItems, versionedFields) {
        console.log("success");
        if (response['status'] == "success") {
            window.sdfUploadProgressNotification.update({ 'title': "Successfully processed your SDF File", 'message': "", 'type': "success" })
            setTimeout(function () {
                window.sdfUploadProgressNotification.close();
            }, 4500);
    
            $('#sdfUploadInput').val(null)
            
            tableData = response['result'];
            
            buildUploadTableRows(tableId, fileUploadSetting, tableData.data, versionedRequestItems, versionedFields).then(function(tableRows) {
                tableData.data = tableRows;
                
                console.log("sdfUploadSubmitButton");
    
                dataTableModule().bulkAddRows(tableId, tableRows, versionedRequestItems, versionedFields);
                $("#basicLoadingModal").modal("hide")
            });
        }
        else {
            window.sdfUploadProgressNotification.update({ 'title': "Failed to process your SDF File", 'message': "Please check the file for issues and try again.", 'type': "danger" })
        }
    }

    var uploadExcel = function(tableId, requestObj, fileUploadSetting, versionedRequestItems, versionedFields) {
        requestObj.jwt = jwt;

        $.ajax({
            url: "/excel2csv/api/values",
            type: "POST",
            data: requestObj
        }).done(function (response) {
            console.log(response);
            csvToTable(tableId, fileUploadSetting, response.value, versionedRequestItems, versionedFields);
        });
    }

    var getAcceptedFileTypes = function(requestItemTypeId, versionedRequestItems) {
        var acceptedFiles = [".csv", ".xls", ".xlsx"];
    
        var thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
    
        var requestFields = thisRequestItemType.fields;
        if (requestFields.filter(x => x.dataTypeId == 8).length > 0) {
            acceptedFiles.push(".sdf");
            acceptedFiles.push(".cdx");
            acceptedFiles.push(".cdxml");
        }
    
        return acceptedFiles;
    }
    
    var makeRequestItemsFileUploadForm = function(requestItemTypeIndex, requestItemType, versionedRequestItems) {
        // Helper function to make the file upload form for request items.

        // Check if this is an old revision.
        var isOldRevision = (typeof (requestRevId) != "undefined" && requestRevId != "");

        // Also find whether or not this request item type exists.
        var requestItemTypeId = requestItemType.requestItemTypeId;
        var thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);

        // Return a blank div if this is either an old revision or we don't have a requestItemType.
        if (isOldRevision || thisRequestItemType === undefined) {
            return $("<div></div>");
        }

        // Set up a list of existing files and names.
        var acceptedFiles = getAcceptedFileTypes(requestItemTypeId, versionedRequestItems);
        var acceptedNames = ["Excel"];

        // Check the fields to see if there is a structure field and if there is, add the SDF format to
        // our two arrays.
        var requestFields = thisRequestItemType.fields;
        if (requestFields.filter(x => x.dataTypeId == 8).length > 0) {
            acceptedNames.push("SD");
            acceptedNames.push("ChemDraw");
        }

        // Now join the arrays to make our format strings.
        var labelStr = acceptedFiles.join(",");
        var acceptedFilesStr = acceptedFiles.join(", ");
        //var acceptedStatusStr = acceptedNames.join(" or ");
        var acceptedStatusStr = [acceptedNames.slice(0, -1).join(", "), acceptedNames.slice(-1)[0]].join(acceptedNames.length < 2 ? "" : " or ");

        // Now build the upload form.
        var requestItemsFileUploadForm = $('<form id="sdfUploadForm" onsubmit="return false;" tablenum="' + requestItemTypeIndex + '"></form>').attr("tableid", "requestItemTable" + requestItemType['requestItemId']);
        var requestItemsFileUploadLabel = $('<label class="btn btn-default btn-file chooseSdFileButton ">').text("Upload File");
        var uploadButton = $('<button id="sdfUploadInput" class="sdfUploadInput resumable-browse" accept="' + labelStr + '" tablenum="' + requestItemTypeIndex + '">');

        requestItemsFileUploadLabel.append(uploadButton);
        var requestItemsFileUploadStatusHolder = $('<label class="text-info sdfUploadStatusHolder" id="sdfUploadStatusHolder" tablenum="' + requestItemTypeIndex + '">').text("Please choose an " + acceptedStatusStr + " File (" + acceptedFilesStr + ")")
        requestItemsFileUploadForm.append(requestItemsFileUploadLabel, requestItemsFileUploadStatusHolder);

        return requestItemsFileUploadForm;
    }

    /**
     * Adds the given fragmentArr to the specified request item table.
     * @param {JSON[]} fragmentArr The array of CDX fragments to add.
     * @param {number} requestItemId The request item table's ID.
     * @param {string} fileUploadSetting The setting for where the uploaded rows should go in relation to the existing rows.
     * @param {string} tableId The HTML ID of the data table we're adding rows to.
     * @param {JSON[]} versionedRequestItems The array of request item config JSONs.
     * @param {JSON[]} versionedFields The array of field config JSONs.
     */
    var addFragmentsToTable = function(fragmentArr, requestItemId, fileUploadSetting, tableId, versionedRequestItems, versionedFields) {
        var columnData = dataTableModule().makeColumnsArray(requestItemId, versionedRequestItems, versionedFields);
        var rowData = [];
    
        var structureCol = columnData.find(dataTableModule().checkForStructure);
    
        if (structureCol === undefined || fragmentArr.length == 0) {
            window.parent.swal("No structures.");
            return;
        }
    
        var struc_name = structureCol.data;
    
        console.log(fragmentArr.length);
    
        $.each(fragmentArr, function (index, fragment) {
            var row = {};
    
            var fragment = fragmentArr[index];
    
            row[struc_name] = [fragment];
            row["sortOrder"] = index + 1;
    
            row["uniqueIdentifier_hidden"] = randomString(32, "#A");
            rowData.push(row);
        });
    
        buildUploadTableRows(tableId, fileUploadSetting, rowData, versionedRequestItems, versionedFields).then(function(tableRows) {
            try {
                dataTableModule().bulkAddRows(tableId, tableRows, versionedRequestItems, versionedFields);
            
                $("#basicLoadingModal").modal("hide")
            } catch (e) {
                console.log(e);
            }
        });
    }

    /**
     * Takes tableRows and merges them with the rows already in the table belonging to tableId in a way defined by the fileUploadSetting
     * and adds the rows to the table.
     * @param {string} tableId The request item table's HTML ID.
     * @param {string} fileUploadSetting The file upload setting that determines where the uploaded fields belong.
     * @param {JSON[]} tableRows The rows to add to the table.
     * @param {JSON[]} versionedRequestItems The list of request item configs for the current request.
     * @param {JSON[]} versionedFields The list of field configs.
     */
    var buildUploadTableRows = function(tableId, fileUploadSetting, tableRows, versionedRequestItems, versionedFields) {
        return new Promise(function(resolve, reject) {
            var thisTable = $(`#${tableId}`);
            var requestItemTypeId = thisTable.attr("requestitemtypeid");
            var thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
    
            if (!thisRequestItemType) {
                return;
            }
            //this parses DD options into option IDs
            tableRows = tableRows.map(function(row){
                $.each(row, function(key,Val){
    
                    var thisRequestItemField = thisRequestItemType.fields.find(x => x.displayName.toLowerCase() == key.toLowerCase());
                    if (!thisRequestItemField) {
                        return;
                    }
    
                    var activeField = versionedFields.find(z => z.id == thisRequestItemField.savedFieldId);
                    if (activeField != undefined)
                    {
                        if (activeField["dataTypeId"] == dataTypeEnums.DROP_DOWN)
                        {
                            if (typeof Val != "number")
                            {
                                var option = activeField["options"].find(q => q.displayName == Val);
                                if (option != undefined)
                                {
                                    row[key] = option["dropdownOptionId"];
                                }
                            }
                        }
                    }
                })
                return (row);
            });
    
            // Figure out if we even have structure fields to parse.
            var requestItemHasStructureField = false;

            var existingRows = thisTable.DataTable().rows().data().toArray();

            // Start by figuring out whar request item type this is and get its config and determine whether or not any of its fields
            // are of data type STRUCTURE.
            var requestItemTypeId = $(`#${tableId}`).attr("requestitemtypeid");
            var thisRequestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
            if (thisRequestItemType) {
                requestItemHasStructureField = thisRequestItemType.fields.some(x => x.dataTypeId == dataTypeEnums.STRUCTURE);
            }

            var itemPromises = [];

            // If we have any structures, then go through all of the existing rows, pull out the actual HTML table row from the DOM,
            // grab the row's structure field, get its moldata, and add it to the data array.
            if (requestItemHasStructureField) {
                $.each(existingRows, function(rowIndex, rowData) {
                    var thisRow = $(`#${tableId} > tbody`).find("tr")[rowIndex];
    
                    if (thisRow == undefined) {
                        return;
                    }
                    
                    var thisDiv = $(thisRow).find(`div[datatypeid=${dataTypeEnums.STRUCTURE}]`);
                    var thisRequestItemTypeFieldId = $(thisDiv).attr("requestitemtypefieldid");
                    var thisRequestItemTypeField = thisRequestItemType.fields.find(x => x.requestTypeFieldId == thisRequestItemTypeFieldId);
                    
                    // Constructing this here instead of trying to infer it from the table row.
                    const structureImageId = `itemType_${requestItemTypeId}_${rowIndex}_${thisRequestItemTypeFieldId}`;

                    itemPromises.push(new Promise(function(resolve, reject) {
                        getChemistryEditorChemicalStructure(structureImageId).then(function(molData) {
                            if (!Object.keys(thisRequestItemTypeField.displayName.toLowerCase()).includes(thisRequestItemTypeField.displayName.toLowerCase())) {
                                rowData[thisRequestItemTypeField.displayName.toLowerCase()] = {data: [], dirty: false};
                            }

                            if (rowData[thisRequestItemTypeField.displayName.toLowerCase()].data.length == 0) {
                                rowData[thisRequestItemTypeField.displayName.toLowerCase()].data.push(molData);
                            }
                            resolve();
                        });
                    }));
                });
            }
    
            // Go through the convertedCSVData and convert it to a format that matches
            // the data structure used for the request item tables.
            tableRows = tableRows.map(function (x) {
                var returnObj = {};
                $.each(Object.keys(x), function (index, key) {
                    if (key != "Name") {
    
                        if (key.toLowerCase() == "structure") {
                            if (x[key] == "undefined") {
                                x[key] = getEmptyMolFile();
                            }
                        }
    
                        var tableVal = x[key];

                        if (!tableVal) {
                            tableVal = [];
                        }

                        if (Object.keys(tableVal).includes("dirty")) {
                            tableVal = tableVal.data;
                        }
    
                        tableVal = Array.isArray(tableVal) ? tableVal : [tableVal];
    
                        var tableData = {
                            dirty: true,
                            data: tableVal
                        };
                        
                        // We need to find this field in the request item type fields list. If it doesn't exist,
                        // then we don't care about it and we can return.
                        var requestItemTypeField = thisRequestItemType.fields.find(x => x.displayName.toLowerCase() == key.toLowerCase());
                        if (!requestItemTypeField) {
                            return;
                        }
                        var requestItemTypeFieldId = requestItemTypeField.requestTypeFieldId;
                        returnObj[requestItemTypeFieldId] = tableData;
                    }
                });
                returnObj['uniqueIdentifier_hidden'] = randomString(32, "#A");
                returnObj["requestItemName"] = Object.keys(returnObj).includes("requestitemname") ? returnObj["requestitemname"]["data"][0] : "";
                returnObj["requestItemId"] = Object.keys(returnObj).includes('requestitemid') ? returnObj["requestitemid"]["data"][0] : 0;
                return returnObj;
            });
    
            Promise.all(itemPromises).then(function() {

                // Check if the table is empty. 
                if (!dataTableModule().checkIfTableIsEmpty(tableId, versionedRequestItems)) {
                    // If we are in here then the table has data we might to keep.
                    // Put the existing rows in the appropriate place.
                    if (fileUploadSetting == "Before") {
                        tableRows = tableRows.concat(existingRows);
                    } else if (fileUploadSetting == "After") {
                        tableRows = existingRows.concat(tableRows);
                    }
                }

                $.each(tableRows, function(rowIndex, tableRow) {
                    tableRow["sortOrder"] = rowIndex + 1;
                });
        
                resolve(tableRows);
            });
        });
    }

    /**
     * Callback function for uploading a file to allow the file import settings modal to resume the upload operation.
     * @param {File} sdFile The SD File being uploaded. Can be null if we're not processing an SD File.
     * @param {*} versionedRequestItems The versioned list of request items.
     * @param {*} versionedFields The versioned list of fields.
     */
    var fileUploadSubmitCallback = function(sdFile, versionedRequestItems, versionedFields) {
        return new Promise(function(resolve, reject) {    
            if ($("#rememberImportSetting").is(":checked")) {
                resolve(ajaxModule().storeFileUploadSetting(companyId, globalUserInfo.userId, fileUploadSetting));
            } else {
                resolve(true);
            }
        }).then(function(response) {
            var fileUploadSetting = $("input[name=fileImportSelect]:checked").val();

            var uploadType = $("#fileImportModal").attr("uploadtype");
            var tableId = $("#fileImportModal").attr("tableid");
            var tableNum = $("#fileImportModal").attr("tablenum");
            var requestObj = JSON.parse($("#fileImportModal").attr("requestobj"));
            var fileExtension = $("#fileImportModal").attr("fileextension");
            var newFileName = $("#fileImportModal").attr("newfilename");
            var requestItemTypeId = $("#fileImportModal").attr("requestitemtypeid");
    
            $("#fileImportModal").modal("hide");
            $("#basicLoadingModal").modal("show");
    
            processTableUpload(tableId, requestObj, fileExtension, newFileName, requestItemTypeId, fileUploadSetting, sdFile, versionedRequestItems, versionedFields);
        });
    }

    var documentReadyFunction = function() {
        
        $("body").on("click", "button.file-upload-setting-cancel", function(event) {
            $("#fileImportModal").modal("hide");
        })
    }

    return {
        displayFileImportOptions: displayFileImportOptions,
        getAcceptedFileTypes: getAcceptedFileTypes,
        makeRequestItemsFileUploadForm: makeRequestItemsFileUploadForm,
        addFragmentsToTable: addFragmentsToTable,
        readSDFile: readSDFile,
        documentReadyFunction: documentReadyFunction
    }
}

tableFileUpload = tableFileUploadModule();

$(document).ready(function() {
    tableFileUpload.documentReadyFunction();
});