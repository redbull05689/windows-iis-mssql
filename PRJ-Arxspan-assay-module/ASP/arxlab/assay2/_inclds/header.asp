<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_getUsersICanSee.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
'platform html header%>
<%mainCssPath="/arxlab/css"%>
<%'for cache busting%>

<!-- #include virtual="/arxlab/_inclds/jsRev.asp" -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"> 
<!-- new ft stuff-->
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/arxspan_global_styles.css?<%=jsRev%>">
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/transitionStyles.css?<%=jsRev%>">
<link href="<%=mainCSSPath%>/latofont.css?<%=jsRev%>" rel="stylesheet" type="text/css">

<!-- jquery for dynatree -->
<script src='js/dynatree/jquery/jquery.js?<%=jsRev%>' type="text/javascript"></script>
<script src='js/dynatree/jquery/jquery-ui.custom.js?<%=jsRev%>' type="text/javascript"></script>
<script src='js/dynatree/jquery/jquery.cookie.js?<%=jsRev%>' type="text/javascript"></script>

<script type="text/javascript" src="<%=mainAppPath%>/js/arxlayout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/isotope.pkgd.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.placeholder.js?<%=jsRev%>"></script>



<!--[if lte IE 8]>
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/normalize.css?<%=jsRev%>" />
 <script type="text/javascript" src="<%=mainAppPath%>/js/html5shiv-printshiv.min.js?<%=jsRev%>"></script>
 <script type="text/javascript" src="<%=mainAppPath%>/js/jspatch.js?<%=jsRev%>"></script>
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/ie8_and_below.css?<%=jsRev%>" />
	<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/lato_ie_300.css?<%=jsRev%>" /> 
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/lato_ie_400.css?<%=jsRev%>" /> 
	<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/lato_ie_700.css?<%=jsRev%>" />
<![endif]-->
<!-- end new ft stuff-->
<link href="css/styles-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="<%=mainCSSPath%>/popup_styles.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/menu-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<link href="css/d3-css.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/contextMenu.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<!--[if lte IE 8]>
	<link rel="stylesheet" type="text/css" href="css/ie8.css?<%=jsRev%>" />
<![endif]-->
<%
specialAssayStyles = checkBoolSettingForCompany("specialAssayStyles", session("companyId"))
If specialAssayStyles then
%>
<link rel="stylesheet" type="text/css" href="<%=mainAppPath%>/assay/css/remove4.css?<%=jsRev%>">
<style type="text/css">
.ax1-textarea {
    width: 480px;
    display: inline-block;
    padding-top: 7px;
    padding-left: 7px;
}

label.ax1-textarea-label, label.ax1-text-label, label.ax1-select-label {
    width: 309px!important;
}

#arxOneContainer>.invPopupDiv>form>.ax1-text, #arxOneContainer>.invPopupDiv>form>.ax1-textarea, #arxOneContainer>.invPopupDiv>form>.ax1-select, #arxOneContainer>.invPopupDiv>form>.ax1-userInfo, #arxOneContainer>.invPopupDiv>form>.ax1-date, #arxOneContainer>.invPopupDiv>form>label:nth-of-type(4)+span.ax1-date {
    width: 408px!important;
    min-width: 408px!important;
    box-sizing: border-box!important;
    min-height: 34px!important;
}

#arxOneContainer>.invPopupDiv>form>label+span {
    min-height: 34px!important;
    box-sizing: border-box;
}
</style>
<%End if%>
<style type="text/css">
.expireDiv{
	width:800px;
}
label{
display:inline-block;
margin-top:7px;
}
img{
	border:none;
}
</style>

<title><%=titleData%></title>
<meta name="description" content="<%=metaDesc%>" />
<meta name="keywords" content="<%=metaKey%>" />

