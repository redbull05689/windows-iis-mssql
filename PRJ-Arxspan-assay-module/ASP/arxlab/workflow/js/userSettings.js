function generateNotificationPreferences_requestTypesTable(notificationSettings) {
	if (typeof window.requestTypesArray == "undefined") {
		setTimeout(generateNotificationPreferences_requestTypesTable.bind(null), 100);
		return false;
	}


	if (window.requestTypesArray.length > 0){
		window.requestTypesArray = window.requestTypesArray.filter(x => x.disabled == 0);
		window.requestTypesArray = utilities().sortArray(window.requestTypesArray, "displayName");
	}

	tableRowsArray = []
	$.each(window.requestTypesArray, function (requestTypeIndex, requestType) {
		var tableRow = $('<tr>').attr('requesttypeid', requestType['id']).attr('requesttypeindex', requestTypeIndex);
		tableRow.append($('<td>').append($('<div>').text(requestType['displayName'])))
		tableRow.append($('<td>').append($('<button>').text("Settings").addClass('btn btn-sm noMarginButton settingsButton').attr("requestTypeId", requestType.id)))

		// Notifications... First, the requestTypeFields
		notificationSettingsObject = { "fields": {}, "requestItemTypes": {} }
		$.each(requestType['fields'], function (requestTypeFieldIndex, requestTypeField) {
			if (typeof requestTypeField['notificationSettings_user'] !== "undefined") {
				requestTypeField['notificationSettings_user']['requestTypeFieldId'] = requestTypeField['requestTypeFieldId'].toString()
				notificationSettingsObject['fields'][requestTypeField['requestTypeFieldId']] = requestTypeField['notificationSettings_user'];
			}
		});
		// Now the requestItemTypeFields
		$.each(requestType['requestItemTypes'], function (requestItemTypeIndex, requestItemType) {
			notificationSettingsObject['requestItemTypes'][requestItemType['requestItemId']] = { "fields": {} }
		});

		// Now add reprioritization email settings
		notificationSettingsObject['reprioritizationNotificationUserSettings'] = requestType['requestTypeReprioritizationNotificationUserSettings']
		$.each(requestType['requestItemTypes'], function (requestItemTypeIndex, requestItemType) {
			notificationSettingsObject['requestItemTypes'][requestItemType['requestItemId']]['reprioritizationNotificationUserSettings'] = requestItemType['requestTypeItemReprioritizationNotificationUserSettings']
		});

		console.log(notificationSettingsObject)

		tableRow.attr('notificationsettings', JSON.stringify(notificationSettingsObject))

		tableRowsArray.push(tableRow)
	});
	$('table#notificationPreferences_requestTypesTable tbody').append(tableRowsArray);
}

