<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->

<%
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from projectInvitesView WHERE id="&SQLClean(request.Form("inviteId"),"N","S") & " AND (shareeId="&SQLClean(session("userId"),"N","S") & ") AND accepted=0"
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	If request.Form("notebookAcceptStatus") = "1" then
		connAdm.execute("UPDATE projectInvites SET accepted=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
		'strQuery = "INSERT INTO notebookAccess(notebookId,userId,canRead,canWrite) values(" &_
		'			SQLClean(rec("notebookId"),"N","S") & "," &_
		'			SQLClean(session("userId"),"N","S") & "," &_
		'			SQLClean(rec("canRead"),"N","S") & "," &_
		'			SQLClean(rec("canRead"),"N","S") & ")"
		'connAdm.execute(strQuery)
		title = "Project Invitation Accepted"
		note = "User "&session("firstName") & " " & session("lastName") & " has accepted your invitation to share Project <a href="""&mainAppPath&"/show-project.asp?id="&rec("projectId")&""">"&rec("name")&"</a>"
		a = sendNotification(rec("sharerId"),title,note,4)
	Else
		connAdm.execute("DELETE from projectInvites WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
		title = "Project Invitation Declined"
		note = "User "&session("firstName") & " " & session("lastName") & " has declined your invitation to share Project <a href="""&mainAppPath&"/show-project.asp?id="&rec("projectId")&""">"&rec("name")&"</a>"
		a = sendNotification(rec("sharerId"),title,note,4)
	End if
End If
%>
<div id="resultsDiv">success</div>