<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<style type="text/css">
	.amountBox{
		width:40px;
	}
	.equivalentsBox{
		width:40px;
	}
	#barcodeChooserTable th,#barcodeChooserTable td{
		text-align:center;
	}
	#barcodeChooserTable select{
		margin:auto;
	}
</style>

<%
	bcExtraCellsForBio = getCompanySpecificSingleAppConfigSetting("addExtraBarcodeCellsForBio", session("companyId"))
	'Check if this company is in the companySettings table, and if it is, set disableTypeahead to whatever's
	' in the database.
	companyId = session("companyId")
	disableTypeahead = 0
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT disableBarCodeTypeAhead FROM companySettings WHERE companyId = " & companyId & ";"
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		disableTypeahead = rec("disableBarCodeTypeAhead")
	End if
	rec.close
	Call disconnect
	
	useCompoundTrackingConfig = checkBoolSettingForCompany("useCompoundTrackingConfig", companyId)
%>

<script type="text/javascript">
blurTimeout = false;
bcUseEquiv = false;

<%if useCompoundTrackingConfig = 1 then%>
<!-- #include file="bcChooserConfigs/ds_ct_config.js"-->
<%else%>
<!-- #include file="bcChooserConfigs/default_config.js"-->
<%end if%>

var chooserFields_fieldNames = []
var chooserFields_searchAgainst = []
var chooserFields_inTypeahead = []
$.each(chooserFields, function(index, chooserField){
	chooserFields_fieldNames.push(chooserField['fieldName']);
	if(chooserField['searchAgainst'] == true){
		chooserFields_searchAgainst.push(chooserField['fieldName'])
	}
	if(chooserField['displayInTypeahead'] == true){
		chooserFields_inTypeahead.push(chooserField['fieldName'])
	}
});

//add flags to each field if not present. default false
for(var i=0;i<chooserFields.length;i++){
	flags = ["displayInTable","isVolumeField","isMassField","isStructureField","isReactantField","isReagentField","isSolventFields","isAmountField","isUnitsField","isNameField","isTabName","isAmountField","userAdded"];
	for (var j=0;j<flags.length;j++){
		if(!chooserFields[i].hasOwnProperty(flags[j])){
			chooserFields[i][flags[j]] = false;
		}
	}
}

bcStructureField = false;
bcAmountField = false;
bcUnitsField = false;
bcNameField = false;
bcTabNameField = false;
for(var i=0;i<chooserFields.length;i++){
	if(chooserFields[i]["isStructureField"]){
		bcStructureField = chooserFields[i];
	}
	if(chooserFields[i]["isAmountField"]){
		bcAmountField = chooserFields[i];
	}
	if(chooserFields[i]["isUnitsField"]){
		bcUnitsField = chooserFields[i];
	}
	if(chooserFields[i]["isNameField"]){
		bcNameField = chooserFields[i];
	}
	if(chooserFields[i]["isTabNameField"]){
		bcTabNameField = chooserFields[i];
	}
}

function makeBarcodeChooser(experimentType){
	
	// Disable the typeahead if disableTypeahead is set to 1 in the settings table.
	disableLookahead = <%=disableTypeahead%>

	console.log("Company ID is: " + "<%=session("companyId")%>")
	console.log((disableLookahead ? "Disabling typeahead" : "Enabling typeahead"))

	window.barcodeChooser_experimentType = experimentType;
	arxOneContainer = document.getElementById("arxOneContainer");
	table = document.createElement("table");
	table.className = "experimentsTable";
	table.setAttribute("id","barcodeChooserTable");
	if(experimentType==1){
		c = document.createElement("caption");
		c.style.textAlign = "right";
		a = document.createElement("a");
		a.href = "javascript:void(0);";
		a.onclick = toggleEquivalents;
		a.appendChild(document.createTextNode("Toggle Equivalents"));
		c.appendChild(a);
		table.appendChild(c);
	}
	tbody = document.createElement("tbody");
	tbody.appendChild(getHeaderRow(experimentType));
	table.appendChild(tbody);
	arxOneContainer.appendChild(table);

	// Fix for width of the barcode chooser in ELN popup
	$('#arxOneContainer').addClass('insidePopup');
	
	div = document.createElement("div");
	div.className = "fieldHolder fieldHolderAddNewGroup";

	// If we're disabling the typeahead, then use the old barcode chooser. I'm not
	// familiar enough with the new one to be able to divorce it from the typeahead
	// and this already had all of the logic for when the user hits Enter.
	if (disableLookahead) {

		bcHolder = document.createElement("div");
		bcHolder.className = "barcodeChooserBoxContainer";
		bc = document.createElement("input");
		bc.setAttribute("type","text");
		bc.setAttribute("id","barcodeChooserBox");
		bc.onkeypress= function(event){
			if (event.keyCode==13){
				payload = {};
				payload["rpp"] = 1;
				payload["action"] = "next";
				payload["collection"] = "inventoryItems";
				payload["list"] = true;
				query = {};
				query[chooserSearchField] = this.value.replace(/\n/,"");
				payload["query"] = query;
				restCallA("/getList/","POST",payload,function(r){
					if(r["forms"].length>0){
						fd = r["forms"][0];
						document.getElementById("barcodeChooserTable").getElementsByTagName("tbody")[0].appendChild(getResultTR(experimentType,fd));
						setRowInputVis();
					}else{
						alert("No match found.")
					}
					document.getElementById("barcodeChooserBox").value = "";
				})

			}
		}
		arxOneContainer.appendChild(bc);
		bc.focus();
		$(bcHolder).append(bc);
		$(div).append(bcHolder);
	} else {
		$(div).append('<div class="barcodeChooserBoxContainer"><input type="text" id="barcodeChooserBox" class="barcodeChooserBox"></div>')
	}
	$(div).append('<div class="addToExperimentButtonContainer"><a href="javascript:void(0);" class="addNewGroupButtonText" onclick="addToExperiment(\''+experimentType+'\')">Add to Experiment</a></div>')
	arxOneContainer.appendChild(div);
	
	if (!disableLookahead) {

		var barcodeChooserBox = $('#barcodeChooserBox').select2({
			text: function (item) { return item.barcode },
			createSearchChoice: function (term, data) {
				console.log(term)
				console.log(data)
				// $('input[type="text"].elnSearchInput').val(term).attr("secretvalue",term);
			},
			selectOnBlur: false,
			ajax: {
				url: "invp.asp?r="+Math.random(),
				dataType: 'json',
				delay: 350,
				method: "POST",
				type: "POST",
				contentType: "application/x-www-form-urlencoded",
				data: function (params) {
					return {
						url: "/getBarcodeSuggestions",
						verb: "POST",
						data: JSON.stringify({"connectionId":connectionId,"userInputValue":params,"chooserFields_fieldNames":chooserFields_fieldNames,"chooserFields_searchAgainst":chooserFields_searchAgainst,"chooserFields_inTypeahead":chooserFields_inTypeahead}),
						r: Math.random()
					};
				},
				results: function (data, params) {
					// parse the results into the format expected by Select2
					console.log(data)
					console.log(params)
					var i = 0;
					resultsArray = data['results']
					while(i < resultsArray.length){
						if(typeof resultsArray[i]['barcode'] !== "undefined" && resultsArray[i]['barcode'] !== ""){
							resultsArray[i]['id'] = resultsArray[i]['barcode']
						}
						i++
					}
					searchForObject = {}
					var searchBoxText = $('.barcodeChooserBox input[type="text"].select2-input').val()
					searchForObject['id'] = "specialResult_searchFor"
					searchForObject['barcode'] = searchBoxText
					resultsArray.unshift(searchForObject)
					return {
						results: resultsArray
					};
				},
				cache: false,
				timeout: 1500
			},
			escapeMarkup: function (markup) { return markup; },
			minimumInputLength: 1,
			multiple: true,
			formatResult: function(object, container, query){
				if(object['id'] == "specialResult_searchFor"){
					contentHTML = '<div class="resultContent_searchFor"><a href="#"><span class="searchFor_arrow">&gt;</span><span class="searchFor_label">Search for:</span> <span class="searchFor_text">' + object['barcode'] + '</span></a></div>'
					return contentHTML;
				}
				else{
					headingHTML = '<div class="resultHeading">'
					contentHTML = '<div class="resultContent">'
					
					$.each(chooserFields_inTypeahead,function(index, columnFieldName){
						columnFieldNameLowerCase = columnFieldName.toLowerCase();

						headingHTML += '<div class="colHeader">' + columnFieldName + '</div>';

						var cellValue = "";
						if(typeof object[columnFieldNameLowerCase] !== "undefined"){
							if(columnFieldNameLowerCase == "location"){
								var locationValue = ""
								$.each(object[columnFieldNameLowerCase],function(index, location){
									if(index > 0){
										locationValue += " > ";
									}
									locationValue += location['linkText'];
								});
								object[columnFieldNameLowerCase] = locationValue;
							}

							cellValue = object[columnFieldNameLowerCase];
						}
						
						contentHTML += '<div class="colContent">' + cellValue + '</div>';
					});

					headingHTML += '</div>'
					contentHTML += '</div>'
					return headingHTML + contentHTML;
				}
			},
			formatSelection: function (item) {
				console.log(item)
				$("#barcodeChooserBox").select2("val", "");
				barcodeChosen(item['barcode'])
				return item.barcode
			},
			formatSearching: null,
			initSelection : function (element, callback) {
				console.log(element)
				console.log(callback)
				var data = {id: element.val(), barcode: element.val()};
				callback(data);
			},
			dropdownCssClass : 'invLookupTypeaheadDropdownWide multiColumnTypeaheadWithSearchFor'
		});

		// This is a hacky way to make the links in the results of the typeahead clickable. Select2 stops the click event when you click a link in the dropdown by default...
		barcodeChooserBox.onSelect = (function(fn) {
			return function(data, options) {
				console.log(data)
				console.log(options)
				window.linkedExperimentInfo = data;
				$('#searchForExperiment').select2('data', {id: data['text'], text: data['text']}).trigger('change');
				$('#searchForExperiment').select2('close');
			}
		})(barcodeChooserBox.onSelect);

		$('.barcodeChooserBox').on("select2-open", function() {
			console.log("opening...")
			$('input[type="text"].barcodeChooserBox').val("");
		})

		$('.barcodeChooserBox').on("select2-close", function(something) {
			console.log("closing...")
			$(".barcodeChooserBox").select2("val", "");
		});
	}
}

