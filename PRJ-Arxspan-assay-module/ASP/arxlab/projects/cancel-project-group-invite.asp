<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
If isAdminUser(session("userId")) Then
	strQuery = "SELECT * from groupProjectInvites WHERE id=" & SQLClean(request.Form("inviteId"),"N","S")
Else
	strQuery = "SELECT * from groupProjectInvites WHERE sharerId="&SQLClean(session("userId"),"N","S") & " AND id=" & SQLClean(request.Form("inviteId"),"N","S")& " and readOnly <> 1"
End If
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	connAdm.execute("DELETE from groupProjectInvites WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
	'a = logAction(1,rec("notebookId"),"",5)
End If
%>
<div id="resultsDiv">success</div>