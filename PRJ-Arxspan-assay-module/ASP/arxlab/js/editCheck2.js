var unsavedChanges = false;

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

function addFocusEvent(el,func)
{
	var oldOnFocus = el.onfocus;
	if (typeof el.onfocus != 'function')
	{
		el.onfocus = func;
	}
	else
	{
		el.onfocus = function(){
			func(el);
			if (oldOnFocus) 
			{
				oldOnFocus();
			}
		}
	}
}

function addBlurEvent(el,func)
{
	var oldOnBlur = el.onblur;
	if (typeof el.onblur != 'function') 
	{
		el.onblur = func;
	} 
	else 
	{
		el.onblur = function(){
			func();
			oldOnBlur();
		}
	}
}

function addChangeEvent(id,func) {
	el = document.getElementById(id)
	var oldOnChange = el.onchange;
	if (typeof el.onchange != 'function')
	{
		el.onchange = func;
	} 
	else
	{
		el.onchange = function() {
			func();
			oldOnChange();
		}
	}
}

//This is to fix a bug with the Add Sketch with the Ajax save
function areExperimentVarsSet(){
	if (typeof experimentId === 'undefined'){
		experimentId = parseInt(document.getElementById("experimentId").value);
	}
	if (typeof experimentType === 'undefined'){
		experimentType = parseInt(document.getElementById("experimentType").value);
	}

}
var timeouts = [];
function sendAutoSave(theKey,theVal){
	return new Promise(function(resolve, reject) {
		if(theVal == null) {
			resolve(true);
			return;
		}
	
		theVal = theVal.toString();
		areExperimentVarsSet();
		if (experimentId !== parseInt(experimentId)){
			experimentId = experimentId.value;
			experimentType = experimentType.value;
		}
		
		if(!unsavedChangesCheck()) {
			resolve(true);
		}
		else {
			showOverMessage("savingDraft","page");
			experimentJSON[theKey] = encodeJSON(theVal);
			var draftSaveUrl = "/arxlab/experiments/ajax/do/saveDraft.asp?experimentId="+experimentId+"&experimentType="+experimentType
			if (canWrite) {
				draftSaveUrl += "&c=" + true;
			}

			$.ajax({
				url: draftSaveUrl,
				data: {
					thePairs: JSON.stringify([{"theKey": theKey, "theVal": encodeJSON(theVal)}])
				},
				type: "POST",
			}).done(function() {
				resolve(true);
				window.setTimeout(function(){hideOverMessage("savingDraft")},500);
			});
		}
	});
}

function saveRow(rowData)
{
	return new Promise(function(resolve, reject) 
	{
		areExperimentVarsSet();
		if (experimentId !== parseInt(experimentId)){
			experimentId = experimentId.value;
			experimentType = experimentType.value;
		}
		showOverMessage("savingDraft","page");
		
		var draftSaveUrl = "/arxlab/experiments/ajax/do/saveDraft.asp?experimentId="+experimentId+"&experimentType="+experimentType
		if (canWrite) {
			draftSaveUrl += "&c=" + true;
		}

		$.post( draftSaveUrl, { thePairs: rowData } )
		.done(function(msg) 
		{
			console.log( "success" );
			resolve(true);
		})
		.fail(function() 
		{
			console.error( "error" );
			reject(false);
		})
		.always(function(msg) 
		{
			hideOverMessage("savingDraft")
			console.log( "finished" );
			console.log(msg);
		});

	});
}

function RemoveRow(tableID,rowNumber)
{
	return new Promise(function(resolve, reject) 
	{
		areExperimentVarsSet();
		if (experimentId !== parseInt(experimentId)){
			experimentId = experimentId.value;
			experimentType = experimentType.value;
		}
	
		var draftSaveUrl = "/arxlab/experiments/ajax/do/EditDraft.asp?experimentId="+experimentId+"&experimentType="+experimentType
		if (canWrite) {
			draftSaveUrl += "&c=" + true;
		}

		$.post( draftSaveUrl, { theRow: rowNumber , theTable: tableID})
		.done(function() 
		{
			console.log( "success" );
			resolve(true);
		})
		.fail(function() 
		{
			console.error( "error" );
			reject(false);
		})
		.always(function(msg) 
		{
			console.log( "finished" );
			console.log(msg);
		});

	});
}

function encodeJSON(str){
	if(!str)
		return "";

	var aStr = str.split('');
    var z = aStr.length;
    aRet = [];
	
	while (--z>=0) {
		var iC = aStr[z].charCodeAt();
		if (iC> 128) {
			aRet.push('&#'+iC+';');
		} else {
			aRet.push(aStr[z]);
		}
	}
	
	return aRet.reverse().join('');
}

