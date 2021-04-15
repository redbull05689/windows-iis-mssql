var initNewRequestPromise = [];

var makeNewRequestModule = (function () {

	var hideRequestEditor = function () {
		$('.dropdownEditorContainer').removeClass('makeVisible');
	}


	var showRequestEditor = function (requestId) {
		return new Promise(function (resolve, reject) {
            if (window.location.href.includes("makenewrequest")) {
                resetRequestEditor()
            }

            $('.dropdownEditorContainer').addClass('makeVisible');
            resolve(true);
		});
	}

    var resetRequestEditor = function() {
        $('.dropdownEditorContainer input[type="text"]').val('');
        $('.dropdownEditorContainer input[type="checkbox"]').prop('checked', false);
        $('.dropdownEditorContainer').find('button, input, select').prop('disabled', false);

        var requestId = "";
        
        if (window.self != window.top) {
            requestId = window.parent.$("#requestId").val();
        }

        $('.dropdownEditorContainer').attr('requestid', requestId);
        $('.dropdownEditorContainer').find('#requestFieldsEditorSection .editorSection').empty();
        $('.dropdownEditorContainer .prioritizeThisRequestContainer').remove();
        $('.dropdownEditorContainer .requestItemsEditorSection').attr('requestitemtypeid', null).attr('requestitemid', null).empty();
        $(".requestItemsEditor").remove();
        window.requestItemTypesColumns = {}
        // This .change() is actually changing the request type & assigned group dropdowns - '.parent().change()' may need to be removed if having loading problems...
        $('.dropdownEditorContainer select option:first-of-type').prop('selected', true).parent().change();
    }
  
    var replaceSavedFieldsDropdownOptions = function(replacementDropdowns, versionedFields) {
      // Loop through all the savedFields looking for dropdowns - replace them with the dropdowns in this response
      $.each(versionedFields, function (savedFieldIndex, savedField) {
          if (savedField['dataTypeId'] == 5) {
              $.each(replacementDropdowns, function (replacementDropdownIndex, replacementDropdown) {
                  if (savedField['dropDownId'] == replacementDropdown['id']) {
                      savedField['options'] = replacementDropdown['options'];
                    }
                });
            }
        });
    }
                    
	var disableDisallowedAssignedUserGroups = function (requestType) {
		return new Promise(function (resolve, reject) {
			userGroupsWithCanBeAssigned = []
			if (requestType['allowedGroups'] != null) {
				$.each(requestType['allowedGroups'], function () {
					if (this['canBeAssigned']) {
						userGroupsWithCanBeAssigned.push(this['groupId'])
					}
				});
			}
			var OptionAval = false;
			// Enable & disable options based on settings
			var selectedOpt = undefined;
			$.each($('select#assignedUserGroupDropdown option'), function () {
				if ($(this).prop('selected') == true) {
					selectedOpt = this;
				}
			});

			$.each($('select#assignedUserGroupDropdown option'), function () {
				if ($.inArray(parseInt($(this).attr('groupid')), userGroupsWithCanBeAssigned) > -1) {


					$(this).attr('disabled', false);
					OptionAval = true;
					$(this).prop('selected', true)
				}
				else {
					$(this).attr('disabled', true);
				}
			});

			if (selectedOpt != undefined) {
				$(selectedOpt).prop('selected', true);
			}

			if (!OptionAval) {
				// Enable & disable options based on settings
				$.each($('select#assignedUserGroupDropdown option'), function () {
					if ($.inArray(parseInt($(this).attr('groupid')), globalUserInfo.userGroups) > -1) {
						$(this).attr('disabled', false);
					}
					else {
						$(this).attr('disabled', true);
					}
				});

			}

			// If the selected option is now disabled, select the first enabled option
			if ($('select#assignedUserGroupDropdown option:selected').attr('disabled')) {
				$.each($('select#assignedUserGroupDropdown option'), function () {
					if (!$(this).attr('disabled')) {
						$(this).prop('selected', true);
						return false;
					}
				});
			}
			resolve(true);
		});
	}

    /**
     * Onchange handler for the request type dropdown picker.
     */
    var changeRequestTypeDropdown = function () {
        return new Promise(function (resolve, reject) {
            
            var thisRequestTypeId;

            if (window.self != window.top) {
                thisRequestTypeId = window.parent.$("#requestTypeId").val();
            } else {
                thisRequestTypeId = $('select#requestTypeDropdown').find(":selected").attr("requesttypeid");
            }

            if(window.top.CurrentPageMode == "repeatRequest"){
                resolve(false)
                return
            }

            ajaxModule().getVersionedConfigData(thisRequestTypeId).then(function(configResponses) {
                var thisRequestType = configResponses[2][0];
                var versionedRequestItems = configResponses[1];
                var versionedFields = configResponses[0];

                window.top.thisRequestType = thisRequestType;
                window.top.versionedRequestItems = versionedRequestItems;
                window.top.versionedFields = versionedFields;

                // Check this request type's settings to see if it shows the prioritization on submission, then update
                // the submit button text accordingly.
                var submitButtonText = (thisRequestType['showPrioritizationOnSubmit']) ? "Prioritize & Submit" : "Submit";
                var cancelNewRequestButtonText = "Cancel";
                $(".dropdownEditorContainer").find(".prioritizeNewRequestButton").text(submitButtonText);
                $(".dropdownEditorContainer").find(".cancelNewRequestButton").text(cancelNewRequestButtonText);

                if (typeof thisRequestType !== "undefined") {
                    requestEditorHelper.populateUserGroupsList()
                        .then(disableDisallowedAssignedUserGroups(thisRequestType))
                        .then(function() {
                            var fieldPromises = [];
                            fieldPromises.push(requestEditorHelper.populateRequestFieldsSection(thisRequestType, selectorString = ".editorSection[sectionid='requestFields']", null, true, window.top.versionedFields, window.top.thisRequestType, window.top.versionedRequestItems))
                            fieldPromises.push(requestEditorHelper.populateRequestItemsEditorSectionInRequestEditor(null, thisRequestType, $(".requestItemsEditorSection"), versionedRequestItems, versionedFields));
                            Promise.all(fieldPromises).then(function() {
                                $.each(versionedRequestItems, function(requestItemTypeIndex, requestItem) {
                                    var requestItemTypeId = requestItem.id;
                                    var rowsArray = [{ "uniqueIdentifier_hidden": randomString(32, '#A'), "sortOrder": 1 }];
                                    var columnsArray = dataTableModule().makeColumnsArray(requestItemTypeId, versionedRequestItems, versionedFields);
                                    tableData = { "data": rowsArray, "columns": columnsArray };
                                    dataTableModule().initRequestItemTable(tableData, requestItemTypeId, "", thisRequestType, versionedRequestItems, versionedFields);
                                });
                                requestEditorHelper.populateDraftVals(thisRequestType, versionedRequestItems, versionedFields)
                            });
                        }).then(
                            function () {
                                if (window.self != window.top) {
                                    resolve(true);
                                } else {
                                    requestEditorHelper.bindRichTextFields(versionedRequestItems, versionedFields).then(function () {
                                        requestFieldHelper().applyDependencies(thisRequestType, versionedFields);
                                    });
                                }
                            })
                        .then(function () {
                            resolve(true);
                        });
                }
            });
		});
    }
    
    /**
     * Fetches the list of request types that the current user is allowed to add and builds the request type dropdown with it.
     */
    var populateRequestsTypesListForNewRequestPage = function() {
        return new Promise(function(resolve, reject) {
            ajaxModule().getRequestTypesICanAdd().then(function(response) {
                if (response) {
                    response = utilities().decodeServiceResponce(response);
                    var defaultOptions = 0;
                    var dropdown = $("<select></select>");

                    $.each(response, function(index, requestType) {
                        var requestTypeOption = $("<option></option>")
                            .attr("value", index)
                            .attr("requestTypeId", requestType["id"])
                            .text(requestType["displayName"]);

                        if (requestType["isDefault"] == 1) {
                            dropdown.prepend(requestTypeOption);
                            dropdown.val(index);
                            defaultOptions = index;
                        } else {
                            dropdown.append(requestTypeOption);
                        }
                    
                        if (window.top != window.self) {
                            var reqTypeId = window.parent.$("#requestTypeId").val();
                            if (reqTypeId == requestType['id']) {
                                preSelect = index;
                            }
                        }
    
                    });

                    $("body").addClass("canMakeNewRequest");
                    utilities().sortDropdownlist(dropdown);

                    if ($('select#requestTypeDropdown').children().length == 0) {
    
                        window.savedFieldsOptionsHTML = dropdown.html();
                        $('select#requestTypeDropdown').html(window.savedFieldsOptionsHTML);
    
                        if (window.top != window.self) {
                            console.log(preSelect);
                            $('select#requestTypeDropdown').val(preSelect);
                            console.log("CHANGED IT!")
                        } else {
                            $('select#requestTypeDropdown').val(defaultOptions);
                        }
    
                    }
                }

                resolve(true);
            })
        });
    }

	var makeNewRequestReady = function () {
		window.initOnce = false;
		window.replacementDropdownsByRequestType = {}

        var promiseChain = [];

        if (window.self == window.top) {
            promiseChain.push(populateRequestsTypesListForNewRequestPage());
        }

        Promise.all(promiseChain).then(function () {
            showRequestEditor().then(function () {
                var thisRequestTypeId;

                if (window.self != window.top) {
                    thisRequestTypeId = window.parent.$("#requestTypeId").val();
                } else {
                    thisRequestTypeId = $('select#requestTypeDropdown').find(":selected").attr("requesttypeid");
                }

                initNewRequestPromise.push(changeRequestTypeDropdown());
                Promise.all(initNewRequestPromise).then(function(reply) {

                    if(reply[0] != false)
                    {
                        requestEditorHelper.finalizeRequestEditorInitialization();
                    
                        $('body').on('change', 'select#requestTypeDropdown', function (event) {
                            changeRequestTypeDropdown();
                        });
                    }

                    $('body').on('change', 'select#assignedUserGroupDropdown', function (event) {
                        var replacingOptions = false;
                        if (typeof window.replacementDropdownsByRequestType[requestTypeId] == "undefined" || typeof window.replacementDropdownsByRequestType[thisRequestTypeId][$('.requestEditorContainer.newRequestEditor .editorField[fieldid="assignedUserGroup"] #assignedUserGroupDropdown').val()] == "undefined") {
                            console.log("replaceDropdownOptions: true!");
                            replacingOptions = true;
                        }

                        if (!replacingOptions) {
                            replaceSavedFieldsDropdownOptions(window.replacementDropdownsByRequestType[thisRequestTypeId][$('.requestEditorContainer.newRequestEditor .editorField[fieldid="assignedUserGroup"] #assignedUserGroupDropdown').val()], fields)
                        }
                        changeRequestTypeDropdown();
                    });
                                    
                    $('body').on('click', '.requestEditorCancel', function (event) {
                        hideRequestEditor();
                    });

                    $('body').on('click', '.newRequestButton', function (event) {
                        showRequestEditor();
                    });

                    $("body").on('click', '.structureImageContainer', function (event) {
                        if (!$(".isCheckedOut")[0]) {
                            utilities().showUnsavedChangesNotification();
                        }
                    });

                    $('body').on('click', '.prioritizeNewRequestButton', function (event) {
                        if (!$(".isCheckedOut")[0]) {
                            $(this).attr('disabled', true);
                            requestEditorHelper.clickRequestSubmitButton(null, thisRequestType, versionedRequestItems, versionedFields);
                        }
                        else {

                            if (typeof window.upsertRequestNotification !== "undefined") {
                                window.upsertRequestNotification.update({ 'title': 'Error', 'message': "A structure needs to be checked in.", 'type': "danger" });
                            }
                            else {
                                window.upsertRequestNotification = $.notify({
                                    title: "Error",
                                    message: "A structure needs to be checked in."
                                }, {
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

                    $('body').on('click', '.cancelNewRequestButton', function () {
                        window.location = '/arxlab/workflow';
                    });
                });
            });
        });

	};

	return {
        disableDisallowedAssignedUserGroups: disableDisallowedAssignedUserGroups,
        showRequestEditor: showRequestEditor,
		makeNewRequestReady: makeNewRequestReady
	};

});

$(document).ready(function () {
	makeNewRequestModule().makeNewRequestReady()
});