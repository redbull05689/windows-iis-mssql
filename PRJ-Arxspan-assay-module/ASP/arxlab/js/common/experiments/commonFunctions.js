// Hack to get the paste handler to not come up when the registration ID sweet alert comes up.
var stopPasteHandler = false;

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

$( document ).ready(function() {
$("#showPDFLink").bind( "click", function(event) {

	event.preventDefault();
	var url = $(this).attr("href");
	var time = 800;
	if (revisionNumber === undefined) {
		checkForEmptyRequiredFields($("originalExperimentType").val(), null, true );
	}
	window.setTimeout(function(){document.location.href=url;}, time);

});
});

function checkForEmptyRequiredFields(experimentType, signingDiv, ToPDF){
	indicateRequiredFields(); // This is called in a setInterval, but it's important to run this here just in case it hasn't been called yet with all the elements on the page
	var errors = [];
	$('*').removeClass('emptyRequiredField');
	$('.requiredExperimentFieldNotice.fieldIsRequired').each(function(){
		var thisFieldName = $(this).attr('data-fieldname');
		var regexToRemoveNumberAtStart = /(\d+)/;
		var thisFieldName_generic = thisFieldName.replace(regexToRemoveNumberAtStart,"");
		if(thisFieldName == "e_cdxData"){
			hasChemdraw().then(function (isInstalled) {
				if (isInstalled) {
					if (cd_getData("mycdx","text/xml") == "") {
						errors.push(thisFieldName)
					}
				}
			});
		}
		else if(thisFieldName == "e_projectLinks"){
			if($('td#projectLinksTD > div[id*="projectList_"]:not([style*="display: none"])').length < 1){
				errors.push(thisFieldName)
			}
		}
		else{
			fieldValueElement = $('#' + thisFieldName).not('span');
			var fieldValue = "";
			if(fieldValueElement.is('input')){
				fieldValue = $(fieldValueElement).val(); 
			}
			else if(fieldValueElement.is('textarea')){
				fieldValue = $(fieldValueElement).val();
			}

			if(fieldValue.replace(/\s+/g, '') == ""){
				errors.push(thisFieldName)
			}
		}
	});

	if(errors.length !== 0 && canWrite){
		$('*').removeClass('emptyRequiredField');
		var errorMessage = "The following required fields are empty:\n"
		if (ToPDF == true)
		{
			localStorage.setItem("Sign",false);
			localStorage.setItem("curURL",window.location.href);
		}
		
		$.each(errors, function(errorNum, error){
			var myRegexp = /(.\d+_)/g;
			var prefix = myRegexp.exec(error);
			if(prefix !== null){
				$('#' + prefix[1] + 'tab.gridTabDiv').addClass('emptyRequiredField'); // Make tab red
				$('#formDiv .caseTable #' + error).parent().parent().addClass('emptyRequiredField'); // Make td holding the input red
			}
			else{
				if(error == "e_Molarity" || error == "e_pressure" || error == "e_temperature"){
					$('#rc_tab').addClass('emptyRequiredField'); // Make tab red
					$('input[name="' + error + '"]').parent().parent().addClass('emptyRequiredField')
				}
				else{
					$('span.requiredExperimentFieldNotice[data-fieldname="' + error + '"]').addClass('emptyRequiredField')
				}
			}
			
			var fieldNameToMatch = getRequiredFieldNameToMatch(error);
			if(typeof experimentTypeName !== "undefined" && typeof requiredFieldsJSON['expType'][experimentTypeName] != "undefined" && typeof requiredFieldsJSON['expType'][experimentTypeName]['requiredFields'][fieldNameToMatch] !== "undefined"){
				if(requiredFieldsJSON['expType'][experimentTypeName]['requiredFields'][fieldNameToMatch] != "")
					error = requiredFieldsJSON['expType'][experimentTypeName]['requiredFields'][fieldNameToMatch];
			}

			errorMessage += "\n" + error
		});
		
		swal("", errorMessage, "");
		return false;
	}
	else{
		if (revisionNumber !== undefined) {
			return;
		}
		if(experimentType == 5) {
			if (ToPDF) {
				handleCustExpSaving(true, true);
			} else {
				handleCustExpSaving(true);
			}
		} else {
			if (signingDiv !== null) {
				showPopup(signingDiv);
			}
		}
	}
}

function custConfirmPdf(href, expId, expType) {
	makePdf = true;
	if (unsavedChanges) {
		unsavedChanges=false;
		makePdf = confirm('This experiment currently has unsaved changes.  Unsaved changes will not be shown in the PDF.');
		if (!makePdf) {
			unsavedChanges = true;
		}
	}
	if (revisionNumber === undefined) {
		if (makePdf){
			$.ajax({
				url: "/arxlab/experiments/ajax/do/discardChanges.asp?experimentId=" + expId + "&experimentType=" + expType,
				type: "GET"
			}).done(function() {
				checkForEmptyRequiredFields(5, "signingDiv", true);
			});
		}
	} else {
		window.parent.location = href;
	}
	
}

function getRequiredFieldNameToMatch(fieldName)
{
	fieldNameToMatch = fieldName;
	fieldNameNoPrefix = fieldName.replace(/(.\d+_)/g,"")
	var myRegexp = /(([A-z]+)\d+_)/g;
	var prefix = myRegexp.exec(fieldName);
	if(prefix != null)
		fieldNameToMatch = prefix[2] + "1_" + fieldNameNoPrefix;
	
	return fieldNameToMatch;
}

function indicateRequiredFields(){
	if(!$.isEmptyObject(requiredFieldsJSON)){
		$('.requiredExperimentFieldNotice').each(function(){
			var fieldName = $(this).attr('data-fieldname');
			fieldNameToMatch = getRequiredFieldNameToMatch(fieldName);
			if(typeof experimentTypeName !== "undefined" && typeof requiredFieldsJSON['expType'][experimentTypeName] != "undefined" && typeof requiredFieldsJSON['expType'][experimentTypeName]['requiredFields'][fieldNameToMatch] !== "undefined"){
				$('.requiredExperimentFieldNotice[data-fieldname="' + fieldName + '"]').addClass('fieldIsRequired')
			}
		});
	}
}