var gridSaveTimeout;
function sendGridAutoSave(){
	saveList = [];
	gridPrefixes = ["r","rg","p","s"];
	
	for(var gp=0; gp < gridPrefixes.length; gp++)
	{
		//var i = -1;
		//while(true)
		for(var i=0;i<30;i++)
		{
			prefix = gridPrefixes[gp] + String(i);
			var tabElem = document.getElementById(prefix+"_tab");
			
			if(tabElem === undefined)
				break;
			else
			{
				experimentJSON[prefix+"_UAStates"] = JSON.stringify(UAStates[prefix]);
				sendAutoSave(prefix + "_UAStates", JSON.stringify(UAStates[prefix]));
				if(document.getElementById(prefix+"_body")) {
					els = document.getElementById(prefix+"_body").getElementsByTagName("input")
					for(j=0;j<els.length;j++){
						if(els[j].getAttribute("type")=="text" || els[j].id==prefix+"_UAStates"){
							saveList.push({"theKey":els[j].id,"theVal":encodeJSON(els[j].value)});
							experimentJSON[els[j].id] = els[j].value;
						}
						if(els[j].getAttribute("type")=="checkbox"){
							if(els[j].checked){
								saveList.push({"theKey":els[j].id,"theVal":"CHECKED"});
								experimentJSON[els[j].id] = "CHECKED";
							}else{
								saveList.push({"theKey":els[j].id,"theVal":""});
								experimentJSON[els[j].id] = "";
							}
						}
					}
				}
			}
		}
	}
	
	var saveDraft = unsavedChangesCheck();
	if (!(experimentId === parseInt(experimentId))){
		experimentId = experimentId.value;experimentType = experimentType.value;
	}
	console.log("editCheck2 sendGridAutoSave");
	if(saveDraft)
	{
		showOverMessage("savingDraft","page");
		var draftSaveUrl = "/arxlab/experiments/ajax/do/saveDraft.asp?experimentId="+experimentId+"&experimentType="+experimentType
		if (canWrite) {
			draftSaveUrl += "&c=" + true;
		}
		$.post( draftSaveUrl, { thePairs: JSON.stringify(saveList)} );
		window.setTimeout(function(){hideOverMessage("savingDraft")},1100);
		if(hasMarvin){
			getChemistryEditorChemicalStructure("mycdx", false, "mrv").then(function (mrvData) {
				$.post("/arxlab/_inclds/experiments/chem/asp/chemDataMarvin.asp",{mrvData: mrvData, molData: "", experimentId: experimentId, experimentJSON: JSON.stringify(experimentJSON)}, function(data){
					console.log(data);
				});
			});
		}
	
	}
}
experimentJSON = {}

function attachEdits(rootEl)
{ 	// make an array of all the text inputs on the page expcept ones that should not have the unsaved changes warning
	els = [];
	els1 = rootEl.getElementsByTagName("input");
	for(i=0;i<els1.length;i++)
	{
		if((els1[i].getAttribute("type") == "text" && els1[i].getAttribute("name") != "fileName" && els1[i].getAttribute("name") != "noteName" && els1[i].getAttribute("name") != "reasonBox"&& els1[i].getAttribute("name") != "tabName" && els1[i].getAttribute("name") != "fileDescription"&& els1[i].getAttribute("name") != "noteText" && els1[i].getAttribute("class") != "attachmentName") 
			|| els1[i].getAttribute("type") == "hidden");
		{
			els.push(els1[i]);
		}
	}

	els1 = rootEl.getElementsByTagName("textarea");
	for(i=0;i<els1.length;i++)
	{
		if (els1[i].getAttribute("name") != "fileName" && els1[i].getAttribute("name") != "noteName" && els1[i].getAttribute("name") != "reasonBox"&& els1[i].getAttribute("name") != "tabName" && els1[i].getAttribute("name") != "fileDescription"&& els1[i].getAttribute("name") != "noteText" && els1[i].getAttribute("name") != "comment")
		{
			els.push(els1[i]);
		}
	}

	els1 = rootEl.getElementsByTagName("select");
	for(i=0;i<els1.length;i++)
	{
		if (els1[i].getAttribute("name")=="sigdig")
		{
			els.push(els1[i]);
		}
	}

	//scroll through the array and add the functions that keep track of whether a field has been changed
	for(i=0;i<els.length;i++)
	{
		addFocusEvent(els[i],editCheckStart);
		addBlurEvent(els[i],editCheckEnd);
		if (els[i].name == "e_userAddedName" || els[i].name == "e_details"){
			$(els[i]).on('input', editCheckEnd);
		}
		experimentJSON[els[i].name] = encodeJSON(els[i].value);
	}
	//alert(JSON.stringify(experimentJSON))
}

