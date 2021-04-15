node = null;

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

if(typeof(String.prototype.trim) === "undefined")
{
    String.prototype.trim = function() 
    {
        return String(this).replace(/^\s+|\s+$/g, '');
    };
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
    var curtop = 0;
    if (obj.offsetParent) {
        do {
            curtop += obj.offsetTop;
        } while (obj = obj.offsetParent);
    return [curtop];
    }
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
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	form = "url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data));
	client.open("POST", "invp.asp", false);
	client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	client.send(form);
	if (client.status == 200){
		if (client.responseText == ""){
			return JSON.parse("{}");
		}else{
			if (returnType == "text/plain"){
				return client.responseText;
			}else{
				return JSON.parse(client.responseText);
			}

		}
	}else{
		return false;
	}
}

function restCallInv(url,verb,data,returnType){
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	form = "url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data));
	client.open("POST", "invpInv.asp", false);
	client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	client.send(form);
	if (client.status == 200){
		if (client.responseText == ""){
			return JSON.parse("{}");
		}else{
			if (returnType == "text/plain"){
				return client.responseText;
			}else{
				return JSON.parse(client.responseText);
			}

		}
	}else{
		return false;
	}
}

function restCallA(url,verb,data,cb,returnType){
	var form
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	form = "url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data));
	client.onreadystatechange=(function(client,cb,returnType){
		return function(){
			restCallACb(client,cb,returnType);
		}
	})(client,cb,returnType);
	client.open("POST", "invp.asp", true);
	client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	client.send(form);
	return false;
}

function restCallAInv(url,verb,data,cb,returnType){
	var form
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}
	form = "url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data));
	client.onreadystatechange=(function(client,cb,returnType){
		return function(){
			restCallACb(client,cb,returnType);
		}
	})(client,cb,returnType);
	client.open("POST", "invpInv.asp", true);
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
					cb(JSON.parse(client.responseText));
				}
			}
		}else{
			return false;
		}
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
	el.multiple = theField.multiple;
	if (!theField.multiple){
		theOption = document.createElement("option");
		theOption.setAttribute("value","");
		theOption.appendChild(document.createTextNode("--SELECT--"));
		el.appendChild(theOption)
	}
	for(var j=0;j<thisField["options"].length;j++){
		thisValue = thisField["options"][j];
		theOption = document.createElement("option");
		theOption.setAttribute("value",thisValue);
		theOption.appendChild(document.createTextNode(thisValue));
		if (theField.multiple){
			if (theField["value"].indexOf(thisValue)!=-1){
				theOption.selected = true;
			}
		}else{
			if (thisValue == theField["value"]){
				theOption.selected = true;
			}
		}
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
					result = restCall("/updateField/","POST",theField)
				}
			}
		};
	}else{
		el.onchange = function(){
			theField.value = this.options[this.selectedIndex].value;
			if(validateField(theField)){
				if (theForm.submitType == "connected"){
					result = restCall("/updateField/","POST",theField)
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
	src = "upload_file_frame.asp?formId="+theForm.fid+"&fieldId="+theField.id+"&readonly="+theForm["view"]+"&connectionId="+connectionId
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
			}
		}
	};
	return el;
}

function createChemBox(theForm,theField,id,name){
	return new Promise(function (resolve, reject) {
		hasChemdraw().then(function (isInstalled) {
			if (isInstalled) {
				el = document.createElement("iframe");
				el.setAttribute("id",id+"_frame");
				el.setAttribute("name",name+"_frame");
				el.setAttribute("src","chemBox.asp?readonly="+theForm["view"]+"&name="+id+"&w="+(theField["dims"][0]+30)+"&h="+(theField["dims"][1]+30))
				if (theField["dims"]){
					el.setAttribute("width",theField["dims"][0]+30);
					el.setAttribute("height",theField["dims"][1]+30);
				}
				theField.smiles = "";
				theField.smilesLoaded = false;

				loadFunction = function(){
					if(theField["value"].hasOwnProperty("cdxml")){
						theValue = theField["value"]["cdxml"];
					}else{
						theField["value"]["cd_id"] = "";
						theValue = "";
					}
					if(theValue != ""){
						document.getElementById(id+"_frame").contentWindow.cd_putData(id,theField["insertFormat"],theValue);
					}
					if(theForm.action!="view"){
						smiles = restCall("/convertStructure/","POST",{'format':'smiles','structure':theField["value"]})["structure"]
						if(smiles == "" || theValue==""){
							theField.smilesLoaded = true;
						}else{
							window.setTimeout((function(id) {
									numTries = 10;
									id = id
									function getSmiles() {
										smiles = document.getElementById(id+"_frame").contentWindow.cd_getData(id,"chemical/x-daylight-smiles");
										if (smiles == ""){
											if (numTries >0){
												window.setTimeout(getSmiles,500);
												numTries -= 1;
											}
										}else{
											theField.smiles = smiles;
											theField.smilesLoaded = true;
										}
									}
									return getSmiles;
								})(id),500)
						}
						//chemSmiles[id] = document.getElementById(id+"_frame").contentWindow.cd_getData(id,"chemical/smiles");
					}
				}
				if(el.attachEvent) {
					el.attachEvent('onload',loadFunction);
				}else{
					el.onload = loadFunction;
				}
				if(theForm.action != "view"){
					theField.onchange = function(){
						theField["value"]["cd_id"] = document.getElementById(id+"_frame").contentWindow.cd_getData(id,theField["getFormat"]);
						theField["value"]["cdxml"] = document.getElementById(id+"_frame").contentWindow.cd_getData(id,"text/xml");
						if(validateField(theField)){
							if (theForm.submitType == "connected"){
								//alert(JSON.stringify(theField))
								result = restCall("/updateField/","POST",theField)
							}
						}
					};
					chemFields.push(theField);
					if (!chemCheckerStarted){
						chemCheckerStarted = true;
						window.setInterval(function(){checkChems();},5000)
					}
				}
				resolve(el);
			} else {
				el = document.createElement("img");
				el.src = "getChemImage.asp?c="+chemTable+"&cdId="+theField["value"]["cd_id"]+"&size=400";
				el.width = 300;
				el.style.backgroundColor = "#ffffff";
				resolve(el);
			}
		});
	});
}

