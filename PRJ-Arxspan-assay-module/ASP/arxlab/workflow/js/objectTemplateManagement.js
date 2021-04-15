//browser plugin that broke scrolling because it was missing
// Limit scope pollution from any deprecated API
(function() {

    var matched, browser;

// Use of jQuery.browser is frowned upon.
// More details: http://api.jquery.com/jQuery.browser
// jQuery.uaMatch maintained for back-compat
    jQuery.uaMatch = function( ua ) {
        ua = ua.toLowerCase();

        var match = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
            /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
            /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
            /(msie) ([\w.]+)/.exec( ua ) ||
            ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) ||
            [];

        return {
            browser: match[ 1 ] || "",
            version: match[ 2 ] || "0"
        };
    };

    matched = jQuery.uaMatch( navigator.userAgent );
    browser = {};

    if ( matched.browser ) {
        browser[ matched.browser ] = true;
        browser.version = matched.version;
    }

// Chrome is Webkit, but Webkit is also Safari.
    if ( browser.chrome ) {
        browser.webkit = true;
    } else if ( browser.webkit ) {
        browser.safari = true;
    }

    jQuery.browser = browser;

    jQuery.sub = function() {
        function jQuerySub( selector, context ) {
            return new jQuerySub.fn.init( selector, context );
        }
        jQuery.extend( true, jQuerySub, this );
        jQuerySub.superclass = this;
        jQuerySub.fn = jQuerySub.prototype = this();
        jQuerySub.fn.constructor = jQuerySub;
        jQuerySub.sub = this.sub;
        jQuerySub.fn.init = function init( selector, context ) {
            if ( context && context instanceof jQuery && !(context instanceof jQuerySub) ) {
                context = jQuerySub( context );
            }

            return jQuery.fn.init.call( this, selector, context, rootjQuerySub );
        };
        jQuerySub.fn.init.prototype = jQuerySub.fn;
        var rootjQuerySub = jQuerySub(document);
        return jQuerySub;
    };

})();

function makeAlphanumericId(){
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for( var i=0; i < 10; i++ )
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
}

//browser plugin that broke scrolling because it was missing
function updateAllThingsConditional(){
	var allConditionalFieldsByName = [];
	var allConditionalFieldOptionsByFieldName = {};
	// Go through all fields - if there is a conditional dropdown, add it to the array & object of field names & option 
	$('#objectFieldsTable .baseRow').each(function(){
		var baseRowId = $(this).attr('baserowid');
		
		var fieldIsConditional = $('[baserowid="'+baseRowId+'"] input[jsonfield="conditional"]').prop("checked");
		var fieldName = $('[baserowid="'+baseRowId+'"] input[type="text"][jsonfield="fieldName"]').val();
		var fieldType = $('[baserowid="'+baseRowId+'"] select[jsonfield="formType"]').val();
		if(fieldIsConditional == true){
			if(fieldType == "select"){
				allConditionalFieldsByName.push(fieldName);
				fieldOptions = {};
				$('[baserowid="'+baseRowId+'"] input.optionValueInput').each(function(){
					var optionName = $(this).val();
					var optionId = $(this).parent().parent().parent().find('.optionIdInput').val();
					fieldOptions[optionName] = optionId;
				});
				allConditionalFieldOptionsByFieldName[fieldName] = fieldOptions;
			}
			else if(fieldType == "text" || fieldType == "date"){
				allConditionalFieldsByName.push(fieldName);
			}
		}
	});
	console.log(allConditionalFieldsByName)
	console.log(allConditionalFieldOptionsByFieldName)
	// Now that we know the conditional fields and each of their options, put them in each field (with modifications to not show the field you're adding to)...
	$('#objectFieldsTable .baseRow').each(function(){
		var baseRowId = $(this).attr('baserowid');
		var fieldName = $('[baserowid="'+baseRowId+'"] input[type="text"][jsonfield="fieldName"]').val();
		conditionalFieldsDropdown_modified = jQuery.grep(allConditionalFieldsByName, function(value) {
											  return value != fieldName;
											});
		conditionalFieldsDropdown_modified_HTML = "";
		$(conditionalFieldsDropdown_modified).each(function(){
			conditionalFieldsDropdown_modified_HTML += '<option value="' + this + '">' + this + '</option>';
		});
		$('[baserowid="'+baseRowId+'"] .conditionalFieldsDropdown').html(conditionalFieldsDropdown_modified_HTML);
	});
}

function addOptionToField(baseRowId, optionValue="", optionId="", conditionalFieldsDropdownValues="", conditionalFieldsDropdownOptionValues=""){
	console.log(baseRowId)
	var newOptionRowHTML = '<tr><td><div class="optionValueContainer"><input type="text" class="optionValueInput" placeholder="Option Value" value="'+optionValue+'"></div></td><td><div class="optionIdContainer"><input type="text" class="optionIdInput" placeholder="Option ID" value="'+optionId+'"></div></td><td><div class="conditionalFieldsDropdownContainer"><select class="conditionalFieldsDropdown" multiple="" setvalueafterpageloads="'+conditionalFieldsDropdownValues+'"></select></div></td><td><div class="conditionalFieldsDropdownContainer"><select class="conditionalFieldsOptionsDropdown" multiple="" setvalueafterpageloads="'+conditionalFieldsDropdownOptionValues+'"></select></div></td><td class="removeOptionButton"></td></tr>'
	$('[columnid="dropdownOptionsSettings"][baserowid="'+baseRowId+'"] table.dropdownOptionsTable tbody').append(newOptionRowHTML)
}

// Look for changes in every field's list of conditionalFields so that options can be added & removed
$('body').on('change','.conditionalFieldsDropdown',function(event){
	var fieldsDropdown = $(this);
	var optionsDropdown = $(this).parent().parent().parent().find('.conditionalFieldsOptionsDropdown');
	
	// Make list of all the field options to put in - start by getting the selected fields
	var allSelectedFields = []
	fieldsDropdown.find('option:selected').each(function(){
		allSelectedFields.push($(this).attr('value'));
	});
	
	// Now that we have all the selected fields by name, go to each field and get all their options and throw them in the list
	var allOptionsFromSelectedFields = [];
	$('#objectFieldsTable .baseRow').each(function(){
		var baseRowId = $(this).attr('baserowid');
		var fieldName = $('[baserowid="'+baseRowId+'"] input[type="text"][jsonfield="fieldName"]').val();
		if($.inArray(fieldName, allSelectedFields) > -1){
			console.log($(this).find('input.optionIdInput'));
			$('[baserowid="'+baseRowId+'"] input.optionIdInput').each(function(){
				allOptionsFromSelectedFields.push($(this).val());
			});
		}
	});
	console.log(allOptionsFromSelectedFields)

	// Build list of currently selected field options
	var currentlySelectedOptions = [];
	console.log(optionsDropdown.find('option').length)
	console.log(optionsDropdown.find('option:selected').length)
	optionsDropdown.find('option:selected').each(function(){
		currentlySelectedOptions.push($(this).attr('value'))
	});
	console.log(currentlySelectedOptions)
	// Make new options HTML
	var newOptionsDropdownHTML = "";
	$.each(allOptionsFromSelectedFields, function(){
		newOptionsDropdownHTML += '<option value="' + this + '">' + this + '</option>';
	});

	// Clear out all the current field options and insert new list of field options
	optionsDropdown.html(newOptionsDropdownHTML);
	
	// Select all the field options that were selected before, as long as they still exist
	$.each(currentlySelectedOptions, function(){
		optionsDropdown.find('option[value="' + this + '"]').prop('selected',true);
	});
})

$('body').on('blur','[jsonfield="fieldName"]',function(event){
	// Whenever the item's fields are changed significantly, update the label printing table
	updateFieldNameDropdownHTML(); // update window.fieldNamesDropdownOptionsHTML
	updateFieldNameDropdownsInLabelPrintingSettingsTable(); // set up field name dropdowns
});

$('body').on('change','select[jsonfield="lookupRegField"]',function(event){
	var lookupRegFieldGroupId = $(this).val();
	console.log("lookupRegFieldGroupId :: "+ lookupRegFieldGroupId);
	if(lookupRegFieldGroupId !== ""){
		var lookupRegFieldNames = JSON.parse(restCall("/getFieldNamesFromReg/","POST",{"regFieldGroupId":lookupRegFieldGroupId}));
		if(lookupRegFieldNames['status'] == "success"){
			var fieldNamesHTML = "";
			$.each(lookupRegFieldNames['results'],function(actualField,displayName){
				fieldNamesHTML += '<option value="' + actualField + '">' + displayName + '</option>';
			});
			
			var lookupRegFieldsToAdd = $(this).parent().parent().parent().parent().find('[jsonfield="lookupRegFieldsToAdd"]');
			lookupRegFieldsToAdd.html(fieldNamesHTML)
			if(typeof lookupRegFieldsToAdd.attr('setvalueafterpageloads') !== "undefined"){
				lookupRegFieldsToAdd.val(lookupRegFieldsToAdd.attr('setvalueafterpageloads').split(','));
			}
			
			var columnsInTypeahead = $(this).parent().parent().parent().parent().find('[jsonfield="columnsInTypeahead"]');
			columnsInTypeahead.html(fieldNamesHTML)
			if(typeof columnsInTypeahead.attr('setvalueafterpageloads') !== "undefined"){
				columnsInTypeahead.val(columnsInTypeahead.attr('setvalueafterpageloads').split(','));
			}
		}
	}
});

$('body').on('change','select[jsonfield="columnsInTypeahead"]',function(event){
	if($(this).val().length > 3){
		if(typeof $(this).attr('lastvalidselection') !== "undefined"){
			var lastValidSelection = $(this).attr('lastvalidselection').split(",");
	    	$(this).val($(this).attr('lastvalidselection').split(","));
    	}
    }
    else{
    	$(this).attr('lastvalidselection',$(this).val());
    }
});

$('body').on('blur','.optionValueInput',function(event){
	var baseRowId = $(this).parent().parent().parent().parent().parent().parent().parent().attr('baserowid')
	var baseRowIdNumber = $('.baseRow[baserowid="'+baseRowId+'"]').attr('baserowidnumber');
	populateBaseRow(baseRowIdNumber)
});

$('body').on('click','.basicSettingsCell, .advancedSettingsCell, .lookupSettingsCell, .dropdownOptionsSettingsCell, .formVisibilitySettingsCell', function(event){
	columnId = $(this).attr('columnid');
	baseRowId = $(this).parent().attr('baserowid');
	baseRowIdNumber = $('.baseRow[baserowid="'+baseRowId+'"]').attr('baserowidnumber');
	if($(this).hasClass('expandedCell')){ // The cell is already being shown - hide the details
		$('.baseRow[baserowid="'+baseRowId+'"] td').removeClass('expandedCell');
		$(this).removeClass('expandedCell');
		$('.detailsRow[baserowid="'+baseRowId+'"][columnid="'+columnId+'"]').removeClass('makeVisible');
	}
	else{ // The cell needs to be expanded and any other detailsRows need to be hidden
		$('.baseRow[baserowid="'+baseRowId+'"] td').removeClass('expandedCell');
		$(this).addClass('expandedCell');
		$('.detailsRow[baserowid="'+baseRowId+'"]').removeClass('makeVisible');
		$('.detailsRow[baserowid="'+baseRowId+'"][columnid="'+columnId+'"]').addClass('makeVisible');
	}
	populateBaseRow(baseRowIdNumber)
});

