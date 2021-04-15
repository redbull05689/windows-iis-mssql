<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from groupNotebookInvites WHERE id=" & SQLClean(request.Form("inviteId"),"N","S")
rec.open strQuery,connAdm,3,3
If (ownsNotebook(rec("notebookId")) Or rec("sharerId")=session("userId")) And hasShareNotebookPermission(false) Then
	Select Case request.Form("newPermissions")
		Case "1"
			connAdm.execute("UPDATE groupNotebookInvites SET canRead=1,canWrite=0 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
			a = logAction(1,rec("notebookId"),"",12)
		Case "2"
			If rec("readOnly") = 0 then
				connAdm.execute("UPDATE groupNotebookInvites SET canRead=0,canWrite=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
				a = logAction(1,rec("notebookId"),"",12)
			End if
		Case "3"
			connAdm.execute("UPDATE groupNotebookInvites SET canRead=1,canWrite=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
			a = logAction(1,rec("notebookId"),"",12)
	End select
End If
%>
<div id="resultsDiv">success</div>