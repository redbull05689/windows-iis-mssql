var requestItemTableHelpers = (function() {

    /**
     * Sets the defauls for each field in a request item row. 
     * @param {String} tableId The table id for $ ref. 
     * @param {Number} rowNum The row number in question 
     * @param {JSON[]} versionedRequestItems The versioned items to check config. 
     * @param {Bool} enforceDirty OPTINAL: defaults to false but can override dirty flag default to true when needed.
     */
    var setDefaultItemFieldValues = function(tableId, rowNum, versionedRequestItems, enforceDirty = false) {
        return new Promise(function(resolve, reject) {
            if (typeof versionedRequestItems != "undefined") {
                // Loop through each requestItemField, clear out existing error messages, and inject new error messages
                var theTable = $('#'+tableId);
                var requestItemTypeId = theTable.attr("requestitemtypeid");
                
                var itemType = undefined;
                $.each(versionedRequestItems, function(ai, thisItemType) {
                    if(thisItemType.hasOwnProperty('id') && thisItemType['id'] == requestItemTypeId) {
                        itemType = thisItemType;
                        return false;
                    }
                });
    
                if(itemType == undefined || (!itemType.hasOwnProperty('id')) || (!itemType.hasOwnProperty('fields'))) {
                    return true;
                }
                    
                var itemTypeId = itemType['id'];
                console.log('processing default values for request item type: ', itemTypeId);
    
                if( $.fn.DataTable.isDataTable(theTable) ){
                    var redrawRow = false;
                    $.each(theTable.DataTable().cells(), function(cellIndex, theCells){
                        $.each(theCells, function(iCell, cell) {
                            if(cell.hasOwnProperty('row') && cell['row'] != rowNum) {
                                return true;
                            }
                            
                            var theCell = cell;
                            var cellNode = theTable.DataTable().cell({'row':theCell['row'], 'column':theCell['column']}).node();
                            var requestItemNode = $(cellNode).find('[requestitemtypefieldid]');
                            var requestItemTypeFieldId = $(requestItemNode).attr('requestitemtypefieldid');
                            $.each((itemType['fieldsDict']['sortOrder']), function(fieldNum, theFieldId) {
    
                                var theField;
                
                                if (itemType['fieldsDict'][theFieldId].length > 1) {
                                    //var groupId = $("#assignedUserGroupDropdown").val();
                                    var groupId;
                                    var fieldSettings = itemType['fieldsDict'][theFieldId];
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
                                        // loop to the next because we dont have a default for this.
                                        return true;
                                    }
                                 
                                } else {
                                    theField = itemType['fieldsDict'][theFieldId][0];
                                }
    
                                if((!theField.hasOwnProperty('requestTypeFieldId')) || theField['requestTypeFieldId'] != requestItemTypeFieldId) {
                                    return true;
                                }
                                
                                if(theField.hasOwnProperty('defaultValue') && theField['defaultValue'] != null && theField['defaultValue'] != "") {
                                    var thisCell = theTable.DataTable().cell({'row':theCell['row'], 'column':theCell['column']});
                                    $.each($(cellNode).find('[requestitemtypefieldid='+theField["requestTypeFieldId"]+']'), function(nodeIndex, node) {
                                        var element = $(node).find('select option[value="'+theField["defaultValue"]+'"]');
                                        
                                        if ( element.is('option') && (thisCell.data() == null || (thisCell.data().data.length == 1 && thisCell.data().data[0] == null))) {
                                            redrawRow = true;
                                            thisCell.data({data: [parseInt(theField["defaultValue"])], dirty: enforceDirty});
                                        }
                                        else
                                        {
                                            element = $(node).find('input');
                                            if (element.is('input') && (thisCell.data() == null || (thisCell.data().data.length == 1 && thisCell.data().data[0] == null))) {
                                                redrawRow = true;
                                                thisCell.data({data: [theField["defaultValue"]], dirty: enforceDirty});
                                            }
                                        }
                                        // Need to do something here if we want to provide for default file attachments or structures, etc.
                                    });
                                }
                                
                                return false;
                            });
                        });
                    });
                                        
                    if(redrawRow) {
                        theTable.DataTable().row(rowNum).draw("page");
                    }
                }
            }
            resolve(true);
        });
    }

    var checkDropdownDependency = function(val, targetJSON, thisDisplayName, fieldType, select) {
        
        if (Object.keys(targetJSON).includes(val)) {
            var divsToPop = targetJSON[val];

            $.each(divsToPop, function(divIndex, target) {
                var targetFieldId = Object.keys(target)[0];

                var targetDiv;
                if (fieldType == "requestType") {
                    targetDiv = $(".editorField[requesttypefieldid=" + targetFieldId + "]").find("select");
                }
                else {                    
                    var row = $($($(select).parent()).parent()).parent();
                    targetDiv = $(row).find("div[requestitemtypefieldid='" + targetFieldId + "'] > select");
                }                
                
                var targetOptionsHtml = target[targetFieldId];

                // Keep track of the original value.
                var targetVal = $(targetDiv.find("option:selected")).val();
                //var targetText = $(targetDiv.find("option:selected")).text();
                //var targetOption = $("<option></option>").val(targetVal).text(targetText);
                var allowedOptions = [];
                
                targetDiv.empty();

                $.each(targetOptionsHtml, function(targetHtmlIndex, optionHtml) {
                    targetDiv.append(optionHtml);
                    allowedOptions.push(optionHtml.val());
                });

                
                /* Commenting out, but leaving this here for reference:
                We used to allow invalid options to maintain backwards compatibility, but
                that will no longer work because dropdown dependency validation is checked on
                the back end now. This used to force the invalid option into the list of allowed
                options and I was planning on just throwing up an error under the dropdown to tell
                the user that the option is not valid, but I figured out how to make it work.

                if (!allowedOptions.includes(targetVal)) {
                   targetDiv.append(targetOption);
                   allowedOptions.push(targetVal);

                   var errorText = `The current option is invalid under dependency settings from field: ${thisDisplayName}.`;
                   var validOptionNames = targetOptionsHtml.map(x => x.text());
                   validOptionNames.shift(); // Remove the blank value.
                   var validOptionsText = `The current valid options are: ${validOptionNames.join(", ")}.`;
                   $(targetDiv).siblings(errorLabel).text(`${errorText} ${validOptionsText}`);

                   updateField = true;
                }
                */

                utilities().sortDropdownlist(targetDiv);
        
                // Now repopulate the value.
                if (targetDiv.find('option:not([emptyDefaultOption])').length == 1) {
                    targetDiv.find('option:not([emptyDefaultOption])').prop('selected', true);
                } else {
                    targetDiv.find("option[value='" + targetVal + "']").prop("selected", true);
                }

                // Force this option to reset its value if the value is not allowed.
                if (!allowedOptions.includes(targetVal)) {
                    targetDiv.change();
                }
            })

        } else {
            var divsToEmpty = targetJSON["empty"];

            $.each(divsToEmpty, function(divIndex, targetFieldId) {
                
                var targetDiv;

                if (fieldType == "requestType") {
                    targetDiv = $(".editorField[requesttypefieldid=" + targetFieldId + "]").find("select");   
                }
                else {                    
                    var row = $($($(select).parent()).parent()).parent();
                    targetDiv = $(row).find("div[requestitemtypefieldid='" + targetFieldId + "'] > select");
                }

                var targetVal = $(targetDiv.find("option:selected")).val();
                targetDiv.empty();

                var dependencyOption = $("<option></option>");
                dependencyOption.val("");
                dependencyOption.text("-- Dropdown is dependent on field: " + thisDisplayName + " --");
                targetDiv.append(dependencyOption);

                utilities().sortDropdownlist(targetDiv);
        
                // Now repopulate the value.
                if (targetDiv.find('option:not([emptyDefaultOption])').length == 1) {
                    targetDiv.find('option:not([emptyDefaultOption])').prop('selected', true);
                } else {
                    targetDiv.find("option[value='" + targetVal + "']").prop("selected", true)   
                }

                // Force this option to reset its value if the value is not allowed.
                if (!(targetVal == "")) {
                    targetDiv.change();
                }
            });
        }
    }

    var applyCellDependency = function(select, requestItemTypeId, versionedRequestItems, versionedFields) {
        
        if (Array.isArray(versionedRequestItems)) {
            var requestItemType = versionedRequestItems.find(x => x.id == requestItemTypeId);
    
            // Grab the dependencies for this dropdown.
            var parent = $(select).parent();
            var requestItemTypeFieldId = $(parent).attr("requestitemtypefieldid");
            var requestItemTypeField = requestItemType["fieldsDict"][requestItemTypeFieldId][0];
            var fieldDependencies = requestItemTypeField["requestItemTypeFieldDropDownDependencies"];
    
            // While we're at it, get this dropdown's display name.
            var thisSavedFieldId = requestItemTypeField["savedFieldId"];
            var thisSavedField = versionedFields.find(x => x.id == thisSavedFieldId);
            var thisDisplayName = thisSavedField["displayName"];
    
            // Make a global default option.
            var emptyDefaultOption = $("<option emptydefaultoption></option>");
            emptyDefaultOption.val("");
            emptyDefaultOption.text("-- Make a Selection --");
            
            var targetJSON = {
                empty: []
            };
    
            // Now, go through the field dependencies.
            $.each(fieldDependencies, function(depIndex, dependency) {
    
                // Pull out the variables from the dependency object.
                var dropdownOptionId = dependency["dropDownOptionId"];
                var targetFieldId = dependency["targetRequestItemTypeFieldId"];
    
                // Pull out the target values from the list of dependency value objects.
                var targetValues = dependency["requestItemTypeFieldDropDownDependencyValues"].map(x => x.targetDropDownOptionId);
    
                // Now figure out what our target field is, along with all of its IDs.
                var targetField = requestItemType["fieldsDict"][targetFieldId][0];
                var targetSavedFieldId = targetField["savedFieldId"];
                var targetSavedField = versionedFields.find(x => x.id == targetSavedFieldId);
    
                // Filter down the options to the ones that are indicated by targetValues.
                var targetOptions = targetSavedField["options"].filter(x => targetValues.includes(x.dropdownOptionId));
    
                // Build an HTML option from each target option, then pre-pend the global default.
                var targetOptionsHtml = targetOptions.map(function(option) {
                    var optionHtml = $("<option></option>");
                    optionHtml.val(option["dropdownOptionId"]);
                    optionHtml.text(option["displayName"]);
                    return optionHtml;
                });
                targetOptionsHtml.unshift(emptyDefaultOption.clone());
    
                if (!Object.keys(targetJSON).includes(dropdownOptionId.toString())) {
                    console.log("Logging some nonsense to make sure multiple dependencies don't break.");
                    targetJSON[dropdownOptionId] = [];
                }
    
                var targetObj = {};
                targetObj[targetFieldId] = targetOptionsHtml;
                targetJSON[dropdownOptionId].push(targetObj);
    
                if (!targetJSON["empty"].includes(targetFieldId)) {
                    targetJSON["empty"].push(targetFieldId);
                }
                
            });
                
            // Make an event listener for this dropdown.
            $(select).change(function() {
                checkDropdownDependency($(this).val(), targetJSON, thisDisplayName, "requestItemType", select);
            });
    
            // Now make sure the listener is actually run on the first run.
            checkDropdownDependency($(select).val(), targetJSON, thisDisplayName, "requestItemType", select);

        }
    }

    var applyItemDependencies = function(tableId, rowNum, versionedRequestItems, versionedFields) {
        // Start by finding the table and getting its request item type id.
        var tableIdStr = '#'+tableId;
        var theTable = $(tableIdStr);
        var requestItemTypeId = theTable.attr("requestitemtypeid");

        // Now get the row we care about, and pull out its dropdowns.
        var tableRows = $("table" + tableIdStr + " > tbody > tr");
        var row = tableRows[rowNum];
        var dropdowns = $(row).find("select");

        // Now, run through each dropdown.
        $.each(dropdowns, function(selIndex, select) {
            applyCellDependency(select, requestItemTypeId, versionedRequestItems, versionedFields);
        });
    }

    return {
        setDefaultItemFieldValues: setDefaultItemFieldValues,
        applyItemDependencies: applyItemDependencies,
        checkDropdownDependency: checkDropdownDependency
    }
})