$('body').on('click','.objectFieldsTable .addOptionButton', function(event){
	addOptionToField($(this).parent().parent().attr('baserowid'));
	//updateAllThingsConditional(); Problematic - for now just force the user to add their dropdown options & hit save before dealing with any conditional stuff
});

$('body').on('click','.objectFieldsTable .removeOptionButton', function(event){
	if(!$(this).parent().parent().parent().parent().parent().hasClass('keepOptionsSynced')){
		$(this).parent().remove();
		//updateAllThingsConditional(); Problematic - for now just force the user to add their dropdown options & hit save before dealing with any conditional stuff
	}
});

$('body').on('click','.editTemplateBottomButtons > div.editTemplateBottomButtons_addField > button', function(event){
	var newFieldIdNumber = addField();
	populateBaseRow(newFieldIdNumber);
	var lookupRegFieldDropdownHTML = $('select[jsonfield="lookupRegField"]').html();
	$('[baserowid="field_'+newFieldIdNumber+'"][columnid="lookupSettings"] .lookupRegFieldDropdown').html(lookupRegFieldDropdownHTML);
	if($('.objectFieldsTable').hasClass('objectFieldsTable_commonPoolOfDropdowns')){
		$('.baseRow[baserowidnumber="'+newFieldIdNumber+'"] .dropdownOptionsSettingsCell').click();
		$('.detailsRow[columnid="dropdownOptionsSettings"][baserowid="field_'+newFieldIdNumber+'"] .addOptionButton').click();
	}
	$('.baseRow[baserowidnumber="'+newFieldIdNumber+'"] [jsonfield="fieldName"]').focus();
});

$('body').on('click','.editTemplateBottomButtons > div.editTemplateBottomButtons_saveObject > button', function(event){
	saveObject();
});

$('body').on('click','.objectFieldsLabelPrintingSettingsBottomButtons > div.objectFieldsLabelPrintingSettingsBottomButtons_saveObjectTemplate > button', function(event){
	saveObject();
});

$('body').on('click','.editTemplateFieldGroupsBottomButtons > div.editTemplateFieldGroupsBottomButtons_addGroup > button', function(event){
	var newGroupId = addFieldGroup();
	// Update fieldGroupsObject
	window.fieldGroupsObject.push({"fieldGroupId": newGroupId, "fieldGroupName": ""});
	upsertFieldGroupToDropdowns(newGroupId, "");
});

$('body').on('change','.fieldGroupSelect', function(event){
	populateObjectFieldsGroupingTable();
});

$('body').on('blur','[jsonfield="fieldGroupName"]', function(event){
	fieldGroupId = $(this).parent().parent().attr('fieldgroupid');
	fieldGroupNameValue = $(this).val();
	// Update fieldGroupsObject
	console.log("blur happened");
	console.log(fieldGroupId);
	console.log(fieldGroupNameValue);
	$.each(window.fieldGroupsObject,function(index, fieldGroup){
		console.log(index)
		console.log(fieldGroup)
		if(fieldGroup['fieldGroupId'] == fieldGroupId){
			console.log("found a match...")
			window.fieldGroupsObject[index]['fieldGroupName'] = fieldGroupNameValue;
			populateObjectFieldsGroupingTable();
			return false;
		}
	});
});

$('body').on('click','#objectFieldsGroupingTable .removeGroupButton', function(event){
	var fieldGroupId = $(this).parent().parent().attr('fieldgroupid');
	console.log(fieldGroupId)
	// Update fieldGroupsObject and removing the group's row from the grouping table
	$.each(window.fieldGroupsObject, function(index, fieldGroup){
		console.log(fieldGroup)
		if(fieldGroup['fieldGroupId'] == fieldGroupId){
			console.log('deleting ' + fieldGroupId)
			window.fieldGroupsObject.splice(index, 1);
			$('[fieldgroupid="'+fieldGroupId+'"]').remove();
			$('#objectFieldsTable tbody tr.baseRow [jsonfield="fieldGroupId"] option[value="'+fieldGroupId+'"]').remove();
			//populateObjectFieldsGroupingTable();
			return false;
		}
	});

});

$('body').on('change','[jsonfield="required"]', function(event){
	var isChecked = $(this).prop('checked');
	var baseRowId = ""
	if(typeof $(this).parent().parent().parent().attr('baserowid') !== "undefined"){
		baseRowId = $(this).parent().parent().parent().attr('baserowid');
	}
	else{
		baseRowId = $(this).parent().parent().parent().parent().attr('baserowid');
	}
	$('[baserowid="'+baseRowId+'"] [jsonfield="required"]').prop('checked',isChecked);
});

$('body').on('change','[jsonfield="conditional"]', function(event){
	var isChecked = $(this).prop('checked');
	var baseRowId = ""
	if(typeof $(this).parent().parent().parent().attr('baserowid') !== "undefined"){
		baseRowId = $(this).parent().parent().parent().attr('baserowid');
	}
	else{
		baseRowId = $(this).parent().parent().parent().parent().attr('baserowid');
	}
	$('[baserowid="'+baseRowId+'"] [jsonfield="conditional"]').prop('checked',isChecked);
});

$('body').on('click','table#objectFieldsTable tbody tr.baseRow td.rightSpecialCell .removeFieldButton', function(event){
	var baseRowId = $(this).parent().parent().attr('baserowid');
	console.log("Trash can :: "+ baseRowId);
	console.log("Trash can :: "+ $('table#objectFieldsTable').hasClass('objectFieldsTable_commonPoolOfDropdowns') );
	
	
	if($('table#objectFieldsTable').hasClass('objectFieldsTable_commonPoolOfDropdowns')){
		// The user is trying to remove a dropdown from the pool of dropdowns
		var dropdownName = $('table#objectFieldsTable.objectFieldsTable_commonPoolOfDropdowns tr[baserowid="'+baseRowId+'"] [jsonfield="fieldName"]').val();
		var dropdownId = $('table#objectFieldsTable.objectFieldsTable_commonPoolOfDropdowns tr[baserowid="'+baseRowId+'"]').attr('pooloffields_dropdown_id');
		console.log("Trash can :: "+ dropdownId);
		if(typeof dropdownId == "undefined"){
			swal({
			  title: "Are you sure?",
			  text: null,
			  showCancelButton: true,
			  confirmButtonText: "Confirm"
			},
			function(isConfirm){
				if(isConfirm){
				  	// It's not in Mongo yet, so just remove the tr from the DOM
				  	$('table#objectFieldsTable.objectFieldsTable_commonPoolOfDropdowns tr[baserowid="'+baseRowId+'"]').remove();
				}
			});
		}
		objectsSyncedToPoolDropdown = restCall("/getObjectsSyncedToPoolDropdown/","POST",{"poolOfFields_dropdown_id":dropdownId});
		if(objectsSyncedToPoolDropdown['syncedInventoryFields'].length == 0){
			var impactedFieldsHTML = '<div class="impactedFieldsDescription">Are you sure you want to delete the dropdown "'+dropdownName+'"?</div>' + generateImpactedFieldsHTML(objectsSyncedToPoolDropdown['syncedInventoryFields']);
			swal({
			  title: "Are you sure?",
			  text: impactedFieldsHTML,
			  html: true,
			  showCancelButton: true,
			  confirmButtonText: "Confirm"
			},
			function(isConfirm){
				if(isConfirm){
				  	dropdownDeleted = restCall("/deleteDropdownFromPoolOfFields/","POST",{"poolOfFields_dropdown_id":dropdownId});
				  	if(dropdownDeleted['result'] == "success"){
				  		swal({
				  		  title: "Successfully Deleted",
				  		  text: null,
				  		  timer: 900,
				  		  showConfirmButton: false,
				  		  type: "success"
				  		})
				  		$('table#objectFieldsTable.objectFieldsTable_commonPoolOfDropdowns tr[baserowid="'+baseRowId+'"]').remove();
				  	}
				}
			});
		}
		else{
			var impactedFieldsHTML = '<div class="impactedFieldsDescription" style="margin-top:-10px;">"'+dropdownName+'" can\'t be deleted because there are Object Types/Fields that are currently using it.</div>' + generateImpactedFieldsHTML(objectsSyncedToPoolDropdown['syncedInventoryFields']);
			swal({
			  title: "Dropdown can't be deleted",
			  text: impactedFieldsHTML,
			  html: true,
			  showCancelButton: false,
			  showConfirmButton: true,
			  confirmButtonText: "Cancel",
			  type: "warning"
			});
		}
	}
	else{
		// The user is trying to remove a field from an object type
		swal({
			title: "Are you sure?",
			text: null,
			showCancelButton: true,
			confirmButtonText: "Confirm"
		},
		function(isConfirm){
			if(isConfirm){
				$('tr[baserowid="'+baseRowId+'"]').remove();
			}
		});
	}

	// Whenever the item's fields are changed significantly, update the label printing table
	updateFieldNameDropdownHTML(); // update window.fieldNamesDropdownOptionsHTML
	updateFieldNameDropdownsInLabelPrintingSettingsTable(); // set up field name dropdowns
});

$('body').on('click','.reorderFieldsButton',function(event){
	var reorderFieldsPopupHTML = "";
	reorderFieldsPopupHTML += '<div class="reorderFieldsPopup">';
	$('#objectFieldsTable tr.baseRow').each(function(){
		var baseRowId = $(this).attr('baserowid');
		var fieldName = $(this).find('.fieldNameTextBox').val();
		reorderFieldsPopupHTML += '<div class="reorderableFieldElement" baserowid="'+baseRowId+'">'+fieldName+'</div>'
	});
	reorderFieldsPopupHTML += '</div>';
	swal({
	  title: "Reorder Object Fields",
	  text: reorderFieldsPopupHTML,
	  html: true,
	  showCancelButton: true,
	  confirmButtonText: "Confirm"
	},
	function(isConfirm){
	  if (isConfirm) {
	  	count = 0;
	  	$('.reorderFieldsPopup .reorderableFieldElement').each(function(){
	  		var baseRowId = $(this).attr('baserowid');
	  		$('#objectFieldsTable > tbody > tr[baserowid='+baseRowId+']').each(function(){
	  			if($('#objectFieldsTable > tbody > tr.justReordered').length == 0){
	  				$('#objectFieldsTable > tbody').prepend($(this));
	  			}
	  			else{
	  				$(this).insertAfter($('#objectFieldsTable > tbody tr.justReordered:last'));
	  				console.log($('#objectFieldsTable > tbody tr.justReordered:last'));
	  			}
	  			$(this).addClass('justReordered');
	  		});
	  		count++;
	  	});
	  	//$('#objectFieldsTable > tbody > tr.justReordered').removeClass('justReordered');
	  }
	});
	$('.reorderFieldsPopup').sortable({placeholder: "ui-state-highlight", helper: 'clone'});
});

$('body').on('change','#labelPrintingSettingsLayoutDropdown',function(){
	var selectedOption = $(this).find('option:selected');
	layoutId = selectedOption.attr('layoutid');
	numberOfLines = parseFloat(selectedOption.attr('numberoflines'));
	changeNumberOfLabelPrinterLayoutLines(numberOfLines); // Give the table the right number of rows
	updateFieldNameDropdownHTML(); // update window.fieldNamesDropdownOptionsHTML
	updateFieldNameDropdownsInLabelPrintingSettingsTable(); // set up field name dropdowns
});

