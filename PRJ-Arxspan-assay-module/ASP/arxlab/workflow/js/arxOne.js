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
				r = JSON.parse(client.responseText);
				if(r.hasOwnProperty("jsError")){
					alert(r["jsError"]);
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
		x = restCall("/standardizeMol","POST",pl);
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
		document.getElementById(f.id+"_frame").contentWindow.cd_putData(f.id,"chemical/x-mdl-molfile",chosenListItemCasJson['molData']);
		f.onchange();
		
		el = document.getElementById("casPopup");
		el.parentNode.removeChild(el); // Close the initial cas lookup popup
		$('#showCasResultsDiv').remove(); // Close the popup w/ table
		blackOff();	
	}
}
/* RC
function lookupCasNumber(casNumberInputValue){
	console.log(casNumberInputValue);

	//document.getElementById("addMolbtn").innerText = "Searching.."
	casDoc = getFile('getCasData.asp?casId='+casNumberInputValue+'&searchType=exactSearch&random='+Math.random());
	
	if ((JSON.parse(casDoc)).data.length > 0) {
		var casJson = ((JSON.parse(casDoc)).data)[0];
		console.log(casJson)
		if ((JSON.parse(casDoc)).currentSize == 1 ) {	//Exact search returned single record
			if (casJson.hasOwnProperty("cd_id")) {
				pl = {};
				pl["structure"] = casJson['cd_structure']['structureData']['structure'];
				pl["format"] = "mol:V3";
				x = restCall("/standardizeMol","POST",pl);
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
				document.getElementById(f.id+"_frame").contentWindow.cd_putData(f.id,"chemical/x-mdl-molfile",casJson['molData']);
				f.onchange();
				
				el = document.getElementById("casPopup");
				el.parentNode.removeChild(el); // Close the initial cas lookup popup
				$('#showCasResultsDiv').remove(); // Close the popup w/ table
				blackOff();
			}
		}
		else {	//Exact search returned multiple records
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
				
				//Reset the div height depending upon the table height
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
		//Exact search did not give any results.. Send another request with sub-search
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
				//Reset the div height depending upon the table height
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
*/

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
			fields = formBucket[i].fields;
			for(var j=0;j<fields.length;j++){
				if(fields[j].fieldType=="chem"){
					chemFields.pop(chemFields.indexOf(fields[j].id));
				}
			}
			formBucket.pop(i);
		}
	}
}

chemCheckerStarted = false;
chemFields = []

function checkChems(){
	for (var i=0;i<chemFields.length ; i++){
		field = chemFields[i];
		if (field.smilesLoaded){
			v = document.getElementById(field.id+"_frame").contentWindow.cd_getData(field.id,"chemical/x-daylight-smiles");
			if (v!=field.smiles){
				field.smiles = v;
				field.onchange();
			}
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
				result = restCall("/updateField","POST",theField)
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
					result = restCall("/updateField","POST",theField)
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
			/* RC
			td = document.createElement("td");
			field = {"value":item["structure"],"insertFormat":"text/xml","dims":[100,100]}
			td.appendChild(createTableChemBox(null,field,item["recordNumber"]+"errorTable",item["recordNumber"]+"errorTable"));
			tr.appendChild(td);
			*/
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
				result = restCall("/updateField","POST",theField)
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
				result = restCall("/updateField","POST",theField)
			}
		}
	};
	return el;
}

function createActionButton(theForm,theField,id,name,containerName){
	if(!(theField["action"]["action"]=="edit"&&!canEdit)){
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
				result = restCall("/updateField","POST",theField)
			}
		}
	};
	return el;
}

