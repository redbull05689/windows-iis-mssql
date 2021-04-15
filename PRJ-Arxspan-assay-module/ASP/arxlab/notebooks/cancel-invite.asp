<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from notebookInvites WHERE id=" & SQLClean(request.Form("inviteId"),"N","S")& " AND readOnly <> 1"
rec.open strQuery,connAdm,3,3
If (ownsNotebook(rec("notebookId")) Or rec("sharerId")=session("userId")) And hasShareNotebookPermission(false) Then
	shareeId = rec("shareeId")
	notebookId = rec("notebookId")
	children = getChildInvites(notebookId,shareeId)
	children = Split(children,",")
	For i = 0 To UBound(children)
		connAdm.execute("DELETE from notebookInvites WHERE id="&SQLClean(children(i),"N","S"))	
	next
	connAdm.execute("DELETE from notebookInvites WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
	a = logAction(1,rec("notebookId"),"",5)
End If
%>
<div id="resultsDiv">success</div>