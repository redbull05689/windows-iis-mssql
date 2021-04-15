<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/jsRev.asp" -->
<!-- #include file="../../_inclds/security/functions/fnc_getUsersICanSee.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
If request.querystring("inFrame") = "true" Then
	inFrame = True
Else
	inFrame = false
End if
%>
<%
If request.querystring("addFromELN") = "true" Then
	addFromELN = True
Else
	addFromELN = false
End if

If request.querystring("addFromREG") = "true" Then
	addFromREG = True
Else
	addFromREG = false
End if
If request.querystring("bulkAddFromREG") = "true" Then
	bulkAddFromREG = True
Else
	bulkAddFromREG = false
End if
If request.querystring("bulkMoveRegItems") = "true" Then
	bulkMoveRegItems = True
Else
	bulkMoveRegItems = false
End if
Response.CharSet = "UTF-8"
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title><%=pageTitle%></title>
<meta name="description" content="<%=metaDesc%>" />
<meta name="keywords" content="<%=metaKey%>" />

<%If isObjectTemplates OR isMappingTemplates OR isManageConfigurationPage then%>
	<base href="<%=mainAppPath%>/workflow/">
<%End if%>
<!-- new ft stuff-->
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/arxspan_global_styles.css?<%=jsRev%>">
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/transitionStyles.css?<%=jsRev%>">
<link href="<%=mainCSSPath%>/latofont.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<script type="text/javascript" src="js/jquery-1.11.1.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/arxlayout.js?<%=jsRev%>"></script>

<script type="text/javascript">
	var jwt = "<%=session("jwtToken")%>";
	$( document ).ready(function() 
	{
		var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");
        var edge = ua.indexOf("Edge");
    	if (edge > 0 || msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) 
    	{
 			window.top.swal(
			{
        	title: "",
        	text: "Workflow is not supported in the current browser, navigate back to dashboard.",
        	type: "error",
        	confirmButtonText: "Return to Dashboard!",
      		},
			function(isConfirm)
			{
				window.top.window.location.replace("<%=mainAppPath%>/dashboard.asp");
			} 
			);
    	}
	
	});
	</script>

<% if lcase(session("email")) = "support@arxspan.com" then %>
<script> var isSupport = true; </script>
<% else %>
<script> var isSupport = false; </script>
<% end if %>

<link href="<%=mainAppPath%>/js/select2-3.5.1/select2.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>

<script type="text/javascript" src="<%=mainAppPath%>/js/isotope.pkgd.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.placeholder.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
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
<link href="<%=mainCSSPath%>/styles-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="<%=mainCSSPath%>/popup_styles.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/menu-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<link href="css/contextMenu.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/selectize.default.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">

<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/md5-min.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js?<%=jsRev%>"></script>

<%
	If whichServer <> "DEV" Then
%>
<script type="text/javascript" src="js/disableConsole.js?<%=jsRev%>"></script>
<%
	End if
%>

<script>
hasMarvin = <%=LCase(CStr(session("useMarvin")))%>
function _base64ToArrayBuffer(base64) {
	return _base64ToArray(base64).buffer;
}

function _base64ToArray(base64) {
	var binary_string =  window.atob(base64);
	var len = binary_string.length;
	var bytes = new Uint8Array( len );
	for (var i = 0; i < len; i++)        {
		bytes[i] = binary_string.charCodeAt(i);
	}
	return bytes;
}

</script>

<script type="text/javascript" src="js/serviceEndpoints.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../util/resumableFunctions.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/workflowUtilities.min.js?<%=jsRev%>"></script>
<!-- #include file="fetchDataTypes.asp"-->
<script type="text/javascript" src="js/requestItemTableHelpers.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/requestFieldHelper.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/elnAutomation.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../js/resumableModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/dataTableModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/tableFileUploadModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/fieldsModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/requestEditorModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/ajaxModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/arxWorkflow.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/sdFileModule.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/BiIntegration/biIntegration.min.js?<%=jsRev%>"></script>
<script type="text/javascript">
	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>