function populateRequestTypeNotificationUserSettingsEditor(requestType, requestTypeNotificationUserSettings = false) {
	console.log(requestType)
	console.log(requestTypeNotificationUserSettings)

	$('#requestTypeNotificationUserSettings .requestTypeNameCardHeader').text(requestType['displayName']);

	var requestReprioritizationEmailToggle = $('<div class="reprioritizationEmailNotificationSettingHolder"><div class="requestTypeReprioritizationEmailOverrideToggle togglebutton switch-sidebar-image"><label>Reprioritization Emails<input type="checkbox" name="requestTypeReprioritizationEmailToggle"><span class="toggle"></span></label></div><div class="requestTypeReprioritizationEmailSetting checkbox"><label><input type="checkbox" name="requestTypeReprioritizationEmailCheckbox" class="emailCheckbox" disabled><span class="checkbox-material"><span class="check"></span></span></label></div></div>')

	// First build table for the fields of the requestType
	var fieldsTableElement = $('<table>').attr('id', 'requestTypeNotificationUserSettings_requestTypeFieldsTable').addClass('table');
	fieldsTableElement.html('<thead class="text-primary"><tr><th>Field Name</th><th>Override</th><th>Email</th><th>Browser</th></tr></thead><tbody></tbody>');
	tableRowsArray = [];
	$.each(requestType['fields'], function (requestTypeFieldIndex, requestTypeField) {
		var tableRow = $('<tr>').attr('requesttypefieldid', requestTypeField['requestTypeFieldId']);
		var nameTD = $('<td>').text(requestTypeField['displayName'])
		var overrideTD = $('<td>').html('<div class="togglebutton switch-sidebar-image"><label><input type="checkbox" name="overrideCheckbox_' + requestTypeFieldIndex + '"><span class="toggle"></span></label></div>');
		var emailTD = $('<td>').html('<div class="checkbox"><label><input type="checkbox" disabled name="emailCheckbox_' + requestTypeFieldIndex + '" class="emailCheckbox"><span class="checkbox-material"><span class="check"></span></span></label></div>');
		var browserTD = $('<td>').html('<div class="checkbox"><label><input type="checkbox" disabled name="browserCheckbox_' + requestTypeFieldIndex + '" class="browserCheckbox"><span class="checkbox-material"><span class="check"></span></span></label></div>');
		tableRow.append(nameTD, overrideTD, emailTD, browserTD);

		tableRowsArray.push(tableRow);
	});
	fieldsTableElement.find('tbody').append(tableRowsArray);
	$('#requestTypeNotificationUserSettings_requestTypeFieldsTableContainer').empty().append(requestReprioritizationEmailToggle, fieldsTableElement);

	// Now build table for the fields of the requestType's requestItemTypes
	requestItemTypeTablesArray = [];
	$.each(requestType['requestItemTypes'], function (requestType_requestItemTypeIndex, requestType_requestItemType) {
		$.each(window.requestItemTypesArray, function (requestItemTypeIndex, requestItemType) {
			if (requestItemType['id'] == requestType_requestItemType['requestItemTypeId']) {
				var requestItemTableHeader = $('<h4 class="card-title"></h4>').text("Item Type: " + requestType_requestItemType['requestItemName']);
				var requestItemReprioritizationEmailToggle = $('<div class="reprioritizationEmailNotificationSettingHolder"><div class="requestItemTypeReprioritizationEmailOverrideToggle togglebutton switch-sidebar-image"><label>Item Reprioritization Emails<input type="checkbox" name="reprioritizationEmail_' + requestType_requestItemType['requestItemId'] + '"><span class="toggle"></span></label></div><div class="requestItemTypeReprioritizationEmailSetting checkbox"><label><input type="checkbox" name="reprioritizationEmailCheckbox_' + requestType_requestItemType['requestItemId'] + '" class="emailCheckbox" disabled><span class="checkbox-material"><span class="check"></span></span></label></div></div>')

				var requestItemTableFieldsTableElement = $('<table>').addClass('table requestTypeNotificationUserSettings_requestItemTypeFieldsTable').attr('requestitemtypeid', requestType_requestItemType['requestItemId']);
				requestItemTableFieldsTableElement.html('<thead class="text-primary"><tr><th>Item Field Name</th><th>Override</th><th>Email</th><th>Browser</th></tr></thead><tbody></tbody>');
				tableRowsArray = []
				$.each(requestItemType['fields'], function (requestItemTypeFieldIndex, requestItemTypeField) {
					var tableRow = $('<tr>').attr('requesttypefieldid', requestItemTypeField['requestTypeFieldId'])
					var nameTD = $('<td>').text(requestItemTypeField['displayName'])
					var overrideTD = $('<td>').html('<div class="togglebutton switch-sidebar-image"><label><input type="checkbox" name="overrideCheckbox_' + requestItemTypeFieldIndex + '"><span class="toggle"></span></label></div>');
					var emailTD = $('<td>').html('<div class="checkbox"><label><input type="checkbox" disabled name="emailCheckbox_' + requestItemTypeFieldIndex + '" class="emailCheckbox"><span class="checkbox-material"><span class="check"></span></span></label></div>');
					var browserTD = $('<td>').html('<div class="checkbox"><label><input type="checkbox" disabled name="browserCheckbox_' + requestItemTypeFieldIndex + '" class="browserCheckbox"><span class="checkbox-material"><span class="check"></span></span></label></div>');
					tableRow.append(nameTD, overrideTD, emailTD, browserTD);

					tableRowsArray.push(tableRow);
				});
				requestItemTableFieldsTableElement.find('tbody').empty().append(tableRowsArray);
				requestItemTypeTablesArray.push(requestItemTableHeader, requestItemReprioritizationEmailToggle, requestItemTableFieldsTableElement)
			}
		});
	});
	$('.requestTypeNotificationUserSettings_requestItemTypeFieldsTableContainer').empty().append(requestItemTypeTablesArray);

	$('#requestTypeNotificationUserSettings').addClass('makeVisible').attr('requesttypeid', requestType['id']);
}

