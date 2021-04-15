//For now, this is where functions that are used by more than one page go...

var auditTrailAuthors = [];
var requestItemTable;
var RowID = 1;
var requestsMap = {};
// Adding a global variable that flags whether or not the table should be redrawn when a new row is added.
var addingRow = false;

var preSelect;

var allReqItemTbls = [];
var drawTimeout = "";
var requestItemTableNames = [];

var genRichText;

var fieldsReady = false;

window.unsavedChangesNotificationOpen = false;
window.cdIdStructureData = {};
window.requestFieldsSectionPopulatedForDupRequest = false;

function setBrowserObject() {
	var matched, browser;
	//NOTE THIS IS NEEDED FOR THE PRIORITIZATION MODAL !!!!!!!DO NOT REMOVE!!!!!!!!!!
	// Use of jQuery.browser is frowned upon.
	// More details: http://api.jquery.com/jQuery.browser
	// jQuery.uaMatch maintained for back-compat
	jQuery.uaMatch = function (ua) {
		ua = ua.toLowerCase();

		var match = /(chrome)[ \/]([\w.]+)/.exec(ua) ||
			/(webkit)[ \/]([\w.]+)/.exec(ua) ||
			/(opera)(?:.*version|)[ \/]([\w.]+)/.exec(ua) ||
			/(msie) ([\w.]+)/.exec(ua) ||
			ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec(ua) ||
			[];

		return {
			browser: match[1] || "",
			version: match[2] || "0"
		};
	};
	matched = jQuery.uaMatch(navigator.userAgent);
	browser = {};
	if (matched.browser) {
		browser[matched.browser] = true;
		browser.version = matched.version;
	}
	// Chrome is Webkit, but Webkit is also Safari.
	if (browser.chrome) {
		browser.webkit = true;
	} else if (browser.webkit) {
		browser.safari = true;
	}
	jQuery.browser = browser;
}