</script>
<!-- BOOTSTRAP STUFF - DISABLED FOR NOW -->
<script type="text/javascript" src="../common/popper.js-1.12.3/dist/umd/popper.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../common/bootstrap-3.3.5/js/bootstrap.js?<%=jsRev%>"></script>
<link href="../common/bootstrap-3.3.5/css/bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<!-- Material Dashboard -->
<link href="css/material-dashboard.css" rel="stylesheet"/>
<link href="css/font-awesome.min.css" rel="stylesheet">
<link href="css/material-dashboard.roboto-with-icons.css" rel="stylesheet" type="text/css">
<script src="js/material.min.js" type="text/javascript"></script>
<script src="js/bootstrap-notify.js?<%=jsRev%>"></script>
<script src="js/material-dashboard.js?<%=jsRev%>"></script>
<script src="../js/common/bootstrap-notify.min.js?<%=jsRev%>"></script>
<link href="css/jquery.dataTables.1.10.15.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/dataTables.1.10.15.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/jquery.dataTables.1.10.15.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/dataTables.1.10.15.bootstrap.min.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/dataTableSortModule.min.js?<%=jsRev%>"></script>

<link href="css/colReorder.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/dataTables.colReorder.min.js?<%=jsRev%>"></script>

<link href="css/rowReorder.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/dataTables.rowReorder.js?<%=jsRev%>"></script>

<link href="css/fixedHeader.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/dataTables.fixedHeader.min.js?<%=jsRev%>"></script>

<link href="css/fixedColumns.bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/dataTables.fixedColumns.min.js?<%=jsRev%>"></script>

<link href="css/jquery.dataTables.yadcf.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="js/jquery.dataTables.yadcf.js?<%=jsRev%>"></script>

<script type="text/javascript" src="../js/arxPlate/sdfParser.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/moment-with-locales.js?<%=jsRev%>"></script>
<script src="../js/moment.min.js"></script>
<script src="../js/datetime-moment.js"></script>

<link href="../css/pikaday.1.6.1.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<!-- Load pikaday.js and then its jQuery plugin -->
<script type="text/javascript" src="../js/pikaday.1.6.1.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../js/pikaday.1.6.1.jquery.js?<%=jsRev%>"></script>

<link href="../js/sweetalert1/sweetalert.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<script type="text/javascript" src="../js/sweetalert1/sweetalert.min.js?<%=jsRev%>"></script>

<link rel="stylesheet" type="text/css" href="../inventory2/arxDraw/css/jquery.mCustomScrollbar.css"> <!-- Malihu Scroll bar -->
<script type="text/javascript" src="../inventory2/arxDraw/js/jquery.mCustomScrollbar.concat.min.js?<%=jsRev%>"></script>  <!-- Malihu Scroll bar -->

<!-- More jQuery.Lazy() plugin files available... -->
<script type="text/javascript" src="js/jquery.lazy.min.js?<%=jsRev%>"></script>

<link href="css/workflowStyles.css" rel="stylesheet" type="text/css" MEDIA="screen">

