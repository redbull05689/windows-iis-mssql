node = null;

//add forEach prototype to arrays.
//calls supplied function with each iteration
if ( !Array.prototype.forEach ) {
    Array.prototype.forEach = function(fn, scope) {
        for(var i = 0, len = this.length; i < len; ++i) {
            fn.call(scope, this[i], i, this);
        }
    }
}

//add indexOf prototype to array
//returns the index of the specified argument
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

//split querystring key value pairs into a JavaScript object 
function qs() {
    var result = {}, keyValuePairs = location.search.slice(1).split('&');

    keyValuePairs.forEach(function(keyValuePair) {
        keyValuePair = keyValuePair.split('=');
        result[keyValuePair[0]] = keyValuePair[1] || '';
    });

    return result;
}

//send a rest call/request to the server.
//requests to CherryPy are 'proxied' by ASP with invp.asp script
//invp.asp passes handles authentication and forwards the request to CherryPy
function restCall(url,verb,data,returnType){
	var form;
	//always add connectionId of user.  Used inside CherryPy to maintain state and manage permission
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}

	data = JSON.stringify(data);

	//make request
	var retVal; 
	$.ajax({
		url: "invp.asp",
		type: 'POST',
		dataType: 'json',
		data: {
				verb: (verb),
				url: (url),
				data: (data),
		},
		async: false
	}).done(function(response) {
		if (response == ""){
			//return javascript object
			retVal = JSON.parse("{}");
		}else{
			if (returnType == "text/plain"){
				//return text object if specified
				retVal = response;
			}else{
				//return javascript object
				retVal = (response);
			}

		}
	}).fail(function(response) {
		retVal = false;
	});

	if (retVal == null)
	{
		return false
	} 
	return retVal

}

//asynchronous rest call/request to CherryPy same as above, but async and calls a callback function when done
function restCallA(url,verb,data,cb,returnType){
	var form;
	//always add connectionId of user.  Used inside CherryPy to maintain state and manage permission
	data["connectionId"] = connectionId;
	if (window.XMLHttpRequest){
		client = new XMLHttpRequest();              
	}else{                                  
		client = new ActiveXObject("Microsoft.XMLHTTP");
	}

	//make request
	form = "url="+encodeURIComponent(url)+"&verb="+encodeURIComponent(verb)+"&data="+encodeURIComponent(JSON.stringify(data));
	client.onreadystatechange=(function(client,cb,returnType){
		return function(){
			//call readystate manager function
			restCallACb(client,cb,returnType);
		}
	})(client,cb,returnType);
	client.open("POST", "invp.asp", true);
	client.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	client.send(form);
	return false;
}

function restCallACb(client,cb,returnType){
	if (client.readyState == 4){
		if (client.status == 200){
			//http OK
			if (client.responseText == ""){
				//call callback with JavaScript object
				cb(JSON.parse("{}"));
			}else{
				if (returnType == "text/plain"){
					//call callback with string
					cb(client.responseText);
				}else{
					//call callback with Javascript object
					cb(JSON.parse(client.responseText));
				}
			}
		}else{
			return false;
		}
	}
}