function initializeLinking(){
	showPopup("linkingPopup");
	$('#lean_overlay').hide(); // Not using the usual lean_overlay mask - hide it
	$('#overlay_select2Compatible').addClass('makeVisible');
	elnSearchBox = $('#searchForExperiment').select2({
		formatSearching: null,
		createSearchChoice: function (term, data) {
			// $('input[type="text"].elnSearchInput').val(term).attr("secretvalue",term);
	    },
	    selectOnBlur: false,
	    minimumInputLength: 3,
	    formatResult: function(object, container, query){
		    var contentHTML = "";
		    if(object['id'] == "specialResult_searchFor"){
		    	// Ignore this - it's meant as a way to make a full search link at the top of the typeahead results
	    	}
	    	else{
		    	contentHTML += '<div class="resultContent">'
		    	resultNameHTML = object['name']
		    	if(object['userExperimentName'] && object['userExperimentName'] !== "" && object['userExperimentName'] !== null){
		    		resultNameHTML += " - " + object['userExperimentName'];
		    	}
    			contentHTML += '<div class="resultNameRow"><div class="resultExperimentName">' + resultNameHTML + '</div><div class="resultNotebookName"><div class="notebookNameLabel">NB</div><div class="notebookNameValue">' + object['notebookName'] + '</div></div></div>';
    			contentHTML += '<div class="resultDetailsRow">' + object['details'] + '</div>';
		    	contentHTML += '</div>'
	    	}
	    	return contentHTML
	    },
	    ajax: {
	    	url: "/arxlab/ajax_loaders/fetchElnSearchTypeahead.asp",
	    	dataType: 'html',
	    	delay: 250,
	    	method: "POST",
	    	type: "POST",
	    	contentType: "application/x-www-form-urlencoded",
	    	data: function (params) {
	    		return {
    		        userInputValue: encodeIt(params),
		      	};
	    	},
	    	results: function (data, params) {
	    		// parse the results into the format expected by Select2
	    		var i = 0;
	    		resultsArray = JSON.parse(data)
	    		while(i < resultsArray.length){
	    			resultsArray[i]['id'] = resultsArray[i]['experimentId'];
	    			resultsArray[i]['text'] = resultsArray[i]['name'];
	    			i++
	    		}
	    		return {
	    			results: resultsArray
	    		};
	    	},
	    	cache: false
	    },
	    dropdownCssClass : 'elnSearchTypeaheadDropdown experimentSearchTypeaheadDropdown',
	    formatInputTooShort: function () {
            return "Please enter at least 3 characters";
        },
        openOnEnter: false,
        placeholder: ""
	}).data('select2');

	// This is a hacky way to make the links in the results of the typeahead clickable. Select2 stops the click event when you click a link in the dropdown by default...
	elnSearchBox.onSelect = (function(fn) {
		return function(data, options) {
			window.linkedExperimentInfo = data;
			$('#searchForExperiment').select2('data', {id: data['text'], text: decodeDoubleByteString(data['text'])}).trigger('change');
	    	$('#searchForExperiment').select2('close');
	    }
	})(elnSearchBox.onSelect);

	initProjectLinkDD("#searchForProject");

	registrationSearchBox = $('input#searchRegistration').select2({
		formatSearching: null,
		createSearchChoice: function (term, data) {
			// $('input[type="text"].elnSearchInput').val(term).attr("secretvalue",term);
	    },
		text: function (item) { return item.regId },
		selectOnBlur: false,
		ajax: {
			url: "/arxlab/ajax_loaders/fetchRegistrationSearchTypeahead.asp",
			dataType: 'html',
			quietMillis: 600,
			method: "POST",
			type: "POST",
			contentType: "application/x-www-form-urlencoded",
			data: function (params) {
				return {
			    	userInputValue: params,
			    	r: Math.random()
			  	};
			},
			results: function (data, params) {
				// parse the results into the format expected by Select2
				var i = 0;
				resultsArray = JSON.parse(data).results
				while(i < resultsArray.length){
					resultsArray[i]['id'] = resultsArray[i]['regId']
					i++
				}
				return {
					results: resultsArray
				};
			},
			cache: false,
			timeout: 1500
		},
		escapeMarkup: function (markup) { return markup; },
		minimumInputLength: 1,
		formatResult: function(object, container, query){
			headingHTML = '<div class="resultHeading">'
			contentHTML = '<div class="resultContent">'
			$.each(object,function(columnName, value){
				if(columnName !== "id" && columnName !== "cd_id"){
					headingHTML += '<div class="colHeader">' + columnName + '</div>';
					contentHTML += '<div class="colContent">' + value + '</div>';
				}
			})
			headingHTML += '</div>'
			contentHTML += '</div>'
			return headingHTML + contentHTML
		},
		formatSelection: function (item) {
			window.linkedRegIdInfo = item;
			return item.regId
		},
		formatSearching: null,
		initSelection : function (element, callback) {
			var data = {id: element.val(), regId: element.val()};
	        callback(data);
	    },
	    openOnEnter: false,
	    dropdownCssClass : 'elnRegIdLookupDropdown'
	});
}

function newExperimentLink(){
	if(typeof window.linkedExperimentInfo == "undefined"){
		window.linkedExperimentInfo = {};
		return;
	}
	
	revisionNumber = getUrlParameter('revisionId');

	if (typeof revisionNumber == 'undefined') {
		revisionNumber = getUrlParameter('revisionNumber')
	}

	var linkedRegistrationId = window.linkedRegIdInfo['regId'].split(",");

	if ($("#linkToType").val() == "registration" && $("#regIdColCheckbox").is(":checked")) {
		bulkLinkRegistrationIds(linkedRegistrationId, window.linkedRegIdInfo["id"].split(","), 0, linkedRegistrationId.length - 1, []);
	} else {
		$.ajax({
			url: '/arxlab/experiments/ajax/do/experimentLink_add.asp',
			type: 'POST',
			dataType: 'html',
			data: {thisExperimentId: window.experimentId, thisExperimentType: window.experimentType, thisRevisionNumber: revisionNumber, linkedExperimentId: window.linkedExperimentInfo['experimentId'], linkedExperimentType: window.linkedExperimentInfo['experimentType'], linkedProjectId: $('#searchForProject').val(), linkedRegistrationId: window.linkedRegIdInfo['cd_id'], linkToType: $('.linkingPopupContent #linkToType').val(), linkAs: $('.linkingPopupContent #linkAs').val(), linkComment: $('.linkingPopupContent #linkComment').val(), biDirectionalLink: $('#biDirectionalCheckbox').prop('checked')},
		})
		.done(function(response) {
			if(response == "Success"){
				loadExperimentLinks($('.linkingPopupContent #linkToType').val());
				// Reset the popup's values
				$('#linkingPopup select#linkToType option:first-of-type').prop('selected',true).change();
				$('#linkingPopup #searchForExperiment, #linkingPopup #searchForProject, #linkingPopup #searchRegistration').select2('val','');
				$('#linkingPopup select#linkAs option:first-of-type').prop('selected',true).change();
				$('#linkingPopup textarea#linkComment').val('');
				$('#lean_overlay').click(); // Close the popup
			}
			else{
				alertTitle = "Error Linking " + $('.linkingPopupContent #linkToType option:selected').text();
				swal(alertTitle, response, "error");
			}
		})
		.fail(function() {
			console.log("error");
		});
	}
}