<style type="text/css">@import url(js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/modal.js?<%=jsRev%>"></script>

<!-- dynatree -->
<link rel='stylesheet' type='text/css' href='js/dynatree/src/skin/ui.dynatree.css?<%=jsRev%>'>
<script src='js/dynatree/src/jquery.dynatree.js?<%=jsRev%>' type="text/javascript"></script>
<script src='js/jquery.contextMenu-custom.js?<%=jsRev%>' type="text/javascript"></script>
<script type="text/javascript" src="js/json2.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/getFile.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/arxXml.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/arxOne.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/platform.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/popups.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/advancedSearch.js?<%=jsRev%>"></script>
<script type="text/javascript" SRC="js/marvin/marvin.js?<%=jsRev%>"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript" src="js/perm.js?<%=jsRev%>"></script>

<script type="text/javascript">
inFrame = false;
</script>

<!-- jeff fitting stuf -->
<script type="text/javascript" src="js/jsfit/numeric-1.2.6.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jsfit/jsfit.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jsfit/curveFits/arxFitSigmoidal.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jsfit/arxFit.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jsfit/flot-0.8.3/jquery.flot.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jsfit/flot-0.8.3/jquery.flot.canvas.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jsfit/knockout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jsfit/makeHeatMapLazy.js?<%=jsRev%>"></script>
<link rel="stylesheet" type="text/css" href="js/jsfit/jsFit.css?<%=jsRev%>">
<!-- end jeff fitting stuf -->

<link href="../../arxlab/js/sweetalert1/sweetalert.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="<%=mainAppPath%>/js/sweetalert1/sweetalert.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/encodingFunctions.js?<%=jsRev%>"></script>
<%
'generate connection id and set permissions based on role
If session("assayRoleName") = "Admin" Or session("assayRoleName") = "Power User" Then
	session("canDeleteAssay") = True
	session("canEditAssay") = True
	If session("assayRoleName") = "Admin" then
		session("canMoveAssay") = True
	Else
		session("canMoveAssay") = True
	End if
Else
	session("canDeleteAssay") = False
	session("canEditAssay") = False
	session("canMoveAssay") = False
End if

' 7972 - According to the permissions document supplied in the ticket, all user permissions are allowed to add things,
' it just has to be allowed in the backend, which /does/ allow Users to add result sets, so everyone who has access to
' Assay should be allowed to have the add permission in the front end.
session("canAddAssay") = True
%>

<!-- #include file="../../_inclds/common/asp/checkLoginAndResetInactivityTimer.asp"-->

<script type="text/javascript">
function isoNoTZ(dStr){
	<%'convert a date string to a iso date string with no timezone%>
	return (new Date(new Date(dStr) - (new Date()).getTimezoneOffset() * 60000)).toISOString();
}
<%'set connection id%>
connectionId = '<%=session("servicesConnectionId")%>';
 userName = '<%=session("firstName") & " " & session("lastName")%>';
<%'start session in platform%>
globalUserInfo = restCall("/elnConnection/","POST",{'connectionId':'<%=session("servicesConnectionId")%>','userId':<%=session("userId")%>,'whichClient':'<%=replace(whichClient,"'","\'")%>','usersICanSee':'<%=getUsersICanSee()%>'})
<%'get assay role%>
jsRole = '<%=lcase(session("assayRoleName"))%>';
<%'get permissions and settings%>
canAdd = <%=lcase(session("canAddAssay"))%>;
canEdit = <%=lcase(session("canEditAssay"))%>;
canDelete = <%=lcase(session("canDeleteAssay"))%>;
chemTable = globalUserInfo["inventoryStructuresTable"];
sendToSeurat = globalUserInfo["sendToSeurat"];
hasStartRun = globalUserInfo["hasStartRun"];
resultTypeId = globalUserInfo["resultTypeId"];
resultSetTypeId = globalUserInfo["resultSetTypeId"];
chemSearchDbName = "structureId.cd_id";
chemSearchDbName2 = "compounds.0.cd_id";
<%'log the user out if they have logged out in a different tab%>
globalLinkField = false;
gettingLink = false;

// Getting a label from whichServer for translations.
var assayDeleteFormWarning = "<%=assayDeleteFormWarning%>";

<%
select case whichServer
	case "DEV"
		serverRoot = "https://dev.arxspan.com"
	case "MODEL"
		serverRoot = "https://model.arxspan.com"
	case "BETA"
		serverRoot = "https://beta.arxspan.com"
	case "PROD"
		serverRoot = "https://eln.arxspan.com"
end select
%>
serverRoot = '<%=serverRoot%>';

sessionEmail = '<%=session("email")%>'

var treeWidth = 'auto';
var treeWidthWider = 'auto';
var isDragging = false;
//on mouse over of tree, set tree width to the width of the widest element + 20 px
$(document).ready(function(){
	$("#tree").mouseenter(function(){
		$("#tree").width($("#tree").find(".dynatree-container")[0].scrollWidth+20);
	})
	$("#tree").mouseleave(function(){
		$("#tree").width(treeWidth);
	})
	$("#tree").mouseup(function(){
		$("#tree").width(treeWidth);
		$("#tree").width($("#tree").find(".dynatree-container")[0].scrollWidth+20);
	})
	$("#treeContextMenu").mouseenter(function(){
		$("#tree").width($("#tree").find(".dynatree-container")[0].scrollWidth+20);
	})
	$("#treeContextMenu").mouseleave(function(){
		$("#tree").width(treeWidth);
	})

})
//end tree drag stuff
</script>

<script type="text/javascript">
//capture mouse position on mouse move
mouse = [];
  	var IE = false;
	if (navigator.appName == "Microsoft Internet Explorer"){IE = true}
	if (!IE){document.captureEvents(Event.MOUSEMOVE)}
	document.onmousemove = getMouseXY;

	function getMouseXY(m){
		try{
			if (IE)	{
				 var tmpX = event.clientX;
				 var tmpY = event.clientY;
				}	
			else 	{
					 var tmpX = m.pageX;
				 var tmpY = m.pageY;
				}  
			if (!document.body.scrollTop)
				{
				 var iL = document.documentElement.scrollLeft;	
				 var iV = document.documentElement.scrollTop;
				}
			else 	{
				 var iL = document.body.scrollLeft;	
				 var iV = document.body.scrollTop;	
				}
			mouse = [tmpX,tmpY];
		}catch(err){}
		return true;
	}
</script>
</head>
<body onMouseMove="getMouseXY()">

<%'frames for overlays%>
<iframe style="display:none;background-color:black;z-index:99999;width:100%;height:100%;top:0;left:0;position:fixed;background:rgba(1,0,0,.7);filter: alpha(opacity = 0);border:none;" id="blackFrame" src="javascript:false;"></iframe>
<div style="display:none;background-color:black;z-index:100000;width:100%;height:100%;top:0;left:0;position:fixed;background:rgba(0,0,0,.7);filter: alpha(opacity = 80);" id="blackDiv"></div>
<iframe style="display:none;background-color:#eee;z-index:100001;width:90%;height:90%;top:40;left:40;position:fixed;padding:10px;" id="linkFrame" src="javascript:false;"></iframe>

<%If session("email")="support@arxspan.com" And 1=1 then%>
<%'magic buttons%>
<input type="button" value="Send All To FT" onclick='restCallA("/sendDataToFT/","POST",{});'>
<input type="button" value="keys" onclick='restCallA("/getFTKeys/","POST",{});'>
<input type="button" value="test" onclick='restCallA("/test","POST",{});'>
<%End if%>

<%If session("sessionTimeout") then%>
<%'html for inactivity/session timeout warning%>
<div id="inactivityDiv" class="popupDiv popupBox">
	<div class="popupFormHeader">Session Expiration</div>
	<p style="padding-bottom:20px;">Due to inactivity your session will expire in <span id="expireSeconds" style="font-size:18px;font-weight:bold;"></span> seconds.</p>
	<form onsubmit="return false;" class="popupForm">
		<section class="bottomButtons buttonAlignedRight">
			<button type="submit" onclick="allowReset=true;$.get('<%=mainAppPath%>/ajax_doers/resetInactivityTimer.asp?rand=<%=Rnd%>');hidePopup('inactivityDiv')">Stay Signed In</button>		
			<button type="submit" onclick="window.location='<%=mainAppPath%>/logout.asp'">Logout</button>
		</section>
	</form>
</div>

<script type="text/javascript" src="<%=mainAppPath%>/js/popups.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.leanModal.min.js?<%=jsRev%>"></script>
<a id="modalDummy" style="display:none;">needed for modal</a>
<script type="text/javascript">
$("#modalDummy").leanModal({ top : 40, overlay : 0.8, closeButton: ".modal_close" });
$("#lean_overlay").click(function(){try{hidePopup(currentPopup)}catch(err){}})
</script>
<%End if%>

<%'context menu for tree%>
<div>
	<ul id="treeContextMenu" class="contextMenu" style="width: 250px;">
		<!--<li><a href="#daughterPlate" id="tcm_daughterPlate">Daughter Plate</a></li>-->
		<li><a href="#add" id="tcm_add">Add</a></li>
		<%If session("canEditAssay") then%>
		<li><a href="#edit" id="tcm_edit">Edit</a></li>
		<%End if%>
		<li><a href="#view" id="tcm_view">View</a></li>
		<li><a href="#startRun" id="tcm_startrun">Start Run</a></li>
		<%If session("canMoveAssay") then%>
		<li><a href="#move" id="tcm_move">Move</a></li>
		<%End if%>
	</ul>
</div>

<%sectionId="assay"%>
<!-- #include virtual="/arxlab/_inclds/header2.0.asp"-->
<!-- #include virtual="/arxlab/_inclds/nav_top_tool.asp"-->
<div style="margin:auto;position:relative" id="contentTable">
<div style="width:20%;float:left;margin-left:2%">
<div style="background-color:#ccc;height:600px;">
	<div id="aNav">
		<%'nav search button%>
		<%If session("companyHasFTLiteAssay") then%>
			<div class="topSectionLower" style="background-color:transparent;margin-top:-5px;min-width:unset;">
				<div class="topSectionLowerButton darker" style="margin-left:4px;">
					<a href="<%=mainAppPath%>/goToFT.asp?lite=assay" style="width:150px;margin:2px;text-align:center;">Search</a>
				</div>
			</div>
		<%else%>
			<div class="topSectionLower" style="background-color:transparent;margin-top:-5px;min-width:unset;">
				<div class="topSectionLowerButton darker" style="margin-left:4px;">
					<a href="javascript:void(0);" onclick="makeSearch('arxOneContainer')" style="width:150px;margin:2px;text-align:center;">Search</a>
				</div>
			</div>
		<%End if%>
	</div>
	<div id="tree" class="assayTree" style="height:100%">

	</div>
	<script type="text/javascript">

		defaultContainerName = "arxOneContainer";
		tableFds = [];
		tableFixedFields = [];
		dontRefreshTableLink = true;
		showParentLinks = false;

		function loadParentTree(parentTree,tree){
			<%'loads a list of nested ids lazily%>
			if(parentTree&&tree){
				keyPath = "";
				for (var j=0;j<parentTree.length;j++){
					keyPath += "/"+parentTree[j]["id"];
				}
				tree.loadKeyPath(keyPath, function(node, status){
					if(status == "loaded") {
						node.expand();
					}else if(status == "ok") {
						node.expand();
					}else if(status == "notfound") {
						var seg = arguments[2],
							isEndNode = arguments[3];
					}
				});
			}
		}

		function loadParentTree2(parentTree,tree){
			if(parentTree&&tree){
				if(tree.getNodeByKey(parentTree[0].toString())){
					window.clearTimeout(toForLoadParentTree)
					keyPath = "";
					for (var j=0;j<parentTree.length;j++){
						keyPath += "/"+parentTree[j];
					}
					tree.loadKeyPath(keyPath, function(node, status){
						if(status == "loaded") {
							node.expand();
						}else if(status == "ok") {
							node.expand();
						}else if(status == "notfound") {
							var seg = arguments[2],
								isEndNode = arguments[3];
						}
					});
				}else{
					window.clearTimeout(toForLoadParentTree)
					toForLoadParentTree = window.setTimeout((function(){return function(){loadParentTree2(parentTree,tree)}})(parentTree,tree),500)
				}
			}
		}
var toForLoadParentTree = 0
		function contextMenuPerms(node){
			fieldList = [];
			if(!node.data.showTable){
				fieldList.push("#daughterPlate");				
			}
			if(!node.data.canAdd  || !<%=lcase(session("canAddAssay"))%>){
				if(node.data.type != "assay"){
					fieldList.push("#add");
				}
			}
			if(!node.data.canEdit){
				fieldList.push("#edit");				
			}
			if(!node.data.canUse){
				fieldList.push("#use");				
			}
			if(!node.data.canMove){
				fieldList.push("#move");				
			}
			if(!node.data.canStartRun){
				fieldList.push("#startRun");				
			}
			return fieldList.join(",");
		}

		$("#tree").dynatree({
			initAjax: {url: "/getTree/",
					   data: {key: "root", // Optional arguments to append to the url
							  mode: "all",
							  type: "root",
							  connectionId:connectionId
							  }
					   },
			onLazyRead: function(node){
				node.appendAjax({url: "/getTree/",
								   data: {"key": node.data.key.replace("_",""), // Optional url arguments
										  "mode": "all",
										  "type": node.data.type,
										  connectionId:connectionId
										  }
								  });
			},
			onCreate: function (node, span) {
				$(span).contextMenu({ menu: 'treeContextMenu' }, (function(node,span){
						return function (action, el, pos) {
							actionFunctions(action,false,node)
						}
					})(node,span)
				).enableContextMenuItems().disableContextMenuItems(contextMenuPerms(node));
			},
			onActivate: function(node){
				handleLink(node.data.key,node.data.type,node.data.showTable);
				if(!node.bExpanded){
					node.expand(true);
				}
			},
			imagePath: "images/treeIcons/",
			debugLevel: 0
		});

		function newPopup(id){
			<%'create element with popup shell%>
			el = document.createElement("div");
			el.className = "popupDiv";
			el.setAttribute("id",id);
			a = document.createElement("a")
			a.className = "popupCloseLink";
			a.setAttribute("href","javascript:void(0);");
			a.onclick = (function(id){
				return function(){
					el = document.getElementById(id);
					el.parentNode.removeChild(el);
					blackOff();
					gettingLink = false;
				}
			})(id);
			img = document.createElement("img");
			img.className = "popupCloseImg";
			img.src = "images/close-x.gif"
			a.appendChild(img);
			el.appendChild(a);
			return el;
		}

		function handleLink(id,collection,showTable,parentTree,containerName){
			if(!containerName){
				containerName = "arxOneContainer"
			}
			var tree = $("#tree").dynatree("getTree");
			node = tree.getNodeByKey(id.toString())
			clearContainer(containerName);
			//tableFields = ["Name","Structure","Amount","Unit Type","Supplier","CAS Number"];
			tableFields = [];
			if(collection!="checkedout" && collection!="disposed"){
				skip = false;
				if(!skip){
					if(showTable){
						getList(false,false,{"parentId":parseInt(id)},tableFields)
					}else{
						makeForm(id,"arxOneContainer","view");
					}
				}
			}
			if(collection=="checkedout"){
				getList(false,false,{"checkedOut":true},tableFields)
			}
			if(collection=="disposed"){
				getList(false,false,{"disposed":true},tableFields)
			}
		}

		function updateTableValues(updateForm,closeTable){
			for (var i=0;i<tableFds.length;i++){
				if(tableFds[i].id == updateForm.id){
					fields = updateForm.fields;
					for(var j=0;j<fields.length;j++){
						updateField = fields[j];
						tableFieldIndex = tableFds[i].fieldNames.indexOf(fields[j].formName);
						if(tableFieldIndex!=-1){
							tableField = tableFds[i].fields[tableFieldIndex];
							if( (tableField.inTable && !tableFixedFields) || (!!tableFixedFields && tableFixedFields.indexOf(updateField.formName)!=-1) ){
								if(tableField.fieldType!="showChildLinks"&&tableField.fieldType!="chem"){
									if(tableField.dbName!=tableFds[i].tableLinkName){
										document.getElementById(tableField.id+"_table_span").innerHTML = updateField.value;
									}else{
										document.getElementById(tableField.id+"_table_link").innerHTML = updateField.value;
									}
								}
							}
						}
					}
					if(closeTable){
						document.getElementById(tableFds[i].fid+"_edit_tr").style.display = "none";
						document.getElementById(tableFds[i].fid+"_expand_img").src = "images/plus.gif"
					}
				}
			}
		}

		function clearContainer(containerName){
			if(containerName == "arxOneContainer"){
				tableFds = [];
				tableFixedFields = [];
			}
			try{
				while(document.getElementById(containerName).getElementsByTagName("div").length>0){
					el = document.getElementById(containerName).getElementsByTagName("div")[0];
					el.parentNode.removeChild(el);
				}
			}catch(err){alert(err.message)}
			try{
				el = document.getElementById(containerName).getElementsByTagName("table")[0];
				el.parentNode.removeChild(el);
			}catch(err){}
			try{
				window.clearInterval(resizeIframeInterval);
			}catch(err){}
			cursorIdPing = false;
		}

		function handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree){
			for (var j=0;j<nodesToReload.length;j++ ){
				node = tree.getNodeByKey(nodesToReload[j].toString())
				if(node){
					node.reloadChildren();
				}else{
					pt = restCall("/getParentTree/","POST",{id:nodesToReload[j]})["parentTree"];
					loadParentTree2(pt,tree);
				}
			}
			for (var j=0;j<nodesToActivate.length;j++ ){
				node = tree.getNodeByKey(nodesToActivate[j].toString())
				if(node){
					node.deactivate();
					node.activate();
				}
			}
		}

		function actionFunctions(action,fd,node,containerName){
			<%'handle actions initiated by the tree%>
			var tree = $("#tree").dynatree("getTree");
			nodesToReload = [];
			nodesToActivate = []
			<%'set action target to default container name if no container name was provided%>
			if(!containerName){
				containerName = defaultContainerName;
			}
			<%'get id and parent tree whether from node in tree or called manually%>
			if(!!fd){
				id = fd.id;
				parentTree = fd.parentTree;
			}
			if(!!node){
				id = parseInt(node.data.key);
				parentTree = node.data.parentTree;
			}
			<%'if parent tree is not provided dont break the tree%>
			if(parentTree=="" || !parentTree){
				parentTree = [0];
			}

			if(action == "add"){
				<%'add new child to parent%>
				<%'add self/parent to list of items to refresh in the tree upon completion%>
				nodesToReload.push(id);
				nodesToActivate.push(id);
				<%'turn black screen on%>
				blackOn();

				<%'make popup for adding%>
				popup = newPopup("addPopup");
				popup.style.width="300px"
				popup.style.height="200px"
				label = document.createElement("label");
				label.innerHTML = "Type to Add";
				popup.appendChild(label);
				<%'load parent form%>
				f = new Form(getCache(id))

				<%'get the list of allowed children from the system and populate them into a drop down%>
				addTypeIds = restCall("/getAllowedChildren/","POST",{"id":id});
				addTypeTexts = [];

				// Throw up an error message to make sure its obvious when a user isn't allowed to add to an object.
				if (!addTypeIds.length) {
					blackOff();
					swal("Error!", "You do not have permission to add anything to this object.", "warning");
					return;
				}

				$.each(addTypeIds,function(i,addTypeId){
					ff = new Form(getCache(addTypeId))
					addTypeTexts.push(ff.getFieldByName('name').value)
				});
				addTypes = zip(addTypeIds,addTypeTexts)
				select = document.createElement("select");
				select.setAttribute("id","addType");
				for(var i=0;i<addTypes.length;i++){
					option = document.createElement("option");
					option.setAttribute("value",addTypes[i][0]);
					option.appendChild(document.createTextNode(addTypes[i][1]));
					select.appendChild(option);
				}
				popup.appendChild(select);

				<%'if the user is support@arxspan.com add fields for manually changing the date and user added%>
				<%'for manual importing purposes%>
				userSelect = false;
				dateBox = false;
				<%if session("email")="support@arxspan.com" then%>
				userSelect = document.createElement("select");
				users = restCall('/getUserList2/','POST',{})
				$.each(users,function(x,user){
					option = document.createElement("option");
					option.setAttribute("value",user[0]);
					option.appendChild(document.createTextNode(user[1]));
					userSelect.appendChild(option);
				})
				popup.appendChild(userSelect)

				dateBox = document.createElement("input");
				dateBox.setAttribute("type","text");
				popup.appendChild(dateBox)
				<%end if%>

				<%'make OK button and attach action%>
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(select,node,parentId,dateBox,userSelect){
					return function(){
						<%'make a form of the type selected in the drop down%>
						theId = parseInt(select.options[select.selectedIndex].value);
						var f = new Form(getCache(theId))
						thisO = JSON.parse(f.getFieldByName('JSON').value)
						thisO.typeId = parseInt(theId);
						t = new Form(thisO);
						<%'clear the arxOneContainer%>
						$("#arxOneContainer").empty();
						
						<%'set the parent of the new form to the id of the item selected in the tree%>
						t.fd.parentId = parentId;

						<%'run any onAdd functions of the new form%>
						if(t.fd["__pFunctions"]["onAdd"]){
							tempF = new Function("form",t.fd["__pFunctions"]["onAdd"]);
							tempF(t);
						}

						<%'change the date and user of the form if the user is support@arxspan.com and they added a date%>
						if(dateBox){
							if(dateBox.value!=""){
								t.fd.dateAdded = isoNoTZ(dateBox.value);
								t.fd.userAdded = {"userName":$(userSelect).find('option:selected').text(),"id":parseInt($(userSelect).val())}
							}
						}

						<%'add any default values to newly added form%>
						addDefaultValues(t.fd)
						
						<%'show the new form%>
						t.show("arxOneContainer","edit");

						<%'get rid of the popup%>
						el = document.getElementById("addPopup");
						el.parentNode.removeChild(el);
						blackOff();

						
					}
				})(select,node,id,dateBox,userSelect);
				<%'add button to popup and show popup%>
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
			}
			if(action == "edit"){
				<%'edit the form of the selected id%>
				editExistingRecord = true;
				makeForm(id,"arxOneContainer","edit")
			}
			if(action == "view"){
				<%'view the form of the selected id%>
				makeForm(id,"arxOneContainer","view")
			}
			if(action == "startRun"){
				<%'start run for Broad CBIP%>
				<%'get form object for assay, protocol, and project%>
				var protocol = new Form(getCache(id))
				var assay = new Form(getCache(protocol.fd.parentId))
				var project = new Form(getCache(assay.fd.parentId))

				<%'create a JSON object for the request with the appropriate data%>
	            x2 = {"arxspanProtocolId":protocol.fd.id,
                  "action":"setAssayRunId",
                  "pinVolume":protocol.getFieldByName("Pin Volume").value,
                  "wellVolume":protocol.getFieldByName("Assay Well Volume").value,
                  "pinVolumeUnits":protocol.getFieldByName("Pin Volume Units").value,
                  "wellVolumeUnits":protocol.getFieldByName("Assay Well Volume Units").value,
                  "measurementLabels":protocol.getFieldByName("Measurement Labels").value.join("||"),
                  "protocolId":zeroPad(protocol.getFieldByName('index').value,2),
                  "assayId":zeroPad(assay.getFieldByName('index').value,2),
                  "projectId":zeroPad(project.getFieldByName('Project Code').value,4)}
				  <%if whichServer = "DEV" then%>
					<%'DEV loops back to itself for testing purposes since we do not have access to CBIP%>
					x2["cbipURL"] = 'https://cbip-qa.broadinstitute.org/cbip/screening/assay/run/StartAssayRunFromELN.action?'
					x2["cbipRunId"] = "ARX-"+Math.floor((Math.random() * 100000) + 1);
					x2["elnRunName"] = "eln run name"
				  <%end if%>
					<%
					'set CBIP url
					select case whichServer
						case "DEV"
							%>theURL = "https://dev.arxspan.com/arxlab/assay2/index.asp"<%
						case "MODEL"
							%>theURL = "https://cbip-qa.broadinstitute.org/cbip/screening/assay/run/StartAssayRunFromELN.action?"+x2["action"]<%
						case "PROD"
							%>theURL = "https://cbip.broadinstitute.org/cbip/screening/assay/run/StartAssayRunFromELN.action?"+x2["action"]<%
					end select
					%>
					<%'we need to POST to CBIP.  Create a form add every member from the JSON request object to the form and submit it%>
					cbipForm = $('<form>',{'method':'POST','action':theURL})					
				  for(var property in x2){
					if(x2.hasOwnProperty(property)){
						cbipForm.append($('<input>',{'name':property,'value':x2[property],'type':'hidden'}))
					}
				  }
				  cbipForm.appendTo("body").submit();
			}
		}
	</script>
	<style type="text/css">
		.ax1-searchHolderDiv #searchButton{
			display:block;
		}
		.ax1-chemSearchFrameBox{
			border:none;
		}
		.ax1-advSearchFrame{
			width:800px;
			border:none;
		}
		.experimentsTable{
			width:800px;
		}

		#tree{
			background-color:#ccc;
			border-right:5px ridge #7dcf2c;
			z-index:10000;
		}
		#treeMove{
			width:200px;
			height:400px;
			background-color:#ccc;
		}
		.popupDiv{
			background-color:white;
			border:0px solid black;
			border-top:20px solid black;
			position:absolute;
			top:40px;
			left:40%;
			z-index:100001;
			padding:20px;
		}
		.popupDiv input,select{
			display:block;
		}
		.groupCheck, .groupCheckUser{
			height:12px;
			display:inline!important;
			margin-right:2px;
		}
		.popupCloseLink{
			position:absolute;
			right:0;
			top:0;
			margin-top:-19px;
		}
		.popupCloseImg{
			width:18px;
			height:18px;
			border:none;
		}

			#overlay {
				position:fixed; 
				top:0;
				left:0;
				width:100%;
				height:100%;
				background:#000;
				opacity:0.5;
				filter:alpha(opacity=50);
				z-index:99999999;
			}

			#modal {
				position:absolute;
				background:url(tint20.png) 0 0 repeat;
				background:rgba(0,0,0,0.2);
				border-radius:14px;
				padding:8px;
				z-index:999999999;
			}

			#content {
				border-radius:8px;
				background:#fff;
				padding:20px;
				z-index:9999999999;
			}

			#close {
				position:absolute;
				background:url(images/modal_close.png) 0 0 no-repeat;
				width:24px;
				height:27px;
				display:block;
				text-indent:-9999px;
				top:-7px;
				right:-7px;
			}
	</style>
</div>
</div>
<div style="width:75%;background-color:#eee;float:left;margin-left:2%" valign="top">
<div id="contentDiv">