function createChildLinksScroller(theForm,theField,id,name,view,useTable){
	//create scroller div for results on result sets
	
	//create wrapper div
	el = document.createElement("div");
	el.setAttribute("class","resultSetHolder");
	el.paddingTop = "25px";

	//create record navigation button holder
	div = document.createElement("div");
	div.className = "resultsPaginationControl";

	//set initial position to 0
	theField.position = 0;

	//create span to hold navigation buttons and page info text
	span = document.createElement("span");
	span.setAttribute("id",id+"_arrows");

	//create link that goes to the beginning of the results
	a = document.createElement("a");
	a.setAttribute("id",id+"_first");
	a.style.display = "none";
	a.href = "javascript:void(0);";
	a.onclick = (function(theField){
		return function(){
			//only show if we are not already on the first result
			if(theField.position>0){
				//clear the result container and set the position to 0 (first record)
				clearContainer(theField.id+"_formHolder");
				theField.position = 0;
				document.getElementById(theField.id+"_position").innerHTML = theField.position + 1;

				//if we are not on the first record show the previous and first links
				if(theField.position>0){
					document.getElementById(theField.id+"_first").style.display = "inline";
					document.getElementById(theField.id+"_prev").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_first").style.display = "none";
					document.getElementById(theField.id+"_prev").style.display = "none";
				}
				//if we are not on the last record show the next and last links
				if(theField.position<theField.value.length-1){
					document.getElementById(theField.id+"_next").style.display = "inline";
					document.getElementById(theField.id+"_last").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_next").style.display = "none";
					document.getElementById(theField.id+"_last").style.display = "none";
				}
				//show the first result
				makeForm(theField.value[theField.position],id,"view");
			}
		}
	})(theField);
	//add image and append to span
	img = document.createElement("img");
	img.src = "images/resultset_first.gif";
	a.appendChild(img);
	span.appendChild(a);

	//create link that goes to the previous record in the results
	a = document.createElement("a");
	a.setAttribute("id",id+"_prev");
	a.style.display = "none";
	a.href = "javascript:void(0);";
	a.onclick = (function(theField){
		return function(){
			if(theField.position>0){
				//clear the result container and decrement the position by 1
				clearContainer(theField.id+"_formHolder");
				theField.position -= 1;
				document.getElementById(theField.id+"_position").innerHTML = theField.position + 1;

				//if we are not on the first record show the previous and first links
				if(theField.position>0){
					document.getElementById(theField.id+"_first").style.display = "inline";
					document.getElementById(theField.id+"_prev").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_first").style.display = "none";
					document.getElementById(theField.id+"_prev").style.display = "none";
				}

				//if we are not on the last record show the next and last links
				if(theField.position<theField.value.length-1){
					document.getElementById(theField.id+"_next").style.display = "inline";
					document.getElementById(theField.id+"_last").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_next").style.display = "none";
					document.getElementById(theField.id+"_last").style.display = "none";
				}
				makeForm(theField.value[theField.position],id,"view");
			}
		}
	})(theField);
	//add image and append to span
	img = document.createElement("img");
	img.src = "images/resultset_prev.gif";
	a.appendChild(img);
	span.appendChild(a);

	//create link that goes to the next record in the results
	a = document.createElement("a");
	a.href = "javascript:void(0);";
	a.setAttribute("id",id+"_next")
	if(theField.value.length==0){
		a.style.display = "none";
	}
	a.onclick = (function(theField){
		return function(){
			if(theField.position+1<theField.value.length){
				//clear the result container and increment the position by 1
				clearContainer(theField.id+"_formHolder");
				theField.position += 1;
				document.getElementById(theField.id+"_position").innerHTML = theField.position + 1;

				//if we are not on the first record show the previous and first links
				if(theField.position>0){
					document.getElementById(theField.id+"_first").style.display = "inline";
					document.getElementById(theField.id+"_prev").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_first").style.display = "none";
					document.getElementById(theField.id+"_prev").style.display = "none";
				}

				//if we are not on the last record show the next and last links
				if(theField.position<theField.value.length-1){
					document.getElementById(theField.id+"_next").style.display = "inline";
					document.getElementById(theField.id+"_last").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_next").style.display = "none";
					document.getElementById(theField.id+"_last").style.display = "none";
				}
				makeForm(theField.value[theField.position],id,"view");
			}
		}
	})(theField);
	//add image and append to span
	img = document.createElement("img");
	img.src = "images/resultset_next.gif";
	a.appendChild(img);
	span.appendChild(a);

	//create link that goes to the last record in the results
	a = document.createElement("a");
	a.href = "javascript:void(0);";
	a.setAttribute("id",id+"_last");
	if(theField.value.length==0){
		a.style.display = "none";
	}
	a.onclick = (function(theField){
		return function(){
			if(theField.position+1<theField.value.length){
				//clear the result container and set position to the last position
				clearContainer(theField.id+"_formHolder");
				theField.position = theField.value.length-1;
				document.getElementById(theField.id+"_position").innerHTML = theField.position + 1;

				//if we are not on the first record show the previous and first links
				if(theField.position>0){
					document.getElementById(theField.id+"_first").style.display = "inline";
					document.getElementById(theField.id+"_prev").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_first").style.display = "none";
					document.getElementById(theField.id+"_prev").style.display = "none";
				}

				//if we are not on the last record show the next and last links
				if(theField.position<theField.value.length-1){
					document.getElementById(theField.id+"_next").style.display = "inline";
					document.getElementById(theField.id+"_last").style.display = "inline";
				}else{
					document.getElementById(theField.id+"_next").style.display = "none";
					document.getElementById(theField.id+"_last").style.display = "none";
				}
				makeForm(theField.value[theField.position],id,"view");
			}
		}
	})(theField);
	//add image and append to span
	img = document.createElement("img");
	img.src = "images/resultset_last.gif";
	a.appendChild(img);
	span.appendChild(a);
	
	//append span to pagination holder div
	div.appendChild(span);

	//create span that shows "x of y results" and append to pagination holder div
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

	//append pagination control to result holder div
	el.appendChild(div);
	div = document.createElement("div");
	div.setAttribute("id",id+"_formHolder");
	el.appendChild(div);

	//show first result
	if(theField.value.length>0){
		afterScroller = (function(thisId){
			return function(){
				makeForm(thisId,"resultsHolderInner","view");
			}
		})(theField.value[0])
	} else {
		// if there are no results
		div.textContent = "No Result Data";
		afterScroller = function(){};
	}
	return el;
}

