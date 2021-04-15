<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
	accordServicePath = getCompanySpecificSingleAppConfigSetting("accordServiceEndpointUrl", session("companyId"))
%>

<%'412015%>
<%

regDefaultGroupId = getCompanySpecificSingleAppConfigSetting("defaultRegGroupId", session("companyId"))

If CStr(regDefaultGroupId) = "" Then
	groupId = "0"
Else
	groupId = regDefaultGroupId
End if%>
<form target="regFrame" id="regForm" method="POST" action="<%=regPath%>/addStructure.asp?sourceId=2&inFrame=true&isBio=1&groupId=<%=groupId%>">
	<input type="hidden" name="experimentId" value="<%=experimentId%>">
	<input type="hidden" name="experimentType" value="<%=experimentType%>">
	<input type="hidden" name="revisionNumber" value="<%=maxRevisionNumber%>">
	<input type="hidden" name="regExperimentName" id="regExperimentName" value="">
	<input type="hidden" name="regNotebookId" id="regNotebookId" value="<%=notebookId%>">
	<input type="hidden" name="regNotebookName" id="regNotebookName" value="<%=notebookName%>">
</form>
<%'/412015%>
<form action="<%=mainAppPath%>/experiments/anal-saveExperiment.asp" method="post" id="experimentForm" onsubmit="return false;">
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
				<table cellpadding="0" cellspacing="0" style="table-layout:fixed;width:100%;">
					<tr class="caseInnerTitle expBoxText" >
						<td style="width:30%;height:24px; font-weight: bold; padding-top: 4px; padding-left: 8px; padding-right:10px; border-bottom-left-radius: 3px;">
							Notebook Page:  <%=experimentName%>
							<input type="hidden" name="e_name" id="e_name" value="<%=draftSet("e_name",experimentName)%>">
						</td>
						<%If session("canChangeExperimentNames") then%>
							<td  style="width:15%;">
								<span style="float:right;"><%=experimentNameLabel%>:</span>
							</td>
							<td  style="width:55%; border-bottom-right-radius: 3px;">
								<% If revisionId = "" and canWrite And ownsExp then %>	
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
				<div class="tabs elnHead"><h2><%=experimentDescriptionLabel%><span class="requiredExperimentFieldNotice" data-fieldname="e_details">*</span></h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<%If revisionId = "" and canWrite And ownsExp then%>
							<td class="caseInnerTitle expBoxText" valign="top">
								<textarea name="e_details" id="e_details" style="resize:vertical;height:48px;width:99%;margin:0;"><%=draftSet("e_details",experimentDetails)%></textarea>
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
	<tr <%If experimentId = "" then%>style="display:none;"<%End if%> id="sectionRow">
		<td>
			<div class="tabs expTabs"><ul id="sectionTabs"><li><a href="javascript:void(0);" onClick="showMainDiv('experimentDiv');return false;" id="experimentDiv_tab" class="tabSelected selectedTab"><%=experimentLabel%></a></li>
			<li><a href="javascript:void(0);" onClick="showMainDiv('attachmentTable');return false;" id="attachmentTable_tab" style="<%if Not hasAttachments then%>display:none;<%End if%>"><%=attachmentsTableLabel%></a></li>
			<li><a href="javascript:void(0);" onClick="showMainDiv('noteTable');return false;" id="noteTable_tab" style="<%If Not hasNotes then%>display:none;<%End if%>"><%=notesTableLabel%></a></li>
			<li><a href="javascript:void(0);" onClick="showMainDiv('elementalMachinesTable');return false;" id="elementalMachinesTable_tab" style="<%If Not hasEMData then%>display:none;<%End if%>color:black;">EM Data</a></li>
			<%If revisionId = "" And canWrite And ownsExp then%>
			<%If session("useResumableFileUploader") = true then%>
				<li><a href="javascript:void(0);" onClick="showPopup('addResumableFileDiv');return false;" id="addFile_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addFileButton"><%=addFileLabel%></span></a></li>
			<%else%>
				<li><a href="javascript:void(0);" onClick="showPopup('addFileDiv');return false;" id="addFile_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addFileButton"><%=addFileLabel%></span></a></li>
			<%end if%>
			<li><a href="javascript:void(0);" onClick="newNote();return false;" id="addNote_tab" <%If experimentId = "" then%>style="display:none;"<%End if%>> <span class="plus">+</span> <span id="addNoteButton"><%=addNoteLabel%></span></a> </li>
			<%If session("hasElementalMachines") Then%>
			<li><a href="javascript:void(0);" onClick="newElementalMachinesData();return false;" id="addElementalMachinesData_tab" <%If experimentId = "" then%>style="display:none;"<%else%>style="width:100px;"<%End if%>> <span class="plus">+</span> <span id="addElementalMachinesDataButton">Add EM Data</span></a></li>
			<%Else%>
			<%If bCheck <> "IE 8.0" then%>
			<li><a href="javascript:void(0);" onClick="newSketch();return false;" id="addSketch_tab" <%If experimentId = "" then%>style="display:none;width:100px;"<%else%>style="width:100px;"<%End if%>> <span class="plus">+</span> <span id="addSketchButton"><%=addSketchLabel%></span></a> </li>
			<%End if%>
			<%End If%>
			<%End If%>
			</ul><div style="height:0px;clear:both;"></div></div>
		</td>
	</tr>
	</table>
