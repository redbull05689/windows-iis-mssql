<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%'412015%>
<%
regDefaultGroupId = getCompanySpecificSingleAppConfigSetting("defaultRegGroupId", session("companyId"))

If CStr(regDefaultGroupId) = "" Then
	groupId = "0"
Else
	groupId = regDefaultGroupId
End if%>
<%'/412015%>
<input type="hidden" name="requestRevisionId" id="requestRevisionId" value="<%=requestRevisionId%>">
<form action="<%=mainAppPath%>/experiments/cust-saveExperiment.asp" method="post" id="experimentForm" onsubmit="return false;">
	<input type="hidden" name="hungSaveSerial" value="<%=hungSaveSerial%>">
  <table cellpadding="0" cellspacing="0" style="width:100%;">
	<tr>
		<td colspan="2">
			<table class="caseTable expHeader" style="table-layout:fixed;height:34px; padding-left: 8px; vertical-align: center; width:100%; border:none;">
                <tr>
                    <td style="width:30%">
                        <div id="experimentTopLeftNavContainer" class="headerNavLinks" style="font-size:80%; font-weight: bold; padding-left: 8px;"></div>
                    </td>
                    <td style="width:70%">
                        <div id="topRightFunctionsAsp" display="block;" style="height:30px;"></div>
                    </td>
                </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" style="background-color:transparent;padding-bottom:none!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2>Experiment Details</h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr class="caseInnerTitle expBoxText" >
						<td style="width:30%;height:24px; font-weight: bold; padding-top: 4px; padding-right:10px; padding-left: 8px;">
							Experiment Number:  <%=experimentName%>
							<input type="hidden" name="e_name" id="e_name" value="<%=draftSet("e_name",experimentName)%>">
						</td>
						<%If session("canChangeExperimentNames") then%>
							<td  style="width:15%;">
								<span style="float:right;">Title:<span class="requiredExperimentFieldNotice" data-fieldname="e_userAddedName">*</span></span>
							</td>
							<td  style="width:55%;">
								<% If currentRevisionNumber = maxRevisionNumber and ownsExp and isDraftAuthor then %>	
								<input type="text" style="width:97%;margin-left:5px;" name="e_userAddedName" id="e_userAddedName" value="<%=draftSet("e_userAddedName",userExperimentName)%>">
								<% Else %>
									<span style="width:97%;padding-left:8px;" name="e_userAddedName" id="e_userAddedName"><%=draftSet("e_userAddedName",userExperimentName)%></span>
								<% End If %>
							</td>
						<%End If%>
					</tr>
				</table>
			</div>
		</td>
	</tr>

	<tr>
		<td align="left" style="background-color:transparent;padding-bottom:none!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2>Objective<span class="requiredExperimentFieldNotice" data-fieldname="e_details">*</span></h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<%If currentRevisionNumber = maxRevisionNumber and ownsExp and isDraftAuthor then%>
							<td class="caseInnerTitle expBoxText" valign="top">
								<textarea name="e_details" id="e_details" style="height:48px;width:99%;margin:0;"><%=draftSet("e_details",experimentDetails)%></textarea>
							</td>
						<%else%>
							<td class="caseInnerTitle expBoxText multiLineSpacing" valign="top">
								<%=Replace(experimentDetails,vbcrlf,"<br/>")%>
							</td>
						<%End if%>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	
	<tr id="requestFields">
		<input type="hidden" name="requestFieldIds" id="requestFieldIds" value="">
		<%
			' This block here populates the JS experimentJSON object with requestField values so
			' Workflow requests in the ELN can have draft saves.
			expJsonKeys = experimentJSON.keys()

			' Make an array of keys that /aren't/ requestFieldIds. This is hardcoded because
			' I couldn't think of a better way of doing this.
			Set elnKeys = JSON.parse("{}")
			elnKeys.set "e_details", 1
			elnKeys.set "e_name", 1
			elnKeys.set "e_userAddedName", 1
			elnKeys.set "hungSaveSerial", 1
			
			' Iterate through all of the json keys and make a hidden input object with the name and id
			' set to the key and the value set to draftSet(key, val). Then add the key to the
			' requestFieldIds input value.
			for i=0 to ubound(expJsonKeys)
				key = expJsonKeys(i)
				val = experimentJSON.Get(key)				
				if not elnKeys.exists(key) then
					draftSetValue = Replace(draftSet(key, val), """", "&quot;")
					%>
						<input type="hidden" name="<%=key%>" id="<%=key%>" value="<%=draftSetValue%>">

						<script>
							if ($("#requestFieldIds").val() == "") {
								$("#requestFieldIds").val($("#requestFieldIds").val() + "<%=key%>");
							} else {
								$("#requestFieldIds").val($("#requestFieldIds").val() + ",<%=key%>");
							}
						</script>
					<%
				end if
			next
		%>
	</tr>
	<tr <%If experimentId = "" then%>style="display:none;"<%End if%> id="sectionRow">
		<td>
			<div class="tabs expTabs"><ul id="sectionTabs"><li><a href="javascript:void(0);" onClick="showMainDiv('experimentDiv');return false;" id="experimentDiv_tab" class="tabSelected selectedTab"><%=experimentLabel%></a></li>
			<li><a href="javascript:void(0);" onClick="showMainDiv('attachmentTable');return false;" id="attachmentTable_tab" style="<%if Not hasAttachments then%>display:none;<%End if%>"><%=attachmentsTableLabel%></a></li>
			<li><a href="javascript:void(0);" onClick="showMainDiv('noteTable');return false;" id="noteTable_tab" style="<%If Not hasNotes then%>display:none;<%End if%>"><%=notesTableLabel%></a></li>
			<%If currentRevisionNumber = maxRevisionNumber And ownsExp and isDraftAuthor then%>
			<%If session("useResumableFileUploader") = true then%>
				<li><a href="javascript:void(0);" onClick="showPopup('addResumableFileDiv');return false;" id="addFile_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addFileButton"><%=addFileLabel%></span></a></li>
			<%else%>
				<li><a href="javascript:void(0);" onClick="showPopup('addFileDiv');return false;" id="addFile_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addFileButton"><%=addFileLabel%></span></a></li>
			<%end if%>
			<li><a href="javascript:void(0);" onClick="newNote();return false;" id="addNote_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addNoteButton"><%=addNoteLabel%></span></a> </li>
			<%If bCheck <> "IE 8.0" then%>
			<li><a href="javascript:void(0);" onClick="newSketch();return false;" id="addSketch_tab" <%If experimentId = "" then%>style="display:none;width:100px;"<%else%>style="width:100px;"<%End if%>> <span class="plus">+</span> <span id="addSketchButton"><%=addSketchLabel%></span></a> </li>
			<%End if%>
			<%End if%>
			</ul><div style="height:0px;clear:both;"></div></div>
		</td>
	</tr>
	</table>
<div id="experimentDiv" style="margin-top: -6px;">
<%
	If requestTypeId <> "" and (isNull(requestId) or requestId = 0)Then
		iframeUrl = mainAppPath & "/workflow/makeNewRequestExp.asp?r=" & requestTypeId & "&inFrame=true"
	Else
		iframeUrl = mainAppPath & "/workflow/viewIndividualRequest.asp?base=false&inFrame=true&requestid=" & requestId & "&r=" & requestTypeId

		if revisionId = "" then
			if CStr(currentRevisionNumber) = 1 then
				iframeUrl = replace(iframeUrl, "viewIndividualRequest", "repeatRequest")
			end if
		end if

		if revisionId <> "" and CStr(currentRevisionNumber) <> CStr(maxRevisionNumber) then
			iframeUrl = iframeUrl & "&revisionId=" & requestRevisionNumber
		end if
	End If
	iframeUrl = iframeUrl & "&currentPageMode=custExp"
%>
<iframe id="tocIframe" class="custExpFrame elnDashObj" src='<%=iframeUrl%>'></iframe>
  <table cellpadding="0" cellspacing="0" style="width:100%;<%If experimentId= "" then%>display:none;<%End if%>" id="experimentDiv">
	<tr>
		<td colspan="2">
			<div class="buttonHolder" style="float:right;" id="makeNextStepButton"><a href="javascript:void(0);" onclick="showPopup('newExperimentNextStepDiv')" class="createLink"  ><%=addNextStepLabel%></a></div>
		</td>
	</tr>
	<tr>
		<td style="height:2px;">
			&nbsp;
			<input type="hidden" name="requestId" id="requestId" value="<%=requestId%>">
			<input type="hidden" name="requestTypeId" id="requestTypeId" value="<%=requestTypeId%>">
			<input type="hidden" name="notebookId" id="notebookId" value="<%=notebookId%>">
			<input type="hidden" name="attachments" id="attachments" value="">
			<input type="hidden" name="approve" id="approve" value="">
			<input type="hidden" name="experimentId" id="experimentId" value="<%=experimentId%>">
			<input type="hidden" name="experimentType" id="experimentType" value="<%=experimentType%>">
			<input type="hidden" name="notebookIdCopy" id="notebookIdCopy" value="">
			<input type="hidden" name="thisRevisionNumber" id="thisRevisionNumber" value="<%=maxRevisionNumber%>">
		</td>
	</tr>

	<%If session("hasInv") Then%>
	<tr>
		<td align="left" style="background-color:black;padding-bottom:0!important;" valign="top" colspan="2">

			<%If currentRevisionNumber = maxRevisionNumber And ownsExp and isDraftAuthor then%>
				<a href="javascript:void(0)" onClick="showPopup('inventoryLinkSelectorDiv');" id="inventoryLinkLink" title="New Inventory Link"><img border="0" src="images/Add.gif" class="png" style="position:absolute;right:5px;"></a>
				<%If session("hasBarcodeChooser") then%>
					<a href="javascript:void(0)" onClick="showMultiAddInventoryPopup();return false;" id="inventoryLinkLink" title="Inventory Barcode Chooser"><img border="0" src="images/barcode.gif" class="png" height="16" width="20" style="margin-top:6px;position:absolute;right:44px;"></a>
				<%End if%>
			<%End if%>
			<div class="tabs"><h2>Inventory Items</h2></div>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<table class="caseTable" cellpadding="0" cellspacing="0" style="width:100%;">
				<tr>
					<td class="caseInnerTitle" valign="top" id="inventoryLinksTD">
						<%
						strQuery = "SELECT inventoryId, name, amount FROM inventoryLinks WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
						Set lRec = server.CreateObject("ADODB.RecordSet")
						lRec.open strQuery,conn
						Do While Not lRec.eof
							%>
								<a href="<%=mainAppPath%>/inventory2/index.asp?id=<%=lRec("inventoryId")%>"><%=lRec("name")%>&nbsp;<%=lRec("amount")%></a><br/>
							<%
							lRec.moveNext
						loop
						%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%End If%>
	
	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2" class="experimentSection_experimentLinks_header">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2><div class="experimentLinksSectionHeader"><%=experimentLinksLabel%></div><div class="experimentLinkMapButtonContainer"><a href="javascript:void(0)" title="View Experiment Link Map" id="showExperimentLinkMapButton" class="showExperimentLinkMapButton">View Experiment Link Map</a></div></h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<td class="caseInnerTitle expBoxText" valign="top" id="linksTD">
							<% ' Removed for ELN-933 %>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			
		</td>
	</tr>
	<%''412015%>
	<%If session("registerFromBio") Or session("companyId")="1" then%>
	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">			
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2>Registration Links</h2></div>						
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<td class="caseInnerTitle expBoxText" valign="top" id="regLinksTD">
							<% ' Removed for ELN-933 %>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<%End if%>
	<%''/412015%>
	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2><%=projectLinksLabel%></h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<td class="caseInnerTitle expBoxText" valign="top" id="projectLinksTD">
							<% ' Removed for ELN-933 %>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>

	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
		<div class="elnObjectContainer elnDashObj">
			<div class="tabs elnHead"><h2>Request Links</h2></div>
			<table cellpadding="0" cellspacing="0" style="width:100%;">
				<tr>
					<td class="caseInnerTitle expBoxText" valign="top" id="reqLinksTD">
						
					</td>
				</tr>
			</table>
		</div>
		</td>
	</tr>

  </table>

</div>

<div style="display:none;" id="attachmentTable" class="addExpTable">
<!-- #include file="../../../attachments/html/resumableFileUploader.asp"-->
<div id="attachmentTableList">
<script>
$( document ).ready(function() {
	$.ajax({
		url: "<%=mainAppPath%>/_inclds/attachments/html/showAttachmentTableWrapper.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionId=<%=revisionId%>",
		type: "GET",
		async: true,
		cache: false,
		dataType: "html"
	})
	.success(function(r) {
		$("#attachmentTableList").html(r);
	})
	.fail(function() {
		alert("Unable to load attachments table. Please contact support@arxspan.com.");
	});
});
</script>
</div>
</div>

<div style="display:none;" id="noteTable" class="experimentNotesTable">
<script>
$( document ).ready(function() {
	$.ajax({
		url: "<%=mainAppPath%>/_inclds/notes/html/showNoteTable.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionId=<%=revisionId%>",
		type: "GET",
		async: true,
		cache: false,
		dataType: "html"
	})
	.success(function(r) {
		$("#noteTable").html(r);
	})
	.fail(function() {
		alert("Unable to load notes table. Please contact support@arxspan.com.");
	});
});
</script>
</div>

<%'this submit button is added bc for IE .submit can not be called in frame bc I think there is a naming conflict with fck%>
<input type="submit" id="subTest" value = "hello" style="height:1px;width:1px;visibility:hidden;">
</form>

<form name="addLinkForm" id="addLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/newExperimentLink.asp" target="submitFrame2">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>

<%'412015%>
<form name="addBioLinkForm" id="addBioLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/newExperimentLink.asp" target="submitFrame2">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>
<%'//412015%>

<form name="deleteLinkForm" id="deleteLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/deleteExperimentLink.asp" target="submitFrame2">
<input type="hidden" name="delLinkType" id="delLinkType" value="">
<input type="hidden" name="delLinkId" id="delLinkId" value="">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>

<%'412015%>
<form name="deleteRegLinkForm" id="deleteRegLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/deleteExperimentRegLink.asp" target="submitFrame2">
<input type="hidden" name="delRegNumber" id="delRegNumber" value="">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>
<%'//412015%>

<form name="deleteRequestLinkForm" id="deleteRequestLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/deleteExperimentRequestLink.asp" target="submitFrame2">
<input type="hidden" name="delRequestId" id="delRequestId" value="">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>

<%'412015%>
<script type="text/javascript">
// Load notebook nav links
$.ajax({
	url: '/arxlab/_inclds/experiments/common/html/experimentTopLeftNav.asp?notebookId=<%=notebookId%>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>',
	type: 'GET',
	async: true
})
.done(function(response) {
	$('#experimentTopLeftNavContainer').html(response);
})
.fail(function(jqXHR, textStatus, errorThrown) {
	console.log("experimentTopLeftNav error: ", errorThrown);
})
.always(function() {
	console.log("experimentTopLeftNav error ran");
});

	<% if session("useResumableFileUploader") = true then %>
		addResumableJSUploader();
	<% end if %>
</script>
<!-- #include file="../../../../java/javaProgrammersApplet.asp"-->
<%'/412015%>


<div class="modal fade in" id="basicLoadingModal" role="dialog" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog">
      	<!-- Modal content-->
      	<div class="modal-content card">
	        <div class="modal-body">
		        <div class="loadingText">Loading form data</div>
	        </div>
		</div>
	</div>
</div>