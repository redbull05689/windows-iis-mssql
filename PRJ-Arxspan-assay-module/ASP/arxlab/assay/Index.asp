<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Assay"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->


<div id="arxOneContainer">

</div>

<script type="text/javascript">
formBucket = [];
searchFieldList = [];

function getList(cursorId,action,query,fixedFields,containerName){
	if(containerName==undefined){
		containerName = "arxOneContainer";
	}
	payload = {};
	if(cursorId){
		payload["cursorId"] = cursorId;
	}
	payload["rpp"] = 10;
	if(!action){
		payload["action"] = "next";
	}else{
		payload["action"] = action;
	}
	if(!query){
		query = {};
	}
	payload["collection"] = "assayItems";
	payload["list"] = true;
	payload["query"] = query;
	restCallA("/getList/","POST",payload,function(r){
		listForms = r["forms"];
		cursorData = r["cursorData"];

		for(var i=0;i<listForms.length;i++){
			addObjectForm = listForms[i];
			addObjectForm.cursorData = cursorData;
		}
		makeEditTable(listForms,containerName,fixedFields);
		try{
			document.getElementById("searchButton").value="Search";
			if(cursorId == false){
				window.scroll(0,findPos(document.getElementById(containerName).getElementById("listTable")));
			}
		}catch(err){}
	});
}

</script>
<div id="temp">
</div>
<style type="text/css">
	#wellView{
		z-index:1000;
		background-color:white;
		border:1px solid black;
		display:none;
		position:fixed;
		left:0;
		top:0;
		width:400px;
	}
	#wellView div{
		width:160px;
		float:left;
	}
	.plateMap .odd{
		background-color:#4c4;
	}
	.plateMap .even{
		background-color:white;
	}
	.plateMap a,.plateMap span{
		text-decoration:none;
		color:black;
		font-weight:bold;
		font-size:11px;
	}
	.plateMap td{
		min-width:50px;
		text-align:center;
	}
</style>
<div id="wellView">
</div>
<iframe id="importUploadFrame" name="importUploadFrame" src="javascript:false;" height="800" width="800" style="display:none;"></iframe>

<script type="text/javascript" src="js/md5-min.js"></script>
<script type="text/javascript">
noHistory = false;
functions = ["makeForm","getList"];
oldFunctions = [];
for(var i=0;i<functions.length;i++){
	oldFunctions.push(window[functions[i]]);
	window[functions[i]] = function(fIndex){
		return function(){
			oldFunctions[fIndex].apply(this,arguments);
			if(!noHistory){
				try{
					//new
					functionData = JSON.stringify({"f":functions[fIndex],"a":[].slice.call(arguments)})
					newHash = hex_md5(functionData).toUpperCase();
					lastHash = location.hash = newHash;
					var payload = {'hash':newHash,'functionData':functionData};
					x = restCall("/setHistory/","POST",payload);
					///new
				}catch(err){}
			}
			noHistory = false;
		}
	}(i);
}
lastHash = "";
checkRunHash = function(){
	hs = location.hash;
	hs = hs.replace("#","");
	if(hs!=lastHash){
		lastHash = hs;
		if(location.hash!=""){
			//new
			hs = restCall("/getHistory/","POST",{"hash":hs})["functionData"];
			///new
			h = JSON.parse(hs);
			clearContainer("arxOneContainer");
			window[h.f].apply(undefined,h.a);
		}
	}
}
if ( "onhashchange" in window.document.body ){
	window.onhashchange = function(){
		hs = location.hash;
		hs = hs.replace("#","");
		if(hs!=lastHash){
			lastHash = hs;
			if(location.hash!=""){
				//new
				hs = restCall("/getHistory/","POST",{"hash":hs})["functionData"];
				///new
				h = JSON.parse(hs);
				clearContainer("arxOneContainer");
				window[h.f].apply(undefined,h.a);
			}
		}
	}
}else{
	window.setInterval(checkRunHash,100);
}
if(location.hash!=""){
	clearContainer("arxOneContainer");
	//new
	hs = location.hash.replace("#","")
	hs = restCall("/getHistory/","POST",{"hash":hs})["functionData"];
	h = JSON.parse(hs);
	///new
	window[h.f].apply(undefined,h.a);
}
<%if request.querystring("id")<>"" then%>
$(document).ready(function(){
	pl = {"action":"view","collection":"assayItems","id":<%=request.querystring("id")%>};
	addObjectForm = restCall("/getForm/","POST",pl);								
	makeForm(addObjectForm,'arxOneContainer');
	tree = $("#tree").dynatree("getTree");
	parentTree = addObjectForm.parentTree;
	parentTree.unshift({"id":"assayGroups"});
	loadParentTree(parentTree,tree);
})
<%end if%>
<%if request.querystring("action")="setAssayRunId" then%>
$(document).ready(function(){
	pl = {"id":<%=request.querystring("arxspanProtocolId")%>,"cbipRunId":"<%=request.querystring("cbipRunId")%>","cbipURL":"<%=request.querystring("cbipURL")%>","elnRunName":"<%=request.querystring("elnRunName")%>"};
	r = restCall("/setAssayRunId/","POST",pl);
	pl = {"action":"view","collection":"assayItems","id":r["newId"]};
	addObjectForm = restCall("/getForm/","POST",pl);								
	makeForm(addObjectForm,'arxOneContainer');
})
<%end if%>
</script>

<!-- #include file="_inclds/footer.asp"-->