//Show Users and UserGroups only if the restrict option is selected
$('body').on('change','#restrictAccess',function(){
	restrictAccessCheck($(this).prop('checked'))
});

function restrictAccessCheck(checked){
	console.log("restrictAccessCheck :: "+ checked)
	if(checked){
		if(!$('.objectAllowedGroupsUsersContainer').hasClass('makeVisible')){ 
			$('.objectAllowedGroupsUsersContainer').addClass('makeVisible');
		}
	}
	else {
		if($('.objectAllowedGroupsUsersContainer').hasClass('makeVisible')){ 
			$('.objectAllowedGroupsUsersContainer').removeClass('makeVisible');
		}
	}
}


//Let the user select only one of four options
$('body').on('change','[jsonfield="isBarcodeField"] , [jsonfield="isAmountField"], [jsonfield="isAmountUnitField"], [jsonfield="isLookupField"]',function(){
	var isChecked = $(this).prop('checked');
	var baseRowId = $(this).parent().parent().parent().attr('baserowid');
	oneOfFourOptionsCheck(isChecked, baseRowId, $(this).attr('jsonfield'))
});

function oneOfFourOptionsCheck(isChecked, baseRowId, jsonfield){
	oneOfFourOptionList = ['isBarcodeField', 'isAmountField', 'isAmountUnitField', 'isLookupField']
	if (isChecked) {
		for (var i = 0; i<oneOfFourOptionList.length; i++){
			opt = oneOfFourOptionList[i];
			if (opt != jsonfield){
				if(! $('#' + oneOfFourOptionList[i] + '_' + baseRowId).is('[disabled=disabled]')) { 
					$('#' + oneOfFourOptionList[i] + '_' + baseRowId).attr("disabled", true);
				}
				
				if(! $("label[for='"+oneOfFourOptionList[i]+"_"+baseRowId+"']").hasClass('gray')){
					$("label[for='"+oneOfFourOptionList[i]+"_"+baseRowId+"']").addClass('gray');
				}
			}
		}
	}
	else {
		for (var i = 0; i<oneOfFourOptionList.length; i++){
			opt = oneOfFourOptionList[i];
			if($('#' + oneOfFourOptionList[i] + '_' + baseRowId).is('[disabled=disabled]')) { 
				$('#' + oneOfFourOptionList[i] + '_' + baseRowId).attr("disabled", false);
			}
			
			if($("label[for='"+oneOfFourOptionList[i]+"_"+baseRowId+"']").hasClass('gray')){
				$("label[for='"+oneOfFourOptionList[i]+"_"+baseRowId+"']").removeClass('gray');
			}
		}
	}
}

//If the form type is File gray out 10 options in Advanced options
$('body').on('change','select[jsonfield="formType"]',function(){
	var selectedOption = $(this).val();
	var baseRowId =$(this).parent().parent().parent().parent().parent().attr('baserowid');
	formTypeCheck(selectedOption, baseRowId);
});

function formTypeCheck(selectedOption, baseRowId){
	advancedOptionList = ['inSearch', 'inImport', 'inTable', 'isTableLink', 'isNameField', 'isBarcodeField', 'isAmountField', 'isAmountUnitField', 'isLookupField', 'isUnique', 'required', 'isHidden', 'disableOnEdit', 'textOnOther'];
	
	for (var i = 0; i < advancedOptionList.length; i++) {
		//Uncheck all the check boxes
		$('#' + advancedOptionList[i] + '_' + baseRowId).prop('checked', false);
		
		if (selectedOption == "file"){
			if (i != "10" && i != "11" && i != "12"){
				if(! $('#' + advancedOptionList[i] + '_' + baseRowId).is('[disabled=disabled]')) { 
					$('#' + advancedOptionList[i] + '_' + baseRowId).attr("disabled", true);
				}
				
				if(! $("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").hasClass('gray')){
					$("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").addClass('gray');
				}
			}
			else{
				if($('#' + advancedOptionList[i] + '_' + baseRowId).is('[disabled=disabled]')) { 
					$('#' + advancedOptionList[i] + '_' + baseRowId).attr("disabled", false);
				}
				if($("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").hasClass('gray')){
					$("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").removeClass('gray');
				}
			}
		}
		else if(selectedOption == "select"){
			if(i == advancedOptionList.length-1){
				if($('#' + advancedOptionList[i] + '_' + baseRowId).is('[disabled=disabled]')) { 
					$('#' + advancedOptionList[i] + '_' + baseRowId).attr("disabled", false);
				}
				if($("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").hasClass('gray')){
					$("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").removeClass('gray');
				}
			}
			else{
				if($('#' + advancedOptionList[i] + '_' + baseRowId).is('[disabled=disabled]')) { 
					$('#' + advancedOptionList[i] + '_' + baseRowId).attr("disabled", false);
				}
				if($("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").hasClass('gray')){
					$("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").removeClass('gray');
				}
			}
		}
		else{
			if(i == advancedOptionList.length-1){
				if(! $('#' + advancedOptionList[i] + '_' + baseRowId).is('[disabled=disabled]')) { 
					$('#' + advancedOptionList[i] + '_' + baseRowId).attr("disabled", true);
				}
				if(! $("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").hasClass('gray')){
					$("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").addClass('gray');
				}
			}
			else{
				if($('#' + advancedOptionList[i] + '_' + baseRowId).is('[disabled=disabled]')) { 
					$('#' + advancedOptionList[i] + '_' + baseRowId).attr("disabled", false);
				}
				if($("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").hasClass('gray')){
					$("label[for='"+advancedOptionList[i]+"_"+baseRowId+"']").removeClass('gray');
				}
			}
		}
	}
}


$('body').on('keyup','.optionValueInput',function(){
	console.log("optionValueInput :: "+ $(this).val());
	$(this).parent().parent().parent().find('input.optionIdInput').val($(this).val());
});

function updateFieldNameDropdownsInLabelPrintingSettingsTable(){
	$('#objectFieldsLabelPrintingSettingsTable tbody tr .fieldNameDropdown_labelPrinting').each(function(){
		currentValue = $(this).val();
		$(this).html(window.fieldNamesDropdownOptionsHTML);
		$(this).val(currentValue).change();
	});
}

// Removes unnecessary rows from label printer layout table & adds necessary ones
function changeNumberOfLabelPrinterLayoutLines(numberOfLines){
	if(isNaN(numberOfLines)){numberOfLines = 0}
	$('#objectFieldsLabelPrintingSettingsTable tbody tr').each(function(lineNumber, labelLine){
		if(numberOfLines <= lineNumber){
			$(this).remove();
		}
	});
	var linesToAdd = numberOfLines - $('#objectFieldsLabelPrintingSettingsTable tbody tr').length;
	for (var i=0;i<linesToAdd;i++){
		var lineNumber = $('#objectFieldsLabelPrintingSettingsTable tbody tr').length+1;
		$('#objectFieldsLabelPrintingSettingsTable tbody').append('<tr linenumber="'+lineNumber+'"><td>Line '+lineNumber+'</td><td><div class="select-style select-style-long"><select class="fieldNameDropdown_labelPrinting"></select></div></td></tr>')
	}
}

// Loop through fields for this Inventory Item and make an HTML string with the <option>'s you need for a dropdown w/ all the field names
function updateFieldNameDropdownHTML(){
	var fieldNamesDropdownOptions = '<option value="">-- Leave Blank --</option>';
	$('table#objectFieldsTable tr.baseRow [jsonfield="fieldName"]').each(function(){
		var fieldName = $(this).val()
		var baseRowId = $(this).parent().parent().attr('baserowid')
		thisOption = $('<option/>', {
            'value': baseRowId,
            'text': fieldName
        })
		fieldNamesDropdownOptions += thisOption.wrapAll('<div>').parent().html();
	});
	window.fieldNamesDropdownOptionsHTML = fieldNamesDropdownOptions;
}

function generateImpactedFieldsHTML(syncedInventoryFields){
	var impactedFieldsHTML = '<h3 class="impactedFieldsTableHeading">Object Types/Fields Using This Dropdown</h3>'
	impactedFieldsHTML += '<table class="impactedFieldsTable">'
	impactedFieldsHTML += '<thead>'
		impactedFieldsHTML += '<th>Object Type</th>'
		impactedFieldsHTML += '<th>Field Name</th>'
	impactedFieldsHTML += '</thead><tbody>'
	if(syncedInventoryFields.length > 0){
		$.each(syncedInventoryFields, function(index, syncedField){
			impactedFieldsHTML += '<tr>'
				impactedFieldsHTML += '<td>' + syncedField['objectType'] + '</td>'
				impactedFieldsHTML += '<td>' + syncedField['formName'] + '</td>'
			impactedFieldsHTML += '</tr>'
		});
	}
	else{
		impactedFieldsHTML += '<tr><td colspan="2" class="noImpactedFieldsCell">There are no Object Types/Fields that use this dropdown.</td></tr>'
	}
	impactedFieldsHTML += '</tbody></table>'
	return impactedFieldsHTML;
}

$('body').on('click','.saveDropdownOptions',function(event){
	var baseRowId = $(this).parent().parent().attr('baserowid');
	var dropdownName = $(this).parent().parent().parent().find("[baserowid='"+baseRowId+"'] [jsonfield='fieldName']").val();
	var poolOfFields_dropdown_id = $(this).parent().parent().parent().find("[baserowid='"+baseRowId+"']").attr('pooloffields_dropdown_id');
	if(typeof poolOfFields_dropdown_id == "undefined"){
		poolOfFields_dropdown_id = makeAlphanumericId();
		$(this).parent().parent().parent().find("[baserowid='"+baseRowId+"']").attr('pooloffields_dropdown_id', poolOfFields_dropdown_id);
	}
	var dropdownDisabled = $('.baseRow[baserowid="'+baseRowId+'"] .commonPoolField_disabled').prop('checked');
	objectsSyncedToPoolDropdown = restCall("/getObjectsSyncedToPoolDropdown/","POST",{"poolOfFields_dropdown_id":poolOfFields_dropdown_id});
	var impactedFieldsHTML = '<div class="impactedFieldsDescription">Are you sure you want to save/update this dropdown?</div>' + generateImpactedFieldsHTML(objectsSyncedToPoolDropdown['syncedInventoryFields']);
	
	options = []
	optionIds = {}
	$('[baserowid="'+baseRowId+'"] .optionValueInput').each(function(i,el){
		options.push($(el).val());
		optionIds[$(el).val()] = $(el).parent().parent().parent().find('input.optionIdInput').val();
	});
	var dropdownData = {}
	dropdownData["options"] = options;
	dropdownData["optionIds"] = optionIds;
	dropdownData["fieldName"] = dropdownName;
	dropdownData["fieldDisabled"] = dropdownDisabled;
	dropdownData["poolOfFields_dropdown_id"] = poolOfFields_dropdown_id;

	if(dropdownData["fieldName"] !== ""){
		swal({
		  title: "Save Dropdown Options",
		  text: impactedFieldsHTML,
		  html: true,
		  showCancelButton: true,
		  confirmButtonText: "Save",
		  closeOnConfirm: false
		},
		function(isConfirm){
		  if (isConfirm) {
		  	var upsertPoolOfDropdowns = restCall("/upsertPoolOfDropdowns/","POST",dropdownData);
		  	if(upsertPoolOfDropdowns['result'] == "error"){
		  		swal("",upsertPoolOfDropdowns['error'],"error");
		  	}
		  	else if(upsertPoolOfDropdowns['result'] == "success"){
		  		swal({
		  		  title: "Save Successful",
		  		  text: null,
		  		  timer: 900,
		  		  showConfirmButton: false,
		  		  type: "success"
		  		})
		  	}
		  }
		});
	}
	else{
		swal("",'You must fill in the "Field Name" text box.',"warning");
	}
});