$(document).ready(function () {

	if (window.self != window.top) {
		$('body').addClass('inIframe');
	}

	$.notifyDefaults({
		placement: {
			from: "bottom",
			align: "right"
		},
		animate: {
			enter: 'animated fadeInDown',
			exit: 'animated fadeOutUp'
		}
	});

	$('table#requestTypeAllowedUsersTable').on('scroll', function () {
		$("table#requestTypeAllowedUsersTable > *").width($("table#requestTypeAllowedUsersTable").width() + $("table#requestTypeAllowedUsersTable").scrollLeft());
	});
	$('table#requestTypeAllowedGroupsTable').on('scroll', function () {
		$("table#requestTypeAllowedGroupsTable > *").width($("table#requestTypeAllowedGroupsTable").width() + $("table#requestTypeAllowedGroupsTable").scrollLeft());
	});

	// Turn off debug messages in DataTables
	$.fn.dataTable.ext.errMode = 'none';

	$("body").on('click', '.structureImageContainer', function (event) {
		if (!$(".isCheckedOut")[0]) {
			utilities().showUnsavedChangesNotification();
		}
	});

	$('body').on('click', '.repeatThisRequestButton', function (event) {
		var requestId = $(this).closest('.requestEditorContainer').attr('requestid');
		window.location = '/arxlab/workflow/repeatRequest.asp?requestid=' + requestId;
	});

	$(document).on('click', '#requestNotificationsList', function (e) {
		e.stopPropagation();
	});

	$(window).resize(function () {
		utilities().resizeManageRequestsTable().then(function () {
			if (window.self != window.parent) {
				var heightToUse = Math.max($(".col-md-12").height(), $(".container-fluid").height());

				if (window.parent.$("#tocIframe").height() != heightToUse) {
					utilities().resizeCustExpIframe();
				}
			}
		});
		$("#dropdownsTable").width( $('div.col-sm-12').width());
	});

	$('body').on('keydown', '.dropdownEditorContainer.makeVisible input, .dropdownEditorContainer.makeVisible select:not(#requestTypeDropdown, #assignedUserGroupDropdown), .dropdownEditorContainer.makeVisible textarea', function (event) {
	
		var uniquID = "";
		if (event.target.attributes.uniqueIdentifyer == undefined){
			uniquID = makeid(10);
			event.target.attributes.uniqueIdentifyer = uniquID;
		}
		else{
			uniquID = event.target.attributes.uniqueIdentifyer;
		}

		if (window.top.originalObj == undefined)
		{
			window.top.originalObj = {};
		}
		if (window.top.changeObj == undefined)
		{
			window.top.changeObj = {};
		}
		
		if (window.top.originalObj[uniquID] == undefined){
			window.top.originalObj[uniquID] = event.target.value;
		}
	    window.top.changeObj[uniquID] = event.target.value;
		//console.warn(event);

	});

	$('body').on('keyup', '.dropdownEditorContainer.makeVisible input, .dropdownEditorContainer.makeVisible select:not(#requestTypeDropdown, #assignedUserGroupDropdown), .dropdownEditorContainer.makeVisible textarea', function (event) {
		
		var uniquID = event.target.attributes.uniqueIdentifyer;
		
	    if(window.top.originalObj[uniquID] != event.target.value){
			utilities().showUnsavedChangesNotification();
		}
		else{
			window.top.changeObj[uniquID] = "";
			var change = false;
			$.each(window.top.changeObj, function(k, val){
				if (val != ""){
					change = true;
				}
			});
			if (change == false){
				utilities().closeUnsavedChangesNotification();
			}
		}
		//console.warn(event);

	});

	function makeid(length) {
		var result           = '';
		var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
		var charactersLength = characters.length;
		for ( var i = 0; i < length; i++ ) {
		   result += characters.charAt(Math.floor(Math.random() * charactersLength));
		}
		return result;
	 }

	$('body').on('change', '.dropdownEditorContainer.makeVisible input, .dropdownEditorContainer.makeVisible select:not(#requestTypeDropdown, #assignedUserGroupDropdown), .dropdownEditorContainer.makeVisible textarea', function (event) {
		if ($(this).closest('.editorField').attr('datatypeid') == "7") {
			var thisValueMoment = moment.utc($(this).val(), "MM/DD/YYYY");
			if (thisValueMoment.isValid()) {
				if (window.self != window.top) {
					var thisElementClasses = $(this).attr("class");
					if (thisElementClasses === undefined) {
						utilities().showUnsavedChangesNotification($(this));
					} else {
						if (thisElementClasses.split(/\s+/).indexOf("avoidTriggeringChangeListener") < 0) {
							utilities().showUnsavedChangesNotification($(this));
						}
					}
				}
				else {
					utilities().showUnsavedChangesNotification($(this));
				}
			}
			else {
				$(this).val("");
			}
		}
		else {
			if (window.self != window.top) {
				var thisElementClasses = $(this).attr("class");
				if (thisElementClasses === undefined) {
					utilities().showUnsavedChangesNotification($(this));
				} else {
					if (thisElementClasses.split(/\s+/).indexOf("avoidTriggeringChangeListener") < 0) {
						utilities().showUnsavedChangesNotification($(this));
					}
				}
			}
			else {
				// if we are looking at changing the number of rows on a dataTable, don't show unsaved changes		
				if (!$(this).closest('div').hasClass("dataTables_length")) {
					utilities().showUnsavedChangesNotification($(this));
				}				
			}
		}

		if (window.self != window.top) {
			var editorFieldHolder = $(this).parent().parent();
			var datatypeid = parseInt(editorFieldHolder.attr("datatypeid"));
			var requestTypeFieldId = editorFieldHolder.attr("requesttypefieldid");

			// if we don't have the data we need, stop
			if (isNaN(datatypeid) || typeof requestTypeFieldId == "undefined")
				return;

			// These lists store data types to make the if else block below easier to manage.
			var inputIds = [1, 2, 3, 4, 7];
			var selectIds = [5, 11, 12];
			var ckeditorIds = [9];

			var val = "";

			// Check if the editorFieldHolder has more than 2 children. If it does, then we're
			// in the case where there are multiple values.
			if (editorFieldHolder.children().length > 2) {

				// Initialize some variables and figure out what datatype we're working with and
				// set the childClass accordingly.
				var valArray = [];
				var childClass = "editorField";
				if (inputIds.indexOf(datatypeid) >= 0) {
					childClass = childClass + "Input";
				} else if (selectIds.indexOf(datatypeid) >= 0) {
					childClass = childClass + "Dropdown";
				}

				// Build the selectorString and use it to get a jquery iterable list of child elements.
				var selectorString = `.editorField[requesttypefieldid=${requestTypeFieldId}] > .editorFieldInputContainer > .${childClass}`;
				var children = $(selectorString)

				// For each child that matches the selectorString, add the val of the child element to
				// valArray.
				$.each(children, function (childIndex, child) {
					var childVal = $(child).val();
					if (childVal) {
						valArray.push($(child).val());
					}
				});

				// val, thus, is just everything in valArray joined with 3 pipes.
				val = valArray.join("|||");
			} else {
				// This is the case where this editor object is the only one in the parent.
				val = $(this).val();
			}

			if (window.top.canWrite) {
				window.parent.sendAutoSave(requestTypeFieldId, val);
			}
		}
	});

	$('body').on('click', '.dropdownEditorSubmit, .dropdownEditorCancel, .requestEditorSubmit, .requestEditorCancel', function (event) {
		utilities().closeUnsavedChangesNotification();
		// look to see if we are individual request page
		if (window.location.pathname == "/arxlab/workflow/viewIndividualRequest.asp") {
			try {
				// try to use this fnc to reload the section
				viewIndividualRequest(requestId, 0);
			} catch {
				// but always have a backup and just reload the page
				window.location.href = window.location.href;
			}
		}
		
	});

	$('body').on('click', '.previewStructuresButton', function (event) {
		$(this).closest('tr').siblings('tr').removeClass('activeRow');
		requestId = parseInt($(this).closest('tr').addClass('activeRow').attr('requestid'));
		$('ul.requestItemStructurePreviewList').find('li.card').remove();
		$('div#prioritizeThisRequestTableModal').addClass('showRequestItemStructurePreviewList');
		$('ul.requestItemStructurePreviewList').addClass('loadingStructureImages');
		ajaxModule().loadRequestPreviewStructureImages(requestId);
	});

	var allowedLinkSelectors = [
		`[href="#"]`,
		`[href=""]`,
		`[href="javascript:void(0)"]`,
		".csvdownload",
		".editStructureLink",
		".cke_button",
		".currentFileLink",
		".navigateLink",
		".clearLink"
	];

	var allowedLinkSelectorString = allowedLinkSelectors.map(x => `:not(${x})`).join("");
	$('body').on('click', `a${allowedLinkSelectorString}`, function (event) {
		if (window.unsavedChangesNotificationOpen && $(this).attr('target') !== "_blank" && this.id != "configRequestNameAccord") {
			window.clickedHref = $(this).attr('href');
			event.stopPropagation();
			event.preventDefault();
			console.log("Prevented link from opening...");

			window.parent.swal({
				title: "Are you sure?",
				text: "You are about to navigate away from this page while you still have unsaved changes.",
				type: "warning",
				confirmButtonText: "Discard Changes",
				cancelButtonText: "Cancel",
				showCancelButton: true
			},
			function (isConfirm) {
				if (isConfirm) {
					window.location = window.clickedHref;
				}
			});
		}
	});

	$(".modal").on("shown.bs.modal", function (e) {
		if (window.self != window.parent) {
			$(".modal").css("top", utilities().calculateOffset());
		}
	});

	$('table#manageRequestsTable').on("mouseenter", "td", function () {
		$(this).attr('title', this.innerText);
	});
	var isConfigManager = utilities().userIsMemberOfGroupByName("Configuration Managers");
	if (!isConfigManager) {
		var user = window.usersList.filter(x => x.id == globalUserInfo.userId);
		if (user != undefined && user[0].roleid == 1) {
			//check for admin
			isConfigManager = true;
		}
	}
	
	var isDropDownManager = utilities().userIsMemberOfGroupByName("Business Administrators");
	if (isConfigManager || isDropDownManager) {
		$("#workflowAdminNavMenu").css("display", "block");
		if (isDropDownManager && !isConfigManager) {
			$(".workflowAdminFields").css("display", "none");
		}
	}
});