function createTableChemBox(theForm,theField,id,name){
	return new Promise(function (resolve, reject) {
		hasChemdraw().then(function (isInstalled) {
			if (isInstalled) {
				el = document.createElement("iframe");
				el.setAttribute("id",id+"_frame");
				el.setAttribute("name",name+"_frame");
				el.setAttribute("src","chemBox.asp?readonly=true&name="+id+"&w=100&h=100")
				if (theField["dims"]){
					el.setAttribute("width",100);
					el.setAttribute("height",100);
				}
				loadFunction = function(){
					if(theField["value"]){
						document.getElementById(id+"_frame").contentWindow.cd_putData(id,theField["insertFormat"],theField["value"]["cdxml"]);
					}
				}
				if(el.attachEvent) {
					el.attachEvent('onload',loadFunction);
				}else{
					el.onload = loadFunction;
				}
				resolve(el);
			}
			else{
				el = document.createElement("img");
				el.src = "getChemImage.asp?c="+chemTable+"&cdId="+theField["value"]["cd_id"]+"&size=100";
				el.style.width = "100px";
				el.style.height = "100px";
				el.style.backgroundColor = "#ffffff";
				resolve(el);
			}
		});
	});
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
		if(theField.assayType == "Notebook Page" || theField.assayType == "Reg Id"){
			if(theField.assayType == "Notebook Page"){
				a = document.createElement("a");
				a.setAttribute("target","new");
				a.setAttribute("href","/arxlab/experiments/experimentByName.asp?name="+theField.value);
				a.innerHTML = theField.value;
				el.appendChild(a);
			}
			if(theField.assayType == "Reg Id"){
				a = document.createElement("a");
				a.href = "../registration/showRegItem.asp?regNumber="+field.value;
				a.innerHTML = field.value;
				a.setAttribute("target","new")
				el.appendChild(a)
			}
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
			try{
				el.innerHTML = val.replace("\n","<br/>");
			}catch(err){
				el.innerHTML = val;
			}
		}
	}
	return el;
}

function createAddChildLink(theForm,theField,id,name){
	el = document.createElement("a");
	el.setAttribute("id",id);
	el.innerHTML = theField["formName"];
	opts = theField["options"];
	el.href='javascript:void(0);';
	el.onclick = (function(opts,theForm){
		return function(){
			clearContainer("arxOneContainer");
			pl = {"action":"add","collection":opts["collection"],"parent":{"collection":"assayItems","id":theForm.id}};
			addObjectForm = restCall("/getForm/","POST",pl);
			formBucket.push(addObjectForm);
			addObjectForm.onSave = function(fd){
				return function(){
					if(validateForm(fd)){
						saveForm(fd,true);
						clearContainer("arxOneContainer");
						removeForm(fd.fid);
						pl = {"action":"view","collection":theForm.fields[theForm.fieldNames.indexOf("_type")].value,"id":theForm.id};
						addObjectForm = restCall("/getForm/","POST",pl);
						makeForm(addObjectForm,"arxOneContainer");
					}
				}
			}(addObjectForm);			
			makeForm(addObjectForm,"arxOneContainer");
		}
	})(opts,theForm);
	return el;
}

function createResults(theForm,theField,id,name){
	joinFields = JSON.parse(theForm.fields[theForm.fieldNames.indexOf("Join Fields")].value);
	el = document.createElement("div");
	thisResult = theField.value;
	div = document.createElement("div");
	div.style.marginLeft="6px";
	barcode = "";
	for (var j=0;j<thisResult.length;j++){
		thisField = thisResult[j];
		if(thisField.name == "Barcode"){
			barcode = thisField.value.trim();
		}
	}
	for(key in joinFields){
		if (joinFields.hasOwnProperty(key)){
			theseJoinFields = joinFields[key];
			if(theseJoinFields.length!=0){
				for(var j=0;j<thisResult.length;j++){
					if (thisResult[j].name==theseJoinFields[0]){
						D = JSON.parse(JSON.stringify(thisResult[j]));
						D["cols"] = [JSON.parse(JSON.stringify(thisResult[j]))];
						D["name"] = key;
						D["hide"] = false;
					}
				}
				for (var i=1;i<theseJoinFields.length;i++){
					for(var j=0;j<thisResult.length;j++){
						if (thisResult[j].name==theseJoinFields[i]){
							D["cols"].push(JSON.parse(JSON.stringify(thisResult[j])));
						}
					}
				}
				numRows = D["value"].length;
				D["value"] = [];
				for(var j=0;j<numRows;j++){
					L = [];
					for (var i=0;i<theseJoinFields.length;i++){
						try{
							L.push(D["cols"][i]["value"][j]);
						}catch(err){}
					}
					D["value"].push(L);
				}
				thisResult.unshift(D);
			}
		}
	}
	//should use the show text that the main makeForm does
	for (var j=0;j<thisResult.length;j++){
		thisField = thisResult[j];
		if(!thisField.hide){
			div2 = document.createElement("div");
			div2.style.marginLeft="6px";
			label = document.createElement("label");
			label.innerHTML = thisField.name;
			div2.appendChild(label);
			if (!thisField.multi){
				if (thisField.assayType=="Notebook Page" ||	thisField.assayType == "Reg Id"){
					span = document.createElement("span");
					a = document.createElement("a");
					a.setAttribute("target","new");
					if(thisField.assayType=="Notebook Page"){
						a.setAttribute("href","/arxlab/experiments/experimentByName.asp?name="+thisField.value);
					}else{
						a.setAttribute("href","../registration/showRegItem.asp?regNumber="+thisField.value);
					}
					a.innerHTML = thisField.value;
					el.appendChild(a);
					span.appendChild(a);
					div2.appendChild(span);
				}else{
					span = document.createElement("span");
					if(thisField.decimalPlaces&&thisField.showScientificNotation&&thisField.value!=""){
						span.innerHTML = parseFloat(thisField.value).toExponential(thisField.decimalPlaces);
					}else{
						span.innerHTML = thisField.value;
					}
					div2.appendChild(span);
				}
			}else{

					div2.appendChild(createPlateTable(thisField.value,thisField.id,j,barcode,thisField))
				if(thisField.hasHeat){
					div2.appendChild(createPlateTableHeat(thisField.value,thisField.id,j,barcode,thisField.hasHeaders))
				}
			}
		}
		div.appendChild(div2);
	}
	el.appendChild(div);
	
	return el;
}

