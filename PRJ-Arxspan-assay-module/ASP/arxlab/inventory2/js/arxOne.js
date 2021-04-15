try{
Number.prototype.autoRound = window.parent.Number.prototype.autoRound;
}catch(err){}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function getViewport(){

 var viewPortWidth;
 var viewPortHeight;

 // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight
 if (typeof window.innerWidth != 'undefined') {
   viewPortWidth = window.innerWidth,
   viewPortHeight = window.innerHeight
 }

// IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)
 else if (typeof document.documentElement != 'undefined'
 && typeof document.documentElement.clientWidth !=
 'undefined' && document.documentElement.clientWidth != 0) {
    viewPortWidth = document.documentElement.clientWidth,
    viewPortHeight = document.documentElement.clientHeight
 }

 // older versions of IE
 else {
   viewPortWidth = document.getElementsByTagName('body')[0].clientWidth,
   viewPortHeight = document.getElementsByTagName('body')[0].clientHeight
 }
 return [viewPortWidth, viewPortHeight];
}

function scrollPos(){
	var position = [0, 0];
	if (typeof window.pageYOffset != 'undefined'){
		position = [
			window.pageXOffset,
			window.pageYOffset
		];
	}else if (typeof document.documentElement.scrollTop
		!= 'undefined' && document.documentElement.scrollTop > 0){
			position = [
			document.documentElement.scrollLeft,
			document.documentElement.scrollTop
			];
	}else if (typeof document.body.scrollTop != 'undefined'){
		position = [
			document.body.scrollLeft,
			document.body.scrollTop
		];
	}
	return position;
}

function findPos(obj) {
	try{
		var curtop = 0;
		if (obj.offsetParent) {
			do {
				curtop += obj.offsetTop;
			} while (obj = obj.offsetParent);
		return [curtop];
		}
	}catch(err){return [0];}
}

if ( !Array.prototype.forEach ) {
    Array.prototype.forEach = function(fn, scope) {
        for(var i = 0, len = this.length; i < len; ++i) {
            fn.call(scope, this[i], i, this);
        }
    }
}

if (!Array.prototype.indexOf) {
  Array.prototype.indexOf = function (searchElement , fromIndex) {
    var i,
        pivot = (fromIndex) ? fromIndex : 0,
        length;

    if (!this) {
      throw new TypeError();
    }

    length = this.length;

    if (length === 0 || pivot >= length) {
      return -1;
    }

    if (pivot < 0) {
      pivot = length - Math.abs(pivot);
    }

    for (i = pivot; i < length; i++) {
      if (this[i] === searchElement) {
        return i;
      }
    }
    return -1;
  };
}

function array_unique(array) {
    return $.grep(array, function(el, index) {
        return index === $.inArray(el, array);
    });
}

function qs() {
    var result = {}, keyValuePairs = location.search.slice(1).split('&');

    keyValuePairs.forEach(function(keyValuePair) {
        keyValuePair = keyValuePair.split('=');
        result[keyValuePair[0]] = keyValuePair[1] || '';
    });

    return result;
}

String.prototype.toHHMMSS = function () {
    var sec_num = parseInt(this, 10); // don't forget the second parm
    var hours   = Math.floor(sec_num / 3600);
    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
    var seconds = sec_num - (hours * 3600) - (minutes * 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}
	time = ""
	if (sec_num >= 3600){
		time += hours + ':'
	}
	if (sec_num >= 60){
		time += minutes + ':'
	}
	time += seconds;
    return time;
}

/**
 * Try and parse json out of a string passed in. This is to get around inconsistent responses from svc.
 * @param {string} item sting to parse
 */
function jsonParse(item){
	let retVal = null;
	try {
		retVal = JSON.parse(item);
	} catch (error) {
		//If we are here then we did not get types back from the end point so we need to supress the alert since we dont care
		retVal = null;
	}
	return retVal;
}

/**
 * Add a event handeler to build required fields and display them to the user.
 * @param {object} select The select eliment at add the event hadeler too
 */
function addTypeSelectChangeHandler(select) {
	// we need to get the form to check required fields 
	 select.addEventListener('change', (event) => {
		let form = restCall("/getForm/","POST",{
			"action":"add",
			"collection":event.target.value,
			"parent":{
				"collection":"inventoryItems",
				"id":parseInt( $("#treeAdd").dynatree("getActiveNode").data.key)
				}
			}
		)
		
		$("#requiredFields").empty();
		// once we have the form lets pull out the required fields
		let requiredFields = form.fields.filter(x => x.required)
		console.log(requiredFields)

		//we will now loop through and add them to the dom
		$.each(requiredFields, function(index, field){

			var fieldsToSkip = ["barcode", "amount", "units"];
			if (fieldsToSkip.includes(field.dbName)) {
				return;
			}

			//make the label
			let fieldLabel = createLabel(`${field.formName}*`);
			$("#requiredFields").append(fieldLabel);
			if (field.fieldType == "text") {
				//setup actual amount per container.
				var inputField = document.createElement("input");
				inputField.value = field.value
			}
			else if (field.fieldType == "select") {
				var inputField = createSelectWithOptions( field.dbName, field.options, field.value);
			}
			else if (field.fieldType == "textarea") {
				var inputField = document.createElement("textarea");
				inputField.value = field.value
			}
			else if (field.fieldType == "date") {
				var inputField = document.createElement("input");
				inputField.setAttribute("type", "date")
				inputField.value = field.value
			}
			else if (field.fieldType == "checkbox") {
				var inputField = document.createElement("input");
				inputField.setAttribute("type", "checkbox")
				inputField.value = field.value
			}
			else if (field.fieldType == "file") {
				// TODO: files are out of scope for this ticket. Will need to include this in a leter date. Signed off by Amanda
				return;
			}

			if (inputField) {
				inputField.setAttribute("dbName", field.dbName);
				$("#requiredFields").append(inputField);
			}

		});

	});
	return select;

}

/**
 * Helper function to handle the updates to the sample type dropdown selector.
 * @param {string} target The type of container to add an item to, if possible.
 * @param {string} parentId The ID of the parent element.
 * @param {HTMLElement} formDiv The div that will hold the form.
 * @param {string} theLink The link to the ELN experiment.
 * @param {JSON} autoFillValues Json of values to get automaticly applied to the container
 */
function popupFormGeneator(target, parentId, formDiv, theLink, autoFillValues) {
	// clear any existing form
	clearContainer(formDiv);
	// get a new form from the server 
	getFormFromServer(target, parentId).then(function(response) {
		formBucket.push(response);
		// we need to mask out the "identity" field since we are going to get that info out of band
		var identityField = getIdentityField(response.fields);
	
		response.onSave = function(fd) {
			return function() {
				if (validateForm(fd)) {

					// Figure out what inital name this item should use for the link to inventory.
					var nameToUse = determineBarcodeOrNameValue(fd.fields);

					// Get extra barcodes
					var barcodes = [];
					var promiseArray = [];
					var barcodeStr = $("#barcodeBox").val()
					if (barcodeStr) {
						b = barcodeStr.split("\n");
						for(var i=0;i<b.length;i++){
							if(b[i]!=""){
								promiseArray.push(getFormFromServer(target, parentId));
								barcodes.push(b[i]);
							}
						}
					}

					// WAIT
					$("[formname='Submit']").val("WAIT");

					// get necessary forms
					Promise.all(promiseArray).then(function(forms) {
						// update the fields
						$.each(forms, function(formIndex, form){
							$.each(form.fields, function(filedIndex, item) {
								item.value = fd.fields[filedIndex].value;
							})
							var identity = getIdentityField(form.fields);
							if (identity) {
								var field = form.fields.find(x => x.id == identity.id);
								if (field) {
									field.value = b[formIndex];
								}
							}
							restCall("/updateFields/","POST",{"fields": form.fields});
							//save the forms
							s = saveForm(form, true, theLink);
							form.id = s.newId;
						});
						// Now figure out what the amount to use and what the units are.
						var amountStringArray = [];
						amountStringArray.push(determineAmountValue(fd.fields))
						amountStringArray.push(determineUnits(fd.fields));
						var amountToUse = amountStringArray.join(" ").trim();

						// Save the original form
						s = saveForm(fd, true, theLink);
						fd.id = s.newId;
						// add the form to the rest of the forms
						forms.push(fd);

						var newContainers = [];
						// add the items to the experiment
						$.each(forms, function(index,form) {
							window.parent.addInventoryLink(form["id"], amountToUse, determineBarcodeOrNameValue(form.fields));
							// build final obj for adding to the grid
							//{"id":newId,"name":barcode,"amount":str(D["amount"])+" "+str(D["amountUnits"])}
							newContainers.push({
								"id": form["id"],
								"name": determineBarcodeOrNameValue(form["fields"]),
								"amount": amountToUse
							})
						});
						
						// if chem add to the grid
						if(experimentType==1){
							window.parent.removeInvLinks(args["prefix"]);
							window.parent.makeInvLinks(args["prefix"], newContainers);
						}
						
						// call inv callbacks
						if(window.parent.inventoryAddCallback) {
							window.parent.inventoryAddCallback();
						}
						// refresh inv links
						window.parent.getInventoryLinks();
						// hide the popup
						window.parent.hidePopup("inventoryPopup");
						
					});
					$("[formname='Submit']").val("Submit");
				}
			};
		}(response);	
		
		// if we have values to add
		if (autoFillValues){
			// if we have a structure then add it here so we can get img on load
			if ('moldata' in autoFillValues) {
				
				if (response.fields.find(x => x.formName == "Structure")) {
					$.each(response.fields, function(index, x){
						if (x.formName == "Structure") {
							x.value = {
								"cdxml": autoFillValues.moldata,
								"cd_id": autoFillValues.moldata
							};
							// note since we are pre loading this we want to make it non editable -
							x.readOnly = true;
							return false;
						}
					});
					
				}
			}
		}

		// make the form and add it to the screen
		window.makeForm(response, formDiv, undefined, undefined, undefined, autoFillValues);
		
	});
}

/**
 * since inv is weird we need to do some work to identify the identity field... 
 * for cust. containers this could be marked barcode or name... for default it is by the name of the field... 
 * @param {JSON[]} fields The fields to search through.
 */
function getIdentityField(fields){

	
	// first lets look for barcode fields...
	var barcodeField = fields.find(x => x.isBarcodeField);
	if (barcodeField){
		return barcodeField;
	}

	// we dont have explicit option so try by name 
	barcodeField = fields.find(x => x.dbName == "barcode");
	if (barcodeField){
		return barcodeField;
	}

	// lets look for name fields...
	var nameField = fields.find(x => x.isNameField);
	if (nameField){
		return nameField;
	}

	// we dont have explicit option so try by name 
	barcodeField = fields.find(x => x.dbName == "name");
	if (barcodeField){
		return barcodeField;
	}
	
	// we did not find any identity so return false
	return false;

}

/**
 * Apply values to the form that are outside of the default values.
 * @param {JSON} form The form deffination to apply the values too
 * @param {JSON} values The values that need to get applied 
 */
function autoPopulateValues(form, values) {
	
	console.log(form);
	console.log(values);
	$.each(form.fields, function(index, x){
		
		if ((x.isAmountField || ["amount", "volume", "initialAmount", "initialVolume"].includes(x.isAmountField)) && "ammount" in values ) {
			$(`[formname='${x.formName}']`).val(values.ammount).trigger("onchange");
		}
		else if (x.dbName == "structureId") {
			
			x.value = {
				"cdxml": values.moldata,
				"cd_id": values.moldata
			}

			restCall("/updateField/","POST",x);
			
		}
		else if (x.dbName == "units" && "amountUnits" in values) {
			$(`[formname='${x.formName}']`).val(values.amountUnits).trigger("onchange");
		}
		else {
			if (x.dbName in values) {
				$(`[formname='${x.formName}']`).val(values[x.dbName]).trigger("onchange");
			}
		}
	
	});
	
	
}

function restCall(url,verb,data,returnType){
	var form;
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	form = "url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data))+"&r="+Math.random();
	client.open("POST", "invp.asp?r="+Math.random(), false);
	client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	client.send(form);
	if (client.status == 200){
		if (client.responseText == ""){
			return JSON.parse("{}");
		}else{
			if (returnType == "text/plain"){
				return client.responseText;
			}else{
				r = {};
				try { r = JSON.parse(client.responseText); }
				catch(err) { r["jsError"] = "Please send this error to support@arxspan.com\n" + form + "\n" + err.message; }
				
				if(r.hasOwnProperty("jsError")){
					alert(r["jsError"]);
					return false;
				}

				return r;
			}

		}
	}else{
		return false;
	}
}

function restCallA(url,verb,data,cb,returnType,async){
	var form
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(async!="async"){
		async = "no";
	}
	form = "async="+async+"&url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data))+"&r="+Math.random();
	client.onreadystatechange=(function(client,cb,returnType){
		return function(){
			restCallACb(client,cb,returnType);
		}
	})(client,cb,returnType);
	client.open("POST", "invp.asp?r="+Math.random(), true);
	client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	client.send(form);
	return false;
}

function restCallACb(client,cb,returnType){
	if (client.readyState == 4){
		if (client.status == 200){
			if (client.responseText == ""){
				cb(JSON.parse("{}"));
			}else{
				if (returnType == "text/plain"){
					cb(client.responseText);
				}else{
					r = JSON.parse(client.responseText);
					if(r.hasOwnProperty("jsError")){
						alert(r["jsError"]);
					}
					cb(r);
				}
			}
		}else{
			return false;
		}
	}
}

axTemplateNS = {};

function addMolFromList(casJson_itemId){
	chosenListItemCasJson = window.casJsonData[casJson_itemId];
	//**Disable all the buttons on the result div**//
	var el = document.getElementById("chemAxonResultDiv");
    all = el.getElementsByTagName("button");
    for(i=0; i<all.length; i++) {
		if (i == casJson_itemId){
			all[i].innerText = 'Adding...'
		}
		all[i].disabled = true;
		all[i].style.color='grey';
	}
	
	if (chosenListItemCasJson.hasOwnProperty("cd_id")) {
		pl = {};
		pl["structure"] = chosenListItemCasJson['cd_structure']['structureData']['structure'];
		pl["format"] = "mol:V3";
		x = restCall("/standardizeMol/","POST",pl);
		chosenListItemCasJson['molData'] = x["structure"];

		f = lookupCasNumber_fd.getFieldByFormName("Name");
		el = document.getElementById(f.id)
		var nameFieldValue = ""
		if(typeof chosenListItemCasJson['traditional_name'] !== "undefined" && chosenListItemCasJson['traditional_name'] !== "" && chosenListItemCasJson['traditional_name'] !== null){
			nameFieldValue = chosenListItemCasJson['traditional_name'];
		}
		else{
			nameFieldValue = prompt("There is no \"Traditional Name\" for this CAS number. Please enter the name you would like to use:",chosenListItemCasJson['cd_formula'])
		}
		el.value = nameFieldValue;
		
		el.onchange();

		f = lookupCasNumber_fd.getFieldByFormName("CAS Number");
		el = document.getElementById(f.id)
		el.value = chosenListItemCasJson["cas"];
		el.onchange();
		
		f = lookupCasNumber_fd.getFieldByFormName("Structure");
		updateLiveEditStructureData(f.id, chosenListItemCasJson['molData'], 'mol');
		
		el = document.getElementById("casPopup");
		el.parentNode.removeChild(el); // Close the initial cas lookup popup
		$('#showCasResultsDiv').remove(); // Close the popup w/ table
		blackOff();	
	}
}

function lookupCasNumber(casNumberInputValue){
	console.log("casNumberInputValue: ", casNumberInputValue);

	//document.getElementById("addMolbtn").innerText = "Searching.."
	casDoc = getFile('getCasData.asp?casId='+casNumberInputValue+'&searchType=exactSearch&random='+Math.random());
	
	if ((JSON.parse(casDoc)).data.length > 0) {
		var casJson = ((JSON.parse(casDoc)).data)[0];
		//console.log(casJson)
		if ((JSON.parse(casDoc)).currentSize == 1 ) {	//**Exact search returned single record**//
			if (casJson.hasOwnProperty("cd_id")) {
				pl = {};
				pl["structure"] = casJson['cd_structure']['structureData']['structure'];
				pl["format"] = "mol:V3";
				x = restCall("/standardizeMol/","POST",pl);
				casJson['molData'] = x["structure"];

				f = lookupCasNumber_fd.getFieldByFormName("Name");
				el = document.getElementById(f.id)
				var nameFieldValue = ""
				if(typeof casJson['traditional_name'] !== "undefined" && casJson['traditional_name'] !== "" && casJson['traditional_name'] !== null){
					nameFieldValue = casJson['traditional_name'];
				}
				else{
					nameFieldValue = prompt("There is no \"Traditional Name\" for this CAS number. Please enter the name you would like to use:",casJson['cd_formula'])
				}
				el.value = nameFieldValue;

				el.onchange();

				f = lookupCasNumber_fd.getFieldByFormName("CAS Number");
				el = document.getElementById(f.id)
				el.value = casJson["cas"];
				el.onchange();
				
				f = lookupCasNumber_fd.getFieldByFormName("Structure");
				updateLiveEditStructureData(f.id, casJson['molData'], 'mol');
				
				el = document.getElementById("casPopup");
				el.parentNode.removeChild(el); // Close the initial cas lookup popup
				$('#showCasResultsDiv').remove(); // Close the popup w/ table
				blackOff();
			}
		}
		else {	//**Exact search returned multiple records**//
			jList = (JSON.parse(casDoc)).currentSize;
			window.casJsonData = JSON.parse(casDoc)['data']
			resultHTML = casReturnResultTable(JSON.parse(casDoc), jList);
			
			var showCasResultsPopupHTML = ""
			showCasResultsPopupHTML += '<div id="showCasResultsDiv" class="popupDiv" style="left: 50%;width: 1000px;margin-left: -500px;">'
			showCasResultsPopupHTML += '<div class="popupFormHeader">Search Results</div>'
			showCasResultsPopupHTML += '<a href="javascript:void(0)" onclick="$(this).parent().remove()" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="images/close-x.gif" style="border:none;"></a>'
			showCasResultsPopupHTML += '<div id="chemAxonResultDiv" style="overflow:auto;height:750px;"></div>'
			showCasResultsPopupHTML += '</div>'
			$("#contentTable").append(showCasResultsPopupHTML);
			$('#casLookupSubmitButton').attr("value","Search");
			if (resultHTML != "") {
				document.getElementById("chemAxonResultDiv").innerHTML = resultHTML;
				
				//**Reset the div height depending upon the table height**//
				var table = document.getElementById("displayResults");
				var div = document.getElementById("chemAxonResultDiv");
				if(div.offsetHeight > table.offsetHeight) {
					div.style.height = table.style.height;
				}
				return false;
			}
			else {
				alert("An error occured during the search. Please try again...");
				resetAddMolBtn();
				return false;
			}
		}
	}
	else {
		//** Exact search did not give any results.. Send another request with sub-search **//
		casDocSubSearch = getFile('getCasData.asp?casId='+casNumberInputValue+'&searchType=subSearch&random='+Math.random());
		
		if ((JSON.parse(casDocSubSearch)).currentSize > 1) {
			jList = (JSON.parse(casDocSubSearch)).currentSize;
			window.casJsonData = JSON.parse(casDocSubSearch)['data']
			resultHTML = casReturnResultTable(JSON.parse(casDocSubSearch), jList);
			
			var showCasResultsPopupHTML = ""
			showCasResultsPopupHTML += '<div id="showCasResultsDiv" class="popupDiv" style="left: 50%;width: 1000px;margin-left: -500px;">'
			showCasResultsPopupHTML += '<div class="popupFormHeader">Search Results</div>'
			showCasResultsPopupHTML += '<a href="javascript:void(0)" onclick="$(this).parent().remove()" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="images/close-x.gif" style="border:none;"></a>'
			showCasResultsPopupHTML += '<div id="chemAxonResultDiv" style="overflow:auto;height:750px;"></div>'
			showCasResultsPopupHTML += '</div>'
			$("#contentTable").append(showCasResultsPopupHTML);
			$('#casLookupSubmitButton').attr("value","Search");
			if (resultHTML != "") {
				document.getElementById("chemAxonResultDiv").innerHTML = resultHTML;
				//**Reset the div height depending upon the table height**//
				var table = document.getElementById("displayResults");
				var div = document.getElementById("chemAxonResultDiv");
				if(div.offsetHeight > table.offsetHeight) {
					div.style.height = table.style.height;
				}
				return false;
			}
			else {
				alert("There is an error occured during the Search. Please try again...");
				resetAddMolBtn();
				return false;
			}
		}
		else {
			$('#casLookupSubmitButton').attr("value","Search");
			alert("CAS number not found. Please try another...");
			return false;
		}
	}
}

function casReturnResultTable(obj, jList){
	var resultHTML = "";
	if (obj.data.length > 0) {
		resultHTML = "<table id='displayResults'><tr class='stochHeadRow'><th>CAS Number</th><th>Formula</th><th>Name</th><th>Structure</th><th></th></tr>"
		for(j=0; j<jList; j++){
			var cls = "stochEven"
			if(j % 2 == 1){
				cls = 'stochOdd'
			}
			var casJSON = obj.data[j];
			if (casJSON.hasOwnProperty("cd_id")) {
				resultHTML = resultHTML + "<tr class="+cls+"><td class='caseInnerData'>"+casJSON["cas"] +"</td><td class='caseInnerData'>" + casJSON["cd_formula"] +"</td><td class='caseInnerData'>" + casJSON["traditional_name"] + "</td><td><img src='data:image/png;base64,"+casJSON["cd_structure"]["image"]["image"]+"'></img></td><td class='caseInnerData' align='center'><button id='addResultMolbtn' class='bottomButtons' onclick='addMolFromList("+j+");'>"+window.addLabel+"</button></td></tr>"
			}
		}
		resultHTML = resultHTML + "</table>"
	}
	return resultHTML;
}


function includeJS(sId, fileUrl, source) 
{ 
if ( ( source != null ) && ( !document.getElementById( sId ) ) ){ 
var oHead = document.getElementsByTagName('HEAD').item(0);
var oScript = document.createElement( "script" );
oScript.language = "javascript";
oScript.type = "text/javascript";
oScript.id = sId;
oScript.defer = true;
oScript.text = source;
oHead.appendChild( oScript );
} 
} 

function delayedRunJS(inString,fid)
{
	matches = inString.match(/<.cript[^>]*>([\s\S]*?)<\/.cript>/ig)
	javascriptString = ""
	if(matches)
	{
		for (q=0;q<matches.length ;q++ )
		{
			javascriptString += matches[q].replace(/<.cript[^>]*>/,"").replace(/<\/.cript>/,"") + "\n"
		}
		javascriptString = "axFormId='"+fid+"';\n"+javascriptString;
		theRand = Math.random().toString().replace(".","");
		axTemplateNS[fid] = {};
		javascriptString = javascriptString.replace(/axns\./gi,"axTemplateNS['"+fid+"'].");
		//alert(javascriptString)
		javascriptString = "function misc"+theRand+"_go(){"+javascriptString+"}"
		includeJS('misc'+theRand+'_script','',javascriptString)
		setTimeout("misc"+theRand+"_go()",1)
	}
}

function updateValue(formId,fieldId,value){
	for(var i=0;i<formBucket.length;i++){
		if(formBucket[i].fid==formId){
			fields = formBucket[i].fields;
			for(var j=0;j<fields.length;j++){
				if(fields[j].id==fieldId){
					fields[j].value = value;
					fields[j].onchange();
				}
			}
		}
	}
}

function removeForm(formId){
	for(var i=0;i<formBucket.length;i++){
		if(formBucket[i].fid==formId){
			formBucket.pop(i);
		}
	}
}

function createTextBox(theForm,theField,id,name){
	el = document.createElement("input");
	el.setAttribute("type","text");
	el.setAttribute("id",id);
	el.setAttribute("name",name);
	if(theField["value"]){
		el.setAttribute("value",theField["value"])
	}
	el.onchange = function(){
		theField.value = this.value;
		fixNumbers(theField);
		if(validateField(theField)){
			if (theForm.submitType == "connected"){
				result = restCall("/updateField/","POST",theField)
			}
		}
	};
	return el;
}

function createFieldMapping(theForm,theField,id,name){
	var item;
	el = document.createElement("table");
	el.className = "fieldMappingTable";
	el.setAttribute("id",id);
	el.setAttribute("name",name);
	tBody = document.createElement("tbody");
	tr = document.createElement("tr");
	th = document.createElement("th");
	th.innerHTML = "System Field";
	tr.appendChild(th);
	th = document.createElement("th");
	th.innerHTML = "SD Field";
	tr.appendChild(th);
	if(!theForm["view"]){
		if(theField["options"]["importFields"]){
			tBody.appendChild(tr);
			importFields = theField["options"]["importFields"];
			sdFields = theField["options"]["sdFields"];
			window.latestImportOptions = theField["options"]
			for(var i=0;i<importFields.length;i++){
				tr = document.createElement("tr");
				td = document.createElement("td");
				td.innerHTML = importFields[i];
				tr.appendChild(td);
				td = document.createElement("td");
				select = document.createElement("select");
				select.setAttribute("formName",importFields[i]);
				theOption = document.createElement("option");
				theOption.setAttribute("value","");
				theOption.appendChild(document.createTextNode("--SELECT--"));
				select.appendChild(theOption);
				for(var j=0;j<sdFields.length;j++){
					theOption = document.createElement("option");
					theOption.setAttribute("value",sdFields[j]);
					theOption.appendChild(document.createTextNode(sdFields[j]));
					select.appendChild(theOption);
				}
				select.onchange = (function(el){
					return function(){
						el.onchange()
					}
				})(el)
				td.appendChild(select);
				tr.appendChild(td);
				tBody.appendChild(tr);
			}
		}
	}else{
		tBody.appendChild(tr);
		for (var i=0;i<theField["value"].length;i++ ){
			item = theField["value"][i];
			tr = document.createElement("tr");
			td = document.createElement("td");
			td.innerHTML = item[0];
			tr.appendChild(td);
			td = document.createElement("td");
			td.innerHTML = item[1];
			tr.appendChild(td);
			tBody.appendChild(tr);
		}
	}
	el.appendChild(tBody);
	el.onchange = (function(theField,el){
		return function(){
			theValue = [];
			selects = el.getElementsByTagName("select")
			for(var i=0;i<selects.length;i++){
				select = selects[i];
				//alert(i+" "+select.value)
				if(select.value!=""){
					theValue.push([select.getAttribute("formName"),select.options[select.selectedIndex].value]);
				}
			}
			theField.value = theValue;
			if(validateField(theField)){
				if (theForm.submitType == "connected"){
					result = restCall("/updateField/","POST",theField)
				}
			}
		};
	})(theField,el)
	return el;
}