$(document).ready(function () {

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

	setBrowserObject();

	$("body").bind("paste", function (e) {
		//access the clipboard using the api
		//tbody 
		var pastedData = e.originalEvent.clipboardData.getData('text');
		var tar = e.target;
		try {
			var $Tpar = $(tar).parent().parent().parent().parent();
			if ($Tpar[0].localName == "tbody") {
				var table = $($Tpar).parent()[0]//.attr("id");
				//$(tableID)[0];
				var $td = $(e.target).closest('td');
				var $tr = $($td).closest('tr');
				var rowOn = $($tr).index();
				rowOn += 1;
				var msg = pastedData;
				var colCount = table.rows[rowOn].cells.length;
				var TypeKey = [];
				for (i = 1; i < colCount; i++) {

					//cell to mess with
					var cellInteract = table.rows[rowOn].cells[i];
					var UD = $(cellInteract).children().children()[0];
					var thisTableCellDiv = $(UD).closest('div');
					var thisTableCellDataTypeId = parseInt(thisTableCellDiv.attr('datatypeid'));

					TypeKey.push(thisTableCellDataTypeId);

				}




				var twoD = [];
				var data = [];
				var ExIn = pastedData.split(String.fromCharCode(9));
				if (ExIn.length > 1) {
					for (i = 0; i < ExIn.length; i++) {
						if (data.length == colCount - 1) {
							twoD.push(data);
							data = [];
							data.push("");
						}
						if (ExIn[i] == String.fromCharCode(10) || ExIn[i] == String.fromCharCode(13)) {
							data.push("");
						}
						else {
							data.push(ExIn[i]);
						}
					}
					if (data.length > 0) {
						twoD.push(data);
					}


					for (i = 0; i < colCount; i++)// cycle through col
					{
						if (TypeKey[i] == 5) // find dd
						{
							var cellInteract = table.rows[rowOn].cells[i + 1];
							var DDKey = $(cellInteract).children().children()[0];
							DDKey = $(DDKey).children();
							for (td = 0; td < twoD.length; td++)//cycle through TwoD row
							{
								for (c = 0; c < DDKey.length; c++) {
									if (twoD[td][i] != undefined) {
										if (twoD[td][i].toUpperCase().replace(" ", "").replace(String.fromCharCode(13), "").replace(String.fromCharCode(10), "") == $(DDKey[c]).html().toUpperCase().replace(" ", "")) {
											twoD[td][i] = $(DDKey[c]).attr("value");
										}
									}
								}
							}

						}
					}


					console.log("IN:" + pastedData);

					var msg = twoD[0].join();
					for (i = 1; i < twoD.length; i++) {
						var Holder = twoD[i].join();
						Holder = Holder.replace(String.fromCharCode(13), "")
						msg = msg + "," + String.fromCharCode(10) + "," + Holder;
					}


					$.ajax(
						{
							type: "POST",
							url: "cpRequest.asp",
							async: false,
							data: { "msg": "03" + msg }
						})
						.done(function (response) {
							dataTableModule().PasteRequest("04", rowOn, table)
						});


					e.preventDefault();


					console.log(pastedData);
				}

			}


		}
		catch (err) {

		}


	});

	setTimeout(function () {
		var tablesArray = $('.dataTables_scrollBody > .requestItemEditorTable');
		$.each(tablesArray, function () {
			$(this).DataTable().draw();
		})
	}, 4000);

	utilities().fetchNotificationCount();
	var notificationCountInterval = 60000; // Set this to a minute.
	utilities().pollNotificationCount(notificationCountInterval);
	$('#prioritizeThisRequestTable > tbody').sortable({ placeholder: "ui-state-highlight", helper: 'clone' })
	
	$('body').on('click', '#cancelPrioritizeNewRequestBtn', function (event) {
		$(".prioritizeNewRequestButton").attr("disabled", false);
	});
	
}); // document ready 

var allStructures = {};