function submitRequestTypeNotificationUserSettings() {
	window.upsertRequestTypeNotificationUserOverrides = $.notify({
		title: "Updating your notification settings...",
		message: ""
	}, {
			delay: 0,
			type: "yellowNotification",
			template: '<div data-notify="container" class="col-xs-11 col-sm-3 alert alert-{0}" role="alert">' +
				'<button type="button" aria-hidden="true" class="close" data-notify="dismiss">x</button>' +
				'<span data-notify="icon"></span> ' +
				'<span data-notify="title">{1}</span> ' +
				'<span data-notify="message">{2}</span>' +
				'<div class="progress" data-notify="progressbar">' +
				'<div class="progress-bar progress-bar-{0}" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>' +
				'</div>' +
				'<a href="{3}" target="{4}" data-notify="url"></a>' +
				'</div>'
		});

	var userSettingsObject = {}
	var requestTypeId = $('#requestTypeNotificationUserSettings').attr('requesttypeid');

	userSettingsObject['fields'] = {}
	// Build up the request type fields object
	$.each($('table#requestTypeNotificationUserSettings_requestTypeFieldsTable tbody tr'), function (requestTypeFieldRowIndex, requestTypeFieldRow) {
		var requestTypeFieldId = $(requestTypeFieldRow).attr('requesttypefieldid');
		var overrideEnabled = $(requestTypeFieldRow).find('input[name="overrideCheckbox_' + requestTypeFieldRowIndex + '"]').prop('checked');
		var notifyByEmail = $(requestTypeFieldRow).find('input[name="emailCheckbox_' + requestTypeFieldRowIndex + '"]').prop('checked');
		var notifyByBrowser = $(requestTypeFieldRow).find('input[name="browserCheckbox_' + requestTypeFieldRowIndex + '"]').prop('checked');
		userSettingsObject['fields'][requestTypeFieldId] = {
			"requestTypeFieldId": requestTypeFieldId,
			"overrideEnabled": overrideEnabled,
			"notifyByEmail": notifyByEmail,
			"notifyByBrowser": notifyByBrowser
		}
	});

	userSettingsObject['reprioritizationNotificationUserSettings'] = {
		"overrideEnabled": $('input[name="requestTypeReprioritizationEmailToggle"]').prop('checked'),
		"notifyByEmail": $('input[name="requestTypeReprioritizationEmailCheckbox"]').prop('checked')
	}

	// Build up the request item type fields object(s)
	userSettingsObject['requestItemTypes'] = {}
	console.log($(this).find('table.requestTypeNotificationUserSettings_requestItemTypeFieldsTable'))
	$.each($('.requestTypeNotificationUserSettings_requestItemTypeFieldsTableContainer'), function () {
		var requestItemTypeFieldsTable = $(this).find('.requestTypeNotificationUserSettings_requestItemTypeFieldsTable');
		var requestItemTypeId = requestItemTypeFieldsTable.attr('requestitemtypeid')
		userSettingsObject['requestItemTypes'][requestItemTypeId] = { "fields": {} }
		$.each(requestItemTypeFieldsTable.find('tbody tr'), function (requestItemTypeFieldRowIndex, requestItemTypeFieldRow) {
			var requestTypeFieldId = $(requestItemTypeFieldRow).attr('requesttypefieldid');
			var overrideEnabled = $(requestItemTypeFieldRow).find('input[name="overrideCheckbox_' + requestItemTypeFieldRowIndex + '"]').prop('checked');
			var notifyByEmail = $(requestItemTypeFieldRow).find('input[name="emailCheckbox_' + requestItemTypeFieldRowIndex + '"]').prop('checked');
			var notifyByBrowser = $(requestItemTypeFieldRow).find('input[name="browserCheckbox_' + requestItemTypeFieldRowIndex + '"]').prop('checked');
			userSettingsObject['requestItemTypes'][requestItemTypeId]['fields'][requestTypeFieldId] = {
				"requestTypeFieldId": requestTypeFieldId,
				"requestItemTypeId": requestItemTypeId,
				"overrideEnabled": overrideEnabled,
				"notifyByEmail": notifyByEmail,
				"notifyByBrowser": notifyByBrowser
			}
		});

		userSettingsObject['requestItemTypes'][requestItemTypeId]['reprioritizationNotificationUserSettings'] = {
			"overrideEnabled": $(this).find('input[name="reprioritizationEmail_' + requestItemTypeId + '"]').prop('checked'),
			"notifyByEmail": $(this).find('input[name="reprioritizationEmailCheckbox_' + requestItemTypeId + '"]').prop('checked')
		}
	});

	$('table#notificationPreferences_requestTypesTable tbody tr[requesttypeid="' + requestTypeId + '"]').attr('notificationsettings', JSON.stringify(userSettingsObject))

	inputData = {};
	inputData['connectionId'] = connectionId;
	inputData['userNotificationSettings'] = userSettingsObject;
	inputData['requestTypeId'] = requestTypeId;

	console.log(inputData)
	//return false;

	$.ajax({
		url: 'invp.asp',
		type: 'POST',
		dataType: 'json',
		data: {
			//async: "async",
			verb: "POST",
			url: "/upsertRequestTypeFieldUserNotificationSettings/",
			data: JSON.stringify(inputData),
			r: Math.random()
		},
		async: true
	})
		.done(function (response) {
			console.log("success");
			window.upsertRequestTypeNotificationUserOverrides.update({ 'title': "Successfully updated your notification settings.", 'message': "", 'type': "success" })
		})
		.fail(function () {
			window.upsertRequestTypeNotificationUserOverrides.update({ 'title': "Failed to update your notification settings.", 'message': "", 'type': "danger" })
		})
		.always(function () {
			console.log("complete");
		});
}

