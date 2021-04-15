<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->

<%
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from notebookInvitesView WHERE id="&SQLClean(request.Form("inviteId"),"N","S") & " AND (shareeId="&SQLClean(session("userId"),"N","S") & " OR shareeEmail=" & SQLClean(session("email"),"T","S") &") AND accepted=0"
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	If request.Form("notebookAcceptStatus") = "1" then
		connAdm.execute("UPDATE notebookInvites SET accepted=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
		strQuery = "INSERT INTO notebookAccess(notebookId,userId,canRead,canWrite) values(" &_
					SQLClean(rec("notebookId"),"N","S") & "," &_
					SQLClean(session("userId"),"N","S") & "," &_
					SQLClean(rec("canRead"),"N","S") & "," &_
					SQLClean(rec("canRead"),"N","S") & ")"
		connAdm.execute(strQuery)
		title = "Notebook Invitation Accepted"
		note = "User "&session("firstName") & " " & session("lastName") & " has accepted your invitation to share Notebook <a href="""&mainAppPath&"/show-notebook.asp?id="&rec("notebookId")&""">"&rec("name")&"</a>"
		a = sendNotification(rec("sharerId"),title,note,3)
	Else
		connAdm.execute("DELETE from notebookInvites WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
		title = "Notebook Invitation Declined"
		note = "User "&session("firstName") & " " & session("lastName") & " has declined your invitation to share Notebook <a href="""&mainAppPath&"/show-notebook.asp?id="&rec("notebookId")&""">"&rec("name")&"</a>"
		a = sendNotification(rec("sharerId"),title,note,3)
	End if
End If
%>
<div id="resultsDiv">success</div>