function createPlateTable(L,id1,id2,barcode,field){
	hasHeaders = field.hasHeaders;
	numDecimals = field.decimalPlaces;
	assayType = field.assayType;
	showScientificNotation = field.showScientificNotation;
	numCols = L[0].length;
	numRows = L.length;
	rows = [];
	cols = [];
	for(var i=1;i<=numCols;i++){
		if(i<10){
			cols.push("0"+i);
		}else{
			cols.push(i);
		}
	}
	for(var i=0;i<numRows;i++){
		rows.push(String.fromCharCode(65+i));
	}
	var el = document.createElement("table");
	el.setAttribute("id","plateMap_"+id1+"_"+id2);
	el.className = "plateMap";
	var tbody = document.createElement("tbody");
	//tbody.onmouseout=function(){document.getElementById("wellView").style.left="-1000px";}
	if(!hasHeaders){
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
	}	
	for(var i=0;i<rows.length;i++){
		tr = document.createElement("tr");
		if(!hasHeaders){
			td = document.createElement("td");
			td.appendChild(document.createTextNode(rows[i]));
			tr.appendChild(td);
		}		
		if(i%2==0){
			tr.className = "even";
		}else{
			tr.className = "odd";
		}
		for(var j=0;j<cols.length;j++){
			if(field.cols){
				numDecimals = field["cols"][j].decimalPlaces;
				showScientificNotation = field["cols"][j].showScientificNotation;
				assayType = field["cols"][j].assayType;
			}
			td = document.createElement("td");
			span = document.createElement("span");
			span.setAttribute("id","plateMap_"+id1+"_"+id2+"_"+(i+1)+"_"+(j+1));
			if(numDecimals==""){
				try{
					if(isNaN(Math.round(L[i][j] * 100) / 100)||L[i][j]==""){
						if(assayType=="Reg Id"){
							a = document.createElement("a");
							a.href = "../registration/showRegItem.asp?regNumber="+L[i][j];
							a.innerHTML = L[i][j];
							a.setAttribute("target","new")
							span.appendChild(a)
						}else{
							span.innerHTML = L[i][j];
						}
					}else{
						if(showScientificNotation){
							span.innerHTML = (Math.round(L[i][j] * 100) / 100).toExponential();
						}else{
							span.innerHTML = Math.round(L[i][j] * 100) / 100
						}
					}
				}catch(err){}
			}else{
				try{
					if(isNaN(Math.round(L[i][j] * 100) / 100)||L[i][j]==""){
						if(assayType=="Reg Id"){
							a = document.createElement("a");
							a.href = "../registration/showRegItem.asp?regNumber="+L[i][j];
							a.innerHTML = L[i][j];
							a.setAttribute("target","new")
							span.appendChild(a)
						}else{
							span.innerHTML = L[i][j];
						}
					}else{
						if(showScientificNotation){
							span.innerHTML = parseFloat(L[i][j]).toExponential(numDecimals);	
						}else{
							span.innerHTML = parseFloat(L[i][j]).toFixed(numDecimals);
						}
					}
				}catch(err){}
			}
			if(span.innerHTML=="NaN"){
				span.innerHTML = "";
			}
			td.appendChild(span);
			tr.appendChild(td);
		}
		tbody.appendChild(tr)
	}
	el.appendChild(tbody);
	if(barcode!=""){
		payload22 = {};
		query22 = {"barcode":barcode,"_invType":"plate"}
		payload22["rpp"] = 1;
		payload22["collection"] = "inventoryItems";
		payload22["list"] = true;
		payload22["query"] = query22;
		payload22["action"] = "next";
		restCallAInv("/getList/","POST",payload22,function(bcForm){
			if(bcForm["forms"].length!=0){
				payload2 = {}
				query = {"_invType":"well","parent.id":bcForm["forms"][0].id}
				payload2["rpp"] = 1000;
				payload2["collection"] = "inventoryItems";
				payload2["list"] = true;
				payload2["query"] = query;
				payload2["action"] = "next";
				restCallAInv("/getList/","POST",payload2,function(r){
					listForms = r["forms"];
					for(var i=0;i<listForms.length;i++){
						var fd = listForms[i];
						//alert(JSON.stringify(fd))
						//alert(JSON.stringify(fd.fieldNames));
						compounds = fd.fields[fd.fieldNames.indexOf("Compounds")].value;
						//alert(compounds)
						if(compounds.length){
							loc = fd.fields[fd.fieldNames.indexOf("Location")].value;
							a = document.createElement("a");
							a.innerHTML = document.getElementById("plateMap_"+id1+"_"+id2+"_"+loc["rowPos"]+"_"+loc["colPos"]).innerHTML;
							a.href="javascript:void(0)";
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
									makeForm(fd,"wellView");
									compounds = fd.fields[fd.fieldNames.indexOf("Compounds")].value;
									pl = {"action":"view","collection":"compound","id":compounds[0]["compound_id"],"little":true};
									addObjectForm = restCallInv("/getForm/","POST",pl);
									makeForm(addObjectForm,"wellView");
									$("#wellView").mouseenter(function(){
										$("#wellView").mouseleave(function(){
											$("#wellView").css({'left':-1000+'px'})
										})						
									})
								}
							})(fd);
							cell = document.getElementById("plateMap_"+id1+"_"+id2+"_"+loc["rowPos"]+"_"+loc["colPos"]);
							if(cell){
								cell.innerHTML = '';
								cell.appendChild(a);
							}
						}
					}
				});
			}	
		});
	}	

	return el;
}