$('body').on('click','.importOptionsFromCommonPoolButton',function(event){
	var poolDropdownId = $(this).parent().find('.commonPoolDropdownsDropdown').val();
	var baseRowId = $(this).parent().parent().parent().attr('baserowid');
	$.each(window.commonPoolOfDropdowns['dropdowns'],function(index, thisDropdown){
		if(thisDropdown['poolOfFields_dropdown_id'] == poolDropdownId){ // looking at the right dropdown
			for(var j=0;j<thisDropdown["options"].length;j++){
				optionValue = thisDropdown["options"][j];
				optionId = "";
				if(typeof thisDropdown["optionIds"] !== "undefined"){
					optionId = thisDropdown["optionIds"][thisDropdown["options"][j]];
				}
				addOptionToField(baseRowId, optionValue, optionId);
			}
		}
	});
});

$('body').on('change','.keepOptionsSyncedCheckbox',function(event){
    var keepOptionsSyncedCB = $(this);
    var dropdownOptionsTableBody = $(this).parent().parent().find('.dropdownOptionsTable tbody');
    var importOptionsButton = $(this).parent().find('.importOptionsFromCommonPoolButton');
    var detailsRow = $(this).parent().parent().parent();
    if(keepOptionsSyncedCB.is(":checked")) {
    	var nameOfChosenDropdown = keepOptionsSyncedCB.parent().find('.commonPoolDropdownsDropdown option:selected').text();
        swal({
        	title: "Are you sure?",
        	text: 'If you check this box, all the options for your dropdown will be completely replaced by the options in "'+nameOfChosenDropdown+'".',
        	showCancelButton: true,
        	type: "warning",
        },
        function(isConfirm){
			if(isConfirm){
				// This code is also used in loadJSON()...
				keepOptionsSyncedCB.attr("checked",true);
				dropdownOptionsTableBody.empty();
				importOptionsButton.click();
				detailsRow.addClass('keepOptionsSynced');
				detailsRow.find('.optionValueInput, .optionIdInput').prop('disabled',true);
			}
			else {
				keepOptionsSyncedCB.attr("checked",false);
				detailsRow.removeClass('keepOptionsSynced');
				detailsRow.find('.optionValueInput, .optionIdInput').prop('disabled',false);
			}
        });


        //var returnVal = confirm("Are you sure?");
        //$(this).attr("checked", returnVal);
    }
    else{
    	detailsRow.removeClass('keepOptionsSynced');
    	detailsRow.find('.optionValueInput, .optionIdInput').prop('disabled',false);
    }
    $('#textbox1').val($(this).is(':checked'));        
});

$('body').on('change','.commonPoolField_disabled',function(){
	var fieldDisabled = $(this).prop('checked');
	var fieldId = $(this).parent().parent().attr('pooloffields_dropdown_id');
	if(typeof fieldId !== "undefined"){
		toggleDisabled = restCall("/commonPoolField_toggleDisabled/","POST",{"fieldId":fieldId,"fieldDisabled":fieldDisabled});
	}
});

// Select the fields that are supposed to be selected
function selectConditionalFieldsFromLastSave(){
	$('#objectFieldsTable .baseRow').each(function(){
		var baseRowId = $(this).attr('baserowid');
		
		var fieldRowsForBaseRowId_fieldName = $(this).find('input[type="text"][jsonfield="fieldName"]').val();
		$.each(window.mostRecentSavedObjectData['fields'],function(){
			if(fieldRowsForBaseRowId_fieldName == this['fieldName']){
				var savedObjectData_field = this;
				console.log('[baserowid="'+baseRowId+'"] .optionIdInput');
				$('[baserowid="'+baseRowId+'"] .optionIdInput').each(function(){
					var optionIdValue = $(this).val();
					var fieldNamesSelect = $(this).parent().parent().parent().find('.conditionalFieldsDropdown');
					var fieldOptionsSelect = $(this).parent().parent().parent().find('.conditionalFieldsOptionsDropdown');
					console.log(optionIdValue)
					console.log(fieldNamesSelect)
					console.log(fieldOptionsSelect)
					if(typeof savedObjectData_field['conditionalFieldsAndOptions'][optionIdValue] !== "undefined"){
						$.each(savedObjectData_field['conditionalFieldsAndOptions'][optionIdValue]['fieldNames'], function(){
							fieldNamesSelect.find('option[value="'+this+'"]').prop('selected',true);
						});
						fieldNamesSelect.change();
						$.each(savedObjectData_field['conditionalFieldsAndOptions'][optionIdValue]['fieldOptions'], function(){
							fieldOptionsSelect.find('option[value="'+this+'"]').prop('selected',true);
						})
					}
				});
				return false;
			}
		});

	});
}

function loadLabelPrintingLayoutList(labelPrinting_layouts){
	var dropdownOptions = '<option value="">-- None (Label Printing Disabled) --</option>';
	$.each(labelPrinting_layouts, function(index, layout){
		console.log(layout)
		dropdownOptions += '<option layoutid="'+layout.id+'" numberoflines="'+layout.lineCount+'">'+layout.layoutName+'</option>';
	});
	$('#labelPrintingSettingsLayoutDropdown').html(dropdownOptions);
}