<style type="text/css">@import url(js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>

<script type="text/javascript" src="js/jquery.csv.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="../js/resumable.js?<%=jsRev%>"></script>

<!-- jquery for dynatree -->
<script src='js/dynatree/jquery/jquery-ui.custom.js?<%=jsRev%>' type="text/javascript"></script>
<script src='js/dynatree/jquery/jquery.cookie.js?<%=jsRev%>' type="text/javascript"></script>
<!-- dynatree -->

<script type="text/javascript" src="js/json2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/getFile.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/arxXml.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/arxOne.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/popups.js?<%=jsRev%>"></script>
<script type="text/javascript" src="js/advancedSearch.js?<%=jsRev%>"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript" src="js/download.js?<%=jsRev%>"></script>

<%If inframe then%>
<!-- only when inframe -->
<link rel="stylesheet" type="text/css" href="css/inframePatch.css" />
<script type="text/javascript">
var inIframe = true;
</script>
<!-- end only when in iframe -->
<%Else%>
<script type="text/javascript">
var inIframe = false;
</script>
<%end if%>

<script type="text/javascript" src="js/selectize.min.js?<%=jsRev%>"></script>

<!--invPerm-->
<script type="text/javascript" src="js/perm.js?<%=jsRev%>"></script>
<!-- end invPerm-->

<script type="text/javascript">
autoClickAdd = false;
inFrame = false;
autoClickValue = "";
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

<%
session("canAdd") = True
If session("invRoleName") = "Admin" Or session("invRoleName") = "Power User" Then
	session("canDispose") = True
Else
	session("canDispose") = False
End if
If session("invRoleName") = "Admin" Or session("invRoleName") = "Power User" Then
	session("canEdit") = True
Else
	session("canEdit") = False
End if
If session("invRoleName") = "Admin" Or session("invRoleName") = "Power User" Then
	session("canImport") = True
Else
	session("canImport") = False
End if
%>

<!-- #include file="../../_inclds/common/asp/checkLoginAndResetInactivityTimer.asp"-->

<!-- #include file="../getGlobalUserInfo.asp"-->
<!-- #include file="../getUsersAndUserGroups.asp"-->

<script type="text/javascript">

connectionId = '<%=session("servicesConnectionId")%>';

inputData = {
	"connectionId": connectionId,
	"userId": <%=session("userId")%>,
	'whichClient':'<%=replace(whichClient,"'","\'")%>'
}

globalUserInfo = JSON.parse('<%=userInfo%>');
usersList = JSON.parse(`<%=userArray%>`);
groupsList = JSON.parse(`<%=groupArray%>`);
whichClient = '<%=replace(whichClient,"'","\'")%>'
canAdd = <%=lcase(session("canAdd"))%>;
canEdit = <%=lcase(session("canEdit"))%>;
canImport = <%=lcase(session("canImport"))%>;
canUpdate = <%=lcase(session("canImport"))%>;
canDispose = <%=lcase(session("canDispose"))%>;
chemTable = globalUserInfo["inventoryStructuresTable"];
companyId = globalUserInfo["companyId"];
hasFireControl = globalUserInfo["hasFireControl"];
hasReceiving = globalUserInfo["hasReceiving"];
hasAuditTrail = globalUserInfo["hasAuditTrail"];
chemistryInSearch = true;
whichServer = "<%=whichServer%>";
chemSearchDbName = "structureId.cd_id";
workflowServiceEndpointUrl = "<%=getCompanySpecificSingleAppConfigSetting("workflowServiceEndpointUrl", session("companyId"))%>";
//tree dragging stuff
var treeWidth = 164;
var treeWidthWider = 164;
var isDragging = false;
$(function(){
	$('#tree ul:first-child').on( 'scroll', function(ev){
		$( document ).off( '.dragging' );
		$('#tree').css( {
			'width'      : (treeWidthWider) + 'px'
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
				if (isDragging){
					treeWidthWider = thisWidth+ev.pageX-x;
					if(treeWidthWider<treeWidth){
						treeWidthWider = treeWidth;
					}
				}
				isDragging = false;
            } );    
        } );
    } );
} );
$(document).ready(function(){
	$("#tree").mouseenter(function(){
		if(!isDragging){
			document.getElementById("tree").style.width = treeWidthWider+"px";
		}
	})
	$("#tree").mouseleave(function(){
		document.getElementById("tree").style.width = treeWidth+"px";
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

function initMappingInterface(id,sourceType,destinationType,mappingCategory,popupId,loadingSavedFieldMap){
	var requiredUniqueFields = makeSamplePopupRequiredUniqueFieldsValuesObject();
	if(requiredUniqueFields == "error"){
		return false;
	}

	if(mappingCategory == "bulkImport_bulkUpdate"){
		// This mapping template is based on a bulk import/update so the source is just a string of column names - must make it match the format of requests that we make for normal field mapping templates
		fieldsArray = []
		$.each(sourceType.split(','), function(){
			objectToAdd = {"formName": this, "required": false, "value": "", "dbType": "text", "fieldType": "text"}
			fieldsArray.push(objectToAdd)
		})
		addObjectForm = {"fields": fieldsArray}
		
		// Rather than create a new mappingInit function because our source is incompatible, use the destinationType for source & destination types & modify the result...
		r = restCall("/mappingInit/","POST",{"lineageParentId":id,"collection":destinationType,"type":destinationType})
		r['sourceColumnKeys'] = fieldsArray
	}
	else{
		pl = {"action":"view","collection":sourceType,"id":id};
		addObjectForm = restCall("/getForm/","POST",pl);
		r = restCall("/mappingInit/","POST",{"lineageParentId":id,"collection":sourceType,"type":destinationType})
	}
	
	if(r['sourceColumnKeys'].length > 0 && r['destinationColumnKeys'].length > 0){
		/* SUCCESS */
		if(popupId){	
			$('#'+popupId).addClass('mapFields').removeClass('initialPage')
		}
		
		// First build up a <select> to add to each destination field
		var sourceColumnDropdown_all = '<select class="sourceFieldsDropdown"><option value="">--Blank--</option>';
		var sourceColumnDropdown_dates = '<select class="sourceFieldsDropdown"><option value="">--Blank--</option>';
		var sourceColumnDropdown_numbers = '<select class="sourceFieldsDropdown"><option value="">--Blank--</option>';
		var sourceColumnDropdown_none = '<select class="sourceFieldsDropdown"><option value="">--Blank--</option></select>'
		$.each(r['sourceColumnKeys'],function(sourceFieldIndex, sourceField){
			var sourceFieldValueParentheses = "";
			var sourceFieldRequired = "";
			$.each(addObjectForm['fields'],function(){
				if(this['formName'] == sourceField['formName']){
					if(!loadingSavedFieldMap){
						if(typeof this['value'] == "undefined" || this['value'] == null){
							this['value'] = "";
						}
						sourceFieldValueParentheses = this['value'].toString().substring(0, 45);
						if(sourceFieldValueParentheses.length == 45){
							sourceFieldValueParentheses += "...";
						}
						sourceFieldValueParentheses = ' (value: "'+sourceFieldValueParentheses+'")'
					}
					if(this['required'] == true){
						sourceFieldRequired = "*";
					}
					return false;
				}
			})
			sourceColumnDropdown_all += '<option value="'+sourceField['formName']+'">'+sourceField['formName']+sourceFieldRequired+sourceFieldValueParentheses+'</option>'
			if(sourceField['fieldType'] == "date"){
				sourceColumnDropdown_dates += '<option value="'+sourceField['formName']+'">'+sourceField['formName']+sourceFieldRequired+sourceFieldValueParentheses+'</option>'
			}
			else if(sourceField['dbType'] == "actual_number"){
				sourceColumnDropdown_numbers += '<option value="'+sourceField['formName']+'">'+sourceField['formName']+sourceFieldRequired+sourceFieldValueParentheses+'</option>'
			}
		});
		sourceColumnDropdown_all += '</select>'
		sourceColumnDropdown_dates += '</select>'
		sourceColumnDropdown_numbers += '</select>'

		var fieldMappingHeader = '<div class="fieldMappingHeader"><div class="fieldMappingHeader_destination">Destination ('+destinationType+')</div><div class="fieldMappingHeader_source">Source ('+sourceType+')</div></div>'
		var destinationFieldsHTML = "";
		$.each(r['destinationColumnKeys'],function(destinationFieldIndex, destinationField){
			destinationFieldAsterisk = "";
			if(destinationField['required'] == true){ destinationFieldAsterisk = "*" }
			var correctDropdown = sourceColumnDropdown_all;
			if(destinationField['fieldType'] == "date"){
				correctDropdown = sourceColumnDropdown_dates;
			}
			else if(destinationField['dbType'] == "actual_number"){
				correctDropdown = sourceColumnDropdown_numbers;
			}
			else if(destinationField['fieldType'] == "select"){
				correctDropdown = sourceColumnDropdown_none;
				// If the source & destination item types are the same, they must have matching dropdown fields so we're going to give a dropdown with "--Blank--" & the current value in the source's matching field
				if(sourceType == destinationType){
					$.each(addObjectForm['fields'],function(){
						if(this['formName'] == destinationField['formName']){
							sourceFieldValueParentheses = ""
							if(!loadingSavedFieldMap){
								sourceFieldValueParentheses = ' (value: "'+this['value']+'")'
							}
							correctDropdown = '<select class="sourceFieldsDropdown"><option value="">--Blank--</option><option value="'+this['formName']+'">'+this['formName']+sourceFieldValueParentheses+'</option></select>'
						}
					});
				}
			}
			destinationFieldsHTML += '<div class="destinationFieldContainer" fieldname="'+destinationField['formName']+'"><label>' + destinationField['formName'] + destinationFieldAsterisk + '</label>' + '<div class="sourceFieldsDropdownContainer">' + correctDropdown + '</div></div>'
		});
		$('#fieldMappingDiv').html(fieldMappingHeader + destinationFieldsHTML)
		if(!loadingSavedFieldMap){
			$('.destinationFieldContainer').each(function(){
				$(this).find('.sourceFieldsDropdown > option[value="'+$(this).attr('fieldname')+'"]').prop('selected',true) // Select fields w/ the same names
			});
		}
	}else{
		swal("Error loading mapping interface","The source and/or destination object type's fields did not load properly. Please try again or contact Arxspan Support.","error")
	}
}

function makeFieldNamePairsFromMap(mapId){
	var fieldNamePairs = {};
	$('#' + mapId).find('.destinationFieldContainer').each(function(){
		var destinationFieldName = $(this).attr('fieldname');
		var sourceField = $(this).find('.sourceFieldsDropdown').val();
		fieldNamePairs[destinationFieldName] = sourceField;
	});
	console.log(fieldNamePairs);
	return fieldNamePairs;
}

function updateMappingTemplateDropdown(dropdownId, mappingTemplatesArray, sourceType, destinationType){
	dropdownOptionsHTML = '<option value="custom" selected>-- Choose Mapping Template --</option>'
	$.each(mappingTemplatesArray,function(index, mappingTemplate){
		console.log(mappingTemplate)
		if(this['sourceType'] == sourceType && this['destinationType'] == destinationType){
			dropdownOptionsHTML += '<option value="'+index+'">' + mappingTemplate['mappingTemplateName'] + '</option>'
		}
	});
	$('#'+dropdownId).empty().append(dropdownOptionsHTML).change();
}

function makeFieldNamePairsFromOldFieldMappingTable(classOfTableToMapFrom){
	var tableToMapFrom = $('.' + classOfTableToMapFrom);
	var fieldMap = {}
	tableToMapFrom.find('tr:not(:first-of-type)').each(function(){
		var key = $(this).find('td:first-of-type').html()
		var value = $(this).find('td:nth-of-type(2) select option:selected').val()
		fieldMap[key] = value;
	});
	return fieldMap;
}

function loadFieldMapIntoOldFieldMappingTable(classOfTableToMapFrom,mappingTemplateIndex){
	mappingTemplate = window.bulkImport_bulkUpdateMappingTemplates[mappingTemplateIndex];
	$('.' + classOfTableToMapFrom).find('tbody tr:not(:first-of-type) td:nth-of-type(2) select').each(function(){
		var valueToSelect = mappingTemplate['fieldMap'][$(this).attr('formname')];
		$(this).find('option[value="'+valueToSelect+'"]').prop('selected',true);
		$(this).change();
	});
}
</script>

</head>
<body>

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
<%End If ' When copied from Inventory, this sessionTimeout block didn't end here... %>

<%If Not inFrame then%>
<%sectionId="workflow"%>
<!-- #include virtual="/arxlab/_inclds/header2.0.asp"-->
<!-- #include virtual="/arxlab/_inclds/nav_top_tool.asp"-->
<%End if%>

<div class="wrapper">
    <div class="sidebar" data-color="materialblue">

		<!--
	        Tip 1: You can change the color of the sidebar using: data-color="purple | blue | green | orange | red"

	        Tip 2: you can also add an image using data-image tag
	    -->
	    <!--
		<div class="logo">
			<a href="http://www.creative-tim.com" class="simple-text">
				Arxspan
			</a>
		</div>
		-->
				
    	<div class="sidebar-wrapper">
            <ul class="nav">
			    <li class="sidebarItem_eln_dashboard">
                    <a href="/arxlab/dashboard.asp">
                        <i class="material-icons">A</i>
                        <p>Nav Bar</p>
                    </a>
							
						<ul class="nav sub-nav">
							<li class="sidebarItem_eln_dashboard_link elnSidebar">
								<a href="/arxlab/dashboard.asp">
									<i class="material-icons">dashboard</i>
									<p>Dashboard</p>
								</a>
							</li>
							<li class="sidebarItem_ELNWatchlist elnSidebar">
								<a href="/arxlab/table_pages/show-watchlist.asp">
									<i class="material-icons">content_paste</i>
									<p>Watchlist</p>
								</a>
							</li>
							<li class="sidebarItem_ELNNotebooks elnSidebar">
								<a href="/arxlab/table_pages/show-notebooks.asp?all=true">
									<i class="material-icons">library_books</i>
									<p>Notebooks</p>
								</a>
							</li>
							<li class="sidebarItem_ELNProjects elnSidebar">
								<a href="/arxlab/table_pages/show-projects.asp">
									<i class="material-icons">timeline</i>
									<p>Projects</p>
								</a>
							</li>
							<li class="sidebarItem_contactSupport elnSidebar">
								<a href="/arxlab/support-request.asp">
									<i class="material-icons">help</i>
									<p>CONTACT SUPPORT</p>
								</a>
							</li>
							<li class="sidebarItem_logout elnSidebar">
								<a href="/arxlab/logout.asp">
									<i class="material-icons">arrow_back</i>
									<p>Logout</p>
								</a>
							</li>
						</ul>

                </li>
                <li class="sidebarItem_dashboard">
                    <a href="<%=mainAppPath%>/workflow/">
                        <i class="material-icons">dashboard</i>
                        <p>My Requests</p>
                    </a>
                </li>
                <li class="sidebarItem_makeNewRequest">
                    <a href="makeNewRequest.asp">
                        <i class="material-icons">add</i>
                        <p>Submit New Request</p>
                    </a>
                </li>
                <li class="sidebarItem_manageRequests">
                    <a href="manageRequests.asp">
                        <i class="material-icons">content_paste</i>
                        <p>Manage Requests</p>
                    </a>
                </li>
			</ul>
	
			<ul class="nav separatingLineAbove">
				<li class="sidebarItem_userSettings">
					<a href="userSettings.asp">
	                    <i class="material-icons">person</i>
	                    <p>User Settings</p>
		    		</a>
		    	</li>
		    </ul>
			<ul id="workflowAdminNavMenu" class="nav" <% if session("role") <> "Admin" and session("manageWorkflow") = false then %>style="display:none;"<%End If%>>
                <li class="sidebarItem_adminConfiguration">
                    <a href="#" class="" aria-expanded="true">
                        <i class="material-icons">settings</i>
                        <p>Admin Configuration</p>
                    </a>
                    <div class="collapse in" aria-expanded="true" style="">
                        <ul class="nav">
                            <li class="sidebarItem_manageDropdowns">
                                <a href="manageConfiguration/editDropdowns.asp">
                                    <span class="sidebar-mini">D</span>
                                    <span class="sidebar-normal">Dropdowns</span>
                                </a>
                            </li>
                            <li class="sidebarItem_manageFields workflowAdminFields">
                                <a href="manageConfiguration/editFields.asp">
                                    <span class="sidebar-mini">F</span>
                                    <span class="sidebar-normal">Fields</span>
                                </a>
                            </li>
                            <li class="sidebarItem_manageRequestTypes workflowAdminFields">
                                <a href="manageConfiguration/editRequestTypes.asp">
                                    <span class="sidebar-mini">RT</span>
                                    <span class="sidebar-normal">Request Types</span>
                                </a>
                            </li>
                            <li class="sidebarItem_manageRequestItemTypes workflowAdminFields">
                                <a href="manageConfiguration/editRequestItemTypes.asp">
                                    <span class="sidebar-mini">RIT</span>
                                    <span class="sidebar-normal">Request Item Types</span>
                                </a>
                            </li>
                        </ul>
                    </div>
                </li>
            </ul>
    	</div>
	</div>
	<div id="BioDiv"></div>
    <div class="main-panel">
		<% if not inFrame then %>
			<nav class="navbar navbar-transparent navbar-absolute">
				<div class="container-fluid">
					<div class="navbar-header">
						<button type="button" class="navbar-toggle" data-toggle="collapse">
							<span class="sr-only">Toggle navigation</span>
							<span class="icon-bar"></span>
							<span class="icon-bar"></span>
							<span class="icon-bar"></span>
						</button>
						<a class="navbar-brand" href="#">Workflow</a>
					</div>
					
					<ul class="nav navbar-nav navbar-right notificationsSectionUL">
						<li class="dropdown">
							<a href="#" class="dropdown-toggle notifications-dropdown-toggle" data-toggle="dropdown" id="notificationsDropdownToggle">
								<i class="material-icons">notifications</i>
								<span class="notification"></span>
								<span id="reactNotificationCount">0</span>
							</a>
						</li>
						<div id="reactNotificationHolder"></div>
					</ul>
				</div>
			</nav>
		<% end if %>

        <% if not inFrame then %>
        <div class="content">
            <div class="container-fluid">
        <% else %>
        <div class="content nopadding">
            <div class="container-fluid nopadding">
        <% end if %>
                
<script type="text/javascript" src="../_inclds/CKE/CKE5-Standard-Editing/build/ckeditor.js?<%=jsRev%>"></script>

<script>
/*
	$(".sidebarItem_eln_dashboard").on("mouseover", function() {
		if ($(".sidebar-wrapper-eln").css("display") == "none") {
			$(".sidebar-wrapper-eln").show("fast", function() {
				$(this).stop(true, false);
			});
		}
	});

	$(".sidebarItem_eln_dashboard").on("mouseleave", function(target) {
		if (!$(".sidebar-wrapper-eln").is(":hover") && target.toElement != $("li.sidebarItem_eln_dashboard_link.elnSidebar")[0]) {
			$(".sidebar-wrapper-eln").stop(true, true).hide("slow");
		}
	});

	$(".sidebar-wrapper-eln").bind("mouseenter", function(e) {
		$(this).stop(true, false);
	}).bind("mouseleave", function(e) {
		$(this).hide();
		//$(this).stop(true, true);
	})
	*/
</script>

<%
	workflowexcelimportparentrowindcolname = getCompanySpecificSingleAppConfigSetting("workflowExcelImportParentRowIndColName", session("companyId"))
%>

<link rel="stylesheet" href="js/React/react-table.css">
<!-- #include file="reactIncludes.asp"-->
<script src="js/React/babel6.min.js" charset="utf-8"></script>
<script>
  var ReactTable = window.ReactTable.default;
  var changeObj = {}
  var originalObj = {}

  isWorkflowManager = "<%=session("isWorkflowManager")%>" == "true";
  excelImportParentRow = "<%=workflowexcelimportparentrowindcolname%>";
</script>


<script type="text/babel" src="js/React/commonReactElements.js?<%=jsRev%>"></script>
<script type="text/babel" src="js/React/notificationComponent.js?<%=jsRev%>"></script>
<link rel="stylesheet" href="js/React/notificationComponent.css">