function generateExcelImportSettingsTable() {

	return new Promise(function(resolve, reject) {

		var beforeRow = $('<tr>');
		var beforeLabel = $("<label></label>").text("Before Existing Rows").attr("for", "beforeLabel");
		var beforeButton = $("<input></input>").attr("name", "fileImportRadio").attr("type", "radio").attr("id", "beforeLabel");
		beforeButton.val("Before");
		beforeRow.append($('<td>').append(beforeButton).append(beforeLabel).css("display", "flex"));
	
		var afterRow = $('<tr>');
		var afterLabel = $("<label></label>").text("After Existing Rows").attr("for", "afterLabel");
		var afterButton = $("<input></input>").attr("name", "fileImportRadio").attr("type", "radio").attr("id", "afterLabel");
		afterButton.val("After");
		afterRow.append($('<td>').append(afterButton).append(afterLabel).css("display", "flex"));
	
		var deleteRow = $('<tr>');
		var deleteLabel = $("<label></label>").text("Delete Existing Rows").attr("for", "deleteLabel");
		var deleteButton = $("<input></input>").attr("name", "fileImportRadio").attr("type", "radio").attr("id", "deleteLabel");
		deleteButton.val("Delete")
		deleteRow.append($('<td>').append(deleteButton).append(deleteLabel).css("display", "flex"));
	
		var eraseRow = $('<tr>');
		var eraseLabel = $("<label></label>").text("Erase Current Setting").attr("for", "eraseLabel");
		var eraseButton = $("<input></input>").attr("name", "fileImportRadio").attr("type", "radio").attr("id", "eraseLabel");
		eraseButton.val("Erase");
		eraseRow.append($('<td>').append(eraseButton).append(eraseLabel).css("display", "flex"));
	
		var tableRowsArray = [beforeRow, afterRow, deleteRow, eraseRow];
	
		$('table#excelImportSettingsTable tbody').append(tableRowsArray);
	
		var submitButton = $("<button>").addClass("btn").addClass("file-upload-btn").addClass("btn-success").addClass("btn-sml").text("Submit");
		$("table#excelImportSettingsTable").append(submitButton);
	
		ajaxModule().fetchFileUploadSetting(companyId, globalUserInfo.userId).then(function(response) {
			var existingSetting = response;
			if (existingSetting) {
				var selectorString = "input[name='fileImportRadio'][value='{setting}']".replace("{setting}", existingSetting);
				$(selectorString).prop("checked", true);
			}
			
			resolve(true);
		})		
	})
}

