<!-- #include virtual="/_inclds/sessionInit.asp" -->

	<%if session("noChemDraw") then
	session("lastPage") = "https://"&request.servervariables("SERVER_NAME")&mainAppPath&"/experiment.asp?"&request.servervariables("QUERY_STRING")
		if Not session("useMarvin") then
			response.redirect(Replace(session("lastPage"),"experiment.asp","arxlab/experiment_no_chemdraw.asp"))
		end if 

	end if%>

<%startTime = timer%>
<%
sectionId = "experiment"
experimentType = "1"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/experiments/common/asp/experimentInitVars.asp"-->
<!-- #include file="_inclds/common/asp/uploadInit.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
	hasCombi = checkBoolSettingForCompany("hasCombi", session("companyId"))
	hasCombiPlate = checkBoolSettingForCompany("hasCombiPlate", session("companyId"))
	sectionID = "tool"
	subSectionID="experiment"
	terSectionID=""
	metaD=""
	metaKey=""
%>


<!-- #include file="_inclds/experiments/chem/asp/chemGetExperimentVars.asp"-->
<!-- #include file="_inclds/experiments/common/asp/getExperimentPermissions.asp"-->
<%
If session("hasCompoundTracking") Or session("hasInventoryIntegration") Then
	If revisionId = "" Then
		currLetter = draftSet("currLetter",expRec("currLetter"))
	End if
End If
If hasCombi and hasCombiPlate Then
	resultSD = draftSet("resultSD",expRec("resultSD"))
	If IsNull(resultSD) Then
		resultSD = ""
	End If