function barcodeChosen(barcodeValue){
	if(barcodeValue !== ""){
		payload = {};
		payload["rpp"] = 1;
		payload["action"] = "next";
		payload["collection"] = "inventoryItems";
		payload["list"] = true;
		query = {};
		query[chooserSearchField] = barcodeValue.replace(/\n/,"");
		payload["query"] = query;
		restCallA("/getList/","POST",payload,function(r){
			if(r["forms"].length>0){
				fd = r["forms"][0];
				document.getElementById("barcodeChooserTable").getElementsByTagName("tbody")[0].appendChild(getResultTR(window.barcodeChooser_experimentType,fd));
				setRowInputVis();
			}else{
				swal("No match found",null,"error")
			}
			document.getElementById("barcodeChooserBox").value = "";
		})
	}
}

function getRoleSelect(){
	s = document.createElement("select");
	s.setAttribute("class","roleSelect");
	option = document.createElement("option");
	option.setAttribute("value","reactant");
	option.appendChild(document.createTextNode("Reactant"));
	s.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","reagent");
	option.appendChild(document.createTextNode("Reagent"));
	s.appendChild(option);
	option = document.createElement("option");
	option.setAttribute("value","solvent");
	option.appendChild(document.createTextNode("Solvent"));
	s.appendChild(option);
	s.onblur = function(){
		blurTimeout = setTimeout(function(){document.getElementById("barcodeChooserBox").focus()},1);
	}
	s.onfocus = function(){
		clearTimeout(blurTimeout);
	}
	s.onchange = function(){
		setRowInputVis();
	}
	return s;
}

function getAmountBox(){
	ip = document.createElement("input");
	ip.setAttribute("type","text");
	ip.setAttribute("class","amountBox")
	ip.onblur = function(){
		blurTimeout = setTimeout(function(){document.getElementById("barcodeChooserBox").focus()},1);
	}
	ip.onfocus = function(){
		clearTimeout(blurTimeout);
	}
	return ip;
}

function getEquivalentsBox(){
	ip = document.createElement("input");
	ip.setAttribute("type","text");
	ip.setAttribute("class","equivalentsBox")
	ip.onblur = function(){
		blurTimeout = setTimeout(function(){document.getElementById("barcodeChooserBox").focus()},1);
	}
	ip.onfocus = function(){
		clearTimeout(blurTimeout);
	}
	return ip;
}

function getLimitCheckbox(){
	ip = document.createElement("input");
	ip.setAttribute("type","checkbox");
	ip.setAttribute("class","limitCheck")
	ip.onblur = function(){
		blurTimeout = setTimeout(function(){document.getElementById("barcodeChooserBox").focus()},1);
	}
	ip.onfocus = function(){
		clearTimeout(blurTimeout);
	}
	ip.onclick = function(){
		if(this.checked){
			$(".limitCheck").prop("checked",false);
			$(this).prop("checked",true);
			setRowInputVis();
		}
	}
	return ip;
}

function getHeaderRow(experimentType){
	tr = document.createElement("tr");
	for (var i=0;i<chooserFields.length;i++){
		if(chooserFields[i].displayInTable){
			th = document.createElement("th");
			th.appendChild(document.createTextNode(chooserFields[i]["headerName"]));
			tr.appendChild(th);
		}
	}

	if(experimentType==1){
		th = document.createElement("th");
		th.appendChild(document.createTextNode("Role"));
		tr.appendChild(th);
	}
	if(experimentType==1 || useAmountForNonChemistry){
		if(bcAmountField){
			th = document.createElement("th");
			th.appendChild(document.createTextNode("Amount"));
			th.className = "amountCell";
			tr.appendChild(th);
		}
		if(bcAmountField&&experimentType==1){
			th = document.createElement("th");
			th.appendChild(document.createTextNode("Equivalents"));
			th.className = "equivalentsCell"
			if(!bcUseEquiv){
				th.style.display = "none";
			}
			tr.appendChild(th);
		}
		if(bcUnitsField){
			th = document.createElement("th");
			th.appendChild(document.createTextNode("Units"));
			tr.appendChild(th);
		}
		if(experimentType==1){
			if(!window.parent.hasLimittingMoles()){
				th = document.createElement("th");
				th.appendChild(document.createTextNode("Lim"));
				tr.appendChild(th);
			}
		}
	}
	tr.appendChild(document.createElement("th"));
	return tr;
}

