<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->
<%
'muf
Function getUserName(userId)
	Set uuRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT firstName,lastName from users WHERE id="&SQLClean(userId,"N","S")
	uuRec.open strQuery,conn,0,-1
	getUserName = uuRec("firstName")&" "&uuRec("lastName")
End function
%>
<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
revisionId = request.querystring("revisionId")
Call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT notebookId, userId FROM notebookIndex WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND typeId=" & SQLClean(experimentType,"N","S")
rec.open strQuery,conn,3,3
If Not rec.eof then
	notebookId = CStr(rec("notebookId"))
	canWrite = canWriteNotebook(notebookId)
	If session("userId") = rec("userId") Then
		ownsExp = True
	Else
		ownsExp = false
	End if
Else
	canWrite = False
	ownsExp = false
End If
canView = canViewExperiment(experimentType,experimentId,session("userId"))
%>
<!-- #include file="../_inclds/experiments/common/asp/getExperimentPermissions.asp"-->
<!-- #include file="../_inclds/experiments/common/asp/getExperimentJSON.asp"-->
<%isAjax = true%>
<!-- #include file="../_inclds/attachments/html/showAttachmentTable.asp"-->

<script type="text/javascript">
	attachEdits(document.getElementById("attachmentTable"));
	//Check for the extension and native messaging host and show the buttons accordingly 9/8/16
liveEditor.addInstalledCallback(function(args) {
		console.log("btnDisplayCheck...");
		$(".liveEdit").addClass("makeVisible");
		$(".noLiveEdit").hide();
		return true;
	}, {});
</script>
<!-- #include file="../_inclds/experiments/common/asp/saveExperimentJSON.asp"-->