function resizeIframe(iframeId) {
	//resize iframe to its internal height
	var the_height= document.getElementById(iframeId).contentWindow.document.body.scrollHeight; 
	document.getElementById(iframeId).height= the_height;
}

function makeForm(id,containerId,viewState){
	//takes a form object and displays the form

	//empty the target container
	$("#"+containerId).empty();
	//get form from cache and display with the specified view state
	var f = new Form(getCache(id));
	f.show(containerId,viewState)
	if(f.fd.typeId!=2113){
		handleNodeReloads([id],[],false,$("#tree").dynatree("getTree"))
	}
}

function makeEditTable(ids,containerId){
	//make a table view for a cursor list view

	//empty the target container
	$("#"+containerId).empty();
	numCols = 0;

	//create the table
	table = document.createElement("table");
	table.setAttribute("id","listTable")
	table.className = "experimentsTable"
	table.style.width="95%";
	tBody = document.createElement("tBody");
	table.appendChild(tBody);
	tableNames = [];
	tableLinkFieldName = "XXXXXXXXXXXXXXXXX";

	//if ids is not empty create the appropriate header row for the table
	if(ids.length>0){
		tr = document.createElement("tr");
		//get a form from the first id and add all of the names of the fields that are inTable to header rows
		var f1 = new Form(getCache(ids[0]))
		var f2 = new Form(getCache(f1.fd.typeId))
		$.each(f2.getFieldByName('fields').fields,function(i,field){
			if(field.getFieldByName('inTable').value){
				th = document.createElement("th");
				tableName = field.getFieldByName('name').value
				th.innerHTML = tableName;
				tableNames.push(tableName)
				tr.appendChild(th);
				numCols +=1				
			}
			//set table link name
			if(field.getFieldByName('isTableLink').value){
				tableLinkFieldName = field.getFieldByName('name').value;
			}
		});
		tBody.appendChild(tr);
		cursorIdPing = cursorData.cursorId;
	}
	//loop through all ides
	for (var i=0;i<ids.length;i++){
		//make tr for earch record
		tr = document.createElement("tr");
		var f3 = new Form(getCache(ids[i]));
		//make a td for each appropriate field
		for (var j=0;j<tableNames.length;j++){
			td = document.createElement("td");
			thisField = f3.getFieldByName(tableNames[j])
			if (thisField){
				//create link if field should like
				if(tableNames[j]==tableLinkFieldName){
					a = document.createElement("a");
					a.innerHTML = thisField.value;
					a.href = "javascript:void(0)";
					a.onclick = (function(theId){
						return function(){
							var ff = new Form(getCache(theId))
							if(ff.fd.showTable){
								//if the target should show a table, show a table
								getList(false,false,{"parentId":parseInt(theId)},false)
							}else{
								//otherwise view the target
								makeForm(theId,"arxOneContainer","view");
							}
						}
					})(f3.fd.id)
					td.appendChild(a)
				}else{
					td.innerHTML = thisField.value;
				}
			}
			tr.appendChild(td)
		}
		tBody.appendChild(tr);
	}
	//add navigation row
	tr = document.createElement("tr");
	td = document.createElement("td");
	//set colspan to number of columns added
	td.setAttribute("colspan",numCols);
	td.colSpan = numCols;
	td.setAttribute("align","right");
	if (ids.length){
		//create pagination span
		span = document.createElement("span");
		//add page number info display
		span.innerHTML = "page "+cursorData.page+" of "+cursorData.pages+", total results: "+cursorData.count;
		td.appendChild(span);
		//create first link if the cursor says ok
		if(cursorData.hasFirst){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = function(){
				getList(cursorData.cursorId,"first",false,false,containerId);
			};
			img = document.createElement("img");
			img.src = "images/resultset_first.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		//create prev link if the cursor says ok
		if(cursorData.hasPrev){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = function(){
				getList(cursorData.cursorId,"prev",false,false,containerId);
			};
			img = document.createElement("img");
			img.src = "images/resultset_prev.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		//create next link if the cursor says ok
		if(cursorData.hasNext){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = function(){
				getList(cursorData.cursorId,"next",false,false,containerId);
			};
			img = document.createElement("img");
			img.src = "images/resultset_next.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
		//create last link if the cursor says ok
		if(cursorData.hasLast){
			a = document.createElement("a");
			a.href = "javascript:void(0);";
			a.onclick = function(){
				getList(cursorData.cursorId,"last",false,false,containerId);
			};
			img = document.createElement("img");
			img.src = "images/resultset_last.gif";
			a.appendChild(img);
			td.appendChild(a);
		}
	}else{
		//if empty display no results message
		span = document.createElement("span");
		span.innerHTML = "Search returned no results";
		td.appendChild(span);
	}
	tr.appendChild(td);
	tBody.appendChild(tr);
	//remove previous table
	try{
		el=document.getElementById('listTable');
		el.parentNode.removeChild(el);
	}catch(err){}
	document.getElementById(containerId).appendChild(table);
}