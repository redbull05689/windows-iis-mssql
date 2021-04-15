<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<!-- #include virtual="/arxlab/_inclds/jsRev.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
redirectAssayToPlatform = checkBoolSettingForCompany("usePlatformAssay", session("companyId"))
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))

If redirectAssayToPlatform Then
	response.redirect("/arxlab/assay2/index.asp?"&request.servervariables("QUERY_STRING"))
End if
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="utf-8"> 
<!-- new ft stuff-->
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/arxspan_global_styles.css?<%=jsRev%>">
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/transitionStyles.css?<%=jsRev%>">
<link href="<%=mainCSSPath%>/latofont.css?<%=jsRev%>" rel="stylesheet" type="text/css">
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
<%If specialInventoryStyles then%>
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

<!-- jquery for dynatree -->
<script src='js/dynatree/jquery/jquery.js?<%=jsRev%>' type="text/javascript"></script>
<script src='js/dynatree/jquery/jquery-ui.custom.js?<%=jsRev%>' type="text/javascript"></script>
<script src='js/dynatree/jquery/jquery.cookie.js?<%=jsRev%>' type="text/javascript"></script>
<!-- dynatree -->
<link rel='stylesheet' type='text/css' href='js/dynatree/src/skin/ui.dynatree.css?<%=jsRev%>'>
<script src='js/dynatree/src/jquery.dynatree.js?<%=jsRev%>' type="text/javascript"></script>
<script src='js/jquery.contextMenu-custom.js?<%=jsRev%>' type="text/javascript"></script>
<script type="text/javascript" src="js/json2.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/getFile.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/arxXml.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/arxOne.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/popups.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/advancedSearch.js?<%=jsRev%>"></script>
<script type="text/javascript" SRC="js/marvin/marvin.js?<%=jsRev%>"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript" src="js/perm.js?<%=jsRev%>"></script>
<script type="text/javascript">
inFrame = false;
</script>

<%
If session("assayRoleName") = "Admin" Or session("assayRoleName") = "Power User" Then
	session("canEditAssay") = True
	session("canAddAssay") = True
	If session("assayRoleName") = "Admin" then
		session("canMoveAssay") = True
	Else
		session("canMoveAssay") = True
	End if
Else
	session("canEditAssay") = False
	session("canAddAssay") = False
	session("canMoveAssay") = False
End if
%>

<!-- #include file="../../_inclds/common/asp/checkLoginAndResetInactivityTimer.asp"-->

<script type="text/javascript">
//add some connection stuff
connectionId = '<%=session("servicesConnectionId")%>';
restCallInv("/elnConnection/","POST",{'connectionId':'<%=session("servicesConnectionId")%>','userId':<%=session("userId")%>,'whichClient':'<%=replace(whichClient,"'","\'")%>'})
globalUserInfo = restCall("/elnConnection/","POST",{'connectionId':'<%=session("servicesConnectionId")%>','userId':<%=session("userId")%>,'whichClient':'<%=replace(whichClient,"'","\'")%>'})
canAdd = <%=lcase(session("canAddAssay"))%>;
canEdit = <%=lcase(session("canEditAssay"))%>;
chemTable = globalUserInfo["inventoryStructuresTable"];
sendToSeurat = globalUserInfo["sendToSeurat"];
hasStartRun = globalUserInfo["hasStartRun"];
chemSearchDbName = "structureId.cd_id";
chemSearchDbName2 = "compounds.0.cd_id";
whichClient = '<%=replace(whichClient,"'","\'")%>'
globalLinkField = false;
gettingLink = false;