function bulkLinkRegistrationIds(idList, idNameList, numProcessed, totalNumberOfLinks, linkErrors) {
	idToReg = idList.pop();
	idName = idNameList.pop();

	$.ajax({
		url: '/arxlab/experiments/ajax/do/experimentLink_add.asp',
		type: 'POST',
		dataType: 'html',
		data: {thisExperimentId: window.experimentId, thisExperimentType: window.experimentType, thisRevisionNumber: revisionNumber, linkedExperimentId: window.linkedExperimentInfo['experimentId'], linkedExperimentType: window.linkedExperimentInfo['experimentType'], linkedProjectId: $('#searchForProject').val(), linkedRegistrationId: idToReg, linkToType: $('.linkingPopupContent #linkToType').val(), linkAs: $('.linkingPopupContent #linkAs').val(), linkComment: $('.linkingPopupContent #linkComment').val(), biDirectionalLink: $('#biDirectionalCheckbox').prop('checked')},
	})
	.done(function(response) {
		if(response == "Success"){
			if (idList.length == 0) {
				loadExperimentLinks($('.linkingPopupContent #linkToType').val());
				// Reset the popup's values
				$('#linkingPopup select#linkToType option:first-of-type').prop('selected',true).change();
				$('#linkingPopup #searchForExperiment, #linkingPopup #searchForProject, #linkingPopup #searchRegistration').select2('val','');
				$('#linkingPopup select#linkAs option:first-of-type').prop('selected',true).change();
				$('#linkingPopup textarea#linkComment').val('');
				$('#lean_overlay').click(); // Close the popup
			}
		} else {
			linkErrors.push(idName);
		}
	})
	.always(function() {
		if (idList.length > 0) {
			if ($("#bulkRegProgressBar").css("display") == "none") {
				showPopup("bulkRegProgressBar");
			}
			moveProgressBar(numProcessed, totalNumberOfLinks);
			bulkLinkRegistrationIds(idList, idNameList, numProcessed+1, totalNumberOfLinks, linkErrors);
		} else {
			$("#bulkRegProgressBar").hide();
			if (linkErrors.length > 0) {
				var warningTitle = "Error: Duplicate ID";
				var warningText = "Could not link ";
				if (linkErrors.length > 1) {
					warningTitle += "s";
					warningText += linkErrors.length + " IDs.";
				} else {
					warningText += " ID.";
				}

				warningText += "\n" + linkErrors.join(", ");

				swal({
						title: warningTitle,
						text: warningText,
						type: 'warning',
					},
					function () {
						hidePopup("linkingPopup");
					}
				);
			}
			$("#searchRegistration").val("");
			window.linkedRegIdInfo = {};
		}
	})
	.fail(function() {
		console.log("error");
	});
}

function bulkSearchRegIds(inputIds, foundIds, foundCDIDs) {
	$.ajax({
		url: "/arxlab/ajax_loaders/batchFetchRegistrationSearch.asp",
		method: "POST",
		type: "POST",
		contentType: "application/x-www-form-urlencoded",
		data: {
			userInputValue: inputIds.join(","),
			r: Math.random()
		}
	}).success(function(response) {
		resp = JSON.parse(response);
		results = resp["results"];
		$.each(results, function(index, result) {
			foundIds.push(result["regId"]);
			foundCDIDs.push(result["cd_id"]);
		});

		idsNotFound = inputIds.filter(function(val) {
			return foundIds.indexOf(val) < 0;
		});

		$("#searchRegistration").val(foundIds.join(","));
		window.linkedRegIdInfo["id"] = foundIds.join(",");						
		window.linkedRegIdInfo["regId"] = foundCDIDs.join(",");

		if (idsNotFound.length > 0) {
			var warningTitle = "Could not find ID";
			if (idsNotFound.length > 1) {
				warningTitle += "s";
			}
			swal(warningTitle, idsNotFound.join(", "), "warning");
		} else {
			swal.close();
		}
	});
}

function moveProgressBar(numProcessed, numTotal) {
	var elem = document.getElementById("bulkRegBar"); 
	var width = Math.round((numProcessed / numTotal)  * 100);
	elem.innerHTML = width + '%';
	elem.style.width = width + '%'; 
}

function toggleRegLinkTable() {
	if ($("#regLinksTD").css("display") == "none") {
		$("#regLinksTD").css("display", "table-cell");
		$("#toggleRegLinkImg").prop("src", "images/triangle_down_1x.png")
	} else {
		$("#regLinksTD").css("display", "none");
		$("#toggleRegLinkImg").prop("src", "images/triangle_right_1x.png")
	}
}

function deleteExperimentProjectLink(projectId){
	$.ajax({
		url: 'projects/project-remove-experiment.asp',
		type: 'GET',
		dataType: 'html',
		data: {experimentId: experimentId, experimentType: experimentType, projectId: projectId, fromExperiment: 1, random: Math.random()},
	})
	.done(function(response) {
		loadExperimentLinks('project');
	});
}

/**
 * Startup function to load all types of experiment links.
 */
function loadAllExperimentLinks() {
	loadExperimentLinks("experiment");
	loadExperimentLinks("project");
	loadExperimentLinks("registration");
	loadExperimentLinks("request");
}

/**
 * Fetches the list of experiment links specified by experimentLinkSection.
 * @param {string} experimentLinkSection The type of experiment link to load.
 */
function loadExperimentLinks(experimentLinkSection){
	// Open experiments have revisionId in experimentJSON... Experiments that aren't open don't have experimentJSON but do have revisionId set
	revisionNumber = getUrlParameter('revisionId');

	if (typeof revisionNumber == 'undefined') {
		revisionNumber = getUrlParameter('revisionNumber')
	}
	
	if( typeof experimentId == "undefined" || typeof experimentType == "undefined" ){
		setTimeout(function(){
			loadExperimentLinks(experimentLinkSection);
		},200);
		return false;
	}

	if (experimentLinkSection == "request") {
		// Request links come from the link service, so fetch from there.		
		// Type Codes:
		// 1 - Request
		// 2 - Reg
		// 3 - Project
		// 4 - Notebook
		// 5 - Experiment
		// 6 - Inventory
		// 7 - Assay
		// 8 - Request Field Value
		// 9 - Request Item Field Value
		var promArray = [
			fetchLinkDataFromLinkSvc(experimentId, experimentType, 8), 
			fetchLinkDataFromLinkSvc(experimentId, experimentType, 9)
		]
		Promise.all(promArray).then(function(response) {
			decodeProms = [];
			allResponseData = [];
			response.forEach(function(item) {
				var jsonResp = JSON.parse(item);
				if (jsonResp.result != "success") {
					return;
				}
				var jsonData = JSON.parse(jsonResp.data);
				if (jsonData.length > 0) {
					allResponseData = allResponseData.concat(jsonData);
					// Before we can build the table, we need request names, so fetch those once we have the requests.
					decodeProms.push(fetchReqNames(jsonData));
				}
			});
			Promise.all(decodeProms).then(function(decodedLinks) {
				totalDecodedLinks = [];
				decodedLinks.forEach(function(links) {
					totalDecodedLinks = totalDecodedLinks.concat(links);
				});
				createReqLinksTable(allResponseData, totalDecodedLinks);
			});
		})
	} else {
		// Fetch the link data, then pass the results to the appropriate function for handling.
		fetchLinkData(experimentLinkSection).then(function(response) {
			
			if(experimentLinkSection == "experiment" || experimentLinkSection == null) {
				createExperimentLinksTable(response);
			} else if(experimentLinkSection == "project") {
				createProjectLinksTable(response);
			} else if(experimentLinkSection == "registration") {
				createRegLinksTable(response);
			}			
		});	
	}
}