function addField(id){
	if(typeof id == "undefined"){
		id = "field_" + $('table#objectFieldsTable tbody tr.baseRow').length; // Add Field button was clicked, needs new ID
	}
	idNumberOnly = id.replace("field_","");

	// Generate the Base Field table row
	var rowHTML = ""
	rowHTML += '<tr class="baseRow alwaysVisible" baserowid="'+id+'" baserowidnumber="'+idNumberOnly+'">'
		rowHTML += '<td class="fieldNameCell"><input type="text" class="fieldNameTextBox" placeholder="Field name (required)" jsonfield="fieldName"><div class="select-style select-style-medium-short fieldGroupSelectContainer"><select class="fieldGroupSelect" jsonfield="fieldGroupId"><option value="">-- No field group --</option>'
		var fieldGroupOptionsHTML = "";
		$.each(window.fieldGroupsObject, function(index, fieldGroup){
			fieldGroupOptionsHTML += '<option value="'+fieldGroup['fieldGroupId']+'">'+fieldGroup['fieldGroupName']+'</option>'
		});
		rowHTML += fieldGroupOptionsHTML
		rowHTML += '</select></div></td>'
		rowHTML += '<td class="basicSettingsCell" columnid="basicSettings">'
			rowHTML += '<div class="keyValuePair dbType">'+'<label>DB Type:</label><span></span>'+'</div>'
			rowHTML += '<div class="keyValuePair formType">'+'<label>Form Type:</label><span></span>'+'</div>'
			rowHTML += '<div class="keyValuePair defaultValue">'+'<label>Default Value:</label><span></span>'+'</div>'
			rowHTML += '<div class="keyValuePair widgetName">'+'<label>Widget Name:</label><span></span>'+'</div>'
			rowHTML += '<div class="keyValuePair multipleValues">'+'<label>Multiple Values:</label><span></span>'+'</div>'
		rowHTML += '</td>'
		rowHTML += '<td class="formVisibilitySettingsCell" columnid="formVisibilitySettings"></td>'
		rowHTML += '<td class="advancedSettingsCell" columnid="advancedSettings">'
			rowHTML += '<div class="shortlist advancedSettingsShortlist"></div>'
		rowHTML += '</td>'
		rowHTML += '<td class="lookupSettingsCell" columnid="lookupSettings">'
			rowHTML += '<div class="keyValuePair lookupSource">'+'<label>Source:</label><span></span>'+'</div>'
			rowHTML += '<div class="keyValuePair lookupFieldGroup">'+'<label>Field Group:</label><span></span>'+'</div>'
			rowHTML += '<div class="noLookup">N/A</div>'
		rowHTML += '</td>'
		rowHTML += '<td class="dropdownOptionsSettingsCell" columnid="dropdownOptionsSettings">'
			rowHTML += '<div class="shortlist dropdownOptionsShortlist"></div>'
		rowHTML += '</td>'
		if($('table#objectFieldsTable').hasClass('objectFieldsTable_commonPoolOfDropdowns')){
			rowHTML += '<td class="disabledCommonPoolFieldTD">';
			rowHTML += '<input type="checkbox" name="isDisabled_'+id+'" id="isDisabled_'+id+'" class="css-checkbox commonPoolField_disabled"><label class="css-label" for="isDisabled_'+id+'"></label>'
			rowHTML += '</td>'
		}
		rowHTML += '<td class="rightSpecialCell"><button class="removeFieldButton"></button></td>'
	rowHTML += '</tr>'
	$('#objectFieldsTable > tbody').append(rowHTML)

	// Generate the Basic Settings details row
	var rowHTML = ""
	rowHTML += '<tr class="detailsRow" baserowid="'+id+'" columnid="basicSettings">'
		rowHTML += '<td class="detailsRowTD" colspan="7">'
			rowHTML += '<div class="settingsRow">'
				rowHTML += '<div class="dbType"><label for="dbType_'+id+'">DB Type:</label><div class="select-style"><select name="dbType_'+id+'" id="dbType_'+id+'" jsonfield="databaseType">'
					rowHTML += '<option value="text">Text</option>'
					rowHTML += '<option value="date">Date</option>'
					rowHTML += '<option value="actual_number">Number</option>'
					//rowHTML += '<option value="bool">Bool</option>'
				rowHTML += '</select></div></div>'
				rowHTML += '<div class="formType"><label for="formType_'+id+'">Form Type:</label><div class="select-style"><select name="formType_'+id+'" id="formType_'+id+'" jsonfield="formType">'
					rowHTML += '<option value="text">Text</option>'
					rowHTML += '<option value="textarea">Text Area</option>'
					rowHTML += '<option value="date">Date</option>'
					rowHTML += '<option value="select">Dropdown</option>'
					rowHTML += '<option value="checkbox">Checkbox</option>'
					rowHTML += '<option value="file">File</option>'
					//rowHTML += '<option value="widget">Widget</option>'
					//rowHTML += '<option value="multiText">Multi Text</option>'
				rowHTML += '</select></div></div>'
				rowHTML += '<div class="isRequired"><input type="checkbox" name="isRequired_'+id+'" id="isRequired_'+id+'" class="css-checkbox" jsonfield="required"><label class="css-label" for="isRequired_'+id+'">Required</label></div>'
			rowHTML += '</div>'
			rowHTML += '<div class="settingsRow">'
				rowHTML += '<div class="defaultValue"><label for="defaultValue_'+id+'">Default Value:</label><input type="text" name="defaultValue_'+id+'" jsonfield="defaultValue"></div>'
				rowHTML += '<div class="fillWithDate"><div class="fillWithDate_text">Populate with date</div><input type="text" placeholder="# of Days" jsonfield="autoPopulateField_days"><div class="fillWithDate_text">days</div><select class="autoPopulateField_beforeOrAfter" jsonfield="autoPopulateField_beforeOrAfter"><option value="">-select-</option><option value="before">before</option><option value="after">after</option></select></div>' // Pick up here - Fill w/ Date
			rowHTML += '</div>'
			//rowHTML += '<div class="settingsRow">'
				//rowHTML += '<div class="widgetName"><label for="widgetName_'+id+'">Widget Name:</label><input type="text" name="widgetName_'+id+'" jsonfield="widgetName"></div>'
			//rowHTML += '</div>'
			rowHTML += '<div class="settingsRow multipleValuesSettingsRow">'
				rowHTML += '<div class="multipleValues">'
					rowHTML += '<input type="checkbox" name="multipleValues_field_'+id+'" id="multipleValues_field_'+id+'" class="css-checkbox" jsonfield="multipleValues"><label class="css-label" for="multipleValues_field_'+id+'">Multiple Values</label>'
				rowHTML += '</div>'
				rowHTML += '<div class="multipleValues_minValues">'
					rowHTML += '<label for="multipleValues_minValues_field_'+id+'">Min. # of Values:</label><input type="text" placeholder="#" jsonfield="multipleValues_minValues">'
				rowHTML += '</div>'
				rowHTML += '<div class="multipleValues_maxValues">'
					rowHTML += '<label for="multipleValues_maxValues_field_'+id+'">Max. # of Values:</label><input type="text" placeholder="#" jsonfield="multipleValues_maxValues">'
				rowHTML += '</div>'
			rowHTML += '</div>'
		rowHTML += '</td>'
	rowHTML += '</tr>'
	$('#objectFieldsTable > tbody').append(rowHTML)

	// Generate the Advanced Settings details row
	var rowHTML = ""
	rowHTML += '<tr class="detailsRow" baserowid="'+id+'" columnid="advancedSettings">'
		rowHTML += '<td class="detailsRowTD" colspan="7">'
			rowHTML += '<div class="advancedSettings advancedSettings_left">'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="inSearch" name="inSearch_'+id+'" id="inSearch_'+id+'"><label for="inSearch_'+id+'" class="checkboxLabel css-label">Display in search</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="inImport" name="inImport_'+id+'" id="inImport_'+id+'"><label for="inImport_'+id+'" class="checkboxLabel css-label">Display in import</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="inTable" name="inTable_'+id+'" id="inTable_'+id+'"><label for="inTable_'+id+'" class="checkboxLabel css-label">Display field in Table view</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="isTableLink" name="isTableLink_'+id+'" id="isTableLink_'+id+'"><label for="isTableLink_'+id+'" class="checkboxLabel css-label">Is table link</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="isNameField" name="isNameField_'+id+'" id="isNameField_'+id+'"><label for="isNameField_'+id+'" class="checkboxLabel css-label">Is name field</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="isBarcodeField" name="isBarcodeField_'+id+'" id="isBarcodeField_'+id+'"><label for="isBarcodeField_'+id+'" class="checkboxLabel css-label">Is barcode field</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="isAmountField" name="isAmountField_'+id+'" id="isAmountField_'+id+'"><label for="isAmountField_'+id+'" class="checkboxLabel css-label">Is amount field</label><br />'
			rowHTML += '</div>'
			rowHTML += '<div class="advancedSettings advancedSettings_right">'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="isAmountUnitField" name="isAmountUnitField_'+id+'" id="isAmountUnitField_'+id+'"><label for="isAmountUnitField_'+id+'" class="checkboxLabel css-label">Is amount unit field</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="isLookupField" name="isLookupField_'+id+'" id="isLookupField_'+id+'"><label for="isLookupField_'+id+'" class="checkboxLabel css-label">Is lookup/search field</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="isUnique" name="isUnique_'+id+'" id="isUnique_'+id+'"><label for="isUnique_'+id+'" class="checkboxLabel css-label">Must be unique</label><br />'			
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="required" name="required_'+id+'" id="required_'+id+'"><label for="required_'+id+'" class="checkboxLabel css-label">Is required</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="isHidden" name="isHidden_'+id+'" id="isHidden_'+id+'"><label for="isHidden_'+id+'" class="checkboxLabel css-label">Is hidden</label><br />'
				//rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="hideFieldWithCSS" name="hideFieldWithCSS_'+id+'" id="hideFieldWithCSS_'+id+'"><label for="hideFieldWithCSS_'+id+'" class="checkboxLabel css-label">Is hidden with CSS</label><br />'
				//rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="hideLabel" name="hideLabel_'+id+'" id="hideLabel_'+id+'"><label for="hideLabel_'+id+'" class="checkboxLabel css-label">Hidden label</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="disableOnEdit" name="disableOnEdit_'+id+'" id="disableOnEdit_'+id+'"><label for="disableOnEdit_'+id+'" class="checkboxLabel css-label">View Only</label><br />'
				rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="textOnOther" name="textOnOther_'+id+'" id="textOnOther_'+id+'"><label for="textOnOther_'+id+'" class="checkboxLabel css-label">Show textbox when "Other" is selected(From drop-down)</label><br />'
				//rowHTML += '<input type="checkbox" class="css-checkbox" jsonfield="conditional" name="conditional_'+id+'" id="conditional_'+id+'"><label for="conditional_'+id+'" class="checkboxLabel css-label">Is conditional</label><br />'
			rowHTML += '</div>'
			rowHTML += '<div class="advancedSettings advancedSettings_javascriptContainer">'
				rowHTML += '<label for="templateFieldJS_'+id+'">JavaScript to run on page load:</label>'
				rowHTML += '<textarea name="templateFieldJS_'+id+'" class="templateFieldJStextarea" jsonfield="templateFieldJS" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>'
			rowHTML += '</div>'
		rowHTML += '</td>'
	rowHTML += '</tr>'
	$('#objectFieldsTable > tbody').append(rowHTML)




	// Generate the Lookup details row
	var rowHTML = ""
	rowHTML += '<tr class="detailsRow" baserowid="'+id+'" columnid="lookupSettings">'
		rowHTML += '<td class="detailsRowTD" colspan="7">'
			rowHTML += '<div class="settingsRow lookupSettingsRow">'
				rowHTML += '<div class="lookupSourceApp"><label for="lookupSourceApp_'+id+'">Lookup source:</label><div class="select-style"><select name="lookupSourceApp_'+id+'" id="lookupSourceApp_'+id+'" class="lookupSourceAppDropdown" jsonfield="lookupSourceApp">'
					rowHTML += '<option value="">--select--</option>'
					rowHTML += '<option value="reg">Registration</option>'
				rowHTML += '</select></div></div>'
				rowHTML += '<div class="lookupRegField"><label for="lookupRegField_'+id+'">Reg field group:</label><div class="select-style"><select name="lookupRegField_'+id+'" id="lookupRegField_'+id+'" class="lookupRegFieldDropdown" jsonfield="lookupRegField">'
				rowHTML += '</select></div></div>'
			rowHTML += '</div>'
			rowHTML += '<div class="settingsRow lookupFieldMultiselects">'
				rowHTML += '<div class="addTheseRegFieldsContainer">'
					rowHTML += '<label class="addTheseRegFieldsLabel regLookupFieldsElements">Add These Reg Fields:</label>'
					rowHTML += '<select class="lookupRegFieldsToAdd" jsonfield="lookupRegFieldsToAdd" multiple></select>'
				rowHTML += '</div>'
				rowHTML += '<div class="columnsInTypeaheadContainer">'
					rowHTML += '<label class="columnsInTypeaheadLabel regLookupFieldsElements">Columns in Typeahead:</label>'
					rowHTML += '<select class="columnsInTypeahead" jsonfield="columnsInTypeahead" multiple></select>'
				rowHTML += '</div>'
			rowHTML += '</div>'
		rowHTML += '</td>'
	rowHTML += '</tr>'
	$('#objectFieldsTable > tbody').append(rowHTML)


	// Generate the Dropdown Options details row
	var rowHTML = ""
	rowHTML += '<tr class="detailsRow" baserowid="'+id+'" columnid="dropdownOptionsSettings">'
		rowHTML += '<td class="detailsRowTD" colspan="7">'
			rowHTML += '<table class="dropdownOptionsTable">'
				rowHTML += '<thead>'
					rowHTML += '<tr>'
						rowHTML += '<th>Option Value</th>'
						rowHTML += '<th>Option ID</th>'
						rowHTML += '<th>Cond. Fields Triggered</th>'
						rowHTML += '<th>Enabled Options</th>'
						rowHTML += '<th></th>'
					rowHTML += '</tr>'
				rowHTML += '</thead>'
				rowHTML += '<tbody></tbody>'
			rowHTML += '</table>'
			rowHTML += '<div class="clickPreventionMask"></div><div class="addOptionButton"><div class="addOptionButton_plus">+</div><div class="addOptionButton_text">Add Option</div></div>'
			rowHTML += '<div class="importOptionsContainer"><div class="select-style select-style-medium commonPoolDropdownsDropdownHolder"><select class="commonPoolDropdownsDropdown">'
				rowHTML += window.commonPoolOfDropdowns_dropdownHTML;
			rowHTML += '</select></div><button class="importOptionsFromCommonPoolButton">Import Options</button><input type="checkbox" class="css-checkbox keepOptionsSyncedCheckbox" name="keepOptionsSynced_'+id+'" id="keepOptionsSynced_'+id+'"><label for="keepOptionsSynced_'+id+'" class="checkboxLabel css-label">Keep Synced</label></div>'
			rowHTML += '<button class="saveDropdownOptions">Save Dropdown Options</button>'
		rowHTML += '</td>'
	rowHTML += '</tr>'
	$('#objectFieldsTable > tbody').append(rowHTML)

	// Generate the Form Visibility details row
	var rowHTML = ""
	rowHTML += '<tr class="detailsRow" baserowid="'+id+'" columnid="formVisibilitySettings">'
		rowHTML += '<td class="detailsRowTD" colspan="7">'
			rowHTML += '<div class="settingsRow">'
				rowHTML += '<div class="checkboxContainer"><input type="checkbox" class="css-checkbox" jsonfield="add" name="add_'+id+'" id="add_'+id+'" checked><label for="add_'+id+'" class="checkboxLabel css-label">Add</label></div>'
				rowHTML += '<div class="checkboxContainer"><input type="checkbox" class="css-checkbox" jsonfield="edit" name="edit_'+id+'" id="edit_'+id+'" checked><label for="edit_'+id+'" class="checkboxLabel css-label">Edit</label></div>'
				rowHTML += '<div class="checkboxContainer"><input type="checkbox" class="css-checkbox" jsonfield="view" name="view_'+id+'" id="view_'+id+'" checked><label for="view_'+id+'" class="checkboxLabel css-label">View</label></div>'
				rowHTML += '<div class="checkboxContainer"><input type="checkbox" class="css-checkbox" jsonfield="conditional" name="conditional_'+id+'" id="conditional_'+id+'"><label for="conditional_'+id+'" class="checkboxLabel css-label">Conditional (hidden until triggered by another field)</label></div>'
			rowHTML += '</div>'
		rowHTML += '</td>'
	rowHTML += '</tr>'
	$('#objectFieldsTable > tbody').append(rowHTML)

	return idNumberOnly.toString();
}

