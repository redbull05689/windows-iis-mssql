<!-- #include virtual="/_inclds/sessionInit.asp" -->
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
	pageTitle = "Arxspan Experiment"
	metaD=""
	metaKey=""
%>

<%If session("requireProjectLink") = true Then%>
	<script type="text/javascript">
		var requireProjectLink = true
	</script>
<%End if%>
<!-- #include file="_inclds/experiments/chem/asp/chemGetExperimentVars.asp"-->
<!-- #include file="_inclds/experiments/common/asp/getExperimentPermissions.asp"-->
<%
If revisionId = "" then
	sigdigs = draftSet("sigdig",expRec("sigdigs"))
End If

pageTitle = experimentName
%>
<!-- #include file="_inclds/header-tool.asp"-->
<!-- #include file="_inclds/common/html/popupDivs.asp"-->
<!-- #include file="_inclds/nav_tool.asp"-->
<!-- #include file="_inclds/experiments/common/html/deleteExperimentForm.asp"-->

<%
If hasCombi and hasCombiPlate Then
	resultSD = draftSet("resultSD",expRec("resultSD"))
	If IsNull(resultSD) Then
		resultSD = ""
	End If
End if
%>

<script type="text/javascript" src="js/common/experiments/commonFunctions.js?<%=jsRev%>"></script>
<script>
	var experimentStatusId = <%= statusId %>;
	var experimentType = <%=experimentType%>;
	var experimentId = <%=experimentId%>;
</script>

<%hasInviteRead = hasNotebookInviteRead(notebookId,session("userId"))%>
<%If (canViewExperiment("1",experimentId,session("userId")) Or canRead Or ownsExp Or (canWrite And ownsExp) Or hasInviteRead) And notebookVisible And experimentVisible then%>
<!-- #include file="experiments/fileUploadForm.asp"-->
<!-- #include file="_inclds/common/html/infoBox.asp"-->
<!-- #include file="_inclds/experiments/chem/js/chemJSIncludes.asp"-->
<!-- #include file="_inclds/experiments/chem/js/chemJS_no_chemdraw.asp"-->
<!-- #include file="_inclds/experiments/common/asp/unsavedChanges.asp"-->

<%
Set fRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM experimentFavorites WHERE experimentType=1 AND experimentId="&SQLClean(experimentId,"N","S")& " AND userId="&SQLClean(session("userId"),"N","S")
fRec.open strQuery,conn,3,3
If fRec.eof Then
	emptyStar = true
End if
experimentType="1"
strQuery = "UPDATE noteAddedNotifications set dismissed=1 WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0;UPDATE attachmentAddedNotifications set dismissed=1 WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0;UPDATE experimentSavedNotifications set dismissed=1 WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0;"
If request.querystring("comments") = "true" Then
	strQuery = strQuery & "UPDATE commentNotifications set dismissed=1 WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND (dismissed=0 or dismissed is null)"
End if
Call getconnectedadm
connAdm.execute(strQuery)
Call disconnectadm
%>
<!--<a href="javascript:void(0)" onClick="document.getElementById('favForm').submit();this.style.display='none';document.getElementById('filledStar').style.display='block';" title="Add to Watchlist" id="emptyStar" <%If Not emptyStar then%>style="display:none;"<%End if%>><img border="0" src="images/star.gif" style="position:absolute;right:45px;"></a>
<a href="javascript:void(0)" onClick="document.getElementById('removeFavForm').submit();this.style.display='none';document.getElementById('emptyStar').style.display='block';" title="Remove from Watchlist" id="filledStar" <%If emptyStar then%>style="display:none;"<%End if%>><img border="0" src="images/star-filled.gif" style="position:absolute;right:45px;"></a>-->
<%
fRec.close
Set fRec = nothing
%>
<!-- #include file="_inclds/experiments/chem/html/chemForm.asp"-->
<%If request.querystring("id")<>"" then%>
<script type="text/javascript">
addLoadEvent(function(){
	try{
		//Update experimentJSON
		Object.assign(experimentJSON, <%=JSON.stringify(experimentJSON)%>);

		//Update UAStates
		var theKeys = Object.keys(experimentJSON);
		uaStatesList = theKeys.filter(function(value){
			return /(r|rg|s|p)\d+_UAStates/.test(value);
		});
		uaStatesList.forEach(function(element){
			theMatch = element.match(/(r|rg|s|p)\d+/);
			if(experimentJSON[element] != ""){
				UAStates[theMatch[0]] = JSON.parse(experimentJSON[element]);
			}
		});
	}catch(e){
		console.log("ERROR Loading experimentJSON");
	}
	waitPopulate();
})
</script>
<%end if%>
<!-- #include file="_inclds/common/html/submitFrame.asp"-->
<%If request.querystring("id") = "" then%>
<script type="text/javascript">
	notebookChange();
</script>
<%End if%>
<div id="bottomButtons">
<!-- #include file="_inclds/experiments/common/buttons/html/experimentBottomButtons.asp"-->
</div>
<!-- #include file="_inclds/experiments/common/js/experimentBounceToTab.asp"-->

<%trash = addToRecentlyViewed(experimentId,experimentType)%>
<%else%>
	<%If Not notebookVisible Or Not experimentVisible then%>
		<p>This experiment has been deleted</p>
	<%else%>
		<p>You are not authorized to view this experiment</p>
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
	<input type="hidden" name="regOwnsExp" id="regOwnsExp" value="">
	<input type="hidden" name="requestId" id="requestId" value="">
	<input type="hidden" name="checkComRequested" id="checkComRequested" value="true">
</form>

<!-- #include file="_inclds/footer-tool.asp"-->
