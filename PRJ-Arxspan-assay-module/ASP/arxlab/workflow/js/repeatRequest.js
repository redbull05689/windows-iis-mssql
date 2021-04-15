/**
 * Build the request editor with the given requestToDup, but mark it so that the editor knows its making a duplicate.
 * @param {JSON} requestToDup The request we're duplicating.
 * @param {JSON} thisRequestType The request type config data.
 * @param {Array} versionedRequestItems The request item config data
 * @param {Array} versionedFields The field config data
 */
function populateRequestEditorToDuplicateRequest(requestToDup, thisRequestType, versionedRequestItems, versionedFields) {
	var duplicationInterval = window.setInterval(function () {
		if (typeof window.changingRequestTypeDropdown !== "undefined" && window.changingRequestTypeDropdown)
			return false;

		window.clearInterval(duplicationInterval);
		console.log(requestToDup)
		console.log(thisRequestType)

		var assignedGroupId = requestToDup['assignedGroupId'];
		if (!assignedGroupId) {
			if (globalUserInfo.userGroups.length > 0) {
				assignedGroupId = globalUserInfo.userGroups[0];
			} else {
				swal("Error loading request", "There was an error loading the request you're trying to repeat. Please contact Arxspan Support.", "error");
				return false;
			}
		}

		var assignedUserGroupDropdownOption = $('select#assignedUserGroupDropdown').find('option[value="' + assignedGroupId.toString() + '"]:not(:disabled)');
		if (!assignedUserGroupDropdownOption) {
			swal("Error loading request", "There was an error loading the request you're trying to repeat. Please try refreshing the page or contact Arxspan Support.", "error")
			return false;
		}

		var requestEditorDuplicationInterval = window.setInterval(function () {
			var selectorString = ".editorSection[sectionid='requestFields']";
			if ($(selectorString).length == 0)
				return;

			window.clearInterval(requestEditorDuplicationInterval);
			var myDiv = $('<div/>');

			var fieldPromises = [];
			fieldPromises.push(requestEditorHelper.populateRequestFieldsSection(thisRequestType, selectorString, requestToDup, true, versionedFields, versionedRequestItems));
			fieldPromises.push(requestEditorHelper.populateRequestItemsEditorSectionInRequestEditor(requestToDup, thisRequestType, myDiv, versionedRequestItems, versionedFields))
			Promise.all(fieldPromises).then(async function (fieldValues) {
				var itemDiv = fieldValues[1];
				$('.requestEditorContainer .bottomButtons').before(itemDiv.children());

				await dataTableModule().convertSavedRequestDataForDT(requestToDup, thisRequestType, versionedRequestItems, versionedFields);
				requestEditorHelper.populateDraftVals(thisRequestType, versionedRequestItems, versionedFields);

				if (window.top.currApp == "ELN") {
					window.parent.$("#basicLoadingModal").modal("hide");
					window.parent.bindSaveShortcut();
				}
				$('#basicLoadingModal').modal('hide');
			});
		}, 100);
	}, 100);
	//    assignedUserGroupDropdownOption.prop('selected',true).parent().change();
}

/**
 * Initiates the request duplication function.
 * @param {number} requestId The request's ID.
 */
function initDuplicateRequest(requestId) {
	$('.dropdownEditorContainer').attr('requestid', requestId);
	return new Promise(function (resolve, reject) {
		$('#basicLoadingModal').modal('show');
		var inputParams = {
			getFieldData: true,
			getItemData: true,
			appName: "Workflow"
		}

		ajaxModule().getRequests(requestId, inputParams).then(function (response) {
			if (typeof response !== "undefined") {
				var request = response;
				ajaxModule().getVersionedConfigData(request.requestTypeId).then(function (f) {
					window.top.versionedFields = f[0]
					window.top.versionedRequestItems = f[1]
					window.top.thisRequestType = f[2][0];
					$('.duplicatingRequestNotice .duplicateRequestName').text(request['requestName']).attr('href', 'viewIndividualRequest.asp?requestid=' + request["id"]);

					console.error("About to run populateRequestEditorToDuplicateRequest")

					Promise.all(initNewRequestPromise).then(function () {

						var popReqPromises = [];
						popReqPromises.push(requestEditorHelper.finalizeRequestEditorInitialization())

						Promise.all(popReqPromises).then(function () {

							requestEditorHelper.populateUserGroupsList()
								.then(makeNewRequestModule().disableDisallowedAssignedUserGroups(window.top.thisRequestType));

							window.parent.$("#submitRow").show();
							populateRequestEditorToDuplicateRequest(request, window.top.thisRequestType, window.top.versionedRequestItems, window.top.versionedFields);
						});
					})
				})
			}

			resolve(true);
		}).then(function () {
			console.log("complete");
			$('#basicLoadingModal').modal('hide');
		});
	});
}

$(document).ready(function () {
	makeNewRequestModule().showRequestEditor().then(function () {
		initDuplicateRequest(window.duplicateRequestId);
	})
});