/**
 * Make a POST call to getExperimentLinks2.asp to fetch this experiment's links.
 * @param {string} experimentLinkSection The type of experiment link to load.
 */
function fetchLinkData(experimentLinkSection) {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: 'experiments/ajax/load/getExperimentLinks2.asp',
			type: 'POST',
			dataType: 'json',
			data: {
				experimentId: experimentId,
				experimentType: experimentType,
				revisionId: revisionNumber,
				experimentStatusId: experimentStatusId,
				experimentLinkSection: experimentLinkSection,
				random: Math.random()
			},
		}).done(function(response) {
			resolve(response);
		});
	});
}

/**
 * Fetches the links from the link svc where this experiment is the origin.
 * @param {number} experimentId The current experiment's legacy Id.
 * @param {number} experimentType The current experiment's type Id.
 * @param {number} childTypeIdCd The type cd of the children to fetch.
 */
function fetchLinkDataFromLinkSvc(experimentId, experimentType, childTypeIdCd) {
	return new Promise(function(resolve, reject) {
		getAllExperimentId(experimentId, experimentType).then(function(allExpId) {

			// parentTypeId 5 in the link svc URL means "get all links for object ID ${allExpId}, which is of type 5. Type Id Code 5 is the Experiment type code."
			$.ajax({
				url: "/arxlab/workflow/invp.asp",
				data: {
					url: "/links/parentTypeId/5/parentId/" + allExpId + "?childTypeId=" + childTypeIdCd + "&depth=1&appName=ELN",
					verb: "GET",
					serialUUID: uuidv4(),
					config: true,
					linkService: true
				},
				type: "POST"
			}).done(function(response) {
				resolve(response);
			});
		});
	});
}

/**
 * Takes an experiment's legacy Id and type Id and fetches the allExperiments ID from an ajax call.
 * @param {number} experimentId The current experiment's legacy Id.
 * @param {number} experimentType The current experiment's type Id.
 */
function getAllExperimentId(experimentId, experimentType) {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "/arxlab/ajax_checkers/getAllExperimentId.asp?id=" + experimentId + "&expType=" + experimentType,
			verb: "GET",
		}).done(function(response) {
			resolve(response);
		})
	});
}

/**
 * Construct this experiment's experiment links table.
 * @param {Array} response This experiment's experiment links.
 */
function createExperimentLinksTable(response) {

	window.linksJSON_experiments = response;

	// Build the table object.
	var experimentLinkSectionTable = $("<table>")
		.addClass("experimentLinksTable")
		.attr("experimentlinksection", "experimentLinks");
	
	// Build the header row.
	var experimentLinkSectionTableHeadRow = $("<tr>")
		.append($("<th>").text("Experiment Name"))
		.append($("<th>").text("Experiment Description"))
		.append($("<th>").text("Linked As"))
		.append($("<th>").text("Owner"))
		.append($("<th>").text("Link Comment"))
		.append($("<th>").text("Delete"));

	// Now create the header and body.
	var experimentLinkSectionTableHead = $("<thead>").append(experimentLinkSectionTableHeadRow);	
	var experimentLinkSectionTableBody = $("<tbody>");

	// If we don't have any experiments, put in the default row.
	if (window.linksJSON_experiments.length == 0) {
		var emptyRow = $("<tr>")
			.append($("<td>")
				.attr("colspan", 6)
				.addClass("emptyLinksTable")
				.text("This experiment has no Experiment Links.")
			);
		experimentLinkSectionTableBody.append(emptyRow);
	}

	// Otherwise, iterate through all of the experiment links and build link rows.
	$.each(window.linksJSON_experiments, function(i, experimentLink) {
		experimentLinkSectionTableBody.append(createExperimentLinkRow(experimentLink, i));
	});

	// Finalize the table, then add it to the DOM.
	experimentLinkSectionTable
		.append(experimentLinkSectionTableHead)
		.append(experimentLinkSectionTableBody);

	$('#linksTD table.experimentLinksTable').remove();
	$('#linksTD').append(experimentLinkSectionTable);
	
	if($.isEmptyObject(window.linksJSON_experiments) || window.linksJSON_experiments.length == 0){
		$('#showExperimentLinkMapButton').removeClass('makeVisible');
	}
	else{
		$('#showExperimentLinkMapButton').addClass('makeVisible');
	}
}

/**
 * Builds an experiment link row.
 * @param {*} experimentLink The experiment link object.
 * @param {string} index The experiment type index, meant to determine what experiment page to link to.
 */
function createExperimentLinkRow(experimentLink, index) {

	// Build the link cell.
	var experimentLinkPage = "{type}experiment.asp?id={id}";
	var experimentLinkType = "";

	if (experimentLink["linkExperimentType"] == 2) {
		experimentLinkType = "bio-";
	} else if (experimentLink["linkExperimentType"] == 3) {
		experimentLinkType = "free-";
	} else if (experimentLink["linkExperimentType"] == 4) {
		experimentLinkType = "anal-";
	} else if (experimentLink["linkExperimentType"] == 5) {
		experimentLinkType = "cust-";
	}

	experimentLinkPage = experimentLinkPage
		.replace("{type}", experimentLinkType)
		.replace("{id}", experimentLink['linkExperimentId']);

	var experimentLinkCell = createLinkLinkCell(experimentLinkPage, experimentLink["name"]);
	
	// Now the description cell.
	var experimentDescriptionCell = $("<td>").html(experimentLink["details"]);

	// Now the linked-as cell.
	var linkedAsText = "Reference";
	if (experimentLink["prev"]) {
		linkedAsText = "Prev Step";
	} else if (experimentLink["next"]) {
		linkedAsText = "Next Step";
	}

	var linkedAsCell = $("<td>")
		.addClass("whiteSpaceNoWrapCell")
		.text(linkedAsText);

	// Now the owner cell.
	var ownerCell = $("<td>")
		.addClass("whiteSpaceNoWrapCell")
		.text(experimentLink["firstName"] + " " + experimentLink["lastName"])

	// Finish with the comment and delete cells.
	var commentCell = createLinkCommentCell(experimentLink["comments"]);
	var deleteCell = createLinkDeleteCell(experimentLink['canDeleteExperimentLink'] == true && typeof revisionNumber == "undefined");

	// Put it all together and return the <tr>
	return $("<tr>")
		.attr("experimentid", experimentLink["linkExperimentId"])
		.attr("experimenttype", experimentLink["linkExperimentType"])
		.attr("linkindex", index)
		.append(experimentLinkCell)
		.append(experimentDescriptionCell)
		.append(linkedAsCell)
		.append(ownerCell)
		.append(commentCell)
		.append(deleteCell);
}