function getResultTR(experimentType,fd){
	rowJSON = {};
	rowJSON["isVolume"] = false;
	tr = document.createElement("tr");
	tr.className = "resultRow";
	rowJSON["id"] = fd.id;
	rowJSON["collection"] = fd.collection;
	//create tds for display/non special fields
	for (var i=0;i<chooserFields.length;i++){
		for (var j=0;j<fd.fields.length;j++){
			field = fd.fields[j];
			chooserField = chooserFields[i];
			if(field.formName.toLowerCase()==chooserFields[i]["fieldName"].toLowerCase()){
				if(chooserField.displayInTable){
					tr.appendChild(editTableTDs(fd,field,tr))
				}
				if(chooserField.isStructureField==false){
					theVal = myTrim(field.value.toString());
					if(theVal != "-1" && theVal != ""){
						if(chooserField.hasOwnProperty("suffix")){
							theVal += chooserField["suffix"];
						}
						if(chooserField.hasOwnProperty("fixedDigits")){
							if(isNumeric(theVal)){
								theVal = parseFloat(theVal).toFixed(chooserField["fixedDigits"]);
							}
						}
					}
					rowJSON[chooserField.fieldName] = theVal;
				}
			}
			if(bcStructureField){
				if(field.formName.toLowerCase()==bcStructureField["fieldName"].toLowerCase()){
					if (field.value){
						rowJSON["structure"] = field.value.cdxml;
					}else{
						rowJSON["structure"] = ""
					}
				}
			}
			if(bcNameField){
				if(field.formName.toLowerCase()==bcNameField["fieldName"].toLowerCase()){
					rowJSON["name"] = field.value;
				}
			}else{
				rowJSON["name"] = "Untitled";
			}
		}
	}

	foundUnits = false;
	if(bcUnitsField){
		for (var j=0;j<fd.fields.length;j++){
			field = fd.fields[j];
			if(field.formName.toLowerCase()==bcUnitsField.fieldName.toLowerCase()||field.formName.toLowerCase()=="units"){
				rowJSON["units"] = field.value;
				foundUnits = true;
				for (var k=0;k<volumeUnits.length;k++){
					if(volumeUnits[k].toLowerCase()==rowJSON["units"].toLowerCase()){
						rowJSON["isVolume"] = true;
					}
				}
			}
		}
		
		if(rowJSON["isVolume"])
		{
			var hasDensity = false;
			for (var j=0;j<fd.fields.length;j++)
			{
				var densityIndex = -1;
				var field = fd.fields[j];
				if(field.formName.toLowerCase().indexOf("density") == 0)
				{
					if(!isNaN(parseFloat(field.value)) && isFinite(field.value))
					{
						console.log("density=",field.value);
						hasDensity = true;
					}
					
					densityIndex = j;
					break;
				}
			}
			
			if(!hasDensity)
			{
				<%If session("companyId") = 57 Or session("companyId") = 84 Or session("companyId") = 54 Then%>
				if(densityIndex != -1)
					rowJSON["density"] = "1.0 g/mL";
				<%Else%>
				alert("Container " + rowJSON["name"] + " does not have a density so it cannot be used.");
				return false;
				<%End If%>
			}
		}
		
		if(!foundUnits || rowJSON["units"]=="" || rowJSON["units"]=="-1"){
			rowJSON["units"] = "";
			if(warnNoUnits){
				alert("Warning: no units found for item");
			}
			if(errorNoUnits){
				alert("ERROR: no units found for item");
				return false;
			}
		}
	}

	if(experimentType==1){
		td = document.createElement("td");
		td.appendChild(getRoleSelect());
		tr.appendChild(td);
	}
	<%if bcExtraCellsForBio = 1 then%>
	if(experimentType==2){
		td = document.createElement("td");
		tr.appendChild(td);
		td = document.createElement("td");
		tr.appendChild(td);
	}
	<%end if%>
	if(experimentType==1 || useAmountForNonChemistry){
		if(bcAmountField){
			td = document.createElement("td");
			td.appendChild(getAmountBox());
			td.className = "amountCell";
			tr.appendChild(td);
		}
		if(bcAmountField&&experimentType==1){
			td = document.createElement("td");
			td.appendChild(getEquivalentsBox());
			td.className = "equivalentsCell"
			if(!bcUseEquiv){
				td.style.display = "none";
			}
			tr.appendChild(td);
		}
		if(bcUnitsField){
			td = document.createElement("td");
			td.appendChild(document.createTextNode(rowJSON["units"]));
			tr.appendChild(td);
		}
		if(experimentType==1){
			if(!window.parent.hasLimittingMoles()){
				td = document.createElement("td");
				td.appendChild(getLimitCheckbox());
				tr.appendChild(td);
			}
		}
	}
	td = document.createElement("td");
	img = document.createElement("img");
	img.src = "<%=mainAppPath%>/images/delete.png";
	img.onclick = function(){
		$(this).parent().parent().remove();
		document.getElementById("barcodeChooserBox").focus();
	}
	td.appendChild(img);
	h = document.createElement("input");
	h.setAttribute("type","hidden");
	h.className = "rowJSON";
	h.value = JSON.stringify(rowJSON);
	td.appendChild(h)
	tr.appendChild(td);
	return tr;
}

