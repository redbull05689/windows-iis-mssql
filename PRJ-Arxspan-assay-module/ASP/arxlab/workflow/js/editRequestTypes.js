
// Mapping of attribute data types.
const CUST_ATTR_DATA_TYPES = {
	STRING: 1,
	NUMERIC: 2,
	DATE: 3,
	LONG_TEXT: 4,
	BOOLEAN: 5,
	DROP_DOWN: 6,
};

// Labels for the above data types.
let CUST_ATTR_DATA_TYPE_LABELS = {};
CUST_ATTR_DATA_TYPE_LABELS[CUST_ATTR_DATA_TYPES.STRING] = "String";
CUST_ATTR_DATA_TYPE_LABELS[CUST_ATTR_DATA_TYPES.NUMERIC] = "Numeric";
CUST_ATTR_DATA_TYPE_LABELS[CUST_ATTR_DATA_TYPES.DATE] = "Date";
CUST_ATTR_DATA_TYPE_LABELS[CUST_ATTR_DATA_TYPES.LONG_TEXT] = "Long Text";
CUST_ATTR_DATA_TYPE_LABELS[CUST_ATTR_DATA_TYPES.BOOLEAN] = "Boolean";
CUST_ATTR_DATA_TYPE_LABELS[CUST_ATTR_DATA_TYPES.DROP_DOWN] = "Drop Down";

// Global objects to hold onto attribute definitions.
// Not a fan but I couldn't figure out a better way of keeping these definitions accessible.
let custAttrDefList = [];
let requestTypeCustomAttributeDefinitions = [];