/**
 * Construct this experiment's project links table.
 * @param {Array} response This experiment's project links.
 */
function createProjectLinksTable(response) {
	window.linksJSON_projects = response;
				
	var projectLinksSectionTable = $("<table>")
		.attr("experimentlinksection", "projectLinks")
		.addClass("experimentLinksTable");
	
	var projectLinksSectionTableHeadRow = $("<tr>")
		.append($("<th>").text("Project Name"))
		.append($("<th>").text("Project Description"))
		.append($("<th>").text("Link Comment"))
		.append($("<th>").text("Delete"));

	var projectLinksSectionTableHead = $("<thead>").append(projectLinksSectionTableHeadRow);
	var projectLinksSectionTableBody = $("<tbody>");
	
	if (window.linksJSON_projects.length == 0) {
		var emptyRow = $("<tr>")
			.append($("<td>")
				.attr("colspan", 4)
				.addClass("emptyLinksTable")
				.text("This experiment has no Project Links.")
			);
			projectLinksSectionTableBody.append(emptyRow);
	}

	$.each(window.linksJSON_projects, function(index, projectLink) {
		projectLinksSectionTableBody.append(createProjectLinksRow(projectLink, index));
	});

	projectLinksSectionTable
		.append(projectLinksSectionTableHead)
		.append(projectLinksSectionTableBody);

	$('#projectLinksTD table.experimentLinksTable').remove();
	$('#projectLinksTD').append(projectLinksSectionTable);
}

/**
 * Builds a project link row.
 * @param {*} projectLink The project link object.
 * @param {string} index The link index.
 */
function createProjectLinksRow(projectLink, index) {

	var projectUrl = "show-project.asp?id=" + projectLink["projectId"];
	var linkCell = createLinkLinkCell(projectUrl, projectLink["projectName"]);
	
	var descriptionCell = $("<td>").html(projectLink["projectDescription"]);

	var commentCell = $("<td>");
	if (!projectLink["viaNotebook"]) {
		commentCell = createLinkCommentCell(projectLink["linkComment"]);
	} else {
		commentCell.text("Linked via Notebook");
	}

	var deleteCell = createLinkDeleteCell(projectLink['canDeleteExperimentLink'] == true && typeof revisionNumber == "undefined" && !projectLink['viaNotebook']);

	return $("<tr>")
		.attr("projectid", projectLink["projectId"])
		.attr("linkindex", index)
		.append(linkCell)
		.append(descriptionCell)
		.append(commentCell)
		.append(deleteCell);
}

/**
 * Construct this experiment's reg links table.
 * @param {Array} response This experiment's reg links.
 */
function createRegLinksTable(response) {

	window.linksJSON_registration = response;
				
	var regLinksSectionTable = $("<table>")
		.attr("experimentlinksection", "registrationLinks")
		.addClass("experimentLinksTable");
	
	var regLinksSectionTableHeadRow = $("<tr>")
		.append($("<th>").text("Reg Number"))
		.append($("<th>").text("Link Comment"))
		.append($("<th>").text("Delete"));

	var regLinksSectionTableHead = $("<thead>").append(regLinksSectionTableHeadRow);
	var regLinksSectionTableBody = $("<tbody>");
	
	if (window.linksJSON_registration.length == 0) {
		var emptyRow = $("<tr>")
			.append($("<td>")
				.attr("colspan", 3)
				.addClass("emptyLinksTable")
				.text("This experiment has no Registration Links.")
			);
			regLinksSectionTableBody.append(emptyRow);
	}

	$.each(window.linksJSON_registration, function(index, regLink){
		regLinksSectionTableBody.append(createRegLinksRow(regLink, index));
	});

	regLinksSectionTable
		.append(regLinksSectionTableHead)
		.append(regLinksSectionTableBody);

	$('#regLinksTD table.experimentLinksTable').remove();
	$('#regLinksTD').append(regLinksSectionTable);
}

/**
 * Builds a reg link row.
 * @param {*} regLink The reg link object.
 * @param {string} index The link index.
 */
function createRegLinksRow(regLink, index) {
	var linkCell = createLinkLinkCell(regLink["regLinkUrl"], regLink["displayRegNumber"]);	
	var commentCell = createLinkCommentCell(regLink["linkComment"]);
	var deleteCell = createLinkDeleteCell(regLink['canDeleteExperimentLink'] == true && typeof revisionNumber == "undefined");
	
	return $("<tr>")
		.attr("regnumber", regLink["regNumber"])
		.attr("linkindex", index)
		.append(linkCell)
		.append(commentCell)
		.append(deleteCell);
}

/**
 * Fetches the request names for each of the request links.
 * @param {Array} response An array of request links.
 */
function fetchReqNames(response) {
	return new Promise(function(resolve, reject) {
		var requestNames = [];
	
		if (response.length > 0) {			
		
			var idList = response.map(function(x) { return x.targetId });
			// For each of these we are going to fetch the request info.
			var decodeObj = {
				objectTypeCd: response[0].targetIdTypeCd,
				objectIdList: JSON.stringify(idList),
			}

			$.ajax({
				url: window.location.origin + "/arxlab/entityDecode/decode.asp",
				data:  decodeObj,
				type: "POST",
				dataType: 'json',
			}).then(function(requestNamesResponse) {
				resolve(requestNamesResponse);
			});

		} else {
			resolve(requestNames);
		}
	})
}

/**
 * Construct this experiment's request links table.
 * @param {Array} response This experiment's request links from link svc.
 * @param {Array} decodedLinks The decoded request links.
 */
function createReqLinksTable(response, decodedLinks) {

	window.linksJSON_request = response;
				
	var reqLinksSectionTable = $("<table>")
		.attr("experimentlinksection", "requestLinks")
		.addClass("experimentLinksTable");
	
	var reqLinksSectionTableHeadRow = $("<tr>")
		.append($("<th>").text("Request"))
		.append($("<th>").text("Link Comment"))
		.append($("<th>").text("Delete"));

	var reqLinksSectionTableHead = $("<thead>").append(reqLinksSectionTableHeadRow);
	var reqLinksSectionTableBody = $("<tbody>");
	
	if (window.linksJSON_request.length == 0) {
		var emptyRow = $("<tr>")
			.append($("<td>")
				.attr("colspan", 3)
				.addClass("emptyLinksTable")
				.text("This experiment has no Request Links.")
			);
			reqLinksSectionTableBody.append(emptyRow);
	}

	$.each(window.linksJSON_request, function(index, reqLink){
		var reqName = "NONAME";
		var targetId = 0;

		// Find the field we care about by matching the PK of the field and ensuring we're
		// using the correct type code.
		var thisRequestField = decodedLinks.find(function(request) {
			return request["objectId"] == reqLink["targetId"] && request["typeCd"] == reqLink["targetIdTypeCd"];
		});

		if (thisRequestField) {
			reqName = thisRequestField["linkName"];
			targetId = thisRequestField["linkId"];
		}
		
		reqLinksSectionTableBody.append(createReqLinksRow(reqLink, index, reqName, targetId));
	});

	reqLinksSectionTable
		.append(reqLinksSectionTableHead)
		.append(reqLinksSectionTableBody);

	$('#reqLinksTD table.experimentLinksTable').remove();
	$('#reqLinksTD').append(reqLinksSectionTable);
}