function addToExperiment(experimentType){
	if((experimentType==1 || useAmountForNonChemistry)&&requireAmount&&!bcUseEquiv){
		breakFlag = false;
		$("#barcodeChooserTable .resultRow").each(function(i,el){
			thisAmount = myTrim($(el).find(".amountBox").val());
			if(thisAmount == ""){
				alert("Please enter an amount for each item");
				breakFlag = true;
				return false;
			}
		})
		if(breakFlag){
			return false;
		}
	}
	if(experimentType==1){
		if(!window.parent.hasLimittingMoles()&&bcUseEquiv){
			foundLimit = false;
			$("#barcodeChooserTable .resultRow").each(function(i,el){
				if($(el).find(".limitCheck").prop("checked")){
					foundLimit = true;
				}
			})
			if(!foundLimit){
				alert("Must select a limitting reagent.");
				return false;
			}
		}
	}
	if(!bcUseEquiv){
		breakFlag = false;
		$("#barcodeChooserTable .resultRow").each(function(i,el){
			thisAmount = myTrim($(el).find(".amountBox").val());
			if(myTrim(thisAmount) != "" ){
				if(!isNumeric(thisAmount)){
					alert("Invalid Amount");
					breakFlag = true;
					return false;
				}
			}
		})
		if(breakFlag){
			return false;
		}
	}

	if(bcUseEquiv){
		breakFlag = false;
		$("#barcodeChooserTable .resultRow").each(function(i,el){
			rowJSON = JSON.parse($(el).find(".rowJSON").val());
			isLimittingRow = rowJSON["isLimittingRow"];
			role = $(el).find(".roleSelect").val()
			if(rowJSON["hasAmount"]){
				thisAmount = myTrim($(el).find(".amountBox").val());
				if(myTrim(thisAmount) != "" ){
					if(!isNumeric(thisAmount)){
						alert("Invalid Amount");
						breakFlag = true;
						return false;
					}
				}
			}
			if(rowJSON["hasEquivalents"]){
				thisAmount = myTrim($(el).find(".equivalentsBox").val());
				if(myTrim(thisAmount) != "" ){
					if(!isNumeric(thisAmount)){
						alert("Invalid Equivalents");
						breakFlag = true;
						return false;
					}
				}
			}
		})
		if(breakFlag){
			return false;
		}
	}

	if(bcUseEquiv){
		breakFlag = false;
		$("#barcodeChooserTable .resultRow").each(function(i,el){
			rowJSON = JSON.parse($(el).find(".rowJSON").val());
			if(rowJSON["hasAmount"]){
				thisAmount = myTrim($(el).find(".amountBox").val());
				if(myTrim(thisAmount) == "" ){
					alert("Please enter an amount for each amount box");
					breakFlag = true;
					return false;
				}
			}
			if(rowJSON["hasEquivalents"]){
				thisAmount = myTrim($(el).find(".equivalentsBox").val());
				if(myTrim(thisAmount) == "" ){
					alert("Please enter equivalents for each equivalent box");
					breakFlag = true;
					return false;
				}
			}
		})
		if(breakFlag){
			return false;
		}
	}

	blackOn();	
	$("#loadingDiv").show();
	
 	var rows = [];
	$("#barcodeChooserTable .resultRow").each(function(i,el){
		rowJSON = JSON.parse($(el).find(".rowJSON").val());
		console.log(rowJSON);
		try
		{
			thisAmount = myTrim($(el).find(".amountBox").val());
		}
		catch(err)
		{
			thisAmount="";
		}
		
		var thisAmountWithUnits = thisAmount;
		if(rowJSON.hasOwnProperty("units") && rowJSON["units"]!="")
			thisAmountWithUnits = thisAmount + " " + rowJSON["units"];
		
		// Declare a variable to track the equivalents. This used to be global,
		// so every structure would have the same equivalents regardless of what was entered.
		var theseEquivalents = null;
		if(rowJSON["hasEquivalents"])
			theseEquivalents = myTrim($(el).find(".equivalentsBox").val());

		
		if(experimentType==1){
			var cdxml = rowJSON["structure"];			
			var role = $(el).find(".roleSelect").val();
			
			if(role=="reactant")
				fragLocation = "left";
			else if(role=="reagent")
				fragLocation = "top";
			else if(role=="solvent")
				fragLocation = "bottom";

			if(!cdxml) {
				return(false);
			}
		}

		var row = {};
		row.thisAmount = thisAmount;
		row.thisAmountWithUnits = thisAmountWithUnits;
		row.cdxml = cdxml;
		row.role = role;
		row.fragLocation = fragLocation;
		row.rowJSON = rowJSON;
		row.experimentType = experimentType;
		if (theseEquivalents) {
			row.equivalents = theseEquivalents;
		}

		rows.push(row);
			
	});		

 	// call process row
	processRow(rows, {}, [], [], [], 0);
		
}

/**
 * Iterates through every row in rows and adds each one to the parent window's chemistry experiment.
 * @param {JSON[]} rows The rows of inventory items to add to the experiment.
 * @param {JSON} expJSONStorage The accumulated object storing all of the data to be added to the grid.
 * @param {string[]} prefixList The accumulated list of prefixes for all of the structures added.
 * @param {JSON[]} itemsToDecrement The accumulated list of items to decrement from inventory.
 * @param {JSON[]} equivalentRowsToDecrement The accumulated list of volumes to decrement from inventory.
 * @param {number} numErrors The number of rows that failed to be inserted.
 */
