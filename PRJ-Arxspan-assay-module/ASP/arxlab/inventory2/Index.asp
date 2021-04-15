<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
titleData = "Arxspan Inventory"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header.asp"-->

<div id="aboveArxOneContainer">
</div>
<div id="arxOneContainer">
<%If session("companyId")="17" then%>
<script type="text/javascript" src="js/jquery.leanModal.min.js"></script>
<script type="text/javascript">
chemistryInSearch = false;
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
$.get("templates/mskihc_splash.html?r="+Math.random())
	.done(function(data){
		div = document.createElement("div");
		div.innerHTML = data;
		document.getElementById("arxOneContainer").appendChild(div);
		delayedRunJS(data);
	});
</script>
<%End if%>
</div>
<%'412015%>
<div id="hiddenContainer" style="display:none;">
</div>
<div style="width:300px;height:100px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:fixed;left:50%;margin-left:-150px;z-index:100001;top:100px;" id="loadingDiv" class="popupDiv">
<table height="100%" width="100%">
	<tr>
		<td valign="middle" align="center">
			<h1 style="display:inline;">Loading...</h1>&nbsp;&nbsp;<img src="<%=mainAppPath%>/images/ajax-loader.gif">
		</td>
	</tr>
</table>
</div>
<div style="width:300px;height:100px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:fixed;left:50%;margin-left:-150px;z-index:100001;top:100px;" id="copyingDiv" class="popupDiv">
<table height="100%" width="100%">
	<tr>
		<td valign="middle" align="center">
			<h1 style="display:inline;">Copying...</h1>&nbsp;&nbsp;<img src="<%=mainAppPath%>/images/ajax-loader.gif">
		</td>
	</tr>
</table>
</div>
<%'/412015%>
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
		background-color:#f1f1f1;
	}
	.plateMap .even{
		background-color:white;
	}
	.plateMap a{
		text-decoration:none;
		color:black;
		font-weight:bold;
		font-size:11px;
	}
	.plateMap td{
		width:50px;
		text-align:center;
	}
	#selectedItemsDiv .experimentsTable{
		width:520px!important;
	}
</style>

<div id="wellView">
</div>


<script type="text/javascript">
formBucket = [];
searchFieldList = [];
//rpp and cb added 412015
function getList(cursorId,action,query,fixedFields,containerId,rpp,cb){
	payload = {};
	if(cursorId){
		payload["cursorId"] = cursorId;
	}
	if(rpp){
		payload["rpp"] = rpp;
	}else{
		payload["rpp"] = 10;
	}
	if(!action){
		payload["action"] = "next";
	}else{
		payload["action"] = action;
	}
	if(!query){
		query = {};
	}
	payload["collection"] = "inventoryItems";
	payload["list"] = true;
	payload["query"] = query;
	restCallA("/getList/","POST",payload,function(r){

		listForms = r["forms"];
		cursorData = r["cursorData"];

		for(var i=0;i<listForms.length;i++){
			addObjectForm = listForms[i];
			addObjectForm.cursorData = cursorData;
		}
		if(ignoreTableFields){
			if(listForms.length>0){
				L = [];
				for (var i=0;i<listForms[0].fields.length;i++){
					if(listForms[0].fields[i].inTable){
						L.push(listForms[0].fields[i].formName)
					}
				}
				fixedFields = L;
			}
		}
		<%if inFrame then%>
			document.getElementById("searchButton").value="Search";
			if(containerId){
				selectedItemFds = listForms;
				makeEditTable(listForms,containerId,fixedFields,true);
			}else{
				makeEditTable(listForms,'arxOneContainer',fixedFields,true);
			}

		<%else%>
			//412015
			if(!containerId){
				containerId = "arxOneContainer";
			}
			if(listForms.length!=0){
				listForms[0].exportAllFunction = (function(query,fixedFields){
					return function(){
						blackOn();
						$("#loadingDiv").show();
						newFixedFields = [];
						for(var i=0;i<fixedFields.length;i++){
							if(fixedFields[i]!="Structure"){
								newFixedFields.push(fixedFields[i]);
							}
						}
						getList(false,false,query,newFixedFields,"hiddenContainer",10000,function(){
							$('#exportLink')[0].click();
							$("#loadingDiv").hide();
							blackOff();
						});
					}
				})(query,fixedFields)
			}
			makeEditTable(listForms,containerId,fixedFields);
			///412015
		<%end if%>
		try{
			if(cursorId == false){
				window.scroll(0,findPos(document.getElementById("listTable")));
				document.getElementById("searchButton").value="Search";
			}
		}catch(err){}
		//412015
		if(cb){
			cb();
		}
		///412015
	});
}

</script>
<div id="temp">
</div>


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
	pl = {"action":"view","collection":"inventoryItems","id":<%=request.querystring("id")%>};
	addObjectForm = restCall("/getForm/","POST",pl);								
	makeForm(addObjectForm,'arxOneContainer');
	tree = $("#tree").dynatree("getTree");
	parentTree = addObjectForm.parentTree;
	loadParentTree(parentTree,tree)
})
<%end if%>
</script>
<script type="text/javascript" src="<%=mainAppPath%>/js/promisePolyfill.min.js?<%=jsRev%>"></script>
<!-- #include file="_inclds/footer.asp"-->