function createPlateTableHeat(L,id1,id2,barcode,hasHeaders){
	numCols = L[0].length;
	numRows = L.length;
	rows = [];
	cols = [];
	for(var i=1;i<=numCols;i++){
		if(i<10){
			cols.push("0"+i);
		}else{
			cols.push(i);
		}
	}
	for(var i=0;i<numRows;i++){
		rows.push(String.fromCharCode(65+i));
	}
	var el = document.createElement("table");
	el.setAttribute("id","plateMapHeat_"+id1+"_"+id2);
	el.className = "plateMap";
	var tbody = document.createElement("tbody");
	//tbody.onmouseout=function(){document.getElementById("wellView").style.left="-1000px";}
	if(!hasHeaders){
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
	}
	max = -1000000000;
	min = 1000000000;
	for(var i=0;i<rows.length;i++){
		for(var j=0;j<cols.length;j++){

			try{
				if(isNaN(Math.round(L[i][j] * 100) / 100)){
					span.innerHTML = L[i][j];
				}else{
					theNum = Math.round(L[i][j] * 100) / 100
					if(theNum>max){
						max = theNum;
					}
					if(theNum<min){
						min = theNum;
					}
				}
			}catch(err){}
		}
	}
	for(var i=0;i<rows.length;i++){
		tr = document.createElement("tr");
		if(hasHeaders && i==0){
			continue;
		}
		if(i%2==0){
			tr.className = "even";
		}else{
			tr.className = "odd";
		}
		for(var j=0;j<cols.length;j++){
			td = document.createElement("td");
			td.style.height = "10px";
			span = document.createElement("span");
			span.setAttribute("id","plateMapHeat_"+id1+"_"+id2+"_"+(i+1)+"_"+(j+1));
			try{
				if(isNaN(Math.round(L[i][j] * 100) / 100)){
					//span.innerHTML = L[i][j];
					td.style.backgroundColor = 'rgb(255,255,255)'
				}else{
					theNum = Math.round(L[i][j] * 100) / 100
					theColor = parseInt((((theNum - min) * (255 - 0)) / (max - min)) + 0)
					td.style.backgroundColor = 'rgb('+(255-theColor)+',255,'+(255-theColor)+')'
				}
			}catch(err){}
			td.appendChild(span);
			tr.appendChild(td);
		}
		tbody.appendChild(tr)
	}
	el.appendChild(tbody);
	if(barcode!=""){
		payload22 = {};
		query22 = {"barcode":barcode,"_invType":"plate"}
		payload22["rpp"] = 1;
		payload22["collection"] = "inventoryItems";
		payload22["list"] = true;
		payload22["query"] = query22;
		payload22["action"] = "next";
		restCallAInv("/getList/","POST",payload22,function(bcForm){
			if(bcForm["forms"].length!=0){
				payload2 = {}
				query = {"_invType":"well","parent.id":bcForm["forms"][0].id}
				payload2["rpp"] = 1000;
				payload2["collection"] = "inventoryItems";
				payload2["list"] = true;
				payload2["query"] = query;
				payload2["action"] = "next";
				restCallAInv("/getList/","POST",payload2,function(r){
					listForms = r["forms"];
					for(var i=0;i<listForms.length;i++){
						var fd = listForms[i];
						//alert(JSON.stringify(fd))
						//alert(JSON.stringify(fd.fieldNames));
						compounds = fd.fields[fd.fieldNames.indexOf("Compounds")].value;
						//alert(compounds)
						if(compounds.length){
							loc = fd.fields[fd.fieldNames.indexOf("Location")].value;
							a = document.createElement("a");
							a.innerHTML = document.getElementById("plateMapHeat_"+id1+"_"+id2+"_"+loc["rowPos"]+"_"+loc["colPos"]).innerHTML;
							a.href="javascript:void(0)";
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
									makeForm(fd,"wellView");
									compounds = fd.fields[fd.fieldNames.indexOf("Compounds")].value;
									pl = {"action":"view","collection":"compound","id":compounds[0]["compound_id"],"little":true};
									addObjectForm = restCallInv("/getForm/","POST",pl);
									makeForm(addObjectForm,"wellView");
									$("#wellView").mouseenter(function(){
										$("#wellView").mouseleave(function(){
											$("#wellView").css({'left':-1000+'px'})
										})						
									})
								}
							})(fd);
							cell = document.getElementById("plateMapHeat_"+id1+"_"+id2+"_"+loc["rowPos"]+"_"+loc["colPos"]);
							if(cell){
								cell.innerHTML = '';
								cell.appendChild(a);
							}
						}
					}
				});
			}	
		});
	}	

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
	query = {"_type":"well","parent.id":theForm.id}
	payload2["rpp"] = 1000;
	payload2["collection"] = "assayItems";
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
						handleLink(fd.id,fd.fields[fd.fieldNames.indexOf("_type")].value,showTable,fd.parentTree)
					}
				})(fd);
				a.onmouseover = (function(fd){
					return function(){
						wv = document.getElementById("wellView");
						wv.style.left = (mouse[0]-scrollPos()[0]+6)+"px";
						wv.style.top = (mouse[1]-scrollPos()[1]+6)+"px";
						wv.style.display = "block";
						clearContainer("wellView");
						makeForm(fd,"wellView");
						compounds = fd.fields[fd.fieldNames.indexOf("Compounds")].value;
						pl = {"action":"view","collection":"compound","id":compounds[0]["compound_id"]};
						addObjectForm = restCall("/getForm/","POST",pl);
						makeForm(addObjectForm,"wellView");
						$("#wellView").mouseenter(function(){
							$("#wellView").mouseleave(function(){
								$("#wellView").css({'left':-1000+'px'})
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
		a.href = "javascript:void(0);";
		a.onclick = (function(opts){
			return function(){
				pl = {"action":"view","collection":opts.collection,"id":opts.id};
				addObjectForm = restCall("/getForm/","POST",pl);
				clearContainer("arxOneContainer");
				makeForm(addObjectForm,"arxOneContainer");
			}
		})(opts);
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

function createChildLinksScroller(theForm,theField,id,name,view,useTable){
	el = document.createElement("div");
	el.setAttribute("class","resultSetHolder");
	el.paddingTop = "25px";
	div = document.createElement("div");
	div.style.top = "0px";
	div.style.right = "0px";
	div.className = "resultsPaginationControl";
	theField.position = 0;
	span = document.createElement("span");
	span.setAttribute("id",id+"_arrows");
	a = document.createElement("a");
	a.setAttribute("id",id+"_first");
	a.style.display = "none";
	a.href = "javascript:void(0);";
	a.onclick = (function(theField){
		return function(){
			if(theField.position>0){
				clearContainer(theField.id+"_formHolder");
				theField.position = 0;
				document.getElementById(theField.id+"_position").innerHTML = theField.position + 1;
				if(theField.position>0){
					document.getElementById(theField.id+"_first").style.display = "inline";
					document.getElementById(theField.id+"_prev").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_first").style.display = "none";
					document.getElementById(theField.id+"_prev").style.display = "none";
				}
				if(theField.position<theField.value.length-1){
					document.getElementById(theField.id+"_next").style.display = "inline";
					document.getElementById(theField.id+"_last").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_next").style.display = "none";
					document.getElementById(theField.id+"_last").style.display = "none";
				}
				pl = {"action":"view","collection":theField["options"]["collection"],"id":theField.value[theField.position]["id"]};
				restCallA("/getForm/","POST",pl,function(r){
					r.header = "";
					r.showParentLink = false;
					makeForm(r,theField.id+"_formHolder");
					try{window.scroll(0,findPos(document.getElementById(theField.id+"_formHolder"))-42);}catch(err){}
				});
			}
		}
	})(theField);
	img = document.createElement("img");
	img.src = "images/resultset_first.gif";
	a.appendChild(img);
	span.appendChild(a);
	a = document.createElement("a");
	a.setAttribute("id",id+"_prev");
	a.style.display = "none";
	a.href = "javascript:void(0);";
	a.onclick = (function(theField){
		return function(){
			if(theField.position>0){
				clearContainer(theField.id+"_formHolder");
				theField.position -= 1;
				document.getElementById(theField.id+"_position").innerHTML = theField.position + 1;
				if(theField.position>0){
					document.getElementById(theField.id+"_first").style.display = "inline";
					document.getElementById(theField.id+"_prev").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_first").style.display = "none";
					document.getElementById(theField.id+"_prev").style.display = "none";
				}
				if(theField.position<theField.value.length-1){
					document.getElementById(theField.id+"_next").style.display = "inline";
					document.getElementById(theField.id+"_last").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_next").style.display = "none";
					document.getElementById(theField.id+"_last").style.display = "none";
				}
				pl = {"action":"view","collection":theField["options"]["collection"],"id":theField.value[theField.position]["id"]};
				restCallA("/getForm/","POST",pl,function(r){
					r.header = "";
					r.showParentLink = false;
					makeForm(r,theField.id+"_formHolder");
					try{window.scroll(0,findPos(document.getElementById(theField.id+"_formHolder"))-42);}catch(err){}
				});
			}
		}
	})(theField);
	img = document.createElement("img");
	img.src = "images/resultset_prev.gif";
	a.appendChild(img);
	span.appendChild(a);

	a = document.createElement("a");
	a.href = "javascript:void(0);";
	a.setAttribute("id",id+"_next")
	if(theField.value.length==0){
		a.style.display = "none";
	}
	a.onclick = (function(theField){
		return function(){
			if(theField.position+1<theField.value.length){
				clearContainer(theField.id+"_formHolder");
				theField.position += 1;
				document.getElementById(theField.id+"_position").innerHTML = theField.position + 1;
				if(theField.position>0){
					document.getElementById(theField.id+"_first").style.display = "inline";
					document.getElementById(theField.id+"_prev").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_first").style.display = "none";
					document.getElementById(theField.id+"_prev").style.display = "none";
				}
				if(theField.position<theField.value.length-1){
					document.getElementById(theField.id+"_next").style.display = "inline";
					document.getElementById(theField.id+"_last").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_next").style.display = "none";
					document.getElementById(theField.id+"_last").style.display = "none";
				}
				pl = {"action":"view","collection":theField["options"]["collection"],"id":theField.value[theField.position]["id"]};
				restCallA("/getForm/","POST",pl,function(r){
					r.header = "";
					r.showParentLink = false;
					makeForm(r,theField.id+"_formHolder");
					try{window.scroll(0,findPos(document.getElementById(theField.id+"_formHolder"))-42);}catch(err){}
				});
			}
		}
	})(theField);
	img = document.createElement("img");
	img.src = "images/resultset_next.gif";
	a.appendChild(img);
	span.appendChild(a);
	a = document.createElement("a");
	a.href = "javascript:void(0);";
	a.setAttribute("id",id+"_last");
	if(theField.value.length==0){
		a.style.display = "none";
	}
	a.onclick = (function(theField){
		return function(){
			if(theField.position+1<theField.value.length){
				clearContainer(theField.id+"_formHolder");
				theField.position = theField.value.length-1;
				document.getElementById(theField.id+"_position").innerHTML = theField.position + 1;
				if(theField.position>0){
					document.getElementById(theField.id+"_first").style.display = "inline";
					document.getElementById(theField.id+"_prev").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_first").style.display = "none";
					document.getElementById(theField.id+"_prev").style.display = "none";
				}
				if(theField.position<theField.value.length-1){
					document.getElementById(theField.id+"_next").style.display = "inline";
					document.getElementById(theField.id+"_last").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_next").style.display = "none";
					document.getElementById(theField.id+"_last").style.display = "none";
				}
				pl = {"action":"view","collection":theField["options"]["collection"],"id":theField.value[theField.position]["id"]};
				restCallA("/getForm/","POST",pl,function(r){
					r.header = "";
					r.showParentLink = false;
					makeForm(r,theField.id+"_formHolder");
					try{window.scroll(0,findPos(document.getElementById(theField.id+"_formHolder"))-42);}catch(err){}
				});
			}
		}
	})(theField);
	img = document.createElement("img");
	img.src = "images/resultset_last.gif";
	a.appendChild(img);
	span.appendChild(a);
	
	div.appendChild(span);

	span = document.createElement("span");
	span.setAttribute("id",id+"_position");
	if(theField.value.length>0){
		span.innerHTML = "1";
	}else{
		span.innerHTML = "0";
	}
	div.appendChild(span);
	span = document.createElement("span");
	span.setAttribute("id",id+"_position2");
	span.innerHTML = " of "+(theField.value.length);
	div.appendChild(span);

	span = document.createElement("span");
	span.setAttribute("id",id+"_pipe");
	span.innerHTML = "&nbsp;|&nbsp;";
	div.appendChild(span);
	
	a = document.createElement("a");
	a.appendChild(document.createTextNode("Show Table"))
	a.setAttribute("href","javascript:void(0);");
	a.setAttribute("id",id+"_useTableLink");
	a.onclick = (function(){
		return function(){
			clearContainer(id+"_formHolder");
			createChildLinksScroller(theForm,theField,id,name,view,true);
			$(this).hide();
			$("#"+id+"_arrows").hide();
			$("#"+id+"_position").hide();
			$("#"+id+"_position2").hide();
			$("#"+id+"_pipe").hide();
			$("#"+id+"_useFormLink").show();
		}
	})(theForm,theField,id,name,view)
	div.appendChild(a);

	a = document.createElement("a");
	a.appendChild(document.createTextNode("Show Forms"))
	a.setAttribute("href","javascript:void(0);");
	a.setAttribute("id",id+"_useFormLink");
	a.style.display = "none";
	a.onclick = (function(){
		return function(){
			clearContainer(id+"_formHolder");
			createChildLinksScroller(theForm,theField,id,name,view,false);
			$(this).hide();
			$("#"+id+"_arrows").show();
			$("#"+id+"_position").html("1");
			$("#"+id+"_position").show();
			$("#"+id+"_position2").show();
			$("#"+id+"_pipe").show();
			$("#"+id+"_useTableLink").show();
		}
	})(theForm,theField,id,name,view)
	div.appendChild(a);

	el.appendChild(div);
	div = document.createElement("div");
	div.setAttribute("id",id+"_formHolder");
	el.appendChild(div);
	if(theField.value.length>0){
		pl = {"action":"view","collection":theField["options"]["collection"],"id":theField.value[0]["id"]};
		restCallA("/getForm/","POST",pl,function(r){
			if (useTable){
				tableFields = [];
				results = r.fields[r.fieldNames.indexOf("Results")].value;
				for(var q=0;q<results.length;q++ ){
					tableFields.push(results[q].name)
				}
				ids = [];
				for (var q=0;q<theField.value.length;q++){
					ids.push(theField.value[q]["id"]);
				}
				getList(false,false,{"id":{"$in":ids}},tableFields,id+"_formHolder");
			}else{
				r.header = "";
				r.showParentLink = false;
				makeForm(r,id+"_formHolder");
			}

		});
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
		a.onclick = (function(theField){
			return function(){
				opts = theField["options"];
				blackOn();
				popup = newPopup("linkPopup");
				popup.style.width="850px";
				popup.style.height="600px";
				popup.style.left="150px";
				label = document.createElement("label");
				if(opts.hasOwnProperty("title")){
					label.innerHTML = opts["title"];
				}else{
					label.innerHTML = opts["collection"];
				}
				popup.appendChild(label);
				div = document.createElement("div");
				div.setAttribute("id","popupSearchListTable");
				popup.appendChild(div);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				globalLinkField = theField;
				gettingLink = true;
				theLinkCollection = opts["collection"];
				theQuery = {"_type":opts["collection"]};
				if(opts.hasOwnProperty("extraQuery")){
					theQuery["id"] = opts["extraQuery"]["id"];
				}
				if(opts.hasOwnProperty("byId")){
					getList(false,false,{"parent.id":opts["byId"]},tableFields,"popupSearchListTable");
				}else{
					getList(false,false,theQuery,[],"popupSearchListTable");
				}
			};
		})(theField);
		el.appendChild(a);
	}
	div = buildInnerLinks(theForm,theField,id,view);
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


function buildInnerLinks(theForm,theField,id,view){
	div = document.createElement("div");
	div.setAttribute("id",id+"_links");
	for(var i=0;i<theField.value.length;i++){
		div2 = document.createElement("div")
		opts = theField.value[i];
		a = document.createElement("a");
		if(opts["linkText"]!=""){
			a.innerHTML = opts["linkText"];
		}else{
			a.innerHTML = "Untitled"
		}
		a.href='javascript:void(0);';
		a.onclick = (function(opts){
			return function(){
				if(opts["_type"]==undefined){
					opts["_type"] = opts["collection"];
				}
				handleLink(opts["id"],opts["_type"],false)
			}
		})(opts);
		div2.appendChild(a);
		if(!view||1==1){
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
	return div;
}

function resizeIframe(iframeId) { 
	var the_height= document.getElementById(iframeId).contentWindow.document.body.scrollHeight; 
	document.getElementById(iframeId).height= the_height;
}

function makeSearch(containerId){
	clearContainer(containerId);
	searchDiv = document.createElement("div");
	searchDiv.setAttribute("id","searchDiv");
	searchDiv.className = "ax1-searchHolderDiv";
	h1 = document.createElement("h1");
	h1.innerHTML = "Search";
	h1.style.paddingBottom = "5px";
	searchDiv.appendChild(h1);
	//iframe = document.createElement("iframe");
	//iframe.src = "ajaxSearchChemBox.asp?chemTable="+chemTable+"&chemSearchDbName="+chemSearchDbName+"&chemSearchDbName2="+chemSearchDbName2;
	//iframe.setAttribute("height","250");
	//iframe.className = "ax1-chemSearchFrameBox";
	//iframe.setAttribute("id","tempChemSearchFrame");
	//iframe.setAttribute("frameborder","0")
	//searchDiv.appendChild(iframe);
	iframeSearch = document.createElement("iframe");
	iframeSearch.src = "ajaxSearchAdv.asp?chemTable="+chemTable+"&chemSearchDbName="+chemSearchDbName+"&chemistryFrameId="+"tempChemSearchFrame"+"&chemSearchDbName2="+chemSearchDbName2;
	iframeSearch.setAttribute("height","40");
	iframeSearch.className = "ax1-advSearchFrame";
	iframeSearch.id = "advSearchFrame";
	resizeIframeInterval = window.setInterval("resizeIframe('advSearchFrame')",100);
	loadFunction = function(){
		pl = {
				'action':'next',
				'rpp':1000,
				'collection':'assayItems',
				'list':true,
				'query':{'_type':'resultDefinition'}
		};
		resultDefs = restCall("/getList/","POST",pl)["forms"];
		searchFieldList = []
		searchFieldList.push({name:"name",fName:"Result Set Name",type:"text"})
		for(var i=0;i<resultDefs.length;i++){
			fd = resultDefs[i];
			fieldName = fd.fields[fd.fieldNames.indexOf("Name")].value;
			dataType = fd.fields[fd.fieldNames.indexOf("Type")].value;
			if(dataType=="Text"){
				dataType = "text";
			}else{
				if(dataType=="Date"){
					dataType = "date";
				}else{
					dataType = "actual_number";
				}
			}
			searchFieldList.push({name:fieldName,fName:fieldName,type:dataType,resultDefinition:true})
		}
		document.getElementById("advSearchFrame").contentWindow.searchFieldList = searchFieldList
		//alert(JSON.stringify(resultDefs))
		//document.getElementById("advSearchFrame").contentWindow.searchFieldList = [
		//	{name:"name",fName:"Name",type:"text"},
		//	{name:"barcode",fName:"Barcode",type:"text"},
		//	{name:"purity",fName:"Purity",type:"actual_number"},
		//	{name:"supplier",fName:"Supplier",type:"text"},
		//	{name:"supplierCode",fName:"Supplier Catalog Number",type:"text"},
		//	{name:"initialAmount",fName:"Initial Amount",type:"actual_number"},
		//	{name:"amount",fName:"Amount",type:"actual_number"},
		//	{name:"units",fName:"Units",type:"text",options:[["kg","kg"],["g","g"],["mg","mg"],["bottles","bottles"],["gal","gal"],["L","L"],["ml","ml"],["mm","mm"]]},
		//	{name:"casNumber",fName:"CAS Number",type:"text"},
		//	{name:"molFormula",fName:"Mol Formula",type:"text"},
		//	{name:"molWeight",fName:"Mol Weight",type:"actual_number"},
		//	{name:"chemicalName",fName:"Chemical Name",type:"text"},
		//	{name:"userAddedInitial.userName",fName:"User Added",type:"text"}
		//];
	}
	if(iframeSearch.attachEvent) {
		iframeSearch.attachEvent('onload',loadFunction);
	}else{
		iframeSearch.onload = loadFunction;
	}
	searchDiv.appendChild(iframeSearch);
	searchButton = document.createElement("input");
	searchButton.setAttribute("type","button");
	searchButton.setAttribute("id","searchButton");
	searchButton.value = "Search";
	searchButton.onclick = function(){
		document.getElementById("searchButton").value="Loading...";
		document.getElementById("advSearchFrame").contentWindow.finalizeSearch();
		try{
			el=document.getElementById('listTable');
			el.parentNode.removeChild(el);
		}catch(err){}
		//tableFields = ["Name","Structure","Amount","Unit Type","Supplier","CAS Number"];
		tableFields = [];
		document.getElementById("advSearchFrame").contentWindow.loadSearch().then(function (theSearch) {
			getList(false, false, theSearch, tableFields);
			try { window.scroll(0, findPos(document.getElementById("listTable"))); } catch (err) { }
		});
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

function saveForm(fd,remove){
	var payload = {'formId':fd.fid,'remove':remove};
	return restCall("/saveForm/","POST",payload);
}

function deleteForm(fd){
	var payload = {'formId':fd.fid};
	return restCall("/deleteForm/","POST",payload);
}

function validateField(theField){
	fieldValid = true;
	if(theField.required){
		if(theField.value==""){
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
	for(var i=0;i<fd.fields.length;i++){
		if(!validateField(fd.fields[i])){
			formValid = false;
		}
	}
	return formValid;
}

function makeForm(fd,containerId){
	if (containerId !='arxOneContainer'){
		noHistory=true;
	}
	formDiv = document.createElement("div");
	formDiv.setAttribute("class","invPopupDiv invPopupDivResults");
	if (fd.header!=""){
		h1 = document.createElement("h1");
		h1.innerHTML = fd.header;
		formDiv.appendChild(h1)
	}
	if(fd.parent&&fd.view&&(showParentLinks||fd.showParentLink)){
		a = document.createElement("a");
		a.href = "javascript:void(0)";
		a.innerHTML = "Parent";
		a.onclick = (function(fd){
			return function(){
				handleLink(fd.parent.id,"resultSet",false)
			}
		})(fd);
		formDiv.appendChild(a);
	}
	form = document.createElement("form");
	form.setAttribute("id",fd.fid);
	form.setAttribute("name",fd.fid);
	fields = fd["fields"];
	for(var i=0;i<fields.length;i++ ){
		thisField = fields[i];
		fieldId = thisField["id"];

		if(thisField.startGroup){
			groupH2 = document.createElement("h2");
			groupH2.appendChild(document.createTextNode(thisField.startGroup));
			groupH2.style.marginTop = "10px";
			groupH2.style.marginBottom = "5px";
			form.appendChild(groupH2)
		}

		thisLabel = document.createElement("label");
		labelText = thisField["formName"];
		if(thisField.required){
			labelText += "*";
		}
		thisLabel.appendChild(document.createTextNode(labelText));
		thisLabel.setAttribute("for",fieldId);
		if(thisField["fieldType"]=="text"){
			if (!fd["view"]){
				thisEl = createTextBox(fd,thisField,fieldId,fieldId);
			}else{
				thisEl = showText(fd,thisField,fieldId,fieldId);
			}
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="password"){
			if (!fd["view"]){
				thisEl = createPasswordBox(fd,thisField,fieldId,fieldId);
			}else{
				thisEl = document.createElement("span");
			}
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="textarea"){
			if (!fd["view"]){
				thisEl = createTextArea(fd,thisField,fieldId,fieldId)
			}else{
				thisEl = showText(fd,thisField,fieldId,fieldId)
			}
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"] == "select"){
			if (!fd["view"]){
				thisEl = createSelect(fd,thisField,fieldId,fieldId)
			}else{
				thisEl = showText(fd,thisField,fieldId,fieldId)
			}
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"] == "checkbox"){
			if (!fd["view"]){
				thisEl = createCheckBox(fd,thisField,fieldId,fieldId)
			}else{
				thisEl = showText(fd,thisField,fieldId,fieldId)
			}
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"] == "userInfo"){
			thisEl = showText(fd,thisField,fieldId,fieldId,thisField.displayKey)
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"] == "date"){
			thisEl = showText(fd,thisField,fieldId,fieldId)
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="chem"){
			createChemBox(fd, thisField, fieldId, fieldId).then(function (el) {
				thisEl = el;
				thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
				thisEl.className += " ax1-"+thisField["fieldType"];
				form.appendChild(thisLabel);
				form.appendChild(thisEl);
			});
		}
		if(thisField["fieldType"]=="addChildLink"){
			thisEl = createAddChildLink(fd,thisField,fieldId,fieldId)
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="showChildLinks"){
			thisEl = createShowChildLinks(fd,thisField,fieldId,fieldId)
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="childLinks2"){
			if (thisField.options.scroller){
				thisEl = createChildLinksScroller(fd,thisField,fieldId,fieldId,fd["view"]);
			}else{
				thisEl = createChildLinks2(fd,thisField,fieldId,fieldId,fd["view"])
			}
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			if(thisField.options.scroller){
				thisLabel.className += " resultSetLabel";
			}
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="file"){
			thisEl = createFileBox(fd,thisField,fieldId,fieldId)
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="multiText"){
			if (!fd["view"]){
				thisEl = createMultiText(fd,thisField,fieldId,fieldId)
			}else{
				thisEl = showText(fd,thisField,fieldId,fieldId)
			}
			thisLabel.className += "ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="plateMap"){
			thisEl = createPlateMap(fd,thisField,fieldId,fieldId)
			thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="button"){
			if (!fd["view"]){
				thisEl = createButton(fd,thisField,fieldId,fieldId)
			}
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]=="actionButton"){
			thisEl = createActionButton(fd,thisField,fieldId,fieldId,containerId)
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisEl);
		}
		if(thisField["fieldType"]!="generated"){
			span = document.createElement("span");
			span.className = "itemError";
			span.className += "ax1-"+thisField["fieldType"]+"-error";
			span.setAttribute("id",fieldId+"_error");
			form.appendChild(span);
			//br = document.createElement("br")
			//form.appendChild(br)
		}
		//invPerm
		if(thisField["fieldType"]=="permissions"){
			thisEl = createPermissions(fd,thisField,fieldId,fieldId,fd["view"])
			thisEl.className += "ax1-text"
			thisLabel.className += " ax1-text-label";
			thisLabel.style.marginTop = "0px";
			thisLabel.style.width = "228px";
			thisEl.className += " ax1-"+thisField["fieldType"];
			form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
		//end invPerm
		if(thisField["fieldType"]=="results"){
			thisEl = createResults(fd,thisField,fieldId,fieldId)
			//thisLabel.className += " ax1-"+thisField["fieldType"]+"-label";
			thisEl.className += " ax1-"+thisField["fieldType"];
			//form.appendChild(thisLabel);
			form.appendChild(thisEl);
		}
	}
	if (!fd["view"]){
		theButton = document.createElement("input");
		theButton.setAttribute("type","button");
		theButton.setAttribute("id",fd.fid+"_submit");
		theButton.setAttribute("name",fd.fid+"_submit");
		theButton.setAttribute("value",fd["submitButtonText"])
		theButton.onclick = fd.onSave;
		theButton.style.display = "block";
		form.appendChild(theButton);
	}else{
		if(canEdit){
			goAhead = false
			if(fd.fieldNames.indexOf("_type")!=-1){
				goAhead = fd.fields[fd.fieldNames.indexOf("_type")].value=="joinFields" || fd.fields[fd.fieldNames.indexOf("_type")].value=="templateField" || fd.fields[fd.fieldNames.indexOf("_type")].value=="assay" || fd.fields[fd.fieldNames.indexOf("_type")].value=="assayGroup" || fd.fields[fd.fieldNames.indexOf("_type")].value=="protocol"  || fd.fields[fd.fieldNames.indexOf("_type")].value=="resultSet"
			}
			if(goAhead){
				theButton = document.createElement("input");
				theButton.setAttribute("type","button");
				theButton.setAttribute("id",fd.fid+"_submit");
				theButton.setAttribute("name",fd.fid+"_submit");
				theButton.setAttribute("value","EDIT")
				theButton.style.display = "block";
				theButton.onclick = function(){
					pl = {"action":"edit","collection":fd.fields[fd.fieldNames.indexOf("_type")].value,"id":fd.id};
					addObjectForm = restCall("/getForm/","POST",pl);
					formBucket.push(addObjectForm);
					containerName = "arxOneContainer"
					addObjectForm.onSave = function(fd,node){
						return function(){
							if(validateForm(fd)){
								saveForm(fd,true);
								updateTableValues(fd,true);
								clearContainer(containerName);
								if(containerName=="arxOneContainer"){
									pl = {"action":"view","collection":fd.fields[fd.fieldNames.indexOf("_type")].value,"id":fd.id};
									addObjectForm = restCall("/getForm/","POST",pl);								
									makeForm(addObjectForm,containerName);
								}
								removeForm(fd.fid);
							}
						}
					}(addObjectForm,node);
					clearContainer(containerName);
					makeForm(addObjectForm,containerName);
				};
				form.appendChild(theButton);
			}
		}
	}
	if(fd.userInfo.canDelete && (fd.fields[fd.fieldNames.indexOf("_type")].value=="resultSet"||fd.fields[fd.fieldNames.indexOf("_type")].value=="templateField"||fd.fields[fd.fieldNames.indexOf("_type")].value=="joinFields")){
		theButton = document.createElement("input");
		theButton.setAttribute("type","button");
		theButton.setAttribute("id",fd.fid+"_delete");
		theButton.setAttribute("name",fd.fid+"_delete");
		theButton.setAttribute("value","Delete");
		theButton.style.display = "block";
		theButton.onclick = function(){
			parentId = fd.parent.id
			deleteForm(fd);
			clearContainer("arxOneContainer")
			var tree = $("#tree").dynatree("getTree");
			node = tree.getNodeByKey(parentId.toString())
			if(node){
				node.reloadChildren();
			}
			pl = {"action":"view","collection":"assayItems","id":parentId};
			addObjectForm = restCall("/getForm/","POST",pl);								
			makeForm(addObjectForm,'arxOneContainer');
		}
		form.appendChild(theButton);
	}
	formDiv.appendChild(form);
	expireDiv = document.createElement("div");
	expireDiv.setAttribute("id",fd.fid+"_expires");
	expireDiv.className = "expireDiv";
	formDiv.appendChild(expireDiv);
	countdown = function(){
		if (fd.timeout>0){
			fd.timeout -= 1;
			document.getElementById(fd.fid+"_expires").innerHTML = "Form expires: "+fd.timeout.toString().toHHMMSS()+"<br/>"+JSON.stringify(fd);
		}else{
			document.getElementById(fd.fid+"_expires").innerHTML = "Form expires: expired<br/>"+JSON.stringify(fd);
		}
	};
	//window.setInterval(countdown,1000);

	document.getElementById(containerId).appendChild(formDiv);
	$(".resultsPaginationControl").css("position","static").css("position","relative");
}


function editTableTDs(fd,field,tr){
	td = document.createElement("td");
	assayType = "";
	if(field.assayType == "Reg Id"){
		assayType = field.assayType;
	}
	if(field.fieldType!="showChildLinks"&&field.fieldType!="chem"&&assayType!="Reg Id"){
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
		if(field.dbName==fd.tableLinkName || field.formName==fd.tableLinkName){
			if(field.value==""){
				span.innerHTML = "Untitled";
			}
			a = document.createElement("a");
			a.setAttribute("id",field.id+"_table_link")
			if(!inFrame){
				if(dontRefreshTableLink){
					a.href = "javascript:void(0);";
					if(gettingLink){
						a.onclick = (function(fd){
							return function(){
								if(fd.fields[fd.fieldNames.indexOf("_type")].value==theLinkCollection){
									r = {"collection":fd.fields[fd.fieldNames.indexOf("_type")].value,"linkText":fd.fields[fd.fieldNames.indexOf("Name")].value,"id":fd.id};
									globalLinkField.value.push(r);
									outter = document.getElementById(globalLinkField.id);
									inner = document.getElementById(globalLinkField.id+"_links");
									inner.parentNode.removeChild(inner);
									outter.appendChild(buildInnerLinks(fd,globalLinkField,globalLinkField.id,false));
									globalLinkField.onchange();
									gettingLink = false;
									theLinkCollection = "";
									el = document.getElementById("popupSearchListTable");
									el.parentNode.removeChild(el);
									el = document.getElementById("linkPopup");
									el.parentNode.removeChild(el);
									blackOff();
								}else{
									getList(false,false,{"parent.id":fd.id},tableFields,"popupSearchListTable");
								}
							}
						})(fd);						
					}else{
						a.onclick = (function(fd){
							return function(){
								showTable = false;
								if(fd.fieldNames.indexOf("_numChildren")!=-1){
									if(fd.fields[fd.fieldNames.indexOf("_numChildren")].value>0){
										showTable = true;
									}
								}
								handleLink(fd.id,fd.fields[fd.fieldNames.indexOf("_type")].value,showTable,fd.parentTree)
							}
						})(fd);
					}
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
	}
	if(field.fieldType=="showChildLinks"){
		el = createShowChildLinks(fd,field,field.id,field.id)
		td.appendChild(el);
	}
	if(field.fieldType=="chem"){
		createTableChemBox(fd, field, field.id + "_tn", field.id + "_tn").then(function (el) {
			td.appendChild(el);
		});
	}
	if(assayType=="Reg Id"){
		el = document.createElement("div");
		iFrame = document.createElement("iframe");
		iFrame.setAttribute("id",field.id+"_frame");
		iFrame.setAttribute("name",field.id+"_frame");
		iFrame.setAttribute("src","regChemBox.asp?readonly=true&w=130&h=130&regNumber="+field.value+"&name="+field.id)
		iFrame.setAttribute("width",130);
		iFrame.setAttribute("height",130);
		el.appendChild(iFrame);
		el.appendChild(document.createElement("br"));
		a = document.createElement("a");
		a.href = "../registration/showRegItem.asp?regNumber="+field.value;
		a.innerHTML = field.value;
		a.setAttribute("target","new")
		el.appendChild(a)
		td.appendChild(el);
	}
	return td;
}


function makeEditTable(fds,containerId,fixedFields){
	tableFds = fds;
	tableFixedFields = fixedFields;
	numCols = 0;
	table = document.createElement("table");
	table.setAttribute("id","listTable")
	table.className = "experimentsTable"
	table.style.width="95%";
	tBody = document.createElement("tBody");
	table.appendChild(tBody);
	if(fds.length>0){
		tr = document.createElement("tr");
		th = document.createElement("th");
		tr.appendChild(th);
		if(fixedFields.length){
			console.log("this")
			for(var i=0;i<fixedFields.length;i++){
				th = document.createElement("th");
				th.innerHTML = fixedFields[i];
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
		tBody.appendChild(tr);
		cursorIdPing = fds[0].cursorData.cursorId;
	}
	console.log(fds.length)
	for (var i=0;i<fds.length;i++)
	{
		console.log("what1")
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
				editTR.className = 'arxOneExpandedRow';
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
		td.appendChild(img);
		h = document.createElement("input");
		h.setAttribute("type","hidden");
		h.setAttribute("id",fd.fid+"_edit_loaded");
		h.value = 0;
		td.appendChild(h);
		tr.appendChild(td);
		if(fixedFields.length){
			for(var j=0;j<fixedFields.length;j++){
				fieldName = fixedFields[j];
				if(fd.fieldNames.indexOf(fieldName)==-1){
					tr.appendChild(document.createElement("td"));
				}else{
					tr.appendChild(editTableTDs(fd,fields[fd.fieldNames.indexOf(fieldName)],tr))
				}
			}
		}else{
			for(var j=0;j<fields.length;j++){
				if(fields[j].inTable){
					tr.appendChild(editTableTDs(fd,fields[j],tr))
				}
			}
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
		console.log("what2")
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
			a.onclick = function(){
				getList(fd.cursorData.cursorId,"first",false,fixedFields,containerId);
			};
			img = document.createElement("img");
			img.src = "images/resultset_first.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		if(fd.cursorData.hasPrev){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = function(){
				getList(fd.cursorData.cursorId,"prev",false,fixedFields,containerId);
			};
			img = document.createElement("img");
			img.src = "images/resultset_prev.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		if(fd.cursorData.hasNext){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = function(){
				getList(fd.cursorData.cursorId,"next",false,fixedFields,containerId);
			};
			img = document.createElement("img");
			img.src = "images/resultset_next.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		if(fd.cursorData.hasLast){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = function(){
				getList(fd.cursorData.cursorId,"last",false,fixedFields,containerId);
			};
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
		el=document.getElementById('listTable');
		el.parentNode.removeChild(el);
	}catch(err){}
	console.log(containerId)
	console.log("what3")
	document.getElementById(containerId).appendChild(table);
}