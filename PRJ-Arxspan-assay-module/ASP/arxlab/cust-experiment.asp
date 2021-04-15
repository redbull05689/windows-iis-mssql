<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "cust-experiment"
experimentType="5"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/experiments/common/asp/experimentInitVars.asp"-->
<!-- #include file="_inclds/common/asp/uploadInit.asp"-->
<!-- #include file="_inclds/class_logger.asp"-->

<link href="common/bootstrap-3.3.5/css/bootstrap.min.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<%
	sectionID = "tool"
	subSectionID="cust-experiment"
	terSectionID=""

	metaD=""
	metaKey=""
	statusId = "none"
%>
<!-- #include file="_inclds/experiments/cust/asp/custGetExperimentVars.asp"-->
<!-- #include file="_inclds/experiments/common/asp/getExperimentPermissions.asp"-->

<script>
	var statusId = "<%=statusId%>";
	var isCurrRev = "<%=currentRevisionNumber = maxRevisionNumber%>" == "True";
	var canWrite = "<%=canWrite%>" == "True" && ["5", "6"].indexOf(statusId) < 0 && isCurrRev;
</script>
<%
canWrite = canWrite or isCoAuthor
hasWritePerm = canWrite
canWrite = canWrite and isDraftAuthor
If experimentDetails <> "" Then
	pageTitle = experimentDetails
else
	pageTitle = experimentName
End if
coAuthors = getCoAuthors(experimentId, experimentType, revisionId)
'SIGNERS = addSigners(experimentId, experimentType, revisionId, "1382,1383,1384")
%>
<!-- #include file="_inclds/header-tool.asp"-->
<!-- #include file="_inclds/common/html/popupDivs.asp"-->
<!-- #include file="_inclds/nav_tool.asp"-->
<!-- #include file="_inclds/experiments/common/html/deleteExperimentForm.asp"-->
<!-- #include file="_inclds/jsRev.asp"-->

<script type="text/javascript">
	window.CurrentPageMode = "custExp";
	window.currApp = "ELN";
</script>

<script type="text/javascript" src="js/common/experiments/commonFunctions.js?<%=jsRev%>"></script>
<script type="text/javascript" src="common/bootstrap-3.3.5/js/bootstrap.js?<%=jsRev%>"></script>

<script>
	var experimentStatusId = <%= statusId %>;
	var experimentType = <%=experimentType%>;
	var experimentId = <%=experimentId%>;

	var userId = "<%=session("userId")%>";
	var ownerId = "<%=expUserId%>";
	var isDraftAuthor = "<%=isDraftAuthor%>" == "True";
	var draftAuthor = "<%=draftAuthor%>";
	var coAuthors = "<%=coAuthors%>";
	var signers = "<%=revisionId%>";
	var isCoAuthorStr = "<%=isCoAuthor%>";
	var isCoAuthor = "<%=isCoAuthor%>" == "True";
	var latestStatus = "<%=latestStatus%>";
	var ownsExp = "<%=ownsExp%>";
	//canWrite = canWrite || isCoAuthor;
</script>

<%hasInviteRead = hasNotebookInviteRead(notebookId,session("userId"))%>
<%If (canViewExperiment("5",experimentId,session("userId")) Or canRead Or hasInviteRead) And notebookVisible And experimentVisible then%>

	<%If isDraftAuthor then%>
		<!-- #include file="experiments/fileUploadForm.asp"-->
	<%End if%>

<!-- #include file="_inclds/common/html/infoBox.asp"-->

<!-- #include file="_inclds/experiments/cust/js/custJSIncludes.asp"-->
<!-- #include file="_inclds/experiments/cust/js/custJS.asp"-->
<!-- #include file="_inclds/experiments/common/asp/unsavedChanges.asp"-->

<!-- #include file="_inclds/experiments/cust/html/custForm.asp"-->
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
if ("<%=ownsExp%>" == "True" && isDraftAuthor) {
	addEvent(window,'load',function(){unsavedChanges=true;showOverMessage("unsavedChanges","page")})
}
<%
end if
%>


console.log("latestStatus : " + latestStatus)
console.log("requestId : " + $("#requestId").val())
console.log("requestRevisionId : " + $("#requestRevisionId").val())

if (latestStatus != "1" && (($("#requestId").val() == "0" && revisionId != "1" )|| $("#requestRevisionId").val() == "0" )) {
	swal("There is an error with this experiment. Please contact support.");
}

if ("<%=ownsExp%>" == "True" && !isDraftAuthor) {
	swal("There is an existing draft created by " + draftAuthor + ". The experiment has been set to read-only mode.");
	unsavedChanges = false;
	hideUnsavedChanges();
}

$("#basicLoadingModal").modal("show");
</script>

<!-- #include file="_inclds/footer-tool.asp"-->