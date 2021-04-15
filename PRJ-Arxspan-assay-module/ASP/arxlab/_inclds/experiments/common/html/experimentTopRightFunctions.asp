<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->

<%
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
%>
<form name="linkForm" id="linkForm" method="POST" action="<%=mainAppPath%>/misc/ajax/do/copy.asp" target="submitFrame2">
<%If experimentType="4" Then%>
<input type="hidden" name="linkType" value="5">
<%else%>
<input type="hidden" name="linkType" value="<%=experimentType%>">
<%End if%>
<input type="hidden" name="linkId" value="<%=experimentId%>">
</form>
<%If request.querystring("pdfView") = "1" Then%>
<div class="topRightFunctionButtonsContainerPdf">
<%Else%>
<div class="topRightFunctionButtonsContainer">
<%End if%>
<form name="favForm" id="favForm" method="post" action="<%=mainAppPath%>/misc/ajax/do/add-favorite.asp" target="submitFrame2">
<input type="hidden" name="experimentType" value="<%=experimentType%>">
<input type="hidden" name="experimentId" value="<%=experimentId%>">
</form>
<form name="removeFavForm" id="removeFavForm" method="post" action="<%=mainAppPath%>/misc/ajax/do/remove-favorite.asp" target="submitFrame2">
<input type="hidden" name="experimentType" value="<%=experimentType%>">
<input type="hidden" name="experimentId" value="<%=experimentId%>">
</form>

<%If (session("role")="Admin" And session("canDelete")) Or (session("canDelete") And ownsExperiment(experimentType,experimentId,session("userId"))) then%>
	<div><a href="javascript:void(0)" onclick="deleteSubmit()" title="Delete Experiment" id="deleteExperimentButton" class="topRightFunctionButtons deleteExperimentButton">Delete Experiment</a></div>
<%End if%>

<div><a href="javascript:void(0)" onClick="openInfo()" title="Show Info" id="infoLink" style="text-decoration:none;" class="topRightFunctionButtons">Show Info</a></div>

<div><a href="javascript:void(0)" title="Show Comments" id="commentsLink" style="text-decoration:none;" class="topRightFunctionButtons"><div class="commentsButtonText">Tags &amp; Comments</div><div id="commentsButtonMessageCount" class="commentsButtonMessageCount" style="left:22px;top:2px;"></div></a></div>

<script type="text/javascript">
$(document).ready(function() {
    $.ajax({
        url: "<%=mainAppPath%>/_inclds/experiments/common/functions/fnc_numberOfCommentsSinceLastView.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>",
        type: "GET",
        async: true,
        cache: false
    })
    .success(function (numComments) {
        $("#commentsButtonMessageCount").html(numComments);
        return true;
    })
    .fail(function () {
        console.error("Unable to load number of unread comments. Please contact support@arxspan.com.");
        return true;
    });
});
<%If request.querystring("comments") = "true" then%>
addLoadEvent(openComments())
<%End if%>
</script>

<%
Set fRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM experimentFavorites WHERE experimentType="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")& " AND userId="&SQLClean(session("userId"),"N","S")
fRec.open strQuery,conn,adOpenStatic,adLockReadOnly
If fRec.eof Then
	emptyStar = true
End if
Dim notificationQueries(2)
notificationQueries(0) = "UPDATE noteAddedNotifications set dismissed=1 WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0"
notificationQueries(1) = "UPDATE attachmentAddedNotifications set dismissed=1 WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0"
notificationQueries(2) = "UPDATE experimentSavedNotifications set dismissed=1 WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND dismissed=0"
If request.querystring("comments") = "true" Then
    ReDim Preserve notificationQueries(UBound(notificationQueries) + 1)
	notificationQueries(UBound(notificationQueries)) =  "UPDATE commentNotifications set dismissed=1 WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S") & " AND userId=" & SQLClean(session("userId"),"N","S") & " AND (dismissed=0 or dismissed is null)"
End if
Call getconnectedadm
For q = 0 To UBound(notificationQueries)
	connAdm.execute(notificationQueries(q))
Next
Call disconnectadm
%>
<div><a href="javascript:void(0)" onClick="document.getElementById('favForm').submit();this.style.display='none';document.getElementById('filledStar').style.display='block';" title="Add to Watchlist" id="emptyStar" class="topRightFunctionButtons" <%If Not emptyStar then%>style="display:none;"<%End if%>>Add to Watchlist</a>
<a href="javascript:void(0)" onClick="document.getElementById('removeFavForm').submit();this.style.display='none';document.getElementById('emptyStar').style.display='block';" title="Remove from Watchlist" id="filledStar" class="topRightFunctionButtons" <%If emptyStar then%>style="display:none;"<%End if%>>Remove from Watchlist</a></div>
<%
fRec.close
Set fRec = nothing
%>

<div><a href="javascript:void(0)" onclick="initializeLinking()" title="Link" id="initializeLinkingButton" class="topRightFunctionButtons initializeLinkingButton">Link</a></div>
</div>