function removeField(){
	$(this).parent().remove();
}

function removeOption(that){
	$(that).parent().remove();
}

function makeJSON(){
	theJSON = {};
	theJSON["name"] = $("#objectName").val();
	theJSON["icon"] = $("input[name=icon]:checked").val();
	theJSON["active"] = $("#active").prop("checked");
	theJSON["hasStructure"] = $("#hasStructure").prop("checked");
	theJSON["canAdd"] = $("#canAdd").prop("checked");
	theJSON["canSample"] = $("#canSample").prop("checked");
	theJSON["canEdit"] = $("#canEdit").prop("checked");
	theJSON["canUse"] = $("#canUse").prop("checked");
	theJSON["canMove"] = $("#canMove").prop("checked");
	theJSON["canCheck"] = $("#canCheck").prop("checked");
	theJSON["canDispose"] = $("#canDispose").prop("checked");
	theJSON["canImport"] = $("#canImport").prop("checked");
	theJSON["showTable"] = $("#showTable").prop("checked");
	theJSON["restrictAccess"] = $("#restrictAccess").prop("checked");
	theJSON["fieldGroups"] = window.fieldGroupsObject;

	var labelPrintingSettingsObject = {};
	labelPrintingSettingsObject['labelLayoutId'] = $('#labelPrintingSettingsLayoutDropdown option:selected').attr('layoutid');
	$("table#objectFieldsLabelPrintingSettingsTable tbody tr").each(function(){
		var lineNumberLabelKey = "line" + $(this).attr('linenumber') + "Label";
		var lineLabel = $(this).find('select.fieldNameDropdown_labelPrinting option:selected').text();
		if(lineLabel == "-- Leave Blank --"){
			lineLabel = "";
		}
		labelPrintingSettingsObject[lineNumberLabelKey] = lineLabel;
	});
	theJSON["labelPrintingSettings"] = labelPrintingSettingsObject;
	
	groupIds = [];
	a = document.getElementById("groupIds").value.split(",")
	for (var i=0;i<a.length;i++){
		if (a[i]!=""){
			groupIds.push(parseInt(a[i]))
		}
	}
	userIds = [];
	a = document.getElementById("userIds").value.split(",")
	for (var i=0;i<a.length;i++){
		if (a[i]!=""){
			userIds.push(parseInt(a[i]))
		}
	}
	theJSON["restrictedGroupIds"] = groupIds;
	theJSON["restrictedUserIds"] = userIds;
	fieldList = [];
	$('#objectFieldsTable .baseRow').each(function(i,el){
		var baseRowId = $(this).attr('baserowid');

		field = {};
		field["fieldName"] = $('[baserowid="'+baseRowId+'"] [jsonField=fieldName]').val()
		field["databaseType"] = $('[baserowid="'+baseRowId+'"] [jsonField=databaseType]').val()
		field["formType"] = $('[baserowid="'+baseRowId+'"] [jsonField=formType]').val()
		field["defaultValue"] = $('[baserowid="'+baseRowId+'"] [jsonField=defaultValue]').val()
		field["widgetName"] = $('[baserowid="'+baseRowId+'"] [jsonField=widgetName]').val()

		field['fieldGroupId'] = $('[baserowid="'+baseRowId+'"] [jsonField=fieldGroupId]').val()

		field["multipleValues"] = $('[baserowid="'+baseRowId+'"] [jsonField=multipleValues]').prop("checked")
		field["multipleValues_minValues"] = $('[baserowid="'+baseRowId+'"] [jsonField=multipleValues_minValues]').val()
		field["multipleValues_maxValues"] = $('[baserowid="'+baseRowId+'"] [jsonField=multipleValues_maxValues]').val()

		if(!$('[baserowid="'+baseRowId+'"][columnid="dropdownOptionsSettings"] .keepOptionsSyncedCheckbox').prop("checked")){
			options = []
			optionIds = {}
			$('[baserowid="'+baseRowId+'"] .optionValueInput').each(function(i,el){
				options.push($(el).val());
				optionIds[$(el).val()] = $(el).parent().parent().parent().find('input.optionIdInput').val();
			});
			field["options"] = options;
			field["optionIds"] = optionIds;
		}
		else{
			// The options & optionIds will come from the dropdown that it's synced with - add that dropdown ID to the JSON
			field["poolOfFields_dropdown_id"] = $('[baserowid="'+baseRowId+'"] select.commonPoolDropdownsDropdown').val();
			field["options"] = [];
			field["optionIds"] = {};
		}

		field["autoPopulateField_days"] = $('[baserowid="'+baseRowId+'"] [jsonField=autoPopulateField_days]').val();
		field["autoPopulateField_beforeOrAfter"] = $('[baserowid="'+baseRowId+'"] [jsonField=autoPopulateField_beforeOrAfter]').val();
		field["inSearch"] = $('[baserowid="'+baseRowId+'"] [jsonField=inSearch]').prop("checked");
		field["inImport"] = $('[baserowid="'+baseRowId+'"] [jsonField=inImport]').prop("checked");
		field["required"] = $('[baserowid="'+baseRowId+'"] [jsonField=required]').prop("checked");
		field["isUnique"] = $('[baserowid="'+baseRowId+'"] [jsonField=isUnique]').prop("checked");
		field["inTable"] = $('[baserowid="'+baseRowId+'"] [jsonField=inTable]').prop("checked");
		field["isTableLink"] = $('[baserowid="'+baseRowId+'"] [jsonField=isTableLink]').prop("checked");
		field["isNameField"] = $('[baserowid="'+baseRowId+'"] [jsonField=isNameField]').prop("checked");
		field["isBarcodeField"] = $('[baserowid="'+baseRowId+'"] [jsonField=isBarcodeField]').prop("checked");
		field["isAmountField"] = $('[baserowid="'+baseRowId+'"] [jsonField=isAmountField]').prop("checked");
		field["isAmountUnitField"] = $('[baserowid="'+baseRowId+'"] [jsonField=isAmountUnitField]').prop("checked");
		field["isLookupField"] = $('[baserowid="'+baseRowId+'"] [jsonField=isLookupField]').prop("checked");
		field["lookupSourceApp"] = $('[baserowid="'+baseRowId+'"] [jsonField=lookupSourceApp]').val();
		field["lookupRegField"] = $('[baserowid="'+baseRowId+'"] [jsonField=lookupRegField]').val();
		field["templateFieldJS"] = $('[baserowid="'+baseRowId+'"] [jsonField=templateFieldJS]').val();
		field["lookupRegFieldsToAdd"] = $('[baserowid="'+baseRowId+'"] [jsonField=lookupRegFieldsToAdd]').val();
		field["columnsInTypeahead"] = $('[baserowid="'+baseRowId+'"] [jsonField=columnsInTypeahead]').val();
		field["isHidden"] = $('[baserowid="'+baseRowId+'"] [jsonField=isHidden]').prop("checked");
		field["hideLabel"] = $('[baserowid="'+baseRowId+'"] [jsonField=hideLabel]').prop("checked");
		field["hideFieldWithCSS"] = $('[baserowid="'+baseRowId+'"] [jsonField=hideFieldWithCSS]').prop("checked");
		field["disableOnEdit"] = $('[baserowid="'+baseRowId+'"] [jsonField=disableOnEdit]').prop("checked");
		field["textOnOther"] = $('[baserowid="'+baseRowId+'"] [jsonField=textOnOther]').prop("checked"); // INV-161
		conditionalFieldsAndOptionsToAdd = {}
		$('[baserowid="'+baseRowId+'"] table.dropdownOptionsTable > tbody > tr').each(function(){
			var fieldOptionId = $(this).find('.optionIdInput').val();
			fieldNamesAndOptions = {};
			selectedFieldNames = [];
			$(this).find('.conditionalFieldsDropdown > option:selected').each(function(){
				selectedFieldNames.push($(this).attr('value'));
			});
			selectedFieldOptionIds = [];
			$(this).find('.conditionalFieldsOptionsDropdown > option:selected').each(function(){
				selectedFieldOptionIds.push($(this).attr('value'));
			});
			fieldNamesAndOptions["fieldNames"] = selectedFieldNames;
			fieldNamesAndOptions["fieldOptions"] = selectedFieldOptionIds;
			conditionalFieldsAndOptionsToAdd[fieldOptionId] = fieldNamesAndOptions;
		});
		field["conditionalFieldsAndOptions"] = conditionalFieldsAndOptionsToAdd;
	
		field["regFieldsMultiselect"] = $('[baserowid="'+baseRowId+'"] [jsonField=autoPopulateField_beforeOrAfter]').val();
		
		field["add"] = $('[baserowid="'+baseRowId+'"] [jsonField=add]').prop("checked");
		field["edit"] = $('[baserowid="'+baseRowId+'"] [jsonField=edit]').prop("checked");
		field["view"] = $('[baserowid="'+baseRowId+'"] [jsonField=view]').prop("checked");
		field["conditional"] = $('[baserowid="'+baseRowId+'"] [jsonField=conditional]').prop("checked");
		
		if(field['required'] == true && field['conditional'] == true){
			field['condRequired'] = true;
			field['required'] = false; // you never want required to be true for a conditional field because the backend will complain about the field even if it isn't visible
		}
		else{
			field['condRequired'] = false;
		}

		fieldList.push(field);
	});
	theJSON["fields"] = fieldList;
	return theJSON;
}