var editRequestTypes = function() {

	// This is used to convert 0 to A, 1 to B, etc.
	var fieldGroups = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var fieldGroupsDropdown = $('<select class="fieldGroupDropdown editorFieldDropdown">').html('<option value=""></option>');

	var resetRequestTypeEditor = function() {
		custAttrDefList = [];
		requestTypeCustomAttributeDefinitions = [];
		$('.dropdownEditorContainer input[type="text"]').val('');
		$('.dropdownEditorContainer input[type="checkbox"]').prop('checked',false);
		$('.dropdownEditorContainer').find('button, input, select').prop('disabled',false)
		$('.dropdownEditorContainer select option:first-of-type').prop('selected',true)
		$('.dropdownEditorContainer').removeClass('isSavedField');
		$('.dropdownEditorContainer').attr('requesttypeid',"");
		$('.dropdownEditorContainer').attr('datatypeid',"")
		$('table#requestTypeFieldsTable > tbody').empty();
		$('table#requestTypeRequestItemTypesTable > tbody').empty();
		$('#requestTypeAllowedUsersEditorSection, #requestTypeAllowedGroupsEditorSection, .requestTypeFieldNotificationsContainer').removeClass('makeVisible');
		$('select#requestTypesDropdownForNotificationSettings').empty();

		$("select#requestTypeAllowedAppsSelect").empty();
		$("select#requestTypeAllowedAppsSelect").val(null)
		$("select#requestTypeAllowedAppsSelect").attr("multiple", false);
		$("select#requestTypeAllowedAppsSelect").attr("disabled", false);
		$("#requestTypeCustomAttributesTable > tbody").empty();
		$("#requestTypeAttributeTable").hide();
		$("#requestTypeFieldAttributesTable").hide();
	
		if(window.requestTypePageMode == "requestItemTypes"){
			$(".editorField[fieldid='colabNotification']").hide();
			$(".editorField[fieldid='showPrioritizationOnSubmit']").hide();
			$("#requestTypeAllowedAppsEditorSection").hide();
		}
		else 
		{
			$("#requestNameOptions").removeClass("in")
			$("#requestTypeAllowedAppsEditorSection").show();
		}
	}

	/**
	 * Creates and displays the request type editor for the given request type ID.
	 * @param {number} requestTypeId The request type ID we want to edit.
	 */
	var showRequestTypeEditor = async function(requestTypeId){
		resetRequestTypeEditor();

		let appList = [];
		if (window.requestTypePageMode == "requestTypes") {
			appList = await ajaxModule().getAllowedApps();
			await populateApplications(appList);
		}

		if(!requestTypeId){
			$('.dropdownEditorContainer').addClass('makeVisible');
			if(window.requestTypePageMode == "requestTypes"){
				addRequestItemTypeToEditor();
			}
			$('.dropdownEditorContainer .editorField[fieldid="displayName"] input[type="text"]').focus();
			$('#configRequestNotifications').attr("requesttypeid", -1)
			$(".requestTypeReprioritizationNotificationsContainer").hide();			
			await updateCustAttrDefs($("#requestTypeAllowedAppsSelect").val());
		}
		else{
			$('.dropdownEditorContainer').attr('requesttypeid',requestTypeId);
			var requestType = window.pageModeRequestTypes.find(x => x.id == requestTypeId);
			if (requestType) {
				if (requestType["requestTypeCustomAttributeDefinitions"].length > 0) {
					requestTypeCustomAttributeDefinitions =	requestType["requestTypeCustomAttributeDefinitions"];
				}

				$('.dropdownEditorContainer .editorField[fieldid="displayName"] input[type="text"]').val(requestType['displayName'])
				$('.dropdownEditorContainer .editorField[fieldid="hoverText"] input[type="text"]').val(requestType['hoverText'])

				$("#staticNameString").val(requestType["reqNamePrefix"]);
				$("#staticNameSortOrder").val(requestType["reqNamePrefixOrder"]);

				$("#requestNameSelectField").attr("saveditem", requestType["reqNameRequestTypeFieldId"]);
				$("#groupSortOrder").val(requestType["reqNameUseUserGroupIdOrder"]);

				$("#useAssignedGroup").prop('checked', requestType["reqNameUseUserGroupId"] == 1);
				$("#fieldInNameSortOrder").val(requestType["reqNameRequestTypeFieldIdOrder"]);

				if (requestType["reqNameUseIncrementingNumbersCode"] != null)
				{
					$("#selectIncromentingNum").val(requestType["reqNameUseIncrementingNumbersCode"]);
				}
				else 
				{
					$("#selectIncromentingNum").val(0)
				}

				$("#incromentingNumSortOrder").val(requestType["reqNameUseIncrementingNumbersCodeOrder"]);
				
				if (window.requestTypePageMode == "requestTypes")
				{
					$('#configRequestNotifications').attr('requestTypeNotificationGroupSettings', stringNotifications(requestType["requestTypeNotificationGroupSettings"]));
					$('#configRequestNotifications').attr('requestTypeNotificationUserSettings', stringNotifications(requestType["requestTypeNotificationUserSettings"]));
					$('#configRequestNotifications').attr('requestTypeNotificationOtherUserSettings', stringNotifications(requestType["requestTypeNotificationOtherUserSettings"]));
				}
				else
				{
					$('#configRequestNotifications').hide();
				}

				var greatestFieldGroupNumber = 0;
				var processedRequestTypeFieldIds = [];
				$.each(requestType['fields'], function(index, field){
					if(field['fieldGroup'] > greatestFieldGroupNumber && processedRequestTypeFieldIds.indexOf(field['requestTypeFieldId']) == -1){
						processedRequestTypeFieldIds.push(field['requestTypeFieldId']);
						greatestFieldGroupNumber = field['fieldGroup'];
					}
				});
				updateGlobalFieldGroupsDropdown(greatestFieldGroupNumber);
				
				if(!requestType['frozenColumnsLeft']){
					requestType['frozenColumnsLeft'] = 0;
				}
				$('.dropdownEditorContainer .editorField[fieldid="frozenColumnsLeft"] input[type="number"]').val(requestType['frozenColumnsLeft']);

				processedRequestTypeFieldIds = [];
				$.each(requestType['fields'], function(index, field){
					var requestTypeFieldId = field["requestTypeFieldId"];

					// We only want to add each field to the editor once. This can be deprecated when we
					// figure out how to undo the cludge with the duplicate field rows for every default value.
					if(processedRequestTypeFieldIds.indexOf(requestTypeFieldId) == -1) {
						processedRequestTypeFieldIds.push(requestTypeFieldId);
						addRequestTypeFieldToEditor(field);
					}
					
					// Regardless of whether or not we're adding this field to the editor, we do want to
					// add this field's default value to the field row's metadata.
					var thisRow = $(`tr[requesttypefieldid=${requestTypeFieldId}]`);

					// If we do not yet have a defaultValueJson attr set in the row, create an empty one and add it.
					if (thisRow.attr("defaultValueJson") == undefined) {
						var initDefaultValueJson = {
							company: null,
							user: {},
							group: {},
						};
						thisRow.attr("defaultValueJson", JSON.stringify(initDefaultValueJson));
					}

					// Pull out the default value JSON and add to it based on what kind of default value we have.
					var defaultValueJson = JSON.parse(thisRow.attr("defaultValueJson"));
					if (field["userDefaultValue"]) {
						defaultValueJson["user"][field["userId"]] = field["userDefaultValue"];
					} else if (field["groupDefaultValue"]) {
						defaultValueJson["group"][field["groupId"]] = field["groupDefaultValue"];
					} else if (field["defaultValue"]) {
						defaultValueJson["company"] = field["defaultValue"];
					}

					// Now set it back into the row.
					thisRow.attr("defaultValueJson", JSON.stringify(defaultValueJson));
				});
				
				if(requestType['requestItemTypes']){
					$.each(requestType['requestItemTypes'], function(index, requestItemType){
						addRequestItemTypeToEditor(requestItemType);
					});
				}

				$('.dropdownEditorContainer .editorField[fieldid="requiresApproval"] input[type="checkbox"]').prop('checked',requestType['requiresApproval']);

				$('.dropdownEditorContainer .editorField[fieldid="isDefault"] input[type="checkbox"]').prop('checked',requestType['isDefault']);

				if (requestType.hasOwnProperty("notifyColabs"))
				{	
					$('.dropdownEditorContainer .editorField[fieldid="colabNotification"] input[type="checkbox"]').prop('checked',requestType['notifyColabs']);
				}
				$('.dropdownEditorContainer .editorField[fieldid="restrictAccess"] input[type="checkbox"]').prop('checked',requestType['restrictAccess']).change();
				$('.dropdownEditorContainer .editorField[fieldid="showPrioritizationOnSubmit"] input[type="checkbox"]').prop('checked',requestType['showPrioritizationOnSubmit']).change();
				
				$('.dropdownEditorContainer .editorField[fieldid="searchRegForExistingCompound"] input[type="checkbox"]').prop('checked',requestType['searchRegForExistingCompound']).change();
				$('.dropdownEditorContainer .editorField[fieldid="registerNewCompounds"] input[type="checkbox"]').prop('checked',requestType['registerNewCompounds']).change();
				$('.dropdownEditorContainer .editorField[fieldid="checkIfStructIsRequestedBeforeReg"] input[type="checkbox"]').prop('checked',requestType['checkIfStructIsRequestedBeforeReg']).change();

				$('.dropdownEditorContainer .editorField[fieldid="genNotebook"]').empty();
				$('.dropdownEditorContainer .editorField[fieldid="genProject"]').empty();

				populateRestrictAccessSettingsTables('requestType', requestType['allowedUsers'], requestType['allowedGroups']);

				if (requestType['allowedApps']) {
					let allowedIds = appList.map(allowedApp => allowedApp.name in requestType["allowedApps"] ? allowedApp.id : null)
										.filter(x => x);

					let multipleIds = allowedIds.length > 1;
					$("#requestTypeAllowedAppsSelect").attr("multiple", multipleIds);
					if (multipleIds) {
						$("#requestTypeAllowedAppsSelect").val(allowedIds);
					} else if (allowedIds.length == 1) {				
						$("#requestTypeAllowedAppsSelect").val(allowedIds[0]);
						await updateCustAttrDefs(allowedIds[0]);
					}

					$("select#requestTypeAllowedAppsSelect").attr("disabled", true);
				}

				if (requestType["requestTypeCustomAttributeValues"]) {
					requestType["requestTypeCustomAttributeValues"].forEach(function(val, index) {
						addCustomAttributeToEditor(val, requestType["requestTypeCustomAttributeDefinitions"]);
					});
				}

				if(window.requestTypePageMode == "requestTypes"){
					if(requestType['requestTypeReprioritizationNotificationGroupSettings']){
						$.each(requestType['requestTypeReprioritizationNotificationGroupSettings'], function(){
							$('table#requestTypeReprioritizationNotificationsTable').find('tr[groupid="'+this['groupId']+'"] input.notifyByEmailCheckbox').prop('checked',this['notifyByEmail']);
						});
					}
					$("#numFrozenColumns").attr("max", "5")

					$("input[name='SortSelect']").on("mouseup", function(event){
						if (window.top.isSupport == false)
						{
							if ($("input[name='SortSelect']:checked").length == 0)
							{
								swal({
									title: "Once you save this option you will not have the ability to change or modify it.",
									text: "Are you sure you want to make this change?",
									type: "warning",
									confirmButtonText: "Yes",
									cancelButtonText: "No",
									showCancelButton: true
								},
								function (isConfirm) {
									if (isConfirm) {
										$(event.target).closest('tr').attr("filterField", "1");
									}
									else {
										$(event.target).prop('checked', false);
									}
			
								});
							}
							else 
							{
								window.top.preventClick = true;
							}
						}
						else{
							$("tr[filterField='1']").attr("filterField", "");
							$(event.target).closest('tr').attr("filterField", "1");
						}
					});	

					$("input[name='SortSelect']").on("click", function(event){
						if (window.top.preventClick == true)
						{
							event.preventDefault();
							swal("Please contact support@arxspan.com!", "This action may lead to data loss.", "warning");
							window.top.preventClick = false;
						}
						console.log(event)
					});
				}
				else 
				{
					$('div[fieldid="checkIfStructIsRequestedBeforeReg"]').hide();
				}

				if (requestType['disabled'] == true)
				{
					requestType['disabled'] = true;
				}
				else 
				{
					requestType['disabled'] = false;
				}

				$('.dropdownEditorContainer .editorField[fieldid="disabled"] input[type="checkbox"]').prop('checked',requestType['disabled']);

				$('.dropdownEditorContainer').attr('requesttypeid',requestType['requestTypeId']);

				$('#configRequestNotifications').attr("requesttypeid", requestTypeId);

				// If this is the requestItemTypes page, we need to make the notification settings requestTypes dropdown
				if(window.requestTypePageMode == "requestItemTypes"){
					var requestType_requestItemTypesDropdownOptionsArray = [];
					$.each(window.requestTypesArray, function(reqTypeIndex, reqType){
						// Add requestTypes which use this requestItemType
						$.each(reqType['requestItemTypes'], function(){
							if(this['requestItemTypeId'] == requestType['id']){
								var dataTypeOption = $('<option></option>').attr('value',this['requestItemId']).text(reqType['displayName'])
								requestType_requestItemTypesDropdownOptionsArray.push(dataTypeOption)
							}
						})
					});
					$('select#requestTypesDropdownForNotificationSettings').append(requestType_requestItemTypesDropdownOptionsArray)
					$("#requestTypeIncludeOnDash").text("");
				}
			}
			$('.dropdownEditorContainer').addClass('makeVisible isSavedField');
		}
	
		$(".ui-sortable" ).sortable({
			start: function( event, ui ) 
			{
				utilities().showUnsavedChangesNotification();
			}
		});
	
		$('.main-panel').scrollTop(0);


		if ( window.requestTypePageMode != "requestTypes")
		{
			$('#configRequestNameAccord').hide();
		}
		
		if (window.historical == true)
		{
			$(".dropdownEditorSubmit ").remove()
		}

	
	}

	var hideRequestTypeEditor = function() {
		$('.dropdownEditorContainer').removeClass('makeVisible');
	}

	/**
	 * Helper function to check if there are any permissions in the given permissionsList
	 * that are turned on.
	 * @param {JSON[]} permissionsList The list of permissions to check.
	 * @param {string[]} permissionNamesList The list of permission names to check.
	 */
	let checkIfAnyPermissions = function(permissionsList, permissionNamesList) {
		let anyPermissions = false;

		permissionNamesList.some(function(permName) {
			let hasPermission = permissionsList.some(perm => perm[permName] == 1);
			if (hasPermission) {
				anyPermissions = hasPermission;
			}
		})

		return anyPermissions;
	}

	/**
	 * Packages and submits the current request item type editor.
	 */
	var submitRequestItemTypeEditor = function() {
		return new Promise(function(resolve, reject) {
			editor = $('.dropdownEditorContainer');
	
			var requestTypeName = editor.find('[fieldid="displayName"] input[type="text"]').val();
			if(window.requestTypePageMode == "requestTypes"){
				var reqTypeOrReqItemTypeNotificationText = "request type";
			}
			else{
				var reqTypeOrReqItemTypeNotificationText = "request item type";
			}
	
			if(editor.attr('requesttypeid') !== ""){
				var notificationTitle = 'Updating ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '"...';
			}
			else{
				var notificationTitle = 'Creating new ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '"...';
			}
	
			window.upsertRequestTypeNotification = $.notify({
			title: notificationTitle,
			message: ""
			},{
			delay: 0,
			type: "yellowNotification" 
			});
	
			var requestTypeId = editor.attr('requesttypeid') !== "" ? parseInt(editor.attr('requesttypeid')) : 0;
			var requestItemTypePermArray = [];
			//$.each(editor.find('table#requestTypeAllowedUsersTable tbody tr'), function(){
			$.each(editor.find('.allowedUsers > button'), function(){
				var userId = parseInt($(this).attr("userid"));
	
				allowedUser = {
					"requestItemTypeId": requestTypeId,
					"allowedUserId": userId,
					"allowedGroupId": null,
					"canAdd": utilities().boolToInt($(".CanAddCheckbox[userId=" + userId + "]").prop("checked")),
					"canView": utilities().boolToInt($(".CanViewCheckbox[userId=" + userId + "]").prop("checked")),
					"canEdit": utilities().boolToInt($(".CanEditCheckbox[userId=" + userId + "]").prop("checked")),
					"canDelete": utilities().boolToInt($(".CanDeleteCheckbox[userId=" + userId + "]").prop("checked"))
				}
				requestItemTypePermArray.push(allowedUser);
			});
	
			//$.each(editor.find('table#requestTypeAllowedUsersTable tbody tr'), function(){
			$.each(editor.find('.allowedGroups > button'), function(){
				var groupId = parseInt($(this).attr("groupid"));
	
				allowedGroup = {
					"requestItemTypeId": requestTypeId,
					"allowedUserId": null,
					"allowedGroupId": groupId,
					"canAdd": utilities().boolToInt($(".CanAddCheckbox[groupId=" + groupId + "]").prop("checked")),
					"canView": utilities().boolToInt($(".CanViewCheckbox[groupId=" + groupId + "]").prop("checked")),
					"canEdit": utilities().boolToInt($(".CanEditCheckbox[groupId=" + groupId + "]").prop("checked")),
					"canDelete": utilities().boolToInt($(".CanDeleteCheckbox[groupId=" + groupId + "]").prop("checked"))
				}
				requestItemTypePermArray.push(allowedGroup);
			});

			let restrictAccess = utilities().boolToInt(editor.find('[fieldid="restrictAccess"] input[type="checkbox"]').prop('checked'));
			let permissionTypesList = ["canAdd", "canView", "canEdit", "canDelete"];

			if (restrictAccess == 1 && !checkIfAnyPermissions(requestItemTypePermArray, permissionTypesList)) {
				//nobody can add so fail the submit
				window.upsertRequestTypeNotification.update({
					title: "There are no permissions set on this restricted request item type.",
					message: "Please select permissions to continue.",
					type: "danger" 
				});

				reject();
				return;
			}
	
			typeFieldsArray = [];
			$.each(editor.find('table#requestTypeFieldsTable > tbody > tr'), function(requestTypeFieldIndex){
	
				requestTypeFieldId = 0;
				if($(this).attr('requesttypefieldid')){			
					requestTypeFieldId = $(this).attr('requesttypefieldid');			
				}
				
				savedFieldId = $(this).find('select.savedFieldDropdown option:selected').attr("savedfieldid");		
				var dataTypeId = parseInt($(this).attr('datatypeid'));
	
				var defaultValue = "";
				var defaultValueJson = {};
				var defaultValueAttr = $(this).attr("defaultvaluejson");
				if (defaultValueAttr) {
					defaultValueJson = JSON.parse(defaultValueAttr);
				}
				
				if($.inArray(dataTypeId, [dataTypeEnums.TEXT, dataTypeEnums.LONG_TEXT, dataTypeEnums.INTEGER, dataTypeEnums.REAL_NUMBER, dataTypeEnums.DROP_DOWN]) > -1 && defaultValueJson["company"]){
					defaultValue = defaultValueJson["company"];
				}

				var requestItemTypeFieldDefaultValuesByGroupArray = packageDefaultValuesForSubmission(defaultValueJson, "group");
				var requestItemTypeFieldDefaultValuesByUserArray = packageDefaultValuesForSubmission(defaultValueJson, "user");
	
				fieldGroup = null;
				if($(this).find('td.requestTypeFieldGroupTD select.fieldGroupDropdown').val() !== ""){
					fieldGroup = parseInt($(this).find('td.requestTypeFieldGroupTD select.fieldGroupDropdown').val())+1;
				}
	
				var filterValue;
				if ($(this).find('#SortDropDown').length != 0)
				{//this is the Drop Down (data type ID = 5)
					filterValue = $($(this).find('#SortDropDown')[0]).val();
				}
				else if ($(this).find('#SortLabel').length != 0)
				{//this is the text box (data type ID = 1)
					filterValue = $($(this).find('#SortLabel')[0]).val();
				}

				filterValue = filterValue ? filterValue : null;

				var biDirectionalLink = checkForNewBidirectionalField(requestTypeFieldId, dataTypeId) ? 1 : utilities().boolToInt($(this).attr('biDirectinalLink') == 'true');
	
				//Note: unique ids need to be cleared on repeat requests 
				var thisField = {
					"id": requestTypeFieldId,
					"fieldId": savedFieldId,
					"required": utilities().boolToInt(parseInt($(this).attr('isrequired'))),
					"allowMultiple": utilities().boolToInt(parseInt($(this).attr('allowmultiple'))),
					"disabled": utilities().boolToInt(parseInt($(this).attr('isdisabled'))),
					"sortOrder": requestTypeFieldIndex+1,
					"restrictAccess": utilities().boolToInt(parseInt($(this).attr('restrictaccess'))),
					"defaultValue": defaultValue,
					"requestItemTypeFieldDefaultValuesByGroups": requestItemTypeFieldDefaultValuesByGroupArray,
					"requestItemTypeFieldDefaultValuesByUsers": requestItemTypeFieldDefaultValuesByUserArray,
					"fieldGroup": fieldGroup,
					"clearWhenDuplicate": dataTypeId == dataTypeEnums.UNIQUE_ID? 1 : utilities().boolToInt(parseInt($(this).attr('clearWhenDuplicate'))),
					"filterField": utilities().boolToInt($(this).find('input[type=radio]').prop('checked')),
					"filterValue": filterValue,
					"autoGenerateNotebook": utilities().boolToInt($(this).attr('autoGenNotebook') == 'true'),
					"autoGenerateExperiment": utilities().boolToInt($(this).attr('autoGenExperement') == 'true'),
					"autoGenerateProject": utilities().boolToInt($(this).attr('autoGenProject') == 'true'),
					"bidirectionalRequestLinking": biDirectionalLink,
					"sendToELN": utilities().boolToInt($(this).attr("sendToELN") == "true"),
				};
				
				if($(this).attr('notificationsettings')){			
					notificationGroupSettingArray = [];
					var notificationSettingsObject = JSON.parse($(this).attr('notificationsettings'));
					$.each(Object.keys(notificationSettingsObject), function(notificationIndex, notificationSettingKey) {
						
						var notificationGroupSetting = notificationSettingsObject[notificationSettingKey];
						var notificationSettingsArray = notificationGroupSetting["groups"];
	
						$.each(notificationSettingsArray, function(notificationSettingsIndex, notificationSetting) {
							thisSetting = {
								"requestItemTypeFieldId": requestTypeId,
								"groupId": notificationSetting["groupId"],
								"notifyByEmail": utilities().boolToInt(notificationSetting["notifyByEmail"]),
								"notifyByBrowser": utilities().boolToInt(notificationSetting["notifyByBrowser"])
							};
							notificationGroupSettingArray.push(thisSetting);
						});
					});
					thisField["requestItemTypeFieldNotificationGroupSettings"] = notificationGroupSettingArray;
				}
	
				thisField["requestItemTypeFieldNotificationUserSettings"] = null
				
				fieldPermArray = [];
	
				if($(this).attr('restrictaccesssettings')){
					var restrictAccessSettingsObject = JSON.parse($(this).attr('restrictaccesssettings'));
					var allowedUsers = restrictAccessSettingsObject['users'];
					var allowedGroups = restrictAccessSettingsObject['groups'];
	
					// Note: unique id is a system generated value and anyone can add it
					if (allowedUsers) {
						$.each(allowedUsers, function(userIndex, allowedUser) {
							thisPerm = {
								"requestItemTypeFieldId": requestTypeId,
								"allowedUserId": allowedUser["userId"],
								"allowedGroupId": null,
								"canAdd": utilities().boolToInt(dataTypeId == dataTypeEnums.UNIQUE_ID? true : allowedUser["canAdd"]),
								"canEdit": utilities().boolToInt(allowedUser["canEdit"]),
								"canView": utilities().boolToInt(allowedUser["canView"]),
								"canDelete": utilities().boolToInt(allowedUser["canDelete"])
							}
							fieldPermArray.push(thisPerm);
						});
					}
	
					// Note: unique id is a system generated value and anyone can add it
					if (allowedGroups) {
						$.each(allowedGroups, function(userIndex, allowedGroup) {
							thisPerm = {
								"requestItemTypeFieldId": requestTypeId,
								"allowedUserId": null,
								"allowedGroupId": allowedGroup["groupId"],
								"canAdd": utilities().boolToInt(dataTypeId == dataTypeEnums.UNIQUE_ID? true : allowedGroup["canAdd"]),
								"canEdit": utilities().boolToInt(allowedGroup["canEdit"]),
								"canView": utilities().boolToInt(allowedGroup["canView"]),
								"canDelete": utilities().boolToInt(allowedGroup["canDelete"])
							}
							fieldPermArray.push(thisPerm);
						});
					}
	
					
					if (thisField['required'] == 1 && thisField["restrictAccess"] == 1)//check to see if field is required 
					{
						//get all users/ groups that can add 
						var canAddItems = fieldPermArray.filter(x => x.canAdd == 1);
	
						//check to make sure someomne can add
						if (canAddItems.length == 0 || canAddItems == undefined)
						{
	
							//nobody can add so fail the submit
							window.upsertRequestTypeNotification.update({
									title: `Request field "${$(this).find('select.savedFieldDropdown option:selected').html()}" is required but no users or groups have the "Add" permission.`,
									message: "",
									type: "danger" 
									});
							
									reject();
						}					
	
					}
	
	
					thisField["requestItemTypeFieldsPermissions"] = fieldPermArray;
				}
	
				var dropdownRelations = $(this).attr("dropdownrelations");
				thisField["requestItemTypeFieldDropDownDependencies"] = dropdownRelations !== undefined ? JSON.parse(dropdownRelations) : [];
	
				typeFieldsArray.push(thisField);
	
				/*
				if ($(this).attr("dropdownrelations") !== undefined) {
					thisSavedField["dropdownRelations"] = JSON.parse($(this).attr("dropdownrelations"));
				}*/
			});
	
			var frozenColumnsLeftValue = parseInt(editor.find('[fieldid="frozenColumnsLeft"] input[type="number"]').val());
			if(isNaN( frozenColumnsLeftValue )){
				frozenColumnsLeftValue = 0;
			}
			
			if (frozenColumnsLeftValue > typeFieldsArray.length) {
				window.upsertRequestTypeNotification.update({'title': "Error!", 'message': "The number of frozen columns cannot exceed the total number of fields on this table!", type: "danger"});
				return;
			}

			if (frozenColumnsLeftValue < 0) {
				window.upsertRequestTypeNotification.update({'title': "Error!", 'message': "The number of frozen columns must not be negative!", type: "danger"});
				return;
			}

			data = {
				"appName": "Configuration",
				"requestItemType": {
					"id": requestTypeId,
					"displayName": requestTypeName,
					"hoverText": editor.find('[fieldid="hoverText"] input[type="text"]').val(),
					"restrictAccess": restrictAccess,
					"requiresApproval": utilities().boolToInt(editor.find('[fieldid="requiresApproval"] input[type="checkbox"]').prop('checked')),
					"disabled": utilities().boolToInt(editor.find('[fieldid="disabled"] input[type="checkbox"]').prop('checked')),
					"isDefault": utilities().boolToInt(editor.find('[fieldid="isDefault"] input[type="checkbox"]').prop('checked')),
					"searchRegForExistingCompound": utilities().boolToInt(editor.find('[fieldid="searchRegForExistingCompound"] input[type="checkbox"]').prop('checked')),
					"registerNewCompounds": utilities().boolToInt(editor.find('[fieldid="registerNewCompounds"] input[type="checkbox"]').prop('checked')),
					"frozenColumnsLeft": frozenColumnsLeftValue,
					"requestItemTypePermissions": requestItemTypePermArray,
					"requestItemTypeFields": typeFieldsArray
				}
			}
			
			var serviceObj = {
				configService: true,
			};
			utilities().makeAjaxPost(configServiceEndpoints.REQUEST_ITEM_TYPES_UPSERT, data, serviceObj).then(function(response) {
				console.log(response);
				resolve(response);
			}).catch(function(response) {
				console.log("error");
				if(requestTypeId){
					notificationTitle = 'Failed to update ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '".';
				}
				else{
					notificationTitle = 'Failed to create new "' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '".';
				}
				window.upsertRequestTypeNotification.update({'title': notificationTitle, 'message': "", type: "danger"})
			});
		});
	}

	/**
	 * Packages and submits the current request type editor.
	 */
	var submitRequestTypeEditor = function() {
		return new Promise(function(resolve, reject) {
			editor = $('.dropdownEditorContainer');
	
			var requestTypeName = editor.find('[fieldid="displayName"] input[type="text"]').val();
			if(window.requestTypePageMode == "requestTypes"){
				var reqTypeOrReqItemTypeNotificationText = "request type";
			}
			else{
				var reqTypeOrReqItemTypeNotificationText = "request item type";
			}
	
			if(editor.attr('requesttypeid') !== ""){
				var notificationTitle = 'Updating ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '"...';
			}
			else{
				var notificationTitle = 'Creating new ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '"...';
			}
	
			window.upsertRequestTypeNotification = $.notify({
			title: notificationTitle,
			message: ""
			},{
			delay: 0,
			type: "yellowNotification" 
			});
	
			var requestTypeId = editor.attr('requesttypeid') !== "" ? parseInt(editor.attr('requesttypeid')) : 0;
			var requestTypePermArray = [];
			//$.each(editor.find('table#requestTypeAllowedUsersTable tbody tr'), function(){
			$.each(editor.find('.allowedUsers > button'), function(){
				var userId = parseInt($(this).attr("userid"));
	
				allowedUser = {
					"requestTypeId": requestTypeId,
					"allowedUserId": userId,
					"allowedGroupId": null,
					"canAdd": utilities().boolToInt($(".CanAddCheckbox[userId=" + userId + "]").prop("checked")),
					"canView": utilities().boolToInt($(".CanViewCheckbox[userId=" + userId + "]").prop("checked")),
					"canEdit": utilities().boolToInt($(".CanEditCheckbox[userId=" + userId + "]").prop("checked")),
					"canDelete": utilities().boolToInt($(".CanDeleteCheckbox[userId=" + userId + "]").prop("checked")),
					"canBeAssigned": utilities().boolToInt($(".CanBeAssignedCheckbox[userId=" + userId + "]").prop("checked")),
					//"onlyNotifyRequestor": utilities().boolToInt($(".OnlyNotifyRequestorCheckbox[userId=" + userId + "]").prop("checked")),
				}
				requestTypePermArray.push(allowedUser);
			});
	
			//$.each(editor.find('table#requestTypeAllowedUsersTable tbody tr'), function(){
			$.each(editor.find('.allowedGroups > button'), function(){
				var groupId = parseInt($(this).attr("groupid"));
	
				allowedGroup = {
					"requestTypeId": requestTypeId,
					"allowedUserId": null,
					"allowedGroupId": groupId,
					"canAdd": utilities().boolToInt($(".CanAddCheckbox[groupId=" + groupId + "]").prop("checked")),
					"canView": utilities().boolToInt($(".CanViewCheckbox[groupId=" + groupId + "]").prop("checked")),
					"canEdit": utilities().boolToInt($(".CanEditCheckbox[groupId=" + groupId + "]").prop("checked")),
					"canDelete": utilities().boolToInt($(".CanDeleteCheckbox[groupId=" + groupId + "]").prop("checked")),
					"canBeAssigned": utilities().boolToInt($(".CanBeAssignedCheckbox[groupId=" + groupId + "]").prop("checked")),
					//"onlyNotifyRequestor": utilities().boolToInt($(".OnlyNotifyRequestorCheckbox[groupId=" + groupId + "]").prop("checked")),
				}
				requestTypePermArray.push(allowedGroup);
			});
			
			let restrictAccess = utilities().boolToInt(editor.find('[fieldid="restrictAccess"] input[type="checkbox"]').prop('checked'));
			let permissionTypesList = ["canAdd", "canView", "canEdit", "canDelete"];

			if (restrictAccess == 1 && !checkIfAnyPermissions(requestTypePermArray, permissionTypesList)) {
				// There are no permissions so fail this submission.
				window.upsertRequestTypeNotification.update({
					title: "There are no permissions set on this restricted request type.",
					message: "Please select permissions to continue.",
					type: "danger" 
				});
		
				reject();
				return;
			}
	
	
			notificationSettingArray = [];
			$.each(editor.find('table#requestTypeReprioritizationNotificationsTable tbody tr'), function(){
				groupSetting = {
					"requestTypeId": requestTypeId,
					"groupId": parseInt($(this).attr('groupid')),
					"notifyByEmail": utilities().boolToInt($(this).find('.notifyByEmailCheckbox').prop('checked'))
				}
				notificationSettingArray.push(groupSetting);
			});

			let restrictionsArray = [];
			let restrictedAppIdVal = $("#requestTypeAllowedAppsSelect").val();
			if (Array.isArray(restrictedAppIdVal)) {
				if (restrictedAppIdVal) {
					restrictionsArray = restrictedAppIdVal.map(appId => ({
						"requestTypeId": requestTypeId,
						"appId": appId,
					}));
				}
			} else {
				restrictionsArray.push({
					"requestTypeId": requestTypeId,
					"appId": restrictedAppIdVal,
				})
			}

			var typeFieldsArray = [];
			$.each(editor.find('table#requestTypeFieldsTable > tbody > tr'), function(requestTypeFieldIndex){
	
				requestTypeFieldId = 0;
				if($(this).attr('requesttypefieldid')){			
					requestTypeFieldId = $(this).attr('requesttypefieldid');			
				}
				
				savedFieldId = $(this).find('select.savedFieldDropdown option:selected').attr("savedfieldid");		
				var dataTypeId = parseInt($(this).attr('datatypeid'));
	
				var defaultValue = "";
				var defaultValueJson = {};
				var defaultValueAttr = $(this).attr("defaultvaluejson");
				if (defaultValueAttr) {
					defaultValueJson = JSON.parse(defaultValueAttr);
				}

				if($.inArray(dataTypeId, [dataTypeEnums.TEXT, dataTypeEnums.LONG_TEXT, dataTypeEnums.INTEGER, dataTypeEnums.REAL_NUMBER, dataTypeEnums.DROP_DOWN]) > -1 && defaultValueJson["company"]){
					defaultValue = defaultValueJson["company"];
				}

				var requestTypeFieldDefaultValuesByGroupArray = packageDefaultValuesForSubmission(defaultValueJson, "group");
				var requestTypeFieldDefaultValuesByUserArray = packageDefaultValuesForSubmission(defaultValueJson, "user");
	
				fieldGroup = null;
				if($(this).find('td.requestTypeFieldGroupTD select.fieldGroupDropdown').val() !== ""){
					fieldGroup = parseInt($(this).find('td.requestTypeFieldGroupTD select.fieldGroupDropdown').val())+1;
				}

				var includeInManageRequests = $(this).find("td.requestTypeIncludeInTableTD > input").prop('checked');
	
				var filterValue;
				if ($(this).find('#SortDropDown').length != 0)
				{//this is the Drop Down (data type ID = 5)
					filterValue = $($(this).find('#SortDropDown')[0]).val();
				}
				else if ($(this).find('#SortLabel').length != 0)
				{//this is the text box (data type ID = 1)
					filterValue = $($(this).find('#SortLabel')[0]).val();
				}

				filterValue = filterValue ? filterValue : null;
	
				if ($(this).attr("requestTypeFieldNotificationGroupSettings") != undefined)
				{
					var requestTypeFieldNotificationGroupSettings = utilities().parseJsons($(this).attr("requestTypeFieldNotificationGroupSettings").split("|||"));
					var requestTypeFieldNotificationOtherUserSettings = utilities().parseJsons($(this).attr("requestTypeFieldNotificationOtherUserSettings").split("|||"));
					var requestTypeFieldNotificationUserSettings = utilities().parseJsons($(this).attr("requestTypeFieldNotificationUserSettings").split("|||"));
				}
				else 
				{
					var requestTypeFieldNotificationGroupSettings = [];
					var requestTypeFieldNotificationOtherUserSettings = [];
					var requestTypeFieldNotificationUserSettings = [];

				}
	
				var biDirectionalLink = checkForNewBidirectionalField(requestTypeFieldId, dataTypeId) ? 1 : utilities().boolToInt($(this).attr('biDirectinalLink') == 'true');
	
				let fieldCustAttrListStr = $(this).attr("requestTypeFieldCustomAttributeValues");
				let fieldCustAttrList = [];
				
				if (fieldCustAttrListStr) {
					fieldCustAttrList = JSON.parse(fieldCustAttrListStr);

					fieldCustAttrList.forEach(function(attr) {
						if (!("vendorAttributeId" in attr)) {
							let vendorAttr = mapCustAttrIdToVendorAttr(custAttrDefList, attr.requestTypeCustAttribDefId, true);
							if (vendorAttr) {
								attr["vendorAttributeId"] = vendorAttr.vendorAttributeId;

								if (vendorAttr["displayDataType"] == CUST_ATTR_DATA_TYPES.DROP_DOWN) {
									let optionDefId = attr["requestTypeCustAttribDropdownOptDefId"];
									let optionDef = vendorAttr["requestTypeCustomAttributeDropDownOptionDefinitionList"].find(x => x.id == optionDefId);
									
									if (optionDef) {
										attr["dropDownValue"] = optionDef["optionKey"];
									}
								}
							}
						}
					});
				}
				//Note: unique ids need to be cleared on repeat requests 
				var thisField = {
					"id": requestTypeFieldId,
					"fieldId": savedFieldId,
					"required": utilities().boolToInt(parseInt($(this).attr('isrequired'))),
					"allowMultiple": utilities().boolToInt(parseInt($(this).attr('allowmultiple'))),
					"disabled": utilities().boolToInt(parseInt($(this).attr('isdisabled'))),
					"sortOrder": requestTypeFieldIndex+1,
					"restrictAccess": utilities().boolToInt(parseInt($(this).attr('restrictaccess'))),
					"inRequestsTable": utilities().boolToInt(includeInManageRequests),
					"defaultValue": defaultValue,
					"requestTypeFieldDefaultValuesByGroups": requestTypeFieldDefaultValuesByGroupArray,
					"requestTypeFieldDefaultValuesByUsers": requestTypeFieldDefaultValuesByUserArray,
					"fieldGroup": fieldGroup,
					"clearWhenDuplicate": dataTypeId == dataTypeEnums.UNIQUE_ID? 1 :  utilities().boolToInt(parseInt($(this).attr('clearWhenDuplicate'))),
					"filterField": utilities().boolToInt($(this).find('input[type=radio]').prop('checked')),
					"filterValue": filterValue,
					"autoGenerateNotebook": utilities().boolToInt($(this).attr('autoGenNotebook') == 'true'),
					"autoGenerateExperiment": utilities().boolToInt($(this).attr('autoGenExperement') == 'true'),
					"autoGenerateProject": utilities().boolToInt($(this).attr('autoGenProject') == 'true'),
					"bidirectionalRequestLinking": biDirectionalLink,
					"sendToELN": utilities().boolToInt($(this).attr("sendToELN")),
					"requestTypeFieldNotificationGroupSettings": requestTypeFieldNotificationGroupSettings,
					"requestTypeFieldNotificationOtherUserSettings": requestTypeFieldNotificationOtherUserSettings,
					"requestTypeFieldNotificationUserSettings": requestTypeFieldNotificationUserSettings,
					"requestTypeFieldCustomAttributeValues": fieldCustAttrList,
				};

				if ($(this)[0].hasAttribute('priorityoptions'))
				{
					thisField["requestTypeFieldPriorityOptions"] = JSON.parse($(this).attr('priorityoptions'));
				}
				
				fieldPermArray = [];
	
				if($(this).attr('restrictaccesssettings')){
					var restrictAccessSettingsObject = JSON.parse($(this).attr('restrictaccesssettings'));
					var allowedUsers = restrictAccessSettingsObject['users'];
					var allowedGroups = restrictAccessSettingsObject['groups'];
	
					// Note: unique id is a system generated value and anyone can add it
					if (allowedUsers) {
						$.each(allowedUsers, function(userIndex, allowedUser) {
							thisPerm = {
								"requestTypeFieldId": requestTypeId,
								"allowedUserId": allowedUser["userId"],
								"allowedGroupId": null,
								"canAdd": utilities().boolToInt(dataTypeId == dataTypeEnums.UNIQUE_ID? true : allowedUser["canAdd"]),
								"canEdit": utilities().boolToInt(allowedUser["canEdit"]),
								"canView": utilities().boolToInt(allowedUser["canView"]),
								"canDelete": utilities().boolToInt(allowedUser["canDelete"]),
								"onlyNotifyRequestor": 0
							}
							fieldPermArray.push(thisPerm);
						});
					}
	
					// Note: unique id is a system generated value and anyone can add it
					if (allowedGroups) {
						$.each(allowedGroups, function(userIndex, allowedGroup) {
							thisPerm = {
								"requestTypeFieldId": requestTypeId,
								"allowedUserId": null,
								"allowedGroupId": allowedGroup["groupId"],
								"canAdd": utilities().boolToInt(dataTypeId == dataTypeEnums.UNIQUE_ID? true : allowedGroup["canAdd"]),
								"canEdit": utilities().boolToInt(allowedGroup["canEdit"]),
								"canView": utilities().boolToInt(allowedGroup["canView"]),
								"canDelete": utilities().boolToInt(allowedGroup["canDelete"])
							}
							fieldPermArray.push(thisPerm);
						});
					}
	
					if (thisField['required'] == 1 && thisField["restrictAccess"] == 1)//check to see if field is required 
					{
						//get all users/ groups that can add 
						var canAddItems = fieldPermArray.filter(x => x.canAdd == 1);
	
						//check to make sure someomne can add
						if (canAddItems.length == 0 || canAddItems == undefined)
						{
	
							//nobody can add so fail the submit
							window.upsertRequestTypeNotification.update({
									title: `Request field "${$(this).find('select.savedFieldDropdown option:selected').html()}" is required but no users or groups have the "Add" permission.`,
									message: "",
									type: "danger" 
									});
							
									reject();
						}					
	
					}
	
	
					thisField["requestTypeFieldsPermissions"] = fieldPermArray;
				}
	
				var dropdownRelations = $(this).attr("dropdownrelations");
				thisField["requestTypeFieldDropDownDependencies"] = dropdownRelations !== undefined ? JSON.parse(dropdownRelations) : [];
				
				typeFieldsArray.push(thisField);
	
				/*
				if ($(this).attr("dropdownrelations") !== undefined) {
					thisSavedField["dropdownRelations"] = JSON.parse($(this).attr("dropdownrelations"));
				}*/
			});
	
			var typeItemsArray = [];
			if(window.requestItemTypesArray.length > 0){
				$.each(editor.find('table#requestTypeRequestItemTypesTable > tbody > tr'), function(requestTypeItemsIndex){
					
					var requestItemId = 0;
					if($(this).attr('requestitemid')){
						requestItemId = parseInt($(this).attr('requestitemid'));
					}


					if ($(this).attr("requestTypeItemFieldNotificationGroupSettings") != undefined)
					{
						var requestTypeItemFieldNotificationGroupSettings = utilities().parseJsons($(this).attr("requestTypeItemFieldNotificationGroupSettings").split("|||"));
						var requestTypeItemFieldNotificationOtherUserSettings = utilities().parseJsons($(this).attr("requestTypeItemFieldNotificationOtherUserSettings").split("|||"));
						var requestTypeItemFieldNotificationUserSettings = utilities().parseJsons($(this).attr("requestTypeItemFieldNotificationUserSettings").split("|||"));
						var requestTypeItemNotificationGroupSettings = utilities().parseJsons($(this).attr("requestTypeItemNotificationGroupSettings").split("|||"));
						var requestTypeItemNotificationOtherUserSettings = utilities().parseJsons($(this).attr("requestTypeItemNotificationOtherUserSettings").split("|||"));
						var requestTypeItemNotificationUserSettings = utilities().parseJsons($(this).attr("requestTypeItemNotificationUserSettings").split("|||"));	
					}
					else 
					{
						var requestTypeItemFieldNotificationGroupSettings = [];
						var requestTypeItemFieldNotificationOtherUserSettings = [];
						var requestTypeItemFieldNotificationUserSettings = [];
						var requestTypeItemNotificationGroupSettings = [];
						var requestTypeItemNotificationOtherUserSettings = [];
						var requestTypeItemNotificationUserSettings = [];
	
					}
		
					
					var thisTypeItem = {
						"id": requestItemId,
						"requestTypeId": requestTypeId,
						"requestItemTypeId": $(this).find('select.requestType_requestItemTypeDropdown option:selected').attr('requestitemtypeid'),
						"requestItemName": $(this).find('input[type="text"].requestType_requestItemCustomName').val(),
						"requestItemMinimumCount": $(this).find('input[type="text"].requestType_requestItemMinimumCount').val(),
						"deleteOnEdit": $(this).find('input[type="checkbox"].centerAlign').prop("checked"),
						"requestTypeItemFieldNotificationGroupSettings": requestTypeItemFieldNotificationGroupSettings,
						"requestTypeItemFieldNotificationOtherUserSettings": requestTypeItemFieldNotificationOtherUserSettings,
						"requestTypeItemFieldNotificationUserSettings": requestTypeItemFieldNotificationUserSettings,
						"requestTypeItemNotificationGroupSettings": requestTypeItemNotificationGroupSettings,
						"requestTypeItemNotificationOtherUserSettings": requestTypeItemNotificationOtherUserSettings,
						"requestTypeItemNotificationUserSettings": requestTypeItemNotificationUserSettings
					};
	
					console.log(requestTypeItemsIndex)
	
		
					typeItemsArray.push(thisTypeItem);
				});
			}
			
			var hasDuplicate = false;
			typeItemsArray.map(x => x.requestItemTypeId).sort().sort((a, b) => {
				if (a === b) hasDuplicate = true;
			});
	
			if (hasDuplicate) {
				window.upsertRequestTypeNotification.update({'title': "Error", 'message': ("Cannot have duplicate request items"), type: "danger"})
				return false;
			}
	
			var frozenColumnsLeftValue = parseInt(editor.find('[fieldid="frozenColumnsLeft"] input[type="number"]').val());
			if(isNaN( frozenColumnsLeftValue )){
				frozenColumnsLeftValue = 0;
			}

			var requetNameSetting = {};

			var reqNameRequestTypeFieldId =  $("#requestNameSelectField").attr("saveditem");
			reqNameRequestTypeFieldId = reqNameRequestTypeFieldId == 0 ? null : reqNameRequestTypeFieldId;



			var NameOrdersS = new Set(); 
			var check = 4;
			
			isNaN(parseInt($("#staticNameSortOrder").val())) ? check -= 1 : NameOrdersS.add(parseInt($("#staticNameSortOrder").val()));
			isNaN(parseInt($("#groupSortOrder").val())) ? check -= 1 : NameOrdersS.add(parseInt($("#groupSortOrder").val()));
			isNaN(parseInt($("#fieldInNameSortOrder").val())) ? check -= 1 : NameOrdersS.add(parseInt($("#fieldInNameSortOrder").val()));
			isNaN(parseInt($("#incromentingNumSortOrder").val())) ? check -= 1 : NameOrdersS.add(parseInt($("#incromentingNumSortOrder").val()));
			

	
			if (NameOrdersS.size != check)
			{
				window.upsertRequestTypeNotification.update({'title': "Request names cannot have 2 values at the same position.", 'message': "", type: "danger"})
				reject(true);
				return
			}
			try
			{
				var requesttypenotificationgroupsettings = utilities().parseJsons($("#configRequestNotifications").attr("requesttypenotificationgroupsettings").split("|||"));
				var requesttypenotificationusersettings = utilities().parseJsons($("#configRequestNotifications").attr("requesttypenotificationusersettings").split("|||"));
				var requesttypenotificationotherusersettings = utilities().parseJsons($("#configRequestNotifications").attr("requesttypenotificationotherusersettings").split("|||"));
			}
			catch(e)
			{
				var requesttypenotificationgroupsettings = null;
				var requesttypenotificationusersettings = null;
				var requesttypenotificationotherusersettings = null;
			}

			let requestTypeCustomAttributeValues = getCustAttrValList("requestTypeCustomAttributesTable", "requestTypeId", requestTypeId);
			data = {
				"appName": "Configuration",
				"requestType": {
					"id": requestTypeId,
					"displayName": requestTypeName,
					"hoverText": editor.find('[fieldid="hoverText"] input[type="text"]').val(),
					"restrictAccess": utilities().boolToInt(editor.find('[fieldid="restrictAccess"] input[type="checkbox"]').prop('checked')),
					"requiresApproval": utilities().boolToInt(editor.find('[fieldid="requiresApproval"] input[type="checkbox"]').prop('checked')),
					"disabled": utilities().boolToInt(editor.find('[fieldid="disabled"] input[type="checkbox"]').prop('checked')),
					"isDefault": utilities().boolToInt(editor.find('[fieldid="isDefault"] input[type="checkbox"]').prop('checked')),
					"frozenColumnsLeft": frozenColumnsLeftValue,
					"notifyColabs": utilities().boolToInt(editor.find('[fieldid="colabNotification"] input[type="checkbox"]').prop('checked')),
					"showPrioritizationOnSubmit": utilities().boolToInt(editor.find('[fieldid="showPrioritizationOnSubmit"] input[type="checkbox"]').prop('checked')),
					"searchRegForExistingCompound": utilities().boolToInt(editor.find('[fieldid="searchRegForExistingCompound"] input[type="checkbox"]').prop('checked')),
					"registerNewCompounds": utilities().boolToInt(editor.find('[fieldid="registerNewCompounds"] input[type="checkbox"]').prop('checked')),
					"checkIfStructIsRequestedBeforeReg": utilities().boolToInt(editor.find('[fieldid="checkIfStructIsRequestedBeforeReg"] input[type="checkbox"]').prop('checked')),
					//"autoGenerateNotebook": utilities().boolToInt(editor.find('[fieldid="genNotebook"] input[type="checkbox"]').prop('checked')),
					//"autoGenerateExperiment": null,
					//"autoGenerateProject": utilities().boolToInt(editor.find('[fieldid="genProject"] input[type="checkbox"]').prop('checked')),
					"requestRestrictions": restrictionsArray,
					"requestTypePermissions": requestTypePermArray,
					"requestTypeFields": typeFieldsArray,
					"requestTypeItems": typeItemsArray,
					"reqNamePrefix": $("#staticNameString").val(),
					"reqNamePrefixOrder": isNaN(parseInt($("#staticNameSortOrder").val())) ? 0 : parseInt($("#staticNameSortOrder").val()),
					"reqNameUseUserGroupId": utilities().boolToInt($("#useAssignedGroup").prop('checked')),
					"reqNameUseUserGroupIdOrder": isNaN(parseInt($("#groupSortOrder").val())) ? 0 : parseInt($("#groupSortOrder").val()),
					"reqNameRequestTypeFieldId": reqNameRequestTypeFieldId,
					"reqNameRequestTypeFieldIdOrder": isNaN(parseInt($("#fieldInNameSortOrder").val())) ? 0 : parseInt($("#fieldInNameSortOrder").val()),
					"reqNameUseIncrementingNumbersCode": $("#selectIncromentingNum").val(),
					"reqNameUseIncrementingNumbersCodeOrder": isNaN(parseInt($("#incromentingNumSortOrder").val())) ? 0 : parseInt($("#incromentingNumSortOrder").val()),
					"requesttypenotificationgroupsettings": requesttypenotificationgroupsettings,
					"requesttypenotificationusersettings": requesttypenotificationusersettings,
					"requesttypenotificationotherusersettings": requesttypenotificationotherusersettings,
					"requestTypeCustomAttributeDefinitions": custAttrDefList,
					"requestTypeCustomAttributeValues": requestTypeCustomAttributeValues,
				}
			}
			
			var serviceObj = {
				configService: true,
			};
			utilities().makeAjaxPost(configServiceEndpoints.REQUEST_TYPES_UPSERT, data, serviceObj).then(function(response) {
				console.log(response);
				resolve(response);
			}).catch(function(response) {
				console.log("error");
				if(requestTypeId){
					notificationTitle = 'Failed to update ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '".';
				}
				else{
					notificationTitle = 'Failed to create new "' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '".';
				}
				window.upsertRequestTypeNotification.update({'title': notificationTitle, 'message': "", type: "danger"})
			});
		});
	}

	/**
	 * Packages up the default values stored in the DOM for submission based on the input level string.
	 * @param {JSON} defaultValueJson The default values JSON object.
	 * @param {string} level The level of defaults we're currently looking at. Should either be "group" or "user".
	 */
	var packageDefaultValuesForSubmission = function(defaultValueJson, level) {
		var defaultValuesArray = [];
		for (id in defaultValueJson[level]) {
			var valueField = {
				"requestTypeFieldId": requestTypeFieldId,
				"defaultValue": defaultValueJson[level][id],
			};

			// This is assigned outside to work around a JS limitation where we can't use
			// an interpolated string while creating a JSON.
			valueField[`${level}Id`] = id;
			defaultValuesArray.push(valueField);
		}
		return defaultValuesArray;
	}

	/**
	 * Checks if this field is a referential ELN field that should have the bidirectional link flag set on creation.
	 * @param {number} requestTypeFieldId The current field's request type field ID. Should be 0 if this is a new field.
	 * @param {number} dataTypeId The current field's data type ID.
	 */
	var checkForNewBidirectionalField = function(requestTypeFieldId, dataTypeId) {
		return requestTypeFieldId == 0 && [dataTypeEnums.NOTEBOOK, dataTypeEnums.PROJECT, dataTypeEnums.EXPERIMENT].includes(dataTypeId);
	}

	var addRequestTypeFieldToEditor = function(requestTypeField, alwaysAllowDelete, ignoreRequestTypeFieldId) {
		var tableRow = $('<tr></tr>');
		var grabHandle = $("<td></td>").append("<i class='material-icons editRequestTypeDrag' title='Drag Handle'>reorder</i>");
		var savedFieldDropdownTD = $('<td class="savedFieldDropdownTD"></td>').append('<select class="savedFieldDropdown"></select>')
		var requestTypeFieldGroupTD = $('<td class="requestTypeFieldGroupTD">').append(fieldGroupsDropdown.clone())
		var requestTypeIncludeInTableTD = $(`<td class="requestTypeIncludeInTableTD">`).append(`<input type="checkbox"></input>`);
		var requestTypeFieldOptionsTD = $('<td></td>').append('<button class="basicActionButton manageFieldOptionsButton">Edit</button>')
		var requestTypeFieldDeleteButtonTD = $('<td></td>').append('<button class="editorSectionTableRowDeleteButton">Delete</button>')
		var requestTypeFieldSortBtn = $('<td></td>').append("<input type='radio' class='RadioAlign centerAlign alignMiddle' name='SortSelect'/>")
	
		// Putting this here instead of down below to cover up a weird visual bug where you can see underneath the table for the edit request types page.
		if (requestTypePageMode == "requestItemTypes") {
			requestTypeFieldSortBtn.addClass("hide");
		}
	
		// Populate the dropdown of saved fields
		savedFieldDropdownTD.find('select').html(window.savedFieldsOptionsHTML);
	
		if(requestTypeField){
			console.log(requestTypeField)
			if(!ignoreRequestTypeFieldId){
				tableRow.attr('requesttypefieldid',requestTypeField['requestTypeFieldId'])
			}

			// disable the field selector and set the class which removes the
			// arrow from the select element
			savedFieldDropdownTD.find('select').attr('disabled','disabled');
			savedFieldDropdownTD.find('select').addClass('disabledSavedField');
			
			tableRow.attr("savedFieldId", requestTypeField["savedFieldId"])
			
			// Select the right saved field in the dropdown
			savedFieldDropdownTD.find('option[savedfieldid="'+requestTypeField['savedFieldId']+'"]').prop('selected',true);
			
			tableRow.attr('isrequired',requestTypeField['required']);
			//requestTypeFieldRequiredTD.find('input[type="checkbox"]').prop('checked',requestTypeField['required'])
	
			tableRow.attr('allowmultiple',requestTypeField['allowMultiple']);
			//requestTypeFieldAllowMultipleTD.find('input[type="checkbox"]').prop('checked',requestTypeField['allowMultiple'])
	
			tableRow.attr('isdisabled',requestTypeField['disabled']);
			//requestTypeFieldDisabledTD.find('input[type="checkbox"]').prop('checked',requestTypeField['disabled'])
			
			if(typeof requestTypeField['restrictAccess'] !== "undefined"){ // Currently not on every requestTypeField in DB...(!)
				tableRow.attr('restrictaccess',requestTypeField['restrictAccess']);
				//requestTypeFieldRestrictAccessTD.find('input[type="checkbox"]').prop('checked',requestTypeField['restrictAccess'])
			}
	
			tableRow.attr('autoGenNotebook',requestTypeField['autoGenerateNotebook'] == 1);
			tableRow.attr('autoGenProject',requestTypeField['autoGenerateProject'] == 1);
			tableRow.attr('autoGenExperement',requestTypeField['autoGenerateExperement'] == 1);
			tableRow.attr('biDirectinalLink',requestTypeField['bidirectionalRequestLinking'] == 1);
			tableRow.attr("sendToELN", requestTypeField["sendToELN"] == 1);


			if (window.requestTypePageMode == "requestTypes")
			{
				var isFilterField = requestTypeField["requestTypeFieldPriorityOptions"].length > 0? "1": "0";
				tableRow.attr('priorityOptions', JSON.stringify(requestTypeField["requestTypeFieldPriorityOptions"]));
				tableRow.attr('filterField', isFilterField);
				tableRow.attr('requestTypeFieldNotificationGroupSettings',stringNotifications(requestTypeField['requestTypeFieldNotificationGroupSettings']));
				tableRow.attr('requestTypeFieldNotificationUserSettings',stringNotifications(requestTypeField['requestTypeFieldNotificationUserSettings']));
				tableRow.attr('requestTypeFieldNotificationOtherUserSettings',stringNotifications(requestTypeField['requestTypeFieldNotificationOtherUserSettings']));
				tableRow.attr("requestTypeFieldCustomAttributeValues", JSON.stringify(requestTypeField["requestTypeFieldCustomAttributeValues"]))
			}
	
			if (requestTypeField['dataTypeId'] == dataTypeEnums.DROP_DOWN)
			{//checking for the 2 data types alowed for filtering 
				if (isFilterField == "1")
				{//while loading the request fields re check the already selected value
					$($(requestTypeFieldSortBtn).children()[0]).prop("checked", true);
				}
    			else if( requestTypeField['dataTypeId'] == dataTypeEnums.DROP_DOWN)
				{//if dt 5 then re populate the drop downs 
					var dependencyField = "requestTypeFieldDropDownDependencies";
	
					if (requestTypePageMode == "requestItemTypes") {
						dependencyField = "requestItemTypeFieldDropDownDependencies";
					}
	
					tableRow.attr("dropdownrelations", JSON.stringify(requestTypeField[dependencyField]));
				}
			}
			else 
			{
				requestTypeFieldSortBtn.empty();
			}
	
			tableRow.attr("clearWhenDuplicate", requestTypeField['clearWhenDuplicate']);
	
			if(typeof requestTypeField['allowedUsers'] !== "undefined" && typeof requestTypeField['allowedGroups'] !== "undefined"){
				tableRow.attr('restrictaccesssettings',JSON.stringify({"users": requestTypeField['allowedUsers'], "groups": requestTypeField['allowedGroups']}))
			}
	

	
			tableRow.attr('inrequeststable',requestTypeField['inRequestsTable']);
			$($(requestTypeIncludeInTableTD).children()[0]).prop("checked", requestTypeField['inRequestsTable']);
			if (window.requestTypePageMode == "requestItemTypes")
			{
				requestTypeIncludeInTableTD = $("<td></td>");
			}

			if (requestTypeField['dataTypeId'] == dataTypeEnums.BIOSPIN_EDITOR) {
				$("requestTypeIncludeInTableTD").prop("disabled",true);
			}
			//requestTypeFieldInRequestsTableTD.find('input[type="checkbox"]').prop('checked',requestTypeField['inRequestsTable'])
	
			// Don't want it to be possible to remove this saved field because it's already been saved
			if(!alwaysAllowDelete){
				requestTypeFieldDeleteButtonTD.empty();
			}
			/*if(window.requestTypePageMode == "requestItemTypes"){
				requestTypeFieldNotificationsTD.empty();
				$('th#requestTypeNotificationsTableHeader').empty()
			}*/
		}
	
		tableRow.append(grabHandle, savedFieldDropdownTD, requestTypeFieldGroupTD, requestTypeIncludeInTableTD, requestTypeFieldOptionsTD, requestTypeFieldDeleteButtonTD, requestTypeFieldSortBtn)
		updateRequestTypeFieldSavedFieldChoice(tableRow);
		
		if(requestTypeField){
			// Set the default value if one exists
			if(requestTypeField['defaultValue']){
				if($.inArray(requestTypeField['dataTypeId'], [dataTypeEnums.TEXT, dataTypeEnums.LONG_TEXT, dataTypeEnums.INTEGER, dataTypeEnums.REAL_NUMBER, dataTypeEnums.DROP_DOWN]) > -1){
					tableRow.attr('defaultvalue', requestTypeField['defaultValue']);
				}
			}
			if(requestTypeField['fieldGroup']){
				tableRow.find('select.fieldGroupDropdown option[value="' + (requestTypeField['fieldGroup']-1) + '"]').prop('selected', true).change();
				tableRow.attr('fieldgroup',requestTypeField['fieldGroup']);
			}
		}
	
		$('table#requestTypeFieldsTable > tbody').append(tableRow)
	}

	var populateRequestItemReprioritizationNotificationsContainer = function(requestItemTypeRowElement) {
		requestItemName = requestItemTypeRowElement.find('.requestType_requestItemCustomName').val();

		// Reset the checkboxes
		$('#reprioritizationRequestItemTypeNotificationSettingsModal table.requestItemReprioritizationNotificationsTable input[type="checkbox"]').prop('checked', false);
		$('.notificationsContainerTitle .reprioritizationRequestItemTypeNameContainer').text(requestItemName + "s");
	}

	var addRequestItemTypeToEditor = function(requestType_requestItemType, alwaysAllowDelete, ignoreRequestTypeFieldId) {
		var tableRow = $('<tr></tr>')
		var requestType_requestItemTypeDropdownTD = $('<td></td>').append('<select class="requestType_requestItemTypeDropdown"></select>')
		var requestType_requestItemCustomNameTD = $('<td></td>').append('<input type="text" class="requestType_requestItemCustomName">')
		var requestType_requestItemMinimumCountTD = $('<td></td>').append('<input type="text" class="requestType_requestItemMinimumCount" value="0">')
		//var requestType_requestItemNotificationSettingsTD = $('<td></td>').append('<button class="basicActionButton manageRequestItemTypeNotificationSettingsButton">Manage</button>')
		var requestType_requestItemDeleteOnEditCB = $('<td></td>').append('<input type="checkbox" class="centerAlign"/>')
		var requestType_requestItemDeleteButtonTD = $('<td></td>').append('<button class="editorSectionTableRowDeleteButton">Delete</button>')
		// Populate the dropdown of request item types
		requestType_requestItemTypeDropdownTD.find('select').html(window.requestItemTypesOptionsHTML);

		if(requestType_requestItemType){
			if(!ignoreRequestTypeFieldId){
				tableRow.attr('requestitemid',requestType_requestItemType['requestItemId'])
			}
			requestType_requestItemTypeDropdownTD.find('option[requestitemtypeid="'+requestType_requestItemType['requestItemTypeId']+'"]').prop('selected',true);
			
			// Don't want it to be possible to remove this request item type because it's already been saved
			if(!alwaysAllowDelete){
				requestType_requestItemDeleteButtonTD.empty();
			}

			requestType_requestItemCustomNameTD.find('input[type="text"].requestType_requestItemCustomName').val(requestType_requestItemType['requestItemName'])
			if(requestType_requestItemType['requestItemMinimumCount']){
				requestType_requestItemMinimumCountTD.find('input[type="text"].requestType_requestItemMinimumCount').val(requestType_requestItemType['requestItemMinimumCount']);
			}
			if (window.requestTypePageMode == "requestTypes")
			{
				tableRow.attr('requestTypeItemFieldNotificationGroupSettings',stringNotifications(requestType_requestItemType['requestTypeItemFieldNotificationGroupSettings']));
				tableRow.attr('requestTypeItemFieldNotificationUserSettings',stringNotifications(requestType_requestItemType['requestTypeItemFieldNotificationUserSettings']));
				tableRow.attr('requestTypeItemFieldNotificationOtherUserSettings',stringNotifications(requestType_requestItemType['requestTypeItemFieldNotificationOtherUserSettings']));
				tableRow.attr('requestTypeItemNotificationGroupSettings',stringNotifications(requestType_requestItemType['requestTypeItemNotificationGroupSettings']));
				tableRow.attr('requestTypeItemNotificationUserSettings',stringNotifications(requestType_requestItemType['requestTypeItemNotificationUserSettings']));
				tableRow.attr('requestTypeItemNotificationOtherUserSettings',stringNotifications(requestType_requestItemType['requestTypeItemNotificationOtherUserSettings']));
			}
			if(requestType_requestItemType['deleteOnEdit'] == true)
			{
				$($(requestType_requestItemDeleteOnEditCB).children()).prop('checked', true)
			}

		}
		// (!) While we only allow ONE requestItemType at a time, we don't need the delete button
		//requestType_requestItemDeleteButtonTD.empty();

		tableRow.append(requestType_requestItemTypeDropdownTD, requestType_requestItemCustomNameTD, requestType_requestItemMinimumCountTD, requestType_requestItemDeleteOnEditCB, requestType_requestItemDeleteButtonTD)
		$('table#requestTypeRequestItemTypesTable > tbody').append(tableRow)
	}
	
	var populateRequestTypesTable = function(asOfDate = null) {
		//$('#dropdownsTable > tbody').empty()

		//instead of reloading the ajax you need to recreate the table beacuse you need the new as of time. 
		if ($.fn.DataTable.isDataTable('#dropdownsTable')) {
			$("#dropdownsTable").DataTable().destroy();
			$("#dropdownsTable").empty(); 
        }

		var dataTable = $("#dropdownsTable").DataTable({
			processing: true,
			"scrollX": true,
			'language':{ 
			   "loadingRecords": "",
			   "zeroRecords": "",
			   "emptyTable": "",
			   "processing": "<div class='blueLoadingSpinner'></div><br>Loading...",
			},
			ajax: function(data,callback,settings){

				var requestTypePromises = [];
				requestTypePromises.push(getRequestTypes(asOfDate));
				requestTypePromises.push(getRequestItemTypes(asOfDate));
		
				Promise.all(requestTypePromises).then(function() {
					var rows = [];
					$.each(window.pageModeRequestTypes, function (index, requestType) {
						requestType.fieldsDict = ajaxModule().makeFieldsDict(requestType.fields)
		
						var datarow = [];
		
						datarow.push(requestType['displayName']);
		
						datarow.push(requestType['hoverText'])
						
						var fieldNamesArray = []
						$.each(window.savedFieldsArray, function(savedFieldIndex, savedField){
							$.each(Object.keys(requestType['fieldsDict']), function(fieldIndex, fieldId) {
								var field = requestType['fieldsDict'][fieldId][0];
								if (field !== undefined) {
									if(savedField['id'] == field['savedFieldId']){
										fieldNamesArray.push(savedField['displayName']);
										return false;
									}	
								}
							});
						});
						
						datarow.push(fieldNamesArray.join(', '));
		
						var requestTypeRestrictAccesss = requestType["restrictAccess"] ? "True" : "False";
						datarow.push(requestTypeRestrictAccesss);
						
						var requestTypeRequiresApproval = requestType["requiresApproval"] ? "True" : "False";
						datarow.push(requestTypeRequiresApproval);
						
						var requestTypeIsDefault = requestType["isDefault"] ? "True" : "False";
						datarow.push(requestTypeIsDefault);
						
						var requestTypeDisabled = requestType["disabled"] ? "Disabled" : "Enabled";
						datarow.push(requestTypeDisabled);

						datarow.push(requestType['id']);
						
						rows.push(datarow);
						//var addedRow = dataTable.row.add(datarow).node();
						//$(addedRow).attr("requesttypeid", requestType['id']);
					});
					callback(rows);	
					$(".dropdownsTable").width( $('div.col-sm-12').width());
				});			
				settings.sAjaxDataProp = '';
			},
			columnDefs: [
				{
					targets: 2,
					width: "700px"
				}
			]
		});
	}

	var getRequestTypes = function(asOfDate = null) {
		return new Promise(function(resolve, reject) {

			var requestTypeParams = {
				includeDisabled: true,
				isConfigPage: true,
				appName: "Configuration",
				asOfDate: utilities().getDateForService(asOfDate)
			};

			ajaxModule().getRequestTypes(requestTypeParams)
				.then(function(response) {
					response = utilities().decodeServiceResponce(response);
					window.requestTypesArray = response.map(function(x){
						x.fields = utilities().sortArray(x.fields, "sortOrder")
						return x
					})

					if (window.requestTypePageMode == "requestTypes") {
						window.pageModeRequestTypes = window.requestTypesArray;
					}
					 
					resolve(true);
				});
		});
	}

	var getRequestItemTypes = function(asOfDate) {
		return new Promise(function(resolve, reject) {
			
			var requestItemTypesParams = {
                includeDisabled: true,
                isConfigPage: true,
                appName: "Configuration",
                asOfDate: utilities().getDateForService(asOfDate)
			}
			
			ajaxModule().getRequestItemTypes(requestItemTypesParams)
				.then(function(response) {
					response = utilities().decodeServiceResponce(response);
					window.requestItemTypesArray = response.map(function(x){
						x.fields = utilities().sortArray(x.fields, "sortOrder")
						return x
					})
		
					if (window.requestTypePageMode == "requestItemTypes") {
						window.pageModeRequestTypes = response
					}
					resolve(true);
				});
		});
	}

	var populateDataTypes = function() {
		return new Promise(function(resolve, reject) {
			$('select#dataTypeDropdown').empty();

			$.each(window.dataTypesArray, function(index, dataType){
				var dataTypeOption = $('<option></option>').attr('value',dataType['id']).text(dataType['displayName'])
				$('select#dataTypeDropdown').append(dataTypeOption)
			});
			resolve(true);
		});
	}

	var updateRequestItemNotificationSettingsContainerAttribute = function() {
		notificationSettingsObject = {}
		if($('#requestItemReprioritizationNotificationsEditorSection').attr('notificationsettings')){
			notificationSettingsObject = JSON.parse($('#requestItemReprioritizationNotificationsEditorSection').attr('notificationsettings'))
		}
		groupsArray = [];
		$.each($('#reprioritizationRequestItemTypeNotificationSettingsModal').find('table#requestItemReprioritizationNotificationsTable tbody tr'), function(){
			group = {
				"groupId": parseInt($(this).attr('groupid')),
				"notifyByEmail": $(this).find('.notifyByEmailCheckbox').prop('checked')
			}
			groupsArray.push(group);
		});
		notificationSettingsObject['groups'] = groupsArray;
		
		return notificationSettingsObject;
	}

	var updateRequestTypeFieldSavedFieldChoice = function(tableRow) {
		var thisSavedField = window.savedFieldsArray.find(x => x.id == parseInt( tableRow.find('.savedFieldDropdown option:selected').attr("savedfieldid") ));
		tableRow.attr('savedfieldindex', tableRow.find('select.savedFieldDropdown').val()).attr('datatypeid', thisSavedField['dataTypeId'].toString());

		// If the user chose a dropdown, populate the defaultValue dropdown with the appropriate options
		if(thisSavedField['dataTypeId'] == 5){
			var dropdownOptionsArray = []
			dropdownOptionsArray.push($('<option value="">').text('-- None --'))
			$.each(thisSavedField['options'], function(optionIndex, option){
				if(this['disabled'] == false){
					dropdownOptionsArray.push($('<option>').attr('value', option['dropdownOptionId']).text(option['displayName']));
				}
			});
			tableRow.find('select.defaultValueDropdown').empty().append(dropdownOptionsArray);
		} 
		if (thisSavedField['dataTypeId'] == dataTypeEnums.BIOSPIN_EDITOR) {
			$(tableRow.find(".requestTypeIncludeInTableTD > input").attr("checked", false));
			$(tableRow.find(".requestTypeIncludeInTableTD > input").attr("disabled", true));
		
		} else {
			$(tableRow.find(".requestTypeIncludeInTableTD > input").attr("disabled", false));
		}
	}

	/**
	 * Onclick handler to submit the request type field editor information back into the DOM.
	 */
	var submitRequestTypeFieldEditor = function(){
		var dropdownRelations = getDropdownRelationFromTable();

		if (!dropdownRelations) {
			swal("Warning!", "There is a duplicate combination of source value and target value.", "warning");
			return false;
		}

		if (dropdownRelations == {}) {
			// Figure out our requestType and savedField.
			var requestTypeFieldId = $(window.requestTypeFieldEditorTableRow).attr("requesttypefieldid");
			var requestTypeId = $(".dropdownEditorContainer").attr("requesttypeid");

			var requestType = window.pageModeRequestTypes.find(x => x.id == requestTypeId);
			
			if (requestType === undefined) {
				return srcCol;
			}

			var currField = requestType.fields.find(x => x.requestTypeFieldId == requestTypeFieldId);

			if (currField === undefined) {
				return srcCol;
			}

			var savedFieldId = currField.savedFieldId;
			dropdownRelations = getExistingDropdownRelation(requestType, savedFieldId);
		}

		window.requestTypeFieldEditorTableRow.attr('isrequired', +$('#requestTypeFieldEditorModal').find('input.requestTypeFieldIsRequired').prop('checked'));
		window.requestTypeFieldEditorTableRow.attr('allowmultiple', +$('#requestTypeFieldEditorModal').find('input.requestTypeFieldAllowMultiple').prop('checked'));
		window.requestTypeFieldEditorTableRow.attr('isdisabled', +$('#requestTypeFieldEditorModal').find('input.requestTypeFieldIsDisabled').prop('checked'));
		window.requestTypeFieldEditorTableRow.attr('restrictaccess', +$('#requestTypeFieldEditorModal').find('input.requestTypeFieldRestrictAccess').prop('checked'));
		window.requestTypeFieldEditorTableRow.attr('clearWhenDuplicate', +$('#requestTypeFieldEditorModal').find('input.requestTypeFieldClearWhenDuplicate').prop('checked'));

		window.requestTypeFieldEditorTableRow.attr('autoGenNotebook', $('[fieldid = requestTypeFieldAutoGenNotebook]').find("input").prop('checked'));
		window.requestTypeFieldEditorTableRow.attr('autoGenProject', $('[fieldid = requestTypeFieldAutoGenProject]').find("input").prop('checked'));
		window.requestTypeFieldEditorTableRow.attr('autoGenExperement', $('[fieldid = requestTypeFieldAutoGenExperiment]').find("input").prop('checked'));
		window.requestTypeFieldEditorTableRow.attr('biDirectinalLink', $('[fieldid = requestTypeFieldBiDirectinalLink]').find("input").prop('checked'));
		window.requestTypeFieldEditorTableRow.attr('sendToELN', $('[fieldid = requestTypeFieldSendToELN]').find("input").prop('checked'));

		var requestTypeFieldRestrictionsContainer = $('#requestTypeFieldEditorModal').find('.requestTypeFieldRestrictionsContainer');
		allowedUsersArray = [];
		$.each(requestTypeFieldRestrictionsContainer.find('table#requestTypeFieldAllowedUsersTable tbody tr'), function(){
			allowedUser = {
				"userId": parseInt($(this).attr('userid')),
				"canAdd": $(this).find('.canAddCheckbox').prop('checked'),
				"canView": $(this).find('.canViewCheckbox').prop('checked'),
				"canEdit": $(this).find('.canEditCheckbox').prop('checked'),
				"canDelete": $(this).find('.canDeleteCheckbox').prop('checked')
			}
			allowedUsersArray.push(allowedUser);
		});
		allowedGroupsArray = [];
		$.each(requestTypeFieldRestrictionsContainer.find('table#requestTypeFieldAllowedGroupsTable tbody tr'), function(){
			allowedGroup = {
				"groupId": parseInt($(this).attr('groupid')),
				"canAdd": $(this).find('.canAddCheckbox').prop('checked'),
				"canView": $(this).find('.canViewCheckbox').prop('checked'),
				"canEdit": $(this).find('.canEditCheckbox').prop('checked'),
				"canDelete": $(this).find('.canDeleteCheckbox').prop('checked')
			}
			allowedGroupsArray.push(allowedGroup);
		});
		restrictAccessSettings = {"users": allowedUsersArray, "groups": allowedGroupsArray}
		window.requestTypeFieldEditorTableRow.attr('restrictaccesssettings', JSON.stringify(restrictAccessSettings));
		

		window.requestTypeFieldEditorTableRow.attr('notificationsettings', JSON.stringify(updateRequestTypeFieldNotificationSettingsContainerAttribute()));
		window.requestTypeFieldEditorTableRow.attr('inrequeststable', +$('td.requestTypeIncludeInTableTD').find('input').prop('checked'));

		dataTypeIdParsed = parseInt($('#requestTypeFieldEditorModal').attr('datatypeid'));

		var defaultValueJson = JSON.parse(window.requestTypeFieldEditorTableRow.attr("defaultvaluejson"));
		if($.inArray(dataTypeIdParsed, [dataTypeEnums.TEXT, dataTypeEnums.LONG_TEXT, dataTypeEnums.INTEGER, dataTypeEnums.REAL_NUMBER]) > -1){
			defaultValueJson = packageDefaultValues(defaultValueJson, "input.defaultValueInput");
			window.requestTypeFieldEditorTableRow.attr('defaultvalue', $('#requestTypeFieldEditorModal').find('input.defaultValueInput').val());
		}
		else if(dataTypeIdParsed == dataTypeEnums.DROP_DOWN){
			defaultValueJson = packageDefaultValues(defaultValueJson, "select.defaultValueDropdown");
			window.requestTypeFieldEditorTableRow.attr('defaultvalue', $('#requestTypeFieldEditorModal').find('select.defaultValueDropdown').val());

			if(window.requestTypeFieldEditorTableRow.attr("filterField") == "1")
			{
				var data = $("#filterValueManagmentTable").DataTable().data().toArray();
				if (data)
				{
					window.requestTypeFieldEditorTableRow.attr("priorityoptions", JSON.stringify(data));
				}
			}
		}

		window.requestTypeFieldEditorTableRow.attr("defaultvaluejson", JSON.stringify(defaultValueJson));

		let custAttrJson = getCustAttrValList("requestTypeFieldCustomAttributesTable");
		window.requestTypeFieldEditorTableRow.attr("requesttypefieldcustomattributevalues", JSON.stringify(custAttrJson)); 

		if(isNaN(parseInt($('#requestTypeFieldEditorModal').find('select.fieldGroupDropdown').val()))){
			window.requestTypeFieldEditorTableRow.attr('fieldgroup', null);
		}
		else{
			window.requestTypeFieldEditorTableRow.find('select.fieldGroupDropdown option[value="'+$('#requestTypeFieldEditorModal').find('select.fieldGroupDropdown').val()+'"]').prop('selected',true);
			window.requestTypeFieldEditorTableRow.find('select.fieldGroupDropdown').change();
		}

		//window.requestTypeFieldEditorTableRow.attr('savedfieldindex',tableRow.attr('savedfieldindex'));
		//window.requestTypeFieldEditorTableRow.attr('datatypeid',tableRow.attr('datatypeid'));

		// 8PM hack to make sure this doesn't blow up.
		if (dropdownRelations == "No relation") {
			dropdownRelations = {};
		}

		window.requestTypeFieldEditorTableRow.attr('dropdownrelations', JSON.stringify(dropdownRelations));

		return true;
	}

	/**
	 * Scrapes the default values from the field editor and stores them in the default value JSON.
	 * @param {JSON} defaultValueJson The default value JSON object.
	 * @param {string} selector The JQuery selector string to find the value from.
	 */
	var packageDefaultValues = function(defaultValueJson, selector) {
		for (levelKey in defaultValueJson) {
			if (levelKey != "company") {
				
				$.each($(`.${levelKey}DefaultsTabs`).find(".tabContent"), function(i, tabContent) {
					var id = $(tabContent).attr(`${levelKey}id`);
					var defVal = $(tabContent).find(selector).val();

					defaultValueJson[levelKey][id] = defVal;
				});

			} else {
				defaultValueJson[levelKey] = $("#requestTypeFieldEditorModal").find(`${selector}.company`).val();
			}
		}
		return defaultValueJson;
	}

	/**
	 * Populates the field editor modal with data from the corresponding field's table row.
	 * @param {*} tableRow The JQuery row object that represents the current field.
	 */
	var populateRequestTypeFieldEditor = function(tableRow){
		window.requestTypeFieldEditorTableRow = tableRow;

		// Clear out the editor
		$('#requestTypeFieldEditorModal input[type="text"]').val('');
		$('#requestTypeFieldEditorModal input[type="checkbox"]').prop('checked',false);

		$('#requestTypeFieldEditorModal').attr('requesttypefieldid',tableRow.attr('requesttypefieldid'));
		$('#requestTypeFieldEditorModal').attr('isrequired',tableRow.attr('isrequired'));
		$('#requestTypeFieldEditorModal').attr('allowmultiple',tableRow.attr('allowmultiple'));
		$('#requestTypeFieldEditorModal').attr('isdisabled',tableRow.attr('isdisabled'));
		$('#requestTypeFieldEditorModal').attr('clearWhenDuplicate',tableRow.attr('clearWhenDuplicate'));
		$('#requestTypeFieldEditorModal').attr('restrictaccess',tableRow.attr('restrictaccess'));
		$('#requestTypeFieldEditorModal').attr('restrictaccesssettings',tableRow.attr('restrictaccesssettings'));
		$('#requestTypeFieldEditorModal').attr('notificationsettings',tableRow.attr('notificationsettings'));
		$('#requestTypeFieldEditorModal').attr('inrequeststable',tableRow.attr('inrequeststable'));
		$('#requestTypeFieldEditorModal').attr('savedfieldindex',tableRow.attr('savedfieldindex'));
		$('#requestTypeFieldEditorModal').attr('datatypeid',tableRow.attr('datatypeid'));
		var filterField = (tableRow.attr('filterField') == "1");
		$('[fieldid = requestTypeFieldAutoGenNotebook]').hide();	
		$('[fieldid = requestTypeFieldAutoGenProject]').hide();
		$('[fieldid = requestTypeFieldAutoGenExperiment]').hide();
		$('[fieldid = requestTypeFieldBiDirectinalLink]').hide();
		$("[fieldid=requestTypeFieldSendToELN]").hide();
		emptyDependencyTable();
		$("#requestTypeFieldCustomAttributesTable > tbody").empty();

		
		populateUserDefaultsTabs();
		populateGroupDefaultsTabs();
		
		var thisSavedField = window.savedFieldsArray.find(x => x.id == parseInt( tableRow.attr('savedfieldid') ));
		var requestTypeId = $('.dropdownEditorContainer').attr("requesttypeid");
		if (requestTypeId != "")
		{
			var requestType = window.pageModeRequestTypes.find(x => x.id == parseInt(requestTypeId));
		}

		$('#requestTypeFieldEditorModal .modalTitleFixed').text(thisSavedField['displayName']);

		var dataTypeIdParsed = parseInt(tableRow.attr('datatypeid'));
		if (dataTypeIdParsed != dataTypeEnums.DROP_DOWN || !filterField){
			$("#filterSection").hide();
		}
		else {
			$("#filterSection").show();
		}

		if(dataTypeIdParsed == dataTypeEnums.DROP_DOWN){
			var dropdownOptionsArray = [];
			$("#filterValueManagmentTable").show();
			if (window.requestTypePageMode == "requestTypes") {
				var priorityOptions = tableRow.attr("priorityOptions");
				if (priorityOptions) {
					priorityOptions = JSON.parse(priorityOptions);
				} else {
					priorityOptions = [];
				}
				initFilterTable(thisSavedField.options, priorityOptions, tableRow.attr('requesttypefieldid'));
			}

			dropdownOptionsArray.push($('<option value="">').text('-- None --'))
			if (thisSavedField['options']) {
				$.each(thisSavedField['options'], function(optionIndex, option){
					if(this['disabled'] == false){
						dropdownOptionsArray.push($('<option>').attr('value', option['dropdownOptionId']).text(option['displayName']));
					}
				});
			}
			$('#requestTypeFieldEditorModal').find('select.defaultValueDropdown').empty().append(dropdownOptionsArray);
		}
		else if (dataTypeIdParsed == dataTypeEnums.FILE_ATTACHMENT) {
			$("[fieldid=requestTypeFieldSendToELN]").show();
			$("[fieldid=requestTypeFieldSendToELN]").find("input").prop("checked", tableRow.attr("sendToELN") == "true");
		}
		else if (dataTypeIdParsed == 13 || dataTypeIdParsed == 14 || dataTypeIdParsed == 15)
		{
			if (dataTypeIdParsed == 13)
			{
				$('[fieldid = requestTypeFieldAutoGenNotebook]').show();	
				$('[fieldid = requestTypeFieldAutoGenNotebook]').find("input").prop('checked',tableRow.attr('autoGenNotebook') == 'true');
			}
			else if(dataTypeIdParsed == 14)
			{
				$('[fieldid = requestTypeFieldAutoGenProject]').show();
				$('[fieldid = requestTypeFieldAutoGenProject]').find("input").prop('checked',tableRow.attr('autoGenProject') == 'true');
			}
			else if(dataTypeIdParsed == 15)
			{
				//$('[fieldid = requestTypeFieldAutoGenExperiment]').show();  //wait to show this untill we are setting up auto gen for experement
				$('[fieldid = requestTypeFieldAutoGenExperiment]').find("input").prop('checked',tableRow.attr('autoGenExperement') == 'true');
			}

			$('[fieldid = requestTypeFieldBiDirectinalLink]').show();
			$('[fieldid = requestTypeFieldBiDirectinalLink]').find("input").prop('checked',tableRow.attr('biDirectinalLink') == 'true');
		} 

		$('#requestTypeFieldEditorModal .requestTypeFieldIsRequired').prop('checked', parseInt(tableRow.attr('isrequired')));
		$('#requestTypeFieldEditorModal .requestTypeFieldAllowMultiple').prop('checked', parseInt(tableRow.attr('allowmultiple')));
		$('#requestTypeFieldEditorModal .requestTypeFieldIsDisabled').prop('checked', parseInt(tableRow.attr('isdisabled')));
		$('#requestTypeFieldEditorModal .requestTypeFieldRestrictAccess').prop('checked', parseInt(tableRow.attr('restrictaccess')));
		$('#requestTypeFieldEditorModal .requestTypeFieldClearWhenDuplicate').prop('checked', parseInt(tableRow.attr('clearWhenDuplicate')));

		if(dataTypeIdParsed == dataTypeEnums.UNIQUE_ID) { 
			// restrict the restict access stuff to only can view 

			// Note: set the required default during field being added to the type or item 
			// Disable allow multiples 
			$('#requestTypeFieldEditorModal .requestTypeFieldAllowMultiple').prop('disabled', true);

			// Disable and auto check this since we are doing this by definition
			$('#requestTypeFieldEditorModal .requestTypeFieldClearWhenDuplicate').prop('checked', true);
			$('#requestTypeFieldEditorModal .requestTypeFieldClearWhenDuplicate').prop('disabled', true);

			// Disable "Allow Multiple Values" for data types - STRUCTURE, RICH TEXT and BIOSPIN-EDITOR - Sub task 7818 under tkt 5580
		} else if ( [dataTypeEnums.STRUCTURE, dataTypeEnums.RICH_TEXT, dataTypeEnums.BIOSPIN_EDITOR].includes(dataTypeIdParsed) ) {
			$('#requestTypeFieldEditorModal .requestTypeFieldAllowMultiple').prop('disabled', true);
		} 

		else {
			// make sure this is not disabled for anything else
			$('#requestTypeFieldEditorModal .requestTypeFieldClearWhenDuplicate').removeProp('disabled');
			$('#requestTypeFieldEditorModal .requestTypeFieldAllowMultiple').removeProp('disabled');
		}

		populateRequestTypeFieldRestrictionsContainer(tableRow, dataTypeIdParsed);
		hideFieldRestrictAccess();

		$('.requestTypeFieldNotificationsContainer').addClass('makeVisible');
		// Reset the checkboxes
		$('.requestTypeFieldNotificationsContainer table.requestTypeFieldNotificationsTable input[type="checkbox"]').prop('checked', false);

		var defaultValueJson = JSON.parse(tableRow.attr("defaultvaluejson"));
		if($.inArray(dataTypeIdParsed, [dataTypeEnums.TEXT, dataTypeEnums.LONG_TEXT, dataTypeEnums.INTEGER, dataTypeEnums.REAL_NUMBER]) > -1){

			for (levelKey in defaultValueJson) {
				if (levelKey != "company") {
					for (id in defaultValueJson[levelKey]) {
						$(`.tabContent[${levelKey}id=${id}]`).find("input.defaultValueInput").val(defaultValueJson[levelKey][id]);
					}
				} else {
					$('#requestTypeFieldEditorModal').find('input.defaultValueInput.company').val(defaultValueJson[levelKey]);
				}
			}

			$(".dependencyEditor").css("display", "none");
		}
		else if(dataTypeIdParsed == dataTypeEnums.DROP_DOWN){			
			for (levelKey in defaultValueJson) {
				if (levelKey != "company") {
					for (id in defaultValueJson[levelKey]) {
						$(`.tabContent[${levelKey}id=${id}]`).find(`select.defaultValueDropdown option[value=${parseInt(defaultValueJson[levelKey][id])}]`).prop("selected", true);
					}
				} else {
					$(`#requestTypeFieldEditorModal select.defaultValueDropdown.company option[value=${parseInt(defaultValueJson[levelKey])}]`).prop('selected', true);
				}
			}

			$(".dependencyEditor").css("display", "block");
			prepopulateDependencies();
		} else {
			$(".dependencyEditor").css("display", "none");
		}

		let fieldValuesList = JSON.parse(tableRow.attr("requesttypefieldcustomattributevalues"));
		if (fieldValuesList.length) {
			fieldValuesList.forEach(function(val, index) {
				addFieldCustomAttributeToEditor(val, requestType["requestTypeCustomAttributeDefinitions"]);
			});
		}

		$('#requestTypeFieldEditorModal .requestTypeFieldGroupContainer').html($('<div>').append(fieldGroupsDropdown.clone()).html());
		$('#requestTypeFieldEditorModal .requestTypeFieldGroupContainer').find('.fieldGroupDropdown option[value="' + (parseInt(tableRow.attr('fieldgroup'))-1) + '"]').prop('selected', true);

	}

	var hideFieldRestrictAccess = function() {
		var isChecked = $(".requestTypeFieldRestrictAccess").is(":checked");
		var displayText = isChecked ? "display:block" : "display:none";
		$(".requestTypeFieldRestrictAccessSection").attr("style", displayText);
	}

	var emptyDependencyTable = function() {
		// Empties the dropdown dependency table
		$(".dropdownDependencyBody").empty();
	}

	var changeTargetValues = function(rowNum, savedFieldId) {
		// Trigger function that changes the checkbox options when the target dropdown is changed.
		
		// Figure out which checkbox group we're looking at, then empty it.
		var selectorString = ".dropdownCheckboxes[rownum={rowNum}]".replace("{rowNum}", rowNum);
		$(selectorString).empty();

		var requestTypeId = $(".dropdownEditorContainer").attr("requesttypeid");

		var requestType = window.pageModeRequestTypes.find(x => x.id == requestTypeId);

		var currField = requestType.fields.find(x => x.requestTypeFieldId == savedFieldId);

		savedFieldId = currField.savedFieldId;
		
		// Look in the savedFieldsArray for savedFieldId.
		var savedField = window.savedFieldsArray.find(x => x.id == savedFieldId);

		if (savedField === undefined) {
			// If it doesn't exist, make a null checkbox that says as much.
			$(selectorString).append(makeCheckboxHolder(rowNum, null, "Target not found"));

		} else {
			// Otherwise, take each option and make a checkbox out of it.
			var options = savedField.options;
			$.each(options, function(index, option) {
				$(selectorString).append(makeCheckboxHolder(rowNum, option.dropdownOptionId, option.displayName));
			});
		}
	}
	
	var makeCheckboxHolder = function(rowNum, value, text) {
		// Helper function that makes the checkbox items.
		
		// Each checkbox is in a holder div for CSS formatting.
		var checkboxHolder = $("<div></div>").addClass("checkboxHolder");

		// Make the input and set all of the attributes accordingly. The checkbox will be disabled if
		// there is no actual value.
		$("<input />", {type: 'checkbox', id: 'cb' + rowNum + "-" + value, value: value, disabled: value === null}).appendTo(checkboxHolder);

		// Make a label for the checkbox.
		$("<label />", {'for': 'cb' + rowNum + "-" +value, text: text}).appendTo(checkboxHolder);

		return checkboxHolder;
	}
	
	var prepopulateDependencies = function() {
		// Loads the dependencies from the requestType if they don't exist in the DOM.

		// Check to make sure we don't have any current dependencies.
		var currentDependencies = $(window.requestTypeFieldEditorTableRow).attr("dropdownrelations");
		
		if (currentDependencies !== undefined) {
			// If we do, then load them and don't do the rest of this.
			loadCurrentDependencies(JSON.parse(currentDependencies));
			return;
		}

		// Figure out requestType and savedFieldId
		var requestTypeFieldId = $(window.requestTypeFieldEditorTableRow).attr("requesttypefieldid");
		var requestTypeId = $(".dropdownEditorContainer").attr("requesttypeid");
		var requestType = window.pageModeRequestTypes.find(x => x.id == requestTypeId);

		if (requestType === undefined) {
			return;
		}

		var currField = requestType.fields.find(x => x.requestTypeFieldId == requestTypeFieldId);

		if (currField === undefined) {
			return;
		}

		var savedFieldId = currField.savedFieldId;

		// Figure out the dependencies.
		var thisRowDependencies = $(window.requestTypeFieldEditorTableRow).attr("dependencies");
		
		if (thisRowDependencies === undefined) {
			// If we don't have any, then just stop here because there's nothing to do.
			return;
		}

		thisRowDependencies = thisRowDependencies.split(",");

		// Get the dependency values, then filter out the dependencies for this source field so we only have the
		// ones we care about.
		var fieldDependencyValues = requestType.fieldDependencyValues;
		var dependenciesThatExist = thisRowDependencies.filter(x => Object.keys(fieldDependencyValues).indexOf(x) >= 0);

		// Iterate through and make new rows that are populated with the dependency values.
		$.each(dependenciesThatExist, function(index, dependencyKey) {
			var srcVals = Object.keys(fieldDependencyValues[dependencyKey][savedFieldId]);
			
			$.each(srcVals, function(srcIndex, srcVal) {
				addDependencyRow();
				populateDependencyRow(srcVal, dependencyKey, fieldDependencyValues[dependencyKey][savedFieldId][srcVal]);
			});
		});
	}

	var loadCurrentDependencies = function(currentDependencies) {
		// Loads the dependencies that currently exist in the DOM.

		$.each(currentDependencies, function(depIndex, dependency) {
			
			if (requestTypePageMode == "requestTypes") {
				srcVal = dependency.dropDownOptionId;
				targetId = dependency.targetRequestTypeFieldId;
				targetVals = dependency.requestTypeFieldDropDownDependencyValues.map(x => x.targetDropDownOptionId);
			} else if (requestTypePageMode == "requestItemTypes") {
				srcVal = dependency.dropDownOptionId;
				targetId = dependency.targetRequestItemTypeFieldId;
				targetVals = dependency.requestItemTypeFieldDropDownDependencyValues.map(x => x.targetDropDownOptionId);
			}

			addDependencyRow();
			populateDependencyRow(srcVal, targetId, targetVals);
		});
		
	}
	
	var addDependencyRow = function() {
		// Adds a row to the dependency dropdown table.

		// Determine the next available row number we can use.
		var tableLength = $(".dropdownDependencyBody").children().length;
		var rowNum = 0;

		// If we have rows in the table, then we'll get the latest row number and increment that by 1.
		if (tableLength > 0) {
			var rowNum = parseInt($($(".dropdownDependencyBody").children()[tableLength - 1]).attr("rownum")) + 1;
		}

		// Instantiate the table row and everything that goes in it.
		var tr = $("<tr></tr>").attr("rownum", rowNum);

		var srcCol = makeSrcColDropdown(rowNum);
		var targetCol = makeTargetDropdown(rowNum);
		var targetVals = $("<div></div>").addClass("dropdownCheckboxes").attr("rowNum", rowNum);

		// By default we don't have anything selected, so make a blank checkbox with instructions on how to get values.
		var emptyCheckbox = $("<div></div>").addClass("checkboxHolder");
		$("<input />", {type: 'checkbox', id: 'cb'+rowNum, value: null}).attr("disabled", true).appendTo(emptyCheckbox);
		$("<label />", {'for': 'cb'+rowNum, text: "Select a Target"}).appendTo(emptyCheckbox);
		targetVals.append(emptyCheckbox);

		// Add the delete button.
		var deleteButton = $("<button></button>").addClass("basicActionButton").addClass("deleteRowButton").attr("rownum", rowNum).text("Delete");

		// Append everything to the table.
		tr.append($("<td></td>").append(srcCol)).append($("<td></td>").append(targetCol)).append($("<td></td>").append(targetVals)).append($("<td></td>").append(deleteButton));
		$(".dropdownDependencyBody").append(tr);
	}

	var populateDependencyRow = function(srcVal, targetVal, selectedTargets) {
		// Helper function to prepopulate a dependency row.
	
		// Get the rowNum. This only loads on table-load, so we can assume these are all sequential.
		var rowNum = $(".dropdownDependencyBody").children().length - 1;
	
		// Get the three objects we actually care about.
		var srcDropdown = $(".srcValues[rownum=" + rowNum + "]");
		var targetDropdown = $(".targetDropdowns[rownum=" + rowNum + "]");
		var targetCheckboxes = $(".dropdownCheckboxes[rownum=" + rowNum + "]");
		
		// Select the values for the two dropdowns, then call .change() on the targetDropdown to get that
		// trigger active.
		srcDropdown.val(srcVal);
		targetDropdown.val(targetVal);
		targetDropdown.change();
	
		// Now check off the values in the checkbox holders that are designated as selected.
		$.each(selectedTargets, function(index, target) {
			var selectorString = "#cb" + rowNum + "-" + target;
			$(selectorString).attr("checked", true);
		});
	}

	var getDropdownRelationFromTable = function() {
		// Turns the relational dropdown table into a JSON that gets stored in the DOM for later use.
	
		// Initialize the return object.
		var returnObj = [];
	
		// Figure out requestType and savedFieldId
		var requestTypeFieldId = $(window.requestTypeFieldEditorTableRow).attr("requesttypefieldid");
		var requestTypeId = $(".dropdownEditorContainer").attr("requesttypeid");
		var requestType = window.pageModeRequestTypes.find(x => x.id == requestTypeId);
		if(requestType != undefined)
		{
			var currField = requestType.fields.find(x => x.requestTypeFieldId == requestTypeFieldId);
		} 
		
		if (requestType === undefined) {
			return "No relation";
		}
	
		var currField = requestType.fields.find(x => x.requestTypeFieldId == requestTypeFieldId);
	
		if (currField === undefined) {
			return;
		}
	
		var savedFieldId = currField.savedFieldId;
		
		var srcFieldName = "requestTypeFieldId";
		var targetFieldName = "targetRequestTypeFieldId";
		var targetFieldDependencyKey = "requestTypeFieldDropDownDependencyValues"
	
		if (requestTypePageMode == "requestItemTypes") {
			srcFieldName = "requestItemTypeFieldId";
			targetFieldName = "targetRequestItemTypeFieldId";
			targetFieldDependencyKey = "requestItemTypeFieldDropDownDependencyValues"
		}
	
		$.each($(".dropdownDependencyBody").children(), function(index, row) {
	
			var rowObj = {};
	
			var srcId = parseInt(currField["requestTypeFieldId"]);
			var srcVal = parseInt($(".srcValues[rownum=" + index + "]").find(":selected").val());
			var targVal = parseInt($(".targetDropdowns[rownum=" + index + "]").find(":selected").val());
			var targChecks = $(".dropdownCheckboxes[rownum=" + index + "] > .checkboxHolder > input:checked").map(function() {
				return {"targetDropDownOptionId": parseInt(this.value)}
			}).get();
	
			if (targChecks.length == 0) {
				return;
			}
	
			var existingRow = returnObj.find(x => x[srcFieldName] == srcId && x.dropDownOptionId == srcVal && x[targetFieldName] == targVal);
	
			if (existingRow === undefined) {
				rowObj[srcFieldName] = srcId;
				rowObj["dropDownOptionId"] = srcVal;
				rowObj[targetFieldName] = targVal;
				rowObj[targetFieldDependencyKey] = targChecks;
	
				returnObj.push(rowObj);
			} else {
				existingRow[targetFieldDependencyKey] = existingRow[targetFieldDependencyKey].concat(targChecks);
			}
		});	
	
		return returnObj;
	}

	var makeSrcColDropdown = function(rowNum) {
		// Makes the dropdown container for the source values.
		var srcCol = $("<select></select>").addClass("srcValues").attr("rowNum", rowNum);

		// Give it the default value.
		srcCol.append($("<option></option>").text("-- Make a Selection --").val(null));

		// Figure out our requestType and savedField.
		var requestTypeFieldId = $(window.requestTypeFieldEditorTableRow).attr("requesttypefieldid");
		var requestTypeId = $(".dropdownEditorContainer").attr("requesttypeid");

		var requestType = window.pageModeRequestTypes.find(x => x.id == requestTypeId);
		
		if (requestType === undefined) {
			return srcCol;
		}

		var currField = requestType.fields.find(x => x.requestTypeFieldId == requestTypeFieldId);

		if (currField === undefined) {
			return srcCol;
		}

		var savedFieldId = currField.savedFieldId;
		var savedField = window.savedFieldsArray.find(x => x.id == savedFieldId);

		if (savedField === undefined) {
			return srcCol;
		}

		// Grab all of the options from savedField and turn each one into a dropdown that gets added to srcCol.
		var options = savedField.options;
		$.each(options, function(index, option) {
			$("<option></option>").text(option.displayName).val(option.dropdownOptionId).appendTo(srcCol);
		});
		return srcCol;
	}
	
	var makeTargetDropdown = function(rowNum) {
		// Make the dropdown for all of the possible target dropdowns.

		var targCol = $("<select></select>").addClass("targetDropdowns").attr("rowNum", rowNum);
		targCol.append($("<option></option>").text("-- Make a Selection --").val(null));
		
		// Figure out requestType, savedField, etc.
		var requestTypeFieldId = $(window.requestTypeFieldEditorTableRow).attr("requesttypefieldid");
		var requestTypeId = $(".dropdownEditorContainer").attr("requesttypeid");

		var requestType = window.pageModeRequestTypes.find(x => x.id == requestTypeId);
		
		if (requestType === undefined) {
			return targCol;
		}

		var currField = requestType.fields.find(x => x.requestTypeFieldId == requestTypeFieldId);

		if (currField === undefined) {
			return targCol;
		}

		var currFields = requestType.fieldsDict;

		$.each(currFields.sortOrder, function(index, key) {
			var field = currFields[key][0];

			if (field.requestTypeFieldId == currField.requestTypeFieldId || field.dataTypeId != 5) {
				return;
			}

			$("<option></option>").text(field.displayName).val(field.requestTypeFieldId).appendTo(targCol);
		});

		return targCol;
	}

	var getExistingDropdownRelation = function(requestType, savedFieldId) {
		// Looks in the request type for an existing dropdown relation for savedFieldId
		// and converts it into the format used for the dropdownrelation tr attribute.
		var returnObj = {};

		var fieldDependencies = requestType.fieldDependencies;
		var fieldDependencyValues = requestType.fieldDependencyValues;

		var targetIds = fieldDependencies[savedFieldId];
		if (fieldDependencyValues !== undefined)
		{
			$.each(targetIds, function(targIdIndex, targetId) {
				if(Object.keys(fieldDependencyValues).indexOf(targetId.toString()) < 0)
				{
					return;
				}
				var srcToTargetValJSON = fieldDependencyValues[targetId][savedFieldId];

				if (srcToTargetValJSON === undefined) {
					return;
				}

				var srcVals = Object.keys(srcToTargetValJSON);

				$.each(srcVals, function(srcValIndex, srcVal) {
					var targVals = srcToTargetValJSON[srcVal];


					if (Object.keys(returnObj).indexOf(srcVal) < 0) {
						returnObj[srcVal] = {};
					}
					
					returnObj[srcVal][targetId] = targVals;

				});
			});
		}
		return returnObj;
	}

	var updateGlobalFieldGroupsDropdown = function(numberOfGroups) {
		fieldGroupsDropdown = $('<select class="fieldGroupDropdown editorFieldDropdown">').html('<option value=""></option>');
		// +1 to add a group letter beyond currently used groups
		for(var i = 0; i < numberOfGroups+1; i++){
			fieldGroupsDropdown.append($('<option>').attr('value', i).text(fieldGroups[i]));
		} 
	}

	var getDefaultSelectValue = function() {
		return $("input[name=defaultSelect]:checked").val();
	}
	
	var populateRequestTypeFieldRestrictionsContainer = function(requestTypeFieldRowElement, datatypeid) {
		//requestTypeModule.populateUsersAndUserGroupsAllowedTables('requestTypeField');
		$('.requestTypeFieldRestrictionsContainer').addClass('makeVisible');
		chosenFieldName = requestTypeFieldRowElement.find('select.savedFieldDropdown option:selected').text();
		
		// Reset the checkboxes
		$('.requestTypeFieldRestrictionsContainer table.restrictAccessTable input[type="checkbox"]').prop('checked', false);
		
		var groupRows = $('.dropdownEditorContainer #requestTypeFieldAllowedGroupsTable tbody > div > div > tr');
		var userRows = $('.dropdownEditorContainer #requestTypeFieldAllowedUsersTable tbody > div > div > tr');

		// We dont want the users to be able to access all of the perms. So we will disable the ones we dont want them toutching. 
		// This prevents the user from backing themself in a corner.
		if (datatypeid == dataTypeEnums.UNIQUE_ID) {
			$.each(groupRows, function(index, row){
				$(row).find('input[type="checkbox"].canAddCheckbox').prop('disabled', true)
				$(row).find('input[type="checkbox"].canEditCheckbox').prop('disabled', true)
				$(row).find('input[type="checkbox"].canDeleteCheckbox').prop('disabled', true)
			});
	
			$.each(userRows, function(index, row){
				$(row).find('input[type="checkbox"].canAddCheckbox').prop('disabled', true)
				$(row).find('input[type="checkbox"].canEditCheckbox').prop('disabled', true)
				$(row).find('input[type="checkbox"].canDeleteCheckbox').prop('disabled', true)
			});
		} 
		else {
			$.each(groupRows, function(index, row){
				$(row).find('input[type="checkbox"].canAddCheckbox').removeProp('disabled')
				$(row).find('input[type="checkbox"].canEditCheckbox').removeProp('disabled')
				$(row).find('input[type="checkbox"].canDeleteCheckbox').removeProp('disabled')
			});
	
			$.each(userRows, function(index, row){
				$(row).find('input[type="checkbox"].canAddCheckbox').removeProp('disabled')
				$(row).find('input[type="checkbox"].canEditCheckbox').removeProp('disabled')
				$(row).find('input[type="checkbox"].canDeleteCheckbox').removeProp('disabled')
			});
		}


		if(requestTypeFieldRowElement.attr('restrictaccesssettings')){
			// Tick the checkboxes based on the settings attribute value
			restrictAccessSettings = JSON.parse(requestTypeFieldRowElement.attr('restrictaccesssettings'));
			console.log(restrictAccessSettings)
			populateRestrictAccessSettingsTables('requestTypeField', restrictAccessSettings['users'], restrictAccessSettings['groups']);
		}
		$('.requestTypeFieldRestrictionsContainer .restrictionsContainerTitle .restrictionsContainerTitleFieldName').text(chosenFieldName);
	}
	
	var updateRequestTypeFieldNotificationSettingsContainerAttribute = function() {
		notificationSettingsObject = {}
		if($('#requestTypeFieldNotificationsEditorSection').attr('notificationsettings')){
			notificationSettingsObject = JSON.parse($('#requestTypeFieldNotificationsEditorSection').attr('notificationsettings'))
		}
		groupsArray = [];
		$.each($('.requestTypeFieldNotificationsContainer').find('table#requestTypeFieldNotificationsTable tbody tr'), function(){
			group = {
				"groupId": parseInt($(this).attr('groupid')),
				"notifyByEmail": $(this).find('.notifyByEmailCheckbox').prop('checked'),
				"notifyByBrowser": $(this).find('.notifyByBrowserCheckbox').prop('checked')
			}
			groupsArray.push(group);
		});
		
		if(window.requestTypePageMode == "requestTypes"){
			notificationSettingsObject['groups'] = groupsArray;
		}
		else{
			notificationSettingsObject[$('#requestTypesDropdownForNotificationSettings').val()] = {"groups": groupsArray}
		}
		
	
		return notificationSettingsObject;
	}

	var updateNameDropDown = function(){

		//clear and re-populate fields drop down 
		var requestFieldRows = $("#requestTypeFieldsTable > tbody > tr");
		var reqFieldSelect = $("#requestNameSelectField");
		reqFieldSelect.empty();
		$(reqFieldSelect).append($("<option value='0'>--Not Used--</option>"));
	
		var restrictedDataTypes = [2,6,8,9];//excluded data types 

		$.each(requestFieldRows, function(){
	
			var fieldId = $(this).attr("savedfieldid");
			var requestFieldId = $(this).attr("requesttypefieldid");
			var newOption = $("<option></option>")
			var fieldInRequest = savedFieldsArray.find(x => x.id == fieldId)
			if (typeof fieldInRequest != "undefined")
			{
				if (restrictedDataTypes.indexOf(fieldInRequest['dataTypeId']) < 0)
				{
					$(newOption).attr("savedfieldid", fieldId);
					$(newOption).attr("value", requestFieldId);
					$(newOption).html(fieldInRequest['displayName']);
					reqFieldSelect.append(newOption);	
				}
			}
	
		});
	
		if(typeof reqFieldSelect.attr("savedItem") != undefined)
		{
			$("#requestNameSelectField").find('option[selected="selected"]').prop('selected', false);
			$("#requestNameSelectField").find('option[value="' + reqFieldSelect.attr("savedItem") + '"]').prop('selected', true);
		}
	}



	var getCodes = function(){
		//get drop down codes for incromenting numbers 

		var codeParams = {
			appName: "Workflow",
			setName: "reqNameIncrementingNumType"
		};

		ajaxModule().getCodes(codeParams).then(function(response) {
			response = utilities().decodeServiceResponce(response);
			var dd = $('#selectIncromentingNum');
			$(dd).append($("<option value='0'>--Not Used--</option>"));
			$.each(response, function()
			{
				var Option = $("<option></option>")
				$(Option).attr('value', this['codeValue']);
				$(Option).html(this['codeDescription']);
				$(dd).append(Option);
			});
		});
	
	}

	var populateUsersAndUserGroupsAllowedTables = function(selectorStringFragmentArray) {
		$.each(selectorStringFragmentArray, function (index, selectorStringFragment) {
			var allowedUsersTableRows = generateAllowedUsersTableRows();
			var allowedGroupsTableRows = generateAllowedGroupsTableRows();
			populateAllowedUsersTabs();
			populateAllowedGroupsTabs();
			$('.dropdownEditorContainer #' + selectorStringFragment + 'AllowedUsersTable > tbody').append(allowedUsersTableRows);
			$('.dropdownEditorContainer #' + selectorStringFragment + 'AllowedGroupsTable > tbody').append(allowedGroupsTableRows);
			$('.dropdownEditorContainer #' + selectorStringFragment + 'AllowedUsersTable > tbody, .dropdownEditorContainer #' + selectorStringFragment + 'AllowedGroupsTable > tbody').mCustomScrollbar({
				theme: "light-3",
				scrollButtons: {
					enable: false
				},
				mouseWheel: {
					preventDefault: true
				},
				scrollbarPosition: 'inside',
				autoExpandScrollbar: true,
				theme: 'dark',
				axis: "y",
				setWidth: "auto"
			});
		});
	}

	var populateRestrictAccessSettingsTables = function(selectorStringFragment, allowedUsers, allowedGroups) {
		console.log(selectorStringFragment)
		console.log(allowedUsers)
		console.log(allowedGroups)
	
		if (allowedUsers == null) {
			allowedUsers = [];
		}
	
		if (allowedGroups == null) {
			allowedGroups = [];
		}
	
		// Select all the appropriate checkboxes in the allowedUsers & allowedGroups tables

	
		if (selectorStringFragment == "requestType")
		{
			$.each(allowedUsers, function (allowedUserIndex, allowedUser) {
				$(".CanAddCheckbox[userId=" + allowedUser["userId"] + "]").prop("checked", allowedUser["canAdd"]);
				$(".CanViewCheckbox[userId=" + allowedUser["userId"] + "]").prop("checked", allowedUser["canView"]);
				$(".CanEditCheckbox[userId=" + allowedUser["userId"] + "]").prop("checked", allowedUser["canEdit"]);
				$(".CanDeleteCheckbox[userId=" + allowedUser["userId"] + "]").prop("checked", allowedUser["canDelete"]);
				$(".CanBeAssignedCheckbox[userId=" + allowedUser["userId"] + "]").prop("checked", allowedUser["canBeAssigned"]);
				//$(".OnlyNotifyRequestorCheckbox[userId=" + allowedUser["userId"] + "]").prop("checked", allowedUser["onlyNotifyRequestor"]);
			});

			$.each(allowedGroups, function (allowedGroupIndex, allowedGroup) {
				$(".CanAddCheckbox[groupId=" + allowedGroup["groupId"] + "]").prop("checked", allowedGroup["canAdd"]);
				$(".CanViewCheckbox[groupId=" + allowedGroup["groupId"] + "]").prop("checked", allowedGroup["canView"]);
				$(".CanEditCheckbox[groupId=" + allowedGroup["groupId"] + "]").prop("checked", allowedGroup["canEdit"]);
				$(".CanDeleteCheckbox[groupId=" + allowedGroup["groupId"] + "]").prop("checked", allowedGroup["canDelete"]);
				$(".CanBeAssignedCheckbox[groupId=" + allowedGroup["groupId"] + "]").prop("checked", allowedGroup["canBeAssigned"]);
				//$(".OnlyNotifyRequestorCheckbox[groupId=" + allowedGroup["groupId"] + "]").prop("checked", allowedGroup["onlyNotifyRequestor"]); 
			});
		}
		else 
		{
			$.each(allowedGroups, function (allowedGroupIndex, allowedGroup) {
	
				var thisTR = $('.dropdownEditorContainer #' + selectorStringFragment + 'AllowedGroupsTable tbody tr[groupid="' + allowedGroup['groupId'] + '"]');
				if (thisTR.length > 0) {
					thisTR.find('input[type="checkbox"].canAddCheckbox').prop('checked', allowedGroup['canAdd'])
					thisTR.find('input[type="checkbox"].canViewCheckbox').prop('checked', allowedGroup['canView'])
					thisTR.find('input[type="checkbox"].canEditCheckbox').prop('checked', allowedGroup['canEdit'])
					thisTR.find('input[type="checkbox"].canDeleteCheckbox').prop('checked', allowedGroup['canDelete'])
					thisTR.find('input[type="checkbox"].canBeAssignedCheckbox').prop('checked', allowedGroup['canBeAssigned'])
					//thisTR.find('input[type="checkbox"].onlyNotifyRequestorCheckbox').prop('checked', allowedGroup['onlyNotifyRequestor'])
				}
			});

			$.each(allowedUsers, function (allowedUserIndex, allowedUser) {

				var thisTR = $('.dropdownEditorContainer #' + selectorStringFragment + 'AllowedUsersTable tbody tr[userid="' + allowedUser['userId'] + '"]');
				if (thisTR.length > 0) {
					thisTR.find('input[type="checkbox"].canAddCheckbox').prop('checked', allowedUser['canAdd'])
					thisTR.find('input[type="checkbox"].canViewCheckbox').prop('checked', allowedUser['canView'])
					thisTR.find('input[type="checkbox"].canEditCheckbox').prop('checked', allowedUser['canEdit'])
					thisTR.find('input[type="checkbox"].canDeleteCheckbox').prop('checked', allowedUser['canDelete'])
					thisTR.find('input[type="checkbox"].canBeAssignedCheckbox').prop('checked', allowedUser['canBeAssigned'])
				}
			});
		}
		
	}
	
	var generateAllowedUsersTableRows = function() {
		var userTableRowsArray = []
		$.each(window.usersList, function (userIndex, thisUser) {
			var tableRow = $('<tr></tr>').attr('userid', thisUser['id']).attr('userindex', userIndex)
			tableRow.append($('<td></td>').append($('<div>').text(thisUser['fullName']).addClass('userFullNameContainer')))
			tableRow.append($('<td>').append('<input type="checkbox" class="canAddCheckbox">'), $('<td>').append('<input type="checkbox" class="canViewCheckbox">'), $('<td>').append('<input type="checkbox" class="canEditCheckbox">'), $('<td>').append('<input type="checkbox" class="canDeleteCheckbox">'), $('<td class="canBeAssignedCheckboxTD">').append('<input type="checkbox" class="canBeAssignedCheckbox">'))
			userTableRowsArray.push(tableRow)
		});
		return userTableRowsArray;
	}

	var generateAllowedGroupsTableRows = function() {
		var groupTableRowsArray = []
		$.each(window.groupsList, function (groupIndex, thisGroup) {
			var tableRow = $('<tr></tr>').attr('groupid', thisGroup['id']).attr('groupindex', groupIndex)
			tableRow.append($('<td></td>').append($('<div>').text(thisGroup['name']).addClass('groupNameContainer')))
			tableRow.append($('<td>').append('<input type="checkbox" class="canAddCheckbox">'), $('<td>').append('<input type="checkbox" class="canViewCheckbox">'), $('<td>').append('<input type="checkbox" class="canEditCheckbox">'), $('<td>').append('<input type="checkbox" class="canDeleteCheckbox">'), $('<td class="canBeAssignedCheckboxTD">').append('<input type="checkbox" class="canBeAssignedCheckbox">'))
			groupTableRowsArray.push(tableRow)
		});
		return groupTableRowsArray;
	}
	
	/**
	 * Populates the allowed users tabs.
	 */
	var populateAllowedUsersTabs = function() {
		var section = "allowedUser";
		emptyTabs(section);
		var sortedUsersList = utilities().sortArray(window.usersList, "fullName");
		generateAllowedUsersTabs(section, sortedUsersList);
	}

	/**
	 * Empties out the tabs belonging to the given section.
	 * @param {string} section The section of tabs to empty out.
	 */
	var emptyTabs = function(section) {
		// Start by emptying the containers holding the allowed users.
		$(`.editRequestTabs > .${section}s`).empty();
		$(`.editRequestTabs > .${section}sTabs`).empty();
	}

	/**
	 * Generates user restriction tabs for every user in the sorted user list.
	 * @param {string} section The section of tabs to empty out.
	 * @param {JSON[]} sortedUsersList The sorted user list.
	 */
	var generateAllowedUsersTabs = function(section, sortedUsersList) {
		$.each(sortedUsersList, function (userIndex, thisUser) {
	
			// Make the label element.
			var tabLabel = generateTabLabel(section, thisUser["fullName"], "userId", thisUser["id"]);
	
			// Make the container for all of the tabs.
			var tabContent = generateTabContent(section, thisUser["fullName"], "userId", thisUser["id"]);
	
			// Add a checkbox for each relevant setting.
			tabContent.append(generateSettingsTab("Can Add", thisUser["fullName"], thisUser["id"], "userId"));
			tabContent.append(generateSettingsTab("Can View", thisUser["fullName"], thisUser["id"], "userId"));
			tabContent.append(generateSettingsTab("Can Edit", thisUser["fullName"], thisUser["id"], "userId"));
			tabContent.append(generateSettingsTab("Can Delete", thisUser["fullName"], thisUser["id"], "userId"));
			tabContent.append(generateSettingsTab("Can Be Assigned", thisUser["fullName"], thisUser["id"], "userId").css("display", "none"));
	
			// Append the container and label to the approprate places.
			$(`.editRequestTabs > .${section}s`).append(tabLabel);
			$(`.editRequestTabs > .${section}sTabs`).append(tabContent);
		});
	}

	/**
	 * Populates the allowed groups tabs.
	 */
	var populateAllowedGroupsTabs = function() {
		var section = "allowedGroup";
		emptyTabs(section);
		var sortedGroupsList = utilities().sortArray(window.groupsList, "name");
		generateAllowedGroupsTabs(section, sortedGroupsList);
	}

	/**
	 * Generates user restriction tabs for every group in the sorted group list.
	 * @param {string} section The section of tabs to empty out.
	 * @param {JSON[]} sortedGroupsList The sorted group list.
	 */
	var generateAllowedGroupsTabs = function(section, sortedGroupsList) {
		$.each(sortedGroupsList, function (groupIndex, thisGroup) {
			// Make the label element.
			var tabLabel = generateTabLabel(section, thisGroup["name"], "groupId", thisGroup["id"]);
	
			// Make the container for all of the tabs.
			var tabContent = generateTabContent(section, thisGroup["name"], "groupId", thisGroup["id"]);
	
			// Add a checkbox for each relevant setting.
			tabContent.append(generateSettingsTab("Can Add", thisGroup["name"], thisGroup["id"], "groupId"));
			tabContent.append(generateSettingsTab("Can View", thisGroup["name"], thisGroup["id"], "groupId"));
			tabContent.append(generateSettingsTab("Can Edit", thisGroup["name"], thisGroup["id"], "groupId"));
			tabContent.append(generateSettingsTab("Can Delete", thisGroup["name"], thisGroup["id"], "groupId"));
			tabContent.append(generateSettingsTab("Can Be Assigned", thisGroup["name"], thisGroup["id"], "groupId"));
	
			// Append the container and label to the approprate places.
			$(`.editRequestTabs > .${section}s`).append(tabLabel);
			$(`.editRequestTabs > .${section}sTabs`).append(tabContent);
		});
	}

	/**
	 * Generates a tab label for the given user/group.
	 * @param {string} section The section of tabs to empty out.
	 * @param {string} name The name of the user or group.
	 * @param {string} idAttr The name of the ID attribute.
	 * @param {number} id The ID of the user/group this goes to.
	 */
	var generateTabLabel = function(section, name, idAttr, id) {
		return $("<button></button>")
			.addClass("tablinks")
			.addClass(`${section}s${name.replace(/ /g, '_')}`)
			.attr(idAttr, id)
			.text(name)
			.click(function () {
				openTab(section, name.replace(/ /g, '_'), idAttr, id);
			});
	}

	/**
	 * Generates a tab content holder for the given user/group.
	 * @param {string} section The section of tabs to empty out.
	 * @param {string} name The name of the user or group.
	 * @param {string} idAttr The name of the ID attribute.
	 * @param {number} id The ID of the user/group this goes to.
	 */
	var generateTabContent = function(section, name, idAttr, id) {
		return $("<div></div>")
			.addClass("tabContent")
			.addClass(`${section}Tab${name.replace(/ /g, '_')}`)
			.attr(idAttr, id);
	}

	/**
	 * Populates the user defaults tabs.
	 */
	var populateUserDefaultsTabs = function() {
		var section = "userDefault";
		emptyTabs(section);
		var sortedUsersList = utilities().sortArray(window.usersList, "fullName");
		generateUserDefaultsTabs(section, sortedUsersList);
	}

	/**
	 * Populates the group defaults tabs.
	 */
	var populateGroupDefaultsTabs = function() {
		var section = "groupDefault";
		emptyTabs(section);
		var sortedUsersList = utilities().sortArray(window.groupsList, "name");
		generateGroupDefaultsTabs(section, sortedUsersList);
	}

	/**
	 * Generates user default tabs for every user in the sorted user list.
	 * @param {string} section The section of tabs to empty out.
	 * @param {JSON[]} sortedUsersList The sorted user list.
	 */
	var generateUserDefaultsTabs = function(section, sortedUsersList) {
		$.each(sortedUsersList, function (userIndex, thisUser) {
	
			// Make the label element.
			var tabLabel = generateTabLabel(section, thisUser["fullName"], "userId", thisUser["id"]);
			//generateUserTabLabel(section, thisUser);
	
			// Make the container for all of the tabs.
			var tabContent = generateTabContent(section, thisUser["fullName"], "userId", thisUser["id"]);	
			tabContent.append(generateDefaultValueEditor());

			// Append the container and label to the approprate places.
			$(`.editRequestTabs > .${section}s`).append(tabLabel);
			$(`.editRequestTabs > .${section}sTabs`).append(tabContent);
		});
	}

	/**
	 * Generates group default tabs for every group in the sorted group list.
	 * @param {string} section The section of tabs to empty out.
	 * @param {JSON[]} sortedGroupsList The sorted group list.
	 */
	var generateGroupDefaultsTabs = function(section, sortedGroupsList) {
		$.each(sortedGroupsList, function (index, thisGroup) {
	
			// Make the label element.
			var tabLabel = generateTabLabel(section, thisGroup["name"], "groupId", thisGroup["id"]);
			//generateUserTabLabel(section, thisUser);
	
			// Make the container for all of the tabs.
			var tabContent = generateTabContent(section, thisGroup["name"], "groupId", thisGroup["id"]);	
			tabContent.append(generateDefaultValueEditor());

			// Append the container and label to the approprate places.
			$(`.editRequestTabs > .${section}s`).append(tabLabel);
			$(`.editRequestTabs > .${section}sTabs`).append(tabContent);
		});
	}

	/**
	 * Closes the currently active tab in the given section and opens the given tabName.
	 * @param {string} section The section of tabs we're operating in.
	 * @param {string} tabName The name of the tab to open.
	 * @param {string} idAttr The name of the ID attribute.
	 * @param {number} id The ID of the user/group this goes to.
	 */
	var openTab = function(section, tabName, idAttr, id) {
		$(`.${section}s > .tablinks`).removeClass("active");
		$(`.${section}s${tabName.replace(new RegExp("/", 'g'), "\\/")}[${idAttr}=${id}]`).addClass("active");
		$(`.${section}sTabs > .tabContent`).css("display", "none");
		$(`.${section}sTabs > .tabContent.${section}tab${tabName.replace(new RegExp("/", 'g'), '\\/')}[${idAttr}=${id}]`).css("display", "block");
	}

	var generateSettingsTab = function(settingName, groupName, groupId, idAttr) {

		var settingNameNoSpace = settingName.replace(/ /g, '');
		var className = settingNameNoSpace + "Checkbox";
		var idName = groupName + settingNameNoSpace;
		var label = groupName + settingNameNoSpace;
	
		var checkboxHolder = $("<div></div>").addClass("tabLabel");
		var checkboxDiv = $('<input type="checkbox" class="' + className + '" id="' + idName + '">').attr(idAttr, groupId);
		var checkBoxLabel = $("<label for='" + label + "'>").text(settingName);
		checkboxHolder.append(checkboxDiv, checkBoxLabel);
	
		return checkboxHolder;
	}

	/**
	 * Generates a default value editor.
	 */
	var generateDefaultValueEditor = function() {

		var containerDiv = $("<div>")
			.addClass("editorField")
			.attr("fieldid", "requestTypeFieldDefaultValue");

		var label = $("<label>")
			.addClass("editorFieldLabel")
			.text("Default Value");

		var textInput = $("<input>")
			.addClass("defaultValueInput")
			.attr("type", "text");
		
		var dropdownInput = $("<select>")
			.addClass("defaultValueDropdown defaultEditorDropdown")

		return containerDiv.append(label).append(textInput).append(dropdownInput);
		//<input class="defaultValueInput" type="text"><select class="defaultValueDropdown editorFieldDropdown"></select>
	}
	
	var documentReadyFunction = async function() {
	
		populateUsersAndUserGroupsAllowedTables(["requestType", "requestTypeField"]);
		getCodes();
		$('body').on('click','.newDropdownButton',function(event){
			showRequestTypeEditor();
		});
	
		$('body').on('click','.addSavedFieldButton',function(event){
			  addRequestTypeFieldToEditor();
		});
		
		$('body').on('click','#requestTypeRequestItemTypesEditorSection .addRequestItemTypeButton',function(event){
			  addRequestItemTypeToEditor();
		});
	
		$('body').on('click','.addCustomAttribute',function(event){
			addCustomAttributeToEditor();
	  	});
	
		$('body').on('click','.addFieldCustomAttribute',function(event){
			addFieldCustomAttributeToEditor();
	  	});

		$('body').on('click','table#requestTypeCustomAttributesTable > tbody > tr > td > .editorSectionTableRowDeleteButton',function(event){
			let tableId = $(this).parent().parent().parent().parent().attr("id");
			$(this).parent().parent().remove();
			updateAttrDropdowns(tableId);
		});
	
		$('body').on('click','table#requestTypeFieldCustomAttributesTable > tbody > tr > td > .editorSectionTableRowDeleteButton',function(event){
			let tableId = $(this).parent().parent().parent().parent().attr("id");
			$(this).parent().parent().remove();
			updateAttrDropdowns(tableId);
		});
		
		$('body').on('click',".autoGenCheck", function(e){
	
			if ($(this).prop('checked') == true)
			{
				$('[fieldid = requestTypeFieldBiDirectinalLink]').find("input").prop('checked', true);
			}
		});
	
		$('body').on('click','.dropdownEditorSubmit', async function(event){
			let response;
			if (requestTypePageMode == "requestTypes") {
				response = await submitRequestTypeEditor();
			} else {
				response = await submitRequestItemTypeEditor();
			}

			var requestTypeId = editor.attr('requesttypeid') !== "" ? parseInt(editor.attr('requesttypeid')) : 0;
			var requestTypeName = editor.find('[fieldid="displayName"] input[type="text"]').val();
			var reqTypeOrReqItemTypeNotificationText = "request type";
			if (window.requestTypePageMode == "requestItemTypes") {
				reqTypeOrReqItemTypeNotificationText = "request item type";
			}

			let notificationTitle;
			if (Object.keys(response).indexOf("error") >= 0) {
				console.log("error");

				if (requestTypeId) {
					notificationTitle = 'Failed to update ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '".';
				} else {
					notificationTitle = 'Failed to create new "' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '".';
				}

				window.upsertRequestTypeNotification.update({ 'title': notificationTitle, 'message': response.error, type: "danger" });

			} else {
				console.log("success");

				if (requestTypeId) {
					notificationTitle = 'Successfully updated ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '".';
				}
				else {
					notificationTitle = 'Successfully created new ' + reqTypeOrReqItemTypeNotificationText + ' "' + requestTypeName + '".';
				}
				window.upsertRequestTypeNotification.update({ 'title': notificationTitle, 'message': "", type: "success" });
				swal({
					title: "Successfully updated",
					type: "success",
					confirmButtonText: "Ok",
					timer: 1100
				});
				hideRequestTypeEditor();

				location.reload();
			}
		});
	
		$('body').on('click','.dropdownEditorCancel',function(event){
			hideRequestTypeEditor();
		});
	
		$('body').on('click','table#dropdownsTable tr td',function(event){
			var requestTypeId = $("#dropdownsTable").DataTable().row($(this).parent()).data()[7];
			showRequestTypeEditor(requestTypeId);
		});
	
		$('body').on('click','table#requestTypeFieldsTable > tbody > tr > td > .editorSectionTableRowDeleteButton',function(event){
			$(this).parent().parent().remove();
		});
		
		$('body').on('click','table#requestTypeRequestItemTypesTable > tbody > tr > td > .editorSectionTableRowDeleteButton',function(event){
			$(this).parent().parent().remove();
		});
	
		$('body').on('change','select#dataTypeDropdown',function(event){
			if($(this).val() == "5"){
				$('#dropdownOptionsEditorSection').addClass('makeVisible');
				$('#dropdownOptionsEditorSection #dropdownOptionsTable > tbody').empty();
			}
			else{
				$('#dropdownOptionsEditorSection').removeClass('makeVisible');
			}
		});
	
		// STILL NEEDS TO BE CHANGED(!)
		$('body').on('change','select#savedDropdownsListDropdown',function(event){
			$('#dropdownOptionsTable > tbody').empty();
			if($(this).val() !== ""){
				var selectedDropdownObject = window.dropdownsArray[parseInt($(this).val())];
				// Make Dropdown Options table for this dropdown
				if(typeof selectedDropdownObject['options'] !== "undefined"){
					$.each(selectedDropdownObject['options'], function(index, option){
						addRequestTypeFieldToEditor(option, true, true);
					});
				}
				if($('#dropdownOptionsEditorSection').hasClass('savedDropdownIsSynced')){
					$('#dropdownOptionsEditorSection button.newDropdownOptionButton').prop('disabled',true)
					$('#dropdownOptionsEditorSection #dropdownOptionsTable').find('input, button').prop('disabled',true)
				}
			}
		});
	
		$('body').on('change','#savedDropdownsListSyncCheckbox',function(event){
			var isChecked = $(this).prop('checked');
			if(isChecked){
				$('select#savedDropdownsListDropdown').change();
				$('#dropdownOptionsEditorSection').addClass('savedDropdownIsSynced');
				$('#dropdownOptionsEditorSection button.newDropdownOptionButton').prop('disabled',true)
				$('#dropdownOptionsEditorSection #dropdownOptionsTable').find('input, button').prop('disabled',true)
			}
			else{
				$('#dropdownOptionsEditorSection').removeClass('savedDropdownIsSynced');
				$('#dropdownOptionsEditorSection button.newDropdownOptionButton').prop('disabled',false)
				$('#dropdownOptionsEditorSection #dropdownOptionsTable').find('input, button').prop('disabled',false)
			}
		});
	
		$('body').on('change','.requestType_requestItemTypeDropdown',function(event){
			var thisRequestItemTypeName = $(this).find('option:selected').text();
			$(this).parent().parent().find('input[type="text"].requestType_requestItemCustomName').val(thisRequestItemTypeName);
		});
	
		$('body').on('change','.dropdownEditorContainer #dataTypeDropdown',function(event){
			dataTypeId = $(this).val();
			$('.dropdownEditorContainer').attr('datatypeid',dataTypeId);
		});
	
		$('body').on('change', '.dropdownEditorContainer .editorField[fieldid="restrictAccess"] input[type="checkbox"]', function(event){
			var isChecked = $(this).prop('checked');
			if(isChecked){
				$('.editorSection.requestTypeRestrictAccessSection').addClass('makeVisible');
				if (requestTypePageMode == "requestTypes") {
					$("#requestTypeAllowedAppsEditorSection").show();
				} else {
					$("#requestTypeAllowedAppsEditorSection").hide();
				}
			}
			else{
				$('.editorSection.requestTypeRestrictAccessSection').removeClass('makeVisible');
			}
		});
	
		$('body').on('click', '.requestTypeFieldRestrictionsContainer .cancelChangesButton', function(event){
			$(this).closest('.requestTypeFieldRestrictionsContainer').removeClass('makeVisible');
		});
	
		$('body').on('click', '.requestTypeFieldRestrictionsContainer .submitUpdateButton', function(event){
			var requestTypeFieldRestrictionsContainer = $(this).closest('.requestTypeFieldRestrictionsContainer');
			allowedUsersArray = [];
			$.each(requestTypeFieldRestrictionsContainer.find('table#requestTypeFieldAllowedUsersTable tbody tr'), function(){
				allowedUser = {
					"userId": parseInt($(this).attr('userid')),
					"canAdd": $(this).find('.canAddCheckbox').prop('checked'),
					"canView": $(this).find('.canViewCheckbox').prop('checked'),
					"canEdit": $(this).find('.canEditCheckbox').prop('checked'),
					"canDelete": $(this).find('.canDeleteCheckbox').prop('checked')
				}
				allowedUsersArray.push(allowedUser);
			});
			
			allowedGroupsArray = [];
			$.each(requestTypeFieldRestrictionsContainer.find('table#requestTypeFieldAllowedGroupsTable tbody tr'), function(){
				allowedGroup = {
					"groupId": parseInt($(this).attr('groupid')),
					"canAdd": $(this).find('.canAddCheckbox').prop('checked'),
					"canView": $(this).find('.canViewCheckbox').prop('checked'),
					"canEdit": $(this).find('.canEditCheckbox').prop('checked'),
					"canDelete": $(this).find('.canDeleteCheckbox').prop('checked')
				}
				allowedGroupsArray.push(allowedGroup);
			});
			
			restrictAccessSettings = {"users": allowedUsersArray, "groups": allowedGroupsArray}
			requestTypeFieldRestrictionsContainer.removeClass('makeVisible');
		});
	
		$('body').on('click', 'button.manageFieldNotificationsButton', function(event){
			thisRequestTypeFieldRowElement = $(this).closest('tr');
			
			// Take the current notification settings and apply them to #requestTypeFieldNotificationsEditorSection
			var notificationSettings = thisRequestTypeFieldRowElement.attr('notificationsettings')
			$('#requestTypeFieldNotificationsEditorSection').attr('notificationsettings', notificationSettings)
			
			window.currentNotificationSettingsRow = thisRequestTypeFieldRowElement;
		});
	
		$('body').on('click', '.requestTypeFieldNotificationsContainer .submitUpdateButton', function(event){
			notificationSettingsObject = updateRequestTypeFieldNotificationSettingsContainerAttribute()
	
			window.currentNotificationSettingsRow.attr('notificationsettings',JSON.stringify(notificationSettingsObject)).removeClass('activeRow')
	
			$('.requestTypeFieldNotificationsContainer').removeClass('makeVisible');
		});
	
		$('body').on('click', '.requestTypeFieldNotificationsContainer .cancelChangesButton', function(event){
			$(this).closest('.requestTypeFieldNotificationsContainer').removeClass('makeVisible');
			window.currentNotificationSettingsRow.removeClass('activeRow')
		});
	
		$('body').on('change', 'select#requestTypesDropdownForNotificationSettings', function(event){
			/* Leaving this for now - not time to do this step yet (!)(!)
			var notificationSettings = JSON.parse($('#requestTypeFieldNotificationsEditorSection').attr('notificationsettings'))
			$.each(notificationSettings, function(){
				this['']
			});
			*/
		});
	
		$('body').on('change', 'table#requestTypeFieldsTable select.savedFieldDropdown', function(event){
	
			$(this).find('option[selected="selected"]').prop('selected', false)
			$(this).find('option:selected').prop('selected', true)
	
			updateRequestTypeFieldSavedFieldChoice($(this).closest('tr'));
		});

		$("#requestTypeAllowedAppsSelect").on("change", async function() {
			let appId = $(this).val();
			await updateCustAttrDefs(appId);
		});
	
		await Promise.all(dtPromise);
		await populateDataTypes();
		await ajaxModule().populateSavedFieldsList();
		
		populateRequestTypesTable();
			
		$('#requestTypeFieldsTable > tbody').sortable({placeholder: "ui-state-highlight", helper: 'clone'})
	
		if(window.requestTypePageMode == "requestTypes"){
			ajaxModule().populateRequestItemTypesList();
		} else {
			$($("#requestTypeFieldsTable > thead > tr > th")[4]).addClass('hide')
		}
	
		$('body').on('change', 'select.fieldGroupDropdown', function(event){
			// Need to find out how many groups are necessary to show in the dropdowns now
			var greatestFieldGroupNumber = 0;
			$('#requestTypeFieldsTable select.fieldGroupDropdown').each(function(){
				if($(this).val() !== ""){
					var thisFieldGroupNumber = parseInt($(this).val())+1;
					console.log(thisFieldGroupNumber)
					if(thisFieldGroupNumber > greatestFieldGroupNumber){
						greatestFieldGroupNumber = thisFieldGroupNumber;
					}
				}
			});
			console.log(greatestFieldGroupNumber);
			updateGlobalFieldGroupsDropdown(greatestFieldGroupNumber);
			// Replace the dropdowns without changing their values
			$('#requestTypeFieldsTable select.fieldGroupDropdown').each(function(){
				var currentDropdownValue = $(this).val();
				$(this).html(fieldGroupsDropdown.html());
				$(this).find('option[value="' + currentDropdownValue + '"]').prop('selected', true);
			});
			var newFieldGroupValue = ""
			if(!isNaN( parseInt($(this).val()) )){
				newFieldGroupValue = parseInt($(this).val())+1;
			}
			$(this).closest('tr').attr('fieldgroup', newFieldGroupValue)
		});
	
		$('body').on('click', 'button.manageRequestItemTypeNotificationSettingsButton', function(event){
			thisRequestItemTypeRowElement = $(this).closest('tr');
			
			// Take the current notification settings and apply them to #requestItemReprioritizationNotificationsEditorSection
			var notificationSettings = thisRequestItemTypeRowElement.attr('notificationsettings')
			$('#requestItemReprioritizationNotificationsEditorSection').attr('notificationsettings', notificationSettings)
			
			window.currentRequestItemReprioritizationNotificationSettingsRow = thisRequestItemTypeRowElement;
			populateRequestItemReprioritizationNotificationsContainer(thisRequestItemTypeRowElement);
			$('#reprioritizationRequestItemTypeNotificationSettingsModal').modal('show');
		});
	
		$('body').on('click', '#reprioritizationRequestItemTypeNotificationSettingsModal .submitUpdateButton', function(event){
			notificationSettingsObject = updateRequestItemNotificationSettingsContainerAttribute()
			window.currentRequestItemReprioritizationNotificationSettingsRow.attr('notificationsettings',JSON.stringify(notificationSettingsObject['groups'])).removeClass('activeRow')
			$('#reprioritizationRequestItemTypeNotificationSettingsModal').modal('hide');
		});
	
		$('body').on('click', '#reprioritizationRequestItemTypeNotificationSettingsModal .cancelChangesButton', function(event){
			$('#reprioritizationRequestItemTypeNotificationSettingsModal').modal('hide');
		});
	
		$('body').on('click', '.manageFieldOptionsButton', function(event){
			
			$('#requestTypeFieldEditorModal .modal-content').html( populateRequestTypeFieldEditor($(this).closest('tr')) );
			$('#requestTypeFieldEditorModal').modal('show');
		});
	
		$('body').on('click', '.requestTypeFieldEditorCancel', function(event){
			$('#requestTypeFieldEditorModal').modal('hide');
		});
	
		$('body').on('click', '.requestTypeFieldEditorSubmit', function(event){
			var success = submitRequestTypeFieldEditor();
	
			if (success) {
				$('#requestTypeFieldEditorModal').modal('hide');
			}
		});
	
		$("input[name=defaultSelect]").change(function() {
			$("input[name=defaultSelect]").attr("disabled", this.value != "None");
			if (this.value == "None" || this.value == "Company") {
				$("#defaultDropdownOptions").attr("disabled", true);
				$("#defaultDropdownOptions").hide();
			} else {
				$("#defaultDropdownOptions").empty();
				$("#defaultDropdownOptions").append('<option value="None" selected emptyDefaultOption>-- Make a Selection --</option>');
				$("#defaultDropdownOptions").attr("disabled", false);
				$("#defaultDropdownOptions").show();
	
				var list;
				var name = "";
				if (this.value == "Group") {
					list = groupsList;
					name = "name";
				} else if (this.value == "User") {
					list = usersList;
					name = "fullName";
				} else {
					return false;
				}
	
				$.each(list, function(index, value) {
					var option = $("<option></option>").attr("value", value.id).text(value[name]);
					$("#defaultDropdownOptions").append(option);
				});
			}
		});
	
		$("body").on("click", ".addDependencyButton", function() {
			addDependencyRow();
		});
	
		$("body").on("change", ".targetDropdowns", function() {
			changeTargetValues($(this).attr("rowNum"), $(this).val());
		});
	
		$("body").on("click", ".deleteRowButton", function() {
			var rowNum = $(this).attr("rownum");
			var selectorString = ".dropdownDependencyBody > tr[rownum={rowNum}]".replace("{rowNum}", rowNum);
			$(selectorString).remove();
		});

		$("body").on("click", "#configRequestNameAccord", function(){
			updateNameDropDown();
		})
	
		$("body").on("click", "#useField", function(){
			updateNameDropDown();
		})
		$("body").on("change", "#requestNameSelectField", function(){
			$(this).attr("savedItem", $(this).val());
			updateNameDropDown();
		})

		$("body").on("click", "#requestNamesCheck", function(){
			updateNameDropDown();
		})

		$("body").on("click", "#configRequestNotifications", function(){
			openNotificationEditor($(this).attr("requesttypeId"));
		});

		$(".requestTypeFieldRestrictAccess").on("click", function() {
			hideFieldRestrictAccess()
		});

		$("body").on("click", ".filterValueCheckbox[existing='true']", function(event){
			if (window.top.isSupport == false)
			{
				swal("Please contact support@arxspan.com!", "This action may lead to data loss.", "warning");
			}
		});


		$("body").on("click", ".filterValueCheckbox:checked", function(event){
			if(!window.top.isSupport)
			{
				swal({
					title: "Once you save this option you will not have the ability to change or modify it.",
					text: "Are you sure you want to make this change?",
					type: "warning",
					confirmButtonText: "Yes",
					cancelButtonText: "No",
					showCancelButton: true
				},
				function (isConfirm) {
					if (isConfirm) {
						updatePriorityTable($(event.target).closest("table"), $(event.target).closest("tr"));
					}
					else {
						$(event.target).attr("checked", false)
						
					}

				});
			}
			else
			{
				updatePriorityTable($(event.target).closest("table"), $(event.target).closest("tr"));
			}
		});

		$("body").on("click", ".filterValueCheckbox:not(:checked)", function(event){
			updatePriorityTable($(event.target).closest("table"), $(event.target).closest("tr"));
		});


		window.historical = false;
		if (window.top.isSupport == true)
		{
			pikadaySettingsObject = {
				firstDay: 1,
				minDate: new Date(1990, 0, 1),
				maxDate: new Date(2040, 12, 31),
				yearRange: [1990, 2040],
				format: 'MM/DD/YYYY',
				defaultDate:  new Date(),
				setDefaultDate: true
			}
			var pikDay = $("#getAsOfDateIn").pikaday(pikadaySettingsObject);
			$("#asOfTime").val(`${new Date().getHours()}:${new Date().getMinutes()}`)
			$("body").on("change","#getAsOfDateIn", function(e){
				window.historical = true;
				$("#dropdownsTable").DataTable().rows().remove().draw();
				populateRequestTypesTable(`${$("#getAsOfDateIn").val()} ${$("#asOfTime").val()}`);
				hideRequestTypeEditor();
				
			});
			$("body").on("change","#asOfTime", function(e){
				window.historical = true;
				$("#dropdownsTable").DataTable().rows().remove().draw();
				populateRequestTypesTable(`${$("#getAsOfDateIn").val()} ${$("#asOfTime").val()}`);
				hideRequestTypeEditor();
				
			});
		}

	}

	var stringNotifications = function(notification){
		var str = "";
		$.each(notification, function(int, item){
			if (str == "")
			{
				str += JSON.stringify(item);
			}
			else
			{
				str += "||| " + JSON.stringify(item);
			}
		})
		if (str == "")
		{
			str = "null"
		}
		return (str)
	}

	/**
	 * Init filter value managment table for drop downs.
	 * @param {JSON} fieldOptions list of options to add to the table.
	 * @param {JSON} requestSettings settings used for loading the existing config.
	 * @param {number} requestTypeFieldId request type field id for empty OBJ.
	 */
	var initFilterTable = function(fieldOptions, requestSettings, requestTypeFieldId) {
	
		if (fieldOptions != undefined && fieldOptions.length == 0)
		{
			return;
		}

		//find the table body
		var $table = $("#filterValueManagmentTable");

		//make sure we have a table
		if ($table.length > 0)
		{
			// make blank for data to be stored
			var tableData = [];
			$.each(fieldOptions, function(index, option){

				var optionSettings = {};
				//make blank as backup new data
				var emptyObj = {
					id : null,
					requestTypeFieldId: requestTypeFieldId,
					dropDownOptionId: option.dropdownOptionId,
					sortOrder : index + 1,
					queueable : false,
				};
				if (requestSettings.length == 0)
				{
					optionSettings = emptyObj;
				}
				else
				{
					optionSettings = requestSettings.find(x => x.dropDownOptionId == option.dropdownOptionId);
					if (optionSettings == undefined)
					{
						optionSettings = emptyObj;
					}
				}
				//setup data to go into table
				var rowData = {
					id: optionSettings.id,
					sortOrder: optionSettings.sortOrder,
					optionName: option.displayName,
					queueable: optionSettings.queueable,
					existing: optionSettings.id != null && optionSettings.queueable == true,
					requestTypeFieldId: optionSettings.requestTypeFieldId,
					dropDownOptionId: option.dropdownOptionId,
				}

				tableData.push(rowData);

			});

			var columnDefs = 
			[
				{
					"className": 'dragHandle',
					"name": "",
					"orderable": false,
					"data": null,
					"defaultContent": '',
					"title": "",
					"render": function (data, type, row) {
						var holderDiv = $("<div>");
						var requestItemDragHandle = $('<div title="Drag Handle" class="requestItemDragHandle">').append($('<i class="material-icons">').text("reorder"));
						var requestItemDragToReorder = $('<button class="requestItemDragToReorder btn">');
						requestItemDragToReorder.append(requestItemDragHandle);
						holderDiv.append(requestItemDragToReorder);
						if (!row.queueable)
						{
							return holderDiv.html();
						}
					}
				},{
					"data": "sortOrder",
					"name": "sortOrder",
					"title": "Order", 
				
				},{
					"data": "optionName",
					"name": "optionName",
					"title": "Option Name", 
				
				},{
					"data": "queueable",
					"name": "filterValue",
					"title": "Filter Value", 
					"render": function (data, type, row) {
						var checked = "";
						var disable = "";
						if (data)
						{
							checked = "checked";
						}
						if (window.top.isSupport == false && row.existing)
						{
							disable = "disabled title='Contact Support to alter this option.'";
						}
						return `<input type="checkbox" class="filterValueCheckbox" ${disable} existing=${row.existing} ${checked}></input>`;
					}
				}
			];

			var reorderSettings = {
				snapX: true,
				selector: 'td:first-child .requestItemDragToReorder',
				dataSrc: "sortOrder"
			}

			if ($.fn.DataTable.isDataTable("#filterValueManagmentTable")) {
				$("#filterValueManagmentTable").DataTable().destroy();
				$("#filterValueManagmentTable").empty();            
			}

			tableData = utilities().sortArray(tableData, "sortOrder");

			var table = $("#filterValueManagmentTable").DataTable({
				columns: columnDefs,
				columnDefs: [
					{ "searchable": false, "targets": [0]}
				],
				data: tableData,
				ordering: false,
				info: false,
				order: [[2,"asc"]],
				searching: false,
				paging: false,
				autoWidth: false,
				'rowReorder': reorderSettings
			});

			table.on( 'row-reordered', function ( event, diff, edit ) {
				console.log(event, diff, edit);
				var datatable = $(event.target).DataTable()
				var data = utilities().sortArray( datatable.data().toArray() , "sortOrder");

				datatable.clear();
				datatable.rows.add(data);
				datatable.draw();

				updatePriorityTable($(event.target))

			});

		}
		else 
		{
			console.warn("Did not find filter table body.");
		}
	}

	/**
	 * Update the table to automaticly set order and toggle checkboxes.
	 * @param {Element} table The table refrance for Data Tables.
	 * @param {Element} row The row we are touching.
	 */
	var updatePriorityTable = function(table, row = null){
		var datatable = $(table).DataTable();
		if (row)
		{
			datatable.row(row).data().queueable = !datatable.row(row).data().queueable;
		}

		var data = datatable.data().toArray();
		data = data.filter(x=> x.queueable).concat(data.filter(x => !x.queueable));
		$.each(data, function(index, obj){
			if(obj.queueable)
			{
				obj.sortOrder = 1;
			}
			else
			{
				var filterLen =  data.filter(x => x.queueable).length;
				var offset = filterLen == 0? 1 : 2;
				obj.sortOrder = (index + offset) - filterLen;
			}
		});
		console.log(data)
		datatable.clear();
		datatable.rows.add(data);
		datatable.draw();

	}

	let populateApplications = async function(appList) {
		appList.forEach(function(app, index) {
			let appOption = $("<option>").addClass("requestTypeAllowedOption")
										.val(app.id)
										.text(app.name);
			$("#requestTypeAllowedAppsSelect").append(appOption);
		});

	}

	/**
	 * Reach out to the config service to get a list of vendor attributes for the given appId.
	 * @param {number} appId The application ID.
	 */
	let updateCustAttrDefs = async function(appId) {
		let vendorEndpointData = await ajaxModule().getVendorEndpointData(appId);
		let vendorCustAttrDefList = vendorEndpointData.requestTypeCustomAttributeDefinitions;

		// If we have any attributes, we can proceed.
		if (vendorCustAttrDefList.length > 0) {
			custAttrDefList = [];

			// For every vendor attribute, check to see if there's an existing corresponding attribute saved in the DB.
			// If there is, use that, otherwise, use the vendor provided one.
			vendorCustAttrDefList.forEach(function(attrDef) {
				let requestTypeCustAttrDef = requestTypeCustomAttributeDefinitions.find(rtAttrDef => rtAttrDef.vendorAttributeId == attrDef.vendorAttributeId && rtAttrDef.isFieldLevel == attrDef.isFieldLevel);
				let attrToUse = attrDef;
				if (requestTypeCustAttrDef) {
					attrToUse = requestTypeCustAttrDef;
				}

				custAttrDefList.push(attrToUse);
			});

			// Show the attribute tables.
			$("#requestTypeAttributeTable").show();
			$("#requestTypeFieldAttributesTable").show();
		}
	}

	/**
	 * Passthrough function for addAttrRowToTable that adds a row to the request type attribute table.
	 * @param {JSON} val The value, if exists.
	 * @param {JSON[]} attrDefsList The list of attributes, if exists.
	 */
	let addCustomAttributeToEditor = function(val, attrDefsList) {
		addAttrRowToTable(val, attrDefsList, "requestTypeCustomAttributesTable", false);		
	}
	
	/**
	 * Passthrough function for addAttrRowToTable that adds a row to the field attribute table.
	 * @param {JSON} val The value, if exists.
	 * @param {JSON[]} attrDefsList The list of attributes, if exists.
 	 */
	let addFieldCustomAttributeToEditor = function(val, attrDefsList) {
		addAttrRowToTable(val, attrDefsList, "requestTypeFieldCustomAttributesTable", true);
	}

	/**
	 * Helper function to add an attribute row to tableId.
	 * @param {JSON} val The value, if exists.
	 * @param {JSON[]} attrDefsList The list of attributes, if exists.
	 * @param {string} tableId The table's DOM ID.
	 * @param {bool} isFieldLevel Is this a field level table?
	 */
	let addAttrRowToTable = function(val, attrDefsList, tableId, isFieldLevel) {
		// Instantiate the table row and cells.
		let tableRow = $("<tr></tr>");
		let attrDropdownTd = $("<td></td>")
							.addClass("attrDropdown");
		let attrDescTd = $("<td></td>")
							.addClass("attrDesc")
							.text("Please select an attribute to the left.");
		let attrDataTypeTd = $("<td></td>")
							.addClass("attrDataType");
		let valEntryTd = $("<td></td>")
							.addClass("attrVal");
		let deleteBtnTd = $("<td></td>")
							.addClass("attrDel");

		// Make the dropdown and attach the change handler.
		let attrDropdown = makeAttrDropdown(isFieldLevel);
		attrDropdown.on("change", function() {
			attrDropdownChangeEvt(
				$(this),
				$(this).val(),
				tableRow,
				attrDescTd,
				attrDataTypeTd,
				valEntryTd,
				isFieldLevel
			);
		});
	
		// If we have a value, add the requisite attributes to the table row, set the attribute dropdown
		// to the selected attribute ID and run the change handler.
		if (val) {
			let valDefId = val["requestTypeCustAttribDefId"];
			let valDef = mapCustAttrIdToVendorAttr(attrDefsList, valDefId, isFieldLevel);
			if (valDef) {
				tableRow.attr("requestTypeCustAttribDefId", valDefId);
				attrDropdown.val(valDef["vendorAttributeId"]);
				attrDropdownChangeEvt(
					attrDropdown,
					valDef["vendorAttributeId"],
					tableRow,
					attrDescTd,
					attrDataTypeTd,
					valEntryTd,
					isFieldLevel,
					val
				);
			}
		} else {
			// If we don't have a value, then add the delete button to the table.
			deleteBtnTd.append(
				$("<button>")
					.addClass("editorSectionTableRowDeleteButton")
					.text("Delete")
			);
		}

		// Append everything to where they need to go.
		attrDropdownTd.append(attrDropdown);
		tableRow.append(
			attrDropdownTd,
			attrDescTd,
			attrDataTypeTd,
			valEntryTd,
			deleteBtnTd,
		);		
		$(`#${tableId}`).append(tableRow);
		updateAttrDropdowns(tableId);
	}

	/**
	 * Helper function to make a Select object based on all applicable attribute definitions.
	 * @param {boolean} isFieldLevel Is this a field level definition?
	 */
	let makeAttrDropdown = function(isFieldLevel) {
		let selectObj = $("<select>")
							.append(
								$("<option>")
									.text("Select an attribute")
									.attr("disabled", true)
									.attr("selected", true)
									.attr("emptyAttr", true)
								);
		let attrList = custAttrDefList.filter(attr => attr.isFieldLevel == isFieldLevel);

		attrList.forEach(attr => {
			selectObj.append(makeAttrOption(attr));
		});

		return selectObj;
	}

	/**
	 * Helper function to make an attribute option based on the attr.
	 * @param {JSON} attr The attribute definition.
	 */
	let makeAttrOption = function(attr) {
		return $("<option>")
				.text(attr["displayLabel"])
				.val(attr["vendorAttributeId"])
				.addClass("vendorAttrDropDownOption")
				.attr("title", attr["displayDescription"]);
	}

	/**
	 * Helper function to trigger DOM events whenever an attribute is selected.
	 * @param {DOM} attrDropdown The dropdown that was changed.
	 * @param {number} vendorId The vendor's attribute ID.
	 * @param {DOM} tableRow The table row.
	 * @param {DOM} descriptionTd The description TD.
	 * @param {DOM} dataTypeTd The data type TD.
	 * @param {DOM} valTd The value TD.
	 * @param {boolean} isFieldLevel Is this a field definition?
	 * @param {JSON} val The value, if it exists.
	 */
	let attrDropdownChangeEvt = function(attrDropdown, vendorId, tableRow, descriptionTd, dataTypeTd, valTd, isFieldLevel, val) {
		let attr = custAttrDefList.find(a => a.isFieldLevel == isFieldLevel && a.vendorAttributeId == vendorId);
		if (attr) {

			// If we have an attribute, start filling out the tableRow with attribute information.
			tableRow.attr("datatype", attr["displayDataType"]);
			tableRow.attr("vendorid", vendorId);

			// Add the description and data type text for the user's benefit.
			descriptionTd.text(attr["displayDescription"]);
			dataTypeTd.text(CUST_ATTR_DATA_TYPE_LABELS[attr["displayDataType"]]);

			// Make the value input and put it in the valTd.
			let valInput = makeAttrValInput(attr, val);
			valTd.html(valInput);

			// If we have a value, then add the value Id to the tableRow and disable the inputs to lock this in place.
			if (val) {
				tableRow.attr("id", val["id"]);
				attrDropdown.attr("disabled", true);
				valInput.attr("disabled", true);
			}

			// Now update all of the other dropdowns to make sure no other dropdowns in this table can select this attribute.
			updateAttrDropdowns($(tableRow).parent().parent().attr("id"));
		}
	}

	/**
	 * Helper function to make a value input for an attribute row.
	 * @param {JSON} attr The attribute definition.
	 * @param {JSON} val The value for this input, if there is one.
	 */
	let makeAttrValInput = function(attr, val) {
		let input = $("<input>");
		let inputVal = attr["displayDefaultValue"];

		// Figure out which data type we're working with, then adjust the inputVal object
		// accordingly and select the appropriate value from the val object if we have one.
		if (attr["displayDataType"] == CUST_ATTR_DATA_TYPES.STRING) {
			input.attr("type", "text");

			if (val) {
				inputVal = val["textValue"];
			}

			input.val(inputVal);
		} else if (attr["displayDataType"] == CUST_ATTR_DATA_TYPES.NUMERIC) {
			input.attr("type", "number");

			if (val) {
				inputVal = val["decimalValue"];
			}

			input.val(inputVal);
		} else if (attr["displayDataType"] == CUST_ATTR_DATA_TYPES.DATE) {
			input.attr("type", "text");

			if (val) {
				inputVal = val["dateValue"];
			}

			// Instantiate a date picker.
			let pikadaySettingsObject = {
				firstDay: 1,
				minDate: new Date(1990, 0, 1),
				maxDate: new Date(2040, 12, 31),
				yearRange: [1990, 2040],
				format: 'MM/DD/YYYY',
				defaultDate:  new Date(),
				setDefaultDate: true
			}
			input.pikaday(pikadaySettingsObject);
			input.val(inputVal);
		} else if (attr["displayDataType"] == CUST_ATTR_DATA_TYPES.LONG_TEXT) {
			input = $("<textarea>");

			if (val) {
				inputVal = val["longTextValue"];
			}

			input.val(inputVal);
		} else if (attr["displayDataType"] == CUST_ATTR_DATA_TYPES.BOOLEAN) { 
			input.attr("type", "checkbox");

			if (val) {
				inputVal = val["boolValue"];
			}

			input.attr("checked", utilities().stringToBool(inputVal));
		} else if (attr["displayDataType"] == CUST_ATTR_DATA_TYPES.DROP_DOWN) {
			input = makeAttrValDropdown(attr["requestTypeCustomAttributeDropDownOptionDefinitionList"]);

			if (val) {
				// We have to map the dropdown option ID to figure out the optionKey for the value.
				let requestTypeCustAttribDropdownOptDefId = val["requestTypeCustAttribDropdownOptDefId"];
				let selectedOption = attr.requestTypeCustomAttributeDropDownOptionDefinitionList.find(optionDef => optionDef.id == requestTypeCustAttribDropdownOptDefId);
				if (selectedOption) {
					inputVal = selectedOption["optionKey"];
				}
			}

			input.val(inputVal);
		}

		return input;
	}

	/**
	 * Create a list of attribute dropdowns based on the given list of definitions.
	 * @param {JSON[]} attrDropDownOptionDefinitionList A list of attribute dropdown definitions.
	 */
	let makeAttrValDropdown = function(attrDropDownOptionDefinitionList) {
		// Create a select object with a default disabled option.
		let selectObj = $("<select>").append(
							$("<option>")
								.text("Select a value")
								.attr("disabled", true)
								.attr("selected", true)
						);
		
		// Iterate through the definition list and create an option for each one, appended to selectObj.
		attrDropDownOptionDefinitionList.forEach(function(def) {
			selectObj.append(
				$("<option>")
					.val(def["optionKey"])
					.text(def["optionValue"])
			);
		});
		return selectObj;
	}

	/**
	 * Helper function to read an attribute table into a list of attribute values.
	 * @param {DOM} row The row object to parse.
	 * @param {string} parentIdLabel The label for the parent ID link. 
	 * @param {string} parentId The parent ID of this val object.
	 */
	let getCustAttrValList = function(tableId, parentIdLabel, parentId) {
		let valList = [];
		let tableRowList = $(`#${tableId} > tbody`).children().toArray();

		tableRowList.forEach(function(row) {
			let val = getCustAttrVal(row, parentIdLabel, parentId);
			if (val) {
				valList.push(val);
			}
		});

		return valList;
	}

	/**
	 * Helper function to read an attribute row into an attribute value.
	 * @param {DOM} row The row object to parse.
	 * @param {string} parentIdLabel The label for the parent ID link. 
	 * @param {string} parentId The parent ID of this val object.
	 */
	let getCustAttrVal = function(row, parentIdLabel, parentId) {
		let vendorId = $(row).attr("vendorId");

		// If we don't have a vendor ID, nothing was selected so skip this row.
		if (!vendorId) {
			return null;
		}

		let valObj = {
			vendorAttributeId: vendorId,
		};
		let valId = $(row).attr("id");
		let dataType = $(row).attr("datatype");
		let valDefId = $(row).attr("requestTypeCustAttribDefId")

		let val;
		let valueLabel;

		// Figure out what input type we want to parse out and determine which label to use.
		if (dataType == CUST_ATTR_DATA_TYPES.STRING) {
			val = $(row).find(".attrVal > input").val();
			valueLabel = "textValue";
		} else if (dataType == CUST_ATTR_DATA_TYPES.NUMERIC) {
			val = $(row).find(".attrVal > input").val();
			valueLabel = "decimalValue";
		} else if (dataType == CUST_ATTR_DATA_TYPES.DATE) {
			val = $(row).find(".attrVal > input").val();
			valueLabel = "dateValue";
		} else if (dataType == CUST_ATTR_DATA_TYPES.LONG_TEXT) {
			val = $(row).find(".attrVal > textarea").val();
			valueLabel = "longTextValue";
		} else if (dataType == CUST_ATTR_DATA_TYPES.BOOLEAN) {
			val = $(row).find(".attrVal > input").attr("checked");			
			valueLabel = "boolValue";
		} else if (dataType == CUST_ATTR_DATA_TYPES.DROP_DOWN) {
			val = $(row).find(".attrVal > select").val();
			valueLabel = "dropDownValue";
		}

		// Start populating the valObj with the stuff we can populate with.
		valObj[valueLabel] = val;

		if (valId) {
			valObj["id"] = valId;
		}

		if (valDefId) {
			valObj["requestTypeCustAttribDefId"] = valDefId;
		}

		if (parentIdLabel && parentId) {
			valObj[parentIdLabel] = parentId;
		}

		return valObj;
	}

	/**
	 * Helper function to get a list of selected vendor attributes.
	 * @param {string} tableId The table's DOM ID.
	 */
	let getSelectedAttributeVendorIdList = function(tableId) {
		let dropdownList = $(`#${tableId} > tbody > tr > .attrDropdown > select`).toArray();
		return dropdownList.map(dropdown => $(dropdown).val()).filter(dropdown => dropdown);
	}

	/**
	 * Helper function to update all attribute dropdowns for the given tableId.
	 * @param {string} tableId The table's DOM ID.
	 */
	let updateAttrDropdowns = function(tableId) {
		// Reinstate all non-emptyAttr dropdowns.
		$(`#${tableId} .attrDropdown > select > option[emptyAttr!=true]`).attr("disabled", false);

		// Figure out what attributes are selected an disable all of the options that match those values to
		// prevent the user from selecting them again.
		let selectedAttrList = getSelectedAttributeVendorIdList(tableId);
		selectedAttrList.forEach(attr => {
			$(`#${tableId} .attrDropdown > select > option[value=${attr}]`).attr("disabled", true);
		});
	}

	/**
	 * Helper function to map a custom attribute definition ID to an attribute.
	 * @param {JSON[]} attrDefsList A list of attribute definitions.
	 * @param {number} requestTypeCustAttribDefId The attribute definition ID to find in attrDefsList.
	 * @param {boolean} isFieldLevel Is this a field level definition?
	 */
	let mapCustAttrIdToVendorAttr = function(attrDefsList, requestTypeCustAttribDefId, isFieldLevel) {
		return attrDefsList.find(attr => attr.id == requestTypeCustAttribDefId && attr.isFieldLevel == isFieldLevel);
	}

	return {
		populateUsersAndUserGroupsAllowedTables: populateUsersAndUserGroupsAllowedTables,
		documentReadyFunction: documentReadyFunction,
		populateRequestTypesTable:populateRequestTypesTable,
	};
}

var requestTypeModule = editRequestTypes();

$(document).ready(function(){
	requestTypeModule.documentReadyFunction();
});
