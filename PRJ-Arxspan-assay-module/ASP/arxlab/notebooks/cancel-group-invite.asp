<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from groupNotebookInvites WHERE id=" & SQLClean(request.Form("inviteId"),"N","S") & " AND readOnly <> 1"
rec.open strQuery,connAdm,3,3
If (ownsNotebook(rec("notebookId")) Or rec("sharerId")=session("userId")) And hasShareNotebookPermission(false) Then
	connAdm.execute("DELETE from groupNotebookInvites WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
	a = logAction(1,rec("notebookId"),"",5)
End If
%>
<div id="resultsDiv">success</div>