/**
 * Builds a request link row.
 * @param {*} reqLink The request link object.
 * @param {string} index The link index.
 * @param {string} reqName The name of the request.
 * @param {JSON} targetId The ID of the request we're linking to.
 */
function createReqLinksRow(reqLink, index, reqName, targetId) {
	// Default this row to the "could not find request" row.
	var linkCell = $("<td>").text("Request not found.");
	var commentCell = createLinkCommentCell("");
	var deleteCell = createLinkDeleteCell(false);

	// If we do have a name and ID though, we're good.
	if (reqName != "NONAME" && targetId != 0) {
		linkCell = createLinkLinkCell("/arxlab/workflow/viewIndividualRequest.asp?requestId=" + targetId, reqName);
		commentCell = createLinkCommentCell(reqLink["description"]);
		deleteCell = createLinkDeleteCell(canDeleteExperimentLinks && typeof revisionNumber == "undefined");
	}
	
	return $("<tr>")
		.attr("linkid", reqLink["id"])
		.attr("linkindex", index)
		.append(linkCell)
		.append(commentCell)
		.append(deleteCell);
}

/**
 * Creates a link cell for a link row.
 * @param {string} href The link this link cell should point to.
 * @param {string} displayText The display text of the link.
 */
function createLinkLinkCell(href, displayText) {
	return $("<td>")
		.append(
			$("<a>")
				.attr("href", href)
				.html(displayText)
		);
}

/**
 * Creates a comment cell.
 * @param {string} comment The comment attached to this link.
 */
function createLinkCommentCell(comment) {
	var commentCell = $("<td>");

	if (comment) {
		commentCell.html(comment);
	} else {
		commentCell.append($("<div>").addClass("emptyCellIndicator"));
	}

	return commentCell;
}

/**
 * Creates a delete row cell.
 * @param {boolean} canDelete Can this user delete this link?
 */
function createLinkDeleteCell(canDelete) {
	var deleteCell = $("<td>")
		.addClass("deleteLinkCell");
	
	if(canDelete) {
		deleteCell.append($("<div>").addClass("deleteLinkButton"));
	}

	return deleteCell;
}

/**
 * Helper function to decode encoded link node names.
 * @param {JSON[]} linkNodesList The list of link nodes for cytoscape.
 */
function decodeLinkNodes(linkNodesList) {
	$.each(linkNodesList["nodes"], function(i, node) {
		if (Object.keys(node).includes("data")) {
			node["data"]["name"] = decodeDoubleByteString(node["data"]["name"]);
		}
	});
	return linkNodesList;
}

function initExperimentLinkNodeMap(cytoscapeElementId){
    $('.nodeMapInfoBox').empty();
    $.ajax({
      url: '/arxlab/apis/eln/elnApiCall.asp',
      type: 'POST',
      dataType: 'json',
      data: {
        verb: "POST",
        url: "/getExperimentLinksVisual/",
        data: JSON.stringify({"experimentType":window.experimentType,"experimentId":window.experimentId,"revisionId":""})
      },
    })
    .done(function(response) {
	
      window.getExperimentLinksVisualResponse = decodeLinkNodes(response);
      window.cytoscope_experimentLinksNodeMap = cytoscape({
        container: document.getElementById(cytoscapeElementId),
        
        layout: {
          name: 'concentric',
          padding: 8,
          animate: true,
          animationEasing: "linear",
          animationDuration: 850,
          directed: false,
          spacingFactor: .9,
          maximalAdjustments: 0,
          componentSpacing: 10
        },
        userPanningEnabled: true,
        boxSelectionEnabled: false,
        style: cytoscape.stylesheet()
          .selector('node')
            .css({
              'shape': 'data(faveShape)',
              'width': 'data(width)',
              'content': 'data(name)',
              'text-valign': 'center',
              'text-outline-width': 2,
              'text-outline-color': 'data(faveColor)',
              'background-color': 'data(faveColor)',
              'color': '#fff'
            })
          .selector(':selected')
            .css({
              'border-width': 3,
              'border-color': '#333'
            })
          .selector('edge')
            .css({
              'curve-style': 'bezier',
              'opacity': 0.666,
              'width': 'mapData(strength, 70, 100, 2, 6)',
              'target-arrow-shape': 'triangle',
              'source-arrow-shape': 'circle',
              'line-color': 'data(faveColor)',
              'source-arrow-color': 'data(faveColor)',
              'target-arrow-color': 'data(faveColor)'
            })
          .selector('edge.biDirectional')
            .css({
              'line-style': 'dotted',
              'target-arrow-shape': 'circle',
              'line-color': 'red'
            })
          .selector('.faded')
            .css({
              'opacity': 0.25,
              'text-opacity': 0
            }),
        
        elements: {
          nodes: response['nodes'],
          edges: response['edges']
        },
        
        ready: function(){
          window.experimentLinkCy = this;
          console.log(response)
          // giddy up
        },
        minZoom: 0.5,
        maxZoom: 2
      });

      window.cytoscope_experimentLinksNodeMap.nodes().on("click", function(e){
        var nodeId = e.target.id();
        var nodeType_Id_array = nodeId.split('_');
        var nodeExperimentType = parseInt(nodeType_Id_array[0]);
        var nodeExperimentId = parseInt(nodeType_Id_array[1]);
        getExperimentMetaDataForNodeMap(nodeExperimentType, nodeExperimentId);
      });
    })
    .fail(function() {
      swal("Error Loading Link Map",null,"error");
    });
}