function attachEditById(id)
{
	addFocusEvent(document.getElementById(id),editCheckStart);
	addBlurEvent(document.getElementById(id),editCheckEnd);
}

var prevEditCheckText = ""
var unavedChanges = false;
var lastTextFieldChanged;
function editCheckStart(el)
{
	//alert(el.getAttribute("stepNumber"))
	try{t=el.getAttribute("stepNumber");if(t){gridStepNumber = t;}}catch(err){}
	//alert(window.gridStepNumber)
	//put the current value of the field into the prevEditCheckText global variable
	if (el.nodeName == "SELECT"){
		if (this.value != undefined){
			prevEditCheckText = this.options[this.selectedIndex].value;
		}
		else{
			prevEditCheckText = el.options[el.selectedIndex].value;
		}
	}else{
		if (this.value != undefined){
			prevEditCheckText = this.value
			lastTextFieldChanged = this;
		}
		else{
			prevEditCheckText = el.value
			lastTextFieldChanged = el;
		}
	}
}


function editCheckEnd()
{
	if (this.nodeName == "SELECT"){
		theValue = this.options[this.selectedIndex].value;
	}else{
		theValue = this.value;
	}
	//if value of field has been changed set global unsavedChanges to true
	if (theValue != prevEditCheckText)
	{
		unsavedChanges = true;
		experimentJSON[this.name] = encodeJSON(theValue);
		var name = this.name;
		sendAutoSave(name,theValue);
		prevEditCheckText = theValue;
		//alert(JSON.stringify(experimentJSON))
	}
	//fix width for the quick units dummy view
	if (theValue.match(/^[0-9\. ]*$/))
	{
		if(theValue.match(/[0-9]+/))
		{
		try{
			if(document.getElementById(this.id+"_du").innerHTML!='')
			{
				this.value = this.value.replace(/^\s+|\s+$/g,"")
				this.value += " " + document.getElementById(this.id+"_du").innerHTML;
				sendAutoSave(this.id,this.value);
				this.onchange();
			}
		}
		catch(err){}
		}
	}
}

//check for unsaved changes every 5 seconds
var usi = window.setInterval("unsavedChangesCheck()",2000)

function unsavedChangesCheck()
{
	//if there are unsaved changes show the unsaved changes nugget
	if (unsavedChanges && document.getElementById("unsavedChanges").style.display != "block")
	{
		showOverMessage("unsavedChanges","page");
	}
	
	return unsavedChanges;
}

function changeHistoryToDraft(){
	try{
		document.getElementById("currentHistoryItem").style.display = "none";
		document.getElementById("draftHistoryItem").style.display = "block";
	}
	catch(err){
		window.setTimeout(changeHistoryToDraft,1000)
	}
}
var editorsOnTimeout = [];
function ckChange(e){
	secondsUntilForceSave = 10;
	secondsToSaveOnIdle = 1;
	e.editor.hasChanged = true;
	unsavedChanges=true;
	if(!e.editor.secondsLastSave){
		e.editor.secondsLastSave = new Date()/1000;
	}
	if(e.editor.timeoutForOnChange && new Date()/1000 - e.editor.secondsLastSave<secondsUntilForceSave){
		window.clearTimeout(e.editor.timeoutForOnChange)
	}else{
		e.editor.secondsLastSave = new Date()/1000;
	}
	e.editor.timeoutForOnChange = setTimeout(function(){
		experimentJSON[e.editor.name]=e.editor.getData();
		sendAutoSave(e.editor.name,e.editor.getData())
		//alert(JSON.stringify(experimentJSON))
		//alert(experimentJSON["e_protocol"])
		//alert(experimentJSON["e_protocol"].length)
		editorsOnTimeout = [];
	},secondsToSaveOnIdle*1000)
	editorsOnTimeout.push(e.editor.timeoutForOnChange);
}

function discardChanges(){
	if(confirm("Are you sure you want to discard all changes made since your last save on "+document.getElementById("lastSaveDate").innerHTML)){
		if (!(experimentId === parseInt(experimentId))){
			experimentId = experimentId.value;experimentType = experimentType.value;
		}
		getFile("/arxlab/experiments/ajax/do/discardChanges.asp?experimentId="+experimentId+"&experimentType="+experimentType);
		window.location = window.location;
	}
}