function createSelect(theForm,theField,id,name){
	el = document.createElement("select");
	el.setAttribute("id",fieldId);
	el.setAttribute("name",fieldId);
	el.multiple = theField.multiple;
	var foundMatch = false;
	var foundOther = false;
	var foundOther_optionId = "";
	if (!theField.multiple){
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
		if (theField.multiple){
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
		console.log(theField["value"]);
		theOption.setAttribute("value",theField["value"]);
		theOption.setAttribute("fieldOptionId",foundOther_optionId)
		theOption.appendChild(document.createTextNode(theField["value"]));
		theOption.selected = true;
		console.log(theOption);
		el.appendChild(theOption)
	}

	if (theField.multiple){
		el.onchange = function(){
			vals = [];
			for (i=0;i<this.options.length;i++ ){
				if(this.options[i].selected){
					vals.push(this.options[i].value);
				}
			}
			theField.value = vals;
			if(validateField(theField)){
				if (theForm.submitType == "connected"){
					result = restCall("/updateField","POST",theField)
				}
			}
		};
	}else{
		el.onchange = function(){
			theField.value = this.options[this.selectedIndex].value;
			if(validateField(theField)){
				if (theForm.submitType == "connected"){
					result = restCall("/updateField","POST",theField)
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
				result = restCall("/updateField","POST",theField)
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
				result = restCall("/updateField","POST",theField)
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
				result = restCall("/updateField","POST",theField)
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
	if((theField.fieldType == "select" && theField.multiple)||theField.fieldType == "multiText"){
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
			if (regId!=""){
				val = "<a href='javascript:void(0)' class='regLink' onclick='toggleRegData(\""+id+"\",\""+regId+"\")'>"+regId+"</a>"
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
	restCallA("/getList","POST",payload2,function(r){
		listForms = r["forms"];
			if(theField.options["nameField"].indexOf(",")!=-1){
				theField.options["nameField"] +=",Cell Line Name";
			}
		for(var i=0;i<listForms.length;i++){
			var fd = listForms[i];
			a = document.createElement("a");
			if(theField.options["nameField"].indexOf(",")!=-1){
				names = theField.options["nameField"].split(",");
				for(var q=0;q<names.length;q++){
					if(fd.fieldNames.indexOf(names[q])!=-1){
						nameValue = fd.fields[fd.fieldNames.indexOf(names[q])].value;
					}
				}
			}else{
				nameValue = fd.fields[fd.fieldNames.indexOf(theField.options["nameField"])].value;
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
	restCallA("/getList","POST",payload2,function(r){
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

function saveForm(fd,remove){
	checkChems();
	var payload = {'formId':fd.fid,'remove':remove};
	return restCall("/saveForm/","POST",payload);
}

function saveFormMulti(fd,remove,fieldName,values,elnLink,newParentId,source){
	checkChems();
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
	//for(var i=0;i<fd.fields.length;i++){
	//	if(!validateField(fd.fields[i])){
	//		formValid = false;
	//	}
	//}
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
		alert("Form contains errors.  Please review your data and try again.")
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
	if(thisField["fieldType"]=="fieldMapping"){
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
	if(thisField["fieldType"]=="text"){
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
	if(thisField["fieldType"]=="productId"){
		thisEl = showProductId(fd,thisField,fieldId,fieldId);
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]=="reactantIds"){
		thisEl = showReactantIds(fd,thisField,fieldId,fieldId);
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]=="itemGrid"){
		thisEl = createItemGrid(fd,thisField,fieldId,fieldId);
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]=="date"){
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
	if(thisField["fieldType"]=="password"){
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
	if(thisField["fieldType"]=="textarea"){
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
	if(thisField["fieldType"] == "select"){
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
	if(thisField["fieldType"] == "checkbox"){
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
	if(thisField["fieldType"] == "userInfo"){
		thisEl = showText(fd,thisField,fieldId,fieldId,thisField.displayKey)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	if(thisField["fieldType"] == "dateFixed"){
		thisEl = showText(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	/* RC
	if(thisField["fieldType"]=="chem"){
		thisEl = createChemBox(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	*/
	if(thisField["fieldType"]=="addChildLink"){
		thisEl = createAddChildLink(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]=="showChildLinks"){
		thisEl = createShowChildLinks(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]=="childLinks2"){
		thisEl = createChildLinks2(fd,thisField,fieldId,fieldId,fd["view"])
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	//invPerm
	if(thisField["fieldType"]=="permissions"){
		thisEl = createPermissions(fd,thisField,fieldId,fieldId,fd["view"])
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	//end invPerm
	if(thisField["fieldType"]=="file"){
		thisEl = createFileBox(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]=="multiText"){
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
	if(thisField["fieldType"]=="widget"){
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
	if(thisField["fieldType"]=="plateMap"){
		thisEl = createPlateMap(fd,thisField,fieldId,fieldId)
		thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
		thisEl.className += " ax1-"+thisField["fieldType"];
		r["label"] = thisLabel;
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]=="button"){
		if (!fd["view"]){
			thisEl = createButton(fd,thisField,fieldId,fieldId)
		}
		thisEl.className += "ax1-"+thisField["fieldType"];
		r["el"] = thisEl;
	}
	if(thisField["fieldType"]=="actionButton"){
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
			$(el).remove();
		}
		targetEl = $("#"+fd.fid+" [formName='"+el.getAttribute("formName")+"_error']");
		if(targetEl){
			$(el).append(targetEl);
		}
	});

	$.each($('.templateSelect .ax1-select'), function(index, val) {
		// Grab the value & text of correct selected option
		var selectedOptionVal = $(this).find('option:selected').attr('value');
		var selectedOptionText = $(this).find('option:selected').text();
		// Reorder option elements alphabetically
		$(this).children().detach().sort(function(a, b) {
			return $(a).text().localeCompare($(b).text());
		}).appendTo($(this));
		// Now select the correct option again
		$.each($(this).find('option'), function(optionIndex,optionElement){
			if($(this).attr('value') == selectedOptionVal && $(this).text() == selectedOptionText){
				$(this).prop('selected', 'selected');
			}
		});
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
			console.log(fieldValueJSONParsed)
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
			replacementHTML = "<a href='javascript:void(0)' class='regLink' onclick='toggleRegData(\""+$(this).attr('id')+"\",\""+regId+"\")'>"+regId+"</a>"
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

function makeObjectTemplateHTML(objectTemplateRequest){
	var dataMiddle = "";
	if(objectTemplateRequest['result'] == "success"){
		var templateElement = $('<div class="objectTemlpateContainer"></div>');
		var templateObject = objectTemplateRequest['templateObject'];
		
		if(templateObject['hasStructure']){
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
		console.log(templateElement);
		console.log(templateElement.html());
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
function makeForm(fd,containerId,lf,floatIt,cb){
	var item;
	currentFD = fd;
	window.itemJSON = fd;
	chemFields = [];
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
		console.log(r);
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
						});				
				});
		}else{
			$.get("templates/"+fd.template+"?r="+Math.random())
				.done(function(data){applyTemplate(data,fd,containerId,cb)});
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
		makeForm(addObjectForm,containerId,undefined,true);
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
	/* RC
	if(field.fieldType=="chem"){
		el = createTableChemBox(fd,field,field.id+"_tn",field.id+"_tn")
		td.appendChild(el);
	}
	*/
	return td;
}
/* RC
var downloadCSV = [];
*/
var thisRow = [];
/* RC
function makeEditTable(fds,containerId,fixedFields,inFrame){
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
			el.parentNode.removeChild(el);
		}else{
			el=document.getElementById('listTable'+containerId);
			el.parentNode.removeChild(el);
		}
	}catch(err){}
	document.getElementById(containerId).appendChild(table);
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
*/
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
			var fieldOptionId = $(this).find('option:selected').attr('fieldoptionid');
			var changedDropdown = $(this);
			if(typeof window.itemJSON !== "undefined"){
				$.each(window.itemJSON['fields'], function(){
					if(formName == this['formName']){
						if(typeof fieldOptionId !== "undefined" && fieldOptionId !== "" && typeof this['conditionalFieldsAndOptions'][fieldOptionId] !== "undefined"){
							// Build up a string for the :not of our query selectors below
							var notString = ""
							$.each(this['conditionalFieldsAndOptions'][fieldOptionId]['fieldNames'], function(key, val){
								notString += '[formname="' + val + '"],'
							});
							notString = notString.substring(0, notString.length - 1); // Remove trailing comma
							// Go through the conditional form rows that are currently shown because of the dropdown that just changed BUT are ":not" one of the fields we're about to un-hide... Then reset their values as we hide them
							$('.conditionalInvTemplateField[class*="showConditional_'+fieldName+'"]:not(' + notString + ')').each(function(){
								// Hide and reset it to the default blank value
								$(this).removeClass('showConditional_' + fieldName).find('select').prop('selectedIndex',0).change().find('option').not(':first-of-type').prop('disabled',true);
								$(this).removeClass('showConditional_' + fieldName).find('input[type="text"]').val('').change();
							});
							// Show the dropdowns triggered
							$.each(this['conditionalFieldsAndOptions'][fieldOptionId]['fieldNames'], function(key, val){
								$('.conditionalInvTemplateField[formname="'+val+'"]').addClass('showConditional_' + fieldName); // Will eventually make this "showConditional_[fieldName]_[fieldOptionId]" in order to better track which dropdowns & which options actually activated the dropdown
							});
							// Enable their options according to the JSON
							$.each(this['conditionalFieldsAndOptions'][fieldOptionId]['fieldOptions'], function(key, val){
								$('.conditionalInvTemplateField.showConditional_' + fieldName).find('select > option[fieldoptionid="' + val + '"]').prop('disabled',false);
							});
						}
						else{
							// Simply remove everything that was triggered by this fieldName, plus anything those things triggered
							$('.conditionalInvTemplateField[class*="showConditional_'+fieldName+'"]').each(function(){
								// Hide and reset it to the default blank value
								$(this).removeClass('showConditional_' + fieldName).find('select').prop('selectedIndex',0).change().find('option').not(':first-of-type').prop('disabled',true);			
								$(this).removeClass('showConditional_' + fieldName).find('input[type="text"]').val('').change();
							});
						}
						return false;
					}
				});
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
		console.log($(this).parent().parent().find('[multiplevalues="True"] .multipleValuesField_valueContainer:last-of-type .multipleValuesField_newValueButton'));
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
			console.log(r)
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
			console.log($(this).parent().parent().find('.multipleValuesField_valueContainer:last-of-type input[type="text"]'));
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