//tree dragging stuff
var treeWidth = 'auto';
var treeWidthWider = 'auto';
var isDragging = false;
$(function(){
	$('#tree ul:first-child').on( 'scroll', function(ev){
		$( document ).off( '.dragging' );
		$('#tree').css( {
			'width'      : treeWidthWider
		} );
	})
	$('#tree').each( function(){      
        var $drag = $(this);
        $drag.on( 'mousedown', function(ev){
            var $this = $( this );
            var $parent = $this.parent();
            var poffs = $parent.position();
			var thisWidth = $this.width();
            var x = ev.pageX;
            var y = ev.pageY;
            $( document ).on( 'mousemove.dragging', function( ev ) {
				var mx = ev.pageX;
                var my = ev.pageY;
                var rx = mx - x;
                var ry = my - y;
				if (mx-$this.parent().offset().left>thisWidth-15 || isDragging)
				{
					isDragging = true;
	                $this.css( {
		                'width'      : (thisWidth + rx) + 'px'
			        } );
				}
				try{
					if(document.selection){
						document.selection.empty()
					}else{
						window.getSelection().removeAllRanges()
					}
				}catch(err){}
            } ).on( 'mouseup.dragging mouseleave.dragging', function( ev) {
				$( document ).off( '.dragging' );
				isDragging = false;
            } );    
        } );
    } );
} );
$(document).ready(function(){
	$("#tree").mouseenter(function(){
		if(!isDragging){
			document.getElementById("tree").style.width = treeWidthWider;
		}
	})
	$("#tree").mouseleave(function(){
		document.getElementById("tree").style.width = treeWidth;
	})
	$("#tree").mousemove(function(e){
		var parentOffset = $(this).parent().offset(); 
		var relX = e.pageX - parentOffset.left;
        var $this = $( this );
		if(relX>$this.width()-10){
			$this.css({
				'cursor':'e-resize'
			});
		}else{
			$this.css({
				'cursor':'auto'
			});
		}
		try{
			if(document.selection){
				document.selection.empty()
			}else{
				window.getSelection().removeAllRanges()
			}
		}catch(err){}
	});
})
//end tree drag stuff
</script>

<script type="text/javascript">

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
<iframe style="display:none;background-color:black;z-index:99999;width:100%;height:100%;top:0;left:0;position:absolute;background:rgba(1,0,0,.7);filter: alpha(opacity = 0);border:none;" id="blackFrame" src="javascript:false;"></iframe>
<div style="display:none;background-color:black;z-index:100000;width:100%;height:100%;top:0;left:0;position:absolute;background:rgba(0,0,0,.7);filter: alpha(opacity = 80);" id="blackDiv"></div>
<iframe style="display:none;background-color:#eee;z-index:100001;width:90%;height:90%;top:40;left:40;position:absolute;padding:10px;" id="linkFrame" src="javascript:false;"></iframe>
<%If session("email")="support@arxspan.com" then%>
<input type="button" value="f" onclick='restCallA("/doAllAssaysSearchTool","POST",{});'>
<input type="button" value="g" onclick='restCallA("/getFTKeys","POST",{});'>
<%End if%>
<%If session("sessionTimeout") then%>
<%'inactivity div%>
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

<div>
	<ul id="treeContextMenu" class="contextMenu" style="width: 250px;">
		<!--<li><a href="#daughterPlate" id="tcm_daughterPlate">Daughter Plate</a></li>-->
		<li><a href="#add" id="tcm_add">Add</a></li>
		<%If session("canEditAssay") then%>
		<li><a href="#edit" id="tcm_edit">Edit</a></li>
		<%End if%>
		<li><a href="#view" id="tcm_view">View</a></li>
		<li><a href="#startRun" id="tcm_startrun">Start Run</a></li>
		<li><a href="#use" id="tcm_use">Use</a></li>
		<%If session("canMoveAssay") then%>
		<li><a href="#move" id="tcm_move">Move</a></li>
		<%End if%>
		<li><a href="#checkout" id="tcm_checkout">Check Out</a></li>
		<li><a href="#checkin" id="tcm_checkin">Check In</a></li>
		<li><a href="#dispose" id="tcm_dispose">Dispose</a></li>
	</ul>
