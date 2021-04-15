<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->
<%
newUserId = request.querystring("newUserId")
projectId = request.querystring("projectId")
If session("role") = "Admin" Then
	usersTable = getDefaultSingleAppConfigSetting("usersTable")
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM "&usersTable&" WHERE id="&SQLClean(newUserId,"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		newName = rec("firstName") &"&nbsp;"& rec("lastName")
		rec.close
		strQuery = "SELECT * FROM projectsView WHERE id="&SQLClean(projectId,"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S") & " AND parentProjectId is null"
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			projectName = rec("name")
			Call getconnectedAdm
			strQuery = "UPDATE projects SET userId="&SQLClean(newUserId,"N","S")&" WHERE id="&SQLClean(projectId,"N","S")&" or parentProjectId="&SQLClean(projectId,"N","S")
			connAdm.execute(strQuery)
			response.write(newName)
			title = "Project Ownership Transfer"
			note = "User "&session("firstName") &" "& session("lastName")& " has transferred the project <a href="""&mainAppPath&"/show-project.asp?id="&projectId&""">"&projectName&"</a> to you"
			a = sendNotification(newUserId,title,note,12)
			If rec("userId") = session("userId") Then
				'if the user who is changing the ownership owned the project before give user read access
				strQuery = "INSERT into projectInvites(projectId,sharerId,shareeId,canRead,canWrite,accepted,denied) values(" &_
				SQLClean(projectId,"N","S") & "," &_ 
				SQLClean(newUserId,"N","S") & "," &_
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean("1","N","S") & "," &_
				SQLClean("0","N","S") & ",0,0)"
				connAdm.execute(strQuery)

				Set nRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM projects WHERE id="&SQLClean(projectId,"N","S")
				nRec.open strQuery,connAdm,3,3
				If Not nRec.eof Then
					projectName = nRec("name")
				End if
				title = "Project Share Invitation"
				note = "User "&session("firstName") &" "& session("lastName")& " has invited you to share <a href="""&mainAppPath&"/show-project.asp?id="&projectId&""">"&projectName&"</a>"

				a = sendNotification(session("userId"),title,note,8)
			End If
			If CStr(newUserId) = CStr(session("userId")) Then
				'if transferring ownership to self, remove invitations
				strQuery = "DELETE FROM projectInvites WHERE projectId="&SQLClean(projectId,"N","S")& " AND shareeId="&SQLClean(session("userId"),"N","S")
				connAdm.execute(strQuery)
			End If
			Call disconnectAdm
		End if
	End If
	rec.close
	Set rec = nothing
End if
%>