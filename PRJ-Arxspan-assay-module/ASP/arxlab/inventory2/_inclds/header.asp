<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/jsRev.asp" -->
<!-- #include file="../../_inclds/security/functions/fnc_getUsersICanSee.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
inventoryIgnoreTableFields = checkBoolSettingForCompany("ignoreTableFieldsInInventory", session("companyId"))
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
If request.querystring("inFrame") = "true" Then
	inFrame = True
Else
	inFrame = false
End if
%>
<%
If request.querystring("barcodeChooser") = "true" Then
	barcodeChooser = True
Else
	barcodeChooser = False
End if
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

addFromNonChemELN = false
If request.querystring("addFromNonChemELN") = "true" then
	addFromNonChemELN = true
end if

addAfterRegFromELN = false
If request.querystring("addAfterRegFromELN") = "true" then
	addAfterRegFromELN = true
end if


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%If isObjectTemplates OR isMappingTemplates then%>
	<base href="<%=mainAppPath%>/inventory2/">
<%End if%>
<!-- new ft stuff-->
<script src='js/jquery-1.11.1.js?<%=jsRev%>' type="text/javascript"></script>
<script type="text/javascript" src="../common/bootstrap-3.3.5/js/bootstrap.js?<%=jsRev%>"></script>
<link href="../common/bootstrap-3.3.5/css/bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">

<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/arxspan_global_styles.css?<%=jsRev%>">
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/transitionStyles.css?<%=jsRev%>">
<link href="<%=mainCSSPath%>/latofont.css?<%=jsRev%>" rel="stylesheet" type="text/css">

<script type="text/javascript" src="<%=mainAppPath%>/js/arxlayout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/isotope.pkgd.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.placeholder.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/promisePolyfill.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/md5-min.js"></script>
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
<link href="css/d3-css.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/contextMenu.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/selectize.default.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">

<%
inventoryPlateMapCSS = checkBoolSettingForCompany("useInventoryPlateMapCSS", session("companyId"))
If inventoryPlateMapCSS then
%>
<style type="text/css">
.inventoryTemplate {
	width:780px!important;
}
.plateMap tbody tr td:nth-of-type(1) {
	width:10px!important;
}
.plateMapHolder {
	width:initial!important;
}
.plateMap {
	width:initial!important;
}
</style>
<%End if%>
<style type="text/css">
.expireDiv{
	width:800px;
}
label{
display:block;
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

<!-- jquery for dynatree -->
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
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="/arxlab/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<script type="text/javascript">
<%If session("useChemDrawForLiveEdit") Then%>
	useChemDrawForLiveEdit = true;
<%End If%>
hasMarvin = <%=LCase(CStr(session("useMarvin")))%>
</script>

<script type="text/javascript" src="js/download.js?<%=jsRev%>"></script>

<!--widget start arxcal-->
<script type="text/javascript" src="js/arxCal.js?<%=jsRev%>"></script>

<script type="text/javascript" src="arxCalInc/js/select2-3.5.1/select2.js"></script>
<script type="text/javascript" src="arxCalInc/js/jquery.placeholder.js"></script>
<script type="text/javascript" src="arxCalInc/js/jquery.dataTables.js"></script>
<script type="text/javascript" src="arxCalInc/js/dataTables.tableTools.js"></script>
<script type="text/javascript" src="arxCalInc/js/jquery.tooltipster.min.js"></script>
<script type="text/javascript" src="arxCalInc/js/spin.min.js"></script>
<script type="text/javascript" src="arxCalInc/js/jquery.spin.js"></script>
<script type="text/javascript" src="arxCalInc/js/wNumb.min.js"></script>

<% if userOptions.Get("languageSelect") = "Japanese" then 'INV-215 %>
	<script type="text/javascript" src="arxCalInc/js/moment.min.js"></script>
<% else %>
	<script type="text/javascript" src="arxCalInc/js/moment-with-locales.js"></script>
<% end if %>


<script type="text/javascript" src="arxCalInc/js/moment-timezone.min.js"></script>
<script type="text/javascript" src="arxCalInc/js/fullcalendar.min.js"></script>
<script type="text/javascript" src="arxCalInc/js/datepair.min.js"></script>
<script type="text/javascript" src="arxCalInc/js/jquery.datepair.min.js"></script>
<script type="text/javascript" src="arxCalInc/js/bootstrap-datepicker.js"></script>
<script type="text/javascript" src="arxCalInc/js/jquery.timepicker.min.js"></script>
<script type="text/javascript" src="arxCalInc/js/classie.js"></script>
<script type="text/javascript" src="arxCalInc/js/modernizr.custom.js"></script>
<script type="text/javascript" src="arxCalInc/js/notificationFx.js"></script>

<link rel="stylesheet" type="text/css" href="arxCalInc/js/select2-3.5.1/select2.css">
<link rel="stylesheet" type="text/css" href="arxCalInc/css/latofont.css">
<link rel="stylesheet" type="text/css" href="arxCalInc/css/jquery.dataTables.css">
<link rel="stylesheet" type="text/css" href="arxCalInc/css/dataTables.tableTools.css">
<link rel="stylesheet" type="text/css" href="arxCalInc/css/tooltipster.css" />
<link rel="stylesheet" type="text/css" href="arxCalInc/js/fullcalendar.min.css" />
<link rel="stylesheet" type="text/css" href="arxCalInc/js/jquery.timepicker.css" />
<link rel="stylesheet" type="text/css" href="arxCalInc/css/ns-default.css" />
<link rel="stylesheet" type="text/css" href="arxCalInc/css/ns-style-attached.css" />
<link rel="stylesheet" type="text/css" href="arxCalInc/css/arxCal.css" />
<!-- end arxcal-->

<!-- widget start sample widget -->
<script type="text/javascript" src="sampleWidget/js/sampleWidget.js?<%=jsRev%>"></script>

<link rel="stylesheet" type="text/css" href="sampleWidget/css/sampleWidget.css" />
<!-- end sample widget -->


<!-- widget start arxDraw -->
<script type="text/javascript" src="arxDraw/js/arxDraw.js?<%=jsRev%>"></script>

<!-- <script type="text/javascript" src="arxDraw/js/jquery.min.2.1.1"></script>
<script type="text/javascript" src="arxDraw/js/jquery-ui.min.1.9.2"></script> -->
<script type="text/javascript" src="arxDraw/js/modernizr.js"></script>
<script type="text/javascript" src="arxDraw/js/fabric.min.js"></script>
<script type="text/javascript" src="arxDraw/js/FileSaver.min.js"></script>
<script type="text/javascript" src="arxDraw/js/jquery.mCustomScrollbar.concat.min.js"></script>  <!-- Malihu Scroll bar -->
<script type="text/javascript" src="arxDraw/js/spin.js"></script> 
<script type="text/javascript" src="arxDraw/js/peptide.js"></script> 
<script type="text/javascript" src="arxDraw/js/restrictedEnzymes.js"></script> 
<script type="text/javascript" src="arxDraw/js/jquery.blockUI.js"></script> 
<script type="text/javascript" src="arxDraw/js/sweetalert.js"></script>

<link rel="stylesheet" type="text/css" href="arxDraw/css/jquery.mCustomScrollbar.css"> <!-- Malihu Scroll bar -->
<link rel="stylesheet" type="text/css" href="arxDraw/css/jquery-ui-1.11.4.css">
<link rel="stylesheet" type="text/css" href="arxDraw/css/arxDraw.css" />
<link rel="stylesheet" type="text/css" href="arxDraw/css/progressbar.css" />
<link rel="stylesheet" type="text/css" href="arxDraw/css/sweetalert.css" />
<!-- end arxDraw -->

<%If inframe then%>
<!-- only when inframe -->
<link rel="stylesheet" type="text/css" href="css/inframePatch.css" />
<!-- end only when in iframe -->
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

<script type="text/javascript">
//add some connection stuff
<%
usersICanSee = "[" & getUsersICanSee() & "]"
searchFieldListIndex = getCompanySpecificSingleAppConfigSetting("inventorySearchFieldListIndex", session("companyId"))
// 5525: Hide ending batch number in Reg ID displaying
regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
%>
connectionId = '<%=session("servicesConnectionId")%>';
globalUserInfo = restCall("/elnConnection/","POST",{'usersICanSee':'<%=usersICanSee%>','connectionId':'<%=session("servicesConnectionId")%>','userId':<%=session("userId")%>,'whichClient':'<%=replace(whichClient,"'","\'")%>'})
whichClient = '<%=replace(whichClient,"'","\'")%>'
searchFieldListIndex = '<%=searchFieldListIndex%>'
// 5525: Hide ending batch number in Reg ID displaying
regBatchNumberDelimiter = '<%=regBatchNumberDelimiter%>';
regBatchNumberLength = '<%=regBatchNumberLength%>';
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
ignoreTableFields = false;
<%if inventoryIgnoreTableFields then%>
	ignoreTableFields = true;
<%end if%>
chemSearchDbName = "structureId.cd_id";
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
<body <%If inframe then%>style="min-width:800px;"<%End if%>>
<iframe style="display:none;background-color:black;z-index:99999;width:100%;height:100%;top:0;left:0;position:absolute;background:rgba(1,0,0,.7);filter: alpha(opacity = 0);border:none;" id="blackFrame" src="javascript:false;"></iframe>
<div style="display:none;background-color:black;z-index:100000;width:100%;height:100%;top:0;left:0;position:absolute;background:rgba(0,0,0,.7);filter: alpha(opacity = 80);" id="blackDiv"></div>
<iframe style="display:none;background-color:#eee;z-index:100001;width:90%;height:90%;top:40;left:40;position:absolute;padding:10px;" id="linkFrame" src="javascript:false;"></iframe>
<%If session("email")="support@arxspan.com" then%>
<input type="button" value="f" onclick='restCallA("/bulkMove/","POST",{});'>
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
<%If session("email") = "support@arxspan.com" Then%>
<input type="button" value="send records to search tool" onclick='restCall("/doAllRecordsSearchTool/","POST",{});'>
<input type="button" value="send disposed to search tool" onclick='restCall("/doAllRecordsSearchToolDispose/","POST",{});'>
<a href="undispose.asp"><input type="button" value="undispose..." /></a>
<%End if%>
<div>
	<ul id="treeContextMenu" class="contextMenu" style="width: 250px;">
<%If session("invRoleName") <> "Reader" Then%>
		<!--<li><a href="#daughterPlate" id="tcm_daugherPlate">Daughter Plate</a></li>-->
<%End if%>
		<li><a href="#import" id="tcm_import">Import</a></li>
		<li><a href="#add" id="tcm_add">Add</a></li>
		<li><a href="#copy" id="tcm_copy">Copy</a></li>
		<%If session("invRoleName") = "Admin" Or session("invRoleName") = "Power User" Then%>
			<li><a href="#bulkAdd" id="tcm_add">Bulk Add</a></li>
		<%End if%>
		<li><a href="#sample" id="tcm_sample">Sample</a></li>
		<%If session("canEdit") then%>
		<li><a href="#edit" id="tcm_edit">Edit</a></li>
		<%End if%>
		<li><a href="#view" id="tcm_view">View</a></li>
		<li><a href="#viewList" id="tcm_viewList">View List</a></li>
		<li><a href="#use" id="tcm_use">Use</a></li>
		<li><a href="#move" id="tcm_move">Move</a></li>
		<li><a href="#checkout" id="tcm_checkout">Check Out</a></li>
		<li><a href="#checkin" id="tcm_checkin">Check In</a></li>
		<%If session("canDispose") then%>
		<li><a href="#dispose" id="tcm_dispose">Dispose</a></li>
		<%End if%>
	</ul>
</div>

<%If Not inFrame then%>
<%sectionId="inventory"%>
<!-- #include virtual="/arxlab/_inclds/header2.0.asp"-->
<!-- #include virtual="/arxlab/_inclds/nav_top_tool.asp"-->
<%End if%>

<table <%If inframe then%>width="800"<%else%>width="1050"<%End if%> style="margin:auto;position:relative" id="contentTable">
<tr>

<td style="width:170px;padding-right:15px;<%If inFrame then%>display:none;<%End if%>" valign="top">
<div style="background-color:#ccc;height:600px;">
	<div id="aNav">
		<%If session("invRoleName") = "Admin" Or session("invRoleName") = "Power User" Then%>
			<style type="text/css">
			nav ul li, nav ul ul li{
				list-style-type:none;
			}
			nav ul ul a{
				width:160px;
			}
			nav ul ul {
				background-color:white;
				display: none;
				position: absolute;left:80px;margin-top:-10px;
			}

			nav ul li:hover > ul {
				display: block;
				z-index:100000000;
			}
			</style>
			<nav>
				<ul>
					<li>
						<a href="#">Bulk Operations</a>
						<ul>
						<%If ((whichServer = "PROD" and session("companyId") = 72) Or (whichServer = "MODEL" and session("companyId") = 51) And session("invRoleName") <> "Power User") Then%>		
							<li><a href="javascript:void(0);" onclick="actionFunctions('update',false,false,'arxOneContainer')" id="updateLink">Bulk Update</a></li>
						<%Else%>
							<li><a href="javascript:void(0);" onclick="actionFunctions('update',false,false,'arxOneContainer')" id="updateLink">Bulk Update</a></li>
						<%End if%>
							<li><a href="javascript:void(0);" onclick="actionFunctions('bulkMove',false,false,'arxOneContainer')" id="updateLink">Bulk Move</a></li>
							<li><a href="javascript:void(0);" onclick="actionFunctions('bulkDispose',false,false,'arxOneContainer')" id="updateLink">Bulk Dispose</a></li>
							<li><a href="javascript:void(0);" onclick="actionFunctions('bulkCheckIn',false,false,'arxOneContainer')" id="updateLink">Bulk Check In</a></li>
							<li><a href="javascript:void(0);" onclick="actionFunctions('bulkCheckOut',false,false,'arxOneContainer')" id="updateLink">Bulk Check Out</a></li>
						</ul>
					</li>
				</ul>
			</nav>
		<%End if%>
		<%If session("companyHasFTLiteInventory") then%>
		<a href="<%=mainAppPath%>/gotoFT.asp?lite=inventory">Search</a>
		<%else%>
		<a href="javascript:void(0);" onclick="clearContainer('aboveArxOneContainer');makeSearch('arxOneContainer')">Search</a>
		<%End if%>
		<%If session("invRoleName") = "Admin" Then%>
			<a href="javascript:void(0);" onclick="clearContainer('aboveArxOneContainer');makeReceiving('aboveArxOneContainer')" style="display:none;" id="makeReceivingLink">Receiving</a>
			<a href="javascript:void(0);" onclick="clearContainer('aboveArxOneContainer');makeFireControl('arxOneContainer')" style="display:none;" id="makeFireControlLink">Flammability Report</a>
			<script type="text/javascript">
				if (hasFireControl){
					document.getElementById("makeFireControlLink").style.display = "block";
				}
				if (hasReceiving){
					document.getElementById("makeReceivingLink").style.display = "block";
				}
				if (canUpdate){
					document.getElementById("updateLink").style.display = "block";
				}
			</script>
		<%End if%>
	</div>
	<div id="tree" class="inventoryTree">

	</div>
</div>
</td>

<%
If inFrame And Not addFromELN and not addFromNonChemELN And Not addFromREG And Not bulkAddFromReg And Not bulkMoveRegItems and Not addAfterRegFromELN Then
	selectFromEln = True
Else
	selectFromEln = False
End if
%>

<%If barcodeChooser then%>
<%selectFromELN = False%>
<!-- #include file="../barcodechooser.asp"-->
	<script type="text/javascript">
		theLink = "<%=request.querystring("link")%>";
		$(document).ready(function(){
			makeBarcodeChooser(<%=request.querystring("experimentType")%>);
			spacerDiv = document.createElement("div")
			spacerDiv.style.height = "800px";
			document.getElementById("arxOneContainer").appendChild(spacerDiv)
		})
	</script>
<%End if%>

<%If selectFromEln then%>
	<script type="text/javascript">
		$(document).ready(function(){makeSearch("arxOneContainer","",true);})
		selectedItemIds = [];
		selectedItemFds = [];
		useEquivalents = false;
		theLink = "<%=request.querystring("link")%>";
		experimentType = <%=request.querystring("experimentType")%>
	</script>
<%End if%>
<%If addFromELN then%>
	<script type="text/javascript">
		$(document).ready(function(){
			experimentType = <%=request.querystring("experimentType")%>
			spacerDiv = document.createElement("div")
			spacerDiv.style.height = "800px";
			document.getElementById("arxOneContainer").appendChild(spacerDiv)
			args = {"amount":"<%=request.querystring("amount")%>","amountUnits":"<%=request.querystring("amountUnits")%>","elnLink":"<%=request.querystring("link")%>","prefix":"<%=request.querystring("prefix")%>","molData":"","trivialName":"C<%=request.querystring("trivialName")%>"};
			if(window.parent.molUpdateCdxml2!=""){
				args["molData"] = window.parent.molUpdateCdxml2;
			}else{
				if(window.parent.molUpdateCdxml!=""){
					args["molData"] = window.parent.molUpdateCdxml;
				}
			}
			actionFunctions("addFromELN",false,false,"arxOneContainer",args);
		})
		theLink = "<%=request.querystring("link")%>";
		//experimentType = <%=request.querystring("experimentType")%>
	</script>
<%End if%>

<%If addAfterRegFromELN then%>
	<script type="text/javascript">
		$(document).ready(function(){
			experimentType = <%=request.querystring("experimentType")%>;
			spacerDiv = document.createElement("div");
			spacerDiv.style.height = "800px";
			document.getElementById("arxOneContainer").appendChild(spacerDiv);
			args = {
				"amount":"<%=request.querystring("amount")%>",
				"amountUnits":"<%=request.querystring("amountUnits")%>",
				"elnLink":"<%=request.querystring("link")%>",
				"prefix":"<%=request.querystring("prefix")%>",
				"regId":"<%=request.querystring("regId")%>",
				"molData":"",
				"trivialName":"<%=request.querystring("trivialName")%>"
				};
			if(window.parent.molUpdateCdxml2!=""){
				args["molData"] = window.parent.molUpdateCdxml2;
			}else if(window.parent.molUpdateCdxml!=""){
				args["molData"] = window.parent.molUpdateCdxml;
			}
			actionFunctions("addAfterRegFromELN",false,false,"arxOneContainer",args);
		})
	</script>
<%End if%>

<% if addFromNonChemELN then %>
	<script type="text/javascript">
		$(document).ready(function() {
			var experimentType = <%=request.querystring("experimentType")%>;
			var spacerDiv = document.createElement("div");
			spacerDiv.style.height = "800px";
			document.getElementById("arxOneContainer").appendChild(spacerDiv);
			theLink = "<%=request.querystring("link")%>";
			var args = {
				"elnLink": "<%=request.querystring("link")%>",
				"prefix": "<%=request.querystring("prefix")%>"
			};
			actionFunctions("addFromNonChemELN", false, false, "arxOneContainer", args);
		});
	</script>
<% end if %>

<%If addFromREG then%>
	<script type="text/javascript">
		$(document).ready(function(){
			experimentType = 0;
			spacerDiv = document.createElement("div")
			spacerDiv.style.height = "800px";
			document.getElementById("arxOneContainer").appendChild(spacerDiv)
			args = {"amount":"","amountUnits":"","elnLink":"<%=request.querystring("link")%>","prefix":"","molData":"<%=replace(request.querystring("molData"),vblf,"\n")%>","trivialName":"<%=request.querystring("trivialName")%>","regId":"<%=request.querystring("regId")%>"};
			actionFunctions("addFromREG",false,false,"arxOneContainer",args);
		})
	</script>
<%End if%>

<%If bulkAddFromREG then%>
	<script type="text/javascript">
		$(document).ready(function(){
			experimentType = 0;
			spacerDiv = document.createElement("div")
			spacerDiv.style.height = "800px";
			document.getElementById("arxOneContainer").appendChild(spacerDiv)
			valStr = '<%=request.querystring("values")%>'.replace(/(^,)|(,$)/g, "")
			args = {"values":valStr.split(","),"fieldToHide":"<%=request.querystring("fieldToHide")%>","theType":"Mouse","elnLink":"<%=request.querystring("link")%>"};
			actionFunctions("bulkAddFromREG",false,false,"arxOneContainer",args);
		})
	</script>
<%End if%>
<%If bulkMoveRegItems then%>
	<script type="text/javascript">
		$(document).ready(function(){
			experimentType = 0;
			spacerDiv = document.createElement("div")
			spacerDiv.style.height = "800px";
			document.getElementById("arxOneContainer").appendChild(spacerDiv)
			valStr = '<%=request.querystring("values")%>'.replace(/(^,)|(,$)/g, "")
			args = {"values":valStr.split(","),"labelName":"<%=request.querystring("labelName")%>","readOnly":true,"fieldName":"<%=request.querystring("fieldName")%>"};
			actionFunctions("bulkMove",false,false,"arxOneContainer",args);
		})
	</script>
<%End if%>
	<script type="text/javascript">

		altCollectionName = "_invType";//false
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
<%If session("invRoleName") <> "Reader" Then%>
			if(!node.data.showTable){
				fieldList.push("#daughterPlate");				
			}
<%End if%>

			if(!node.data.canImport){
				fieldList.push("#import");				
			}
			if(!node.data.canAdd){
				fieldList.push("#add");				
				fieldList.push("#bulkAdd");
			}
			if(node.data.type=="gridBox"){
				fieldList.push("#bulkAdd");
			}
			if(!node.data.canCopy){
				fieldList.push("#copy");							
			}
			if(!node.data.canSample){
				fieldList.push("#sample");				
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
			if(node.data.type!="gridBox"){
				fieldList.push("#viewList");				
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
			return fieldList.join(",");
		}

		$("#tree").dynatree({
			onPostInit: function(isReloading, isError) {
				this.$tree.dynatree('getRoot').visit(function(node){ // INV-222
			        node.expand(true);
			    });
			},
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
				}
			})(id);
			img = document.createElement("img");
			img.className = "popupCloseImg";
			img.src = "images/close-x.gif"
			a.appendChild(img);
			el.appendChild(a);
			return el;
		}
		
