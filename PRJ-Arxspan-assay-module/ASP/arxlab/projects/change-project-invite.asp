<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedadm

canChangeInvite = False
readOnlyInvite = 1

If ownsProject(request.Form("projectId")) Or isAdminUser(session("userId")) Then
	canChangeInvite = True
	readOnlyInvite = 0
Else
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * from projectInvites WHERE sharerId="&SQLClean(session("userId"),"N","S") & " AND id=" & SQLClean(request.Form("inviteId"),"N","S") & ""
	rec.open strQuery,connAdm,3,3
	If Not rec.eof Then
		canChangeInvite = True
		readOnlyInvite = rec("readOnly")
	End If
	rec.Close
	Set rec = Nothing
End If

If canChangeInvite Then
	Select Case request.Form("newPermissions")
		Case "1"
			connAdm.execute("UPDATE projectInvites SET canRead=1,canWrite=0 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
			'a = logAction(1,rec("notebookId"),"",12)
		Case "2"
			If readOnlyInvite = 0 then
				connAdm.execute("UPDATE projectInvites SET canRead=0,canWrite=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
				'a = logAction(1,rec("notebookId"),"",12)
			End if
		Case "3"
			connAdm.execute("UPDATE projectInvites SET canRead=1,canWrite=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
			'a = logAction(1,rec("notebookId"),"",12)
	End select
End If
%>
<div id="resultsDiv">success</div>