End if
If (session("hasInventoryIntegration") Or session("hasCompoundTracking") Or session("hasBarcodeChooser")) And revisionId="" And ownsExp then
	If experimentJSON.exists("cdxml") then
		cdxData = experimentJSON.Get("cdxml")
		cdxData = Replace(cdxData,"""","&quot;")
	End if
	If experimentJSON.exists("mrvData") then
		mrvData = experimentJSON.Get("mrvData")
		mrvData = Replace(mrvData,"""","&quot;")
	End if
End if

If revisionId = "" then
	sigdigs = draftSet("sigdig",expRec("sigdigs"))
End if

If experimentDetails <> "" Then
	pageTitle = experimentDetails
else
	pageTitle = experimentName
End if
%>
<!-- #include file="_inclds/header-tool.asp"-->
<!-- #include file="_inclds/common/html/popupDivs.asp"-->
<!-- #include file="_inclds/nav_tool.asp"-->
<!-- #include file="_inclds/experiments/common/html/deleteExperimentForm.asp"-->

<script type="text/javascript" src="js/common/experiments/commonFunctions.js?<%=jsRev%>"></script>
<script>
	var experimentStatusId = <%= statusId %>;
	var experimentType = <%=experimentType%>;
	var experimentId = <%=experimentId%>;
</script>

<%hasInviteRead = hasNotebookInviteRead(notebookId,session("userId"))%>
<%If (canViewExperiment("1",experimentId,session("userId")) Or canRead Or hasInviteRead) And notebookVisible And experimentVisible then%>
<!-- #include file="experiments/fileUploadForm.asp"-->
<!-- #include file="_inclds/common/html/infoBox.asp"-->
<script type="text/javascript">
	hasMarvin = <%=LCase(CStr(session("useMarvin")))%>;
</script>
<!-- #include file="_inclds/experiments/chem/js/chemJSIncludes.asp"-->
<!-- #include file="_inclds/experiments/chem/js/chemJS_no_chemdraw.asp"-->
<!-- #include file="_inclds/experiments/common/asp/unsavedChanges.asp"-->

<!-- #include file="_inclds/experiments/chem/html/chemForm.asp"-->
<div id="bottomButtons">
<!-- #include file="_inclds/experiments/common/buttons/html/experimentBottomButtons.asp"-->
</div>
<%If request.querystring("id")<>"" then%>
<script type="text/javascript">
addLoadEvent(function(){waitPopulate();})
</script>
<%end if%>
<!-- #include file="_inclds/common/html/submitFrame.asp"-->
<%If request.querystring("id") = "" then%>
<script type="text/javascript">
	notebookChange();
</script>
<%End if%>
<!-- #include file="_inclds/experiments/common/js/experimentBounceToTab.asp"-->

<script language="VBscript">
'MsgBox("Exportable types are: ")
'Set mycdx = Document.getElementById("mycdx")
'For Each dt In mycdx.ExportDataTypes
'	MsgBox(dt.MIME&" "&dt.Extension)
'Next
</script>
<%trash = addToRecentlyViewed(experimentId,experimentType)%>

<%else%>
	<%If Not notebookVisible Or Not experimentVisible then%>
		<%'<p>You are not authorized to view this experiment</p>%>
	<%else%>
		<%'<p>This experiment has been deleted</p>%>
	<%End if%>
<%End if%>

<script type="text/javascript">
function findPos(obj) {
    var curleft = curtop = 0;
    if (obj.offsetParent) {
    do {
    		curleft += obj.offsetLeft;
    		curtop += obj.offsetTop;
    } while (obj = obj.offsetParent);
    return [curleft,curtop];
    }
}
<%
if request.querystring("attachmentId") <> "" then
%>
	toggleAttachment('file_<%=request.querystring("attachmentId")%>');
	try{addEvent(window,'load',function(){window.scrollTo(0,findPos(document.getElementById('file_<%=request.querystring("attachmentId")%>_td'))[1]-100)})}catch(err){}
<%
end if
%>
<%
if request.querystring("noteId") <> "" then
%>
	toggleNote('note_<%=request.querystring("noteId")%>')
	try{addEvent(window,'load',function(){window.scrollTo(0,findPos(document.getElementById('note_<%=request.querystring("noteId")%>_td'))[1]-100)})}catch(err){}
<%
end if
%>
<%
if draftHasUnsavedChanges then
%>
	addEvent(window,'load',function(){unsavedChanges=true;showOverMessage("unsavedChanges","page")})
<%
end if
%>
</script>
<iframe id="upload_frame" name="upload_frame" style="visibility:hidden;height:2px;width:2px;" src="javascript:false;"></iframe>
<form id="echoForm" method="post" action="<%=mainAppPath%>/experiments/echo.asp?experimentId=<%=experimentId%>&experimentType=1&fromChemDraw=yes">
<input type="hidden" value="" name="chemdata" id="echoChemData">
</form>

<form target="regFrame" id="regForm" method="POST" action="<%=regPath%>/addStructure.asp?sourceId=2&inFrame=true">
	<input type="hidden" name="experimentId" value="<%=experimentId%>">
	<input type="hidden" name="experimentType" value="1">
	<input type="hidden" name="revisionNumber" value="<%=maxRevisionNumber%>">
	<input type="hidden" name="regMolData" id="regMolData" value="">
	<input type="hidden" name="regMolData2000" id="regMolData2000" value="">
	<input type="hidden" name="regFieldId" id="regFieldId" value="">
	<input type="hidden" name="regName" id="regName" value="">
	<input type="hidden" name="regExperimentName" id="regExperimentName" value="">
	<input type="hidden" name="regNotebookId" id="regNotebookId" value="<%=notebookId%>">
	<input type="hidden" name="regNotebookName" id="regNotebookName" value="<%=notebookName%>">
	<input type="hidden" name="molPrefix" id="molPrefix" value="">
	<input type="hidden" name="regAmount" id="regAmount" value="">
	<input type="hidden" name="regOwnsExp" id="regOwnsExp" value="">
	<input type="hidden" name="requestId" id="requestId" value="">
	<input type="hidden" name="checkComRequested" id="checkComRequested" value="true">
</form>
<!-- #include file="_inclds/footer-tool.asp"-->