function createErrorTable(theForm,theField,id,name){
	if(theField.value.length!=0){
		el = document.createElement("table");
		el.className = "errorTable";
		el.setAttribute("id",id);
		el.setAttribute("name",name);
		tBody = document.createElement("tbody");
		tr = document.createElement("tr");
		th = document.createElement("th");
		th.innerHTML = "Record Number";
		tr.appendChild(th);
		th = document.createElement("th");
		th.innerHTML = "Structure";
		tr.appendChild(th);
		th = document.createElement("th");
		th.innerHTML = "Errors";
		tr.appendChild(th);
		tBody.appendChild(tr);
		tr = document.createElement("tr");
		td = document.createElement("td");
		td.setAttribute("colspan","3");
		td.innerHTML = "Errors found in import file.  No records imported";
		tr.appendChild(td);
		tBody.appendChild(tr);
		for (var i=0;i<theField["value"].length;i++ ){
			item = theField["value"][i];
			tr = document.createElement("tr");
			td = document.createElement("td");
			td.innerHTML = item["recordNumber"];
			tr.appendChild(td);
			td = document.createElement("td");
			field = {"value":item["structure"],"insertFormat":"text/xml","dims":[100,100]}
			td.appendChild(createTableChemBox(null,field,item["recordNumber"]+"errorTable",item["recordNumber"]+"errorTable"));
			tr.appendChild(td);
			td = document.createElement("td");
			td.innerHTML = item["errorReasons"].join("<br/>");
			tr.appendChild(td);
			tBody.appendChild(tr);
		}
		el.appendChild(tBody);
		return el;
	}else{
		el = document.createElement("span");
		el.innerHTML = "No errors found.  File imported successfully";
		return el;
	}
}

function createDateBox(theForm,theField,id,name){
	el = document.createElement("input");
	el.setAttribute("type","text");
	el.setAttribute("id",id);
	el.setAttribute("name",name);
	if(theField["value"]){
		el.setAttribute("value",theField["value"])
	}
	if(!isNaN(parseInt(theField["autoPopulateField_days"])) && theField["value"] == "" && $('#arxOneContainer').attr('latestaction') !== "edit"){
		if(typeof theField['autoPopulateField_days'] !== "undefined" && typeof theField['autoPopulateField_beforeOrAfter'] !== "undefined"){
			if(theField['autoPopulateField_beforeOrAfter'] == "before"){
				momentBeforeAfter = moment().subtract(parseInt(theField['autoPopulateField_days']),'days').format('MM/DD/YYYY');
			}
			else{
				momentBeforeAfter = moment().add(parseInt(theField['autoPopulateField_days']),'days').format('MM/DD/YYYY');
			}
			el.setAttribute("value",momentBeforeAfter)
		}
	}
	el.onchange = function(){
		theField.value = this.value;
		fixNumbers(theField);
		if(validateField(theField)){
			if (theForm.submitType == "connected"){
				result = restCall("/updateField/","POST",theField)
			}
		}
	};
	return el;
}

function createButton(theForm,theField,id,name){
	el = document.createElement("input");
	el.setAttribute("type","button");
	el.setAttribute("id",id);
	el.setAttribute("name",name);
	el.setAttribute("value",theField["formName"])
	el.onclick = function(){
		if(confirm('Are you sure?')){
			theField.value = this.value;
			if (theForm.submitType == "connected"){
				result = restCall("/updateField/","POST",theField)
			}
		}
	};
	return el;
}

function createActionButton(theForm,theField,id,name,containerName){
	console.log(theForm);
	console.log(theField);
    console.log(id);
	console.log(name);
	console.log(containerName);
	
	if (theForm["isReadOnly"]) {
		console.log("form is read only, not creating button");
		return document.createElement("span");
	}		
	
	if (theForm["disableEdit"] && theField["action"]["action"]=="edit") {
		console.log("editing is disabled, not creating edit button");
		return document.createElement("span");
	}
	
	if(!(theField["action"]["action"]=="edit"&&!canEdit)){
		console.log('creating input field ' + theField["action"]["action"]);
		if (theForm.hasOwnProperty("active")) {
			console.log(theForm["active"]);
			if (!theForm["active"]) {
				var inx = ["edit","move","copy","dispose","checkout","checkin","sample","use"].indexOf(theField["action"]["action"]);
				if (inx != -1) {
					console.log("not creating button");
					return document.createElement("span");
				}
			}
		}

		el = document.createElement("input");
		el.setAttribute("type","button");
		el.setAttribute("id",id);
		el.setAttribute("name",name);
		el.setAttribute("value",theField["formName"])
		el.onclick = function(){
			if(!theField["action"]["showInTable"]){
				containerName = false;
			}
			actionFunctions(theField["action"]["action"],theForm,false,containerName)
		};
	}else{
		el = document.createElement("span")
	}
	return el;
}

function createPasswordBox(theForm,theField,id,name){
	el = document.createElement("input");
	el.setAttribute("type","password");
	el.setAttribute("id",id);
	el.setAttribute("name",name);
	if(theField["value"]){
		el.setAttribute("value",theField["value"])
	}
	el.onchange = function(){
		theField.value = this.value;
		if(validateField(theField)){
			if (theForm.submitType == "connected"){
				result = restCall("/updateField/","POST",theField)
			}
		}
	};
	return el;
}

function createSelect(theForm,theField,id,name){
	el = document.createElement("select");
	el.setAttribute("id",fieldId);
	el.setAttribute("name",fieldId);
	// 10122: Support dropdown with multiple selected values. But in this implementation, we only set multiplevalues to true.
	el.multiple = theField.multiple || theField.multipleValues;
	// I think the default size for a multiple dropdown is 4 and that seemed to override the Height option. Increase it.
	if (el.multiple && thisField["options"].length >= 10) {
		el.setAttribute("size", "10");
	}

	var foundMatch = false;
	var foundOther = false;
	var foundOther_optionId = "";
	if (!theField.multiple && !theField.multipleValues) { // 10122
		theOption = document.createElement("option");
		theOption.setAttribute("value","");
		theOption.appendChild(document.createTextNode("--SELECT--"));
		el.appendChild(theOption)
	}
	for(var j=0;j<thisField["options"].length;j++){
		if($.isArray(thisField["options"][j])){
			thisValue = thisField["options"][j][0];
			thisText =  thisField["options"][j][1];			
		}else{
			thisValue = thisField["options"][j];
			thisText =  thisField["options"][j];
		}
		
		thisOptionId = "";
		if(typeof thisField["optionIds"] !== "undefined" && typeof thisField["optionIds"][thisText] !== "undefined"){
			thisOptionId = thisField["optionIds"][thisText];
			if(thisText.toLowerCase() == "other"){
				foundOther = true;
				foundOther_optionId = thisOptionId;
			}
		}
		theOption = document.createElement("option");
		theOption.setAttribute("value",thisValue);
		theOption.setAttribute("fieldOptionId",thisOptionId);
		theOption.appendChild(document.createTextNode(thisText));
		if (theField.multiple || theField.multipleValues) { // 10122
			if (theField["value"].indexOf(thisValue)!=-1){
				theOption.selected = true;
				foundMatch = true; // INV-161
			}
		}else{
			if (thisValue == theField["value"]){
				theOption.selected = true;
				foundMatch = true; // INV-161
			}
		}
		el.appendChild(theOption)
	}

	// INV-161
	if(foundMatch == false && foundOther == true && theField["value"] !== ""){
		theOption = document.createElement("option");
		//console.log(theField["value"]);
		theOption.setAttribute("value",theField["value"]);
		theOption.setAttribute("fieldOptionId",foundOther_optionId)
		theOption.appendChild(document.createTextNode(theField["value"]));
		theOption.selected = true;
		//console.log(theOption);
		el.appendChild(theOption)
	}

	if (theField.multiple || theField.multipleValues) { // 10122
		el.onchange = function(){
			vals = [];
			Array.prototype.push.apply(vals, $(this).val());
			theField.value = vals;
			if(validateField(theField)){
				if (theForm.submitType == "connected"){
					result = restCall("/updateField/","POST",theField)
				}
			}
			// 10122: piggyback on the existing error field to display the selected options.
			$('#' + theField.id + '_error').html("<b>Selected Options:</b><br/>" + vals.join("<br/>"));   
		};
		// 10122: use the mousedown event to free users from having to hold the ctrl key in multi-select box.
		el.onmousedown = function (e) {
			e.preventDefault();
			var elm = e.target;
			// toggle selection
			elm.selected = !elm.selected;
			var scrollTop = elm.parentNode.scrollTop;
			// trigger a change event to update the selections
			$('#' + theField.id).change();
			// The change event would cause the dropdown to scroll to the first selected option. This seems to fix it.
			setTimeout(() => elm.parentNode.scrollTo(0, scrollTop), 0);
		};
	}else{
		el.onchange = function(){
			theField.value = this.options[this.selectedIndex].value;
			if(validateField(theField)){
				if (theForm.submitType == "connected"){
					result = restCall("/updateField/","POST",theField)
					for(var i=0;i<result["reloadFields"].length;i++){
						fn = result["reloadFields"][i];
						thisField = currentFD.getFieldByFormName(fn);
						thisField.updateValue();
						fieldId = thisField["id"];
						fieldEl = document.getElementById(fieldId);
						parentEl = fieldEl.parentNode;
						r = makeField(currentFD,thisField,fieldId);
						if(r["el"]){
							parentEl.replaceChild(r["el"],fieldEl);
						}
					}
				}
			}
		};
	}
	console.log("CREATE SELECT ELEMENT &&&&&&&&&&", el)
	return el;
}

//INV-316 creating the dropdown for the available printers
function createPrinterListSelect(pList, printerName){
	el = document.createElement("select");
	el.setAttribute("id","printerList");
	el.setAttribute("name","printerList");
	el.setAttribute("class","ax1-select1");
	el.setAttribute("formname","Printer List");
		
	var foundMatch = false;
	
	theOption = document.createElement("option");
	theOption.setAttribute("value","");
	theOption.appendChild(document.createTextNode("--SELECT--"));
	el.appendChild(theOption)
		
	for(var j=0;j<pList.length;j++){
		thisValue = pList[j];
		thisText =  pList[j];
				
		theOption = document.createElement("option");
		theOption.setAttribute("value",thisValue);
		theOption.setAttribute("fieldOptionId",thisValue);
		theOption.appendChild(document.createTextNode(thisText));
		
		if (thisValue == printerName){
			theOption.selected = true;
			foundMatch = true; 
		}
		el.appendChild(theOption)
	}

	el.onchange = function(){
		updatedPrinterName = this.options[this.selectedIndex].value;
		console.log("ON PRINTER CHANGE :::::::", updatedPrinterName);
		window.itemJSON.printerName = updatedPrinterName;
		console.log("printerName :::", printerName);
		if(printerName == "None"){	//There is no default printer selected for this user - update it with new selection
			console.log("Before printer update");
			updateResponse = getFile('getPrinterDetails.asp?updatedPrinterName='+updatedPrinterName+'&random='+Math.random());
			console.log("updateResponse ::", updateResponse)
		}
	};
	return el;
}

function showPrinterNameText(printerName){
	el = document.createElement("span");
	el.setAttribute("id","printerName");
	el.setAttribute("class","ax1-text1");
	el.setAttribute("formname","Printer Name");
	el.innerHTML = printerName;
	
	return el;
}


function fixNumbers(theField){
	if (theField.dbType=="actual_number" && theField.value!=""){
		theField.value = parseFloat(theField.value);
	}
}

function createTextArea(theForm,theField,id,name){
	el = document.createElement("textarea");
	el.setAttribute("id",id);
	el.setAttribute("name",name);
	if(theField["value"]){
		el.value = theField["value"];
	}
	if (theField["dims"]){
		el.style.width = theField["dims"][0]+"px";
		el.style.height = theField["dims"][1]+"px";
	}
	el.onchange = function(){
		theField.value = this.value;
		if(validateField(theField)){
			if (theForm.submitType == "connected"){
				result = restCall("/updateField/","POST",theField)
			}
		}
	};
	return el;
}


function createFileBox(theForm,theField,id,name){
	el = document.createElement("iframe");
	el.setAttribute("id",id+"_frame");
	el.setAttribute("name",name+"_frame");
	src = "upload_file_frame.asp?formId="+theForm.fid+"&fieldId="+theField.id+"&readonly="+theForm["view"]+"&connectionId="+connectionId;
	if(theField.value != ""){
		src+="&fileId="+theField.value+"&collection="+theField.collection;
	}
	el.setAttribute("src",src)
	el.style.border="none";
	if (theField["dims"]){
		el.setAttribute("width",theField["dims"][0]+30);
		el.setAttribute("height",theField["dims"][1]+30);
	}
	theField.onchange = function(){
		if(validateField(theField)){
			if (theForm.submitType == "connected"){
				result = restCall("/updateField/","POST",theField)
				for(var i=0;i<result["reloadFields"].length;i++){
					fn = result["reloadFields"][i];
					thisField = currentFD.getFieldByFormName(fn);
					thisField.updateValue();
					fieldId = thisField["id"];
					fieldEl = document.getElementById(fieldId);
					parentEl = fieldEl.parentNode;
					r = makeField(currentFD,thisField,fieldId);
					if(r["el"]){
						parentEl.replaceChild(r["el"],fieldEl);
					}

				}
			}
		}
	};
	return el;
}

function createChemBox(theForm,theField,id,name){
	var structureWidth = 200;
	var structureHeight = 200;
	if (theField["dims"])
	{
		structureWidth = theField["dims"][0]+30;
		structureHeight = theField["dims"][1]+30;
	}

	var initialMolData = "";
	if(theField.hasOwnProperty("value") && theField.value != null && theField["value"].hasOwnProperty("cdxml"))
		initialMolData = theField["value"]["cdxml"];

	var el = document.createElement('div');
	el.setAttribute("id", id + "_chemBox");
	getChemistryEditorMarkup(id, "", initialMolData, structureWidth, structureHeight, (theForm["view"] || theField.readOnly), null, null, null, null, null, null, true)
		.then(function (theHtml) {
			el.innerHTML = theHtml;
		});

	if(theForm.action != "view")
	{
		if((!theField.hasOwnProperty("intervals")) || theField["intervals"] == null)
			theField["intervals"] = [];
		
		theField["intervals"].push(window.setInterval(function(){
			if (theField.value=="" || theField.value==null){
				theField.value = {};
			}
				
			var startingCdId = "";
			if(theField.hasOwnProperty("value") && theField.value != null && theField["value"].hasOwnProperty("cd_id")){
				startingCdId = theField["value"]["cd_id"];
			}
				
			getChemistryEditorChemicalStructure(id, false, "cdx").catch(function(e){
				
				//Do nothing because this gets called a lot
				//console.log("Error getting chemistry editor structure");
				//console.log(e);
			}).then(function(currentData){
				if(startingCdId != currentData)
				{
					theField["value"]["cd_id"] = currentData;
					theField["value"]["cdxml"] = theField["value"]["cd_id"];
					
					if(validateField(theField)){
						if (theForm.submitType == "connected"){
							result = restCall("/updateField/","POST",theField)
						}
					}
				}
			});
			
		}, 500));
	}
		
	return el;
}

function createTableChemBox(theForm,theField,id,name){
	var initialMolData = "";
	if(theField.hasOwnProperty("value") && theField.value != null && theField["value"].hasOwnProperty("cdxml"))
		initialMolData = theField["value"]["cdxml"];

	var el = document.createElement('div');
	getChemistryEditorMarkup(id, "", initialMolData, 100, 100, true, null, null, null, null, null, null, true)
		.then(function (theHtml) {
			el.innerHTML = theHtml;
		});

	return el;
}

function createCheckBox(theForm,theField,id,name){
	el = document.createElement("input");
	el.setAttribute("type","checkbox");
	el.setAttribute("id",id);
	el.setAttribute("name",name);
	if(theField["value"]){
		el.checked=theField["value"];
	}
	el.onchange = function(){
		theField.value = this.checked ? true : false;
		if(validateField(theField)){
			if (theForm.submitType == "connected"){
				result = restCall("/updateField/","POST",theField)
			}
		}
	};
	return el;
}

function urlify(text) {
    var urlRegex = /(^https?:\/\/[^\s]+)/g;
    q = text.replace(urlRegex, function(url) {
        return '<a href="' + url + '">' + url + '</a>';
    })
    var urlRegex = /(^www\.[^\s]+)/g;
    q = q.replace(urlRegex, function(url) {
        return '<a href="http://' + url + '">' + url + '</a>';
    })
	return q;
}

function showText(theForm,theField,id,name,displayKey){
	el = document.createElement("span");
	el.setAttribute("id",id);
	if ((theField.fieldType == "select" && (theField.multiple || theField.multipleValues))||theField.fieldType == "multiText"){
		val = "";
		for(j=0;j<theField.value.length;j++){
			val += theField.value[j]+"<br/>";
		}
		el.innerHTML = val;
	}else{
		val = theField.value;
		if(theField.textFilter=="wellLocation"){
			if(val.colPos <10){
				val = String.fromCharCode(64+val.rowPos)+"0"+val.colPos;
			}else{
				val = String.fromCharCode(64+val.rowPos)+val.colPos;
			}
		}
		if(!!displayKey){
			val = val[displayKey];
		}
		// INV-177
		if(theField.formName.toLowerCase() == "registration id"){
			regId = val;
			if (regId != "") {
				// 5525: Don't display the ending batch number "-00". This is what we are doing in ShowBatch.asp as well.
				regIdDisplayed = removeBatchNumberFromRegId(regId);
				val = "<a href='javascript:void(0)' class='regLink' onclick='toggleRegData(\"" + id + "\",\"" + regId + "\")'>" + regIdDisplayed + "</a>"
				val += "<a href='/arxlab/registration/showRegItem.asp?regNumber="+regId+"' class='regLink' target=\"_blank\"><img class='openInNewWindowImg' src='/arxlab/images/open_new_window.png' /></a>";
			}
		}
		if(theField.formName.toLowerCase() == "notebook page"){
			if (val!=""){
				val = "<a href='/arxlab/experiments/experimentByName.asp?name="+val+"' class='regLink'>"+val+"</a>";
			}
		}
		try{
			el.innerHTML = val.replace("\n","<br/>");
		}catch(err){
			el.innerHTML = val;
		}
	}
	return el;
}

function toggleRegData(id,regNumber){
	if($("#"+id).parent().parent().find(".regData"+id).length){
		$("#"+id).parent().parent().find(".regData"+id).remove()
	}else{
		$.get("/arxlab/registration/getRegJSON.asp?regNumber="+regNumber+"&random="+Math.random())
			.done(function(regJSON){
				L = JSON.parse(regJSON)
				theStr = "";
				for (var i=0;i<L.length;i++){
					val = L[i]["fieldValue"];
					if(!val && val!==0){
						val = "";
					}
					theStr += "<div class='templateText regData"+id+"'><label class='ax1-text-label'>"+L[i]["fieldName"]+"</label><span class='ax1-text'>"+val+"</span></div>";
				}
				$(theStr).insertAfter($("#"+id).parent());
			});
	}
}

function showProductId(theForm,theField,id,name,displayKey){
	if(theField.value!=""){
		theField.value = theField.value.substring(1,theField.value.length);
		experimentName = theField.value.split("-")[0]+" - "+theField.value.split("-")[1]
		el = document.createElement("a");
		el.setAttribute("id",id);
		el.setAttribute("href","/arxlab/experiments/experimentByName.asp?name="+experimentName);
		el.setAttribute("target","new");
		el.innerHTML = "C"+theField.value;
	}else{
		el = document.createElement("span");
	}
	return el;
}

function showReactantIds(theForm,theField,id,name,displayKey){
	if(theField.value!=""){
		el = document.createElement("div")
		for(var i=0;i<theField.value.length;i++){
			experimentName = theField.value[i].split("-")[0]+" - "+theField.value[i].split("-")[1]
			a = document.createElement("a");
			a.setAttribute("id",id);
			a.setAttribute("href","/arxlab/experiments/experimentByName.asp?name="+experimentName);
			a.setAttribute("target","new");
			a.innerHTML = theField.value[i];
			el.appendChild(a);
			el.appendChild(document.createElement("br"))
		}
	}else{
		el = document.createElement("span");
	}
	return el;
}

function pad(num, size) {
    var s = "000000000" + num;
    return s.substr(s.length-size);
}

function createItemGrid(theForm,theField,id,name){
	rows = [];
	cols = [];
	for(var i=0;i<theForm.fields[theForm.fieldNames.indexOf("Number Of Columns")].value;i++){
		cols.push(pad(i+1,2));
	}
	for(var i=0;i<theForm.fields[theForm.fieldNames.indexOf("Number Of Rows")].value;i++){
		rows.push(String.fromCharCode(65+i));
	}
	el = document.createElement("table");
	el.setAttribute("id","itemGrid_"+id);
	el.setAttribute("class","plateMap ax1-plateMap")
	tbody = document.createElement("tbody");
	tr = document.createElement("tr");
	tr.className="odd";
	td = document.createElement("td");
	td.innerHTML = "&nbsp;";
	tr.appendChild(td);
	for(var i=0;i<cols.length;i++){
		td = document.createElement("td");
		td.appendChild(document.createTextNode(cols[i]));
		tr.appendChild(td);
	}
	tbody.appendChild(tr);
	for(var i=0;i<rows.length;i++){
		tr = document.createElement("tr");
		td = document.createElement("td");
		td.appendChild(document.createTextNode(rows[i]));
		tr.appendChild(td);
		if(i%2==0){
			tr.className = "even";
		}else{
			tr.className = "odd";
		}
		for(var j=0;j<cols.length;j++){
			td = document.createElement("td");
			span = document.createElement("span");
			span.setAttribute("id","itemGrid_"+id+"_"+String.fromCharCode(65+i)+pad(j+1,2));
			span.appendChild(document.createTextNode("x"));
			td.appendChild(span);
			tr.appendChild(td);
		}
		tbody.appendChild(tr)
	}
	el.appendChild(tbody);

	payload2 = {}
	query = {"parent.id":theForm.id,"disposed":false,"checkedOut":false}
	payload2["rpp"] = 1000;
	payload2["collection"] = "inventoryItems";
	payload2["list"] = true;
	payload2["query"] = query;
	payload2["action"] = "next";
	restCallA("/getList/","POST",payload2,function(r){
		listForms = r["forms"];
			if(theField.options["nameField"].indexOf(",")!=-1){
				theField.options["nameField"] +=",Cell Line Name";
			}
		for(var i=0;i<listForms.length;i++){
			//console.log("----------------------------------------------");
			var fd = listForms[i];
			//console.log("FD:",fd);
			//console.log("theField: ",theField);
			a = document.createElement("a");
			
			// look for name field
			var foundNameField = false;
			for (var x = 0; x < fd.fields.length; x++) {
				if (fd.fields[x].isNameField) {
					//console.log("FOUND NAME FIELD: ", fd.fields[x].formName, " X: ",x," VALUE: ",fd.fields[x].value);
					nameValue = fd.fields[x].value;
					foundNameField = true;
					break;
				}
			}
			
			if (!foundNameField) {
				if(theField.options["nameField"].indexOf(",")!=-1){
					names = theField.options["nameField"].split(",");
					//console.log("names: ",names);
					for(var q=0;q<names.length;q++){
						if(fd.fieldNames.indexOf(names[q])!=-1) {
							tval = fd.fields[fd.fieldNames.indexOf(names[q])].value;
							if (tval && tval !== '') {
								nameValue = fd.fields[fd.fieldNames.indexOf(names[q])].value;
								
								//console.log("SETTING NAME VALUE TO: ",nameValue);
								//console.log("Q:",q,"XYZ: ",fd.fields[fd.fieldNames.indexOf(names[q])]);
								break;
							}
							//console.log("nameValue:", nameValue," name:",names[q]);
							//break;
						}
						// reverting the fix to display name in grid box
						//break;
					}
				}else{
					//console.log("else nameValiue: ",nameValue);
					nameValue = fd.fields[fd.fieldNames.indexOf(theField.options["nameField"])].value;
				}
			}
			a.innerHTML = nameValue;
			a.href="javascript:void(0)";
			a.onclick = (function(fd){
				return function(){
					//document.getElementById("wellView").style.left="-1000px";
					showTable = false;
					if(fd.fieldNames.indexOf("_numChildren")!=-1){
						if(fd.fields[fd.fieldNames.indexOf("_numChildren")].value>0){
							showTable = true;
						}
					}
					handleLink(fd.id,fd.fields[fd.fieldNames.indexOf("_invType")].value,showTable,fd.parentTree)
				}
			})(fd);
			loc = fd.fields[fd.fieldNames.indexOf("Grid Location")].value;
			cell = document.getElementById("itemGrid_"+id+"_"+loc);
			if(cell){
				cell.innerHTML = '';
				cell.appendChild(a);
			}
		}
	});

	return el;
}