function loadJSON(o){
	$("#objectName").val(o["name"])
	$("input[name=icon][value='" + o["icon"] + "']").prop('checked',true);
	$("#active").prop("checked",o["active"]);
	$("#hasStructure").prop("checked",o["hasStructure"]);
	$("#canAdd").prop("checked",o["canAdd"]);
	$("#canSample").prop("checked",o["canSample"]);
	$("#canEdit").prop("checked",o["canEdit"]);
	$("#canUse").prop("checked",o["canUse"]);
	$("#canMove").prop("checked",o["canMove"]);
	$("#canCheck").prop("checked",o["canCheck"]);
	$("#canDispose").prop("checked",o["canDispose"]);
	$("#canImport").prop("checked",o["canImport"]);
	$("#showTable").prop("checked",o["showTable"]);
	$("#restrictAccess").prop("checked",o["restrictAccess"]);
	//show and hide users & user groups depending upon selection
	restrictAccessCheck(o["restrictAccess"]);
	
	if (o.hasOwnProperty("restrictedGroupIds")){
		$("#groupIds").val(o["restrictedGroupIds"].join(","));
	}
	if (o.hasOwnProperty("restrictedUserIds")){
		$("#userIds").val(o["restrictedUserIds"].join(","));
	}
	for(var i=0;i<o["fields"].length;i++){
		addField("field_"+i);
		if(typeof o["fields"][i]["poolOfFields_dropdown_id"] !== "undefined" && o["fields"][i]["poolOfFields_dropdown_id"] !== ""){
			$('[baserowid=field_'+i+"]").attr("poolOfFields_dropdown_id", o["fields"][i]["poolOfFields_dropdown_id"]); // Add attribute to baseRow & detailsRows
			$('[baserowid=field_'+i+"]").find('#isDisabled_field_'+i).prop("checked", o["fields"][i]["disabled"]); // If filling in the table that's used to manage the pool of common fields, toggle the checkbox that disables the field
			
			// If filling in the object type editing table, set the optionIds & options to the common pool dropdown's optionIds & options:
			if(!$('table.objectFieldsTable').hasClass('objectFieldsTable_commonPoolOfDropdowns')){
				$('[baserowid=field_'+i+"] select.commonPoolDropdownsDropdown option[value='"+o["fields"][i]["poolOfFields_dropdown_id"]+"']").prop('selected',true).change();
				// LINE ABOVE IS NOT WORKING - LINE BELOW ISN'T REALLY WORKING EITHER - MANUALLY ADD CLASS LIKE CHECKBOX WOULD DO AND FIX THE DROPDOWN LINE ABOVE
				var keepOptionsSyncedCB = $('[baserowid=field_'+i+"] .keepOptionsSyncedCheckbox");
			    var dropdownOptionsTableBody = $('[baserowid=field_'+i+"] .dropdownOptionsTable tbody");
			    var importOptionsButton = $('[baserowid=field_'+i+"] .importOptionsFromCommonPoolButton");
			    var detailsRow = $('[baserowid=field_'+i+"][columnid='dropdownOptionsSettings']");
				// This code is also used in loadJSON()...
				keepOptionsSyncedCB.attr("checked",true);
				dropdownOptionsTableBody.empty();
				importOptionsButton.click();
				detailsRow.addClass('keepOptionsSynced');
				detailsRow.find('.optionValueInput, .optionIdInput').prop('disabled',true);
			}
		}
		$('[baserowid=field_'+i+"] [jsonField=fieldName]").val(o["fields"][i]["fieldName"]);
		$('[baserowid=field_'+i+"] [jsonField=databaseType]").val(o["fields"][i]["databaseType"]);
		$('[baserowid=field_'+i+"] [jsonField=formType]").val(o["fields"][i]["formType"]);
		//enable disable advanced options depending upon formType
		formTypeCheck(o["fields"][i]["formType"], 'field_'+i);
		$('[baserowid=field_'+i+"] [jsonField=defaultValue]").val(o["fields"][i]["defaultValue"]);
		$('[baserowid=field_'+i+"] [jsonField=widgetName]").val(o["fields"][i]["widgetName"]);
		$('[baserowid=field_'+i+"] [jsonField=fieldGroupId]").val(o["fields"][i]["fieldGroupId"]);
		$('[baserowid=field_'+i+"] [jsonField=multipleValues]").prop("checked",o["fields"][i]["multipleValues"]);
		$('[baserowid=field_'+i+"] [jsonField=multipleValues_minValues]").val(o["fields"][i]["multipleValues_minValues"]);
		$('[baserowid=field_'+i+"] [jsonField=multipleValues_maxValues]").val(o["fields"][i]["multipleValues_maxValues"]);
		for(var j=0;j<o["fields"][i]["options"].length;j++){
			baseRowId = 'field_'+i;
			optionValue = o["fields"][i]["options"][j];
			optionId = "";
			if(typeof o["fields"][i]["optionIds"] !== "undefined"){
				optionId = o["fields"][i]["optionIds"][o["fields"][i]["options"][j]];
			}
			addOptionToField(baseRowId, optionValue, optionId);
		}
		$('[baserowid=field_'+i+"] [jsonField=autoPopulateField_days]").val(o["fields"][i]["autoPopulateField_days"]);
		$('[baserowid=field_'+i+"] [jsonField=autoPopulateField_beforeOrAfter]").val(o["fields"][i]["autoPopulateField_beforeOrAfter"]);
		$('[baserowid=field_'+i+"] [jsonField=inSearch]").prop("checked",o["fields"][i]["inSearch"]);
		$('[baserowid=field_'+i+"] [jsonField=inImport]").prop("checked",o["fields"][i]["inImport"]);
		$('[baserowid=field_'+i+"] [jsonField=required]").prop("checked",o["fields"][i]["required"]);
		$('[baserowid=field_'+i+"] [jsonField=isUnique]").prop("checked",o["fields"][i]["isUnique"]);
		$('[baserowid=field_'+i+"] [jsonField=inTable]").prop("checked",o["fields"][i]["inTable"]);
		$('[baserowid=field_'+i+"] [jsonField=isTableLink]").prop("checked",o["fields"][i]["isTableLink"]);
		$('[baserowid=field_'+i+"] [jsonField=isNameField]").prop("checked",o["fields"][i]["isNameField"]);
		$('[baserowid=field_'+i+"] [jsonField=isBarcodeField]").prop("checked",o["fields"][i]["isBarcodeField"]);
		if(o["fields"][i]["isBarcodeField"]) {
			oneOfFourOptionsCheck(o["fields"][i]["isBarcodeField"], 'field_'+i, 'isBarcodeField')
		}
		$('[baserowid=field_'+i+"] [jsonField=isAmountField]").prop("checked",o["fields"][i]["isAmountField"]);
		if(o["fields"][i]["isAmountField"]) {
			oneOfFourOptionsCheck(o["fields"][i]["isAmountField"], 'field_'+i, 'isAmountField')
		}
		$('[baserowid=field_'+i+"] [jsonField=isAmountUnitField]").prop("checked",o["fields"][i]["isAmountUnitField"]);
		if(o["fields"][i]["isAmountUnitField"]) {
			oneOfFourOptionsCheck(o["fields"][i]["isAmountUnitField"], 'field_'+i, 'isAmountUnitField')
		}
		$('[baserowid=field_'+i+"] [jsonField=isLookupField]").prop("checked",o["fields"][i]["isLookupField"]);
		if(o["fields"][i]["isLookupField"]) {
			oneOfFourOptionsCheck(o["fields"][i]["isLookupField"], 'field_'+i, 'isLookupField')
		}
		$('[baserowid=field_'+i+"] [jsonField=lookupSourceApp]").val(o["fields"][i]["lookupSourceApp"]);
		$('[baserowid=field_'+i+"] [jsonField=lookupRegField]").attr("setvalueafterpageloads",o["fields"][i]["lookupRegField"]);
		$('[baserowid=field_'+i+"] [jsonField=templateFieldJS]").val(o["fields"][i]["templateFieldJS"]);
		$('[baserowid=field_'+i+"] [jsonField=lookupRegFieldsToAdd]").attr("setvalueafterpageloads",o["fields"][i]["lookupRegFieldsToAdd"]);
		$('[baserowid=field_'+i+"] [jsonField=columnsInTypeahead]").attr("setvalueafterpageloads",o["fields"][i]["columnsInTypeahead"]);
		$('[baserowid=field_'+i+"] [jsonField=columnsInTypeahead]").attr("lastvalidselection",o["fields"][i]["columnsInTypeahead"]);
		$('[baserowid=field_'+i+"] [jsonField=isHidden]").prop("checked",o["fields"][i]["isHidden"]);
		$('[baserowid=field_'+i+"] [jsonField=hideLabel]").prop("checked",o["fields"][i]["hideLabel"]);
		$('[baserowid=field_'+i+"] [jsonField=hideFieldWithCSS]").prop("checked",o["fields"][i]["hideFieldWithCSS"]);
		$('[baserowid=field_'+i+"] [jsonField=disableOnEdit]").prop("checked",o["fields"][i]["disableOnEdit"]);
		if(typeof o["fields"][i]["textOnOther"] == "undefined"){
			o["fields"][i]["textOnOther"] = false;
		}
		$('[baserowid=field_'+i+"] [jsonField=textOnOther]").prop("checked",o["fields"][i]["textOnOther"]);
		
		$('[baserowid=field_'+i+"] [jsonField=add]").prop("checked",o["fields"][i]["add"]);
		$('[baserowid=field_'+i+"] [jsonField=edit]").prop("checked",o["fields"][i]["edit"]);
		$('[baserowid=field_'+i+"] [jsonField=view]").prop("checked",o["fields"][i]["view"]);
		if(typeof o["fields"][i]["conditional"] == "undefined"){
			o["fields"][i]["conditional"] = false;
		}
		$('[baserowid=field_'+i+"] [jsonField=conditional]").prop("checked",o["fields"][i]["conditional"]);
		if(typeof o["fields"][i]["condRequired"] == "undefined"){
			o["fields"][i]["condRequired"] = false;
		}
		$('[baserowid=field_'+i+"] [jsonField=condRequired]").prop("checked",o["fields"][i]["condRequired"]);

		// If the field is conditional it can only ever have "condRequired" & not "required" so check the required box now and it will be corrected on save
		if(o["fields"][i]["conditional"] == true){
			$('[baserowid=field_'+i+"] [jsonField=required]").prop("checked",o["fields"][i]["condRequired"]);
		}

		populateBaseRow(i);
	}

	// Get the fields for the lookupRegField dropdown, add the fields to the dropdown, then set the dropdown values accordingly
	
	try{
		lookupSourceFieldNames = JSON.parse(restCall("/getFieldGroupNamesFromReg/","POST",{}));
		if(lookupSourceFieldNames['status'] == "success"){
			$('select[jsonfield="lookupRegField"]').append('<option value="">--select--</option>')
			$.each(lookupSourceFieldNames['results'],function(key, fieldGroup){
				$.each(fieldGroup,function(key, value){
					$('select[jsonfield="lookupRegField"]').append('<option value="'+key+'">'+value+'</option>')
				});
			});

			$('select[jsonfield="lookupRegField"]').each(function(){
				if($(this).attr('setvalueafterpageloads')){
					$(this).val($(this).attr('setvalueafterpageloads')).change()
				}
			});

			$('select[jsonfield="columnsInTypeahead"]').each(function(){
				if($(this).attr('setvalueafterpageloads')){
					$(this).val($(this).attr('setvalueafterpageloads').split(',')).change()
				}
			});

			for(var i=0;i<o["fields"].length;i++){ /* Need to run this again because the lookupRegField is populated now... Keep initial one, otherwise page loads in too slow */
				populateBaseRow(i)
			}
		}
	}
	catch(err){
		// Do nothing
	}

	updateAllThingsConditional();
	selectConditionalFieldsFromLastSave();
	populateObjectFieldsGroupingTable(true);

	// Check that stuff would be the same if you were to immediately hit Save after loading
	/*if( !o.is( $(makeJSON()) ) ){ Nevermind - moving on for now... Trying to check that JS objects are equal is hard...
		console.log(o);
		console.log(makeJSON())
		alert("WARNING: There may have been an issue while loading this Inventory item. Please notify Arxspan Support before saving your changes to avoid potential problems.");
	}*/
}