function processRow(rows, expJSONStorage, prefixList, itemsToDecrement, equivalentRowsToDecrement, numErrors){	
	if (rows === undefined || rows.length == 0) {
		//console.log("All done, let go home.");
	}else{
		console.log("start processing row");
		// Hack to process solvents first. For some reason, the grid gets testy when solvents are added via barcode
		// in marvin last.
		var row;

		// Using filter here because IE doesn't support find.
		var solventRows = rows.filter(function(x) {
			return x.role == "solvent";
		});

		if (solventRows.length > 0) {
			row = solventRows[0];
			var rowIndex = rows.indexOf(row);
			rows.splice(rowIndex, 1);
		} else {
			row = rows.pop();
		}

		thisAmount = row.thisAmount;
		thisAmountWithUnits = row.thisAmountWithUnits;
		cdxml = row.cdxml;
		role = row.role;
		fragLocation = row.fragLocation;
		rowJSON = row.rowJSON;
		experimentType = row.experimentType;
		var experimentReaction = {};

		// We can't guarantee that cdxml is /actually/ a CDXML string, so we're going to convert it first.
		convertToCDXML(cdxml).then(function(cdxml) {

			if(experimentType == 1)
			{
				var blankCDXML = '<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd" ><CDXML  CreationProgram="ChemDraw 16.0.1.4"  Name="blank.cdx"  BoundingBox="0 0 0 0"  WindowPosition="0 0"  WindowSize="0 -2147483648"  WindowIsZoomed="yes"  FractionalWidths="yes"  InterpretChemically="yes"  ShowAtomQuery="yes"  ShowAtomStereo="no"  ShowAtomEnhancedStereo="yes"  ShowAtomNumber="no"  ShowResidueID="no"  ShowBondQuery="yes"  ShowBondRxn="yes"  ShowBondStereo="no"  ShowTerminalCarbonLabels="no"  ShowNonTerminalCarbonLabels="no"  HideImplicitHydrogens="no"  LabelFont="3"  LabelSize="10"  LabelFace="96"  CaptionFont="4"  CaptionSize="12"  HashSpacing="2.70"  MarginWidth="2"  LineWidth="1"  BoldWidth="4"  BondLength="30"  BondSpacing="12"  ChainAngle="120"  LabelJustification="Auto"  CaptionJustification="Left"  AminoAcidTermini="HOH"  ShowSequenceTermini="yes"  ShowSequenceBonds="yes"  ResidueWrapCount="40"  ResidueBlockCount="10"  ResidueZigZag="yes"  NumberResidueBlocks="no"  PrintMargins="36 36 36 36"  MacPrintInfo="000300000258025800000000190D1357FFA9FFB21971139E0367052803FC000200000258025800000000190D1357000100640064000000010001010100000001270F000100010000000000000000000000000002001901900000000000600000000000000000000100000000000000000000000000000000"  ChemPropName=""  ChemPropFormula="Chemical Formula: "  ChemPropExactMass="Exact Mass: "  ChemPropMolWt="Molecular Weight: "  ChemPropMOverZ="m/z: "  ChemPropAnalysis="Elemental Analysis: "  ChemPropBoilingPt="Boiling Point: "  ChemPropMeltingPt="Melting Point: "  ChemPropCritTemp="Critical Temp: "  ChemPropCritPres="Critical Pres: "  ChemPropCritVol="Critical Vol: "  ChemPropGibbs="Gibbs Energy: "  ChemPropLogP="Log P: "  ChemPropMR="MR: "  ChemPropHenry="Henry&apos;s Law: "  ChemPropEForm="Heat of Form: "  ChemProptPSA="tPSA: "  ChemPropCLogP="CLogP: "  ChemPropCMR="CMR: "  ChemPropLogS="LogS: "  ChemPropPKa="pKa: "  ChemPropID=""  color="0"  bgcolor="1"  RxnAutonumberStart="1"  RxnAutonumberConditions="no"  RxnAutonumberStyle="Roman"  RxnAutonumberFormat="(#)" ><colortable><color r="1" g="1" b="1"/><color r="0" g="0" b="0"/><color r="1" g="0" b="0"/><color r="1" g="1" b="0"/><color r="0" g="1" b="0"/><color r="0" g="1" b="1"/><color r="0" g="0" b="1"/><color r="1" g="0" b="1"/></colortable><fonttable><font id="3" charset="iso-8859-1" name="Arial"/><font id="4" charset="iso-8859-1" name="Times New Roman"/></fonttable><page  id="5"  BoundingBox="0 0 540 720"  HeaderPosition="36"  FooterPosition="36"  PrintTrimMarks="yes"  HeightPages="1"  WidthPages="1" /></CDXML>';
				$.ajax({
					method: "POST",
					url: "/arxlab/ajax_doers/getCDXTemplate.asp",
					data: {"originCDXML": cdxml, "templateCdxml": blankCDXML},
				}).done(function(response) {
					if (response != null && response.length > 0) {
						var cdxml = response;
						var prefix;

						window.top.getChemistryEditorChemicalStructure("mycdx",true).then(function(experimentCdxml){
							if(experimentCdxml == "") {
								// If we don't have a CDXML, then default to this CDXML that's just an arrow.
								experimentCdxml = '<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE CDXML SYSTEM "http://www.cambridgesoft.com/xml/cdxml.dtd" ><CDXML CreationProgram="ChemDraw 16.0.1.4" Name="just an arrow.cdxml" BoundingBox="117.54 330.38 449.46 342.63" WindowPosition="0 0" WindowSize="0 1073741824" WindowIsZoomed="yes" FractionalWidths="yes" InterpretChemically="yes" ShowAtomQuery="yes" ShowAtomStereo="no" ShowAtomEnhancedStereo="yes" ShowAtomNumber="no" ShowResidueID="no" ShowBondQuery="yes" ShowBondRxn="yes" ShowBondStereo="no" ShowTerminalCarbonLabels="no" ShowNonTerminalCarbonLabels="no" HideImplicitHydrogens="no" Magnification="1333" LabelFont="3" LabelSize="10" LabelFace="96" CaptionFont="4" CaptionSize="12" HashSpacing="2.70" MarginWidth="2" LineWidth="1" BoldWidth="4" BondLength="30" BondSpacing="12" ChainAngle="120" LabelJustification="Auto" CaptionJustification="Left" AminoAcidTermini="HOH" ShowSequenceTermini="yes" ShowSequenceBonds="yes" ResidueWrapCount="40" ResidueBlockCount="10" ResidueZigZag="yes" NumberResidueBlocks="no" PrintMargins="36 36 36 36" MacPrintInfo="00030000025802580000000019081340FFA0FFA01968138C0367052803FC00020000025802580000000019081340000100640064000000010001010100000001270F000100010000000000000000000000000002001901900000000000600000000000000000000100000000000000000000000000000000" ChemPropName="" ChemPropFormula="Chemical Formula: " ChemPropExactMass="Exact Mass: " ChemPropMolWt="Molecular Weight: " ChemPropMOverZ="m/z: " ChemPropAnalysis="Elemental Analysis: " ChemPropBoilingPt="Boiling Point: " ChemPropMeltingPt="Melting Point: " ChemPropCritTemp="Critical Temp: " ChemPropCritPres="Critical Pres: " ChemPropCritVol="Critical Vol: " ChemPropGibbs="Gibbs Energy: " ChemPropLogP="Log P: " ChemPropMR="MR: " ChemPropHenry="Henry&apos;s Law: " ChemPropEForm="Heat of Form: " ChemProptPSA="tPSA: " ChemPropCLogP="CLogP: " ChemPropCMR="CMR: " ChemPropLogS="LogS: " ChemPropPKa="pKa: " ChemPropID="" color="0" bgcolor="1" RxnAutonumberStart="1" RxnAutonumberConditions="no" RxnAutonumberStyle="Roman" RxnAutonumberFormat="(#)"><colortable><color r="1" g="1" b="1"/><color r="0" g="0" b="0"/><color r="1" g="0" b="0"/><color r="1" g="1" b="0"/><color r="0" g="1" b="0"/><color r="0" g="1" b="1"/><color r="0" g="0" b="1"/><color r="1" g="0" b="1"/></colortable><fonttable><font id="3" charset="iso-8859-1" name="Arial"/><font id="4" charset="iso-8859-1" name="Times New Roman"/></fonttable><page id="8" BoundingBox="0 0 540 720" HeaderPosition="36" FooterPosition="36" PrintTrimMarks="yes" HeightPages="1" WidthPages="1"><graphic id="6" SupersededBy="9" BoundingBox="449.46 337.01 117.54 337.01" Z="3" GraphicType="Line" ArrowType="FullHead" HeadSize="2250"/><scheme  id="85" ><step  id="86"  ReactionStepReactants=""  ReactionStepProducts=""  ReactionStepArrows="6"  ReactionStepObjectsAboveArrow="" /></scheme><arrow id="9" BoundingBox="117.54 330.38 449.46 342.63" Z="3" FillType="None" ArrowheadHead="Full" ArrowheadType="Solid" HeadSize="2250" ArrowheadCenterSize="1969" ArrowheadWidth="563" Head3D="449.46 337.01 0" Tail3D="117.54 337.01 0" Center3D="508.22 505.51 0" MajorAxisEnd3D="840.14 505.51 0" MinorAxisEnd3D="508.22 837.43 0"/></page></CDXML>';
							}

							experimentReaction = {
								"reactionData": experimentCdxml,
								"reactionFormat": window.top.getFileFormat(experimentCdxml),
								"reactionElement": "mycdx",
							};

							<% if session("useMarvin") then %>
								
								if (fragLocation == "bottom" || role == "solvent") {
									fragPromise = new Promise(function(resolve, reject) {
										//prefix = window.parent.addSolvent(rowJSON["Chemical Name"]);
										structureData = {
											"fields": [],
											"prefix" : "",
											"addType": window.top.assignCasDataSource("1"),
											"molType": "solvent",
											"name": rowJSON["Chemical Name"],
											"MW": rowJSON["Mol Weight"],
											"Formula": rowJSON["formula"],
											"reagentCdxml": "",
											"experimentCdxml": experimentCdxml,
											"cas": "",
											"label": "",
											"fragLocation": "",
											"addStructureToDiagram": false,
											"newFragmentId": -1
										};
										window.top.addToReactionMarvin(structureData).then(function() {
											prefix = structureData["prefix"]
											resolve({
												'fragmentId':structureData['newFragmentId'],
												'reactionData':experimentCdxml,
												'reactionFormat':'MRV',
												'reactionElement':'mycdx'
											});
										});
									});
								} else {
									fragPromise = window.top.marvinInsert.insertFragmentMarvin(fragLocation, cdxml, experimentCdxml);
								}
							<% else %>
								fragPromise = window.top.insertFragment(fragLocation, cdxml, experimentCdxml);
							<% end if %>

							fragPromise.then(function(fragmentData) {
								new Promise(function(resolve, reject) {
									var newFragmentId = -1;
									var myDependencies = [];
									if(fragmentData.hasOwnProperty("fragmentId")) {
										newFragmentId = fragmentData["fragmentId"];
									}
									
									if(fragmentData.hasOwnProperty("reactionData")) {
										experimentReaction["reactionData"] = fragmentData["reactionData"];
									}
									
									if(fragmentData.hasOwnProperty("reactionFormat")) {
										experimentReaction["reactionFormat"] = fragmentData["reactionFormat"];
									}
									
									if(fragmentData.hasOwnProperty("reactionElement")) {
										experimentReaction["reactionElement"] = fragmentData["reactionElement"];
									}
									
									if(newFragmentId == -1) {
										numErrors += 1;
										resolve();
									} else {
										var promiseFunc;
										if (!prefix) {
											if(role=="reactant")
												promiseFunc = window.parent.addReactant();
											else if(role=="reagent")
												promiseFunc = window.parent.addReagent();
											else if(role=="solvent")
												promiseFunc = window.parent.addSolvent();	
										} else {
											promiseFunc = new Promise(function(resolve, reject) {resolve(prefix)});
										}

										promiseFunc.then(function(value) {
											prefix = value;
											prefixList.push(prefix);

											if(useLabels)
											{
												theLabel = window.parent.getNextLabel();
											}
											else
											{
												if(bcTabNameField)
												{
													theVal = rowJSON[bcTabNameField["fieldName"]];
													if(theVal)
														theLabel = theVal.toString().substr(0,20)
													else
														theLabel = prefix.replace(/[^0-9]+/,role.charAt(0).toUpperCase()+role.substr(1).toLowerCase()+" ")
												}
												else
												{
													if (rowJSON["Chemical Name"]) {
														theLabel = rowJSON["Chemical Name"].substr(0, 20);
													} else {
														theLabel = prefix.replace(/[^0-9]+/,role.charAt(0).toUpperCase()+role.substr(1).toLowerCase()+" ")
													}
												}

											}
											
											if(!window.parent.UAStates.hasOwnProperty(prefix))
												window.parent.UAStates[prefix] = {};

											if(role=="reactant"){
												if(rowJSON["hasEquivalents"]){
													thisFieldName = prefix+"_equivalents";
													window.parent.UAStates[prefix]["equivalents"] = true;
													window.parent.document.getElementById(thisFieldName).value = row.equivalents;
													myDependencies.push(window.parent.sendAutoSave(thisFieldName,row.equivalents));
													expJSONStorage[thisFieldName] = row.equivalents;
												}else{
													window.parent.UAStates[prefix]["equivalents"] = false;
												}
												for(var i=0;i<chooserFields.length;i++){
													if(chooserFields[i].isReactantField && chooserFields[i].hasOwnProperty("destinationField")){
														if(!(chooserFields[i].isVolumeField && !rowJSON["isVolume"]) && !(chooserFields[i].isMassField && rowJSON["isVolume"])){
															thisFieldName = prefix+"_"+chooserFields[i].destinationField
															thisVal = rowJSON[chooserFields[i]["fieldName"]].toString();
															if(chooserFields[i].userAdded && thisVal!=""){
																window.parent.UAStates[prefix][chooserFields[i].destinationField] = true;
															}
															window.parent.document.getElementById(thisFieldName).value = thisVal;
															myDependencies.push(window.parent.sendAutoSave(thisFieldName,thisVal));
															expJSONStorage[thisFieldName] = thisVal;
														}
													}
												}
												if(thisAmount!="" && rowJSON["hasAmount"]){
													if(rowJSON["isVolume"]){
														thisFieldName = prefix+"_volume";
														window.parent.UAStates[prefix]["volume"] = true;
														window.parent.document.getElementById(thisFieldName).value = thisAmountWithUnits;
														myDependencies.push(window.parent.sendAutoSave(thisFieldName,thisAmountWithUnits));
														expJSONStorage[thisFieldName] = thisAmountWithUnits;

														if(rowJSON.hasOwnProperty("density")){
															thisFieldName = prefix+"_density";
															window.parent.UAStates[prefix]["density"] = true;
															window.parent.document.getElementById(thisFieldName).value = rowJSON["density"];
															expJSONStorage[thisFieldName] = rowJSON["density"];
														}
													}else{
														thisFieldName = prefix+"_sampleMass";
														window.parent.UAStates[prefix]["sampleMass"] = true;
														window.parent.document.getElementById(thisFieldName).value = thisAmountWithUnits;
														myDependencies.push(window.parent.sendAutoSave(thisFieldName,thisAmountWithUnits));
														expJSONStorage[thisFieldName] = thisAmountWithUnits;
													}
												}
												if(rowJSON["isLimittingRow"]){
													thisFieldName = prefix+"_limit";
													window.parent.UAStates[prefix]["limit"] = true;
													window.parent.document.getElementById(thisFieldName).checked = true;
													myDependencies.push(window.parent.sendAutoSave(thisFieldName,true));
													expJSONStorage[thisFieldName] = "CHECKED"
												}
											}
											if(role=="reagent"){
												if(rowJSON["hasEquivalents"]){
													thisFieldName = prefix+"_equivalents";
													window.parent.UAStates[prefix]["equivalents"] = true;
													window.parent.document.getElementById(thisFieldName).value = row.equivalents;
													myDependencies.push(window.parent.sendAutoSave(thisFieldName,row.equivalents));
													expJSONStorage[thisFieldName] = row.equivalents;
												}else{
													window.parent.UAStates[prefix]["equivalents"] = false;
												}
												for(var i=0;i<chooserFields.length;i++){
													if(chooserFields[i].isReagentField && chooserFields[i].hasOwnProperty("destinationField")){
														if(!(chooserFields[i].isVolumeField && !rowJSON["isVolume"]) && !(chooserFields[i].isMassField && rowJSON["isVolume"])){
															thisFieldName = prefix+"_"+chooserFields[i].destinationField
															thisVal = rowJSON[chooserFields[i]["fieldName"]].toString();
															if(chooserFields[i].userAdded && thisVal!=""){
																window.parent.UAStates[prefix][chooserFields[i].destinationField] = true;
															}
															window.parent.document.getElementById(thisFieldName).value = thisVal;
															myDependencies.push(window.parent.sendAutoSave(thisFieldName,thisVal));
															expJSONStorage[thisFieldName] = thisVal;
														}
													}
												}
												if(thisAmount!="" && rowJSON["hasAmount"]){
													if(rowJSON["isVolume"]){
														thisFieldName = prefix+"_volume";
														window.parent.UAStates[prefix]["volume"] = true;
														window.parent.document.getElementById(thisFieldName).value = thisAmountWithUnits;
														myDependencies.push(window.parent.sendAutoSave(thisFieldName,thisAmountWithUnits));
														
														if(rowJSON.hasOwnProperty("density")){
															thisFieldName = prefix+"_density";
															window.parent.UAStates[prefix]["density"] = true;
															window.parent.document.getElementById(thisFieldName).value = rowJSON["density"];
															expJSONStorage[thisFieldName] = thisAmountWithUnits;
														}
													}else{
														thisFieldName = prefix+"_sampleMass";
														window.parent.UAStates[prefix]["sampleMass"] = true;
														window.parent.document.getElementById(thisFieldName).value = thisAmountWithUnits;
														myDependencies.push(window.parent.sendAutoSave(thisFieldName,thisAmountWithUnits));
														expJSONStorage[thisFieldName] = thisAmountWithUnits;
													}
												}
												if(rowJSON["isLimittingRow"]){
													thisFieldName = prefix+"_limit";
													window.parent.UAStates[prefix]["limit"] = true;
													window.parent.document.getElementById(thisFieldName).checked = true;
													myDependencies.push(window.parent.sendAutoSave(thisFieldName,true));
													expJSONStorage[thisFieldName] = "CHECKED"
												}
											}
											if(role=="solvent"){
												for(var i=0;i<chooserFields.length;i++){
													if(chooserFields[i].isSolventField && chooserFields[i].hasOwnProperty("destinationField")){
														if(!(chooserFields[i].isVolumeField && !rowJSON["isVolume"]) && !(chooserFields[i].isMassField && rowJSON["isVolume"])){
															thisFieldName = prefix+"_"+chooserFields[i].destinationField
															thisVal = rowJSON[chooserFields[i]["fieldName"]].toString();
															if(chooserFields[i].userAdded && thisVal!=""){
																window.parent.UAStates[prefix][chooserFields[i].destinationField] = true;
															}
															myDependencies.push(window.parent.sendAutoSave(thisFieldName,thisVal));
															window.parent.document.getElementById(thisFieldName).value = thisVal;
															expJSONStorage[thisFieldName] = thisVal;
														}
													}
												}
												if(thisAmount!=""){
													if(rowJSON["isVolume"]){
														thisFieldName = prefix+"_volume";
														window.parent.UAStates[prefix]["volume"] = true;
														window.parent.document.getElementById(thisFieldName).value = thisAmountWithUnits;
														myDependencies.push(window.parent.sendAutoSave(thisFieldName,thisAmountWithUnits));
														expJSONStorage[thisFieldName] = thisAmountWithUnits;
													}
												}
											}

											myDependencies.push(window.parent.newDraftMol(role,newFragmentId,theLabel));
											inventoryItems = [];
											inventoryItems.push({"id":rowJSON["id"],"name":rowJSON["name"],"amount":thisAmountWithUnits,"isVolume":rowJSON["isVolume"]});
											inventoryItems = JSON.stringify(inventoryItems);
											myDependencies.push(window.parent.removeInvLinks(prefix));
											myDependencies.push(window.parent.makeInvLinks(prefix,JSON.parse(inventoryItems)));
											window.top.UAStates[prefix]["inventoryItems"] = true;
											expJSONStorage[prefix + "_inventoryItems"] = inventoryItems;

											window.parent.document.getElementById(prefix+"_fragmentId").value = newFragmentId;
											myDependencies.push(window.parent.sendAutoSave(prefix+"_fragmentId",newFragmentId));
											window.parent.document.getElementById(prefix+"_hasChanged").value = "1";
											myDependencies.push(window.parent.sendAutoSave(prefix+"_hasChanged","1"));
											window.parent.document.getElementById(prefix+"_trivialName").value = theLabel;
											window.parent.document.getElementById(prefix+"_tab_text").innerHTML = theLabel;
											myDependencies.push(window.parent.sendAutoSave(prefix+"_trivialName",theLabel));
											myDependencies.push(window.parent.addInventoryLink(rowJSON["id"],thisAmountWithUnits,rowJSON["name"],rowJSON["collection"],bcAmountField["dbName"],newFragmentId));

											window.parent.document.getElementById(prefix+"_UAStates").value = JSON.stringify(window.parent.UAStates[prefix]);
											myDependencies.push(window.parent.sendAutoSave(prefix+"_UAStates",JSON.stringify(window.parent.UAStates[prefix])));
											expJSONStorage[prefix + "_UAStates"] = JSON.stringify(window.parent.UAStates[prefix]);
											
											// Prepare this link for the inventory decrement call.
											var D = {
												"collection": rowJSON["collection"],
												"id": rowJSON["id"],
												"fieldName": bcAmountField["dbName"],
												"theLink": theLink,
											};
											if(thisAmount!=""){
												D["value"] = parseFloat(thisAmount);
												itemsToDecrement.push(D);
											} else if(rowJSON["hasEquivalents"]){
												D["value"] = "none";
												D["prefix"] = prefix;
												D["isVolume"] = rowJSON["isVolume"];
												equivalentRowsToDecrement.push(D);
											}

											window.parent.updateLiveEditStructureData(experimentReaction["reactionElement"], experimentReaction["reactionData"], experimentReaction["reactionFormat"]).then(function(){
												Promise.all(myDependencies).then(function(){
													resolve();
												});
											});
										})
									}
								}).then(function(){
									if (rows.length > 0){
										processRow(rows, expJSONStorage, prefixList, itemsToDecrement, equivalentRowsToDecrement, numErrors);
									}else{
										//cleanup
										if(experimentType!=1){
											window.parent.getInventoryLinks();
										}
										callMultiUse(itemsToDecrement).then(function(r) {
											// This is to get the labels (they come from dispatch)
											<% if session("useMarvin") then %>
												setTimeout(function(){
													window.top.getChemistryEditorChemicalStructure("mycdx", true).then(function(mrvData) {
														// Populate the experimentJSON here with all of the values we've accumulated.
														populateExpJson(expJSONStorage, prefixList);
														
														window.top.$("#mrvData").text(mrvData);
														window.top.$("#mrvData").val(mrvData);
														callMarvinDispatch(mrvData, window.top.experimentId, window.top.experimentJSON).then(function() {
															for (key in expJSONStorage) {
																window.top.$("#" + key).val(expJSONStorage[key]);
																var element = window.top.document.getElementById(key);
																if (element) {
																	window.top.gridFieldChanged(element);
																}
															}

															fixLimitingEquivalents(expJSONStorage);

															// Populate the experimentJSON here to make sure everything sticks.
															populateExpJson(expJSONStorage, prefixList);
															window.parent.experimentSubmit(false,false,false,false,false).then(function(){
																processEquivalentRows(equivalentRowsToDecrement);
																window.parent.hidePopup("inventoryPopup");
															});
														});
													});

												},3000);
											<% else %>
												setTimeout(function() {
													window.parent.experimentSubmit(false, false, false, false, false).then(function() {
														// processEquivalentRows pulls values from the grid to submit to Inventory, but there currently is
														// no way to tell when the grid has finished calculating, so for the time being, I'm setting a timeout
														// to allow the grid time to complete its calculations. This is unnecessary for Marvin because the grid is
														// constantly updating there, but live edit only does the calculations at the end of the insertions.
														// If we ever update the grid to allow for callback functions to be run after calculations, we can update this
														// timeout to do it the right way, but doing that would be incredibly invasive for just the barcode chooser.
														setTimeout(function() {
															processEquivalentRows(equivalentRowsToDecrement);
														}, 5000);
														window.parent.hidePopup("inventoryPopup");
													});
												}, 3000);
											<% end if %>
											
											if (numErrors > 0) {
												var moreThanOneError = numErrors > 1;
												var wereOrWas = moreThanOneError ? "were" : "was";
												var container = moreThanOneError ? "containers" : "container";
												window.top.swal("Invalid " + container, "There " + wereOrWas + " " + numErrors + " invalid " + container + ". Please contact support.");
											}
										})
									}
								});
							});
						});
					} else {
						hidePopup("inventoryPopup");
						window.top.swal("Error Standardizing Structure", "Please try your request again. If this problem persists, please contact support." , "error");
					}
				}).fail(function() {
					resolve();
					console.log("template application failed.");
				});
			}
		})
	}
};