//INV - 257 MOVED FROM Index.asp as getList function is getting out of scope
formBucket = [];
searchFieldList = [];
//rpp and cb added 412015
function getList(cursorId,action,query,fixedFields,containerId,rpp,cb){
console.log("#### GETLIST #######", cursorId + ", " + containerId);
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
						getList(false, false, query, newFixedFields, "hiddenContainer", 10000, function () {
							if ($('#exportLink')[0] != undefined) {
								$('#exportLink')[0].click();
								$("#loadingDiv").hide();
								blackOff();
							}
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
//

		function handleLink(id,collection,showTable,parentTree,revisionNumber){
			var tree = $("#tree").dynatree("getTree");
			node = tree.getNodeByKey(id.toString());
			// Seems convoluted but it fixes an issue w/ Grid items (or others without their own tree nodes) where clicking through to the item and then clicking a different node results in both nodes being turned blue - doesn't always work perfectly in case there's nothing actually highlighted in the tree and the user is just clicking a link in the audit trail, so we're using a try/catch
			try{
				activeNode = $("#tree").dynatree("getActiveNode");
				$("#tree .dynatree-active").removeClass('dynatree-active');
				$(activeNode.span).addClass('dynatree-active');
				if((activeNode !== null || activeNode !== "null") && (node == null || node == "null")){
					// If activeNode exists and there isn't a node in the tree corresponding to the page/item you're viewing
					activeNode.deactivate();
					$(activeNode.span).addClass('dynatree-active');
				}
			}
			catch(err){
				console.log(err);
			}
			if(node){
				node.expand(true);
			}else{
				node = tree.getActiveNode();
				if(node){
					node.expand(true);
				}
				node = tree.getNodeByKey(id.toString());
				if(node){
					node.expand(true);
				}else{
					loadParentTree(parentTree,tree)
				}
			}
			clearContainer("arxOneContainer");
			ignoreTableFields = false;
			<%if inventoryIgnoreTableFields then%>
				ignoreTableFields = true;
			<%end if%>
			switch(companyId){
				//mskinv
				case 4:
					tableFields = ["Name","Gene","Species","Company","Dye"];
					break;
				///mskinv
				case 70:
					tableFields = ["Name","Plasmid Official Name","Plasmid Detailed Name","Structure","Amount","Unit Type"];
					break;
				case 13:
					tableFields = ["Name","Barcode","LUA Number","Volume","Unit Type"];
					break;
				case 1:
					tableFields = ["Name","Gene","Species","Company","Dye"];
					break;
				case 52:
					tableFields = ["Name","Barcode","Batch","Volume","Unit Type"];
					break;
				case 93:
					tableFields = ["Name","Notebook Page","Barcode","Amount","Units"];
					break;
				case 17:
					tableFields = false;
					break;
				default:
					tableFields = ["Name","Structure","Amount","Unit Type","Supplier","CAS Number"];
			}
			if(collection!="checkedout" && collection!="disposed"){
				if(showTable){
					getList(false,false,{"parent.collection":"inventoryItems","parent.id":parseInt(id),"disposed":false,"checkedOut":false},tableFields)
				}else{
					clearContainer("arxOneContainer");
					pl = {"action":"view","collection":collection,"id":id,"revisionNumber":revisionNumber};
					addObjectForm = restCall("/getForm/","POST",pl);								
					makeForm(addObjectForm,'arxOneContainer');
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
										el = document.getElementById(tableField.id+"_table_link");
										if(el){
											el.innerHTML = updateField.value;
										}
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
				el = document.getElementById(containerName).getElementsByTagName("div")[0];
				el.parentNode.removeChild(el);
			}catch(err){}
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
			for (var i=0;i<nodesToReload.length;i++ ){
				node = tree.getNodeByKey(nodesToReload[i].toString())
				if(node){
					node.reloadChildren(function(node, isOk){
						if(isOk){
							for (var j=0;j<nodesToActivate.length;j++ ){
								console.log("about to activate this node: " + nodesToActivate[j].toString())
								node = tree.getNodeByKey(nodesToActivate[j].toString())
								console.log(node)
								if(node){
									node.deactivate();
									node.activate();
								}
								nodesToActivate.splice(j,1) // Remove this from nodesToActivate to avoid repeated activation
								j--;
							}
						}
						else{
							console.error("Node failed to reload.");
						}
					});
				}
			}
		}

		function makeSamplePopupRequiredUniqueFieldsValuesObject(){
			var requiredUniqueFields = {}
			var errorFound = false;
			$('div.samplePopupExtraTextarea').each(function(){
				var formName = $(this).attr('formname');
				entriesArray = [];
				entriesStr = $(this).find('textarea').val();
				lines = entriesStr.split("\n");
				for(var i=0;i<lines.length;i++){
					if(lines[i]!=""){
						entriesArray.push(lines[i]);
					}
				}
				numContainers = parseInt(numContainersBox.value);
				if(entriesArray.length > numContainers){
					$('#samplePopup').removeClass('mapFields').addClass('initialPage');
					alert("There are too many entries in the \"New "+formName+" Values\" text box. Please make the number of entries in this field match the \"Number of New Containers\" field.");
					errorFound = true;
					return false;
				}
				else if(entriesArray.length < numContainers){
					$('#samplePopup').removeClass('mapFields').addClass('initialPage');
					alert("There aren't enough entries in the \"New "+formName+" Values\" text box. Please make the number of entries in this field match the \"Number of New Containers\" field.");
					errorFound = true;
					return false;
				}
				else{
					requiredUniqueFields[formName] = entriesArray;
				}
			});
			if(errorFound == false){
				return requiredUniqueFields;
			}
			else{
				return "error";
			}
		}

		function actionFunctions(action,fd,node,containerName,args){
			var tree = $("#tree").dynatree("getTree");
			nodesToReload = [];
			nodesToActivate = []
			$('#'+containerName).attr('latestaction',action);
			if(!containerName){
				containerName = defaultContainerName;
			}
			// INV-240 Checks below this are looking for "undefined" or null - setting to null
			units = null
			amount = null
			if(!!fd){
				if(!!altCollectionName){
					collection = fd.fields[fd.fieldNames.indexOf(altCollectionName)].value;
				}else{
					collection = fd.collection;
				}
				id = fd.id;
				parentTree = fd.parentTree;
				for (var i=0;i<fd.fields.length;i++){
					if(fd.fields[i]["isAmountUnitField"] == true){
						units = fd.fields[i].value;
					}
					if(fd.fields[i]["isAmountField"] == true){
						amount = fd.fields[i].value;
						amountField = fd.fields[i].dbName;
					}
				}
				if(typeof units == "undefined" || units == null){
					if(fd.fieldNames.indexOf("Unit Type")!=-1){
						units = fd.fields[fd.fieldNames.indexOf("Unit Type")].value
					}
					if(fd.fieldNames.indexOf("Units")!=-1){
						units = fd.fields[fd.fieldNames.indexOf("Units")].value
					}
					if(fd.fieldNames.indexOf("Amount Units")!=-1){
						units = fd.fields[fd.fieldNames.indexOf("Amount Units")].value
					}
				}
				if(typeof amount == "undefined" || amount == null){
					if(fd.fieldNames.indexOf("Amount")!=-1){
						amount = fd.fields[fd.fieldNames.indexOf("Amount")].value
						amountField = "amount"
					}
					if(fd.fieldNames.indexOf("Volume")!=-1){
						amount = fd.fields[fd.fieldNames.indexOf("Volume")].value
						amountField = "volume";
					}
				}
				console.log("bottom of units ifs")
			}
			if(!!node){
				collection = node.data.type;
				id = parseInt(node.data.key);
				parentTree = node.data.parentTree;
				console.log(node)
				if (node.data.amount){
					console.log("setting amount")
					amount = node.data.amount;
					amountField = "amount"
				}else{
					if (node.data.volume){
						console.log("setting amount from volume")
						amount = node.data.volume;
						amountField = "volume";
					}
				}
				if (node.data.units){
					units = node.data.units;
				}
				if (node.data.amountunits){
					units = node.data.amountunits;
				}
			}
			//if(parentTree=="" || !parentTree){
			//	parentTree = [0];
			//}
			if(action == "printLabel"){
				blackOn();
				popup = newPopup("labelPopup");
				popup.style.width="300px"
				popup.style.height="200px"
				label = document.createElement("label");
				label.innerHTML = "Label Type";
				popup.appendChild(label);

				addTypes = restCall("/getLabelNames/","POST",{});
				select = document.createElement("select");
				select.setAttribute("id","labelType");
				for(var i=0;i<addTypes.length;i++){
					option = document.createElement("option");
					option.setAttribute("value",i);
					option.appendChild(document.createTextNode(addTypes[i]));
					select.appendChild(option);
				}
				popup.appendChild(select);
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(select,node){
					return function(){
						r = restCall("/getLabel/","POST",{"mapId":select.options[select.selectedIndex].value,"id":fd.id});
						downloadFile("data:application/octet-stream;base64,"+r["label"],r["filename"],"application/octet-stream")
						el = document.getElementById("labelPopup");
						el.parentNode.removeChild(el);
						blackOff();
					}
				})(select,node);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
			}
			
			if(action == "printLabelFromTemplate"){
				if(window.liveEditInstalled){
					var printerInputJSON = [];
					console.log("window.itemJSON   ::", window.itemJSON);
					<% if ((whichServer = "PROD" and session("companyId") = 72) Or (whichServer = "MODEL" and session("companyId") = 51)) Then%> 	//Check for the company id for SUN-CPS or demo company on MODEL
						if(window.itemJSON.hasOwnProperty('labelPrintingSettings')){
							for (var i=1;i<1000;i++){
								if(window.itemJSON['labelPrintingSettings'].hasOwnProperty("line"+i+"Label") && window.itemJSON['labelPrintingSettings'].hasOwnProperty("line"+i+"Display")){
									fieldLabel = window.itemJSON['labelPrintingSettings']['line'+i+"Label"];
									fieldDisplay = window.itemJSON['labelPrintingSettings']['line'+i+"Display"];
									fieldValue = "";
									if (fieldLabel.constructor === Array) {
										for(j=0;j<fieldLabel.length;j++){
											if(window.itemJSON.getFieldByFormName(fieldLabel[j])) {
												if (fieldValue == ""){
													fieldValue = window.itemJSON.getFieldByFormName(fieldLabel[j]).value;
												}
												else{
													fieldValue = fieldValue + " " +window.itemJSON.getFieldByFormName(fieldLabel[j]).value;
												}
											}
											else{
												if(fieldLabel[j] == "Avoid moisture and light"){
													if (fieldValue == ""){
														fieldValue = fieldLabel[j];
													}
													else{
														fieldValue = fieldValue + " " + fieldLabel[j]
													}
												}
											}
										}
									}
									else{
										if(window.itemJSON.getFieldByFormName(fieldLabel)) {
											fieldValue = window.itemJSON.getFieldByFormName(fieldLabel).value;
										}
									}
									if (fieldDisplay.constructor === Array) {
										for(var k=1;k<fieldDisplay.length;k++){
											if (fieldValue == ""){
												fieldValue = fieldDisplay[k];
											}
											else{
												fieldValue = fieldValue + ", " + fieldDisplay[k];
											}
										}
										printerInputJSON.push({"line":fieldValue,"lineLabel":fieldDisplay[0]})
									}
									else{
										printerInputJSON.push({"line":fieldValue,"lineLabel":fieldDisplay})
									}
								}
								else{
									break; // Didn't find "line+i+Label" - no more label print layout lines to check for
								}
							}
						}
						var barcodeFieldValue = fd.getFieldBySpecialType("barcode").value;
						printerInputJSON.push({"QRcodeValue":barcodeFieldValue})
						console.log("printerInputJSON :", printerInputJSON);
						console.log("ZPL :", formatZPL(printerInputJSON));
						zplText = formatZPL(printerInputJSON)

						// send a notification email when the label is printed for a request
						if (collection == "Request") {
							console.log('THIS IS A REQUEST, SENDING EMAIL!!');

							if (fd.fieldNames.indexOf("Contact Email") != -1){
								toAddress = fd.fields[fd.fieldNames.indexOf("Contact Email")].value
								compoundName = fd.fields[fd.fieldNames.indexOf("Compound Name")].value
								
								body = "Hello,<p><h3>This is a notification that your request for " + compoundName + " is being fulfilled.</h3></p>Thank you,<br>Arxspan Support<br><br><u>Note:</u></b> this is an automatically generated email, please do not respond. If you have any questions please contact <a href=\"mailto:Sean.Peters@sunovion.com\">Sean Peters</a>."
								
								r = restCall("/sendEmail/","POST",{"toAddress":toAddress,"subject":"Request Created","body":body});
							}
							else {
								console.log("MISSING EMAIL ADDRESS");
							}
						}
					<%ElseIf (whichServer = "PROD" and session("companyId") = 16) Then%> // IDQ 5690 Sunovion barcode setup
						// How this works is that we build a JSON, adding in the field labels and their values.
						// Once it is built, we format it for a zebra printer
						
						var barcodeFieldValue = window.itemJSON.getFieldByFormName("Barcode").value;
						printerInputJSON.push({"barcodeValue":barcodeFieldValue})
						
						if((window.itemJSON).hasOwnProperty("labelPrintingSettings")){
							for (var i=1;i<1000;i++){
								if(window.itemJSON["labelPrintingSettings"].hasOwnProperty("line"+i+"Label") && window.itemJSON["labelPrintingSettings"].hasOwnProperty("line"+i+"Display")){
									fieldLabel = window.itemJSON["labelPrintingSettings"]["line"+i+"Label"];
									fieldDisplay = window.itemJSON["labelPrintingSettings"]["line"+i+"Display"];
									fieldValue = "";
									if (fieldLabel.constructor === Array) {
										for(j=0;j<fieldLabel.length;j++){
										console.log("fieldLabel Array ::",fieldLabel[j]);
											if(window.itemJSON.getFieldByFormName(fieldLabel[j])) {
												if (fieldValue == ""){
													fieldValue = window.itemJSON.getFieldByFormName(fieldLabel[j]).value;
												}
												else{
													fieldValue = fieldValue + " " +window.itemJSON.getFieldByFormName(fieldLabel[j]).value;
												}
											}
										}
									}
									else{
										if(window.itemJSON.getFieldByFormName(fieldLabel)) {
											fieldValue = window.itemJSON.getFieldByFormName(fieldLabel).value;
										}
									}
									printerInputJSON.push({"line":fieldValue,"lineLabel":fieldDisplay})
								}
								else{
									break; // Didn't find "line+i+Label" - no more label print layout lines to check for
								}							
							}
						}
						
						console.log("barcodeFieldValue ::", barcodeFieldValue);
						console.log("printerInputJSON :", printerInputJSON);
						zplText = formatZPL_Sunovion(printerInputJSON); // here we call to format the printer JSON that we built
					<%ElseIf ((whichServer = "PROD" and session("companyId") = 131) Or (whichServer = "MODEL" and session("companyId") = 51)) Then%>	//Check for the company id for Yumanity 	//INV-316
						if((window.itemJSON).hasOwnProperty("labelPrintingSettings")){
							for (var i=1;i<1000;i++){
								if(window.itemJSON["labelPrintingSettings"].hasOwnProperty("line"+i+"Label") && window.itemJSON["labelPrintingSettings"].hasOwnProperty("line"+i+"Display")){
									fieldLabel = window.itemJSON["labelPrintingSettings"]["line"+i+"Label"];
									fieldDisplay = window.itemJSON["labelPrintingSettings"]["line"+i+"Display"];
									fieldValue = "";
									if (fieldLabel.constructor === Array) {
										for(j=0;j<fieldLabel.length;j++){
										console.log("fieldLabel Array ::",fieldLabel[j]);
											if(window.itemJSON.getFieldByFormName(fieldLabel[j])) {
												if (fieldValue == ""){
													fieldValue = window.itemJSON.getFieldByFormName(fieldLabel[j]).value;
												}
												else{
													fieldValue = fieldValue + " " +window.itemJSON.getFieldByFormName(fieldLabel[j]).value;
												}
											}
										}
									}
									else{
										if(window.itemJSON.getFieldByFormName(fieldLabel)) {
											fieldValue = window.itemJSON.getFieldByFormName(fieldLabel).value;
										}
									}
									printerInputJSON.push({"line":fieldValue,"lineLabel":fieldDisplay})
								}
								else{
									break; // Didn't find "line+i+Label" - no more label print layout lines to check for
								}
							}
						}
						var barcodeFieldValue = window.itemJSON.getFieldByFormName("Barcode").value;
						printerInputJSON.push({"barcodeValue":barcodeFieldValue})
						console.log("barcodeFieldValue ::", barcodeFieldValue);
						console.log("printerInputJSON :", printerInputJSON);
						zplText = formatZPL_yumanity(printerInputJSON);
					<%End If%>
					
						//Get the default printer name for the user from itemJSON
						if(window.itemJSON.hasOwnProperty("printerName")){
							printerName = window.itemJSON.printerName;
							console.log("printer name from itemJSON ::", printerName);
							if(printerName != "" && printerName != "None" && printerName != 'undefined') {
								printerDetails = getFile('getPrinterDetails.asp?printerName='+printerName+'&random='+Math.random());
								printerDetails = JSON.parse(printerDetails);
								console.log("Y Printer Deatils :::", printerDetails)
								console.log("Y Printer Deatils :::", printerDetails["printerType"])
								if(printerDetails["printerType"] == 'network'){
									if(printerDetails["printerIp"] != "" && printerDetails["printerIp"] != 'undefined' && printerDetails["printerPort"] != "" && printerDetails["printerPort"] != 'undefined'){
										window.postMessage({
											message_type: "print",
											printType: printerDetails["printerType"],
											ipAddress: printerDetails["printerIp"],
											port: parseInt(printerDetails["printerPort"]),
											zplText: zplText
										},'*');
									}
								}
								else{ 	//USB printer
									if(printerDetails["printerName"] != "" && printerDetails["printerName"] != 'undefined'){
										window.postMessage({
											message_type: 'print',
											printType: 'default',
											printerName: printerDetails["printerName"],
											zplText: zplText
											//ipAddress: '192.168.1.135',
											//port: 9100,
										},'*');
									}
								}
							}else{	//There is no valid printer selected 
								swal({
									title: "Printer not selected",
									text: 'You must select a printer to print the label',
									type: "error",
									html: true
								})
							}
						}
						else{	//There is no default printer selected 
							swal({
								title: "Printer not selected",
								text: 'You must select a printer to print the label',
								type: "error",
								html: true
							})
						}
				}
				else{	//Live Edit is not installed
					swal({
						title: "Live Edit Not Installed",
						text: 'You must install the Live Edit browser plugin to use this function.<br /><a href="arxlab/liveEditDownloads/chromeExtHostInstallation.asp" style="text-decoration:none;color:#00b2ba;">Click here for installation instructions</a>',
						type: "error",
						html: true
					})
				}
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
				newBarcode.setAttribute("id","newBarcode");
				newBarcode.onkeydown = function(e){
					if (e.keyCode == 13) {
						document.getElementById("aBarcode").focus();
						return false;
					}
				}
				popup.appendChild(newBarcode);
				label = document.createElement("label");
				label.innerHTML = "Plate A Barcode";
				popup.appendChild(label);
				aBarcode = document.createElement("input");
				aBarcode.setAttribute("type","text");
				aBarcode.setAttribute("id","aBarcode");
				aBarcode.onkeydown = function(e){
					if (e.keyCode == 13) {
						document.getElementById("bBarcode").focus();
						return false;
					}
				}
				popup.appendChild(aBarcode);
				label = document.createElement("label");
				label.innerHTML = "Plate B Barcode";
				popup.appendChild(label);
				bBarcode = document.createElement("input");
				bBarcode.setAttribute("type","text");
				bBarcode.setAttribute("id","bBarcode");
				bBarcode.onkeydown = function(e){
					if (e.keyCode == 13) {
						document.getElementById("cBarcode").focus();
						return false;
					}
				}				
				popup.appendChild(bBarcode);
				label = document.createElement("label");
				label.innerHTML = "Plate C Barcode";
				popup.appendChild(label);
				cBarcode = document.createElement("input");
				cBarcode.setAttribute("type","text");
				cBarcode.setAttribute("id","cBarcode");
				cBarcode.onkeydown = function(e){
					if (e.keyCode == 13) {
						document.getElementById("dBarcode").focus();
						return false;
					}
				}
				popup.appendChild(cBarcode);
				label = document.createElement("label");
				label.innerHTML = "Plate D Barcode";
				popup.appendChild(label);
				dBarcode = document.createElement("input");
				dBarcode.setAttribute("type","text");
				dBarcode.setAttribute("id","dBarcode");
				dBarcode.onkeydown = function(e){
					if (e.keyCode == 13) {
						document.getElementById("daughterSampleVolume").focus();
						return false;
					}
				}
				popup.appendChild(dBarcode);

				label = document.createElement("label");
				label.innerHTML = "Sample Volume";
				popup.appendChild(label);
				sampleVolume = document.createElement("input");
				sampleVolume.setAttribute("type","text");
				sampleVolume.setAttribute("id","daughterSampleVolume");
				popup.appendChild(sampleVolume);
				sampleVolume.onkeydown = function(e){
					if (e.keyCode == 13) {
						document.getElementById("daughterSolventVolume").focus();
						return false;
					}
				}

				label = document.createElement("label");
				label.innerHTML = "Solvent Volume";
				popup.appendChild(label);
				solventVolume = document.createElement("input");
				solventVolume.setAttribute("type","text");
				solventVolume.setAttribute("id","daughterSolventVolume");
				popup.appendChild(solventVolume);

				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(newBarcode,aBarcode,bBarcode,cBarcode,dBarcode,sampleVolume,solventVolume,node){
					return function(){
						button.setAttribute("value","Loading Please Wait");
						args = {
							"newBarcode":newBarcode.value,
							"aBarcode":aBarcode.value,
							"bBarcode":bBarcode.value,
							"cBarcode":cBarcode.value,
							"dBarcode":dBarcode.value,
							"sampleVolume":sampleVolume.value,
							"solventVolume":solventVolume.value,
							"parent":{"collection":"inventoryItems","id":id}
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
				})(newBarcode,aBarcode,bBarcode,cBarcode,dBarcode,sampleVolume,solventVolume,node);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
			}
			if(action == "casLookup"){
				window.addLabel = "<%=addLabel%>"
				blackOn();
				popup = newPopup("casPopup");
				popup.style.width="300px"
				popup.style.height="100px"
				popup.style.left="50%"
				popup.style.marginLeft="-150px"
				popup.style.top="40px"
				label = document.createElement("label");
				label.innerHTML = "CAS Number";
				popup.appendChild(label);
				input = document.createElement("input");
				input.setAttribute("type","text");
				popup.appendChild(input)
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.setAttribute("id","casLookupSubmitButton")
				button.onclick = (function(input,fd,button){
					return function(){
						button.value = "Loading...";
						console.log(fd)
						window.lookupCasNumber_fd = fd
						lookupCasNumber(input.value)
						/*
						window.setTimeout(function(){
						casData = JSON.parse(getFile('getCasData.asp?casId='+input.value,function(){alert("Cas lookup took too long to respond.");button.setAttribute("value","SEARCH");}));
						console.log(casData);
						if(casData.name){
							pl = {};
							pl["structure"] = casData.molData;
							pl["format"] = "mol:V3";
							x = restCall("/standardizeMol/","POST",pl);
							console.log(x)
							casData.molData = x["structure"];

							f = fd.getFieldByFormName("Name");
							el = document.getElementById(f.id)
							el.value = casData.name;
							el.onchange();

							f = fd.getFieldByFormName("CAS Number");
							el = document.getElementById(f.id)
							el.value = casData.casNumber;
							el.onchange();
							
							f = fd.getFieldByFormName("Structure");
							document.getElementById(f.id+"_frame").contentWindow.cd_putData(f.id,"chemical/x-mdl-molfile",casData.molData);
							f.onchange();
							
							el = document.getElementById("casPopup");
							el.parentNode.removeChild(el);
							blackOff();
						}else{
							alert("No information found for CAS number: "+input.value);
						}},500)
						*/
					}
				})(input,fd,button);
				button.setAttribute("value","Search");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
			}
			if(action == "import"){
				nodesToReload.push(id);
				nodesToActivate.push(id)
				clearContainer(containerName);
				pl = {"action":"add","collection":"bulkImport","parent":{"collection":"inventoryItems","id":id}};
				addObjectForm = restCall("/getForm/","POST",pl);
				formBucket.push(addObjectForm);
				addObjectForm.onSave = function(fd,node){
					return function(){
						if(validateForm(fd)){
							//blackOn();
							cb = (function(nodesToReload,nodesToActivate,parentTree,tree,fd){
								return function(){
									handleNodeReloads(nodesToReload,[],parentTree,tree);
									removeForm(fd.fid);
								}
							})(nodesToReload,nodesToActivate,parentTree,tree,fd)
							showProgressBox({},cb);
							saveFormA(fd,true,function(){
							});
						}
					}
				}(addObjectForm,node);
						
				makeForm(addObjectForm,containerName);
			}
			if(action == "update"){
				clearContainer(containerName);
				pl = {"action":"add","collection":"bulkUpdate"};
				addObjectForm = restCall("/getForm/","POST",pl);
				formBucket.push(addObjectForm);
				addObjectForm.onSave = function(fd,node){
					return function(){
						if(validateForm(fd)){
							//blackOn();
							cb = (function(fd){
								return function(){
								}
							})(fd)
							showProgressBox({},cb);
							saveFormA(fd,true,function(){
							});
						}
					}
				}(addObjectForm,node);
						
				makeForm(addObjectForm,containerName);
			}


			//start addMulti
			if(action == "bulkAdd"){
				nodesToReload.push(id);
				nodesToActivate.push(id)
				blackOn();
				popup = newPopup("addPopup");
				popup.style.width="300px"
				popup.style.height="400px"
				label = document.createElement("label");
				label.innerHTML = "Type to Add";
				popup.appendChild(label);

				addTypes = restCall("/getAllowedChildren/","POST",{"type":collection});
				select = document.createElement("select");
				select.setAttribute("id","addType");
				for(var i=0;i<addTypes.length;i++){
					option = document.createElement("option");
					option.setAttribute("value",addTypes[i]);
					option.appendChild(document.createTextNode(addTypes[i]));
					if(autoClickValue == addTypes[i]){
						option.setAttribute("SELECTED","SELECTED")
					}
					select.appendChild(option);
				}
				popup.appendChild(select);

				label = document.createElement("label");
				label.innerHTML = "Number of Containers";
				popup.appendChild(label);

				numContainersBox = document.createElement("input");
				numContainersBox.setAttribute("type","text");
				popup.appendChild(numContainersBox);

				label = createLabel("Barcodes");
				popup.appendChild(label);

				newBarcodeBox = createNewBarcodeBox("38", "12");
				popup.appendChild(newBarcodeBox);


				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(select,node,newBarcodeBox,numContainersBox){
					return function(){
						barcodes = [];
						barcodeStr = newBarcodeBox.value;
						b = barcodeStr.split("\n");
						for(var i=0;i<b.length;i++){
							if(b[i]!=""){
								barcodes.push(b[i]);
							}
						}
						numContainers = parseInt(numContainersBox.value);
						if(!(numContainers === parseInt(numContainers, 10)) && barcodes.length==0){
							alert("Please enter a number of containers or a barcode for each container to be created.")
							return false;
						}
						if(barcodes.length==0){
							for(var k=0;k<numContainers;k++){
								barcodes.push("");
							}
						}
						errors = restCall("/barcodesExist/","POST",{"barcodes":barcodes});
						if (errors.length!=0){
							alert(errors.join("\n"));
							return false;
						}
						clearContainer(containerName);
						collection = select.options[select.selectedIndex].value;
						pl = {"action":"add","collection":collection,"parent":{"collection":"inventoryItems","id":id},"multi":true,"fieldToHide":"barcode"};
						addObjectForm = restCall("/getForm/","POST",pl);
						formBucket.push(addObjectForm);
						addObjectForm.onSave = function(fd,node,nodesToReload,nodesToActivate,barcodes){
							return function(){
								if(validateForm(fd)){
									saveFormMulti(fd,true,"barcode",barcodes);
									clearContainer(containerName);
									handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
									removeForm(fd.fid);
								}
							}
						}(addObjectForm,node,nodesToReload,nodesToActivate,barcodes);
								
						makeForm(addObjectForm,containerName);
						el = document.getElementById("addPopup");
						el.parentNode.removeChild(el);
						blackOff();
					}
				})(select,node,newBarcodeBox,numContainersBox);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				if(autoClickAdd){
					button.click();
				}
				autoClickAdd = false;
			}
			//end addMulti


			//start bulkAddReg
			if(action == "bulkAddFromREG"){			
				blackOn();
				popup = newPopup("bulkAddPopup");
				popup.style.width="300px"
				popup.style.height="300px"
				label = document.createElement("label");
				label.innerHTML = "New Location";
				popup.appendChild(label);
				div = document.createElement("div")
				div.setAttribute("id","treeBulkMove");
				popup.appendChild(div);
				

				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(args){
					return function(){
						node = $("#treeBulkMove").dynatree("getActiveNode")
						targetId = parseInt(node.data.key);
						parentType = node.data.type
						theType = args["theType"]
						allowedChildren = restCall("/getAllowedChildren/","POST",{"type":parentType});
						if (allowedChildren.indexOf(theType)==-1){
							alert("You cannot create this type of object in this location");
							return false
						}

						clearContainer(containerName);
						pl = {"action":"add","collection":theType,"parent":{"collection":"inventoryItems","id":targetId},"multi":true,"fieldToHide":args["fieldToHide"]};
						addObjectForm = restCall("/getForm/","POST",pl);
						formBucket.push(addObjectForm);
						addObjectForm.onSave = function(fd,node,nodesToReload,nodesToActivate,args){
							return function(){
								if(validateForm(fd)){
									saveFormMulti(fd,true,args["fieldToHide"],args["values"],args["elnLink"]);
									clearContainer(containerName);
									//handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
									removeForm(fd.fid);
									window.parent.location = window.parent.location;
								}
							}
						}(addObjectForm,node,nodesToReload,nodesToActivate,args);
						makeForm(addObjectForm,containerName);
						el = document.getElementById("bulkAddPopup");
						el.parentNode.removeChild(el);
						blackOff();

					}
				})(args,tree);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				$("#treeBulkMove").dynatree({
					initAjax: {url: "/getTree/",
							   data: {"key": "root", // Optional arguments to append to the url
									  "mode": "all",
									  "type": "root",
									  connectionId:connectionId
									  }
							   },
					onLazyRead: function(node){
						node.appendAjax({url: "/getTree/",
										   data: {"key": node.data.key.replace("_",""), // Optional url arguments
												  "mode": "all",
												  "type": node.data.type,
												  "foo":"bar",
												  connectionId:connectionId
												  }
										  });
					},
					onClick: function(node){
						node.appendAjax({url: "/getTree/",
										   data: {"key": node.data.key.replace("_",""), // Optional url arguments
												  "mode": "all",
												  "type": node.data.type,
												  connectionId:connectionId
												  },
											  success: function(data){
												node.expand();
											  }
										  });
					},
					imagePath: "images/treeIcons/"
				});
			}
			//end bulkAddReg




			if(action == "add"){
				nodesToReload.push(id);
				blackOn();
				popup = newPopup("addPopup");
				popup.style.width="300px"
				popup.style.height="93px"

				label = createLabel("Type to Add");
				popup.appendChild(label);

				addTypes = restCall("/getAllowedChildren/","POST",{"type":collection});
				select = createSelectWithOptions("addType", addTypes, autoClickValue);
				popup.appendChild(select);
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(select,node){
					return function(){
						clearContainer(containerName);
						collection = select.options[select.selectedIndex].value;
						pl = {"action":"add","collection":collection,"parent":{"collection":"inventoryItems","id":id}};
						addObjectForm = restCall("/getForm/","POST",pl);
						formBucket.push(addObjectForm);
						addObjectForm.onSave = function(fd,node,nodesToReload,nodesToActivate){
							return function(){
								if(validateForm(fd)){
									responseFromSaveForm = saveForm(fd,true);
									clearContainer(containerName);
									nodesToActivate.push(responseFromSaveForm['newId'])
									console.log(nodesToActivate)
									handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
									removeForm(fd.fid);
								}
							}
						}(addObjectForm,node,nodesToReload,nodesToActivate);
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
				if(autoClickAdd){
					button.click();
				}
				autoClickAdd = false;
			}
			//start sample
			if(action == "sample"){
				nodesToReload.push(id);
				nodesToActivate.push(id)
				blackOn();
				popup = newPopup("samplePopup");
				popup.setAttribute("class","popupDiv initialPage")
				samplePopupBottomSection = document.createElement("div");
				samplePopupBottomSection.setAttribute("class","samplePopupBottomSection");
				samplePopupInnerDiv = document.createElement("div");
				samplePopupInnerDiv.setAttribute("class","samplePopupInner");
				label = document.createElement("label");
				label.innerHTML = "Choose Destination Location";
				samplePopupInnerDiv.appendChild(label);

				div = document.createElement("div")
				div.setAttribute("id","treeSample");
				samplePopupInnerDiv.appendChild(div);

				// Need to fetch the mapping templates - none will be displayed initially but the templates in the dropdown will be replaced/updated whenever the user changes the destination or source types
				window.sampleMappingTemplates = restCall("/fetchAllMappingTemplates/","POST",{"category": "sample","connectionId":connectionId})["templates"]

				label = document.createElement("label");
				label.innerHTML = "Destination Container Type";
				samplePopupInnerDiv.appendChild(label);
				//sampleTypes = restCall("/getSampleTypes/","POST",{"type":collection});
				sampleTypes = restCall("/getAllowedChildren/","POST",{"type":"bottle"});
				sampleTypeSelect = document.createElement("select");
				sampleTypeSelect.setAttribute("id","sampleType");
				for(var i=0;i<sampleTypes.length;i++){
					option = document.createElement("option");
					option.setAttribute("value",sampleTypes[i]);
					option.appendChild(document.createTextNode(sampleTypes[i]));
					sampleTypeSelect.appendChild(option);
				}
				samplePopupInnerDiv.appendChild(sampleTypeSelect);
				label = document.createElement("label");
				label.innerHTML = "Amount Remaining";
				samplePopupInnerDiv.appendChild(label);
				samplePopupInnerDiv.appendChild(document.createTextNode(restCall("/getAmountRemaining/","POST",{"id":id,"collection":collection})["amountRemaining"]))

				label = document.createElement("label");
				label.innerHTML = "Amount in Each New Container";
				samplePopupInnerDiv.appendChild(label);
				amountBox = document.createElement("input");
				amountBox.setAttribute("type","text");
				samplePopupInnerDiv.appendChild(amountBox);

				label = document.createElement("label");
				label.innerHTML = "Number of New Containers";
				samplePopupInnerDiv.appendChild(label);

				numContainersBox = document.createElement("input");
				numContainersBox.setAttribute("type","text");
				samplePopupInnerDiv.appendChild(numContainersBox);

				label = createLabel("New Barcode(s)");
				samplePopupInnerDiv.appendChild(label);

				newBarcodeBox = createNewBarcodeBox("18", "5");
				samplePopupInnerDiv.appendChild(newBarcodeBox);

				extraTextareasBox = document.createElement("div");
				extraTextareasBox.setAttribute("class","samplePopupExtraTextareas");
				extraTextareasBox.setAttribute("id","samplePopupExtraTextareas");
				samplePopupInnerDiv.appendChild(extraTextareasBox);
				
				popup.appendChild(samplePopupInnerDiv);

				fieldMappingDiv = document.createElement("div");
				fieldMappingDiv.setAttribute("class","fieldMappingDiv");
				fieldMappingDiv.setAttribute("id","fieldMappingDiv")
				popup.appendChild(fieldMappingDiv)

				backButton = document.createElement("input");
				backButton.setAttribute("type","button");
				backButton.onclick = (function(select,node){
					$('#samplePopup').removeClass('mapFields').addClass('initialPage')
				});
				backButton.setAttribute("value","Back");
				backButton.setAttribute("class","backButton");
				samplePopupBottomSection.appendChild(backButton);

				sampleMapFieldsHTML = '<select class="sampleMapTemplatesDropdown" id="sampleMapTemplatesDropdown"><option value="custom" selected>-- Choose Mapping Template --</option></select><div class="sampleMapTemplateNameTextboxContainer"><input type="text" class="sampleMapTemplateNameTextbox" placeholder="(Optional) Enter name to save as mapping template"></div>'
				$(samplePopupBottomSection).append(sampleMapFieldsHTML)

				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(id,collection,tree,amountBox,newBarcodeBox,sampleTypeSelect,numContainersBox){
					return function(){
						sampleType = sampleTypeSelect.options[sampleTypeSelect.selectedIndex].value;
						amount = amountBox.value;
						barcodes = [];
						barcodeStr = newBarcodeBox.value;
						b = barcodeStr.split("\n");
						for(var i=0;i<b.length;i++){
							if(b[i]!=""){
								barcodes.push(b[i]);
							}
						}

						numContainers = parseInt(numContainersBox.value);
						if(!(numContainers === parseInt(numContainers, 10))){ // Value is bad or blank
							$('#samplePopup').removeClass('mapFields').addClass('initialPage');
							alert("Please enter a number of containers.")
							return false;
						}
						if(barcodes.length > numContainers){
							$('#samplePopup').removeClass('mapFields').addClass('initialPage');
							alert("There are too many entries in the Barcodes text box. Please make the number of barcodes match the \"Number of New Containers\" field.");
							return false;
						}
						if(barcodes.length < numContainers){
							for(var k=0;k<numContainers;k++){
								barcodes.push("");
							}
						}
						
						if($('#samplePopup').hasClass('customMappingTemplateSelected') && $('.sampleMapTemplateNameTextbox').val() !== ""){
							if(window.confirm('This template will be saved as "' + $('.sampleMapTemplateNameTextbox').val() + '". Are you sure?')){
								// User wants to save the template - do that here 
								var mappingTemplateName = $('.sampleMapTemplateNameTextbox').val();
								var sourceType = collection
								var destinationType = sampleType
								var fieldMap = makeFieldNamePairsFromMap('fieldMappingDiv')
								var isPublic = $('#mappingTemplate_isPublic').prop('checked')

								r = restCall("/saveMappingTemplate/","POST",{"mappingTemplateName": mappingTemplateName, "sourceType": sourceType, "destinationType": destinationType, "fieldMap": fieldMap, "isPublic": isPublic, "category": "sample"})
								if(r["result"] == "success"){
									console.log(r)
								}
								else if(r["result"] == "failure"){
									alert("There was an issue saving your mapping template.")
								}
							}
							else{
								// User hit cancel
								return false;
							}
						}

						var requiredUniqueFields = makeSamplePopupRequiredUniqueFieldsValuesObject();
						if(requiredUniqueFields == "error"){
							return false;
						}

						node = $("#treeSample").dynatree("getActiveNode")
						if(!node){
							alert("Please highlight a location");
						}
						targetType = node.data.type;
						targetId = parseInt(node.data.key);
						allowedChildren = restCall("/getAllowedChildren/","POST",{"type":targetType});
						r = restCall("/getLocations/","POST",{"type":targetType,"id":targetId});
						if (r.status=="locationRequired"){
							locations = r.locations;
							popup = newPopup("locationPopup");
							popup.style.width="500px"
							popup.style.height="680px"
							label = document.createElement("label");
							label.innerHTML = "Location";
							popup.appendChild(label);

							select = document.createElement("select");
							select.setAttribute("id","addType");
							for(var i=0;i<locations.length;i++){
								option = document.createElement("option");
								option.setAttribute("value",locations[i]);
								option.appendChild(document.createTextNode(locations[i]));
								select.appendChild(option);
							}
							popup.appendChild(select);
							button = document.createElement("input");
							button.setAttribute("type","button");

							var requiredUniqueFields = makeSamplePopupRequiredUniqueFieldsValuesObject();
							if(requiredUniqueFields == "error"){
								return false;
							}

							button.onclick = (function(select,node){
								return function(){
									loc = select.options[select.selectedIndex].value;
									el = document.getElementById("locationPopup");
									el.parentNode.removeChild(el);
									nodesToReload.push(node.data.key)
									if($('#samplePopup').hasClass('savedMappingTemplateSelected')){
										selectedTemplateIndex = $('.sampleMapTemplatesDropdown').val()
										fieldMap = window.sampleMappingTemplates[selectedTemplateIndex]['fieldMap'];
									}
									else{
										fieldMap = makeFieldNamePairsFromMap('fieldMappingDiv')
									}
									r = restCall("/sampleFromMap/","POST",{"lineageParentId":id,"targetId":targetId,"location":loc,"collection":collection,"amount":parseFloat(amount),"numberOfContainers":numContainers,"fieldMap":fieldMap,"barcodes":barcodes,"type":sampleType,"requiredUniqueFields":requiredUniqueFields})
									if(!r["error"]){
										clearContainer(containerName);
										handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
										el = document.getElementById("samplePopup");
										el.parentNode.removeChild(el);
										blackOff();
										return false;
									}else{
										alert(r["errorText"])
									}
								}
							})(select,node);
							button.setAttribute("value","OK");
							popup.appendChild(button);

							document.getElementById("contentTable").appendChild(popup);
							window.scroll(0,0);
						}else{
							if(allowedChildren.indexOf(collection)!=-1){
								nodesToReload.push(node.data.key)
								if($('#samplePopup').hasClass('savedMappingTemplateSelected')){
									selectedTemplateIndex = $('.sampleMapTemplatesDropdown').val()
									fieldMap = window.sampleMappingTemplates[selectedTemplateIndex]['fieldMap'];
								}
								else{
									fieldMap = makeFieldNamePairsFromMap('fieldMappingDiv')
								}
								r = restCall("/sampleFromMap/","POST",{"lineageParentId":id,"targetId":targetId,"collection":collection,"amount":parseFloat(amount),"numberOfContainers":numContainers,"fieldMap":fieldMap,"barcodes":barcodes,"type":sampleType,"requiredUniqueFields":requiredUniqueFields})
								if(!r["error"]){
									clearContainer(containerName);
									handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
									el = document.getElementById("samplePopup");
									el.parentNode.removeChild(el);
									blackOff();
								}else{
									alert(r["errorText"])
								}
							}else{
								alert("Item may not be created in this location.")
							}
						}
					}
				})(id,collection,tree,amountBox,newBarcodeBox,sampleTypeSelect,numContainersBox);
				button.setAttribute("value","Make Samples");
				button.setAttribute("class","sampleButton");
				samplePopupBottomSection.appendChild(button);

				mapButtonOr = document.createElement("div");
				mapButtonOr.setAttribute("class","mapFieldsButtonOr");
				mapButtonOr.innerHTML = "< OR >";
				samplePopupBottomSection.appendChild(mapButtonOr);
				mapButton = document.createElement("input");
				mapButton.setAttribute("type","button");
				mapButton.onclick = (function(select,node){
					destinationType = sampleTypeSelect.options[sampleTypeSelect.selectedIndex].value;
					return initMappingInterface(id,collection,destinationType,"sample","samplePopup")
				});
				mapButton.setAttribute("value","New Mapping Template");
				mapButton.setAttribute("class","mapFieldsButton");
				samplePopupBottomSection.appendChild(mapButton);

				$(samplePopupBottomSection).append('<input type="checkbox" name="mappingTemplate_isPublic" id="mappingTemplate_isPublic" class="css-checkbox"><label for="mappingTemplate_isPublic" class="css-label checkboxLabel mappingTemplate_isPublic_label">Make Template Public</label>')
				popup.appendChild(samplePopupBottomSection)
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				$("#treeSample").dynatree({
					onPostInit: function(isReloading, isError) {
						this.$tree.dynatree('getRoot').visit(function(node){ // INV-222
					        $(node.span).children('a').click(); // click the root node...
					    });
					},
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
					onClick: function(node){
						node.appendAjax({url: "/getTree/",
										   data: {"key": node.data.key.replace("_",""), // Optional url arguments
												  "mode": "all",
												  "type": node.data.type,
												  connectionId:connectionId
												  },
											  success: function(data){
												node.expand(); // PROBLEMATIC! Causees the nodes to be impossible to close - when you click, this gets triggered and expands the node all over again... Created issue INV-223
											  	if(typeof window.treeSampleActiveNodeType == "undefined" || (window.treeSampleActiveNodeType !== $("#treeSample").dynatree("getActiveNode").data.type)){
											  		window.treeSampleActiveNodeType = $("#treeSample").dynatree("getActiveNode").data.type

											  		sampleTypes = restCall("/getAllowedChildren/","POST",{"type":window.treeSampleActiveNodeType});
											  		$('#sampleType').empty();
											  		for(var i=0;i<sampleTypes.length;i++){
											  			option = document.createElement("option");
											  			option.setAttribute("value",sampleTypes[i]);
											  			option.appendChild(document.createTextNode(sampleTypes[i]));
											  			$('#sampleType').append(option);
											  		}
											  		$('#sampleType').change();
											  	}
											  }
										  });
					},
					imagePath: "images/treeIcons/"
				});
				$('body').on('change','#sampleType',function(){
					// Sample Type just changed - need to update the textareas for fields in this type that are both required & unique
					var sampleType = $('#sampleType').val();
					pl = {"action":"add","collection":sampleType};
					addObjectForm = restCall("/getForm/","POST",pl);
					$('#samplePopupExtraTextareas .samplePopupExtraTextarea').remove();
					// Loop through fields of this sample type looking for unique required fields
					$.each(addObjectForm['fields'],function(){
						if(this['required'] && this['isUnique'] && this['formName'] !== "Barcode"){
							// Make a textarea for this field where the user must enter a value/row for each sample being made
							newTextareaHTML = '<div class="samplePopupExtraTextarea" formname="'+ this['formName'] +'"><label>New '+this['formName']+' Values</label><textarea cols="18" rows="5"></textarea></div>'
							$('.samplePopupInner > #samplePopupExtraTextareas').append(newTextareaHTML);
						}
					});

					// Update the templates available in sampleMapTemplatesDropdown
					updateMappingTemplateDropdown('sampleMapTemplatesDropdown', window.sampleMappingTemplates, collection, sampleType);
				});
				$('body').on('change','.sampleMapTemplatesDropdown',function(){
					if($(this).val().toLowerCase() == "custom"){
						$('#samplePopup').addClass('customMappingTemplateSelected').removeClass('savedMappingTemplateSelected');
					}
					else{
						$('#samplePopup').removeClass('customMappingTemplateSelected').addClass('savedMappingTemplateSelected');
					}
				});
				$('.sampleMapTemplatesDropdown').change();
			}
			//end sample

			//start addFromELN
			if(action == "addFromELN"){
				blackOn();

				//setup args to include whole grid... 
				var jsonKeys = Object.keys(window.top.experimentJSON).filter(x => x.substring(0, args.prefix.length) == args.prefix);
				$.each(jsonKeys, function(index, key){
					args[key.substring(args.prefix.length +1 ).toLowerCase()] = window.top.experimentJSON[key];
				});

				popup = newPopup("addFromELN");

				label = createLabel("New Location");
				popup.appendChild(label);

				div = createDiv("treeAdd");
				popup.appendChild(div);

				label = createLabel("Target Container Type");
				popup.appendChild(label);

				sampleTypes = restCall("/getSampleTypes/","POST",{});
				sampleTypeSelect = createSelectForForm("sampleType");
				sampleTypeSelect.appendChild(createOption("", "--SELECT A LOCATION--"));
				sampleTypeSelect.addEventListener("change", function() {
					var tree = $("#treeAdd").dynatree("getTree");
					var parentKey = tree.activeNode.data.key;
					var parentId = parseInt(parentKey);
					popupFormGeneator(this.value, parentId, "formDiv", theLink, args);
				})
				popup.appendChild(sampleTypeSelect);

				label = createLabel("Additional Barcode(s)");
				popup.appendChild(label);
				newBarcodeBox = createNewBarcodeBox("32", "10");
				popup.appendChild(newBarcodeBox);
				
				var formDiv = createDiv("formDiv");
				popup.appendChild(formDiv);
				document.getElementById("contentTable").style.position = null;
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				var tree = $("#treeAdd").dynatree({
					initAjax: {
						url: "/getTree/",
				 	    data: {
							key: "root", // Optional arguments to append to the url
							mode: "all",
							type: "root",
							connectionId:connectionId
						}
					},
					onLazyRead: function(node){
						node.appendAjax({
							url: "/getTree/",
							data: {
								"key": node.data.key.replace("_",""), // Optional url arguments
								"mode": "all",
								"type": node.data.type,
								connectionId:connectionId
							}
						});
					},
					onClick: function(node){
						var type = node.data.type;
						node.appendAjax({
							url: "/getTree/",
							data: {
								"key": node.data.key.replace("_",""), // Optional url arguments
								"mode": "all",
								"type": type,
								connectionId: connectionId
							},
							success: function(data){
								node.expand();
							}
						});
						clearContainer("formDiv");
						updateContainerSelect(sampleTypeSelect, type, true);
					},
					imagePath: "images/treeIcons/",
					onPostInit: function(isReloading,isError){
						kp = "<%=session("defaultAddFromELNKeyPath")%>";
						if (kp!=""){
							this.loadKeyPath(kp, function(node, status){
								// do nothing 
							});
						}
					}
				});

			}
			//end addFromELN

			if(action == "addAfterRegFromELN"){
				// set some display styles to block and hids some divs 
				blackOn();
				
				// setup the popup 
				popup = newPopup("addAfterRegFromELN");
				
				// creats a label and add it for the tree
				label = createLabel("Select Location");
				popup.appendChild(label);

				// Creates the item tree and adds it to the popup
				div = createDiv("treeAdd");
				popup.appendChild(div);

				//create a lable and add it for container type
				label = createLabel("Target Container Type");
				popup.appendChild(label);

				//setup select for container
				var restrictedFields = ["amount", "units", "structure"];
				sampleTypeSelect = createSelectWithOptions("sampleType", [], "");
				popup.appendChild(sampleTypeSelect);
				
				//setup amount label
				label = createLabel("Amount");
				popup.appendChild(label);

				//setup amount field 
				amountBox = document.createElement("input");
				amountBox.setAttribute("type","number");
				amountBox.setAttribute("id","totalAmount");
				amountBox.addEventListener('change', (event) => {
					$("#amountInput").val(event.target.value / $("#numContainers").val());
				});
				amountBox.value = args["amount"]
				popup.appendChild(amountBox);

				//setup units label
				amountUnits = args["amountUnits"];
				label = createLabel("Amount Units");
				popup.appendChild(label);

				//setup units field
				unitTypes = restCall("/getUnitTypes/","POST",{});
				unitTypeSelect = createSelectWithOptions("unitType", unitTypes, amountUnits);
				popup.appendChild(unitTypeSelect);

				//setup number of containers label
				label = createLabel("Number of Containers");
				popup.appendChild(label);

				//setup number of containers field 
				containerCount = document.createElement("input");
				containerCount.setAttribute("type","number");
				containerCount.setAttribute("min","1");
				containerCount.setAttribute("max","20");
				containerCount.setAttribute("id","numContainers");
				containerCount.addEventListener('change', (event) => {
					$("#amountInput").val( $("#totalAmount").val() / event.target.value);
				});
				containerCount.value = 1;
				popup.appendChild(containerCount);
				
				//setup label for actual ammount
				label = createLabel("Amount Per container");
				popup.appendChild(label);

				//setup actual amount per container.
				actualAmount = document.createElement("input");
				actualAmount.setAttribute("disabled","disabled");
				actualAmount.setAttribute("id","amountInput");
				actualAmount.value = args["amount"];
				popup.appendChild(actualAmount);

				requiredFields = document.createElement("div");
				requiredFields.setAttribute("id","requiredFields");
				popup.appendChild(requiredFields);

				label = createLabel("New Barcode(s)");
				popup.appendChild(label);
				newBarcodeBox = createNewBarcodeBox("32", "20");
				popup.appendChild(newBarcodeBox);

				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(tree,amountBox,newBarcodeBox,sampleTypeSelect,unitTypeSelect,containerCount){
					return function(){
						//begin submit
						//get sample type
						var sampleType = $("#sampleType").val()
						//get unit type
						var unitType = unitTypeSelect.options[unitTypeSelect.selectedIndex].value;
						//get ammount per container
						var amount = actualAmount.value;
						//check if we required data
						if(unitType==""){
							window.top.swal('Please select a unit',"",'error');
							return false;
						}
						if(sampleType==""){
							window.top.swal("Please select a Container Type", "", "error");
							return false;
						}
						if(!parseInt(amount)){
							window.top.swal("Please select a amount", "", "error");
							return false;
						}
						//get barcodes
						var barcodes = [];
						var barcodeStr = newBarcodeBox.value;
						var b = barcodeStr.split("\n");
						barcodes = b.filter(x => x != "");
						//get container count
						var numOfContainers = containerCount.value;
						//make sure we have enough barcodes as containers
						if (numOfContainers != barcodes.length) {
							window.top.swal("The number of barcodes needs to equal the number of containers!", "", "error");
							return false;
						} 
						//get location
						node = $("#treeAdd").dynatree("getActiveNode")
						if(!node){
							window.top.swal("Please highlight a location", "", "error");
						}
					
						targetId = parseInt(node.data.key);
						var reqError = "";
						var requiredValues = {};
						$.each($("#requiredFields").children("[dbname]").toArray(), function(index, field){
							let val = $(field).val();
							if (!val){
								reqError = `Please add a value for: ${$(field).prev().html()}`
								return false;
							}
							requiredValues[$(field).attr("dbname")] = val;

						});
						
						if (reqError){
							window.top.swal(reqError, "", "error");
							return false;
						}
						
						// setup items for submition 
						var items = []
						for(var i=0; i < numOfContainers; i++){
							items.push({
								"amount":parseFloat(amount),
								"barcode":barcodes.pop(),
								"type":sampleType,
								"units":unitType,
								"elnLink":args["elnLink"],
								"molData":args["molData"],
								"trivialName":args["trivialName"],
								"registrationId":args['regId'],
								"elnLink":args["elnLink"],
								...requiredValues
							})
						}	 

						//submit 
						nodesToReload.push(node.data.key)
						button.setAttribute("value","WAIT"); 
						// use ajax to make sure we do not lock up the page.
						makeAjaxPost("/AddForm/", {
							"targetId":targetId,
							"items":items
						}).then(function(r){
							// make sure we have a proper response 
							try {
								r = JSON.parse(r);
							} 
							catch (error) {
								// sometimes inv locks up on the back end. This can be fixed by just waiting and resubmitting... 
								// we do want the user to know though so we need to say something. 
								console.error(error);
								window.top.swal("Internal Server Error", "Please contact Support.", "error");
								button.setAttribute("value","OK");
							}

							// check for errors and then act accordingly
							if(!r["error"]){
								
								for(var i=0;i<r["newContainers"].length;i++){
									item = r["newContainers"][i];
									window.parent.addInventoryLink(item["id"],item["amount"],item["name"]);
								}
								window.parent.getInventoryLinks();
								window.parent.hidePopup("inventoryPopup");
								if(experimentType==1){
									window.parent.removeInvLinks(args["prefix"]);
									window.parent.makeInvLinks(args["prefix"],r["newContainers"]);
								}
								el = document.getElementById("samplePopup");
								el.parentNode.removeChild(el);
								document.body.innerHTML = "";
								if(window.parent.molUpdatePrefix!=""){
									window.parent.molUpdatePrefix = "";
									window.parent.molUpdateCdxml = "";
									if(window.parent.inventoryAddCallback)
										window.parent.inventoryAddCallback();
								}
							}else{
								window.top.swal(r["errorText"], "", "error");
								button.setAttribute("value","OK");
							}
						});
						
						
					}
				})(tree,amountBox,newBarcodeBox,sampleTypeSelect,unitTypeSelect,containerCount);


				button.setAttribute("value","OK");
				button.setAttribute("style", "margin-bottom: 425px;");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				$("#treeAdd").dynatree({
					initAjax: {
						url: "/getTree/",
				 	    data: {
							key: "root", // Optional arguments to append to the url
							mode: "all",
							type: "root",
							connectionId:connectionId
						}
					},
					onLazyRead: function(node){
						node.appendAjax({
							url: "/getTree/",
							data: {
								"key": node.data.key.replace("_",""), // Optional url arguments
								"mode": "all",
								"type": node.data.type,
								connectionId:connectionId
							}
						});

						// after the user clicks we need to update the selectable objects the user can add
						let sampleTypes = restCall("/GetAllowedChildrenWithFields/","POST", {"type": node.data.type, "fields": restrictedFields},"text/plain");
						sampleTypes = jsonParse(sampleTypes);
						sampleTypes = sampleTypes ? sampleTypes : [];
						let defaultSampleTypes = restCall("/getSampleTypes/","POST",{}, "text/plain");
						defaultSampleTypes = jsonParse(defaultSampleTypes);
						defaultSampleTypes = defaultSampleTypes ? defaultSampleTypes : [];
						sampleTypes.push(...defaultSampleTypes);
						$("#sampleType").replaceWith(addTypeSelectChangeHandler(createSelectWithOptions("sampleType", sampleTypes, "")));
						
					},
					onClick: function(node){
						node.appendAjax({
							url: "/getTree/",
							data: {
								"key": node.data.key.replace("_",""), // Optional url arguments
								"mode": "all",
								"type": node.data.type,
								connectionId:connectionId
							},
							success: function(data){
								node.expand();
							}
						});

						// after the user clicks we need to update the selectable objects the user can add
						let sampleTypes = restCall("/GetAllowedChildrenWithFields/","POST", {"type": node.data.type, "fields": restrictedFields},"text/plain");
						sampleTypes = jsonParse(sampleTypes);
						sampleTypes = sampleTypes ? sampleTypes : [];
						let defaultSampleTypes = restCall("/getSampleTypes/","POST",{}, "text/plain");
						defaultSampleTypes = jsonParse(defaultSampleTypes);
						defaultSampleTypes = defaultSampleTypes ? defaultSampleTypes : [];
						sampleTypes.push(...defaultSampleTypes);
						$("#sampleType").replaceWith(addTypeSelectChangeHandler(createSelectWithOptions("sampleType", sampleTypes, "")));
					},
					imagePath: "images/treeIcons/",
					onPostInit: function(isReloading,isError){
						kp = "<%=session("defaultAddFromELNKeyPath")%>";
						if (kp!=""){
							this.loadKeyPath(kp, function(node, status){
								if(status == "loaded") {
									node.activate();
								}else if(status == "ok") {
									node.activate();
								}else if(status == "notfound") {
									var seg = arguments[2],
										isEndNode = arguments[3];
								}
							});
						}
					}
				});
			}

			//start addFromNonChemELN
			if(action == "addFromNonChemELN"){
				blackOn();
				popup = newPopup("addFromNonChemELN");


				label = createLabel("New Location");
				popup.appendChild(label);

				div = createDiv("treeAdd");
				popup.appendChild(div);

				label = createLabel("Target Container Type");
				popup.appendChild(label);

				var formDiv = createDiv("formDiv");

				sampleTypes = restCall("/getSampleTypes/","POST",{});
				sampleTypeSelect = createSelectForForm("sampleType");
				sampleTypeSelect.appendChild(createOption("", "--SELECT A LOCATION--"));
				sampleTypeSelect.addEventListener("change", function() {
					var tree = $("#treeAdd").dynatree("getTree");
					var parentKey = tree.activeNode.data.key;
					var parentId = parseInt(parentKey);
					sampleTypeSelectChangeHandler(this.value, parentId, "formDiv", theLink);
				})
				popup.appendChild(sampleTypeSelect);
				popup.appendChild(formDiv);
				
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				var tree = $("#treeAdd").dynatree({
					initAjax: {
						url: "/getTree/",
				 	    data: {
							key: "root", // Optional arguments to append to the url
							mode: "all",
							type: "root",
							connectionId:connectionId
						}
					},
					onLazyRead: function(node){
						node.appendAjax({
							url: "/getTree/",
							data: {
								"key": node.data.key.replace("_",""), // Optional url arguments
								"mode": "all",
								"type": node.data.type,
								connectionId:connectionId
							}
						});
					},
					onClick: function(node){
						var type = node.data.type;
						node.appendAjax({
							url: "/getTree/",
							data: {
								"key": node.data.key.replace("_",""), // Optional url arguments
								"mode": "all",
								"type": type,
								connectionId: connectionId
							},
							success: function(data){
								node.expand();
							}
						});
						clearContainer("formDiv");
						updateContainerSelect(sampleTypeSelect, type);
					},
					imagePath: "images/treeIcons/",
					onPostInit: function(isReloading,isError){
						kp = "<%=session("defaultAddFromELNKeyPath")%>";
						if (kp!=""){
							this.loadKeyPath(kp, function(node, status){
								if(status == "loaded") {
									node.activate();
								}else if(status == "ok") {
									node.activate();
								}else if(status == "notfound") {
									var seg = arguments[2],
										isEndNode = arguments[3];
								}
							});
						}
					}
				});
			}
			//end addFromNonChemELN

			//start addFromREG
			if(action == "addFromREG"){
				blackOn();
				popup = newPopup("samplePopup");
				popup.style.width="300px"
				popup.style.height="600px"

				label = createLabel("New Location");
				popup.appendChild(label);

				div = createDiv("treeAdd");
				popup.appendChild(div);

				label = createLabel("Target Container Type");
				popup.appendChild(label);
				
				sampleTypeSelect = createSelectForForm("sampleType");
				option = createOption("Bulk Reagent", "Bulk Reagent");
				sampleTypeSelect.appendChild(option);
				popup.appendChild(sampleTypeSelect);
				
				label = createLabel("Number of Containers");
				popup.appendChild(label);

				numContainersBox = document.createElement("input");
				numContainersBox.setAttribute("type","text");
				popup.appendChild(numContainersBox);

				label = createLabel("Amount");
				popup.appendChild(label);

				amountBox = document.createElement("input");
				amountBox.setAttribute("type","text");
				amountBox.value = args["amount"]
				popup.appendChild(amountBox);

				amountUnits = args["amountUnits"];
				label = createLabel("Amount Units");
				popup.appendChild(label);

				unitTypes = restCall("/getUnitTypes/","POST",{});
				unitTypeSelect = createSelectWithOptions("unitType", unitTypes, amountUnits);
				popup.appendChild(unitTypeSelect);

				label = createLabel("New Barcode(s)");
				popup.appendChild(label);

				newBarcodeBox = createNewBarcodeBox("18", "5");
				popup.appendChild(newBarcodeBox);

				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(tree,amountBox,newBarcodeBox,sampleTypeSelect,unitTypeSelect,numContainersBox){
					return function(){
						sampleType = sampleTypeSelect.options[sampleTypeSelect.selectedIndex].value;
						unitType = unitTypeSelect.options[unitTypeSelect.selectedIndex].value;
						amount = amountBox.value;
						numContainers = parseInt(numContainersBox.value);
						if(unitType==""){
							alert("Please select units");
							return false;
						}
						barcodes = [];
						barcodeStr = newBarcodeBox.value;
						b = barcodeStr.split("\n");
						for(var i=0;i<b.length;i++){
							if(b[i]!=""){
								barcodes.push(b[i]);
							}
						}
						if(!(numContainers === parseInt(numContainers, 10)) && barcodes.length==0){
							alert("Please enter a number of containers or a barcode for each container to be created.")
							return false;
						}
						if(barcodes.length==0){
							for(var k=0;k<numContainers;k++){
								barcodes.push("");
							}
						}
						node = $("#treeAdd").dynatree("getActiveNode")
						if(!node){
							alert("Please highlight a location");
						}
						targetType = node.data.type;
						targetId = parseInt(node.data.key);
						allowedChildren = restCall("/getAllowedChildren/","POST",{"type":targetType});
						r = restCall("/getLocations/","POST",{"type":targetType,"id":targetId});
						if (r.status=="locationRequired"){
							locations = r.locations;
							popup = newPopup("locationPopup");
							popup.style.width="300px"
							popup.style.height="500px"
							label = document.createElement("label");
							label.innerHTML = "Location";
							popup.appendChild(label);

							select = document.createElement("select");
							select.setAttribute("id","addType");
							for(var i=0;i<locations.length;i++){
								option = document.createElement("option");
								option.setAttribute("value",locations[i]);
								option.appendChild(document.createTextNode(locations[i]));
								select.appendChild(option);
							}
							popup.appendChild(select);
							button = document.createElement("input");
							button.setAttribute("type","button");
							button.onclick = (function(select,node){
								return function(){
									loc = select.options[select.selectedIndex].value;
									el = document.getElementById("locationPopup");
									el.parentNode.removeChild(el);
									nodesToReload.push(node.data.key)
									r = restCall("/addFromREG/","POST",{"targetId":targetId,"location":loc,"amount":parseFloat(amount),"barcodes":barcodes,"type":sampleType,"amountUnits":unitType,"elnLink":args["elnLink"],"regId":args["regId"],"molData":args["molData"],"trivialName":args["trivialName"]})
									if(!r["error"]){
										clearContainer(containerName);
										window.parent.addInventoryLinks(JSON.stringify(r["newContainers"]));
										window.parent.hidePopup("inventoryPopup");
										el = document.getElementById("samplePopup");
										el.parentNode.removeChild(el);
										document.body.innerHTML = "";
										return false;
									}else{
										alert(r["errorText"])
									}
								}
							})(select,node);
							button.setAttribute("value","OK");
							popup.appendChild(button);
							document.getElementById("contentTable").appendChild(popup);
							window.scroll(0,0);
						}else{
							nodesToReload.push(node.data.key)
							r = restCall("/addFromREG/","POST",{"targetId":targetId,"amount":parseFloat(amount),"barcodes":barcodes,"type":sampleType,"amountUnits":unitType,"elnLink":args["elnLink"],"regId":args["regId"],"molData":args["molData"],"trivialName":args["trivialName"]})
							if(!r["error"]){
								clearContainer(containerName);
								window.parent.addInventoryLinks(JSON.stringify(r["newContainers"]));
								window.parent.hidePopup("inventoryPopup");
								el = document.getElementById("samplePopup");
								el.parentNode.removeChild(el);
								document.body.innerHTML = "";
								return false;
							}else{
								alert(r["errorText"])
							}
						}
					}
				})(tree,amountBox,newBarcodeBox,sampleTypeSelect,unitTypeSelect,numContainersBox);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				popup.style.left = "250px";
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				$("#treeAdd").dynatree({
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
					onClick: function(node){
						node.appendAjax({url: "/getTree/",
										   data: {"key": node.data.key.replace("_",""), // Optional url arguments
												  "mode": "all",
												  "type": node.data.type,
												  connectionId:connectionId
												  },
											  success: function(data){
												node.expand();
											  }
										  });
					},
					imagePath: "images/treeIcons/"
				});
			}
			//end addFromREG




			//start addFromCopy
			if(action == "copy"){
				args = {}
				blackOn();
				popup = newPopup("copyPopup");
				popup.style.width="300px"
				popup.style.height="624px"

				label = createLabel("New Location");
				popup.appendChild(label);

				div = createDiv("treeAdd");
				popup.appendChild(div);

				popup.appendChild(document.createElement("br"));

				label = createLabel("Number of Copies");
				popup.appendChild(label);

				numCopiesBox = document.createElement("input");
				numCopiesBox.setAttribute("type","text");
				popup.appendChild(numCopiesBox);

				label = createLabel("New Barcode(s)");
				popup.appendChild(label);

				newBarcodeBox = createNewBarcodeBox("16", "10");
				popup.appendChild(newBarcodeBox);

				label = createLabel("Edit data before copy");
				popup.appendChild(label);

				editDataCb = document.createElement("input");
				editDataCb.setAttribute("type","checkbox");
				popup.appendChild(editDataCb);

				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(tree,newBarcodeBox,numCopiesBox){
					return function(){
						
						node = $("#treeAdd").dynatree("getActiveNode")
						if(!node){
							alert("Please highlight a location");
							return false;
						}

						barcodes = [];
						barcodeStr = newBarcodeBox.value;
						b = barcodeStr.split("\n");
						for(var i=0;i<b.length;i++){
							if(b[i]!=""){
								barcodes.push(b[i]);
							}
						}
						if (barcodes.length!=0 && numCopiesBox.value.replace(/\s+/ig,"")!="" && !(barcodes.length == numCopiesBox.value.replace(/\s+/ig,""))){
							alert("Number of barcodes entered does not equal the number of copies requested.");
							return false;							
						}
						if(barcodes.length==0){
							numCopies = numCopiesBox.value.replace(/[^0-9]/,"")
							for(var i=0;i<numCopies;i++){
								barcodes.push("")
							}
						}
						if(barcodes.length==0){
							alert("Please enter one or more barcodes or select a number of copies");
							return false;
						}
						errors = restCall("/barcodesExist/","POST",{"barcodes":barcodes});
						if (errors.length!=0){
							alert(errors.join("\n"));
							return false;
						}

						allowedChildren = restCall("/getAllowedChildren/","POST",{"type":node.data.type});
						if (allowedChildren.indexOf(collection)==-1){
							alert("You cannot create this type of object in this location");
							return false
						}


						el = document.getElementById("copyPopup");
						el.parentNode.removeChild(el);
						blackOff();
						if(!editDataCb.checked){
							blackOn();
							$("#copyingDiv").show();
						}
						clearContainer(containerName);
						pl = {"action":"edit","collection":collection,"id":id,"multi":true,"fieldToHide":"barcode"};
						addObjectForm = restCall("/getForm/","POST",pl);
						formBucket.push(addObjectForm);
						addObjectForm.onSave = function(fd,node,barcodes){
							return function(){
								if(validateForm(fd)){
									r = saveFormMulti(fd,true,"barcode",barcodes,false,node.data.key,"created from copy");
									clearContainer(containerName);
									handleNodeReloads([node.data.key],[node.data.key],parentTree,tree);
								}
							}
						}(addObjectForm,node,barcodes);
						makeForm(addObjectForm,containerName,undefined,undefined,function(){
							$("div [formName=versionDiv]").text("Make Copy");
							$("div [formName=auditTrail]").hide();
							$("div [formName='CAS Lookup']").hide();
							$("div [formName=View]").hide();
							$("div [formName='Date Created']").hide();
							$("div [formName='User Added']").hide();
							if(!editDataCb.checked){
								addObjectForm.onSave();
								$("#copyingDiv").hide();
								blackOff();
							}
						})
					}
				})(tree,newBarcodeBox,numCopiesBox);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				$("#treeAdd").dynatree({
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
					onClick: function(node){
						node.appendAjax({url: "/getTree/",
										   data: {"key": node.data.key.replace("_",""), // Optional url arguments
												  "mode": "all",
												  "type": node.data.type,
												  connectionId:connectionId
												  },
											  success: function(data){
												node.expand();
											  }
										  });
					},
					imagePath: "images/treeIcons/",
					onPostInit: function(isReloading,isError){
						loadParentTree(parentTree,this);
					}
				});
				document.getElementById("treeAdd").style.width="300px";
			}
			//end addFromCopy

			//start bulkDispose
			if(action == "bulkDispose"){

				popup = document.createElement("div");
				header = document.createElement("h2");
				bulkDisposeText = "Bulk Dispose";
				header.innerHTML = bulkDisposeText;
				popup.appendChild(header);

				label = createLabel("Scan or Enter Barcodes");
				popup.appendChild(label);

				newBarcodeBox = createNewBarcodeBox("38", "30");
				popup.appendChild(newBarcodeBox);

				swal({
					title: null,
					text: $(popup).html(),
					html: true,
					customClass: "bulkActionPopup",
					closeOnConfirm: false,
					allowOutsideClick: false
				},function(){
					barcodes = [];
					barcodeStr = document.getElementById("barcodeBox").value;
					//alert(barcodeStr);
					b = barcodeStr.split("\n");
					for(var i=0;i<b.length;i++){
						if(b[i]!=""){
							barcodes.push(b[i]);
						}
					}
					if(barcodes.length==0){
						alert("Please enter one or more barcodes");
						return false;
					}
					pl = {};
					pl["barcodes"] = barcodes;

					swal({
						title: null,
						text: 'Loading...',
						html: true,
						customClass: "bulkActionPopup_loading",
						closeOnConfirm: false,
						closeOnCancel: false,
						allowOutsideClick: false
					});

					restCallA("/bulkDispose/","POST",pl,function(r){
						if(r.errors.length == 0){
							swal({
								title: bulkDisposeText + " Successful", 
								text: null,
								type: "success",
								timer: 1600
							});
						}else{
							swal({
								title: bulkDisposeText + " Alert", 
								text: r.errors.join("<br />"),
								html: true,
								type: "error"
							});
						}

						$('.sweet-alert.bulkActionPopup').removeClass('bulkActionPopup');
						nodesToReload = r.nodesToReload;
						var match = null;
						tree.visit(function(node){
							if(node.data.title === "Disposed"){
								match = node.data.key;
								return false;
							}
						});
						if(match){
							nodesToReload.push(match);
						}
						handleNodeReloads(nodesToReload,nodesToReload,false,tree);
					});
				});
			}
			//end bulkDispose

			//start bulkCheckInOut
			if(action == "bulkCheckIn" || action == "bulkCheckOut"){
				if(action == "bulkCheckIn"){
					checkingOut = false;
				}
				else if(action == "bulkCheckOut"){
					checkingOut = true;
				}
				popup = document.createElement("div");
				header = document.createElement("h2");
				if(action == "bulkCheckIn"){
					bulkCheckInOutText = "Bulk Check In";
				}
				else{
					bulkCheckInOutText = "Bulk Check Out";
				}
				header.innerHTML = bulkCheckInOutText;
				popup.appendChild(header);
				
				label = createLabel("Scan or Enter Barcodes");
				popup.appendChild(label);

				newBarcodeBox = createNewBarcodeBox("38", "30");
				popup.appendChild(newBarcodeBox);

				swal({
					title: null,
					text: $(popup).html(),
					html: true,
					customClass: "bulkActionPopup",
					closeOnConfirm: false,
					allowOutsideClick: false
				},function(){
					barcodes = [];
					barcodeStr = document.getElementById("barcodeBox").value;
					b = barcodeStr.split("\n");
					for(var i=0;i<b.length;i++){
						if(b[i]!=""){
							barcodes.push(b[i]);
						}
					}
					if(barcodes.length==0){
						alert("Please enter one or more barcodes");
						return false;
					}
					pl = {};
					pl["barcodes"] = barcodes;
					pl["value"] = checkingOut;
					
					swal({
						title: null,
						text: 'Loading...',
						html: true,
						customClass: "bulkActionPopup_loading",
						closeOnConfirm: false,
						closeOnCancel: false,
						allowOutsideClick: false
					});
					
					restCallA("/bulkCheckInOut/","POST",pl,function(r){
						if(r.errors.length == 0){
							swal({
								title: bulkCheckInOutText + " Successful", 
								text: null,
								type: "success",
								timer: 1600
							});
						}else{
							swal({
								title: bulkCheckInOutText + " Alert", 
								text: r.errors.join("<br />"),
								html: true,
								type: "error"
							});
						}
						$('.sweet-alert.bulkActionPopup').removeClass('bulkActionPopup');
						nodesToReload = r.nodesToReload;
						tree = $("#tree").dynatree("getTree");
						if(typeof addObjectForm !== "undefined"){
							parentTree = addObjectForm.parentTree;
							nodesToReload.push(parentTree[0]["id"].toString()+"_checkedout");
							nodesToReload.push(parentTree[parentTree.length-1]["id"]);
						}
						nodesToReload = array_unique(nodesToReload);
						console.log(nodesToReload);
						handleNodeReloads(nodesToReload,[],false,tree);
					});
				});
				document.getElementById("barcodeBox").focus();
			}
			//end bulkCheckInOut

			if(action == "bulkMove"){
				if(!args){
					args = {};
					args["labelName"] = "Barcodes";
					args["readOnly"] = false;
					args["fieldName"] = "barcode";
					args["values"] = [];
				}
				blackOn();
				popup = newPopup("movePopup");
				popup.style.width="300px"
				popup.style.height="550px"

				label = createLabel("New Location");
				popup.appendChild(label);

				div = createDiv("treeBulkMove");
				popup.appendChild(div);
				
				popup.appendChild(document.createElement("br"));

				label = createLabel(args["labelName"]);
				popup.appendChild(label);

				newBarcodeBox = createNewBarcodeBox("32", "12");
				if(args["readOnly"]){
					newBarcodeBox.setAttribute("readonly","1");
				}
				newBarcodeBox.value = args["values"].join("\n")
				popup.appendChild(newBarcodeBox);

				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(newBarcodeBox){
					return function(){
						node = $("#treeBulkMove").dynatree("getActiveNode")
						targetId = parseInt(node.data.key);
						barcodes = [];
						barcodeStr = newBarcodeBox.value;
						b = barcodeStr.split("\n");
						for(var i=0;i<b.length;i++){
							if(b[i]!=""){
								barcodes.push(b[i]);
							}
						}
						if(barcodes.length==0){
							alert("Please enter one or more items");
							return false;
						}
						pl = {};
						pl["values"] = barcodes;
						pl["targetId"] = targetId;
						pl["fieldName"] = args["fieldName"];
						button.setAttribute("value","Please Wait...");
						button.disabled = true;
						restCallA("/bulkMove/","POST",pl,function(r){
								if(r.errors.length == 0){
								nodesToReload = r.nodesToReload;
								handleNodeReloads(nodesToReload,nodesToReload,false,tree);
									el = document.getElementById("movePopup");
									el.parentNode.removeChild(el);
									blackOff();
									try{
									window.parent.hidePopup("inventoryPopup");
									}catch(err){}
								}else{
									alert(r.errors.join("\n"));
								}
								button.setAttribute("value","OK");
								button.disabled = false;
							}
						);
					}
				})(newBarcodeBox,tree);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				$("#treeBulkMove").dynatree({
					onPostInit: function(isReloading, isError) {
						this.$tree.dynatree('getRoot').visit(function(node){ // INV-222
					        $(node.span).children('a').click(); // click the root node...
					    });
					},
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
					onClick: function(node){
						node.appendAjax({url: "/getTree/",
										   data: {"key": node.data.key.replace("_",""), // Optional url arguments
												  "mode": "all",
												  "type": node.data.type,
												  connectionId:connectionId
												  },
											  success: function(data){
												node.expand();
											  }
										  });
					},
					imagePath: "images/treeIcons/"
				});
			}
			//end bulkMove

			if(action == "edit"){
				nodesToReload.push(parentTree[parentTree.length-1]["id"])
				clearContainer(containerName);
				pl = {"action":"edit","collection":collection,"id":id};
				addObjectForm = restCall("/getForm/","POST",pl);
				window.itemJSON = addObjectForm;
				formBucket.push(addObjectForm);
				addObjectForm.onSave = function(fd,node){ // on click of submit button
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
			}
			if(action == "view"){
				clearContainer(containerName);
				pl = {"action":"view","collection":collection,"id":id};
				addObjectForm = restCall("/getForm/","POST",pl);								
				makeForm(addObjectForm,containerName);
			}
			if(action == "viewList"){
				clearContainer(containerName);
				getList(false,false,{"parent.collection":"inventoryItems","parent.id":parseInt(id),"disposed":false,"checkedOut":false},tableFields)
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

				label = createLabel("Use");
				popup.appendChild(label);

				span = document.createElement("span");
				span.innerHTML = "<em>Amount Remaining:</em> "+amount+" "+units;
				popup.appendChild(span);
				
				textBox = document.createElement("input");
				textBox.setAttribute("type","text");
				popup.appendChild(textBox);
				
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(textBox,node,button){
					return function(){
						button.disabled = true
						pl = {"collection":collection,"id":id,"fieldName":amountField,"value":parseFloat(textBox.value)};
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
				})(textBox,node,button);
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
				label = createLabel("New Location");
				popup.appendChild(label);

				div = createDiv("treeMove");
				popup.appendChild(div);
				
				button = document.createElement("input");
				button.setAttribute("type","button");
				button.onclick = (function(id,collection,tree){
					return function(){
						node = $("#treeMove").dynatree("getActiveNode")
						targetType = node.data.type;
						targetId = parseInt(node.data.key);
						allowedChildren = restCall("/getAllowedChildren/","POST",{"type":targetType});
						r = restCall("/getLocations/","POST",{"type":targetType,"id":targetId});
						if (r.status=="locationRequired"){
							locations = r.locations;
							popup = newPopup("locationPopup");
							popup.style.width="300px"
							popup.style.height="500px"
							label = document.createElement("label");
							label.innerHTML = "Location";
							popup.appendChild(label);

							select = document.createElement("select");
							select.setAttribute("id","addType");
							for(var i=0;i<locations.length;i++){
								option = document.createElement("option");
								option.setAttribute("value",locations[i]);
								option.appendChild(document.createTextNode(locations[i]));
								select.appendChild(option);
							}
							popup.appendChild(select);
							button = document.createElement("input");
							button.setAttribute("type","button");
							button.onclick = (function(select,node){
								return function(){
									loc = select.options[select.selectedIndex].value;
									el = document.getElementById("locationPopup");
									el.parentNode.removeChild(el);
									nodesToReload.push(node.data.key)
									restCall("/moveItem/","POST",{"id":id,"collection":collection,"targetId":targetId,"location":loc})
									clearContainer(containerName);
									handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
									el = document.getElementById("movePopup");
									el.parentNode.removeChild(el);
									blackOff();
									return false;
								}
							})(select,node);
							button.setAttribute("value","OK");
							popup.appendChild(button);
							document.getElementById("contentTable").appendChild(popup);
							window.scroll(0,0);
						}else{
							if(allowedChildren.indexOf(collection)!=-1){
								nodesToReload.push(node.data.key)
								restCall("/moveItem/","POST",{"id":id,"collection":collection,"targetId":targetId})
								clearContainer(containerName);
								handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
								el = document.getElementById("movePopup");
								el.parentNode.removeChild(el);
								blackOff();
							}else{
								alert("Item may not be moved to this location.")
							}
						}
					}
				})(id,collection,tree);
				button.setAttribute("value","OK");
				popup.appendChild(button);
				document.getElementById("contentTable").appendChild(popup);
				window.scroll(0,0);
				$("#treeMove").dynatree({
					onPostInit: function(isReloading, isError) {
						this.$tree.dynatree('getRoot').visit(function(node){ // INV-222
					        $(node.span).children('a').click(); // click the root node...
					    });
					},
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
					onClick: function(node){
						node.appendAjax({url: "/getTree/",
										   data: {"key": node.data.key.replace("_",""), // Optional url arguments
												  "mode": "all",
												  "type": node.data.type,
												  connectionId:connectionId
												  },
											  success: function(data){
												node.expand();
											  }
										  });
					},
					imagePath: "images/treeIcons/"
				});
			}
			if(action == "dispose"){
				// INV-145
				clearContainer(containerName);
				pl = {"action":"view","collection":collection,"id":id};
				addObjectForm = restCall("/getForm/","POST",pl);								
				var numberOfChildren = 0;
				$.each(addObjectForm['fields'],function(){
					if(this['formName'] == "_numChildren"){
						numberOfChildren = this['value'];
						return false;
					}
				});
				if(numberOfChildren > 0){
					swal({   
						title: "Are you sure?",
						text: "Are you sure you want to dispose of this location? Any sub-locations or objects contained within this location will also be disposed.",
						type: "warning",
						showCancelButton: true,
						confirmButtonColor: "#DD6B55",
						confirmButtonText: "Confirm",
						closeOnConfirm: false 
					}, function(){
						nodesToReload.push(parentTree[0]["id"].toString()+"_disposed")
						nodesToReload.push(parentTree[parentTree.length-1]["id"])
						nodesToActivate.push(parentTree[parentTree.length-1]["id"])
						pl = {"collection":collection,"id":id,"fieldName":"disposed","value":true};
						addObjectForm = restCall("/updateFieldById/","POST",pl);
						handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
						swal("Location Disposed", "The location was successfully disposed.", "success");
					});
				}
				else{
					nodesToReload.push(parentTree[0]["id"].toString()+"_disposed")
					nodesToReload.push(parentTree[parentTree.length-1]["id"])
					nodesToActivate.push(parentTree[parentTree.length-1]["id"])
					pl = {"collection":collection,"id":id,"fieldName":"disposed","value":true};
					addObjectForm = restCall("/updateFieldById/","POST",pl);
					handleNodeReloads(nodesToReload,nodesToActivate,parentTree,tree);
				}
			}
		}

		/**
		 * Creates an HTML div element with the given id.
		 * @param {string} id The id of this div.
		 */
		function createDiv(id) {
			var div = document.createElement("div")
			div.setAttribute("id", id);
			return div;
		}

		/**
		 * Creates an HTML label element with the given labelName.
		 * @param {string} labelName The name of this label.
		 */
		function createLabel(labelName) {
			var label = document.createElement("label");
			label.innerHTML = labelName;
			return label;
		}

		/**
		 * Creates an HTML textarea element with the given id that is cols wide and rows tall.
		 * Named createBasicTextArea as a function so that it does not collide with the one in arxOne.js
		 * @param {string} id The id of this element.
		 * @param {string} cols The number of columns for this barcode box.
		 * @param {string} rows The number of rows for this barcode box.
		 */
		function createBasicTextArea(id, cols, rows) {
			var textarea = document.createElement("textarea");
			textarea.setAttribute("id", id);
			textarea.setAttribute("cols", cols);
			textarea.setAttribute("rows", rows);
			return textarea;
		}

		/**
		 * Creates an HTML textarea element so users can enter barcodes.
		 * @param {string} cols The number of columns for this barcode box.
		 * @param {string} rows The number of rows for this barcode box.
		 */
		function createNewBarcodeBox(cols, rows) {
			var newBarcodeBox = createBasicTextArea("barcodeBox", cols, rows);
			return newBarcodeBox;
		}

		/**
		 * Creates an HTML select element with the given id.
		 * @param {string} id The id of this div.
		 */
		function createSelectForForm(id) {
			var select = document.createElement("select");
			select.setAttribute("id", id);
			return select;
		}
		
		/**
		 * Creates an HTML option element with the given value and text.
		 * @param {string} val The value of this option.
		 * @param {string} text The text to display.
		 */
		function createOption(val, text) {
			var option = document.createElement("option");
			option.setAttribute("value", val);
			option.appendChild(document.createTextNode(text));
			return option;
		}

		/**
		 * Adds the list of options to the given select option..
		 * @param {HTMLElement} select The select object.
		 * @param {string[]} optionsList The list of options to make html options out of.
		 * @param {string} preSelectedOption The option to designate as selected.
		 */
		function addOptionsListToSelect(select, optionsList, preSelectedOption) {
			if (optionsList.length > 0) {
				optionsList.forEach(function(thisOption) {
					var option = createOption(thisOption, thisOption);
					if(preSelectedOption && preSelectedOption.toLowerCase() == thisOption.toLowerCase()){
						option.setAttribute("SELECTED","SELECTED");
					}
					select.appendChild(option);
				})
			}
			else {
				return select;
			}
		}
		
		/**
		 * Creates an HTML select element with a list of options made from optionsList.
		 * @param {string} id The ID of this select.
		 * @param {string[]} optionsList The list of options to make html options out of.
		 * @param {string} preSelectedOption The option to designate as selected.
		 */
		function createSelectWithOptions(id, optionsList, preSelectedOption) {
			var select = createSelectForForm(id);
			var defaultOption = createOption("", "--SELECT--");
			select.appendChild(defaultOption);
			
			addOptionsListToSelect(select, optionsList, preSelectedOption);
			return select;
		}

		/**
		 * Helper function to update selectElem with the allowed children for the target.
		 * @param {HTMLElement} selectElem The select container to display the dropdown options.
		 * @param {string} target The type of container to add an item to, if possible.
		 * @param {bool} includeStructures Defualt to false. This indicates if we are going to retrieve containers with structures.
		 */
		function updateContainerSelect(selectElem, target, includeStructures = false) {
			getAllowedChildren(target, includeStructures).then(function(resp) {
				selectElem.innerHTML = "";
				if (resp.length > 0) {
					var defaultOption = createOption("", "--SELECT--");
					selectElem.appendChild(defaultOption);
					addOptionsListToSelect(selectElem, resp, null);
				} else {
					var invalidOption = createOption("", "--SELECT A VALID LOCATION--");
					selectElem.appendChild(invalidOption);
				}
			})
		}

		/**
		 * Helper function to fetch the allowed children for the target from inventoryActual.
		 * @param {string} target The type of container to add an item to, if possible.
		 * @param {bool} includeStructures Defualt to false. This indicates if we are going to retrieve containers with structures.
		 */
		function getAllowedChildren(target, includeStructures = false) {
			return new Promise(function(resolve, reject) {

				// We can't do chemistry in an iframe because iframes can't communicate with Chrome extensions, so
				// we're going to hide forms with structures if we catch that we're in an iframe.
				var hideStructures = (window != window.top && !includeStructures);
				makeAjaxPost("/getAllowedChildren/", {"type": target, "hideStructures": hideStructures}).then(function(r) {
					var returnArr = [];
					try {
						returnArr = JSON.parse(r);
					} catch(err) {
						console.log("Not a valid location.");
					}
					resolve(returnArr);
				});
			})
		}

		/**
		 * Helper function to fetch the target form from inventoryActual.
		 * @param {string} target The type of container to add an item to, if possible.
		 * @param {string} parentId The ID of the parent element.
		 */
		function getFormFromServer(target, parentId) {
			return new Promise(function(resolve, reject) {
				var data = {
					"action": "add",
					"collection": target,
					"parent": {
						"collection": "inventoryItems",
						"id": parentId,
					},
				};

				makeAjaxPost("/getForm/", data).then(function(r) {
					var returnObj = {};
					try {
						returnObj = JSON.parse(r);
					} catch(err) {
						console.log("Not a valid location.");
					}
					resolve(returnObj);
				});
			});
		}

		/**
		 * Helper function to handle the updates to the sample type dropdown selector.
		 * @param {string} target The type of container to add an item to, if possible.
		 * @param {string} parentId The ID of the parent element.
		 * @param {HTMLElement} formDiv The div that will hold the form.
		 * @param {string} theLink The link to the ELN experiment.
		 */
		function sampleTypeSelectChangeHandler(target, parentId, formDiv, theLink) {
			clearContainer(formDiv);
			getFormFromServer(target, parentId).then(function(response) {
				formBucket.push(response);
				response.onSave = function(fd) {
					return function() {
						if (validateForm(fd)) {
							// Figure out what name this item should use for the link to inventory.
							var nameToUse = determineBarcodeOrNameValue(fd.fields);

							// Now figure out what the amount to use and what the units are.
							var amountStringArray = [];
							amountStringArray.push(determineAmountValue(fd.fields))
							amountStringArray.push(determineUnits(fd.fields));
							var amountToUse = amountStringArray.join(" ").trim();

							// Save the form, then create a new inventory link on the ELN.
							s = saveForm(fd, true, theLink);
							window.top.addInventoryLink(s["newId"], amountToUse, nameToUse).then(function() {
								// Now that we're done, refresh the inventory links table and hide the inventory popup.
								window.top.getInventoryLinks();
								window.top.hidePopup("inventoryPopup");
							});
						}
					};
				}(response);	
				window.makeForm(response, formDiv);
			});
		}
		
		/**
		 * Helper function to get the value of a default inventory field.
		 * @param {JSON[]} fieldsList The list of fields to check.
		 * @param {string} dbName The field name in the DB to check for.
		 */
		function determineDefaultField(fieldsList, dbName) {
			var returnVal = "";
			var filteredList = fieldsList.filter(function(x) {
				return x["dbName"] == dbName;
			})

			if (filteredList.length > 0) {
				var field = filteredList[0];
				if (field["value"]) {
					returnVal = field["value"];
				}
			}
			return returnVal;
		}

		/**
		 * Helper function to get the value of a custom inventory field.
		 * @param {JSON[]} fieldsList The list of fields to check.
		 * @param {string} custIdentifier The name of the tag to check for.
		 */
		function determineCustField(fieldsList, custIdentifier) {
			var returnVal = "";
			var filteredList = fieldsList.filter(function(x) {
				return x[custIdentifier];
			})

			if (filteredList.length > 0) {
				var field = filteredList[0];
				if (field["value"]) {
					returnVal = field["value"];
				}
			}
			return returnVal;
		}

		/**
		 * Helper function to get the name or barcode value of a form.
		 * @param {JSON[]} fieldsList The list of fields to check.
		 */
		function determineBarcodeOrNameValue(fieldsList) {
			var returnVal = "No name or barcode.";
			
			var barcodeVal = determineDefaultField(fieldsList, "barcode");
			if (barcodeVal) {
				return barcodeVal;
			}

			var custBarcodeVal = determineCustField(fieldsList, "isBarcodeField");
			if (custBarcodeVal) {
				return custBarcodeVal;
			}

			var nameVal = determineDefaultField(fieldsList, "name");
			if (nameVal) {
				return nameVal;
			}

			var custNameVal = determineCustField(fieldsList, "isNameField");
			if (custNameVal) {
				return custNameVal;
			}

			return returnVal;
		}

		/**
		 * Helper function to get the amount value of a form.
		 * @param {JSON[]} fieldsList The list of fields to check.
		 */
		function determineAmountValue(fieldsList) {
			var returnVal = 0;

			var amountVal = determineDefaultField(fieldsList, "amount");
			if (amountVal) {
				return amountVal;
			}
			
			var custAmountVal = determineCustField(fieldsList, "isAmountField");
			if (custAmountVal) {
				return custAmountVal;
			}

			return returnVal;
		}

		/**
		 * Helper function to get the units value of a form.
		 * @param {JSON[]} fieldsList The list of fields to check.
		 */
		function determineUnits(fieldsList) {
			var units = "";

			var unitsVal = determineDefaultField(fieldsList, "units");
			if (unitsVal) {
				return unitsVal;
			}

			var custUnitsVal = determineCustField(fieldsList, "isAmountUnitField");
			if (custUnitsVal) {
				return custUnitsVal;
			}

			return units;
		}

		/**
		 * Helper function to make an AJAX post to invp.asp.
		 * @param {string} url The endpoint to hit in inventoryActual.
		 * @param {JSON} data The POST body.
		 */
		function makeAjaxPost(url, data) {
			return new Promise(function(resolve, reject) {
				if (!("connectionId" in data)) {
					data["connectionId"] = connectionId;
				}
				
				$.ajax({
					url: "invp.asp?r=" + Math.random(),
					type: "POST",
					data: {
						url: url,
						data: JSON.stringify(data),
						verb: "POST",
					}
				}).then(function(response) {
					resolve(response);
				});
			})
		}

	</script>
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
		#recTable td{
			padding:5px;
		}
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
			width:164px;
			<%if session("companyId")=17 then%>
				height:470px;
			<%else%>
				height:470px;
			<%end if%>
			background-color:#ccc;
			position:absolute;
			border-right:5px ridge #7dcf2c;
		}
		#treeMove{
			width:200px;
			height:400px;
			background-color:#ccc;
		}
		#treeBulkMove{
			width:200px;
			height:250px;
			background-color:#ccc;
		}
		#treeSample{
			width:480px;
			height:290px;
			background-color:#ccc;
		}
		#treeAdd{
			width:200px;
			height:200px;
			background-color:#ccc;
		}
		.popupDiv{
			background-color:white;
			border:0px solid black;
			border-top:20px solid black;
			position:absolute;
			<%if inFrame then%>
			left:250px;
			top:40px;
			<%else%>
			left:400px;
			top:-120px;
			<%end if%>
			z-index: 100001;
			padding:20px;
		}
		.popupDiv#samplePopup {
			<%if inFrame then%>
			left:  250px;
			<%end if%>
		}
		.popupDiv input,select{
			display:block;
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
		.ax1-itemGrid .odd{
			background-color:#4c4;
		}
		.ax1-itemGrid .even{
			background-color:white;
		}
		.ax1-itemGrid a{
			text-decoration:none;
			color:black;
			font-weight:bold;
			font-size:11px;
		}
		.ax1-itemGrid td{
			width:50px;
			text-align:center;
		}
		.calendar {
			z-index: 100002; /* This doesn't display on a popup form because the z-indexes are hard coded, so we're going to ensure this bubbles to the top. */
		}
	</style>

<script type="text/javascript">
	if (companyId!=17){
		h = 530;
	}
	if(hasReceiving){
		h-=30;
	}
	if(hasFireControl){
		h-=30;
	}
	if(canUpdate){
		h-=30;
	}
	document.getElementById("tree").style.height = h+"px";
</script>

<td style="width:835px;background-color:#eee;padding:15px 0px 15px 15px;" valign="top">
<div id="contentDiv">

<script type="text/javascript">
	function goProgress(pl,cb){
		restCallA("/getProgress/","POST",pl,function(r){
			drawProgress(r,cb);
		})
	}
	function drawProgress(r,cb){ 
		percentComplete = r["percentComplete"];
		if(percentComplete.toString().length>6){
			percentComplete = percentComplete.toString().replace("%","");
			percentComplete = parseFloat(percentComplete).toFixed(2);
		}
		percentComplete = percentComplete;
		status = r["status"]
		totalRecords = r["totalRecords"];
		recordsImported = r["recordsImported"];
		recordsProcessed = r["recordsProcessed"];
		errors = r["errors"];
		document.getElementById("progressBar").style.width = percentComplete*3+"px";
		document.getElementById("percentCompleteTD").innerHTML = percentComplete + "%";
		document.getElementById("statusTD").innerHTML = status;
		if (recordsProcessed == 0 && totalRecords ==0){
			document.getElementById("recordsProcessedTD").innerHTML = "wait";
		}else{
			document.getElementById("recordsProcessedTD").innerHTML = recordsProcessed +"/"+totalRecords;
		}
		document.getElementById("recordsImportedTD").innerHTML = recordsImported+"/"+totalRecords;
		document.getElementById("errorsTD").innerHTML = errors;
		if (percentComplete == 100){
			document.getElementById("loadingImg").src = '<%=mainAppPath%>/images/reg-import-loading-done.gif'
			window.setTimeout(function(){
				clearContainer("arxOneContainer");
				cb();
				window.clearInterval(progressInterval);
				pl = {"action":"view","collection":r["link"]["collection"],"id":r["link"]["id"]};
				objectForm = restCall("/getForm/","POST",pl);
				makeForm(objectForm,"arxOneContainer");
				hideProgressBox();
			},1000)
			percentComplete = 199;
		}
	}

	function clearProgressBox(){
		document.getElementById("progressBar").style.width = "0px";
		document.getElementById("percentCompleteTD").innerHTML = "";
		document.getElementById("statusTD").innerHTML = "";
		document.getElementById("recordsProcessedTD").innerHTML = "";
		document.getElementById("recordsImportedTD").innerHTML = "";
		document.getElementById("errorsTD").innerHTML = "";
	}
	var progressInverval
	function showProgressBox(pl){
		clearProgressBox();
		blackOn();
		window.scroll(0,0);
		document.getElementById('progressBox').style.display='block';
		progressInterval = window.setInterval((function(pl){return function(){goProgress(pl,cb)}})(pl,cb),500);
	}
	function hideProgressBox(){
		window.clearInterval(progressInterval);
		clearProgressBox();
		blackOff();
		document.getElementById('progressBox').style.display='none';
	}

</script>

<div id="progressBox" style="border:10px solid black;padding:10px;width:400px;display:none;visibility:visible;" class="popupDiv">
<a class="popupCloseLink" href="javascript:void(0);" onclick="document.getElementById('progressBox').style.display='none';blackOff();"><img class="popupCloseImg" src="images/close-x.gif"/></a>
<table style="width:100%">
<tr>
<td align="center">
<table>
<tr style="height:200px;">
<td colspan="2" align="center">
<img border="0" style="border:none;" src="<%=mainAppPath%>/images/reg-import-loading.gif" id="loadingImg">
</td>
</tr>
<tr>
<td colspan="2">
<div id="progressHolder" style="width:300px;border:1px solid black;padding:2px;">
<div id="progressBar" style="background-color:black;height:20px;">
</div>
</div>
</td>
</tr>
<tr>
<td>
Status
</td>
<td id="statusTD">

</td>
</tr>
<tr>
<td>
Percent Complete
</td>
<td id="percentCompleteTD">

</td>
</tr>
<tr>
<td>
Records Processed
</td>
<td id="recordsProcessedTD">

</td>
</tr>
<tr>
<td>
Records Imported
</td>
<td id="recordsImportedTD">

</td>
</tr>
<tr>
<td>
Errors
</td>
<td id="errorsTD">

</td>
</tr>
</table>
</td>
</tr>
</table>
</div>
</div>
