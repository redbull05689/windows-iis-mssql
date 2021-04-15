<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "bio-experiment"
experimentType="2"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/experiments/common/asp/experimentInitVars.asp"-->
<!-- #include file="_inclds/common/asp/uploadInit.asp"-->
<%
	sectionID = "tool"
	subSectionID="bio-experiment"
	terSectionID=""

	metaD=""
	metaKey=""
%>
<!-- #include file="_inclds/experiments/bio/asp/bioGetExperimentVars.asp"-->
<!-- #include file="_inclds/experiments/common/asp/getExperimentPermissions.asp"-->
<%
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
<%If (canViewExperiment("2",experimentId,session("userId")) Or canRead Or hasInviteRead) And notebookVisible And experimentVisible then%>
<!-- #include file="experiments/fileUploadForm.asp"-->

<!-- #include file="_inclds/common/html/infoBox.asp"-->

<!-- #include file="_inclds/experiments/bio/js/bioJSIncludes.asp"-->
<!-- #include file="_inclds/experiments/bio/js/bioJS.asp"-->
<!-- #include file="_inclds/experiments/common/asp/unsavedChanges.asp"-->

<!-- #include file="_inclds/experiments/bio/html/bioForm.asp"-->
<div id="bottomButtons">
	<!-- #include file="_inclds/experiments/common/buttons/html/experimentBottomButtons.asp"-->
</div>
<!-- #include file="_inclds/common/html/submitFrame.asp"-->
<%If request.querystring("id") = "" then%>
<script type="text/javascript">
	notebookChange();
</script>
<%End if%>

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

<!-- #include file="_inclds/footer-tool.asp"-->