$(document).ready(function () {
	utilities().showLoadingModal();

	var promiseChain = [];
	promiseChain.push(ajaxModule().processRequestTypesArray());
	promiseChain.push(ajaxModule().populateRequestItemTypesList());
	promiseChain.push(generateExcelImportSettingsTable());

	Promise.all(promiseChain).then(function () {
		generateNotificationPreferences_requestTypesTable();

		utilities().hideLoadingModal();

		$('body').on('click', 'table#notificationPreferences_requestTypesTable tbody tr button.settingsButton', function (event) {
			var requestTypeIndex = $(this).closest('tr').attr('requesttypeindex');
			requestTypeNotificationUserSettings = false;
			$(this).closest('tr').siblings().removeClass('activeRow');
			$(this).closest('tr').addClass('activeRow')
			if ($(this).closest('tr').attr('notificationsettings')) {
				requestTypeNotificationUserSettings = JSON.parse($(this).closest('tr').attr('notificationsettings'));
			}
			showUserSetting($(this).attr("requesttypeId"));
			//populateRequestTypeNotificationUserSettingsEditor(window.requestTypesArray[requestTypeIndex], requestTypeNotificationUserSettings);
		});

		$('body').on('click', '#requestTypeNotificationUserSettings .cancelChangesButton', function (event) {
			$('#requestTypeNotificationUserSettings').removeClass('makeVisible');
			$('table#notificationPreferences_requestTypesTable tbody tr').removeClass('activeRow');
		});

		$('body').on('click', '#requestTypeNotificationUserSettings .saveChangesButton', function (event) {
			$('#requestTypeNotificationUserSettings').removeClass('makeVisible');
			$('table#notificationPreferences_requestTypesTable tbody tr').removeClass('activeRow');
			submitRequestTypeNotificationUserSettings();
		});

		$('body').on('change', '#requestTypeNotificationUserSettings table#requestTypeNotificationUserSettings_requestTypeFieldsTable .togglebutton input[type="checkbox"], #requestTypeNotificationUserSettings table.requestTypeNotificationUserSettings_requestItemTypeFieldsTable .togglebutton input[type="checkbox"]', function () {
			console.log($(this).prop('checked'))
			console.log($(this).closest('tr').find('.emailCheckbox'))
			$(this).closest('tr').find('.emailCheckbox').prop('disabled', !$(this).prop('checked'))
			$(this).closest('tr').find('.browserCheckbox').prop('disabled', !$(this).prop('checked'))
		});

		$('body').on('change', '.reprioritizationEmailNotificationSettingHolder .togglebutton input[type="checkbox"]', function () {
			$(this).closest('.reprioritizationEmailNotificationSettingHolder').find('.emailCheckbox').prop('disabled', !$(this).prop('checked'));
		});

		$("button.file-upload-btn").on("click", function () {

			return new Promise(function(resolve, reject) {
				var selectVal = $("input[name=fileImportRadio]:checked").val();
				var selectMsg = "Currently set to: {setting}"

				if (selectVal == "Erase") {
					selectVal = null;
					selectMsg = "Setting deleted.";
				} else {
					selectMsg = selectMsg.replace("{setting}", selectVal);
				}
				resolve(ajaxModule().storeFileUploadSetting(companyId, globalUserInfo.userId, selectVal, selectMsg));
			}).then(function(selectMsg) {

				$.notify({
					title: "Successfully changed import setting.",
					message: selectMsg
				}, {
						delay: 4000,
						type: "success",
						template: '<div data-notify="container" class="col-xs-11 col-sm-3 alert alert-{0}" role="alert">' +
							'<button type="button" aria-hidden="true" class="close" data-notify="dismiss">x</button>' +
							'<span data-notify="icon"></span> ' +
							'<span data-notify="title">{1}</span> ' +
							'<span data-notify="message">{2}</span>' +
							'<div class="progress" data-notify="progressbar">' +
							'<div class="progress-bar progress-bar-{0}" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>' +
							'</div>' +
							'<a href="{3}" target="{4}" data-notify="url"></a>' +
							'</div>'
					});
			});

		});
	});
});