function getExperimentMetaDataForNodeMap(nodeExperimentType, nodeExperimentId){
  $.ajax({
    url: '/arxlab/apis/eln/elnApiCall.asp',
    type: 'POST',
    dataType: 'json',
    data: {
      verb: "POST",
      url: "/getExperimentMetaData/",
      data: JSON.stringify({"experimentType":nodeExperimentType,"experimentId":nodeExperimentId,"revisionId":"","experimentLinkTypes":["project","registration"]})
    }
  })
  .done(function(result) {
    var nodeDataContainer = $('<div class="nodeDataContainer"></div>');
    
    // Basic Experiment Info section of the nodeDataContainer
    var experimentObject = result['experiment'];
    if(experimentObject){
      var nodeExperimentData = $('<div class="nodeExperimentData"></div>')

      if(experimentObject['experimentType'] == 1){
      	experimentPageLink = "experiment.asp?id=" + experimentObject['id'];
      }
      else if(experimentObject['experimentType'] == 2){
      	experimentPageLink = "bio-experiment.asp?id=" + experimentObject['id'];
      }
      else if(experimentObject['experimentType'] == 3){
      	experimentPageLink = "free-experiment.asp?id=" + experimentObject['id'];
      }
      else if(experimentObject['experimentType'] == 4){
      	experimentPageLink = "anal-experiment.asp?id=" + experimentObject['id'];
      }

      nodeExperimentData.append($('<div class="experimentData_name"><a href="'+ experimentPageLink +'">' + decodeDoubleByteString(experimentObject['name']) + '</a></div>'))
      nodeExperimentData.append($('<div class="experimentData_notebookLink"><a href="show-notebook.asp?id=' + experimentObject['notebookId'] + '">' + 'View Notebook' + '</a></div>'))
      nodeDataContainer.append(nodeExperimentData);
    }

    var nodeMetaDataContainer = $('<div class="nodeMetaDataContainer"></div>');
    
    // Registration Links section of the nodeDataContainer
    nodeData_regLinksContainer = $('<div class="nodeMetaData_registrationLinks"><div class="nodeMetaData_linksSectionTitle">Registration Links</div><div class="nodeMetaData_linksScrollContainer"></div></div>')
    if(typeof result['experimentLinks_registration'] !== 'undefined' && result['experimentLinks_registration'].length > 0){
      $.each(result['experimentLinks_registration'], function(){
        var displayRegNumber = this['displayRegNumber'];
        var regLinkUrl = this['regLinkUrl'];
        var regLinkComment = ""
        if(typeof this['linkComment'] !== "undefined"){
          regLinkComment = decodeDoubleByteString(this['linkComment']);
        }
        var regLinkElement = $('<div class="nodeMetaData_regLink"><a href="/arxlab/registration'+regLinkUrl+'" class="regLinkLink">'+displayRegNumber+'</a><div class="regLinkComment">'+regLinkComment+'</div></div>')
        nodeData_regLinksContainer.find('.nodeMetaData_linksScrollContainer').append(regLinkElement)
      });
    }
    else{
      nodeData_regLinksContainer.find('.nodeMetaData_linksScrollContainer').append($('<div class="noLinksNotice">No Registration Links</div>'))
    }
    nodeMetaDataContainer.append(nodeData_regLinksContainer)

    // Project Links section of the nodeDataContainer
    nodeData_projectLinksContainer = $('<div class="nodeMetaData_projectLinks"><div class="nodeMetaData_linksSectionTitle">Project Links</div><div class="nodeMetaData_linksScrollContainer"></div></div>')
    if(typeof result['experimentLinks_projects'] !== 'undefined' && result['experimentLinks_projects'].length > 0){
      $.each(result['experimentLinks_projects'], function(){
        var projectName = decodeDoubleByteString(this['projectName']);
        var projectId = this['projectId'];
        var projectLinkComment = ""
        if(typeof this['linkComment'] !== "undefined" && !!this['linkComment']){
          projectLinkComment = this['linkComment']
        }
        var projectLinkElement = $('<div class="nodeMetaData_projectLink"><a href="/arxlab/show-project.asp?id='+projectId+'" class="projectLinkLink">'+projectName+'</a><div class="projectLinkComment">'+projectLinkComment+'</div></div>')
        nodeData_projectLinksContainer.find('.nodeMetaData_linksScrollContainer').append(projectLinkElement)
      });
    }
    else{
      nodeData_projectLinksContainer.find('.nodeMetaData_linksScrollContainer').append($('<div class="noLinksNotice">No Project Links</div>'))
    }
    nodeMetaDataContainer.append(nodeData_projectLinksContainer)

    nodeDataContainer.append(nodeMetaDataContainer)
    $('.nodeMapInfoBox').html(nodeDataContainer)
  })
  .fail(function() {
    swal("Error Loading Link Map Node Data",null,"error");
  });
  
}