</div>
<%sectionId="assay"%>
<!-- #include virtual="/arxlab/_inclds/header2.0.asp"-->
<!-- #include virtual="/arxlab/_inclds/nav_top_tool.asp"-->
<div style="margin:auto;position:relative" id="contentTable">
<div style="width:20%;float:left;margin-left:2%">
<div style="background-color:#ccc;height:600px;">
	<div id="aNav">
		<script type="text/javascript">
		function newInv(){
			pl = {"action":"add","collection":"inventory"};
			addObjectForm = restCall("/getForm/","POST",pl);
			formBucket.push(addObjectForm);
			addObjectForm.onSave = function(fd){
				return function(){
					if(validateForm(fd)){
						saveForm(fd,true);
						clearContainer('arxOneContainer');
						removeForm(fd.fid);
					}
				}
			}(addObjectForm);
			makeForm(addObjectForm,"arxOneContainer");
		}
		function showCompound(id){
			pl = {"action":"view","collection":"compound","id":id};
			addObjectForm = restCall("/getForm/","POST",pl);
			makeForm(addObjectForm,"arxOneContainer");
		}
		</script>
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
		<!--<a href="javascript:void(0);" onclick="newInv()">New Inv</a>-->
		<!--<a href="javascript:void(0);" onclick="showCompound(58605)">compound</a>-->
	</div>
	<div id="tree" class="assayTree" style="height:100%">

	</div>
	<script type="text/javascript">

		altCollectionName = "_type";//false
		defaultContainerName = "arxOneContainer";
		tableFds = [];
		tableFixedFields = [];
		dontRefreshTableLink = true;
		showParentLinks = false;

		function loadParentTree(parentTree,tree){
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
			if(!node.data.canCheckOut){
				fieldList.push("#checkout");				
			}
			if(!node.data.canCheckIn){
				fieldList.push("#checkin");				
			}
			if(!node.data.canDispose){
				fieldList.push("#dispose");				
			}
			if(!node.data.canStartRun || !hasStartRun){
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
				node.appendAjax({url: "/getTree//",
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
				handleLink(node.data.key,node.data.type,node.data.showTable)
			},
			imagePath: "images/treeIcons/"
		});

		function newPopup(id){
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
			if(node){
				if(!node.data.hideExpander){
					node.expand(true);
				}
			}else{
				node = tree.getActiveNode();
				if(node){
					node.expand(true);
				}
				node = tree.getNodeByKey(id.toString());
				if(node){
					node.expand(true);
				}else{
					if(parentTree){
						keyPath = "";
						for (var j=0;j<parentTree.length;j++){
							keyPath += "/"+parentTree[j]["id"];
						}
						if (keyPath != ""){
							//topNodes = ["","assayGroups","resultDefinitions","loadTemplates"];
							topNodes = ["assayGroups"];
							for( var i=0;i<topNodes.length;i++){
								topNode = topNodes[i];
								try{
									if(topNode!=""){
										thisKeyPath = topNode+keyPath;
									}else{
										thisKeyPath = keyPath;
									}
									tree.loadKeyPath(thisKeyPath, function(node, status){
										if(status == "loaded") {
											node.expand();
										}else if(status == "ok") {
											node.expand();
										}else if(status == "notfound") {
											var seg = arguments[2],
											isEndNode = arguments[3];
										}
									});
								}catch(err){}
							}
						}
					}
				}
			}
			clearContainer(containerName);
			//tableFields = ["Name","Structure","Amount","Unit Type","Supplier","CAS Number"];
			tableFields = [];
			if(collection!="checkedout" && collection!="disposed"){
				skip = false;
				if(collection == "assayGroups" || collection == "resultDefinitions" || collection == "loadTemplates"){
					if (collection == "resultDefinitions"){
						getList(false,false,{"parent.id":"resultDefinitions"},tableFields);
					}else{
						getList(false,false,{"_type":collection.substring(0,collection.length-1)},tableFields);
					}
					skip = true;
				}
				if(!skip){
					if(showTable){
						getList(false,false,{"parent.collection":"assayItems","parent.id":parseInt(id),"_type":{"$ne":"protocol"}},tableFields)
					}else{
						pl = {"action":"view","collection":collection,"id":id};
						addObjectForm = restCall("/getForm/","POST",pl);								
						makeForm(addObjectForm,containerName);
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
			var tree = $("#tree").dynatree("getTree");
			nodesToReload = [];
			nodesToActivate = []
			if(!containerName){
				containerName = defaultContainerName;
			}
			if(!!fd){
				if(!!altCollectionName){
					collection = fd.fields[fd.fieldNames.indexOf(altCollectionName)].value;
					parentCollection = fd.fields[fd.fieldNames.indexOf("Parent Collection")].value;
				}else{
					collection = fd.collection;
					parentCollection = fd.fields[fd.fieldNames.indexOf("Parent Collection")].value;
				}
				id = fd.id;
				parentTree = fd.parentTree;
				if(fd.fieldNames.indexOf("Amount")!=-1){
					amount = fd.fields[fd.fieldNames.indexOf("Amount")].value
				}
				if(fd.fieldNames.indexOf("Unit Type")!=-1){
					units = fd.fields[fd.fieldNames.indexOf("Unit Type")].value
				}
			}
			if(!!node){
				collection = node.data.type;
				parentCollection = node.data.parentCollection
				if(node.data.key=="loadTemplates" || node.data.key == "resultDefinitions" || node.data.key == "assayGroups"){
					id = node.data.key;
				}else{
					id = parseInt(node.data.key);
				}
				parentTree = node.data.parentTree;
				if (node.data.amount){
					amount = node.data.amount;
				}
				if (node.data.units){
					units = node.data.units;
				}
			}
			if(parentTree=="" || !parentTree){
				parentTree = [0];
			}
			if(action == "import"){
				nodesToReload.push(id);
				nodesToActivate.push(id)
				blackOn();
				popup = newPopup("addPopup");
				popup.style.width="300px"
				popup.style.height="200px"
				form = document.createElement("form");
				form.setAttribute("target","importUploadFrame");
				form.setAttribute("method","POST");
				form.setAttribute("action","upload-import-file.asp");
				form.setAttribute("ENCTYPE","multipart/form-data");
				label = document.createElement("label");
				label.innerHTML = "Upload File";
				form.appendChild(label);
				file = document.createElement("input");
				file.setAttribute("type","file");
				file.setAttribute("id","file");
				file.setAttribute("name","file");
				form.appendChild(file);
				h = document.createElement("input");
				h.setAttribute("type","hidden");
				h.setAttribute("name","parent");
				h.value = JSON.stringify({'collection':'assayItems',"id":id});
				form.appendChild(h);
				h = document.createElement("input");
				h.setAttribute("type","hidden");
				h.setAttribute("name","importObjectType");
				h.value = "plate";
				form.appendChild(h);
				submitButton = document.createElement("input");
				submitButton.setAttribute("type","submit");
				submitButton.value = "Upload";
				form.appendChild(submitButton);

				popup.appendChild(form);


				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
			}

			if(action == "daughterPlate"){
				nodesToReload.push(id);
				nodesToActivate.push(id)
				blackOn();
				popup = newPopup("daughterPopup");
				popup.style.width="300px"
				popup.style.height="420px"
				label = document.createElement("label");
				label.innerHTML = "New Barcode";
				popup.appendChild(label);
				newBarcode = document.createElement("input");
				newBarcode.setAttribute("type","text");
				popup.appendChild(newBarcode);
				label = document.createElement("label");
				label.innerHTML = "Plate A Barcode";
				popup.appendChild(label);
				aBarcode = document.createElement("input");
				aBarcode.setAttribute("type","text");
				popup.appendChild(aBarcode);
				label = document.createElement("label");
				label.innerHTML = "Plate B Barcode";
				popup.appendChild(label);
				bBarcode = document.createElement("input");
				bBarcode.setAttribute("type","text");
				popup.appendChild(bBarcode);
				label = document.createElement("label");
				label.innerHTML = "Plate C Barcode";
				popup.appendChild(label);
				cBarcode = document.createElement("input");
				cBarcode.setAttribute("type","text");
				popup.appendChild(cBarcode);
				label = document.createElement("label");
				label.innerHTML = "Plate D Barcode";
				popup.appendChild(label);
				dBarcode = document.createElement("input");
				dBarcode.setAttribute("type","text");
				popup.appendChild(dBarcode);
				label = document.createElement("label");
				label.innerHTML = "Amount";
				popup.appendChild(label);
				amount = document.createElement("input");
				amount.setAttribute("type","text");
				popup.appendChild(amount);

				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(newBarcode,aBarcode,bBarcode,cBarcode,dBarcode,amount,node){
					return function(){
						button.setAttribute("value","Loading Please Wait");
						args = {
							"newBarcode":newBarcode.value,
							"aBarcode":aBarcode.value,
							"bBarcode":bBarcode.value,
							"cBarcode":cBarcode.value,
							"dBarcode":dBarcode.value,
							"amount":amount.value,
							"parent":{"collection":"assayItems","id":id}
						};
						pl = {}
						pl["args"] = args;
						restCallA("/daughterPlate/","POST",pl,function(r){
								if(r.errors.length == 0){
									handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
									el = document.getElementById("daughterPopup");
									el.parentNode.removeChild(el);
									blackOff();
								}else{
									alert(r.errors.join("\n"));
								}
								button.setAttribute("value","OK");
							}
						);
					}
				})(newBarcode,aBarcode,bBarcode,cBarcode,dBarcode,amount,node);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
			}

			if(action == "add"){
				nodesToReload.push(id);
				nodesToActivate.push(id);
				blackOn();
				popup = newPopup("addPopup");
				popup.style.width="300px"
				popup.style.height="200px"
				label = document.createElement("label");
				label.innerHTML = "Type to Add";
				popup.appendChild(label);
				addTypes = restCall("/getAllowedChildren/","POST",{"type":collection,"parentType":parentCollection});
				select = document.createElement("select");
				select.setAttribute("id","addType");
				for(var i=0;i<addTypes.length;i++){
					option = document.createElement("option");
					thisText = addTypes[i];
					option.setAttribute("value",thisText);
					if(thisText=="resultDefinition"){
						thisText = "Result Type";
					}
					option.appendChild(document.createTextNode(thisText));
					select.appendChild(option);
				}
				popup.appendChild(select);
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(select,node){
					return function(){
						clearContainer(containerName);
						collection = select.options[select.selectedIndex].value;
						pl = {"action":"add","collection":collection,"parent":{"collection":"assayItems","id":id}};
						addObjectForm = restCall("/getForm/","POST",pl);
						formBucket.push(addObjectForm);
						addObjectForm.onSave = function(fd,node){
							return function(){
								if(validateForm(fd)){
									newId = saveForm(fd,true)["newId"];
									clearContainer(containerName);
									handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
									removeForm(fd.fid);
									pl = {"action":"view","collection":collection,"id":newId};
									restCallA("/getForm/","POST",pl,function(addObjectForm){
											clearContainer(containerName);
											makeForm(addObjectForm,containerName);
										}
									);
									
								}
							}
						}(addObjectForm,node);
								
						makeForm(addObjectForm,containerName);
						el = document.getElementById("addPopup");
						el.parentNode.removeChild(el);
						blackOff();
					}
				})(select,node);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
			}
			if(action == "edit"){
				nodesToReload.push(parentTree[parentTree.length-1]["id"])
				//nodesToActivate.push(id)
				clearContainer(containerName);
				pl = {"action":"edit","collection":collection,"id":id};
				addObjectForm = restCall("/getForm/","POST",pl);
				formBucket.push(addObjectForm);
				addObjectForm.onSave = function(fd,node){
					return function(){
						if(validateForm(fd)){
							saveForm(fd,true);
							updateTableValues(fd,true);
							clearContainer(containerName);
							handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
							removeForm(fd.fid);
							if(containerName=="arxOneContainer"){
								pl = {"action":"view","collection":collection,"id":id};
								addObjectForm = restCall("/getForm/","POST",pl);								
								makeForm(addObjectForm,containerName);
							}
						}
					}
				}(addObjectForm,node);
						
				makeForm(addObjectForm,containerName);
				//el = document.getElementById("addPopup");
				//el.parentNode.removeChild(el);
			}
			if(action == "view"){
				clearContainer(containerName);
				pl = {"action":"view","collection":collection,"id":id};
				addObjectForm = restCall("/getForm/","POST",pl);								
				makeForm(addObjectForm,containerName);
			}
			if(action == "checkout"){
				nodesToReload.push(parentTree[0]["id"].toString()+"_checkedout");
				nodesToReload.push(parentTree[parentTree.length-1]["id"]);
				nodesToActivate.push(parentTree[parentTree.length-1]["id"]);
				pl = {"collection":collection,"id":id,"fieldName":"checkedOut","value":true};
				addObjectForm = restCall("/updateFieldById/","POST",pl);
				handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
			}
			if(action == "checkin"){
				nodesToReload.push(parentTree[0]["id"].toString()+"_checkedout");
				nodesToReload.push(parentTree[parentTree.length-1]["id"]);
				nodesToActivate.push(parentTree[parentTree.length-1]["id"]);
				pl = {"collection":collection,"id":id,"fieldName":"checkedOut","value":false};
				addObjectForm = restCall("/updateFieldById/","POST",pl);
				handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
			}
			if(action == "use"){			
				blackOn();
				popup = newPopup("usePopup");
				popup.style.width="300px"
				popup.style.height="200px"
				label = document.createElement("label");
				label.innerHTML = "Use";
				popup.appendChild(label);
				span = document.createElement("span");
				span.innerHTML = "<em>Amount Remaining:</em> "+amount+" "+units;
				popup.appendChild(span);
				textBox = document.createElement("input");
				textBox.setAttribute("type","text");
				popup.appendChild(textBox);
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(textBox,node){
					return function(){
						pl = {"collection":collection,"id":id,"fieldName":"amount","value":parseFloat(textBox.value)};
						fd = restCall("/decrementFieldById/","POST",pl);
						updateTableValues(fd,true);
						clearContainer(containerName);
						el = document.getElementById("usePopup");
						el.parentNode.removeChild(el);
						blackOff();
						if(containerName=="arxOneContainer"){
							pl = {"action":"view","collection":collection,"id":id};
							addObjectForm = restCall("/getForm/","POST",pl);								
							makeForm(addObjectForm,containerName);
						}
					}
				})(textBox,node);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
			}
			if(action == "move"){			
				nodesToReload.push(parentTree[parentTree.length-1]["id"])
				nodesToActivate.push(parentTree[parentTree.length-1]["id"])
				blackOn();
				popup = newPopup("movePopup");
				popup.style.width="300px"
				popup.style.height="500px"
				label = document.createElement("label");
				label.innerHTML = "New Location";
				popup.appendChild(label);
				div = document.createElement("div")
				div.setAttribute("id","treeMove");
				popup.appendChild(div);
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(id,collection,tree){
					return function(){
						node = $("#treeMove").dynatree("getActiveNode")
						targetType = node.data.type;
						allowedChildren = restCall("/getAllowedChildren/","POST",{"type":targetType,"parentType":parentCollection});
						if(allowedChildren.indexOf(collection)!=-1){
							nodesToReload.push(node.data.key)
							restCall("/moveItem/","POST",{"id":id,"collection":collection,"targetId":parseInt(node.data.key)})
							clearContainer(containerName);
							handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
							el = document.getElementById("movePopup");
							el.parentNode.removeChild(el);
							blackOff();
						}else{
							alert("Item may not be moved to this location.")
						}
					}
				})(id,collection,tree);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				$("#treeMove").dynatree({
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
					imagePath: "images/treeIcons/"
				});
			}
			if(action == "dispose"){
				nodesToReload.push(parentTree[0]["id"].toString()+"_disposed")
				nodesToReload.push(parentTree[parentTree.length-1]["id"])
				nodesToActivate.push(parentTree[parentTree.length-1]["id"])
				pl = {"collection":collection,"id":id,"fieldName":"disposed","value":true};
				addObjectForm = restCall("/updateFieldById/","POST",pl);								
				handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
			}
			if(action == "startRun"){
				pl = {"id":id};
				r = restCall("/startRun/","POST",pl);
				alert(r["url"]);
				window.location = r["url"];
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
			left:400px;
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
	</style>
</div>
</div>
<div style="width:75%;background-color:#eee;float:left;margin-left:2%" valign="top">
<div id="contentDiv">