function createAddChildLink(theForm,theField,id,name){
	el = document.createElement("a");
	el.setAttribute("id",id);
	el.innerHTML = theField["formName"];
	opts = theField["options"];
	el.href='aev.asp?c='+opts["collection"]+"&pc="+opts["parentCollection"]+"&pid="+opts["parentId"];
	return el;
}

function createPlateMap(theForm,theField,id,name){
	rows = [];
	cols = [];
	for(var i=1;i<=theField.value["wellsPerCol"];i++){
		if(i<10){
			cols.push("0"+i);
		}else{
			cols.push(i);
		}
	}
	for(var i=0;i<theField.value["wellsPerRow"];i++){
		rows.push(String.fromCharCode(65+i));
	}
	el = document.createElement("table");
	el.setAttribute("id","plateMap_"+id);
	el.className = "plateMap";
	tbody = document.createElement("tbody");
	//tbody.onmouseout=function(){document.getElementById("wellView").style.left="-1000px";}
	tr = document.createElement("tr");
	tr.className="odd";
	td = document.createElement("td");
	td.innerHTML = "&nbsp;";
	tr.appendChild(td);
	for(var i=0;i<cols.length;i++){
		td = document.createElement("td");
		td.appendChild(document.createTextNode(cols[i]));
		tr.appendChild(td);
	}
	tbody.appendChild(tr);
	for(var i=0;i<rows.length;i++){
		tr = document.createElement("tr");
		td = document.createElement("td");
		td.appendChild(document.createTextNode(rows[i]));
		tr.appendChild(td);
		if(i%2==0){
			tr.className = "even";
		}else{
			tr.className = "odd";
		}
		for(var j=0;j<cols.length;j++){
			td = document.createElement("td");
			span = document.createElement("span");
			span.setAttribute("id","plateMap_"+id+"_"+(i+1)+"_"+(j+1));
			span.appendChild(document.createTextNode("x"));
			td.appendChild(span);
			tr.appendChild(td);
		}
		tbody.appendChild(tr)
	}
	el.appendChild(tbody);
	
	payload2 = {}
	query = {"_invType":"well","parent.id":theForm.id}
	payload2["rpp"] = 1000;
	payload2["collection"] = "inventoryItems";
	payload2["list"] = true;
	payload2["query"] = query;
	payload2["action"] = "next";
	restCallA("/getList/","POST",payload2,function(r){
		listForms = r["forms"];
		for(var i=0;i<listForms.length;i++){
			var fd = listForms[i];
			//alert(JSON.stringify(fd))
			//alert(JSON.stringify(fd.fieldNames));
			compounds = fd.fields[fd.fieldNames.indexOf("Compounds")].value;
			//alert(compounds)
			if(compounds.length){
				a = document.createElement("a");
				a.innerHTML = compounds[0]["compound_id"];
				a.href="javascript:void(0)";
				a.onclick = (function(fd){
					return function(){
						//document.getElementById("wellView").style.left="-1000px";
						showTable = false;
						if(fd.fieldNames.indexOf("_numChildren")!=-1){
							if(fd.fields[fd.fieldNames.indexOf("_numChildren")].value>0){
								showTable = true;
							}
						}
						handleLink(fd.id,fd.fields[fd.fieldNames.indexOf("_invType")].value,showTable,fd.parentTree)
					}
				})(fd);
				a.onmouseover = (function(fd){
					return function(){
						wv = document.getElementById("wellView");
						leftC = mouse[0]-scrollPos()[0];
						topC = mouse[1]-scrollPos()[1];
						if(leftC+wv.clientWidth>getViewport()[0]){
							leftC -= wv.clientWidth+10;
						}
						if(topC+wv.clientHeight>getViewport()[1]){
							topC -= wv.clientHeight+10;
						}
						wv.style.left = (leftC+6)+"px";
						wv.style.top = (topC+6)+"px";
						wv.style.display = "block";
						clearContainer("wellView");
						makeForm(fd,"wellView",true);
						compounds = fd.fields[fd.fieldNames.indexOf("Compounds")].value;
						pl = {"action":"view","collection":"compound","id":compounds[0]["compound_id"],"little":true};
						addObjectForm = restCall("/getForm/","POST",pl);
						makeForm(addObjectForm,"wellView");
									$("#wellView").mouseenter(function(){
										$("#wellView").mouseleave(function(){
											$("#wellView").css({'left':-1000+'px'});
											clearContainer("wellView");
										})						
									})
					}
				})(fd);
				loc = fd.fields[fd.fieldNames.indexOf("Location")].value;
				cell = document.getElementById("plateMap_"+id+"_"+loc["rowPos"]+"_"+loc["colPos"]);
				if(cell){
					cell.innerHTML = '';
					cell.appendChild(a);
				}
			}
		}
	});

	return el;
}

function createShowChildLinks(theForm,theField,id,name){
	el = document.createElement("div");
	for(j=0;j<theField.value.length;j++){
		opts = theField.value[j];
		a = document.createElement("a");
		if(opts["linkText"]!=""){
			a.innerHTML = opts["linkText"];
		}else{
			a.innerHTML = "Untitled"
		}
		a.href='aev.asp?c='+opts["collection"]+"&id="+opts["id"]+"&view=true";
		//this should be in the style sheet
		a.style.display = "block";
		el.appendChild(a);
	}
	return el;
}

function makeMultiHolder(id,num,theField){
	div = document.createElement("div");
	div.setAttribute("id",id+"_holder_"+num);
	div.className = "multiHolder";
	input = document.createElement("input");
	input.setAttribute("type","text");
	input.setAttribute("id",id+"_"+num);
	input.onchange = function(){
		theField.value[num] = this.value;
		theField.onchange();
	}
	if (num<theField.value.length){
		input.value = theField.value[num];
	}
	a = document.createElement("a");
	a.setAttribute("href","javascript:void(0);");
	a.setAttribute("fieldNumber",num);
	a.setAttribute("fieldId",id);
	a.onclick = function(){
		fieldNumber = this.getAttribute("fieldNumber");
		fieldId = this.getAttribute("fieldId");
		removeEl = document.getElementById(fieldId+"_holder_"+fieldNumber);
		removeEl.parentNode.removeChild(removeEl);
		theField.value[fieldNumber] = null;
		theField.onchange();
	}
	img = document.createElement("img");
	img.src = "images/delete.gif";
	a.appendChild(img);
	theField.numTexts += 1;
	div.appendChild(input);
	div.appendChild(a);
	return div;
}

function createMultiText(theForm,theField,id,name){
	el = document.createElement("div");
	el.setAttribute("id",id);
	el.className = "multiText";
	theField.numTexts = 0;
	for(var i=0;i<theField.value.length;i++){
		div = makeMultiHolder(id,i,theField);
		el.appendChild(div);
	}
	a = document.createElement("a");
	a.setAttribute("href","javascript:void(0);");
	a.onclick = function(){
		theField.value.push("");
		div = makeMultiHolder(id,theField.numTexts,theField)
		document.getElementById(id).insertBefore(div,this);
	};
	img = document.createElement("img");
	img.src = "images/add.gif";
	a.appendChild(img);
	el.appendChild(a);
	theField.onchange = function(){
		oldValue = theField.value;
		newValue = [];
		for(var i=0;i<theField.value.length;i++){
			if(theField.value[i]!=null){
				newValue.push(theField.value[i]);
			}
		}
		theField.value = newValue;
		if (theForm.submitType == "connected"){
			result = restCall("/updateField/","POST",this);
		}
		theField.value = oldValue;
	}
	return el;
}

function createChildLinks2(theForm,theField,id,name,view){
	el = document.createElement("div");
	el.setAttribute("id",id);
	if(!view){
		a = document.createElement("a");
		a.innerHTML = "Add Link";
		a.setAttribute("href","javascript:void(0);");
		a.onclick = function(){
			globalLinkTarget = theField;
			linkPopOpen(theField["options"].collection);
		};
		el.appendChild(a);
	}
	el.appendChild(buildInnerLinks(theForm,theField,id,view));
	el.appendChild(div);
	theField.onchange = function(){
		oldValue = theField.value;
		newValue = [];
		for(var i=0;i<theField.value.length;i++){
			if(theField.value[i]!=null){
				newValue.push(theField.value[i]["id"]);
			}
		}
		theField.value = newValue;
		if (theForm.submitType == "connected"){
			result = restCall("/updateField/","POST",this);
		}
		theField.value = oldValue;
	}
	return el;
}

//invPerm
function drawPerms(theField){
	div = document.createElement("div");
	div.className = "permView"
	div.setAttribute("id",theField.id+"_perm");
	if (theField.value!=""){
		if(theField.value.hasOwnProperty("groupNames")){
			if(theField.value.groupNames.length>0){
				h3 = document.createElement("h3");
				h3.innerHTML = "Groups";
				div.appendChild(h3);
				ul = document.createElement("ul");
				for(var i=0;i<theField.value.groupNames.length;i++){
					li = document.createElement("li");
					li.innerHTML = theField.value.groupNames[i];
					ul.appendChild(li);
				}
				div.appendChild(ul);
			}
		}
		if(theField.value.hasOwnProperty("userNames")){
			if(theField.value.userNames.length>0){
				h3 = document.createElement("h3");
				h3.innerHTML = "Users";
				div.appendChild(h3);
				ul = document.createElement("ul");
				for(var i=0;i<theField.value.userNames.length;i++){
					li = document.createElement("li");
					li.innerHTML = theField.value.userNames[i];
					ul.appendChild(li);
				}
				div.appendChild(ul);
			}
		}
	}
	return div
}

function createPermissions(theForm,theField,id,name,view){
	el = document.createElement("div");
	el.setAttribute("id",id);
	if(!view){
		a = document.createElement("a");
		a.innerHTML = "Edit";
		a.setAttribute("href","javascript:void(0);");
		a.onclick = function(){
				blackOn();
				popup = newPopup("permPopup");
				popup.style.width="300px"
				popup.style.height="300px"
				label = document.createElement("label");
				label.innerHTML = "Users";
				popup.appendChild(label);
				div = document.createElement("div");
				popup.appendChild(div);
				$.get("../_inclds/common/html/groupListStandAlone.asp",(function (div,theField){ 
					return function (data){
					$(div).html(data);
					populatePerms(theField.value)
				}})(div,theField)
				);
				
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(theField){
					return function(){
						theField.value = getPermValue(theField);
						result = restCall("/updateField/","POST",theField);
						$("#"+theField.id+"_perm").replaceWith(drawPerms(theField));
						el = document.getElementById("permPopup");
						el.parentNode.removeChild(el);
						blackOff();
					}
				})(theField);
				button.setAttribute("value","OK");
				popup.appendChild(button);

				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);

		};
		el.appendChild(a);
		el.appendChild(document.createElement("br"))
	}
	el.appendChild(drawPerms(theField));
	//el.appendChild(div);
	//theField.onchange = function(){
	//	oldValue = theField.value;
	//	newValue = [];
	//	for(var i=0;i<theField.value.length;i++){
	//		if(theField.value[i]!=null){
	//			newValue.push(theField.value[i]["id"]);
	//		}
	//	}
	//	theField.value = newValue;
	//	if (theForm.submitType == "connected"){
	//		result = restCall("/updateField/","POST",this);
	//	}
	//	theField.value = oldValue;
	//}
	return el;
}
//end invPerm

function buildStaticLinks(theLinks){
	if (theLinks.hasOwnProperty("linkLink")){
		div = document.createElement("div");
		div.innerHTML = theLinks.linkLink;
		return div;
	}
	return buildInnerLinks(null,{"value":theLinks},null,true);
}

function buildInnerLinks(theForm,theField,id,view){
	textStr = "";
	div = document.createElement("div");
	div.setAttribute("id",id+"_links");
	for(var i=0;i<theField.value.length;i++){
		div2 = document.createElement("div")
		opts = theField.value[i];
		a = document.createElement("a");
		if(opts["linkText"]!=""){
			a.innerHTML = opts["linkText"];
			textStr += opts["linkText"];
			if(i<theField.value.length-1){
				textStr += " > ";
			}
		}else{
			a.innerHTML = "Untitled"
		}
		a.href='javascript:void(0);';
		a.onclick = (function(opts){
			return function(){
				if(opts["showInTable"]){
					handleLink(opts["id"],opts["collection"],true,false,opts["revisionNumber"]);
				}else{
					handleLink(opts["id"],opts["collection"],false,false,opts["revisionNumber"]);
				}
			}
		})(opts);
		div2.appendChild(a);
		if(!view){
			a = document.createElement("a")
			a.setAttribute("href","javascript:void(0);");
			a.onclick = (function(theField,id){
				return function(){
					newVal = [];
					oldVal = theField.value;
					for(var i=0;i<oldVal.length;i++){
						if(oldVal[i]["id"]!=id){
							newVal.push(oldVal[i]);
						}else{
							this.parentNode.parentNode.removeChild(this.parentNode);
						}
					}
					theField.value = newVal;
					theField.onchange();
				}
			})(theField,opts["id"]);
			img = document.createElement("img");
			img.src = "images/delete.gif";
			img.width = "16";
			img.height = "16";
			img.style.marginLeft = "5px";
			a.appendChild(img);
			div2.appendChild(a)
		}
		div.appendChild(div2);

	}
	thisRow.push(textStr)
	return div;
}

function resizeIframe(iframeId) { 
	try{
		var the_height= document.getElementById(iframeId).contentWindow.document.body.scrollHeight; 
		document.getElementById(iframeId).height= the_height;
	}catch(err){}
}

function makeFireControl(containerId){
	clearContainer(containerId);
	searchDiv = document.createElement("div");
	h1 = document.createElement("h1");
	h1.innerHTML = "Flammability Report";
	searchDiv.appendChild(h1);
	label = document.createElement("label");
	label.innerHTML = "Zone";
	searchDiv.appendChild(label);
	select = document.createElement("select");
	theOption = document.createElement("option");
	theOption.setAttribute("value","");
	theOption.appendChild(document.createTextNode("--SELECT--"));
	select.appendChild(theOption);
	theOption = document.createElement("option");
	theOption.setAttribute("value","All");
	theOption.appendChild(document.createTextNode("All"));
	select.appendChild(theOption);
	theOption = document.createElement("option");
	theOption.setAttribute("value","Zone A");
	theOption.appendChild(document.createTextNode("Zone A"));
	select.appendChild(theOption);
	theOption = document.createElement("option");
	theOption.setAttribute("value","Zone B");
	theOption.appendChild(document.createTextNode("Zone B"));
	select.appendChild(theOption);
	theOption = document.createElement("option");
	theOption.setAttribute("value","Zone C");
	theOption.appendChild(document.createTextNode("Zone C"));
	select.appendChild(theOption);
	theOption = document.createElement("option");
	theOption.setAttribute("value","Zone D");
	theOption.appendChild(document.createTextNode("Zone D"));
	select.appendChild(theOption);
	searchDiv.appendChild(select);
	button = document.createElement("input");
	button.setAttribute("type","button");
	button.setAttribute("value","Search");
	button.setAttribute("id","fireButton");
	button.onclick = (function(select,button){
		return function(){
			button.value="Loading...";
			selectValue = select.options[select.selectedIndex].value;
			payload = {"rpp":10000,"action":"next","includeChildren":true,"collection":"inventoryItems","list":"true"};
			if(selectValue != "All"){
				payload["query"] = {"$or":[{"$or":[{"controlZone":select.options[select.selectedIndex].value}]}]}
				restCallA("/getList","POST",payload,function(r){
					button.value="Search";
					listForms = r["forms"];
					cursorData = r["cursorData"];
					cursorData["pages"] = 1;
					for(var i=0;i<listForms.length;i++){
						//listForms[i]["fields"].push({"formId":"8f76765222f24e36b9c2","insertFormat":false,"id":"75db1d29e0","getFormat":false,"displayKey":false,"inSearch":true,"add":true,"formName":"Name","updated":false,"multiple":false,"dbType":"text","collection":"","dims":false,"readOnly":false,"fieldType":"text","inTable":true,"validationFunctions":[],"edit":true,"required":true,"value":"(R)-Propane-1,2-diol","dbName":"name","action":false,"options":[],"view":true})
						listForms[i]["fieldNames"].push("Control Zone");
						listForms[i]["fields"].push({"formName":"Control Zone","fieldType":"text","value":selectValue})
					}
					if(listForms[0]){
						listForms[0]["cursorData"] = cursorData;
						listForms[listForms.length-1]["cursorData"] = cursorData;
					}
					makeEditTable(listForms,'arxOneContainer',["Name","Location","Amount","Unit Type","US Units","Control Zone"]);
					try{
						if(cursorId == false){
							window.scroll(0,findPos(document.getElementById("listTable")));
						}
					}catch(err){}
				});
			}else{
				allListForms = [];
				numCallsReturned = 0;
				totalCount = 0;
				zones = []
				for(var i=0;i<select.options.length;i++){
					if(select.options[i].value != "All" && select.options[i].value != ""){
						zones.push(select.options[i].value)
					}
				}
				for(var j=0;j<zones.length;j++){
					payload["query"] = {"$or":[{"$or":[{"controlZone":zones[j]}]}]}
					restCallA("/getList/","POST",payload,(function(zone){
							return function(r){
								numCallsReturned += 1
								listForms = r["forms"];
								cursorData = r["cursorData"];
								cursorData["pages"] = 1;
								for(var i=0;i<listForms.length;i++){
									//listForms[i]["fields"].push({"formId":"8f76765222f24e36b9c2","insertFormat":false,"id":"75db1d29e0","getFormat":false,"displayKey":false,"inSearch":true,"add":true,"formName":"Name","updated":false,"multiple":false,"dbType":"text","collection":"","dims":false,"readOnly":false,"fieldType":"text","inTable":true,"validationFunctions":[],"edit":true,"required":true,"value":"(R)-Propane-1,2-diol","dbName":"name","action":false,"options":[],"view":true})
									listForms[i]["fieldNames"].push("Control Zone");
									listForms[i]["fields"].push({"formName":"Control Zone","fieldType":"text","value":zone});
								}
								for(var i=0;i<listForms.length;i++ ){
									allListForms.push(listForms[i]);
								}
								totalCount += cursorData["count"];

								if(numCallsReturned==zones.length){
									button.value="Search";
									listForms = allListForms;
									cursorData["count"] = totalCount;
									cursorData["pages"] = 1;
									if(listForms[0]){
										listForms[0]["cursorData"] = cursorData;
										listForms[listForms.length-1]["cursorData"] = cursorData;
									}
									makeEditTable(listForms,'arxOneContainer',["Name","Location","Amount","Unit Type","US Units","Control Zone"]);
									try{
										if(cursorId == false){
											window.scroll(0,findPos(document.getElementById("listTable")));
										}
									}catch(err){}
								}
							}
						})(zones[j])
					);
				}
			}
		}
	})(select,button);
	searchDiv.appendChild(button);
	document.getElementById(containerId).appendChild(searchDiv);
}

function makeReceiving(containerId){
	clearContainer('arxOneContainer');
	receivingDiv = document.createElement("div");
	receivingDiv.style.width = "95%";
	receivingDiv.style.border = "1px solid black";
	receivingDiv.style.padding = "10px";
	a = document.createElement("a");
	a.innerHTML = "Close";
	a.onclick = function(){clearContainer(containerId)};
	a.style.cssFloat = "right";
	a.href = "javascript:void(0);"
	receivingDiv.appendChild(a);
	
	h1 = document.createElement("h1");
	h1.innerHTML = "Receiving";
	receivingDiv.appendChild(h1)

	table = document.createElement("table");
	table.setAttribute("id","recTable");
	tBody = document.createElement("tBody");
	table.appendChild(tBody);
	tr = document.createElement("tr");
	td = document.createElement("td");
	td.setAttribute("id","recSearchHolder")
	label = document.createElement("label");
	label.innerHTML = "CAS Number";
	td.appendChild(label);
	input = document.createElement("input");
	input.setAttribute("type","text");
	input.setAttribute("id","recCasNumber");
	td.appendChild(input);
	tr.appendChild(td);
	td = document.createElement("td");
	td.appendChild(document.createTextNode("or"));
	td.setAttribute("text-align","center")
	tr.appendChild(td);
	td = document.createElement("td");
	label = document.createElement("label");
	label.innerHTML = "Chemical Name";
	td.appendChild(label);
	input = document.createElement("input");
	input.setAttribute("type","text");
	input.setAttribute("id","recChemicalName");
	td.appendChild(input);
	tr.appendChild(td);
	td = document.createElement("td");
	td.style.borderLeft = "1px dashed black";
	label = document.createElement("label");
	label.innerHTML = "Location Barcode";
	td.appendChild(label);
	input = document.createElement("input");
	input.setAttribute("type","text");
	input.setAttribute("id","recLocationBarcode");
	td.appendChild(input);
	tr.appendChild(td);
	td = document.createElement("td");
	label = document.createElement("label");
	label.innerHTML = "Container Type";
	td.appendChild(label);
	sampleTypes = restCall("/getSampleTypes/","POST",{});
	sampleTypeSelect = document.createElement("select");
	sampleTypeSelect.setAttribute("id","recType");
	option = document.createElement("option");
	option.setAttribute("value","");
	option.appendChild(document.createTextNode("--SELECT--"));
	sampleTypeSelect.appendChild(option);
	for(var i=0;i<sampleTypes.length;i++){
		option = document.createElement("option");
		option.setAttribute("value",sampleTypes[i]);
		option.appendChild(document.createTextNode(sampleTypes[i]));
		sampleTypeSelect.appendChild(option);
	}
	td.appendChild(sampleTypeSelect);
	tr.appendChild(td);
	td = document.createElement("td");
	td.setAttribute("valign","bottom");
	recButton = document.createElement("input");
	recButton.setAttribute("type","button");
	recButton.setAttribute("id","recButton");
	recButton.setAttribute("value","Receive");
	recButton.onclick = function(){
		error = false;
		materialNotFound = false;
		casNumber = document.getElementById("recCasNumber").value;
		chemicalName = document.getElementById("recChemicalName").value;
		if(casNumber == "" && chemicalName==""){
			alert("Please Enter a Cas Number or a Chemical Name");
			error = true
		}else{
			payload = {"rpp":1,"action":"next","collection":"inventoryItems","list":"true"};
			if(casNumber==""){
				payload["query"] = {"$or":[{"$or":[{"chemicalName":{"$regex":"^"+chemicalName+"$","$options":"-i"}},{"name":{"$regex":"^"+chemicalName+"$","$options":"-i"}}]}]}
			}else{
				payload["query"] = {"$or":[{"$or":[{"casNumber":{"$regex":"^"+casNumber+"$","$options":"-i"}}]}]}
			}
			r = restCall("/getList/","POST",payload);
			fds = r["forms"];
			if(fds.length == 0){
				materialNotFound = true;
			}else{
				lineageParentId = fds[0]["id"];
				collection = fds[0]["collection"];
			}
		}	
		el = document.getElementById("recType");
		recType = el.options[el.selectedIndex].value;
		if(recType == ""){
			alert("Please Enter Container Type");
			error = true
		}
		payload = {"rpp":1,"action":"next","collection":"inventoryItems","list":"true"};
		payload["query"] = {"$or":[{"$or":[{"barcode":{"$regex":"^"+document.getElementById("recLocationBarcode").value+"$","$options":"-i"}}]}]}
		r = restCall("/getList/","POST",payload)
		fds = r["forms"];
		if(fds.length == 0){
			alert("Location does not exist");
			error = true;
		}
		else{
			targetId = fds[0]["id"];
			parentForm = fds[0];
		}
		if(!error){
			if(!materialNotFound){
				clearContainer('arxOneContainer');
				recForm = document.createElement("div");
				label = document.createElement("label");
				label.innerHTML = "Barcode*";
				recForm.appendChild(label);
				recForm.appendChild(label);
				recForm.appendChild(label);
				input = document.createElement("input");
				input.setAttribute("type","text");
				input.setAttribute("id","recBarcode");
				recForm.appendChild(input);
				label = document.createElement("label");
				label.innerHTML = "Amount*";
				recForm.appendChild(label);
				input = document.createElement("input");
				input.setAttribute("type","text");
				input.setAttribute("id","recAmount");
				recForm.appendChild(input);
				label = document.createElement("label");
				label.innerHTML = "Unit Type*";
				recForm.appendChild(label);
				units = ["kg","g","mg","bottles","gal","L","ml","mm"];
				select = document.createElement("select");
				select.setAttribute("id","recUnitType");
				option = document.createElement("option");
				option.setAttribute("value","");
				option.appendChild(document.createTextNode("--SELECT--"));
				select.appendChild(option);
				for(var i=0;i<units.length;i++){
					option = document.createElement("option");
					option.setAttribute("value",units[i]);
					option.appendChild(document.createTextNode(units[i]));
					select.appendChild(option);
				}
				recForm.appendChild(select);
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.setAttribute("value","Receive");
				button.onclick = (function(lineageParentId,targetId,collection,recType){
					return function(){
						error = false;
						barcode = document.getElementById("recBarcode").value;
						amount = document.getElementById("recAmount").value;
						unitType = document.getElementById("recUnitType").options[document.getElementById("recUnitType").selectedIndex].value;
						if(barcode==""){
							error = true;
							alert("Please Enter a Barcode");
						}
						if(amount==""){
							error = true;
							alert("Please Enter an Amount");
						}else{
							if(!amount.match(/^[\-\.0-9]+$/ig)){
								error = true;
								alert("Please Enter a Valid Amount");
							}
						}
						if(unitType==""){
							error = true;
							alert("Please Enter Units");
						}
						if(!error){
							r = restCall("/receive/","POST",{"lineageParentId":lineageParentId,"targetId":targetId,"collection":collection,"amount":parseFloat(amount),"barcode":barcode,"units":unitType,"type":recType})
							if(!r["error"]){
								clearContainer('arxOneContainer');
								//document.getElementById('aboveArxOneContainer').appendChild(document.createTextNode("Item Added"));
								handleLink(r["newId"],r["newCollection"],false,r["newParentTree"]);
								document.getElementById('recCasNumber').value = "";
								document.getElementById('recChemicalName').value = "";
								document.getElementById('recLocationBarcode').value = "";
								document.getElementById('recType').selectedIndex = 0;
								return false;
							}else{
								alert(r["errorText"])
							}
						}
					}
				})(lineageParentId,targetId,collection,recType)
				recForm.appendChild(button)
				document.getElementById("arxOneContainer").appendChild(recForm);
			}else{
				autoClickAdd = true;
				autoClickValue = recType;
				actionFunctions("add",parentForm,false,'arxOneContainer')
			}
		}
	}
	td.appendChild(recButton);
	tr.appendChild(td);
	table.appendChild(tr);
	receivingDiv.appendChild(table);
	document.getElementById(containerId).appendChild(receivingDiv)
}