$(document).ready(function(){
	loadAllExperimentLinks(); // Get all types of links for this experiment
	checkSidebarHeight();

	// Add extra overlay whose z-index works with select2's drop mask
	$("body").append($("<div id='overlay_select2Compatible'></div>"));

	/*!!!!!!!!!!!! START Click Event Handlers !!!!!!!!!!!!*/

	$('body').on('change','#showExperimentSectionsInAttachmentsTable',function(event){
	    if(this.checked) {
	    	$('.attachmentsIndexTable').removeClass('hideExperimentSectionsInTable');
	    }
	    else{
	    	$('.attachmentsIndexTable').addClass('hideExperimentSectionsInTable');
		}
	});

	$('body').on('change','#linkToType',function(event){
		$('#linkingPopup').attr('linktotype',$(this).val()); // Make the popup display the right stuff for this "Link to" value
	});

	$('body').on('change','#linkAs',function(event){
		$('#linkingPopup').attr('linkas',$(this).val()); // Make the popup display the right stuff for this "Link as" value
	});

	$('body').on('click','.confirmLinkButton',function(event){
		newExperimentLink();
	});

	$('body').on('click','table[experimentlinksection="experimentLinks"] .deleteLinkCell .deleteLinkButton',function(event){
		var thisTableRow = $(this).parent().parent();
		swal({
		  title: 'Are you sure?',
		  text: 'This will remove the Experiment Link to "'+decodeDoubleByteString(window.linksJSON_experiments[thisTableRow.attr('linkindex')]['name'])+'".',
		  type: 'warning',
		  showCancelButton: true,
		  confirmButtonText: 'Remove Link'
		},
		function (isConfirm) {
		  if(isConfirm){
		  	deleteLink(thisTableRow.attr('experimenttype'), thisTableRow.attr('experimentid')); // Delete the experiment link - table will refresh
		  }
		})

	});

	$('body').on('click','table[experimentlinksection="projectLinks"] .deleteLinkCell .deleteLinkButton',function(event){
		var thisTableRow = $(this).parent().parent();
		deleteExperimentProjectLink(thisTableRow.attr('projectid')); // Delete the experiment link - table will refresh
	});

	$('body').on('click','table[experimentlinksection="registrationLinks"] .deleteLinkCell .deleteLinkButton',function(event){
		var thisTableRow = $(this).parent().parent();
		deleteRegLink(thisTableRow.attr('regnumber')); // Delete the experiment link - table will refresh
	});

	$('body').on('click','table[experimentlinksection="requestLinks"] .deleteLinkCell .deleteLinkButton',function(event){
		var thisTableRow = $(this).parent().parent();
		deleteRequestLink(thisTableRow.attr('linkid')); // Delete the experiment link - table will refresh
	});

	$('body').on('click','#lean_overlay, #overlay_select2Compatible',function(event){
		$('#searchForExperiment, #addCasName').select2('close'); // If select2 is opened/active when the popup closes, the typeahead stays visible - close it
	});

	$('body').on('click','#overlay_select2Compatible',function(event){
		try{hidePopup(currentPopup)}catch(err){}
	});

	$('body').on('click','a#showExperimentLinkMapButton',function(event){
		initExperimentLinkNodeMap('cytoscapeExperimentLinkNodeMap');
		showPopup('cytoscapeExperimentLinkNodeMapPopup');
	});

	$('body').on('click','div#closeExperimentLinkNodeMap',function(event){
		hidePopup('cytoscapeExperimentLinkNodeMapPopup');
	});

	$('body').on('click','#commentsLink',function(event){
		openComments();
	});

	$('body').on('change','#fileUploadNewCommentAttachmentsFormFileInput',function(event){
		$('#fileUploadNewCommentRemoveAttachmentButton').addClass('makeVisible');
	});

	$('body').on('click','#fileUploadNewCommentRemoveAttachmentButton',function(event){
		$('#fileUploadNewCommentAttachmentsForm input[type="file"]').val('');
		$(this).removeClass('makeVisible');
	});



	$('#commentsDiv').on('drop','.commentDiv:not(.makeDeleteButtonsVisible)',function(e){
		swal("Error","Sorry, you can only upload attachments to your most recently added comment.","error")
		e.preventDefault();
		return false;
	});

	$("#regIdColCheckbox").change(function() {
		$("#searchRegistration").val("");
		window.linkedRegIdInfo = {};
		$("#searchRegistration").on('keydown', function(e){
			e.preventDefault();
		})
		if ($("#regIdColCheckbox").is(":checked")) {
			$("#searchRegistration").select2("destroy");
			$("#searchRegistration").on("click", function(){
				stopPasteHandler = true;
				swal({
					title: "Enter Registration IDs",
					text: "Enter Registration IDs:",
					type: "input",
					showCancelButton: true,
					closeOnConfirm: false,
					closeOnCancel: true,
					inputPlaceholder: "Write something"
				},
				function(inputValue) {
					stopPasteHandler = false;
					if (!inputValue) {
						swal.close();
						return false;
					}

					inputValue = inputValue.replace(new RegExp(" ", "g"), ",").replace(new RegExp("\n", "g"), ",").replace(new RegExp(",+", "g"), ",");
					var inputIds = inputValue.toUpperCase().split(",");
					$.each(inputIds, function(index, id) {
						regex = /(.*-.*-.*)/
						if (regex.exec(id) == null) {
							inputIds[index] = id + "-00";
						}
					})
					var foundIds = [];
					var foundCDIDs = [];
					var idsNotFound = [];

					bulkSearchRegIds(inputIds, foundIds, foundCDIDs);

					/*
					var counter = 0;

					// This is a hack that searches every ID that's input into the bulk registration link by basically running each and every ID
					// through the typeahead search one-by-one to find matches. I could not find a simple ajax function that grabbed every reg ID
					// nor one that would run a whole list of reg IDs through the search, so until that exists, this will do.
					$.each(inputIds, function(index, id) {
						$.ajax({
							url: "/arxlab/ajax_loaders/fetchRegistrationSearchTypeahead.asp",
							method: "POST",
							type: "POST",
							contentType: "application/x-www-form-urlencoded",
							data: {
								userInputValue: id,
								r: Math.random()
							}
						}).success(function(response) {
							counter++;
							resp = JSON.parse(response);
							if (resp["results"].length > 0) {
								var respObj = resp["results"][0];
								var regId = respObj["regId"];
								var cdId = respObj["cd_id"];
	
								if (inputIds.indexOf(regId) >= 0) {
									foundIds.push(regId);
									foundCDIDs.push(cdId);
								}
							}
							if (inputIds.length == counter) {
								idsNotFound = inputIds.filter(function(val) {
									return foundIds.indexOf(val) < 0;
								});
			
								$("#searchRegistration").val(foundIds.join(","));
								window.linkedRegIdInfo["id"] = foundIds.join(",");						
								window.linkedRegIdInfo["regId"] = foundCDIDs.join(",");
			
								if (idsNotFound.length > 0) {
									var warningTitle = "Could not find ID";
									if (idsNotFound.length > 1) {
										warningTitle += "s";
									}
									swal(warningTitle, idsNotFound.join(", "),"warning");
								} else {
									swal.close();
								}
							}
						})					
					})
					*/
				});
			})
		} else {
			$("#searchRegistration").prop("onclick", null).off("click");
			registrationSearchBox = $('input#searchRegistration').select2({
				formatSearching: null,
				createSearchChoice: function (term, data) {
					// $('input[type="text"].elnSearchInput').val(term).attr("secretvalue",term);
				},
				text: function (item) { return item.regId },
				selectOnBlur: false,
				ajax: {
					url: "/arxlab/ajax_loaders/fetchRegistrationSearchTypeahead.asp",
					dataType: 'html',
					quietMillis: 600,
					method: "POST",
					type: "POST",
					contentType: "application/x-www-form-urlencoded",
					data: function (params) {
						return {
							userInputValue: params,
							r: Math.random()
						  };
					},
					results: function (data, params) {
						// parse the results into the format expected by Select2
						var i = 0;
						resultsArray = JSON.parse(data).results
						while(i < resultsArray.length){
							resultsArray[i]['id'] = resultsArray[i]['regId']
							i++
						}
						return {
							results: resultsArray
						};
					},
					cache: false,
					timeout: 1500
				},
				escapeMarkup: function (markup) { return markup; },
				minimumInputLength: 1,
				formatResult: function(object, container, query){
					headingHTML = '<div class="resultHeading">'
					contentHTML = '<div class="resultContent">'
					$.each(object,function(columnName, value){
						if(columnName !== "id" && columnName !== "cd_id"){
							headingHTML += '<div class="colHeader">' + columnName + '</div>';
							contentHTML += '<div class="colContent">' + value + '</div>';
						}
					})
					headingHTML += '</div>'
					contentHTML += '</div>'
					return headingHTML + contentHTML
				},
				formatSelection: function (item) {
					window.linkedRegIdInfo = item;
					return item.regId
				},
				formatSearching: null,
				initSelection : function (element, callback) {
					var data = {id: element.val(), regId: element.val()};
					callback(data);
				},
				openOnEnter: false,
				dropdownCssClass : 'elnRegIdLookupDropdown'
			});
		}
	})

	$(window).resize(checkSidebarHeight);

	/*!!!!!!!!!!!!! END Click Event Handlers !!!!!!!!!!!!!*/




	/*!!!!!!!!!!!! START setIntervals !!!!!!!!!!!!*/
	var repeatedlyIndicateRequiredFields = setInterval(function(){
		if(typeof requiredFieldsJSON !== "undefined"){
			indicateRequiredFields();
		}
	},5500);

	var repeatedlyPositionExperimentButtons = setInterval(function(){
		if(typeof positionButtons !== "undefined"){
			positionButtons();
		}
	},750);

	var repeatedlyCheckSidebarHeight = setInterval(checkSidebarHeight,1000);
	/*!!!!!!!!!!!!! END setIntervals !!!!!!!!!!!!!*/
});