function myTrim(x) {
	if(x){
	    return x.replace(/^\s+|\s+$/gm,'');
	}else{
		return "";
	}
}

function isNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function toggleEquivalents(){
	if(bcUseEquiv){
		bcUseEquiv = false;
		setRowInputVis();
	}else{
		bcUseEquiv = true;
		setRowInputVis();
	}
	document.getElementById("barcodeChooserBox").focus();
}

function setRowInputVis(){
	$("#barcodeChooserTable .resultRow").each(function(i,el){
		if($(el).find(".roleSelect").val()=="solvent"){
			$(el).find(".limitCheck").prop("checked",false)
			$(el).find(".limitCheck").hide();
		}else{
			$(el).find(".limitCheck").show();
		}
	})
	if(!bcUseEquiv){
		$(".equivalentsCell").hide();
		$(".equivalentsCell").val("");
		$(".amountBox").show();
		$("#barcodeChooserTable .resultRow").each(function(i,el){
			rowJSON = JSON.parse($(el).find(".rowJSON").val());
			if($(el).find(".limitCheck")){
				isLimit = $(el).find(".limitCheck").prop("checked");
			}else{
				isLimit = false;
			}
			rowJSON["isLimittingRow"] = isLimit;
			rowJSON["hasAmount"] = true;
			rowJSON["hasEquivalents"] = false;
			$(el).find(".rowJSON").val(JSON.stringify(rowJSON));
		})
	}else{
		$(".equivalentsCell").show();
		$("#barcodeChooserTable .resultRow").each(function(i,el){
			rowJSON = JSON.parse($(el).find(".rowJSON").val());
			if($(el).find(".limitCheck")){
				isLimit = $(el).find(".limitCheck").prop("checked");
			}else{
				isLimit = false;
			}
			if(isLimit){
				$(el).find(".amountBox").show();
				if($(el).find(".equivalentsBox").val()==""){
					$(el).find(".equivalentsBox").val("1.0")
				}
			}else{
				$(el).find(".amountBox").hide();
				$(el).find(".amountBox").val("");
			}
			if($(el).find(".roleSelect").val()=="solvent"){
				$(el).find(".equivalentsBox").hide();
				$(el).find(".amountBox").show();
			}
			rowJSON = JSON.parse($(el).find(".rowJSON").val());
			rowJSON["isLimittingRow"] = isLimit;
			if(isLimit){
				rowJSON["hasAmount"] = true;
				rowJSON["hasEquivalents"] = true;
			}else{
				if($(el).find(".roleSelect").val()=="solvent"){
					rowJSON["hasAmount"] = true;
					rowJSON["hasEquivalents"] = false;
				}else{
					rowJSON["hasAmount"] = false;
					rowJSON["hasEquivalents"] = true;
				}
			}
			$(el).find(".rowJSON").val(JSON.stringify(rowJSON));
		})
	}
}