<div id="experimentDiv">
  <table cellpadding="0" cellspacing="0" style="table-layout:fixed;width:100%;<%If experimentId= "" then%>display:none;<%End if%>">
	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2><%=objectiveLabel%></h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<td class="caseInnerTitle expBoxText" valign="top">
							<%If revisionId = "" and canWrite And ownsExp then%>
								<textarea style="width:830px;height:300px;" name="e_protocol" id="e_protocol"><%=htmlspecialchars(draftSet("e_protocol",protocol))%></textarea>
								<script type="text/javascript">
									CKEDITOR.replace('e_protocol',{allowedContent:true,toolbar : 'arxspanToolbarPrepTemplatesBioProtocol',extraPlugins:'arx_onchange,arx_autoText,arx_bioProtocolTemplates,ajax,arx_timeStampButton'});
									CKEDITOR.instances.e_protocol.on('change',ckChange)
									CKEDITOR.instances['e_protocol'].on('resize',function(ev) { positionButtons(); updateCkEditorSize('analform_e_protocol_height','e_protocol');})
									CKEDITOR.instances['e_protocol'].on('contentDom', function(ev){ev.editor.document.on( 'paste', function(e){pasteHandler(e.data.$,'e_protocol');});});
									CKEDITOR.instances['e_protocol'].on('instanceReady', function(ev) { positionButtons(); });
									if(userOptions['analform_e_protocol_height']){
										CKEDITOR.instances['e_protocol'].config.height = userOptions['analform_e_protocol_height'];
									}
									$(function(){
										//Force reload the data after the page is loaded for a weird bug in firefox
										CKEDITOR.instances['e_protocol'].setData($('#e_protocol').val());
									});
								</script>
							<%else%>
								<%="<p>"&Replace(protocol,vbcrlf,"</p><p>")&"</p>"%>
							<%End if%>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>

	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
				<div class="tabs elnHead"><h2><%=summaryLabel%></h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<td class="caseInnerTitle expBoxText" valign="top">
							<%If revisionId = "" and canWrite And ownsExp then%>
								<textarea style="width:830px;height:80px;" name="e_summary" id="e_summary"><%=htmlspecialchars(draftSet("e_summary",summary))%></textarea>
								<script type="text/javascript">
									CKEDITOR.replace('e_summary',{allowedContent:true,toolbar : 'arxspanToolbarPrepTemplatesBioSummary',extraPlugins:'arx_onchange,arx_autoText,arx_bioSummaryTemplates,ajax,arx_timeStampButton'});
									CKEDITOR.instances.e_summary.on('change',ckChange)
									CKEDITOR.instances['e_summary'].on('resize',function(){positionButtons();updateCkEditorSize('analform_e_summary_height','e_summary');})
									CKEDITOR.instances['e_summary'].on('contentDom', function(ev){ev.editor.document.on( 'paste', function(e){pasteHandler(e.data.$,'e_summary');});});
									CKEDITOR.instances['e_summary'].on('instanceReady', function(ev) { positionButtons(); });
									if(userOptions['analform_e_summary_height']){
										CKEDITOR.instances['e_summary'].config.height = userOptions['analform_e_summary_height'];				
									}
									$(function(){
										//Force reload the data after the page is loaded for a weird bug in firefox
										CKEDITOR.instances['e_summary'].setData($('#e_summary').val());
									});
								</script>
							<%else%>
								<%=summary%>
							<%End if%>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>

	<tr>
		<td colspan="2">
			<div class="buttonHolder" style="float:right;" id="makeNextStepButton"><a href="javascript:void(0);" onclick="showPopup('newExperimentNextStepDiv')" class="createLink"  ><%=addNextStepLabel%></a></div>
		</td>
	</tr>
	<tr>
		<td style="height:2px;">
			&nbsp;
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
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
					
			<div class="elnObjectContainer elnDashObj">			
				<div class="invButtons">
					<%If revisionId = "" And ownsExp then%>
						<a href="javascript:void(0)" onClick="showPopup('inventoryLinkSelectorDiv');" id="inventoryLinkLink" title="New Inventory Link"><img border="0" src="images/Add.gif" class="png" style="position:absolute;right:25px;"></a>
						<%If session("hasBarcodeChooser") then%>
							<a href="javascript:void(0)" onClick="showMultiAddInventoryPopup();return false;" id="inventoryLinkLink" title="Inventory Barcode Chooser"><img border="0" src="images/barcode.gif" class="png" height="16" width="20" style="margin-top:6px;position:absolute;right:64px;"></a>
						<%End if%>
					<%End if%>	
				</div>
				<div class="tabs elnHead"><h2>Inventory Items</h2></div>
				<table cellpadding="0" cellspacing="0" style="width:100%;">
					<tr>
						<td class="caseInnerTitle expBoxText" valign="top" id="inventoryLinksTD">
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
			</div>
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
	
	<%''412015%>
	<%If session("registerFromBio") Or session("companyId")="1" then%>
	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
			<div class="elnObjectContainer elnDashObj">
			<div class="invButtons">
				<%If session("hasReg") And Not IsNull(session("regRoleNumber")) And Not session("hasAccordInt") And accordServicePath="" then%>
					<a id="regLinkLink" href="javascript:void(0);" onclick="isIntReg=false;document.getElementById('regExperimentName').value=document.getElementById('e_name').value;document.getElementById('regForm').submit();showPopup('regDiv');return false;"><img border="0" src="images/Add.gif" class="png" style="position:absolute;right:64px;"></a>
					<script>
					function getRegLinks(){
						loadExperimentLinks("registration");
					}
					</script>
				<%End If%> 
				<a href="javascript:void(0)" onclick="toggleRegLinkTable();return false;" id="regLinkToggle" title="Show/Hide Link Table"><img id="toggleRegLinkImg" src="images/triangle_down_1x.png" class="png" style="position:absolute;right:25px;" border="0"></a>
			</div>
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

<div style="display:none;" id="attachmentTable" class="addExpTable experimentAttachmentTable">
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

<div style="display:none;" id="noteTable" class="addExpTable experimentNotesTable">
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

<div style="display:none;" id="elementalMachinesTable">
<!-- #include file="../../../elementalMachines/html/showElementalMachinesTable.asp"-->
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

<form name="deleteRequestLinkForm" id="deleteRequestLinkForm" method="POST" action="<%=mainAppPath%>/experiments/ajax/do/deleteExperimentRequestLink.asp" target="submitFrame2">
<input type="hidden" name="delRequestId" id="delRequestId" value="">
<input type="hidden" name="lExperimentType" value="<%=experimentType%>">
<input type="hidden" name="lExperimentId" value="<%=request.querystring("id")%>">
</form>

<%'//412015%>
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

<%If session("hasElementalMachines") Then%>
	checkEMCredentials(false);
<%End if%>

	<% if session("useResumableFileUploader") = true then %>
		addResumableJSUploader();
	<% end if %>
</script>
<!-- #include file="../../../../java/javaProgrammersApplet.asp"-->
<%'/412015%>