function getNumberAmount(startPoint) {
	// When the amount is read-only it has been populated from ELN and has units at the end. Remove them here.
	checkNum = "";
	var currentAmount = startPoint;
	for(var j = currentAmount.length - 1; j >= 0; j--) {
		if(currentAmount[j] == "." || !isNaN(parseInt(currentAmount[j])))
			checkNum = currentAmount[j] + checkNum;
	}
	
	return checkNum;
}

function makeSearch(containerId,thisSearchType,inFrame){
	clearContainer(containerId);
	searchDiv = document.createElement("div");
	searchDiv.setAttribute("id","searchDiv");
	searchDiv.className = "ax1-searchHolderDiv";
	h1 = document.createElement("h1");
	h1.innerHTML = "Search";
	h1.style.paddingBottom = "5px";
	searchDiv.appendChild(h1);
	br = document.createElement("br");
	searchDiv.appendChild(br);
	
	if(chemistryInSearch)
	{
		var exact = false;
		var readOnly = false;
		var initialMolData = "";
		var selectHtml = '<select id="searchTypeForSearch" name="searchTypeForSearch">';
		selectHtml += '<option value="SUBSTRUCTURE">Substructure Search</option>';
		selectHtml += '<option value="DUPLICATE">Exact Search</option>';
		selectHtml += '</select>';
		
		if(inFrame && typeof window.parent.molUpdateCdxml != 'undefined' && window.parent.molUpdateCdxml != "")
		{
			readOnly = true;
			initialMolData = window.parent.molUpdateCdxml;
			selectHtml = '<select id="searchTypeForSearch" name="searchTypeForSearch">';
			selectHtml += '<option value="DUPLICATE" SELECTED>Exact Search</option>';
			selectHtml += '</select>';
		}
		
		var theDiv = document.createElement("div");
		theDiv.setAttribute("height","250");
		theDiv.setAttribute("width","250");
		theDiv.className = "ax1-chemSearchFrameBox";
		theDiv.setAttribute("id","tempChemSearchFrame");

		getChemistryEditorMarkup("mycdx", "", initialMolData, 800, 300, readOnly, null, null, null, null, null, null, true)
		.then(function (theInnerHtml) {
			theInnerHtml += selectHtml;
			theDiv.innerHTML = theInnerHtml;
		});

		// put the content into the div
		if(inFrame)
			theDiv.style.float = "left";

		searchDiv.appendChild(theDiv);
		if(inFrame && initialMolData.length > 0)
		{
			var myInterval = window.setInterval(function() {
				if($('#mycdx').length == 0 || $('#searchButton').length == 0)
					return;
				
				var caughtException = false;
				try { window.setTimeout(function() { document.getElementById("searchButton").onclick(); }, 5000); }
				catch(e) { console.log("CAUGHT EXCEPTION"); caughtException = true; }
				
				if(!caughtException)
					window.clearInterval(myInterval);
			}, 250);
		}
	}
	
	if(inFrame)
	{
		useDiv = document.createElement("div");
		useDiv.style.float = "left";
		h1 = document.createElement("h1");
		h1.innerHTML = "Selected Items";
		h1.style.paddingBottom = "10px";
		useDiv.appendChild(h1);
		exportDiv = document.createElement("div");
		exportDiv.setAttribute("id","selectedItemsDiv");
		useDiv.appendChild(exportDiv);
		p = document.createElement("p");
		p.setAttribute("id","noSelectedItemsP");
		p.innerHTML = "You have not selected any items."
		p.style.padding = "20px";
		useDiv.appendChild(p)
		button = document.createElement("input");
		button.setAttribute("type","button");
		button.setAttribute("value","Add to Reaction");
		button.onclick = function(){
			if(selectedItemFds.length==0){
				alert("No items selected")
				return false;
			}
			if(selectedItemFds.length>1){
				alert("Only one item may be selected at a time")
				return false;
			}
			if(useEquivalents){
				if(!window.parent.hasLimittingMoles()){
					alert("When using equivalents limiting moles must be present")
					return false;
				}
			}
			for (var i=0;i<selectedItemFds.length;i++ ){
				if(document.getElementById(selectedItemFds[i].id+"_amountToUse").value==""){
					alert("Please Enter an amount to use for each item selected");
					return false;
				}
			}
			for (var i=0;i<selectedItemFds.length;i++ ){
				var checkNum = document.getElementById(selectedItemFds[i].id+"_amountToUse").value;
				
				if(document.getElementById(selectedItemFds[i].id+"_amountToUse").readOnly) {
					checkNum = getNumberAmount(checkNum);
				}
				
				if(!isNumber(checkNum)){
					alert("Please enter only numbers in amount box");
					return false;
				}
			}
			if(experimentType==1){
				molFormula = selectedItemFds[0].fields[fd.fieldNames.indexOf("Formula")].value;
				for (var i=0;i<selectedItemFds.length;i++ ){
					if(selectedItemFds[i].fields[fd.fieldNames.indexOf("Formula")].value!=molFormula){
						alert("All selected items must have the same structure");
						return false;
					}
				}
			}
			if(fd.fieldNames.indexOf("Unit Type")!=-1){
				unit = selectedItemFds[0].fields[fd.fieldNames.indexOf("Unit Type")].value;
			}
			if(fd.fieldNames.indexOf("Units")!=-1){
				unit = selectedItemFds[0].fields[fd.fieldNames.indexOf("Units")].value;
			}
			if(fd.fieldNames.indexOf("Density (g/mL)")!=-1){
				density = selectedItemFds[0].fields[fd.fieldNames.indexOf("Density (g/mL)")].value;
			}else{
				density = ""
			}

			isVolume = false;
			if(unit.toLowerCase()=="ml" || unit.toLowerCase()=="ul" || unit.toLowerCase()=="l"){
				isVolume = true;
			}
			if(useEquivalents && isVolume && density==""){
				alert("Density must be present when using equivalents with containers that are measured by volume")
				return false;
			}

			amount = 0;
			items = [];
			for (var i=0;i<selectedItemFds.length;i++ ){
				if(useEquivalents){
					purity = parseFloat(selectedItemFds[0].fields[fd.fieldNames.indexOf("Purity")].value);
					if(isNaN(purity)){
						purity = "100 %";
					}else{
						purity += " %";
					}
					if(fd.fieldNames.indexOf("Mol Weight")!=-1){
						molWeight = selectedItemFds[0].fields[fd.fieldNames.indexOf("Mol Weight")].value;
					}
					if(fd.fieldNames.indexOf("Unit Type")!=-1){
						unit = selectedItemFds[0].fields[fd.fieldNames.indexOf("Unit Type")].value;
					}
					if(fd.fieldNames.indexOf("Units")!=-1){
						unit = selectedItemFds[0].fields[fd.fieldNames.indexOf("Units")].value;
					}
					equivalents = getNumberAmount(document.getElementById(selectedItemFds[i].id+"_amountToUse").value);
					if(isVolume){
						amount = window.parent.getAmountFromEquivalentsAndMolecularWeightVolume(equivalents,molWeight,density+" g/mL",unit);
					}else{
						amount = window.parent.getAmountFromEquivalentsAndMolecularWeight(equivalents,molWeight,purity,unit);
					}
					amountWithUnits = amount;
					amount = parseFloat(amount.split(" ")[0]);
					thisAmount = amount
				}else{
					thisAmount = document.getElementById(selectedItemFds[i].id+"_amountToUse").value;
					numAmount = getNumberAmount(thisAmount);
					amount += numAmount;
				}
				D = {}
				D["collection"] = selectedItemFds[i].collection;
				D["id"] = selectedItemFds[i].id;
				D["fieldName"] = "amount";
				D["value"] = thisAmount;
				D["theLink"] = theLink;
				items.push(D)
			}
			totalAmount = amount;
			
			for (var i=0;i<selectedItemFds.length;i++ ){
				if(selectedItemFds[i].fields[fd.fieldNames.indexOf("Amount")].value<parseFloat(amount)){
					if(!confirm("Amount is greater than the amount in the container.  Are you sure you would like to continue?")){
						return false;
					}
				}
			}

			this.disabled = true;

			if(experimentType==1){
				purity = selectedItemFds[0].fields[fd.fieldNames.indexOf("Purity")].value;
			}else{purity=""}
			if(purity){
				purity = purity + " %";
			}else{
				purity = "";
			}
			amount = amount + " " + unit;
			try{
				cdxml = selectedItemFds[0].fields[fd.fieldNames.indexOf("Structure")].value.cdxml;
			}catch(err){
				cdxml = "";
			}
			
			el = window.parent.document.getElementById("sigdig");
			if(el){
				sigdigs = el.options[el.selectedIndex].value;
			}else{
				sigdigs = 2;
			}
			if (experimentType==1){
				casNumber = ""
				molFormula = ""
				chemicalName = ""
				molWeight = 0.0
				if(fd.fieldNames.indexOf("Formula") != -1)
					molFormula = selectedItemFds[0].fields[fd.fieldNames.indexOf("Formula")].value;
				if(fd.fieldNames.indexOf("Chemical Name") != -1)
					chemicalName = selectedItemFds[0].fields[fd.fieldNames.indexOf("Chemical Name")].value;
				if(fd.fieldNames.indexOf("Mol Weight") != -1)
					try { molWeight = selectedItemFds[0].fields[fd.fieldNames.indexOf("Mol Weight")].value.toFixed(2); } catch(e) { console.log("error getting molecular weight from inventory."); }
				if(fd.fieldNames.indexOf("CAS Number") != -1)
					casNumber = selectedItemFds[0].fields[fd.fieldNames.indexOf("CAS Number")].value;
			}
			if(fd.fieldNames.indexOf("Product ID")!=-1){
				productId = selectedItemFds[0].fields[fd.fieldNames.indexOf("Product ID")].value;
			}else{
				productId = "";
			}
			if(fd.fieldNames.indexOf("Density (g/mL)")!=-1){
				density = selectedItemFds[0].fields[fd.fieldNames.indexOf("Density (g/mL)")].value.toString();
			}else{
				density = "";
			}
			if(density!=""){
				density += " g/mL";
			}
			if(experimentType==1){
				if(window.parent.molUpdatePrefix==""){
					theLabel = window.parent.getNextLabel();
				}else{
					theLabel = window.parent.document.getElementById(window.parent.molUpdatePrefix+"_trivialName").value;
				}
				r = restCall("/multiUse/","POST",{"items":items,"trivialName":theLabel});
			}else{
				r = restCall("/multiUse/","POST",{"items":items})
			}
			if(experimentType==1){
				cdxml = restCall("/applyTemplate/","POST",{"templateName":"blank_acs1996.cdx","cdxml":cdxml})["cdxml"];
				inventoryItems = [];
				for (var i=0;i<selectedItemFds.length;i++ ){
					id = selectedItemFds[i].id;
					name = selectedItemFds[i].fields[fd.fieldNames.indexOf("Barcode")].value;
					thisAmount = document.getElementById(selectedItemFds[i].id+"_amountToUse").value+" "+unit;
					if(useEquivalents){
						thisAmount = amountWithUnits;
					}
					inventoryItems.push({"id":id,"name":name,"amount":thisAmount,"isVolume":isVolume});
				}
				inventoryItems = JSON.stringify(inventoryItems);
				if(window.parent.molUpdatePrefix==""){
					window.parent.getChemistryEditorChemicalStructure("mycdx",true).then(function(experimentCdxml){

						experimentReaction = {"reactionData":experimentCdxml, "reactionFormat":"cdxml", "reactionElement":"mycdx"};

						window.parent.insertFragment(window.parent.invAddType,cdxml,experimentCdxml,theLabel).then(function(fragmentData) {
							
							if(fragmentData.hasOwnProperty("fragmentId")) {
								newFragmentId = fragmentData["fragmentId"];

								if(window.parent.invAddType=="left"){
									if(isVolume){
										window.parent.addReactant(chemicalName,molWeight,molFormula,casNumber,theLabel,newFragmentId,true,purity,false,false,inventoryItems,productId,thisAmount,density);
									}else{
										window.parent.addReactant(chemicalName,molWeight,molFormula,casNumber,theLabel,newFragmentId,true,purity,thisAmount,false,inventoryItems,productId,false,density);
									}
								}
								//change for reagent swap
								if(window.parent.invAddType=="top"){
									if (isVolume){
										window.parent.addReagent(chemicalName,molWeight,molFormula,casNumber,theLabel,newFragmentId,true,purity,false,false,inventoryItems,productId,thisAmount,density);
									}else{
										window.parent.addReagent(chemicalName,molWeight,molFormula,casNumber,theLabel,newFragmentId,true,purity,thisAmount,false,inventoryItems,productId,false,density);
									}
								}
								//change for reagent swap
								if(window.parent.invAddType=="bottom"){
									if (isVolume){
										window.parent.addSolvent(chemicalName,theLabel,newFragmentId,true,inventoryItems,thisAmount);
									}else{
										window.parent.addSolvent(chemicalName,theLabel,newFragmentId,true,inventoryItems);
									}
								}
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
							window.parent.updateLiveEditStructureData(experimentReaction["reactionElement"], experimentReaction["reactionData"], experimentReaction["reactionFormat"])

						});
					});
				}else{
					prefix = window.parent.molUpdatePrefix;
					//change for reagent swap
					if(window.parent.invAddType=="left" || window.parent.invAddType=="top"){
						window.parent.document.getElementById(prefix+"_productId").value = productId;
						window.parent.sendAutoSave(prefix+"_productId",productId);
						window.parent.document.getElementById(prefix+"_name").value = chemicalName;
						window.parent.sendAutoSave(prefix+"_name",chemicalName);
						window.parent.document.getElementById(prefix+"_molecularWeight").value = molWeight;
						window.parent.sendAutoSave(prefix+"_molecularWeight",molWeight);
						window.parent.document.getElementById(prefix+"_molecularFormula").value = molFormula;
						window.parent.sendAutoSave(prefix+"_molecularFormula",molFormula);
						if(isVolume){
							window.parent.document.getElementById(prefix+"_volume").value = thisAmount;
							if (density){
								window.parent.document.getElementById(prefix+"_density").value = density;
								window.parent.UAStates[prefix]["density"] = true;
							}
							window.parent.UAStates[prefix]["equivalents"] = false;
							window.parent.UAStates[prefix]["volume"] = true;
							window.parent.sendAutoSave(prefix+"_volume",thisAmount);
							if(density){
								window.parent.UAStates[prefix]["density"] = true;
								window.parent.sendAutoSave(prefix+"_density",density);
							}
						}else{
							window.parent.document.getElementById(prefix+"_sampleMass").value = thisAmount;
							window.parent.document.getElementById(prefix+"_percentWT").value = purity;
							window.parent.UAStates[prefix]["equivalents"] = false;
							window.parent.UAStates[prefix]["sampleMass"] = true;
							window.parent.UAStates[prefix]["percentWT"] = true;
							window.parent.sendAutoSave(prefix+"_sampleMass",thisAmount);
							window.parent.sendAutoSave(prefix+"_percentWT",purity);
						}

						window.parent.sendAutoSave(prefix+"_UAStates",JSON.stringify(window.parent.UAStates[prefix]));
						if(isVolume){
							window.parent.window.setTimeout('window.parent.gridFieldChanged(document.getElementById("'+prefix+'_volume"))',1000)
						}else{
							window.parent.window.setTimeout('window.parent.gridFieldChanged(document.getElementById("'+prefix+'_sampleMass"))',1000)
						}
					}
					//change for reagent swap
					if(window.parent.invAddType=="bottom"){
						if(isVolume){
							window.parent.document.getElementById(prefix+"_volume").value = thisAmount;
							window.parent.sendAutoSave(prefix+"_volume",thisAmount)
							window.parent.UAStates[prefix]["volume"] = true;
						}
						window.parent.document.getElementById(prefix+"_name").value = chemicalName;
						window.parent.sendAutoSave(prefix+"_name",chemicalName)
						//window.parent.UAStates[prefix]["name"] = true;
						window.parent.sendAutoSave(prefix+"_UAStates",JSON.stringify(window.parent.UAStates[prefix]));
						if(isVolume){
							window.parent.window.setTimeout('window.parent.gridFieldChanged(document.getElementById("'+prefix+'_volume"))',1000)
						}
					}
					window.parent.removeInvLinks(prefix);
					makeLinksPromise = window.parent.makeInvLinks(prefix,JSON.parse(inventoryItems));
					window.parent.sendAutoSave(prefix+"_inventoryItems",inventoryItems)
					window.parent.document.getElementById(prefix+"_hasChanged").value = "1";
					window.parent.sendAutoSave(prefix+"_hasChanged","1")
					window.parent.populateQuickView();
				}
			}
			for (var i=0;i<selectedItemFds.length;i++ ){
				amount = document.getElementById(selectedItemFds[i].id+"_amountToUse").value+" "+unit;
				id = selectedItemFds[i].id;
				name = selectedItemFds[i].fields[fd.fieldNames.indexOf("Barcode")].value;
				window.parent.addInventoryLink(id,amount,name);
			}
			window.parent.getInventoryLinks();
			//window.parent.document.getElementById("inventorySearchFrame").src = "/arxlab/static/blank.html";
			document.body.innerHTML = "";
			window.parent.hidePopup("inventoryPopup");
			if(experimentType==1){
				if(window.parent.molUpdatePrefix!=""){
					window.parent.molUpdatePrefix = "";
					window.parent.molUpdateCdxml = "";
					if(typeof makeLinksPromise != 'undefined'){
						makeLinksPromise.then(function(){
							window.parent.validateBarcodes();
						});
					}else{
						setTimeout(window.parent.validateBarcodes); //Put this in a timeout but with no time so that it happens after the promises
					}
				}
			}
		}
		useDiv.appendChild(button);
		searchDiv.appendChild(useDiv);
	}
	if(ignoreTableFields){
		r = restCall("/getAllowedCollectionsForSelect/","POST",{});
		select = document.createElement("select");
		select.style.clear = "both";
		select.setAttribute("id","searchObjectType");
		theOption = document.createElement("option");
		theOption.setAttribute("value","");
		theOption.appendChild(document.createTextNode("-- Select Item Type --"));
		select.appendChild(theOption);
		for(var j=0;j<r.length;j++){
			theOption = document.createElement("option");
			theOption.setAttribute("value",r[j][0]);
			theOption.appendChild(document.createTextNode(r[j][1]));
			select.appendChild(theOption);
		}
		searchDiv.appendChild(select);
		searchDiv.appendChild(document.createElement("br"));
	}
	iframeSearch = document.createElement("iframe");
	iframeSearch.src = "ajaxSearchAdv.asp?chemTable="+chemTable+"&chemSearchDbName="+chemSearchDbName+"&chemistryFrameId="+"tempChemSearchFrame";
	iframeSearch.setAttribute("height","100%");
	iframeSearch.className = "ax1-advSearchFrame";
	iframeSearch.id = "advSearchFrame";
	resizeIframeInterval = window.setInterval(resizeIframe,100,'advSearchFrame');
	if(companyId == 52 || companyId==13){
		if (companyId==13){
			loadFunction = function(){
				document.getElementById("advSearchFrame").contentWindow.searchFieldList = [
					{dbType:"text",name:"barcode",fName:"Barcode",type:"text"},
					{dbType:"text",name:"barcodeSequence",fName:"Barcode Sequence",type:"text"},
					{dbType:"text",name:"ccle",fName:"CCLE",type:"text",options:[["yes","yes"],["no","no"]]},
					{dbType:"text",name:"cellLine",fName:"Cell Line",type:"text"},
					{dbType:"text",name:"cellLineLua",fName:"Cell Line LUA",type:"text"},
					{dbType:"text",name:"collaboratorSID",fName:"Collaborator SID",type:"text"},
					{dbType:"text",name:"comments",fName:"Comments",type:"text"},
					{dbType:"text",name:"constructName",fName:"Construct Name",type:"text"},
					{dbType:"text",name:"cultureMedium",fName:"Culture Medium",type:"text",options:[['RPMI-1640: 90.0%', 'RPMI-1640: 90.0%'], ['DMEM: 90.0%', 'DMEM: 90.0%'], ['EMEM: 90.0%', 'EMEM: 90.0%']]},
					{dbType:"date",name:"dateStored",fName:"Date Stored",type:"date"},
					{dbType:"date",name:"dateStoredParental",fName:"Date Stored Parental",type:"date"},
					{dbType:"date",name:"dateThawed",fName:"Date Thawed",type:"date"},
					{dbType:"date",name:"dateUsed",fName:"Date Used",type:"date"},
					{dbType:"text",name:"description",fName:"Description",type:"text"},
					{dbType:"number",name:"doublingTimeCalc",fName:"Doubling Time (Calculated)",type:"actual_number"},
					{dbType:"number",name:"doublingTime",fName:"Doubling Time (Vendor)",type:"actual_number"},
					{dbType:"number",name:"initialVolume",fName:"Initial Volume",type:"actual_number"},
					{dbType:"text",name:"mcl1",fName:"MCL1",type:"text",options:[["yes","yes"],["no","no"]]},					
					{dbType:"text",name:"name",fName:"Name",type:"text"},
					{dbType:"text",name:"notes",fName:"Notes",type:"text"},
					{dbType:"text",name:"growthMedium",fName:"Growth Medium",type:"text",options:[['EMEM + 10% FBS', 'EMEM + 10% FBS'], ['IMDM + 20% FBS', 'IMDM + 20% FBS'], ['RPMI-1640 + 10% FBS', 'RPMI-1640 + 10% FBS'], ['RPMI-1640 + 15% FBS', 'RPMI-1640+ 15% FBS']]},
					{dbType:"text",name:"luaNumber",fName:"LUA Number",type:"text"},
					{dbType:"text",name:"luaNumber2",fName:"LUA Number 2",type:"text"},
					{dbType:"text",name:"ped",fName:"PED",type:"text",options:[["yes","yes"],["no","no"]]},
					{dbType:"text",name:"plate",fName:"Plate",type:"text"},
					{dbType:"number",name:"position",fName:"Position",type:"actual_number"},
					{dbType:"text",name:"primaryDisease",fName:"Primary Disease",type:"text",options:[['Skin Cancer', 'Skin Cancer'], ['Lung Cancer', 'Lung Cancer'], ['Adenocarcinoma', 'Adenocarcinoma'], ['Breast Cancer', 'Breast Cancer']]},
					{dbType:"text",name:"publicId",fName:"Public ID",type:"text"},
					{dbType:"text",name:"sampleId",fName:"Sample ID",type:"text"},
					{dbType:"text",name:"sbIdentifier",fName:"SB Identifier",type:"text"},
					{dbType:"text",name:"source",fName:"Source",type:"text",options:[['ATCC', 'ATCC'], ['DSMZ', 'DSMZ']]},
					{dbType:"text",name:"supplements",fName:"Supplements",type:"text"},
					{dbType:"text",name:"units",fName:"Units",type:"text",options:[["L","L"],["mL","mL"],["uL","uL"]]},
					{dbType:"number",name:"volume",fName:"Volume",type:"actual_number"},
					{dbType:"text",name:"well",fName:"Well",type:"text",options:[['A01', 'A01'], ['A02', 'A02'], ['A03', 'A03'], ['A04', 'A04'], ['A05', 'A05'], ['A06', 'A06'], ['A07', 'A07'], ['A08', 'A08'], ['A09', 'A09'], ['A10', 'A10'], ['A11', 'A11'], ['A12', 'A12'], ['B01', 'B01'], ['B02', 'B02'], ['B03', 'B03'], ['B04', 'B04'], ['B05', 'B05'], ['B06', 'B06'], ['B07', 'B07'], ['B08', 'B08'], ['B09', 'B09'], ['B10', 'B10'], ['B11', 'B11'], ['B12', 'B12'], ['C01', 'C01'], ['C02', 'C02'], ['C03', 'C03'], ['C04', 'C04'], ['C05', 'C05'], ['C06', 'C06'], ['C07', 'C07'], ['C08', 'C08'], ['C09', 'C09'], ['C10', 'C10'], ['C11', 'C11'], ['C12', 'C12'], ['D01', 'D01'], ['D02', 'D02'], ['D03', 'D03'], ['D04', 'D04'], ['D05', 'D05'], ['D06', 'D06'], ['D07', 'D07'], ['D08', 'D08'], ['D09', 'D09'], ['D10', 'D10'], ['D11', 'D11'], ['D12', 'D12'], ['E01', 'E01'], ['E02', 'E02'], ['E03', 'E03'], ['E04', 'E04'], ['E05', 'E05'], ['E06', 'E06'], ['E07', 'E07'], ['E08', 'E08'], ['E09', 'E09'], ['E10', 'E10'], ['E11', 'E11'], ['E12', 'E12'], ['F01', 'F01'], ['F02', 'F02'], ['F03', 'F03'], ['F04', 'F04'], ['F05', 'F05'], ['F06', 'F06'], ['F07', 'F07'], ['F08', 'F08'], ['F09', 'F09'], ['F10', 'F10'], ['F11', 'F11'], ['F12', 'F12'], ['G01', 'G01'], ['G02', 'G02'], ['G03', 'G03'], ['G04', 'G04'], ['G05', 'G05'], ['G06', 'G06'], ['G07', 'G07'], ['G08', 'G08'], ['G09', 'G09'], ['G10', 'G10'], ['G11', 'G11'], ['G12', 'G12'], ['H01', 'H01'], ['H02', 'H02'], ['H03', 'H03'], ['H04', 'H04'], ['H05', 'H05'], ['H06', 'H06'], ['H07', 'H07'], ['H08', 'H08'], ['H09', 'H09'], ['H10', 'H10'], ['H11', 'H11'], ['H12', 'H12']]}
				];
			}
		}else{
			loadFunction = function(){
				document.getElementById("advSearchFrame").contentWindow.searchFieldList = [
					{dbType:"text",name:"name",fName:"Name",type:"text"},
					{dbType:"text",name:"barcode",fName:"Barcode",type:"text"},
					{dbType:"number",name:"initialVolume",fName:"Initial Volume",type:"actual_number"},
					{dbType:"number",name:"volume",fName:"Volume",type:"actual_number"},
					{dbType:"text",name:"units",fName:"Units",type:"text",options:[["L","L"],["mL","mL"],["uL","uL"]]},
					{dbType:"text",name:"batch",fName:"Batch",type:"text"},
					{dbType:"text",name:"preparedBy",fName:"Prepared/Stored by",type:"text"},
					{dbType:"text",name:"notes",fName:"Notes/Description",type:"text"},
					{dbType:"text",name:"userAddedInitial.userName",fName:"User Added",type:"text"},
					{dbType:"date",name:"dateReceived",fName:"Date Received",type:"date"},
					{dbType:"date",name:"dateStored",fName:"Date Stored",type:"date"},
					{dbType:"date",name:"dateCollected",fName:"Date Collected",type:"date"}
				];
			}
		}
	}else{
		if (companyId==17){
			payload = {};
			payload["rpp"] = 1;
			payload["action"] = "next";
			payload["collection"] = "inventoryItems";
			payload["list"] = true;
			payload["query"] = {'_invType':thisSearchType};
			r = restCall("/getList/","POST",payload)
			fds = r["forms"];
			cursorData = r["cursorData"];
			searchFieldList = [];
			for(var i=0;i<fds[0].fields.length;i++){
				field = fds[0].fields[i];
				if(field.inSearch){
					if(field.fieldType=="date"){
						x = {dbType:"date",name:field.dbName,fName:field.formName,type:"date"};
					}else{
						x = {dbType:"text",name:field.dbName,fName:field.formName,type:"text"};
					}
					if(field.fieldType=="select"){
						theseOptions = [];
						for (var j=0;j<field.options.length;j++ ){
							theseOptions.push([field.options[j],field.options[j]]);
						}
						x.options = theseOptions;
					}
					searchFieldList.push(x);
				}
			}
			loadFunction = function(){
				document.getElementById("advSearchFrame").contentWindow.searchFieldList = searchFieldList;
			}
		}else{
			if(globalUserInfo["dsBottles"]&&companyId!=1){
				loadFunction = function(){
					document.getElementById("advSearchFrame").contentWindow.searchFieldList = [
					{dbType:"number",name:"amount",fName:"Amount",type:"actual_number"},
					{dbType:"text",name:"barcode",fName:"Barcode",type:"text"},
					{name:"casNumber",fName:"CAS Number",type:"text"},
					{dbType:"number",name:"catalogPrice",fName:"Catalog Price",type:"actual_number"},
					{dbType:"text",name:"catalogPriceCurrency",fName:"Catalog Price Currencty",options:[["US$","US$"],["EURO","EURO"],["JPY","JPY"]]},
					{name:"chemicalName",fName:"Chemical Name",type:"text"},
					{dbType:"number",name:"containerTare",fName:"Container Tare (g)",type:"actual_number"},
					{dbType:"date",name:"dateAddedInitial",fName:"Date Created",type:"date"},
					{dbType:"number",name:"density",fName:"Density",type:"actual_number"},
					{name:"name",fName:"Container Name",type:"text"},
					{dbType:"date",name:"dateExpires",fName:"Expiration Date",type:"date"},
					{name:"globalBottleId",fName:"Global Bottle ID",type:"text"},
					{name:"globalProductId",fName:"Global Product ID",type:"text"},
					{dbType:"text",name:"hazardClass",fName:"Hazard Class",options:[["flammable","flammable"],["highly toxic","highly toxic"],["corrosive","corrosive"],["refrigeration","refrigeration"],["shelf","shelf"]]},
					{dbType:"number",name:"initialAmount",fName:"Initial Amount",type:"actual_number"},
					{dbType:"text",name:"parentTree.linkText",fName:"Location",type:"text"},
					{name:"mdlNumber",fName:"MDL Number",type:"text"},
					{name:"memo",fName:"Memo",type:"text"},
					{name:"molFormula",fName:"Mol Formula",type:"text"},
					{dbType:"number",name:"molWeight",fName:"Mol Weight",type:"actual_number"},
					{name:"ownerName",fName:"Owner Name",type:"text"},
					{name:"productCode",fName:"Product Code",type:"text"},
					{name:"productId",fName:"Product ID",type:"text"},
					{dbType:"date",name:"purchaseDate",fName:"Purchase Date",type:"date"},
					{dbType:"number",name:"purchasePrice",fName:"Purchase Price",type:"actual_number"},
					{dbType:"text",name:"purchasePriceCurrency",fName:"Purchase Price Currencty",options:[["US$","US$"],["EURO","EURO"],["JPY","JPY"]]},
					{dbType:"number",name:"purity",fName:"Purity",type:"actual_number"},
					{name:"reactantIds",fName:"Reactant ID",type:"text"},
					{name:"registrationId",fName:"Registration ID",type:"text"},
					{dbType:"text",name:"segregationCategory",fName:"Segregation Category",options:[["water reactive electrophile","water reactive electrophile"],["water non-reactive electrophile","water non-reactive electrophile"],["neutral","neutral"],["water reactive nucleophile","water reactive nucleophile"],["non-water reactive nucleophile","non-water reactive nucleophile"],["water reactive inorganc electrophile","water reactive inorganc electrophile"],["oxidizer","oxidizer"]]},
					{name:"structureCode",fName:"Structure Code",type:"text"},
					{name:"supplier",fName:"Supplier",type:"text"},
					{name:"supplierCatalogNumber",fName:"Supplier Catalog Number",type:"text"},
					{name:"synonym",fName:"Synonym",type:"text"},
					{dbType:"date",name:"syntheticDate",fName:"Synthetic Date",type:"date"},
					{name:"units",fName:"Units",type:"text",options:[["kg","kg"],["g","g"],["mg","mg"],["bottles","bottles"],["gal","gal"],["L","L"],["mL","mL"],["uL","uL"]]},
					{name:"userAddedInitial.userName",fName:"User Added",type:"text"}
				];//ds collab
				}
			}else{
			if (companyId==4 || companyId==70 || companyId==1){
				if(companyId==4 || companyId==1){
					loadFunction = function(){
						document.getElementById("advSearchFrame").contentWindow.searchFieldList = [
						{name:"altName",fName:"Alt. Name",type:"text"},
						{name:"manufacturer",fName:"Antibody Manufacturer",type:"text",options:[["BD Pharmingen","BD Pharmingen"],["BioLegend","BioLegend"],["Caltag","Caltag"],["Cell Signalling Technology","Cell Signalling Technology"],["eBioscience","eBioscience"],["Invitrogen","Invitrogen"],["Life Technologies","Life Technologies"],["Santa Cruz","Santa Cruz"]]},
						{name:"name",fName:"Antibody Name",type:"text"},
						{name:"antigenImmunogen",fName:"Antigen/Immunogen",type:"text"},
						{name:"application",fName:"Application",type:"text"},
						{name:"barcode",fName:"Barcode",type:"text"},
						{name:"baseVector",fName:"Base Vector",type:"text"},
						{name:"catalogNumber",fName:"Catalog Number",type:"text"},
						{name:"clonality",fName:"Clonality",type:"text",options:[["Monoclonal","Monoclonal"],["Polyclonal","Polyclonal"]]},
						{name:"clone",fName:"Clone",type:"text"},
						{name:"comments",fName:"Comments",type:"text"},
						{name:"company",fName:"Company",type:"text",options:[["Applied Biosystems","Applied Biosystems"]]},
						{dbType:"date",name:"dateArrived",fName:"Date Arrived",type:"date"},
						{name:"description",fName:"Description",type:"text"},
						{name:"dye",fName:"Dye",type:"text",options:[["FAM","FAM"]]},
						{dbType:"date",name:"dateExpires",fName:"Expiration Date",type:"date"},
						{name:"freezerName",fName:"Freezer Name",type:"text",options:[["Hall -20C Freezer","Hall -20C Freezer"]]},
						{name:"fridgeName",fName:"Fridge Name",type:"text",options:[["Fridge 2","Fridge 2"]]},
						{name:"gene",fName:"Gene",type:"text"},
						{name:"isotype",fName:"Isotype",type:"text"},
						{dbType:"number",name:"length",fName:"Length",type:"actual_number"},
						{dbType:"number",name:"lotNumber",fName:"Lot Number",type:"text"},						
						{name:"manufacturer",fName:"Manufacturer",type:"text"},
						{name:"name",fName:"Name",type:"text"},
						{name:"orientation",fName:"Orientation",type:"text",options:[["Backward","Backward"],["Forward","Forward"]]},
						{name:"name",fName:"Plasmid",type:"text"},
						{name:"name",fName:"Primer Name",type:"text"},
						{name:"raisedIn",fName:"Raised In",type:"text",options:[["Donkey","Donkey"],["Goat","Goat"],["Hamster","Hamster"],["Mouse","Mouse"],["Rabbit","Rabbit"],["Rat","Rat"]]},
						{name:"reactsWith",fName:"Reacts With",type:"text"},
						{name:"resistance",fName:"Resistance",type:"text"},
						{name:"sequence",fName:"Sequence",type:"text"},
						{name:"source",fName:"Source",type:"text"},
						{name:"species",fName:"Species",type:"text",options:[["Human","Human"],["Mouse","Mouse"]]},
						{name:"tagsFluorophores",fName:"Tags/Fluorophores",type:"text"},
						{dbType:"number",name:"tm",fName:"Tm",type:"actual_number"},
						{name:"name",fName:"Tube Name",type:"text"},
						{name:"webpage",fName:"Webpage",type:"text"}
						];
					}
				}else{
					loadFunction = function(){
							document.getElementById("advSearchFrame").contentWindow.searchFieldList = [
							{name:"plasmidType",fName:"Plasmid Type",type:"text",options:[["Triple-Play","Triple-Play"],["Individual","Individual"]]},
							{name:"plasmidSource",fName:"Plasmid Source",type:"text",options:[["DTX","DTX"],["Commercial Vendor","Commercial Vendor"],["External","External"]]},
							{name:"plasmidExternalSource",fName:"Plasmid External Source",type:"text"},
							{name:"project",fName:"Project",type:"text",options:[["eGFP","eGFP"],["HemA","HemA"],["HemB","HemB"],["OTC","OTC"],["DTX101","DTX101"],["Other","Other"]]},
							{name:"helperPlasmid",fName:"Helper Plasmid",type:"text"},
							{name:"serotype",fName:"Serotype",type:"text"},
							{name:"name",fName:"Plasmid Official Name",type:"text"},
							{name:"plasmidDetailedName",fName:"Plasmid Detailed Name",type:"text"},
							{name:"plasmidShorthandName",fName:"Plasmid Shorthand Name",type:"text"},
							{name:"plasmidId",fName:"Plasmid ID",type:"text"},
							{name:"plasmidVendor",fName:"Plasmid Vendor",type:"text"},
							{dbType:"number",name:"plasmidConcentration",fName:"Plasmid Concentration",type:"actual_number"},
							{name:"antibioticResistance",fName:"Antibiotic Resistance",type:"text"},
							{dbType:"number",name:"plasmidSize",fName:"Plasmid Size (bp)",type:"actual_number"},
							{name:"plasmidSequence",fName:"Plasmid Sequence",type:"text"},
							{name:"plasmidAuthor",fName:"Plasmid Author",type:"text"},
							{name:"name",fName:"Name",type:"text"},
							{dbType:"number",name:"purity",fName:"Purity",type:"actual_number"},
							{name:"supplier",fName:"Supplier",type:"text"},
							{dbType:"number",name:"initialAmount",fName:"Initial Amount",type:"actual_number"},
							{dbType:"number",name:"amount",fName:"Amount",type:"actual_number"},
							{name:"units",fName:"Units",type:"text",options:[["kg","kg"],["g","g"],["mg","mg"],["bottles","bottles"],["gal","gal"],["L","L"],["ml","ml"],["mm","mm"]]},
							{name:"supplierCatalogNumber",fName:"Supplier Catalog Number",type:"text"},
							{name:"casNumber",fName:"CAS Number",type:"text"},
							{name:"molFormula",fName:"Mol Formula",type:"text"},
							{dbType:"number",name:"molWeight",fName:"Mol Weight",type:"actual_number"},
							{name:"chemicalName",fName:"Chemical Name",type:"text"},
							{name:"userAddedInitial.userName",fName:"User Added",type:"text"},
							{dbType:"date",name:"dateExpires",fName:"Expiration Date",type:"date"}
						];
					}
				}
				
			}else{
					if (searchFieldListIndex == "1"){
						loadFunction = function(){
							document.getElementById("advSearchFrame").contentWindow.searchFieldList = [
							{dbType:"number",name:"amount",fName:"Amount",type:"actual_number"},
							{dbType:"text",name:"barcode",fName:"Barcode",type:"text"},
							{name:"casNumber",fName:"CAS Number",type:"text"},
							{name:"name",fName:"Cell Line Name",type:"text"},
							{dbType:"number",name:"cellsPerVial",fName:"Cells Per Vial",type:"actual_number"},
							{name:"chemicalName",fName:"Chemical Name",type:"text"},							
							{name:"comments",fName:"Comments",type:"text"},
							{dbType:"date",name:"creationDate",fName:"Creation Date",type:"date"},
							{name:"description",fName:"Description",type:"text"},
							{name:"eukaryoticSelectionAgent",fName:"Eukaryotic Selection Agent",type:"text",options:[["Blasticidin S","Blasticidin S"]]},
							{dbType:"date",name:"dateExpires",fName:"Expiration Date",type:"date"},
							{name:"controlZone",fName:"Fire Control Zone",type:"text",options:[["Zone A","Zone A"],["Zone B","Zone B"],["Zone C","Zone C"],["Zone D","Zone D"]]},
							{dbType:"date",name:"freezeDate",fName:"Freeze Date",type:"date"},
							{name:"growthMedium",fName:"Growth Medium",type:"text"},
							{dbType:"number",name:"initialAmount",fName:"Initial Amount",type:"actual_number"},
							{name:"molFormula",fName:"Mol Formula",type:"text"},
							{dbType:"number",name:"molWeight",fName:"Mol Weight",type:"actual_number"},
							{dbType:"date",name:"obtainedDate",fName:"Obtained Date",type:"date"},
							{name:"obtainedFrom",fName:"Obtained From",type:"text"},
							{dbType:"number",name:"purity",fName:"Purity",type:"actual_number"},
							{name:"rfid",fName:"RFID",type:"text"},
							{name:"sampleType",fName:"Sample Type",type:"text",options:[["Cell Line","Cell Line"],["Viral Vector","Viral Vector"]]},
							{dbType:"number",name:"selectionAgentConcentration",fName:"Selection Agent Concentration (ug/mL)",type:"actual_number"},
							{name:"sequence",fName:"Sequence",type:"text"},
							{name:"supplier",fName:"Supplier",type:"text"},
							{name:"supplierCatalogNumber",fName:"Supplier Catalog Number",type:"text"},
							{name:"units",fName:"Units",type:"text",options:[["kg","kg"],["g","g"],["mg","mg"],["bottles","bottles"],["gal","gal"],["L","L"],["ml","ml"],["uL","uL"],["mm","mm"]]},
							{name:"userAddedInitial.userName",fName:"User Added",type:"text"},
							{name:"vectorInformation",fName:"Vector Information",type:"text",options:[["Lentivirus","Lentivirus"]]},
							{name:"vialLabel",fName:"Vial Label",type:"text"},
							{dbType:"number",name:"viralParticles",fName:"Viral Particles/mL",type:"actual_number"}
						];
						}
					}else{
						loadFunction = function(){
							document.getElementById("advSearchFrame").contentWindow.searchFieldList = [
							{name:"name",fName:"Name",type:"text"},
							{dbType:"number",name:"purity",fName:"Purity",type:"actual_number"},
							{name:"supplier",fName:"Supplier",type:"text"},
							{dbType:"text",name:"barcode",fName:"Barcode",type:"text"},
							{dbType:"number",name:"initialAmount",fName:"Initial Amount",type:"actual_number"},
							{dbType:"number",name:"amount",fName:"Amount",type:"actual_number"},
							{name:"units",fName:"Units",type:"text",options:[["kg","kg"],["g","g"],["mg","mg"],["bottles","bottles"],["gal","gal"],["L","L"],["ml","ml"],["mm","mm"]]},
							{name:"supplierCatalogNumber",fName:"Supplier Catalog Number",type:"text"},
							{name:"casNumber",fName:"CAS Number",type:"text"},
							{name:"molFormula",fName:"Mol Formula",type:"text"},
							{dbType:"number",name:"molWeight",fName:"Mol Weight",type:"actual_number"},
							{name:"chemicalName",fName:"Chemical Name",type:"text"},
							{name:"userAddedInitial.userName",fName:"User Added",type:"text"},
							{name:"controlZone",fName:"Fire Control Zone",type:"text",options:[["Zone A","Zone A"],["Zone B","Zone B"],["Zone C","Zone C"],["Zone D","Zone D"]]},
							{dbType:"date",name:"dateExpires",fName:"Expiration Date",type:"date"}
						];
						if(searchFieldListIndex == "2"){
							document.getElementById("advSearchFrame").contentWindow.searchFieldList.push({dbType:"date",name:"dateReceived",fName:"Received Date",type:"date"})
							document.getElementById("advSearchFrame").contentWindow.searchFieldList.push({dbType:"text",name:"vendorLot",fName:"Vendor Lot",type:"text"})
							document.getElementById("advSearchFrame").contentWindow.searchFieldList.push({dbType:"text",name:"comments",fName:"Comments",type:"text"})
						}
						if(searchFieldListIndex == "3"){
							document.getElementById("advSearchFrame").contentWindow.searchFieldList.push({dbType:"date",name:"dateReceived",fName:"Received Date",type:"date"})
						}
						if(searchFieldListIndex == "4"){
							document.getElementById("advSearchFrame").contentWindow.searchFieldList.push({dbType:"text",name:"lotNumber",fName:"Lot Number",type:"text"})
							document.getElementById("advSearchFrame").contentWindow.searchFieldList.push({dbType:"number",name:"cost",fName:"Cost (USD)",type:"actual_number"})
						}
						}
					}
				}
			}
		}
	}
	r = restCall("/getObjectSearchFields/","POST",{});
	if(r.length>0){
		loadFunction3 = function(){
			for(var i=0;i<r.length;i++){
				document.getElementById("advSearchFrame").contentWindow.searchFieldList.push(r[i]);
			}
			document.getElementById("advSearchFrame").contentWindow.searchFieldList.sort(function(a, b){
			  var nameA=a.fName.toLowerCase(), nameB=b.fName.toLowerCase()
			  if (nameA < nameB) //sort string ascending
				return -1 
			  if (nameA > nameB)
				return 1
			  return 0 //default return value (no sorting)
			})
		}
	}else{
		loadFunction3 = function(){};
	}


	if(!chemistryInSearch){
		loadFunction2 = function(){
			loadFunction();
			iframeSearch.contentWindow.newGroup()
		}
	}else{
		loadFunction2 = loadFunction;
	}

	if(iframeSearch.attachEvent) {
		iframeSearch.attachEvent('onload',function(){loadFunction2();loadFunction3();});
	}else{
		iframeSearch.onload = function(){loadFunction2();loadFunction3();};
	}
	searchDiv.appendChild(iframeSearch);
	searchButton = document.createElement("input");
	searchButton.setAttribute("type","button");
	searchButton.setAttribute("id","searchButton");
	searchButton.value = "Search";
	searchButton.onclick = function(){
		if(ignoreTableFields){
			el = document.getElementById("searchObjectType");
			if(el.options[el.selectedIndex].value==""){
				alert("Please select an item type to search");
				return false;
			}
		}
		document.getElementById("searchButton").value="Loading...";
		document.getElementById("advSearchFrame").contentWindow.finalizeSearch();
		try{
			el=document.getElementById('listTable');
			el.parentNode.removeChild(el);
		}catch(err){}
		switch(companyId){
			//mskinv
			case 4:
				tableFields = ["Name","Location","Gene","Species","Company","Dye"];
				break;
			///mskinv
			case 70:
				tableFields = ["Name","Plasmid Official Name","Plasmid Detailed Name","Structure","Amount","Unit Type"];
				break;
			case 13:
				tableFields = ["Name","Barcode","LUA Number","Volume","Unit Type"];
				break;
			case 1:
				tableFields = ["Name","Location","Gene","Species","Company","Dye"];
				break;
			case 52:
				tableFields = ["Name","Barcode","Batch","Volume","Unit Type"];
				break;
			case 93:
				tableFields = ["Name","Location","Notebook Page","Barcode","Amount","Units"];
				break;
			case 17:
				tableFields = false;
				break;
			default:
				tableFields = ["Name","Location","Structure","Amount","Unit Type","Supplier","CAS Number"];
		}
		if(inFrame && globalUserInfo["dsBottles"]){
			tableFields = ["Name","Location","Barcode","Product ID","Structure","Amount","Unit Type","Purity","Density (g/mL)"];
		}
		// document.getElementById("advSearchFrame").contentWindow.loadSearch().then(function(query){
		// 	getList(false,false,query,tableFields);
		// });
		
		var vars = document.getElementById("advSearchFrame").contentWindow.loadSearchVars();
		loadSearch(vars[0],vars[1],vars[2]).then(function(query){
			getList(false,false,query,tableFields);
		});

		window.scroll(0,findPos(document.getElementById("listTable")));
	}
	searchDiv.appendChild(searchButton);
	input = document.createElement("input");
	input.setAttribute("type","hidden");
	input.setAttribute("id","fieldsForSearch");
	searchDiv.appendChild(input);
	input = document.createElement("input");
	input.setAttribute("type","hidden");
	input.setAttribute("id","savedSearchForSearch");
	searchDiv.appendChild(input);

	document.getElementById(containerId).appendChild(searchDiv);
}

function loadSearch(chemIframeId, chemTableArg, chemSearchDbNameArg) {
	return new Promise(function (resolve, reject) {
		finalizeSearch();
		makeMongoQuery(chemIframeId, chemTableArg, chemSearchDbNameArg).then(function (retVal) {
			resolve(retVal);
		});
	});
}

//INV-290 Relay label printing
function formatZPL_relay(textZpl){
	var zpl = "^XA"
	zpl += "^LS-412" //Left side reset 1.375" * 300dpi/inch = 412
	noOfLines = textZpl.length-1;
	//bar code
	//zpl += "^FO87,26,1"+"^BQN,2,3"+"^FDMM,A"+textZpl[textZpl.length-1]["barcodeValue"]+"^FS";
	//zpl += "^FO150,27"+"^BY2"+"^BCN,30,Y,Y,N"+"^FD"+textZpl[textZpl.length-1]["barcodeValue"]+"^FS";
	
	zpl += "^FO18,40"+"^BXN,3,200,20,20,,_"+"^FD_110"+textZpl[textZpl.length-1]["barcodeValue"]+"^FS";		//GS1 DataMatrix 2D barcode
	
	for (i=0; i<noOfLines; i++){
		var obj = (textZpl[i]);
		if(obj.hasOwnProperty('lineLabel') && obj["lineLabel"] != ""){
			str = obj["lineLabel"] + obj["line"]
		}
		else {
			str = obj["line"]
		}
		//For relay the first line has to be printed with BOLD letters
		var bold = false;
		if (i == 0){
			//bold = true;
		}
		zpl += lineZPL_relay(str, i, noOfLines, bold);
	}
	
	zpl += "^FO360,32"+"^BXN,3,200,20,20,,_"+"^FD_110"+textZpl[textZpl.length-1]["barcodeValue"]+"^FS";		//GS1 DataMatrix 2D barcode
	zpl += "^FO8,103"+"^A0,15,15"+"^FD"+textZpl[textZpl.length-1]["barcodeValue"]+"^FS";	//Barcode identifier printed as text under the QR code
	zpl += "^XZ"

	console.log("Final Zpl ::"+ zpl);
	return zpl;
}

function lineZPL_relay(l,n,nl,bold){
	var labelLength = 300;     //1" or 300DPI for ZPL 2824 Plus
	var labelHeight = 112;     //.375" or 203 x 3 = 609DPI
	var fontH = 20;
	var fontW = 20;
	var offsetX = 150;	//The rectangle label is located .5" away from left end		.5" * 300 = 150
	var offsetY = 20;	//The top gap between label and dotted line .0625"		0.625" * 300 ~ 20
	//var barCodeHeight = 30
	var barCodeHeight = 0
	//var lineSpacing = Math.floor((labelHeight - barCodeHeight - nl * fontH)/(nl));
	
	var res = "^FO"+(offsetX)+","+( barCodeHeight +(n)*fontH + offsetY + (n+1)*(6));
	res += "^A0,"+(fontH)+","+(fontW);
	res += "^FD"+l.trim()+"^FS";
	if(bold){
	  res +=  "^FO"+(offsetX-2)+","+( barCodeHeight +(n+1)*fontH + offsetY);
	  res += "^A0,"+(fontH)+","+(fontW);
	  res += "^FD"+l.trim()+"^FS";
	}
	//console.log("res ::", res)
	return res;
}

function formatZPL(textZpl){
	var zpl = "^XA"
	zpl += "^FWR" //Rotate the text 90 degrees
	zpl += "^LS-100" //Left side reset 1"
	noOfLines = textZpl.length-1;
	for (i=0; i<noOfLines; i++){
		var obj = (textZpl[i]);
		if(obj.hasOwnProperty('lineLabel') && obj["lineLabel"] != ""){
			str = obj["lineLabel"] + obj["line"]
		}
		else {
			str = obj["line"]
		}
		zpl += lineZPL(str, i, noOfLines);
	}
	//QR bar code
	zpl += "^FO220,460,1"+"^BQN,2,7"+"^FDMM,A"+textZpl[textZpl.length-1]["QRcodeValue"]+"^FS";
	zpl += "^FO35,520"+"^A0,15,15"+"^FD"+textZpl[textZpl.length-1]["QRcodeValue"]+"^FS";
	zpl += "^XZ"

	//console.log("Final Zpl ::"+ zpl);
	return zpl;
}

function lineZPL(l,n,nl){
   //Default font 0 - 15Hx12W Font Matrices Table34 - page 1290 in https://www.zebra.com/content/dam/zebra/manuals/en-us/software/zpl-zbi2-pm-en.pdf
   var labelLength = 203;     //1" or 203DPI for ZPL 2824 Plus
   var labelHeight = 609;     //3" or 203 x 3 = 609DPI
   var fontH = 20;
   var fontW = 20;
   var offsetX = 20;
   var offsetY = 10;
   var lineSpacing = Math.floor((labelLength - 2 * offsetY - nl * fontH)/(nl - 1));
   var textLength = l.length;
   var textGaps = textLength - 1;
   var textWidth = textLength * 10 + textGaps * 2;
   //console.log("textWidth ::"+ textWidth);
   var maxWidth = 400      //~~ 609 - offsetX - 200 QR height
   if (textWidth > maxWidth){
       //Instead of displaying in two lines just decrease the font to fit
       fontW1 = Math.round((400 - (textGaps *2))/textLength);
   }
   //console.log("FO :: "+(labelLength - (n)*fontH - offsetY - n*lineSpacing))
   var res = "^FO"+(labelLength - (n)*fontH - offsetY - (n)*lineSpacing)+","+(offsetX);
   res += "^A0,"+(fontH)+","+(fontW);
   res += "^FD"+l+"^FS";
   return res;
}

//INV-316 yumanity label printing
function formatZPL_yumanity(textZpl){
	var zpl = "^XA"
	zpl += "^LS-412" //Left side reset 1.375" * 300dpi/inch = 412
	noOfLines = textZpl.length-1;
	//bar code
	zpl += "^FO150,27"+"^BY2"+"^BCN,30,Y,Y,N"+"^FD"+textZpl[textZpl.length-1]["barcodeValue"]+"^FS";
	zpl += "^FO150,62^A0,22,22^FD"+textZpl[textZpl.length-1]["barcodeValue"]+"^FS";
	
	zpl += "^FO18,40"+"^BXN,3,200,20,20,,_"+"^FD"+textZpl[textZpl.length-1]["barcodeValue"]+"^FS";		//GS1 DataMatrix 2D barcode
	
	for (i=0; i<noOfLines; i++){
		var obj = (textZpl[i]);
		if(obj.hasOwnProperty('lineLabel') && obj["lineLabel"] != ""){
			str = obj["lineLabel"] + obj["line"]
		}
		else {
			str = obj["line"]
		}
		//For relay the first line has to be printed with BOLD letters
		var bold = false;
		if (i == 0){
			//bold = true;
		}
		zpl += lineZPL_yumanity(str, i, noOfLines, bold);
	}
	
	zpl += "^XZ"

	console.log("Final Zpl ::"+ zpl);
	return zpl;
}

function formatZPL_Sunovion(textZpl){
	var zpl = "^XA";
	zpl += "^FO10,50^LS-40";
	var fontHeight = 50;

	// first the barcode
	zpl += "^B3N,N,"+fontHeight+",Y,N";
	zpl += "^FD"+textZpl[0]["barcodeValue"]+"^FS";

	// then the lines...
	noOfLines = textZpl.length;
	for (i=1; i<noOfLines; i++){
		var obj = (textZpl[i]);
		if(obj.hasOwnProperty('lineLabel') && obj["lineLabel"] != ""){
			str = obj["lineLabel"] + obj["line"];
		}
		else {
			str = obj["line"];
		}		
		zpl += lineZPL_sunovion(str, i, noOfLines);
	}

	zpl += "^XZ";
	console.log("Final Zpl ::"+ zpl);
	return zpl;

}

function lineZPL_sunovion(l,n,nl,bold){
	
	// Sunovion uses a 0.5" x 1.5" label

	var fontH = 25;
	var fontW = 25;

	//console.log("FO :: "+(labelLength - (n)*fontH - offsetY - n*lineSpacing))
	var res = "^FO0,140";
	res += "^A0N,"+(fontH)+","+(fontW);
	res += "^FD"+l+"^FS";
	return res;
}

function lineZPL_yumanity(l,n,nl,bold){
	var labelLength = 300;     //1" or 300DPI for ZPL 2824 Plus
	var labelHeight = 112;     //.375" or 203 x 3 = 609DPI
	var fontH = 20;
	var fontW = 20;
	var offsetX = 150;	//The rectangle label is located .5" away from left end		.5" * 300 = 150
	var offsetY = 84;	//The top gap actual barcode + barcode text
	
	var res = "^FO"+(offsetX)+","+((n)*fontH + offsetY);
	res += "^A0,"+(fontH)+","+(fontW);
	res += "^FD"+l.trim()+"^FS";
	if(bold){
		res +=  "^FO"+(offsetX-2)+","+((n+1)*fontH + offsetY + n*4);
		res += "^A0,"+(fontH)+","+(fontW);
		res += "^FD"+l.trim()+"^FS";
	}
	//console.log("res ::", res)
	return res;
}

/**
 * Save the given form.
 * @param {JSON} fd The form object to save.
 * @param {boolean} remove Remove this form on completion?
 * @param {string} elnLink The link to the ELN experiment.
 */
function saveForm(fd,remove, elnLink){
	var payload = {'formId':fd.fid,'remove':remove};
	if (elnLink) {
		payload["link"] = elnLink;
	}
	return restCall("/saveForm/","POST",payload);
}

function saveFormMulti(fd,remove,fieldName,values,elnLink,newParentId,source){
	var payload = {'formId':fd.fid,'remove':remove,'fieldName':fieldName,'values':values};
	if(elnLink){
		payload["elnLink"] = elnLink;
	}
	if(newParentId){
		payload["newParentId"] = newParentId;
	}
	if(source){
		payload["source"] = source;
	}
	return restCall("/saveFormMulti/","POST",payload);
}

function saveFormA(fd,remove,cb){
	var payload = {'formId':fd.fid,'remove':remove};
	return restCallA("/saveForm/","POST",payload,cb,"","async");
}

//function deleteForm(fd){
//	var payload = {'formId':fd.fid};
//	return restCall("/deleteForm/","POST",payload);
//}

function validateField(theField){
	fieldValid = true;
	if(theField.required){
		if(theField.value=="" && theField.value.toString()!="0"){
			fieldValid = false;
			document.getElementById(theField.id+"_error").innerHTML = "Field is required"
		}else{
			document.getElementById(theField.id+"_error").innerHTML = ""
		}
	}
	return fieldValid;
}

function validateForm(fd){
	formValid = true;
	
	var payload = {'formId':fd.fid};
	r = restCall("/validateForm/","POST",payload);
	
	if(r["status"]=="fail"){
		formValid = false;
		for(var i=0;i<r["errors"].length;i++){
			thisError = r["errors"][i];
			el = document.getElementById(thisError["id"]+"_error");

			el.innerHTML = "<br/>"+thisError["errors"].join("<br/>")
		}
		window.scroll(0,0)
		window.top.swal("", "Form contains errors. Please review your data and try again.", "error");
		return;
	}

	var dropdownOtherTextboxIsEmpty = false;
	$('select.ax1-select').each(function(){
		var dropdownOtherTextbox = $(this).parent().find('input.dropdownOtherTextbox[type="text"][dropdownid="' + $(this).attr('id') + '"]');
		if(dropdownOtherTextbox.length > 0){
			if(dropdownOtherTextbox.val() == ""){
				window.top.swal("Dropdowns with \"Other\" selected must have text entered into the supporting field.",null,"error")
				dropdownOtherTextboxIsEmpty = true;
				return;
			}
			else{
				// Adding the value of the textbox as the selected <option>
				$(this).append('<option value="'+dropdownOtherTextbox.val()+'" selected>'+dropdownOtherTextbox.val()+'</option>').change();
			}
		}
	});
	
	var emptyRequiredConditionalField = false;
	$('.conditionalInvTemplateField.conditionalField_required[class*="showConditional_"]').each(function(){
		if($(this).find('input[type="text"]').val() == "" || $(this).find('option:selected').attr('value') == ""){
			$(this).find('span[class*="itemErrorax1"]').text(' Field is required');
			emptyRequiredConditionalField = true;
			window.top.swal("", "Required conditional dropdowns must have a value selected.", "error")
			return;
		}
		else{
			$(this).find('span[class*="itemErrorax1"]').text(''); // Clear the error
		}
	});

	var multipleValuesFieldError = false;
	$('div[multiplevalues="True"]').each(function(){
		var multipleValuesField_min = parseInt($(this).attr('multiplevalues_minvalues'))
		var multipleValuesField_max = parseInt($(this).attr('multiplevalues_maxvalues'))
		if(isNaN(multipleValuesField_min)){
			multipleValuesField_min = 1;
		}
		if(isNaN(multipleValuesField_max)){
			multipleValuesField_max = 1000;
		}
		var numberOfValues = $(this).find('.multipleValuesField_valueContainer').length
		if(numberOfValues < multipleValuesField_min){
			window.top.swal("","The multi-value field '"+$(this).attr('formname')+"' only has "+numberOfValues+" values. It requires at least " + multipleValuesField_min + " values.","error")
			multipleValuesFieldError = true;
			return;
		}
		else if(numberOfValues > multipleValuesField_max){
			window.top.swal("","The multi-value field '"+$(this).attr('formname')+"' has "+numberOfValues+" values. It must have no more than " + multipleValuesField_max + " values.","error")
			multipleValuesFieldError = true;
			return;
		}
		else{
			var multipleValuesArray = [];
			$(this).find('.multipleValuesField_valueContainer').each(function(){
				var valueEntered = $(this).find('input[type="text"]').val();
				multipleValuesArray.push({"value":valueEntered});
			});
			$(this).children('input[type="text"]').val(JSON.stringify(multipleValuesArray)).change();
		}
	});
	
	formValid = (formValid && !dropdownOtherTextboxIsEmpty && !emptyRequiredConditionalField && !multipleValuesFieldError);

	if(formValid)
	{
		var intervalsToCancel = [];
		$.each(fd.fields, function(fi, theField){
			if(theField.hasOwnProperty("intervals") && theField["intervals"] != null)
			{
				$.each(theField["intervals"], function(ii, theInterval) {
					intervalsToCancel.push(theInterval);
				});
				
				delete theField["intervals"];
			}
		});
		
		$.each(intervalsToCancel, function(ii, thisInterval) {
			window.clearInterval(thisInterval);
		});
	}

	return formValid;
}

function makeField(fd,thisField,fieldId,containerId){
	r = {"label":false,"el":false,"errorEl":false};
	thisLabel = document.createElement("label");
	labelText = thisField["formName"];
	if(thisField.required){
		labelText += "*";
	}
	thisLabel.appendChild(document.createTextNode(labelText));
	thisLabel.setAttribute("for",fieldId);
	if(thisField["fieldType"]=="errorTable"){
		thisEl = createErrorTable(fd,thisField,fieldId,fieldId);
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="fieldMapping"){
		thisEl = createFieldMapping(fd,thisField,fieldId,fieldId);
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
		if($(thisEl).find('tbody').html() == ""){ // field mapping table isn't visible, hide associated button & dropdown
			$('.bulkImport_bulkUpdateMapTemplatesDropdown, .saveAsNewMappingTemplateButton').hide();
		}
		else{
			updateMappingTemplateDropdown('bulkImport_bulkUpdateMapTemplatesDropdown', window.bulkImport_bulkUpdateMappingTemplates, window.latestImportOptions['sdFields'].join(','), $('div[formname="Object Type"] select').val());
			$('.bulkImport_bulkUpdateMapTemplatesDropdown, .saveAsNewMappingTemplateButton').show();
		}
	}
	else if(thisField["fieldType"]=="text"){
		if (!fd["view"]){
			thisEl = createTextBox(fd,thisField,fieldId,fieldId);
		}else{
			thisEl = showText(fd,thisField,fieldId,fieldId);
		}
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="productId"){
		thisEl = showProductId(fd,thisField,fieldId,fieldId);
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="reactantIds"){
		thisEl = showReactantIds(fd,thisField,fieldId,fieldId);
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="itemGrid"){
		thisEl = createItemGrid(fd,thisField,fieldId,fieldId);
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="date"){
		if (!fd["view"]){
			thisEl = createDateBox(fd,thisField,fieldId,fieldId);
		}else{
			thisEl = showText(fd,thisField,fieldId,fieldId);
		}
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
		cals.push((function(fieldId){
			return function(){
				Calendar.setup(
				{
				  inputField  : fieldId,         // ID of the input field
				  ifFormat    : "%m/%d/%Y",    // the date format
				  showsTime   : false,
				  timeFormat  : "12",
				  electric    : false
				}
			  );
			}
		})(fieldId))
	}
	else if(thisField["fieldType"]=="password"){
		if (!fd["view"]){
			thisEl = createPasswordBox(fd,thisField,fieldId,fieldId);
		}else{
			thisEl = document.createElement("span");
		}
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="textarea"){
		if (!fd["view"]){
			thisEl = createTextArea(fd,thisField,fieldId,fieldId)
		}else{
			thisEl = showText(fd,thisField,fieldId,fieldId)
		}
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if (thisField["fieldType"] == "select"){
		if (!fd["view"]){
			thisEl = createSelect(fd,thisField,fieldId,fieldId)
		}else{
			thisEl = showText(fd,thisField,fieldId,fieldId)
		}
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"] == "checkbox"){
		if (!fd["view"]){
			thisEl = createCheckBox(fd,thisField,fieldId,fieldId)
		}else{
			thisEl = showText(fd,thisField,fieldId,fieldId)
		}
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"] == "userInfo"){
		thisEl = showText(fd,thisField,fieldId,fieldId,thisField.displayKey)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"] == "dateFixed"){
		thisEl = showText(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="chem"){
		thisEl = createChemBox(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="addChildLink"){
		thisEl = createAddChildLink(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="showChildLinks"){
		thisEl = createShowChildLinks(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="childLinks2"){
		thisEl = createChildLinks2(fd,thisField,fieldId,fieldId,fd["view"])
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	//invPerm
	else if(thisField["fieldType"]=="permissions"){
		thisEl = createPermissions(fd,thisField,fieldId,fieldId,fd["view"])
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	//end invPerm
	else if(thisField["fieldType"]=="file"){
		thisEl = createFileBox(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="multiText"){
		if (!fd["view"]){
			thisEl = createMultiText(fd,thisField,fieldId,fieldId)
		}else{
			thisEl = showText(fd,thisField,fieldId,fieldId)
		}
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="widget"){
		thisEl = document.createElement("div");
		thisEl.setAttribute("id",fieldId);
		thisEl.className = "widget";
		thisWidget = new window[thisField.widgetName](fieldId,thisField.value,fd)
		//thisEl.appendChild(thisWidget.makeHTML())
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
		r["widget"] = thisWidget;
	}
	else if(thisField["fieldType"]=="plateMap"){
		thisEl = createPlateMap(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="button"){
		if (!fd["view"]){
			thisEl = createButton(fd,thisField,fieldId,fieldId)
		}
		thisEl.className += "ax1-"+thisField["fieldType"];
		r["el"] = thisEl;
	}
	else if(thisField["fieldType"]=="actionButton"){
		thisEl = createActionButton(fd,thisField,fieldId,fieldId,containerId)
		thisEl.className += "ax1-"+thisField["fieldType"];
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]!="generated"){
		span = document.createElement("span");
		span.className = "itemError";
		span.className += "ax1-"+thisField["fieldType"]+"-error";
		span.setAttribute("id",fieldId+"_error");
		span.setAttribute("formName",thisField["formName"]+"_error")
		r["errorEl"] = span;
		//br = document.createElement("br")
		//form.appendChild(br)
	}

	try{
		if(thisEl){
			thisEl.setAttribute("formName",thisField["formName"]);
		}
	}catch(err){}
	thisEl = null
	return r;
}

function applyTemplate(data,fd,containerId,cb){
	data = data.replace("thisId=X;","thisId='objectTemplate_"+fd.fid+"';")
	div = document.createElement("div");
	div.innerHTML = data;
	div.setAttribute("id","objectTemplate_"+fd.fid)
	div.className = "templateDiv"
	formDiv.appendChild(div);
	form.style.display = "none";
	formDiv.appendChild(form);
	document.getElementById(containerId).appendChild(formDiv);
	for(var i=0;i<cals.length;i++){
		cals[i]();
	}
	$("#objectTemplate_"+fd.fid+" [formName]").each(function(i,el){
		targetEl = $("#"+fd.fid+" [formName='"+el.getAttribute("formName")+"']").get()[0];
		if(targetEl){
			$(el).append(targetEl);
		}else{			
			var par = $(el).parent();

			$(el).remove();

			if ($(par)
				&& $(par).children().length == 0
				&& $(par).hasClass("templateBottomInfoContainer")) {
				$(par).hide();
			}			
		}
		targetEl = $("#"+fd.fid+" [formName='"+el.getAttribute("formName")+"_error']");
		if(targetEl){
			$(el).append(targetEl);
		}
	});

	$.each($('.templateSelect .ax1-select'), function(index, val) {
//		alert("here");
		// Grab the value & text of correct selected option
		var selectedOptionVal = $(this).find('option:selected').attr('value');
		var selectedOptionText = $(this).find('option:selected').text();
		// Reorder option elements alphabetically
		if (typeof selectedOptionVal !== "undefined")
		{
			$(this).children().detach().sort(function (a, b) {
				return $(a).text().localeCompare($(b).text());
			}).appendTo($(this));
			// Now select the correct option again
			$.each($(this).find('option'), function (optionIndex, optionElement) {
				if ($(this).attr('value') == selectedOptionVal && $(this).text() == selectedOptionText) {
					$(this).prop('selected', 'selected');
				}
			});
		}
	});

	delayedRunJS(data,fd.fid);

	// Used to be in repeatedlyCheckFormLoaded setInterval
	// Fields that belong to groups need to be ...grouped
	$('div.templateText, div.templateDate, div.templateSelect').each(function(){
		if(typeof $(this).attr('fieldgroupid') !== "undefined"){
			var fieldGroupId = $(this).attr('fieldgroupid');
			var fieldGroupName = "";
			// Look for the field group on the page
			if($('div.fieldGroupContainer[fieldgroupid="'+fieldGroupId+'"]').length == 0){
				$.each(window.itemJSON['fieldGroups'], function(index, fieldGroup){
					if(fieldGroup['fieldGroupId'] == fieldGroupId){
						fieldGroupName = fieldGroup['fieldGroupName']
					}
				});
				var fieldGroupContainerHTML = '<div class="fieldGroupContainer" fieldgroupid="'+fieldGroupId+'"><label class="fieldGroupName">'+fieldGroupName+'</label><div class="fieldGroupFields"></div></div>'
				$(this).after(fieldGroupContainerHTML)
			}
			$('.fieldGroupContainer[fieldgroupid="'+fieldGroupId+'"] .fieldGroupFields').append($(this));
			if(typeof $(this).attr('multiplevalues') !== "undefined" && $(this).attr('multiplevalues').toLowerCase() == "true" && $('#arxOneContainer').attr('latestaction') !== "view"){
				if($('.fieldGroupContainer[fieldgroupid="'+fieldGroupId+'"] .fieldGroupFields').find('.groupedMultiValueFieldsButtons').length == 0){
					groupedMultiValueFieldsButtonsHTML = '<div class="groupedMultiValueFieldsButtons"><button class="newValuesButton">+ Add Row</button></div>';
					$('.fieldGroupContainer[fieldgroupid="'+fieldGroupId+'"] .fieldGroupFields').append(groupedMultiValueFieldsButtonsHTML);
				}
				$('.fieldGroupContainer[fieldgroupid="'+fieldGroupId+'"] .fieldGroupFields .groupedMultiValueFieldsButtons').prepend('<button class="removeValuesButton">- Remove Row</button>');
				// Move the .groupedMultiValueFieldsButtons so that it's AFTER the last multivalue field in the group
				$('.fieldGroupContainer[fieldgroupid="'+fieldGroupId+'"] .fieldGroupFields .groupedMultiValueFieldsButtons').insertAfter('.fieldGroupContainer[fieldgroupid="'+fieldGroupId+'"] .fieldGroupFields div[multiplevalues="True"]:last-of-type');
			}

		}
	});


	// INV-174 Disable dropdown options of conditional fields on form load - on .change() the right fields are re-enabled
	$('.conditionalInvTemplateField select.ax1-select > option').each(function(){
		if(typeof $(this).attr('fieldoptionid') !== "undefined"){
			$(this).prop('disabled',true)
		}
	});

	// INV-175 Conditional fields that are empty are hidden in view mode
	if($('#arxOneContainer').attr('latestaction') == "view"){
		$('.conditionalInvTemplateField > label + span').each(function(){
			if($(this).is(':empty')){
				$(this).parent().addClass('hideInvTemplateField');
			}
		});
	}

	// Helps initialize form dropdowns
	$('select.ax1-select').change();
	
	// disableInvTemplateField class is added based on disableOnEdit setting - disable editing of the field
	if($('div.templateText > input, div.templateDate > input').length > 0){ // This is an Edit form, so disable .disableInvTemplateField elements
		$('div.templateDate.disableInvTemplateField > input.ax1-date, div.templateText.disableInvTemplateField > input.ax1-text').prop('disabled',true);
	}
	// INV-163, INV-164
	if($('div.templateDate[formname="Prepared Date"] > input[type="text"][formname="Prepared Date"]').length > 0){
		if($('div.templateDate[formname="Prepared Date"] > input[type="text"][formname="Prepared Date"]').val() == ""){
			$('div.templateDate[formname="Prepared Date"] > input[type="text"][formname="Prepared Date"]').val(moment().format('MM/DD/YYYY')).change();
			if($('div.templateText[formname="Days to Expire"] > input[type="text"][formname="Days to Expire"]').length > 0 && $('div.templateDate[formname="Expiration Date"] > input[type="text"][formname="Expiration Date"]').length > 0){
				// Setting value of the expiration date based on the # of Days to Expire set in the admin interface
				$('div.templateDate[formname="Expiration Date"] > input[type="text"][formname="Expiration Date"]').val(moment().add($('div.templateText[formname="Days to Expire"] > input[type="text"][formname="Days to Expire"]').val(),'days').format('MM/DD/YYYY')).change();
			}
		}
	}

	$('div.templateDate').each(function(){
		var autopopulatefield_days = $(this).attr('autopopulatefield_days');
		var autopopulatefield_beforeorafter = $(this).attr('autopopulatefield_beforeorafter');
		if(typeof autopopulatefield_days !== "undefined" && typeof autopopulatefield_beforeorafter !== "undefined"){
			$(this).find('input[type="text"]').change();
		}
	});

	$('div.templateText').each(function(){
		var multipleValues = $(this).attr('multipleValues')
		var multipleValues_minValues = $(this).attr('multipleValues_minValues')
		var multipleValues_maxValues = $(this).attr('multipleValues_maxValues')
		if(typeof multipleValues !== "undefined"){
			try{
				if($('#arxOneContainer').attr('latestaction') == "view" && $(this).find('.ax1-text').text() !== ""){
					fieldValueJSONParsed = JSON.parse($(this).find('.ax1-text').text());
				}
				else if($(this).find('.ax1-text').val() !== ""){ // Or it's edit/add w/ a value
					fieldValueJSONParsed = JSON.parse($(this).find('.ax1-text').val());
				}
				else{ // Or it's blank
					fieldValueJSONParsed = [{"value":""}]; // Empty multi-value on "Add" page is set up here
				}
			}
			catch(e){
				fieldValueJSONParsed = [{"value":""}];
				swal("", "There was an error loading a multi-value field", "warning")
				console.error("Error loading multi-value field")
			}
			$(this).children('.ax1-text').hide();
			var formFieldElement = $(this);
			//console.log(fieldValueJSONParsed)
			$.each(fieldValueJSONParsed, function(index, entry){
				var entryValue = entry['value'];
				if($('#arxOneContainer').attr('latestaction') == "view"){
					formFieldElement.append('<div class="multipleValuesField_valueContainer"><div class="multipleValuesField_value"></div></div>');
					formFieldElement.find('.multipleValuesField_valueContainer:last-of-type div.multipleValuesField_value').text(entryValue);
				}
				else{
					formFieldElement.append('<div class="multipleValuesField_valueContainer"><input type="text" placeholder="value"><button class="multipleValuesField_removeValueButton">- Remove</button><button class="multipleValuesField_newValueButton" type="button">+ New Value</button></div>');
					formFieldElement.find('.multipleValuesField_valueContainer:last-of-type input[type="text"]').val(entryValue);
				}
			});
		}
	});

	var initialAmountFieldValueObj = {}
	$.each(window.itemJSON['fields'],function(key,field){
		// Go through all the fields and find the initialAmountField & initialAmountFieldUnits, then combine their values and add that below User Added/Date Created
		if(field['dbName'] == "initialAmountField"){
			initialAmountFieldValueObj['initialAmountValue'] = field['value'];
			initialAmountFieldValueObj['initialAmountLabel'] = field['formName']
		}
		else if(field['dbName'] == "initialAmountFieldUnits"){
			initialAmountFieldValueObj['initialAmountUnits'] = field['value'];
		}
	});
	if(initialAmountFieldValueObj['initialAmountValue'] && initialAmountFieldValueObj['initialAmountLabel'] && initialAmountFieldValueObj['initialAmountUnits']){
		$('.templateBottomInfoContainer').after('<div class="templateInitialAmountAndUnits"><label class="initialAmountAndUnitsLabel">' + initialAmountFieldValueObj['initialAmountLabel'] + '</label><div class="initialAmountAndUnitsValue">' + initialAmountFieldValueObj['initialAmountValue'] + " " + initialAmountFieldValueObj['initialAmountUnits'] + '</div></div>')
	}

	$('.isRegLookupField input.ax1-text[type="text"]').select2({
		text: function (item) { return item.regId },
		ajax: {
			url: "invp.asp?r="+Math.random(),
			dataType: 'json',
			delay: 350,
			method: "POST",
			type: "POST",
			contentType: "application/x-www-form-urlencoded",
			data: function (params) {
				return {
			    	url: "/getRegIdSuggestionsFromReg",
			    	verb: "POST",
			    	data: JSON.stringify({"connectionId":connectionId,"userInputValue":params,"regLookupFieldGroupId":$(this.context).parent().attr('reglookupfieldgroupid'),"columnsInTypeAhead":$(this.context).parent().attr('columnsintypeahead')}),
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
			return item.regId
		},
		formatSearching: null,
		initSelection : function (element, callback) {
			var data = {id: element.val(), regId: element.val()};
	        callback(data);
	    },
	    dropdownCssClass : 'invLookupTypeaheadDropdownWide'
	}); 

	// INV-177
	$('.isRegLookupField > span.ax1-text').each(function(){
		regIdLookupFieldContainer = $(this).parent();
		regId = $(this).text()
		groupId = $(this).parent().attr('reglookupfieldgroupid')
		regLookupFieldColumns = $(this).parent().attr('reglookupfieldcolumns')
		if (regId!=""){
			// Make a link out of the Reg ID value
			// 5525: Don't display the ending batch number "-00". This is what we are doing in ShowBatch.asp as well.
			regIdDisplayed = removeBatchNumberFromRegId(regId);
			replacementHTML = "<a href='javascript:void(0)' class='regLink' onclick='toggleRegData(\"" + $(this).attr('id') + "\",\"" + regId + "\")'>" + regIdDisplayed + "</a>"
			replacementHTML += "<a href='/arxlab/registration/showRegItem.asp?regNumber="+regId+"' class='regLink' target=\"_blank\"><img class='openInNewWindowImg' src='/arxlab/images/open_new_window.png' /></a>";
			replacementHTML += '<span class="lookupFieldsToggleButton">Hide Related Fields</span>'
			$(this).html(replacementHTML)
			
			// Request the values for the column names stored in the form
			lookupRegIdSuggestions = JSON.parse(restCall("/getLookupFieldDataFromReg/","POST",{"regId":regId,"regFieldGroupId":groupId,"realColumnNames":regLookupFieldColumns}));
			if(lookupRegIdSuggestions['status'] == "success"){
				var conditionalFieldsHTML = ""
				$.each(lookupRegIdSuggestions['results'], function(realColummName, lookupField){
					if(lookupField['value'] == null){lookupField['value']="";}
					conditionalFieldsHTML += '<div class="templateText" formname="'+regIdLookupFieldContainer.attr('formname')+'_'+lookupField['displayName']+'" originformname="'+regIdLookupFieldContainer.attr('formname')+'"><label class="ax1-text-label"><span class="regLookupFieldIndicator">Reg</span><span class="regLookupFieldLabel">'+lookupField['displayName']+'</span></label><span class=" ax1-text" formname="'+regIdLookupFieldContainer.attr('formname')+'_'+lookupField['displayName']+'">'+lookupField['value']+'</span></div>'
				});
				regIdLookupFieldContainer.after(conditionalFieldsHTML)
			}
		}
	});

	// Loop through JS code for fields that have JS code entered in Inventory's admin interface
	$.each(window.itemJSON['fields'],function(key,field){
		if(field['templateFieldJS']){
			eval(field['templateFieldJS'])
		}
	});

	if(cb!=undefined){
		cb();
	}
}

// 5525: Remove the ending batch number from Reg ID for UI displaying.
function removeBatchNumberFromRegId(regId) {
	regIdDisplayed = regId;
	if (typeof regBatchNumberLength != 'undefined' && regBatchNumberLength > 0 && typeof regBatchNumberDelimiter != 'undefined' && regBatchNumberDelimiter != '') {
		// If there is no regBatchNumberDelimiter, let's not mess with it.
		regBatchNum = regBatchNumberDelimiter;
		for (i = 0; i < regBatchNumberLength; i++) {
			regBatchNum += "0";
		}
		batchZeroPos = regId.lastIndexOf(regBatchNum);
		if (batchZeroPos == (regId.length - regBatchNumberLength - 1)) {
			regIdDisplayed = regId.substring(0, batchZeroPos);
		}
	}
	return regIdDisplayed;
}


function makeObjectTemplateHTML(objectTemplateRequest){
	var dataMiddle = "";
	if(objectTemplateRequest['result'] == "success"){
		var templateElement = $('<div class="objectTemlpateContainer"></div>');
		var templateObject = objectTemplateRequest['templateObject'];
		
		if(templateObject['hasStructure']){
			//console.log("template element innerHTML BEFORE: ", $(templateElement).innerHTML);
			
			var hasStructureHTML = '<div class="templateImage" formName="Structure">'
			hasStructureHTML += '    <div class="structurePropertiesBox">'
			hasStructureHTML += '        <div class="templateText expandContentOnHover" formName="Chemical Name">'
			hasStructureHTML += '            <label for="877f4ffb6a" class="ax1-text-label">Chemical Name</label>'
			hasStructureHTML += '        </div>'
			hasStructureHTML += '        <div class="templateText" formName="Mol Weight">'
			hasStructureHTML += '            <label for="a146654504" class="ax1-text-label">Mol Weight</label>'
			hasStructureHTML += '        </div>'
			hasStructureHTML += '        <div class="templateText" formName="Formula">'
			hasStructureHTML += '            <label for="877f4ffb6a" class="ax1-text-label">Mol Formula</label>'
			hasStructureHTML += '        </div>'
			hasStructureHTML += '        <div class="templateText" formName="CAS Number">'
			hasStructureHTML += '            <label for="877f4ffb6a" class="ax1-text-label">CAS Number</label>'
			hasStructureHTML += '        </div>'
			hasStructureHTML += '    </div>'
			hasStructureHTML += '</div>'
			templateElement.append(hasStructureHTML);
		
			//console.log("template element innerHTML AFTER: ", $(templateElement).innerHTML);
		}

		$.each(templateObject['fields'], function(index, templateField){
			var fieldClasses = [];
			var fieldAttributes = {};
			var fieldLabelClasses = [];
			var fieldElement = $('<div class="objectTemplateField"></div>');
			
			// First build the array of classes to add to this field
			// Add the base classes for each formType first...
			if(templateField["formType"] == "text" || templateField["formType"] == "checkbox"){
				fieldClasses.push("templateText")
				fieldLabelClasses.push("ax1-text-label")
			}
			else if(templateField["formType"] == "select"){
				fieldClasses.push("templateSelect")
				fieldLabelClasses.push("ax1-select-label")
			}
			else if(templateField["formType"] == "textarea" || templateField["formType"] == "multiText"){
				fieldClasses.push("templateTextarea")
				fieldLabelClasses.push("ax1-textarea-label")
			}
			else if(templateField["formType"] == "file"){
				fieldClasses.push("templateFile")
				fieldLabelClasses.push("ax1-file-label")
			}
			else if(templateField["formType"] == "date"){
				fieldClasses.push("templateDate")
				fieldLabelClasses.push("ax1-date-label")
			}
			else if(templateField["formType"] == "widget"){
				fieldClasses.push("templateWidget")
				fieldLabelClasses.push("ax1-date-label")
			}
			if(templateField['hideFieldWithCSS']){
				fieldClasses.push("hideInvTemplateField")
			}
			if(templateField['conditional']){
				fieldClasses.push("conditionalInvTemplateField")
			}
			if(templateField['condRequired']){
				fieldClasses.push("conditionalField_required")
			}
			if(templateField['disableOnEdit']){
				fieldClasses.push("disableInvTemplateField")
			}
			if(templateField['textOnOther']){
				fieldClasses.push("addTextOnOther")
			}
			
			if(templateField['isLookupField'] == true && templateField['lookupSourceApp'] == "reg"){
				fieldClasses.push("isRegLookupField")
				if(templateField['lookupRegField'] && templateField['lookupRegField'] !== ""){
					fieldAttributes['reglookupfieldgroupid'] = templateField['lookupRegField'];
				}
				if(templateField['lookupRegFieldsToAdd']){
					fieldAttributes['reglookupfieldcolumns'] = templateField['lookupRegFieldsToAdd'].join(',');
				}
				if(templateField['columnsInTypeahead']){
					fieldAttributes['columnsintypeahead'] = templateField['columnsInTypeahead'].join(',');
				}
			}

			// Now build the array of attributes to add to this field
			if(templateField['fieldName']){
				fieldAttributes['formName'] = templateField['fieldName'];
			}

			if(templateField['fieldGroupId']){
				fieldAttributes['fieldgroupid'] = templateField['fieldGroupId'];
			}
			if(templateField['autoPopulateField_days']){
				fieldAttributes['autopopulatefield_days'] = templateField['autoPopulateField_days'];
			}
			if(templateField['autoPopulateField_beforeOrAfter']){
				fieldAttributes['autopopulatefield_beforeorafter'] = templateField['autoPopulateField_beforeOrAfter'];
			}
			if(templateField['multipleValues']){
				fieldAttributes['multiplevalues'] = templateField['multipleValues'];
				fieldAttributes['multipleValues_minValues'] = templateField['multipleValues_minValues'];
				fieldAttributes['multipleValues_maxValues'] = templateField['multipleValues_maxValues'];
			}

			// Now we know the classes and attributes of this field - apply them
			fieldElement.addClass(fieldClasses.join(" "));
			$.each(fieldAttributes,function(attributeName,attributeValue){
				fieldElement.attr(attributeName,attributeValue);
			});

			// Need to add a label to the fieldElement
			if(!templateField['hideLabel']){
				labelElement = $('<label></label>');
				asterisk = "";
				if(templateField['required']){
					asterisk = "*";
				}
				labelElement.text(templateField['fieldName'] + asterisk);
				labelElement.addClass(fieldLabelClasses.join(" "));
				fieldElement.append(labelElement);
			}

			templateElement.append(fieldElement);
		});
		//console.log(templateElement);
		//console.log(templateElement.html());
		dataMiddle = templateElement.html();
	}
	else{
		dataMiddle = "Page load error.";
		swal({
			title: "Page load error",
			text: null,
			type: "error",
			showCancelButton: false,
			showConfirmButton: false,
			timer: 1300
		})
	}
	return dataMiddle;
}

currentFD = false;
/**
 * 
 * @param {JSON} fd The form definition
 * @param {string} containerId The container to add the form too
 * @param {*} lf 
 * @param {bool} floatIt CSS float the div to the top left
 * @param {function} cb callback to be called after form is added to the dom
 * @param {JSON} autoFillValues Values to get applied after form is addded to the page
 */
function makeForm(fd,containerId,lf,floatIt,cb, autoFillValues = false){
	var item;
	currentFD = fd;
	window.itemJSON = fd;
	// INV-162
	if(fd.view){
		$('#'+containerId).attr('latestaction',"view");
	}
	else if(typeof fd.action !== "undefined" && fd.action == "add"){
		$('#'+containerId).attr('latestaction',"add");
	}
	//try{
	//alert(fd.id+' '+fd.fields[fd.fieldNames.indexOf("Name")].value)}catch(err){}
	if(containerId!="arxOneContainer"||floatIt){
		noHistory = true;
	}
	floatCss = false;
	if(floatIt || (fd.fields[fd.fieldNames.indexOf("_invType")].value=="well" && lf==undefined)){
		floatCss = true;
	}
	if(fd.fields[fd.fieldNames.indexOf("_invType")].value=="well"){
		clearContainer("wellView");
	}
	cals = [];
	fd.getFieldByFormName = function(fn){
		if(fd.fieldNames.indexOf(fn)!=-1){
			return fd.fields[fd.fieldNames.indexOf(fn)];
		}else{
			return null;
		}
	}
	fd.getFieldBySpecialType = function(specialType){ // Modeled after the backend's getFieldBySpecialType
        lookForTrue = ""
        if(specialType == "name"){
            lookForTrue = "isNameField";
        }
        else if(specialType == "barcode"){
            lookForTrue = "isBarcodeField";
        }
        else if(specialType == "amount"){
            lookForTrue = "isAmountField";
        }
        else if(specialType == "units"){
            lookForTrue = "isAmountUnitField";
        }
        if(lookForTrue !== ""){
        	// We need to look through all the fields and see if the lookForTrue property is true
        	var returnField = false;
        	$.each(fd.fields,function(index, field){
        		if(field[lookForTrue] == true){
        			returnField = field;
        			return false;
        		}
        	});
        	return returnField;
        }
    }
    formDiv = document.createElement("div");
	formDiv.setAttribute("class","invPopupDiv invPopupDivResults sideBySide "+fd.fields[fd.fieldNames.indexOf("_invType")].value);
	if (floatCss){
		formDiv.style.float = "left";
		formDiv.style.verticalAlign = "top";
		//formDiv.style.width = "220px";
		//formDiv.style.height = "500px";
	}
	form = document.createElement("form");
	form.setAttribute("id",fd.fid);
	form.setAttribute("name",fd.fid);

	if(fd.parent&&fd.view&&(showParentLinks||fd.showParentLink)){
		a = document.createElement("a");
		a.href = "javascript:void(0)";
		a.innerHTML = "Parent";
		a.setAttribute("formName","parentLink");
		a.onclick = (function(fd){
			return function(){
				if(fd.tableLinkName=='lotNumber'){
					handleLink(fd.parent.id,'reagent',false,fd.parentTree);
				}
				if(fd.tableLinkName=='equipment'){
					handleLink(fd.parent.id,'lot',false,fd.parentTree);
				}
			}
		})(fd);
		form.appendChild(a);
	}
	if (fd.header!=""){
		h1 = document.createElement("h1");
		span = document.createElement("span");
		span.innerHTML = fd.header;
		span.setAttribute("formName","objectType");
		h1.appendChild(span);
		form.appendChild(h1)
	}
	fields = fd["fields"];
	widgets = []
	for(var i=0;i<fields.length;i++ ){
		thisField = fields[i];
		fieldId = thisField["id"];

		r = makeField(fd,thisField,fieldId,containerId);
		//console.log(r);
		if(r["label"]){
			form.appendChild(r["label"]);
		}
		if(r["el"]){
			form.appendChild(r["el"]);
		}
		if(r["errorEl"]){
			form.appendChild(r["errorEl"]);
		}
		if(r.hasOwnProperty("widget")){
			widgets.push(r["widget"])
		}
		thisField.updateValue = function(){
			r = restCall("/getFieldValue/","POST",thisField);
			this.value = r["value"];
			this.options = r["options"];
		}

	}
	//INV-316 Adding printer name and printer list drop down if action=view and if the labelsetup exists
	if (fd["view"] && fd.hasOwnProperty('labelPrintingSettings') ){
		if(fd["labelPrintingSettings"].hasOwnProperty('labelLayoutId')){
			if(fd["labelPrintingSettings"]["labelLayoutId"] != "" && fd["labelPrintingSettings"]["labelLayoutId"] != undefined){
				printerName = getFile('getPrinterDetails.asp?userPrinter=true&random='+Math.random());
				console.log("PRINTER NAME ::::::", printerName);
				if (printerName == ""){
					printerName = "None";
				}
				//Add the user default printer to the itemJSON fd
				window.itemJSON.printerName = printerName;
				
				printerList = getFile('getPrinterDetails.asp?printerList=true&random='+Math.random());
				pList = printerList.split(",");
				console.log("PRINTER LIST ::::::", pList +", "+ pList.length);
				if(pList.length == 1){
					//Only 1 printer exists for the comany - use it for printing even though user has not set default printer
					window.itemJSON.printerName = pList[0];
				}
				if(pList.length > 1){
					r = showPrinterNameText(printerName)
					form.appendChild(r);
					r1 = createPrinterListSelect(pList, printerName);
					form.appendChild(r1);
				}
			}
		
		}
	}
	if (!fd["view"]){
		theButton = document.createElement("input");
		theButton.setAttribute("type","button");
		theButton.setAttribute("id",fd.fid+"_submit");
		theButton.setAttribute("name",fd.fid+"_submit");
		theButton.setAttribute("value",fd["submitButtonText"])
		theButton.setAttribute("formName","Submit")
		theButton.onmouseover = function(){this.focus();}
		theButton.onclick = fd.onSave;
		form.appendChild(theButton);
	}else{
		//if(canEdit){
		//	theButton = document.createElement("input");
		//	theButton.setAttribute("type","button");
		//	theButton.setAttribute("id",fd.fid+"_submit");
		//	theButton.setAttribute("name",fd.fid+"_submit");
		//	theButton.setAttribute("value","EDIT")
		//	theButton.onclick = function(){
		//		window.location = 'aev.asp?c='+qs()["c"]+"&id="+qs()["id"];	
		//	};
		//	form.appendChild(theButton);
		//}
	}
	//if(fd.showDelete && canEdit){
	//	theButton = document.createElement("input");
	//	theButton.setAttribute("type","button");
	//	theButton.setAttribute("id",fd.fid+"_delete");
	//	theButton.setAttribute("name",fd.fid+"_delete");
	//	theButton.setAttribute("value","Delete");
	//	theButton.onclick = function(){
	//		document.getElementById(fd.fid+"_edit_tr").style.display = "none";
	//		document.getElementById(fd.fid+"_show_tr").style.display = "none";
	//		deleteForm(fd);
	//	}
	//	form.appendChild(theButton);
	//}
	if(fd.template){
//		alert(fd.template);
		if(fd.template=="custom"){
			$.get("templates/custom_start.html?r="+Math.random())
				.done(function(dataStart){
					var getObjectTemplate = restCall("/getObjectTemplate/","POST",{"name":fd.dataType})
					if(getObjectTemplate['result'] == "success"){
						dataMiddle = makeObjectTemplateHTML(getObjectTemplate);
					}
					
					$.get("templates/custom_end.html?r="+Math.random())
						.done(function(dataEnd){
							templateHTML = dataStart+dataMiddle+dataEnd; 
							applyTemplate(templateHTML,fd,containerId,cb);
							for(var i=0;i<widgets.length;i++){
								widgets[i].drawHTML();
							}
							if (autoFillValues) {
								autoPopulateValues(fd, autoFillValues);
							}
						});				
				});
		}else{
			$.get("templates/"+fd.template+"?r="+Math.random())
				.done(function(data){
					applyTemplate(data,fd,containerId,cb);
					if (autoFillValues) {
						autoPopulateValues(fd, autoFillValues);
					}
				});
		}
	}else{
		formDiv.appendChild(form);
		document.getElementById(containerId).appendChild(formDiv);
		for(var i=0;i<cals.length;i++){
			cals[i]();
		}
		for(var i=0;i<widgets.length;i++){
			widgets[i].drawHTML();
		}
	}
	if(hasAuditTrail && fd.auditTrail){
		table = document.createElement("table");
		table.setAttribute("formName","auditTrail");
		table.className = "experimentsTable";
		tBody = document.createElement("tbody");
		table.appendChild(tBody);
		tr = document.createElement("tr");
		tr.className = "auditTrailHeaderRow";
		th = document.createElement("th");
		th.className = "auditTrailRevisionNumberHeader";
		tr.appendChild(th);
		th = document.createElement("th");
		th.className = "auditTrailDateHeader";
		th.appendChild(document.createTextNode("Date"));
		tr.appendChild(th);
		th = document.createElement("th");
		th.className = "auditTrailUserHeader";
		th.appendChild(document.createTextNode("User"));
		tr.appendChild(th);
		th = document.createElement("th");
		th.className = "auditTrailActionHeader";
		th.appendChild(document.createTextNode("Action"));
		tr.appendChild(th);
		th = document.createElement("th");
		th.className = "auditTrailAmountHeader";
		th.appendChild(document.createTextNode("Amount"));
		tr.appendChild(th);
		th = document.createElement("th");
		th.className = "auditTrailLocationHeader";
		th.appendChild(document.createTextNode("Location"));
		tr.appendChild(th);
		th = document.createElement("th");
		th.className = "auditTrailSourceHeader";
		th.appendChild(document.createTextNode("Source"));
		tr.appendChild(th);
		th = document.createElement("th");
		th.className = "auditTrailDestinationHeader";
		th.appendChild(document.createTextNode("Destination"));
		tr.appendChild(th);
		tBody.appendChild(tr);
		for(var i=0;i<fd.auditTrail.length;i++){
			item = fd["auditTrail"][i];
			if(!item.hasOwnProperty("amount")){
				item["amount"] = "";
			}
			tr = document.createElement("tr");
			tr.className = "auditTrailRow";
			if(item["revisionNumber"]==fd.revisionNumber){
				tr.className += " highlight";
			}
			td = document.createElement("td");
			td.className = "auditTrailRevisionNumberCell";
			td.appendChild(document.createTextNode(item["revisionNumber"]));
			tr.appendChild(td);
			td = document.createElement("td");
			td.className = "auditTrailDateCell";
			td.appendChild(buildStaticLinks(item["date"]));
			tr.appendChild(td);
			td = document.createElement("td");
			td.className = "auditTrailUserCell";
			td.appendChild(document.createTextNode(item["user"]));
			tr.appendChild(td);
			td = document.createElement("td");
			td.className = "auditTrailActionCell";
			td.appendChild(document.createTextNode(item["action"]));
			tr.appendChild(td);
			td = document.createElement("td");
			td.className = "auditTrailAmountdeader";
			td.appendChild(document.createTextNode(item["amount"]));
			tr.appendChild(td);
			td = document.createElement("td");
			td.className = "auditTrailLocationCell";
			td.appendChild(buildStaticLinks(item["location"]));
			tr.appendChild(td);
			td = document.createElement("td");
			td.className = "auditTrailSourceCell";
			td.appendChild(buildStaticLinks(item["source"]));
			tr.appendChild(td);
			td = document.createElement("td");
			td.className = "auditTrailDestinationCell";
			td.appendChild(buildStaticLinks(item["destination"]));
			tr.appendChild(td);
			tBody.appendChild(tr);
		}
		form.appendChild(table);
	}
	div = document.createElement("div");
	div.setAttribute("formName","versionDiv");
	if(!fd.hideAuditTrail){
		if (fd.currentVersion){
			div.appendChild(document.createTextNode("Current Version"));
		}else{
			if(fd.revisionNumber){
				div.appendChild(document.createTextNode("Revision: "+fd.revisionNumber));
			}
			else{
				div.appendChild(document.createTextNode("Add New"));
			}
		}
	}
	form.appendChild(div);
	document.getElementById(containerId).appendChild(formDiv);
	if (fd.fields[fd.fieldNames.indexOf("_invType")].value=="well" && lf==undefined){
		compoundId = fd.fields[fd.fieldNames.indexOf("Compounds")].value[0].compound_id;
		pl = {"action":"view","collection":"compound","id":compoundId};
		addObjectForm = restCall("/getForm/","POST",pl);
		makeForm(addObjectForm,containerId,undefined,true, undefined, autoFillValues);
	}
}


function editTableTDs(fd,field,tr,inFrame){
	td = document.createElement("td");
	if(globalUserInfo["dsBottles"]){
		td.setAttribute("align","center");
	}
	if(field.fieldType!="showChildLinks"&&field.fieldType!="childLinks2"&&field.fieldType!="chem"){
		span = document.createElement("span");
		span.setAttribute("id",field.id+"_table_span")
		//truncate
		theText = field.value;
		if(theText==null){
			theText = "";
		}
		if (theText.length > 40){
			theText = theText.substring(0,39)+"...";
		}
		span.innerHTML = theText;
		if(field.formName==fd.tableLinkName&&!inFrame){
			if(field.value==""){
				span.innerHTML = "Untitled";
			}
			a = document.createElement("a");
			a.setAttribute("id",field.id+"_table_link")
			if(!inFrame){
				if(dontRefreshTableLink){
					a.href = "javascript:void(0);";
					a.onclick = (function(fd){
						return function(){
							showTable = false;
							if(fd.fields[fd.fieldNames.indexOf("_numChildren")].value>0){
								showTable = true;
							}
							if(companyId==17){
								showTable = false;
							}
							handleLink(fd.id,fd.fields[fd.fieldNames.indexOf("_invType")].value,showTable,fd.parentTree)
						}
					})(fd);
				}else{
					a.href = "aev.asp?c="+fd.collection+"&view=true&id="+fd.id;
				}
			}else{
				a.href = "javascript:void(0);";
				a.onclick = (function(theField,theId){
					return function(){
						window.parent.processNewLink(theField,theId);
					}
				})(field,fd.id);
			}

			a.appendChild(span);
			td.appendChild(a);
		}else{
			td.appendChild(span);
		}
		thisRow.push(theText);
	}
	if(field.fieldType=="showChildLinks"){
		el = createShowChildLinks(fd,field,field.id,field.id)
		td.appendChild(el);
	}
	if(field.fieldType=="childLinks2"){
		el = buildInnerLinks(fd,field,field.id,true)
		td.appendChild(el);
	}
	if(field.fieldType=="chem"){
		el = createTableChemBox(fd,field,field.id+"_tn",field.id+"_tn")
		td.appendChild(el);
	}
	return td;
}

var downloadCSV = [];
var thisRow = [];
function makeEditTable(fds,containerId,fixedFields,inFrame){
	console.log("makeEditTable #########", containerId);
	console.log("makeEditTable #########", fixedFields);
	console.log("makeEditTable #########", inFrame);
	downloadCSV = [];
	if (fixedFields){
		newFixedFields = [];
		for(var i=0;i<fixedFields.length;i++){
			if(fixedFields[i]!="Structure"){
				newFixedFields.push(fixedFields[i]);
			}
		}
		downloadCSV.push(newFixedFields);
	}
	tableFds = fds;
	tableFixedFields = fixedFields;
	numCols = 0;
	table = document.createElement("table");
	if(containerId=="arxOneContainer"){
		table.setAttribute("id","listTable")
	}else{
		table.setAttribute("id","listTable"+containerId)
	}
	table.className = "experimentsTable"
	tBody = document.createElement("tBody");
	table.appendChild(tBody);
	if(fds.length>0){
		if(!inFrame){
			tr = document.createElement("tr");
			td = document.createElement("td");
			td.setAttribute("align","right");
			colLen = fixedFields.length+1;
			if(inFrame){
				colLen += 1;
			}
			td.setAttribute("colspan",colLen);
			td.style.backgroundColor = "#EEE";
			tr.style.border = "none";
			a = document.createElement("a");
			a.setAttribute("href","#");
			a.innerHTML = "Export Results";
			//412015
			//deleted setidtoo
			theExportLink = a;
			///412015
			td.appendChild(a);
			tr.appendChild(td);
			tBody.appendChild(tr)
		}
		if(inFrame && containerId!="arxOneContainer"){
			tr = document.createElement("tr");
			td = document.createElement("td");
			td.setAttribute("align","right");
			td.setAttribute("colspan",fixedFields.length+2);
			td.style.backgroundColor = "#EEE";
			tr.style.border = "none";
			a = document.createElement("a");
			a.setAttribute("href","javascript:void(0)");
			//change for reagent swap
			if(window.parent.invAddType!="bottom"){
				a.setAttribute("id","useEquivalentsLink");
				a.onclick = function(){
					useEquivalents = true;
					this.style.display = "none";
					document.getElementById("useAmountLink").style.display = "block";
					document.getElementById("addItemHeader").innerHTML = "Equivalents";
				}
				a.innerHTML = "Use Equivalents";
				td.appendChild(a);
			}
			a = document.createElement("a");
			a.setAttribute("href","javascript:void(0)");
			a.setAttribute("id","useAmountLink");
			a.style.display = "none";
			a.onclick = function(){
				useEquivalents = false;
				this.style.display = "none";
				document.getElementById("useEquivalentsLink").style.display = "block";
				document.getElementById("addItemHeader").innerHTML = "Amount To Use";
			}
			a.innerHTML = "Use Amounts";
			td.appendChild(a);
			tr.appendChild(td);
			tBody.appendChild(tr)
		}
		tr = document.createElement("tr");
		th = document.createElement("th");
		tr.appendChild(th);
		if(fixedFields){
			for(var i=0;i<fixedFields.length;i++){
				th = document.createElement("th");
				th.innerHTML = fixedFields[i].replace(" (g/mL)","");
				tr.appendChild(th);
				numCols +=1
			}
		}else{
			for(var i=0;i<fds[0].fields.length;i++){
				field = fds[0].fields[i];
				if(field.inTable){
					th = document.createElement("th");
					th.innerHTML = field.formName;
					tr.appendChild(th);
					numCols +=1
				}
			}
		}
		if (inFrame){
			th = document.createElement("th");
			if (containerId=="arxOneContainer"){
				th.innerHTML = "Select";
			}else{
				th.innerHTML = "Amount To Use";
				th.setAttribute("id","addItemHeader");
			}
			tr.appendChild(th);
			numCols += 1;
		}
		tBody.appendChild(tr);
		cursorIdPing = fds[0].cursorData.cursorId;
	}
	for (var i=0;i<fds.length;i++)
	{
		thisRow = [];
		fd = fds[i];
		fields = fd.fields;
		tr = document.createElement("tr");
		tr.setAttribute("id",fd.fid+"_show_tr");
		td = document.createElement("td");
		img = document.createElement("img");
		img.setAttribute("id",fd.fid+"_expand_img")
		img.src = "images/plus.gif";
		img.onclick = function(fd){
			return function(){
				editTR = document.getElementById(fd.fid+"_edit_tr");
				if(editTR.style.display=="none"){
					if(altCollectionName){
						collectionName = fd.fields[fd.fieldNames.indexOf(altCollectionName)].value;
					}else{
						collectionName = fd.collection;
					}
					restCallA("/getForm/","POST",{'id':fd.id,'action':'view','collection':collectionName},function(editObjectForm){
						formBucket.push(editObjectForm);
						editObjectForm.onSave = function(editObjectForm){
							return function(){
								if(validateForm(editObjectForm)){
									saveForm(editObjectForm,false);
									editTR = document.getElementById(fd.fid+"_edit_tr");
									editTR.style.display = "none";
									document.getElementById(fd.fid+"_expand_img").src = "images/plus.gif"
									updateTableValues(fd);
								}
							}
						}(editObjectForm);
						//editObjectForm.showDelete = true;
						makeForm(editObjectForm,fd.fid+"_edit_td");
						//document.getElementById(fd.fid+"_edit_loaded").value=1;
					})
				}
				if(editTR.style.display=="none"){
					try{
						editTR.style.display = "table-row";
					}catch(err){editTR.style.display = "block";}
					this.src = "images/minus.gif"
				}else{
					editTR.style.display = "none";
					clearContainer(fd.fid+"_edit_td");
					this.src = "images/plus.gif"
				}
			}
		}(fd);
		if(!inFrame){
			td.appendChild(img);
		}
		h = document.createElement("input");
		h.setAttribute("type","hidden");
		h.setAttribute("id",fd.fid+"_edit_loaded");
		h.value = 0;
		td.appendChild(h);
		tr.appendChild(td);
		if(fixedFields){
			for(var j=0;j<fixedFields.length;j++){
				fieldName = fixedFields[j];
				if(fd.fieldNames.indexOf(fieldName)==-1){
					tr.appendChild(document.createElement("td"));
					thisRow.push("");
				}else{
					tr.appendChild(editTableTDs(fd,fields[fd.fieldNames.indexOf(fieldName)],tr,inFrame))
				}
			}
			downloadCSV.push(thisRow)
		}else{
			for(var j=0;j<fields.length;j++){
				if(fields[j].inTable){
					tr.appendChild(editTableTDs(fd,fields[j],tr))
				}
			}
		}
		if (inFrame){
			td = document.createElement("td");
			td.setAttribute("align","center");
			if (containerId=="arxOneContainer"){
				cb = document.createElement("a");
				cb.innerHTML = "Select"
				cb.href = "javascript:void(0)";
				cb.setAttribute("id",fd.id);
				cb.onclick = (function(fd){
					return function(){
						selectedItemIds = [];
						selectedItemIds.push(fd.id);
						if(selectedItemIds.length>0){
							document.getElementById("noSelectedItemsP").style.display = "none";
						}else{
							document.getElementById("noSelectedItemsP").style.display = "block";
						}
						foundUnit = false;
						if(fd.fieldNames.indexOf("Unit Type")!=-1){
							unitName = "Unit Type";
							foundUnit = true;
						}
						if(fd.fieldNames.indexOf("Units")!=-1){
							unitName = "Units";
							foundUnit = true;
						}
						if(!foundUnit){
							alert("To add an inventory item to the ELN, the item must have an amount field and a units field.")
						}
						getList(false,false,{"id":{"$in":selectedItemIds}},["Structure","Amount",unitName,"Purity","Density (g/mL)"],"selectedItemsDiv",10,function(){window.scroll(0,0);})
					}
				})(fd)
				td.appendChild(cb);
			}else{
				tb = document.createElement("input");
				tb.setAttribute("type","text");
				tb.setAttribute("id",fd.id+"_amountToUse")
				tb.style.width = "50px";
				
				// Make read-only if the user already put something in the grid amount
				if(inFrame)
				{
					if(window.parent.inventoryExistingVolumeToUseFromGrid != undefined && window.parent.inventoryExistingVolumeToUseFromGrid.length > 0)
					{
						// use volume if it's there
						tb.value = window.parent.inventoryExistingVolumeToUseFromGrid;
						tb.readOnly = true;
					}
					else if(window.parent.inventoryExistingMassToUseFromGrid != undefined && window.parent.inventoryExistingMassToUseFromGrid.length > 0)
					{
						// otherwise use mass
						tb.value = window.parent.inventoryExistingMassToUseFromGrid;
						tb.readOnly = true;
					}
				}
				
				td.appendChild(tb);
			}
			tr.appendChild(td);
			numCols += 1;
		}
		tBody.appendChild(tr);
		tr = document.createElement("tr");
		tr.setAttribute("id",fd.fid+"_edit_tr");
		td = document.createElement("td");
		td.setAttribute("id",fd.fid+"_edit_td");
		td.setAttribute("colspan",numCols+1);
		td.colSpan = numCols + 1;
		tr.style.display = "none";
		tr.appendChild(td);
		tBody.appendChild(tr);
	}
	tr = document.createElement("tr");
	td = document.createElement("td");
	td.setAttribute("colspan",numCols+1);
	td.colSpan = numCols+1;
	td.setAttribute("align","right");
	if (fds.length){
		span = document.createElement("span");
		span.innerHTML = "page "+fd.cursorData.page+" of "+fd.cursorData.pages+", total results: "+fd.cursorData.count;
		td.appendChild(span);
		if(fd.cursorData.hasFirst){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = (function(fd){
				return function(){
					getList(fd.cursorData.cursorId,"first",false,fixedFields);
				}
			})(fd);
			img = document.createElement("img");
			img.src = "images/resultset_first.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		if(fd.cursorData.hasPrev){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = (function(fd){
				return function(){
					getList(fd.cursorData.cursorId,"prev",false,fixedFields);
				}
			})(fd);
			img = document.createElement("img");
			img.src = "images/resultset_prev.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		if(fd.cursorData.hasNext){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = (function(fd){
				return function(){
					getList(fd.cursorData.cursorId,"next",false,fixedFields);
				}
			})(fd);
			img = document.createElement("img");
			img.src = "images/resultset_next.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		if(fd.cursorData.hasLast){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = (function(fd){
				return function(){
					getList(fd.cursorData.cursorId,"last",false,fixedFields);
				}
			})(fd);
			img = document.createElement("img");
			img.src = "images/resultset_last.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
	}else{
		span = document.createElement("span");
		span.innerHTML = "Search returned no results";
		td.appendChild(span);
	}
	tr.appendChild(td);
	tBody.appendChild(tr);
	try{
		if(containerId=="arxOneContainer"){
			el=document.getElementById('listTable');
			if(el){
				el.parentNode.removeChild(el);
			}
			else{// INV - 257 When the page gets navigated from index.asp then we have to check for different html elements to replace
				pathArrList = (window.location.pathname).split("/");
				for(var i = 0; i < pathArrList.length; i++){
					if (pathArrList[i] == "objectTemplates"){
						el=document.getElementById('inventoryObjectManagementPage')
						el.parentNode.removeChild(el);
					}
					else if(pathArrList[i] == "mappingTemplates"){
						el=document.getElementById('mappingTemplatesManagementPage')
						el.parentNode.removeChild(el);
					}
				}
			}
		}else{
			el=document.getElementById('listTable'+containerId);
			el.parentNode.removeChild(el);
		}
	} catch (err) { }
	if (document.getElementById(containerId) != null) {
		document.getElementById(containerId).appendChild(table);
	}
	var finalVal = '';

	for (var i = 0; i < downloadCSV.length; i++) {
		var value = downloadCSV[i];
		for (var j = 0; j < value.length; j++) {
			var innerValue =  value[j]===null?'':value[j].toString();
			var result = innerValue.replace(/"/g, '""');
			if (result.search(/("|,|\n)/g) >= 0)
				result = '"' + result + '"';
			if (j > 0)
				finalVal += ',';
			finalVal += result;
		}

		finalVal += '\n';
	}
	//412015
	try{
		if(containerId=='hiddenContainer'){
			download = theExportLink;
			download.setAttribute("id","exportLink");
			download.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(finalVal));
			download.setAttribute('download', 'report.csv');
		}else{
			download = theExportLink;
			download.setAttribute('href', 'javascript:void(0)');
			download.onclick = fds[0].exportAllFunction;
		}
	}catch(err){}
	///412015
}

$(document).on('ready',function(){
	$('body').on('change','select.ax1-select',function(){
		if(typeof window.finalChangeBeforeSave == "undefined" || !window.finalChangeBeforeSave){
			if($(this).parent().hasClass('addTextOnOther')){
				if($(this).val().toLowerCase() == "other"){
					textboxHTML = '<input type="text" class="dropdownOtherTextbox" dropdownid="' + $(this).attr('id') + '" style="display: inline-block;font-size: 12px;min-width: 180px;padding: 4px;margin-left: 9px;">'
					$(this).parent().append(textboxHTML);
				}
				else{
					$(this).parent().find('input.dropdownOtherTextbox[type="text"][dropdownid="' + $(this).attr('id') + '"]').remove();
				}
			}
			// INV-162
			var fieldName = $(this).attr('formname').split(' ').join('_');
			var formName = $(this).attr('formname');
			// 10122: supports multiple selected options
			var fieldOptionIds = []
			if (this.multiple) {
				// multiple-value dropdown
				Array.prototype.push.apply(fieldOptionIds, $(this).val());
			} else {
				// single value dropdown
				var selectedOptionId = $(this).find('option:selected').attr('fieldoptionid');
				fieldOptionIds.push(selectedOptionId);
			}
			if (fieldOptionIds.length == 0) {
				// We could be in here if nothing is selected from a multiple dropdown. Let's push undefined to indicate that and hide the conditional fields.
				fieldOptionIds.push(undefined);
            }
			var bShown = false;
			for (i = 0; i < fieldOptionIds.length; i++)
			{
				var fieldOptionId = fieldOptionIds[i];
				var changedDropdown = $(this);
				if (typeof window.itemJSON !== "undefined") {
					$.each(window.itemJSON['fields'], function () {
						if (formName == this['formName']) {
							var notString = "";
							if (typeof fieldOptionId !== "undefined" && fieldOptionId !== "" && typeof this['conditionalFieldsAndOptions'][fieldOptionId] !== "undefined") {
								// Build up a string for the :not of our query selectors below
								// 9460: For some reason, using exact search by name (ex .conditionalInvTemplateField[class="showConditional_' + fieldName + '"]) does not always work
								// but using LIKE works (ex .conditionalInvTemplateField[class*="showConditional_' + fieldName + '"])). But the later might return the current form if the 
								// name of the current form is part of the fieldName. That would result in an infinite loop. To work around this, exclude the current form in the selector.
								notString = '[formname="' + formName + '"],';	
								$.each(this['conditionalFieldsAndOptions'][fieldOptionId]['fieldNames'], function (key, val) {
									notString += '[formname="' + val + '"],'
								});
								notString = notString.substring(0, notString.length - 1); // Remove trailing comma
								// Go through the conditional form rows that are currently shown because of the dropdown that just changed BUT are ":not" one of the fields we're about to un-hide... Then reset their values as we hide them
								$('.conditionalInvTemplateField[class*="showConditional_' + fieldName + '"]:not(' + notString + ')').each(function () {
									// Hide and reset it to the default blank value
									if (!bShown) {
										$(this).removeClass('showConditional_' + fieldName).find('select').prop('selectedIndex', 0).change().find('option').not(':first-of-type').prop('disabled', true);
										$(this).removeClass('showConditional_' + fieldName).find('input[type="text"]').val('').change();
									}
								});
								// Show the dropdowns triggered
								$.each(this['conditionalFieldsAndOptions'][fieldOptionId]['fieldNames'], function (key, val) {
									// This option triggers the conditional field to be shown
									bShown = true;
									$('.conditionalInvTemplateField[formName="' + val + '"]').css("display", "block");
									$('.conditionalInvTemplateField[formname="' + val + '"]').addClass('showConditional_' + fieldName); // Will eventually make this "showConditional_[fieldName]_[fieldOptionId]" in order to better track which dropdowns & which options actually activated the dropdown
								});
								// Enable their options according to the JSON
								$.each(this['conditionalFieldsAndOptions'][fieldOptionId]['fieldOptions'], function (key, val) {
									$('.conditionalInvTemplateField.showConditional_' + fieldName).find('select > option[fieldoptionid="' + val + '"]').prop('disabled', false);
								});
							}
							else {
								//Inv-276 - hide conditional dropdown
								$('.conditionalInvTemplateField[formName="' + fieldName + '"]').css("display", "none");
								// Simply remove everything that was triggered by this fieldName, plus anything those things triggered
								// 9460: For some reason, using exact search by name (ex .conditionalInvTemplateField[class="showConditional_' + fieldName + '"]) does not always work
								// but using LIKE works (ex .conditionalInvTemplateField[class*="showConditional_' + fieldName + '"])). But the later might return the current form if the 
								// name of the current form is part of the fieldName. That would result in an infinite loop. To work around this, exclude the current form in the selector.
								notString = '[formname="' + formName + '"]';	// exclude this current form itself
								$('.conditionalInvTemplateField[class*="showConditional_' + fieldName + '"]:not(' + notString + ')').each(function () {
									// Hide and reset it to the default blank value
									$(this).removeClass('showConditional_' + fieldName).find('select').prop('selectedIndex', 0).change().find('option').not(':first-of-type').prop('disabled', true);
									$(this).removeClass('showConditional_' + fieldName).find('input[type="text"]').val('').change();
								});
							}
							return false;
						}
					});
				}
			}
		}
	});
	$('body').on('click','.ax1-text .lookupFieldsToggleButton',function(event){
		var formNameToMatch = $(this).parent().attr('formname')
		var currentFieldState = "visible";
		if($(this).hasClass('relatedFieldsHidden')){
			currentFieldState = "hidden";
			$(this).removeClass('relatedFieldsHidden');
			$(this).text('Hide Related Fields');
		}
		else{
			$(this).addClass('relatedFieldsHidden');
			$(this).text('Show Related Fields');
		}
		$('[originformname="'+formNameToMatch+'"]').each(function(){
			if(currentFieldState == "visible"){
				$(this).addClass('hideInvTemplateField')
			}
			else{
				$(this).removeClass('hideInvTemplateField')
			}
		});
	});

	// Used when there are multi-value fields in a field group
	$('body').on('click','.groupedMultiValueFieldsButtons .removeValuesButton',function(event){
		var thisNthOfType = $(this).prevAll('.removeValuesButton').length + 1;
		$(this).parent().parent().find('[multiplevalues="True"] .multipleValuesField_valueContainer:nth-of-type('+thisNthOfType+') .multipleValuesField_removeValueButton').click();
		if($(this).parent().find('.removeValuesButton').length > 1){
			$(this).remove();
		}
	});
	$('body').on('click','.groupedMultiValueFieldsButtons .newValuesButton',function(event){
		//console.log($(this).parent().parent().find('[multiplevalues="True"] .multipleValuesField_valueContainer:last-of-type .multipleValuesField_newValueButton'));
		$(this).parent().parent().find('[multiplevalues="True"] .multipleValuesField_valueContainer:last-of-type .multipleValuesField_newValueButton').click();
		$(this).parent().prepend('<button class="removeValuesButton">- Remove Row</button>')
	});


	// Used in Inventory's Bulk Import & Bulk Update
	$('body').on('click','.saveAsNewMappingTemplateButton',function(event){
		blackOn();
		popup = newPopup("saveAsMappingTemplatePopup");
		$(popup).append('<div class="popupFormHeader">Save as New Mapping Template</div><div class="sampleMapTemplateNameTextboxContainer"><input type="text" class="sampleMapTemplateNameTextbox" placeholder="Mapping template name"></div><input type="checkbox" name="mappingTemplate_isPublic" id="mappingTemplate_isPublic" class="css-checkbox"><label for="mappingTemplate_isPublic" class="css-label checkboxLabel mappingTemplate_isPublic_label">Make Public</label><button class="saveMappingTemplateButton">Save Mapping Template</button>').appendTo('body')
	});

	$('body').on('click','#saveAsMappingTemplatePopup .saveMappingTemplateButton',function(event){
		var mappingTemplateName = $('.sampleMapTemplateNameTextbox').val();
		var sourceType = window.latestImportOptions['sdFields'].join(','); // This sets sourceType to a comma-separated list of spreadsheet column names rather than an object type
		var destinationType = $('div[formname="Object Type"] select').val();
		var fieldMap = makeFieldNamePairsFromOldFieldMappingTable('fieldMappingTable');
		var isPublic = $('#mappingTemplate_isPublic').prop('checked');
		
		r = restCall("/saveMappingTemplate/","POST",{"mappingTemplateName": mappingTemplateName, "sourceType": sourceType, "destinationType": destinationType, "fieldMap": fieldMap, "isPublic": isPublic, "category": "bulkImport_bulkUpdate"})
		if(r["result"] == "success"){
			//console.log(r)
			$('#saveAsMappingTemplatePopup').remove();
			blackOff();
		}
		else if(r["result"] == "failure"){
			alert("There was an issue saving your mapping template.")
		}
	});

	$('body').on('click','.multipleValuesField_newValueButton',function(event){
		var maxValues = parseInt($(this).parent().parent().attr('multiplevalues_maxvalues'));
		if($(this).parent().parent().find('.multipleValuesField_valueContainer').length < maxValues || isNaN(maxValues)){
			$(this).parent().after('<div class="multipleValuesField_valueContainer"><input type="text" placeholder="value"><button class="multipleValuesField_removeValueButton">- Remove</button><button class="multipleValuesField_newValueButton" type="button">+ New Value</button></div>');
			//console.log($(this).parent().parent().find('.multipleValuesField_valueContainer:last-of-type input[type="text"]'));
			$(this).parent().parent().find('.multipleValuesField_valueContainer:last-of-type input[type="text"]').focus();
		}
		else{
			swal("", "You've reached the maximum number of values for this field.", "warning");
		}
	});

	$('body').on('click','.multipleValuesField_removeValueButton',function(event){
		var minValues = parseInt($(this).parent().parent().attr('multiplevalues_minvalues'));
		if(isNaN(minValues)){
			minValues = 1;
		}
		if($(this).parent().parent().find('.multipleValuesField_valueContainer').length-1 >= minValues){
			$(this).parent().remove();
		}
		else{
			swal("", "This field requires a minimum of "+minValues+" values.", "warning");
		}
	});

	$('body').on('change','.bulkImport_bulkUpdateMapTemplatesDropdown',function(event){
		if($(this).val() !== "custom"){
			loadFieldMapIntoOldFieldMappingTable('fieldMappingTable',parseInt($(this).val()))
		}
	});
});
