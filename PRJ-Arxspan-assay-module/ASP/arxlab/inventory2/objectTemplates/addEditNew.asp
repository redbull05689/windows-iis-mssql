<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Inventory"
isObjectTemplates = true
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header.asp"-->
<%If session("invRoleName") = "Admin" Then%>
<style type="text/css">
	.fieldDiv{
		background-color:white;
		margin-bottom:10px;
		position:relative;
	}
	.fieldDiv div{
		float:left;
		padding-left:6px;
	}
	.optionsDiv{
		overflow-y:visible;
		height:180px;
		width:454px;
	}
	.holderDiv{
		display:block;
		float:none!important;
	}
	.closeLink{
		position:absolute;
		top:0;
		right:0;
	}
    option.avatar {
      background-repeat: no-repeat !important;
      padding-left: 20px;
    }
    .avatar .ui-icon {
      background-position: left top;
    }
</style>
<h1>Edit Object Type</h1>
<script type="text/javascript">

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
//browser plugin that broke scrolling because it was missing
function updateAllThingsConditional(){
	var allConditionalFieldsByName = [];
	var allConditionalFieldOptionsByFieldName = {};
	$('.fieldDiv.sortable').each(function(){
		var fieldIsConditional = $(this).find('input[jsonfield="conditional"]').prop("checked");
		var fieldName = $(this).find('input[type="text"][jsonfield="fieldName"]').val();
		var fieldType = $(this).find('select[jsonfield="formType"]').val();
		if(fieldIsConditional == true){
			if(fieldType == "select"){
				allConditionalFieldsByName.push(fieldName);
				fieldOptions = {};
				$(this).find('.optionsDiv > #test > input[jsonfield="anOption"]').each(function(){
					var optionName = $(this).val();
					var optionId = $(this).siblings('.fieldOptionId').val();
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
	$('.fieldDiv.sortable').each(function(){
		var fieldName = $(this).find('input[type="text"][jsonfield="fieldName"]').val();
		var fieldType = $(this).find('select[jsonfield="formType"]').val();
		conditionalFieldsDropdown_modified = jQuery.grep(allConditionalFieldsByName, function(value) {
											  return value != fieldName;
											});
		conditionalFieldsDropdown_modified_HTML = "";
		$(conditionalFieldsDropdown_modified).each(function(){
			conditionalFieldsDropdown_modified_HTML += '<option value="' + this + '">' + this + '</option>';
		});
		$(this).find('.conditionalFieldsDropdown').html(conditionalFieldsDropdown_modified_HTML);
	});
}

// Look for changes in every field's list of conditionalFields so that options can be added & removed
$('body').on('change','.conditionalFieldsDropdown',function(event){
	var fieldsDropdown = $(this);
	var optionsDropdown = $(this).siblings('.conditionalFieldsOptionsDropdown');

	// Make list of all the field options to put in - start by getting the selected fields
	var allSelectedFields = []
	fieldsDropdown.find('option:selected').each(function(){
		allSelectedFields.push($(this).attr('value'));
	});
	// Now that we have all the selected fields by name, go to each field and get all their options and throw them in the list
	var allOptionsFromSelectedFields = [];
	$('.fieldDiv.sortable').each(function(){
		var fieldName = $(this).find('input[type="text"][jsonfield="fieldName"]').val();
		if($.inArray(fieldName, allSelectedFields) > -1){
			$(this).find('.optionsDiv > #test > input.fieldOptionId').each(function(){
				allOptionsFromSelectedFields.push($(this).val());
			});
		}
	});

	// Build list of currently selected field options
	var currentlySelectedOptions = [];
	optionsDropdown.find('option:selected').each(function(){
		currentlySelectedOptions.push($(this).attr('value'))
	});

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


$('body').on('change','select[jsonfield="lookupRegField"]',function(event){
	var lookupRegFieldGroupId = $(this).val();
	if(lookupRegFieldGroupId !== ""){
		var lookupRegFieldNames = JSON.parse(restCall("/getFieldNamesFromReg/","POST",{"regFieldGroupId":lookupRegFieldGroupId}));
		if(lookupRegFieldNames['status'] == "success"){
			var fieldNamesHTML = "";
			$.each(lookupRegFieldNames['results'],function(actualField,displayName){
				fieldNamesHTML += '<option value="' + actualField + '">' + displayName + '</option>';
			});
			
			var lookupRegFieldsToAdd = $(this).siblings('[jsonfield="lookupRegFieldsToAdd"]');
			lookupRegFieldsToAdd.html(fieldNamesHTML)
			if(typeof lookupRegFieldsToAdd.attr('setvalueafterpageloads') !== "undefined"){
				lookupRegFieldsToAdd.val(lookupRegFieldsToAdd.attr('setvalueafterpageloads').split(','));
			}
			
			var columnsInTypeahead = $(this).siblings('[jsonfield="columnsInTypeahead"]');
			columnsInTypeahead.html(fieldNamesHTML)
			if(typeof columnsInTypeahead.attr('setvalueafterpageloads') !== "undefined"){
				columnsInTypeahead.val(columnsInTypeahead.attr('setvalueafterpageloads').split(','));
			}
			
			$(this).parent().find('.regLookupFieldsElements').addClass('makeVisible');
		}
	}
	else{
		// There's no reg field group selected - hide the fields to add
		$(this).parent().find('.regLookupFieldsElements').removeClass('makeVisible');
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

// Select the fields that are supposed to be selected
function selectConditionalFieldsFromLastSave(){
	$('.fieldDiv.sortable').each(function(){
		var fieldDiv = $(this);
		var fieldDiv_fieldName = $(this).find('input[type="text"][jsonfield="fieldName"]').val();
		$.each(window.mostRecentSavedObjectData['fields'],function(){
			if(fieldDiv_fieldName == this['fieldName']){
				var savedObjectData_field = this;
				fieldDiv.find('.optionsDiv > #test > .fieldOptionId').each(function(){
					var optionIdValue = $(this).val();
					var fieldNamesSelect = $(this).siblings('.conditionalFieldsDropdown');
					var fieldOptionsSelect = $(this).siblings('.conditionalFieldsOptionsDropdown')
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

function saveObject(){
	objectName = $("#objectName").val();
	pl = {}
	pl["object"] = makeJSON();
	<%if request.querystring("id") <> "" then%>
		pl["id"] = <%=request.querystring("id")%>
	<%end if%>
	r = restCall("/addEditObjectType/","POST",pl);
	window.location = "objectTemplates/index.asp";
}
fieldCounter = 0
function addField(id){
	fieldCounter += 1
	div = document.createElement("div");
	if (id){
		div.setAttribute("id",id)
	}
	div.className = "fieldDiv sortable";
	mainPropDiv = document.createElement("div");

	label = document.createElement("label");
	label.setAttribute("for","fieldName");
	label.appendChild(document.createTextNode("Field Name"))
	mainPropDiv.appendChild(label);
	input = document.createElement("input");
	input.setAttribute("type","text");
	input.setAttribute("name","fieldName");
	input.setAttribute("jsonField","fieldName");
	mainPropDiv.appendChild(input);


	label = document.createElement("label");
	label.setAttribute("for","databaseType");
	label.appendChild(document.createTextNode("Database Type"))
	mainPropDiv.appendChild(label);
	select = document.createElement("select");
	select.setAttribute("name","databaseType");
	select.setAttribute("jsonField","databaseType");
	option = document.createElement("option");
	option.setAttribute("value","text");
	option.appendChild(document.createTextNode("Text"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","date");
	option.appendChild(document.createTextNode("Date"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","actual_number");
	option.appendChild(document.createTextNode("Number"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","bool");
	option.appendChild(document.createTextNode("Bool"));
	select.appendChild(option);
	mainPropDiv.appendChild(select);

	label = document.createElement("label");
	label.setAttribute("for","formType");
	label.appendChild(document.createTextNode("Form Type"))
	mainPropDiv.appendChild(label);
	select = document.createElement("select");
	select.setAttribute("name","formType");
	select.setAttribute("jsonField","formType");
	option = document.createElement("option");
	option.setAttribute("value","text");
	option.appendChild(document.createTextNode("Text"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","textarea");
	option.appendChild(document.createTextNode("Text Area"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","date");
	option.appendChild(document.createTextNode("Date"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","select");
	option.appendChild(document.createTextNode("Drop Down"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","checkbox");
	option.appendChild(document.createTextNode("Check Box"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","file");
	option.appendChild(document.createTextNode("File"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","widget");
	option.appendChild(document.createTextNode("Widget"));
	select.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","multiText");
	option.appendChild(document.createTextNode("Multi Text"));
	select.appendChild(option);
	mainPropDiv.appendChild(select);

	label = document.createElement("label");
	label.setAttribute("for","defaultValue");
	label.appendChild(document.createTextNode("Default Value"))
	mainPropDiv.appendChild(label);
	input = document.createElement("input");
	input.setAttribute("type","text");
	input.setAttribute("name","defaultValue");
	input.setAttribute("jsonField","defaultValue");
	mainPropDiv.appendChild(input);

	label = document.createElement("label");
	label.setAttribute("for","widgetName");
	label.appendChild(document.createTextNode("Widget Name"))
	mainPropDiv.appendChild(label);
	input = document.createElement("input");
	input.setAttribute("type","text");
	input.setAttribute("name","widgetName");
	input.setAttribute("jsonField","widgetName");
	mainPropDiv.appendChild(input);

	div.appendChild(mainPropDiv);

	optionsDiv = document.createElement("div");
	optionsDiv.className = "optionsDiv";
	a = document.createElement("a");
	a.setAttribute("href","javascript:void(0);")
	a.setAttribute("name","addOption")
	a.appendChild(document.createTextNode("Add Option"));
	a.onclick= newOption;
	optionsDiv.appendChild(a);
	div.appendChild(optionsDiv);

	$(div).append('<div class="autoPopulateFieldContainer"><span>Fill w/ date </span><input type="text" class="autoPopulateField_days" jsonfield="autoPopulateField_days" placeholder="# of Days"> <select class="autoPopulateField_beforeOrAfter" jsonfield="autoPopulateField_beforeOrAfter"><option value="">-select-</option><option value="before">before</option><option value="after">after</option></select></div>')

	$(div).append('<div class="lookupDetailsBox"><label class="lookupSourceLabel">Lookup Source:</label><select class="lookupSourceApp" jsonfield="lookupSourceApp"><option value="">--select--</option><option value="reg">Registration</option></select><hr><label class="regFieldsMultiselectLabel">Reg Field Group:</label><select class="lookupRegField" jsonfield="lookupRegField"><option value="">--select--</option></select><hr class="regLookupFieldsElements"><label class="addTheseRegFieldsLabel regLookupFieldsElements">Add These Reg Fields:</label><select class="lookupRegFieldsToAdd regLookupFieldsElements" jsonfield="lookupRegFieldsToAdd" multiple></select><hr class="regLookupFieldsElements"><label class="columnsInTypeaheadLabel regLookupFieldsElements">Columns in Typeahead:</label><select class="columnsInTypeahead regLookupFieldsElements" jsonfield="columnsInTypeahead" multiple></select></div>')

	$(div).append('<div class="invFieldJavascriptCodeContainer"><label class="invFieldJavascriptCodeLabel">JavaScript Code:</label><textarea class="invFieldJavascriptCodeTextarea" jsonfield="templateFieldJS"></textarea></div>');

	checksDiv = document.createElement("div");

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","inSearch");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("In Search"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","inImport");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("In Import"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","required");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("Required"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","isUnique");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("isUnique"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","inTable");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("inTable"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","isTableLink");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("isTableLink"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","isNameField");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("isNameField"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","isBarcodeField");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("isBarcodeField"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","isAmountField");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("isAmountField"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","isAmountUnitField");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("isAmountUnitField"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","isLookupField");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("isLookupField"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);
	
	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","isHidden");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("isHidden"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","hideLabel");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("hideLabel"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","hideFieldWithCSS");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("hideFieldWithCSS"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","disableOnEdit");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("disableOnEdit"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","textOnOther");
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("textOnOther"))
	holderDiv.appendChild(span)
	checksDiv.appendChild(holderDiv);

	div.appendChild(checksDiv)

	stateDiv = document.createElement("div");

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","add");
	cb.checked = true;
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("Add"))
	holderDiv.appendChild(span)
	stateDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","edit");
	cb.checked = true;
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("Edit"))
	holderDiv.appendChild(span)
	stateDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","view");
	cb.checked = true;
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("View"))
	holderDiv.appendChild(span)
	stateDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","conditional");
	cb.checked = false;
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("Conditional"))
	holderDiv.appendChild(span)
	stateDiv.appendChild(holderDiv);

	holderDiv = document.createElement("div")
	holderDiv.className = "holderDiv";
	cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.setAttribute("jsonField","condRequired");
	cb.checked = false;
	holderDiv.appendChild(cb)
	span = document.createElement("span")
	span.appendChild(document.createTextNode("Req'd Cond"))
	holderDiv.appendChild(span)
	stateDiv.appendChild(holderDiv);

	div.appendChild(stateDiv);

	clearBR = document.createElement("br");
	clearBR.style.clear = "both";
	div.appendChild(clearBR);
	
	a = document.createElement("a");
	a.href= "javascript:void(0);";
	a.className = "closeLink"
	a.appendChild(document.createTextNode("X"))
	a.onclick = removeField;

	div.appendChild(a)

	document.getElementById("fieldHolder").appendChild(div);
}

function removeField(){
	$(this).parent().remove();
}

function newOption(optionText,that,optionId){
	htmlStr = "<div id='test'><input type='text' jsonField='anOption' "
	if(typeof optionText == "string"){
		htmlStr += 'value="'+optionText+'"'
	}
	htmlStr += ">";
	var optionIdValue = "";
	if(typeof optionId == "string"){
		optionIdValue += 'value="'+optionId+'"'
	}
	htmlStr += '<input type="text" ' + optionIdValue + ' class="fieldOptionId" placeholder="Option ID">'
	htmlStr += '<select class="conditionalFieldsDropdown" multiple></select>'
	htmlStr += '<select class="conditionalFieldsOptionsDropdown" multiple></select>'

	htmlStr += "<a href='javascript:void(0);' onclick='removeOption($(this))'>X</a></div>"
	el = this;
	if(that){
		el = that;
	}
	$(htmlStr).insertBefore($(el))
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
	$("#fieldHolder .fieldDiv").each(function(i,el){
		field = {};
		field["fieldName"] = $(el).find("[jsonField=fieldName]").val()
		field["databaseType"] = $(el).find("[jsonField=databaseType]").val()
		field["formType"] = $(el).find("[jsonField=formType]").val()
		field["defaultValue"] = $(el).find("[jsonField=defaultValue]").val()
		field["widgetName"] = $(el).find("[jsonField=widgetName]").val()

		options = []
		optionIds = {}
		$(el).find("[jsonField=anOption]").each(function(i,el){
			options.push($(el).val());
			optionIds[$(el).val()] = $(el).parent().find('input.fieldOptionId').val();
		});
		field["options"] = options;
		field["optionIds"] = optionIds;

		field["autoPopulateField_days"] = $(el).find("[jsonField=autoPopulateField_days]").val();
		field["autoPopulateField_beforeOrAfter"] = $(el).find("[jsonField=autoPopulateField_beforeOrAfter]").val();
		field["inSearch"] = $(el).find("[jsonField=inSearch]").prop("checked");
		field["inImport"] = $(el).find("[jsonField=inImport]").prop("checked");
		field["required"] = $(el).find("[jsonField=required]").prop("checked");
		field["isUnique"] = $(el).find("[jsonField=isUnique]").prop("checked");
		field["inTable"] = $(el).find("[jsonField=inTable]").prop("checked");
		field["isTableLink"] = $(el).find("[jsonField=isTableLink]").prop("checked");
		field["isNameField"] = $(el).find("[jsonField=isNameField]").prop("checked");
		field["isBarcodeField"] = $(el).find("[jsonField=isBarcodeField]").prop("checked");
		field["isAmountField"] = $(el).find("[jsonField=isAmountField]").prop("checked");
		field["isAmountUnitField"] = $(el).find("[jsonField=isAmountUnitField]").prop("checked");
		field["isLookupField"] = $(el).find("[jsonField=isLookupField]").prop("checked");
		field["lookupSourceApp"] = $(el).find("[jsonField=lookupSourceApp]").val();
		field["lookupRegField"] = $(el).find("[jsonField=lookupRegField]").val();
		field["templateFieldJS"] = $(el).find("[jsonField=templateFieldJS]").val();
		field["lookupRegFieldsToAdd"] = $(el).find("[jsonField=lookupRegFieldsToAdd]").val();
		field["columnsInTypeahead"] = $(el).find("[jsonField=columnsInTypeahead]").val();
		field["isHidden"] = $(el).find("[jsonField=isHidden]").prop("checked");
		field["hideLabel"] = $(el).find("[jsonField=hideLabel]").prop("checked");
		field["hideFieldWithCSS"] = $(el).find("[jsonField=hideFieldWithCSS]").prop("checked");
		field["disableOnEdit"] = $(el).find("[jsonField=disableOnEdit]").prop("checked");
		field["textOnOther"] = $(el).find("[jsonField=textOnOther]").prop("checked"); // INV-161
		conditionalFieldsAndOptionsToAdd = {}
		$(this).find('.optionsDiv > #test').each(function(){
			var fieldOptionId = $(this).find('.fieldOptionId').val();
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
	
		field['']
		field["regFieldsMultiselect"] = $(el).find("[jsonField=autoPopulateField_beforeOrAfter]").val();
		
		field["add"] = $(el).find("[jsonField=add]").prop("checked");
		field["edit"] = $(el).find("[jsonField=edit]").prop("checked");
		field["view"] = $(el).find("[jsonField=view]").prop("checked");
		field["conditional"] = $(el).find("[jsonField=conditional]").prop("checked");
		field["condRequired"] = $(el).find("[jsonField=condRequired]").prop("checked");

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
	if (o.hasOwnProperty("restrictedGroupIds")){
		$("#groupIds").val(o["restrictedGroupIds"].join(","));
	}
	if (o.hasOwnProperty("restrictedUserIds")){
		$("#userIds").val(o["restrictedUserIds"].join(","));
	}
	for(var i=0;i<o["fields"].length;i++){
		addField("field_"+i);
		$('#field_'+i+" [jsonField=fieldName]").val(o["fields"][i]["fieldName"]);
		$('#field_'+i+" [jsonField=databaseType]").val(o["fields"][i]["databaseType"]);
		$('#field_'+i+" [jsonField=formType]").val(o["fields"][i]["formType"]);
		$('#field_'+i+" [jsonField=defaultValue]").val(o["fields"][i]["defaultValue"]);
		$('#field_'+i+" [jsonField=widgetName]").val(o["fields"][i]["widgetName"]);
		for(var j=0;j<o["fields"][i]["options"].length;j++){
			if(typeof o["fields"][i]["optionIds"] !== "undefined"){
				newOption(o["fields"][i]["options"][j],$('#field_'+i+" [name=addOption]"),o["fields"][i]["optionIds"][o["fields"][i]["options"][j]])
			}
			else{
				newOption(o["fields"][i]["options"][j],$('#field_'+i+" [name=addOption]"))
			}
		}
		$('#field_'+i+" [jsonField=autoPopulateField_days]").val(o["fields"][i]["autoPopulateField_days"]);
		$('#field_'+i+" [jsonField=autoPopulateField_beforeOrAfter]").val(o["fields"][i]["autoPopulateField_beforeOrAfter"]);
		$('#field_'+i+" [jsonField=inSearch]").prop("checked",o["fields"][i]["inSearch"]);
		$('#field_'+i+" [jsonField=inImport]").prop("checked",o["fields"][i]["inImport"]);
		$('#field_'+i+" [jsonField=required]").prop("checked",o["fields"][i]["required"]);
		$('#field_'+i+" [jsonField=isUnique]").prop("checked",o["fields"][i]["isUnique"]);
		$('#field_'+i+" [jsonField=inTable]").prop("checked",o["fields"][i]["inTable"]);
		$('#field_'+i+" [jsonField=isTableLink]").prop("checked",o["fields"][i]["isTableLink"]);
		$('#field_'+i+" [jsonField=isNameField]").prop("checked",o["fields"][i]["isNameField"]);
		$('#field_'+i+" [jsonField=isBarcodeField]").prop("checked",o["fields"][i]["isBarcodeField"]);
		$('#field_'+i+" [jsonField=isAmountField]").prop("checked",o["fields"][i]["isAmountField"]);
		$('#field_'+i+" [jsonField=isAmountUnitField]").prop("checked",o["fields"][i]["isAmountUnitField"]);
		$('#field_'+i+" [jsonField=isLookupField]").prop("checked",o["fields"][i]["isLookupField"]);
		$('#field_'+i+" [jsonField=lookupSourceApp]").val(o["fields"][i]["lookupSourceApp"]);
		$('#field_'+i+" [jsonField=lookupRegField]").attr("setvalueafterpageloads",o["fields"][i]["lookupRegField"]);
		$('#field_'+i+" [jsonField=templateFieldJS]").val(o["fields"][i]["templateFieldJS"]);
		$('#field_'+i+" [jsonField=lookupRegFieldsToAdd]").attr("setvalueafterpageloads",o["fields"][i]["lookupRegFieldsToAdd"]);
		$('#field_'+i+" [jsonField=columnsInTypeahead]").attr("setvalueafterpageloads",o["fields"][i]["columnsInTypeahead"]);
		$('#field_'+i+" [jsonField=columnsInTypeahead]").attr("lastvalidselection",o["fields"][i]["columnsInTypeahead"]);
		$('#field_'+i+" [jsonField=isHidden]").prop("checked",o["fields"][i]["isHidden"]);
		$('#field_'+i+" [jsonField=hideLabel]").prop("checked",o["fields"][i]["hideLabel"]);
		$('#field_'+i+" [jsonField=hideFieldWithCSS]").prop("checked",o["fields"][i]["hideFieldWithCSS"]);
		$('#field_'+i+" [jsonField=disableOnEdit]").prop("checked",o["fields"][i]["disableOnEdit"]);
		if(typeof o["fields"][i]["textOnOther"] == "undefined"){
			o["fields"][i]["textOnOther"] = false;
		}
		$('#field_'+i+" [jsonField=textOnOther]").prop("checked",o["fields"][i]["textOnOther"]);
		
		$('#field_'+i+" [jsonField=add]").prop("checked",o["fields"][i]["add"]);
		$('#field_'+i+" [jsonField=edit]").prop("checked",o["fields"][i]["edit"]);
		$('#field_'+i+" [jsonField=view]").prop("checked",o["fields"][i]["view"]);
		if(typeof o["fields"][i]["conditional"] == "undefined"){
			o["fields"][i]["conditional"] = false;
		}
		$('#field_'+i+" [jsonField=conditional]").prop("checked",o["fields"][i]["conditional"]);
		if(typeof o["fields"][i]["condRequired"] == "undefined"){
			o["fields"][i]["condRequired"] = false;
		}
		$('#field_'+i+" [jsonField=condRequired]").prop("checked",o["fields"][i]["condRequired"]);
	}

	// Get the fields for the lookupRegField dropdown, add the fields to the dropdown, then set the dropdown values accordingly
	
	try{
		lookupSourceFieldNames = JSON.parse(restCall("/getFieldGroupNamesFromReg/","POST",{}));
		if(lookupSourceFieldNames['status'] == "success"){
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
		}
	}
	catch(err){
	// Do nothing
	}

	updateAllThingsConditional();
	selectConditionalFieldsFromLastSave();
}

$(function(){

    $('#fieldHolder').sortable({placeholder: "ui-state-highlight",helper:'clone'});
})

function showGroupPopup(){

	blackOn();
	popup = newPopup("permPopup");
	popup.style.width="300px"
	popup.style.height="300px"
	label = document.createElement("label");
	label.innerHTML = "Users";
	popup.appendChild(label);
	div = document.createElement("div");
	popup.appendChild(div);
	$.get("../_inclds/common/html/groupListStandAlone.asp",(function (div){ 
		return function (data){
		$(div).html(data);
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
		populatePerms(D)
	}})(div)
	);
	
	button = document.createElement("input");
	button.setAttribute("type","button");
	button.onclick = (function(){
		return function(){
			setGroups();
			el = document.getElementById("permPopup");
			el.parentNode.removeChild(el);
			blackOff();
		}
	})();
	button.setAttribute("value","OK");
	popup.appendChild(button);

	document.getElementById("contentTable").appendChild(popup);
	window.scroll(0,0);
}
</script>



<label for="objectName">* Name</label><input type="text" name="objectName" id="objectName">
<br/>
<label for="icon">* Icon</label>
<input type="radio" name="icon" value="flask.gif"><img src="images/treeIcons/flask.gif">
<input type="radio" name="icon" value="check.gif"><img src="images/treeIcons/check.gif">
<input type="radio" name="icon" value="checkedout.gif"><img src="images/treeIcons/checkedout.gif">
<input type="radio" name="icon" value="cylinder.gif"><img src="images/treeIcons/cylinder.gif">
<input type="radio" name="icon" value="disposed.gif"><img src="images/treeIcons/disposed.gif">
<input type="radio" name="icon" value="door.gif"><img src="images/treeIcons/door.gif">
<input type="radio" name="icon" value="freezer.gif"><img src="images/treeIcons/freezer.gif">
<input type="radio" name="icon" value="hierarchy.gif"><img src="images/treeIcons/hierarchy.gif">
<input type="radio" name="icon" value="lab.gif"><img src="images/treeIcons/lab.gif">
<input type="radio" name="icon" value="lock.gif"><img src="images/treeIcons/lock.gif">
<input type="radio" name="icon" value="plate.gif"><img src="images/treeIcons/plate.gif">
<input type="radio" name="icon" value="rack.gif"><img src="images/treeIcons/rack.gif">
<input type="radio" name="icon" value="mouse.gif"><img src="images/treeIcons/mouse.gif">
<input type="radio" name="icon" value="cage.gif"><img src="images/treeIcons/cage.gif">
<br/>
<input type="checkbox" id="active"><span>Active</span>
<br/>
<input type="checkbox" id="hasStructure"><span>Has Structure (works now?)</span>
<br/>
<input type="checkbox" id="canAdd"><span>Can Add Children</span>
<br/>
<input type="checkbox" id="canSample"><span>Can Sample (must have field called amount or volume)</span>
<br/>
<input type="checkbox" id="canEdit"><span>Can Edit</span>
<br/>
<input type="checkbox" id="canUse"><span>Can Use (must have field called amount or volume)</span>
<br/>
<input type="checkbox" id="canMove"><span>Can Move</span>
<br/>
<input type="checkbox" id="canCheck"><span>Can Check In/Out</span>
<br/>
<input type="checkbox" id="canDispose"><span>Can Dispose</span>
<br/>
<input type="checkbox" id="canImport"><span>Can Import (into object from the context menu)</span>
<br/>
<input type="checkbox" id="showTable"><span>Show as table when selected in tree</span>
<br/>
<input type="checkbox" id="restrictAccess"><span>Restrict Access</span>
<br/>
<a href="javascript:void(0)" onclick="showGroupPopup();toggleGroup(0);" class="groupSelectLink">Allowed Groups/Users</a>
<br/>
<input type="hidden" id="groupIds">
<input type="hidden" id="userIds">
<input type="hidden" id="allUserIds">
<input type="hidden" id="numUsers">
<input type="hidden" id="numGroups">

<input type="button" value="Add Field" onclick="addField()">
<div id="fieldHolder">

</div>
<input type="button" value="Add Field" onclick="addField()">
<br/>
<input type="button" value="Save" onclick="saveObject()">
<%If request.querystring("id") <> "" then%>
	<script type="text/javascript">
		$(document).ready(function() {
			r = restCall("/getObject/","POST",{"id":<%=request.querystring("id")%>});
			window.mostRecentSavedObjectData = r;
			loadJSON(r);			
		});
	</script>
<%End if%>
<%End if%>
<!-- #include file="../_inclds/footer.asp"-->