function populateBaseRow(baseRowId){
	console.log(baseRowId)

	// basicSettings
	if($('[baserowid="field_'+baseRowId+'"] [jsonfield="databaseType"]').val() !== ""){
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.dbType span').text( $('[baserowid="field_'+baseRowId+'"] [jsonfield="databaseType"] option:selected').text() ).parent().addClass('makeVisible');
	}
	else{
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.dbType').removeClass('makeVisible');
	}
	if($('[baserowid="field_'+baseRowId+'"] [jsonfield="formType"]').val() !== ""){
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.formType span').text( $('[baserowid="field_'+baseRowId+'"] [jsonfield="formType"] option:selected').text() ).parent().addClass('makeVisible');
	}
	else{
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.formType').removeClass('makeVisible');
	}
	if($('[baserowid="field_'+baseRowId+'"] [jsonfield="defaultValue"]').val() !== ""){
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.defaultValue span').text( $('[baserowid="field_'+baseRowId+'"] [jsonfield="defaultValue"]').val() ).parent().addClass('makeVisible');
	}
	else{
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.defaultValue').removeClass('makeVisible');
	}
	if($('[baserowid="field_'+baseRowId+'"] [jsonfield="widgetName"]').val() !== ""){
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.widgetName span').text( $('[baserowid="field_'+baseRowId+'"] [jsonfield="widgetName"]').val() ).parent().addClass('makeVisible');
	}
	else{
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.widgetName').removeClass('makeVisible');
	}
	if($('[baserowid="field_'+baseRowId+'"] [jsonfield="multipleValues"]').prop("checked")){
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.multipleValues span').text("Yes").parent().addClass('makeVisible');
	}
	else{
		$('.baseRow[baserowid="field_'+baseRowId+'"] .basicSettingsCell .keyValuePair.multipleValues').removeClass('makeVisible');
	}

	// advancedSettings
	var advancedSettingsShortlist = [];
	arrayOfAdvancedSettings = ["inSearch","inImport","inTable","isTableLink","isNameField","isBarcodeField","isAmountField","isAmountUnitField","isLookupField","isUnique","required","isHidden","hideFieldWithCSS","hideLabel","disableOnEdit","textOnOther","conditional"]
	$.each(arrayOfAdvancedSettings, function(index, value){
		if( $('[baserowid="field_'+baseRowId+'"] [jsonfield="'+value+'"]').prop("checked") ){
			advancedSettingsShortlist.push(value)
		}
	});
	$('.baseRow[baserowid="field_'+baseRowId+'"] .advancedSettingsCell .shortlist.advancedSettingsShortlist').text(advancedSettingsShortlist.join(', '))

	// lookupSettings
	if( $('[baserowid="field_'+baseRowId+'"] [jsonfield="lookupSourceApp"]').val() !== "" && $('[baserowid="field_'+baseRowId+'"] [jsonfield="lookupRegField"]').val() !== ""){
		$('.baseRow[baserowid="field_'+baseRowId+'"] .lookupSettingsCell .keyValuePair.lookupSource span').text($('[baserowid="field_'+baseRowId+'"] [jsonfield="lookupSourceApp"] option:selected').text()).parent().addClass('makeVisible')
		$('.baseRow[baserowid="field_'+baseRowId+'"] .lookupSettingsCell .keyValuePair.lookupFieldGroup span').text($('[baserowid="field_'+baseRowId+'"] [jsonfield="lookupRegField"] option:selected').text()).parent().addClass('makeVisible')
		$('.baseRow[baserowid="field_'+baseRowId+'"] .lookupSettingsCell .noLookup').removeClass('makeVisible');
	}
	else{
		$('.baseRow[baserowid="field_'+baseRowId+'"] .lookupSettingsCell .keyValuePair').removeClass('makeVisible');
		$('.baseRow[baserowid="field_'+baseRowId+'"] .lookupSettingsCell .noLookup').addClass('makeVisible');
	}

	// dropdownOptionsSettings
	var optionsValuesArray = [];
	$('[baserowid="field_'+baseRowId+'"] .optionValueInput').each(function(){
		optionsValuesArray.push($(this).val())
	});
	if(optionsValuesArray.length == 0){
		$('.baseRow[baserowid="field_'+baseRowId+'"] .dropdownOptionsSettingsCell .shortlist.dropdownOptionsShortlist').text("No options added");
	}
	else{
		$('.baseRow[baserowid="field_'+baseRowId+'"] .dropdownOptionsSettingsCell .shortlist.dropdownOptionsShortlist').text(optionsValuesArray.join(', '));
	}

	// visibility
	var formVisibilityCellHTML = "";
	$('.detailsRow[baserowid="field_'+baseRowId+'"][columnid="formVisibilitySettings"] input[type="checkbox"]').each(function(){
		if( $(this).prop("checked") ){
			var visibilitySettingName = $(this).attr('jsonfield');
			formVisibilityCellHTML += '<div class="visibilitySettingNugget" visibilitysettingname="'+visibilitySettingName+'">' + visibilitySettingName + '</div>'; 
		}
	});
	$('.baseRow[baserowid="field_'+baseRowId+'"] .formVisibilitySettingsCell').html(formVisibilityCellHTML);

	// Whenever the item's fields are changed significantly, update the label printing table
	updateFieldNameDropdownHTML(); // update window.fieldNamesDropdownOptionsHTML
	updateFieldNameDropdownsInLabelPrintingSettingsTable(); // set up field name dropdowns
}

function showGroupPopup(){
	$.get("../_inclds/common/html/groupListStandAlone_styledCheckboxes.asp",(function (data){ 
		$('.objectAllowedGroupsUsers').html(data);
		D = {}
		groupIds = [];
		a = document.getElementById("groupIds").value.split(",")
		for (var i=0;i<a.length;i++){
			if (a[i]!=""){
				groupIds.push(a[i])
			}
		}
		userIds = [];
		a = document.getElementById("userIds").value.split(",")
		for (var i=0;i<a.length;i++){
			if (a[i]!=""){
				userIds.push(a[i])
			}
		}
		D["groupIds"] = groupIds;
		D["userIds"] = userIds;
		populatePerms_v2(D)
	}));
}

function populatePerms_v2(D){
	if (D!=""){
		if(D.hasOwnProperty("userIds")){
			for(var i=0;i<D["userIds"].length;i++){
				userChecks = document.getElementsByClassName("groupCheckUser");
				console.log(userChecks);
				for(var j=0;j<userChecks.length;j++){
					if(userChecks[j].getAttribute("userid")==D["userIds"][i]){
						el = userChecks[j];
						el.checked = true;
						//el.onclick();
						groupId = el.getAttribute("group");
						el = document.getElementById("groupListUsers-"+groupId)
						link = document.getElementById("expandGroupLink-"+groupId)
						el.style.display = "block";
						link.innerHTML = "&ndash;"
					}
				}
			}
		}
		if(D.hasOwnProperty("groupIds")){
			for(var i=0;i<D["groupIds"].length;i++){
				el = document.getElementById("listGroupCheckGroup-"+D["groupIds"][i]);
				el.checked = true;
				el.onclick();
			}
		}
	}
}

function setGroups_v2(){
	groupList = []
	userList = []
	allUserList = []
	groups = document.getElementsByClassName("groupCheck")
	for(i=0;i<=groups.length;i++){
		if (groups[i] != undefined){
			if (groups[i].checked){
				groupList.push(groups[i].getAttribute("group"))
				els = document.getElementsByClassName("groupCheckUser")
				for(j=0;j<=els.length;j++){
					if (els[j] != undefined){
						if (els[j].checked && els[j].getAttribute("group") == groups[i].getAttribute("group")){
							allUserList.push(els[j].getAttribute("userId"))
						}
					}
				}
			}
			else{
				els = document.getElementsByClassName("groupCheckUser")
				for(j=0;j<=els.length;j++){
					if (els[j] != undefined){
						if (els[j].checked && els[j].getAttribute("group") == groups[i].getAttribute("group")){
							userList.push(els[j].getAttribute("userId"))
							allUserList.push(els[j].getAttribute("userId"))
						}
					}
				}
			}
		}
	}
	document.getElementById("groupIds").value = groupList.join(",")
	document.getElementById("userIds").value = userList.join(",")
	document.getElementById("allUserIds").value = allUserList.join(",")
	document.getElementById("numUsers").innerHTML = userList.length;
	document.getElementById("numGroups").innerHTML = groupList.length;
}

function addFieldGroup(fieldGroupId){
	if(typeof fieldGroupId == "undefined"){
		fieldGroupId = makeAlphanumericId()
	}
	var blankRowHTML = '<tr fieldgroupid="'+fieldGroupId+'">'
	blankRowHTML += '<td columnname="groupName"><input type="text" jsonfield="fieldGroupName"></td>'
	blankRowHTML += '<td columnname="numberOfFields">0</td>'
	blankRowHTML += '<td columnname="delete"><button class="removeGroupButton"></button></td>'
	blankRowHTML += '</tr>'
	$('#objectFieldsGroupingTable tbody').append(blankRowHTML)
	return fieldGroupId;
}

function upsertFieldGroupToDropdowns(fieldGroupId, fieldGroupName){
	// If the field group is simply having its name updated, find the group in the list of options and change its display name - otherwise, add it to the dropdown
	$('#objectFieldsTable tbody tr.baseRow [jsonfield="fieldGroupId"]').each(function(){
		if($(this).find('option[value="'+fieldGroupId+'"]').length > 0){
			$(this).find('option[value="'+fieldGroupId+'"]').text(fieldGroupName);
		}
		else{
			$(this).append('<option value="'+fieldGroupId+'">'+fieldGroupName+'</option>');
		}
	});
}

function populateObjectFieldsGroupingTable(loadFromSavedSettings){
	$('#objectFieldsGroupingTable tbody').empty();
	if(window.fieldGroupsObject.length > 0){
		$.each(window.fieldGroupsObject,function(index, fieldGroup){
			addFieldGroup(fieldGroup['fieldGroupId']);
			upsertFieldGroupToDropdowns(fieldGroup['fieldGroupId'], fieldGroup['fieldGroupName']);
			thisFieldGroupRow = $('#objectFieldsGroupingTable tbody tr:last-of-type');
			thisFieldGroupRow.find('td[columnname="groupName"] input[type="text"][jsonfield="fieldGroupName"]').val(fieldGroup['fieldGroupName']);
			// Look at each field in the object fields table
			var fieldsInThisGroup = 0;
			$('#objectFieldsTable tbody tr.baseRow [jsonfield="fieldGroupId"]').each(function(){
				if(fieldGroup['fieldGroupId'] == $(this).val()){
					fieldsInThisGroup++;
				}
			});
			thisFieldGroupRow.find('td[columnname="numberOfFields"]').text(fieldsInThisGroup);
		});
	}
	else{
		$('#objectFieldsGroupingTable tbody').append('<tr><td colspan="3">'+'<div class="noFieldGroupsMessage">There are no field groups for this object.</div>'+'</td></tr>');
	}
	if(loadFromSavedSettings){
		$('#labelPrintingSettingsLayoutDropdown option[layoutid="' + window.mostRecentSavedObjectData['labelPrintingSettings']['labelLayoutId'] + '"]').prop('selected',true).change();
		$('table#objectFieldsLabelPrintingSettingsTable tbody tr').each(function(){
			var domLineNumber = $(this).attr('linenumber'); // Ex: "1"
			var lineLabel = window.mostRecentSavedObjectData['labelPrintingSettings']['line'+domLineNumber+'Label'] // Ex: "Quantity Weighed"
			$(this).find('select.fieldNameDropdown_labelPrinting option').each(function(){ // Go through each option, find the one w/ .text() that matches the JSON value
				if($(this).text() == lineLabel){
					$(this).prop('selected',true);
					return false;
				}
			});
		});
	}
}

function commonPoolOfDropdowns_makeDropdownHTML(commonPoolOfDropdowns){
	var dropdownHTML = "";
	$.each(commonPoolOfDropdowns,function(index, dropdown){
		console.log(dropdown);
		dropdownHTML += '<option value="'+dropdown['poolOfFields_dropdown_id']+'">'+dropdown['fieldName']+'</option>'
	});
	return dropdownHTML;
}






