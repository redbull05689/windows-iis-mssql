<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from notebookInvites WHERE id=" & SQLClean(request.Form("inviteId"),"N","S") & ""
rec.open strQuery,connAdm,3,3
If (ownsNotebook(rec("notebookId")) Or rec("sharerId")=session("userId")) And hasShareNotebookPermission(false) Then
	shareeId = rec("shareeId")
	notebookId = rec("notebookId")
	Select Case request.Form("newPermissions")
		Case "1"
			canRead = "1"
			canWrite = "0"
			connAdm.execute("UPDATE notebookInvites SET canRead=1,canWrite=0 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
			a = logAction(1,rec("notebookId"),"",12)
		Case "2"
			canRead = "0"
			canWrite = "1"
			If rec("readOnly") = 0 then
				connAdm.execute("UPDATE notebookInvites SET canRead=0,canWrite=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
				a = logAction(1,rec("notebookId"),"",12)
			End if
		Case "3"
			canRead = "1"
			canWrite = "1"
			connAdm.execute("UPDATE notebookInvites SET canRead=1,canWrite=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
			a = logAction(1,rec("notebookId"),"",12)
	End Select
	children = getChildInvites(notebookId,shareeId)
	children = Split(children,",")
	For i = 0 To UBound(children)
		If canRead = "0" then	
			connAdm.execute("UPDATE notebookInvites SET canRead=0 WHERE id="&SQLClean(children(i),"N","S"))
		End if
		If canWrite = "0" then	
			connAdm.execute("UPDATE notebookInvites SET canWrite=0 WHERE id="&SQLClean(children(i),"N","S"))
		End if
	next
End If
%>
<div id="resultsDiv">success</div>