/**
 * This calls the /multiUse endpoint of inventoryActual to decrement the items in itemsList
 * by the amount entered in the barcode chooser.
 * @param {JSON[]} itemsList The list of items to decrement from inventory.
 */
function callMultiUse(itemsList) {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "/arxlab/inventory2/invp.asp",
			data: {
				"url": "/multiUse",
				"verb": "POST",
				"data": JSON.stringify({
					"connectionId": connectionId,
					"items": itemsList,
				}),
			},
			type: "POST",
		}).then(function(r) {
			resolve(r);
		});
	});
}

/**
 * This calls the /multiUse endpoint of inventoryActual to decrement the items in equivalentRowsToDecrement
 * by the amounts set in the table after grid calculations have happened.
 * @param {JSON[]} equivalentRowsToDecrement The list of items to decrement from inventory.
 */
function processEquivalentRows(equivalentRowsToDecrement) {
	return new Promise(function(resolve, reject) {
		equivalentRowsToDecrement.forEach(function(item) {
			var itemPrefix = item["prefix"];
			if (item["isVolume"]) {
				try {
					item["value"] = myTrim(window.top.document.getElementById(itemPrefix + "_volume").value);
				} catch(err) {
					// do nothing?
				}
			} else {
				try {
					item["value"] = myTrim(window.top.document.getElementById(itemPrefix + "_sampleMass").value);
				} catch(err) {
					// do nothing?
				}
			}
			item["value"] = item["value"].replace("µ","u").replace("&micro;","u")
		})
		callMultiUse(equivalentRowsToDecrement).then(function(r) {
			resolve(r);
		});
	});
}

