<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Assay"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->
<link rel="stylesheet" type="text/css" href="css/index-css.css" />

<div id="arxOneContainer">

</div>

<div id="arxTwoContainer">

</div>

<script type="text/javascript">
formBucket = [];
searchFieldList = [];

/**
 * Function to retrieve pdf file content and embed it into html control
 * @param fileId id of the file to download
 * @param sender reference to iframe control that will receive pdf data
 */
function getFileLink(fileId, sender) {

    var url = "getSourceFile.asp?fileId=" + fileId;

    $.ajax({
        url: url,
        type: 'get',
        contentType: true,
        processData: false,
        encoding: null,
        headers: {
            accept: 'application/json'
        },
        beforeSend: function (request) {
            request.overrideMimeType('text/plain; charset=x-user-defined');
        },
        success: function (response) {
            var i = 0;
            var dataArray = new Uint8Array(response.length);
            for (; i < response.length; i++) {
				dataArray[i] = response.charCodeAt(i);
            }

            var blob = new Blob([dataArray.buffer], {
                type: "application/pdf"
            });

			sender.setAttribute("src", URL.createObjectURL(blob));
            sender.onload = null;
        },
    });
}

	

function getList(cursorId,action,query,fixedFields,containerName){
	//gets cursor from database by query

	//set to default container if container name not provided
	if(containerName==undefined){
		containerName = "arxOneContainer";
	}
	payload = {};

	//use cursor id if we are still using a previous cursor
	//e.g. we are paging through a table
	if(cursorId){
		payload["cursorId"] = cursorId;
	}
	//set results per page
	payload["rpp"] = 10;
	//if no action is provided, next will show us the first page
	if(!action){
		payload["action"] = "next";
	}else{
		payload["action"] = action;
	}
	if(!query){
		query = {};
	}
	payload["list"] = true;
	payload["query"] = query;
	//make request lazy
	restCallA("/getList/","POST",payload,function(r){
		listForms = r["forms"];
		cursorData = r["cursorData"];
		//build table with cursor data
		makeEditTable(listForms,containerName,cursorData);
	});
	if(query.hasOwnProperty("parentId")){
		handleNodeReloads([query["parentId"]],[],false,$("#tree").dynatree("getTree"))
	}
}

</script>
<div id="temp">
</div>

<div id="wellView">
</div>
<iframe id="importUploadFrame" name="importUploadFrame" src="javascript:false;" height="800" width="800" style="display:none;"></iframe>

<script type="text/javascript" src="js/md5-min.js"></script>
<script type="text/javascript">
noHistory = false;
//for these function names create a history item when they are run
functions = ["makeForm","getList"];
oldFunctions = [];
for(var i=0;i<functions.length;i++){
	oldFunctions.push(window[functions[i]]);
	//wrap matching function with a decorator.  The old function is run then the new function
	window[functions[i]] = function(fIndex){
		return function(){
			oldFunctions[fIndex].apply(this,arguments);
			if(!noHistory){
				//if history is enabled
				try{
					//stringify arguments and get name of function
					functionData = JSON.stringify({"f":functions[fIndex],"a":[].slice.call(arguments)})
					//make a hash of this object
					newHash = hex_md5(functionData).toUpperCase();
					lastHash = location.hash = newHash;
					//save function data by hash in db
					var payload = {'hash':newHash,'functionData':functionData};
					x = restCall("/setHistory/","POST",payload);
				}catch(err){}
			}
			noHistory = false;
		}
	}(i);
}
lastHash = "";
checkRunHash = function(){
	//for browsers that do not have an onhaschange event
	//detects changes to the hash in the querystring by interval

	//get hash
	hs = location.hash;
	hs = hs.replace("#","");

	//if current hash does not equal last hash i.e. it has changed
	if(hs!=lastHash){
		lastHash = hs;
		if(location.hash!=""){
			//if it is not blank get the hash data from the database,clear the main container and apply the hash data to its function
			hs = restCall("/getHistory/","POST",{"hash":hs})["functionData"];
			h = JSON.parse(hs);
			clearContainer("arxOneContainer");
			window[h.f].apply(undefined,h.a);
		}
	}
}
if ( "onhashchange" in window.document.body ){
	//onhashchange is when the hash changes due to clicking of the next or previous browser
	//buttons
	window.onhashchange = function(){
		hs = location.hash;
		hs = hs.replace("#","");
		if(hs!=lastHash){
			lastHash = hs;
			if(location.hash!=""){
				//get hash from db
				hs = restCall("/getHistory/","POST",{"hash":hs})["functionData"];
				//clear container and apply hash function and parameters 
				h = JSON.parse(hs);
				clearContainer("arxOneContainer");
				window[h.f].apply(undefined,h.a);
			}
		}
	}
}else{
	//check manually by interval
	window.setInterval(checkRunHash,100);
}
if(location.hash!=""){
	//if we have a hash in the querystring, get the hash from the database
	//and execut its function and params
	clearContainer("arxOneContainer");
	//new
	hs = location.hash.replace("#","")
	hs = restCall("/getHistory/","POST",{"hash":hs})["functionData"];
	h = JSON.parse(hs);
	///new
	window[h.f].apply(undefined,h.a);
}
<%if request.querystring("id")<>"" then%>
//when we have and id in the querystring, redirect to view of that id
$(document).ready(function(){
	makeForm(<%=request.querystring("id")%>,"arxOneContainer","view");
})
<%end if%>
<%if request("action")="setAssayRunId" then%>
//loop back for Broad testing
//spoofs what CBIP should send back after start run
$(document).ready(function(){
	pl = {"id":<%=request("arxspanProtocolId")%>,"cbipRunId":"<%=request("cbipRunId")%>","cbipURL":"<%=request("cbipURL")%>","elnRunName":"<%=request("elnRunName")%>"};

	//lock and save protocol
	var p = new Form(getCache(pl["id"]))
	p.fd.locked = true;
	delete cache[p.fd.id];
	cache[p.fd.id] = JSON.parse(JSON.stringify(p.fd))
	theId = p.fd.id;
	restCall("/saveForm/","POST",{"form":p.fd});

	//create new empty result
	theId = parseInt(720);
	var f = new Form(getCache(theId))
	thisO = JSON.parse(f.getFieldByName('JSON').value)
	thisO.typeId = parseInt(theId);
	//empty main container
	$("#arxOneContainer").empty();
	t = new Form(thisO);
	t.fd.parentId = pl["id"];
	//update appropriate fields in result
	t.getFieldByName('name').value = pl['cbipRunId'];
	t.getFieldByName('Run ID').value = '<a href="'+pl['cbipURL']+'">'+pl['cbipRunId']+'</a>';
	t.getFieldByName('ELN Run Name').value = pl['elnRunName'];
	//save result
	newId = saveNew(t.fd);
	//redirect to result
	window.location = "index.asp?id="+newId

})
<%end if%>
</script>

<!-- #include file="_inclds/footer.asp"-->