/**
 * Helper function to ensure the values in the expJSONStorage and prefixList objects persist
 * in the top level experiment JSON.
 * @param {JSON} expJSONStorage The accumulated object storing all of the data to be added to the grid.
 * @param {string[]} prefixList The accumulated list of prefixes for all of the structures added.
 */
function populateExpJson(expJSONStorage, prefixList) {

	for (key in expJSONStorage) {
		window.top.experimentJSON[key] = expJSONStorage[key];
	}

	for (index in prefixList) {
		var prefix = prefixList[index];
		window.top.experimentJSON[prefix + "_fragmentId"] = window.top.$("#" + prefix + "_fragmentId").val();
	}
}

/**
 * Hack to fix the equivalent value for the limiting structure because marvin seems to calculate the equivalents
 * using the left-most item as the limiting structure when that's not necessarily the correct one.
 * @param {JSON} expJSONStorage The JSON object holding all of the entered values from the barcode chooser.
 */
function fixLimitingEquivalents(expJSONStorage) {
	
	var expJSONKeys = Object.keys(expJSONStorage);

	// Check to see if there were any equivalents set. If there were, then don't even bother.
	if (expJSONKeys.filter(function(x) { return x.includes("equivalents") }).length == 0) {
		
		// Figure out which structure is the limiting one.
		var limitingKeys = expJSONKeys.filter(function(x) { return x.includes("_limit") });
		limitingKeys.forEach(function(limitKey) {

			// Make sure its actually "CHECKED".
			if (expJSONStorage[limitKey] == "CHECKED") {

				// Now force an empty string into the appropriate equivalents box and update the grid.
				var limitingEquivalentKey = limitKey.replace("_limit", "_equivalents");
				
				var equivalentInput = window.top.document.getElementById(limitingEquivalentKey);

				// If we have an equivalent input for this structure and blank it out if it exists.
				// We're doing this to force an equivalents recalculation to ensure that the limiting
				// equivalents are set to 1. We're not just setting this equivalent value to 1 because
				// then it would turn the field green and flag it as a UA states thing.
				if (equivalentInput) {
					window.top.$("#" + limitingEquivalentKey).val("");
					window.top.gridFieldChanged(equivalentInput);
				}
			}
		})
	}

}

</script>