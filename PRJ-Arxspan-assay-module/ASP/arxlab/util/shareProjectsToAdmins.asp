<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout = 600%>
<%'sectionId="test"%>
<%response.buffer=false%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<%
if session("email")="support@arxspan.com" Then 'Or 1=1 then
	
	if request.form("submitIt") <> "" Then
		Call getconnected
		Call getconnectedadm
		companyId = 62

		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM projectsView WHERE parentProjectId is null and companyId="&SQLClean(companyId,"N","S")
		rec.open strQuery,conn,0,-1
		Do While Not rec.eof
			projectName = rec("name")
			Set userRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * from usersView WHERE id="&SQLClean(rec("userId"),"N","S")
			userRec.open strQuery,conn,0,-1
			If Not userRec.eof then
				sharerName = userRec("fullName")
			Else
				sharerName = "Unknown User"
				response.write("error: unknown user "&rec("userId")&" "&projectName&"<br/>")
			End if
			userRec.close
			Set userRec = nothing
			'START AUTOSHARING
			Set gaRec=server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT * FROM users WHERE id="&SQLClean(rec("userId"),"N","S") & " AND userAdded is not null and userAdded <> 0 and userAdded <> -1"
			gaRec.open strQuery,connAdm,3,3
			If Not gaRec.eof Then
				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM projectInvites WHERE projectId="&SQLClean(rec("id"),"N","S")&" AND shareeId="&SQLClean(gaRec("userAdded"),"N","S")
				rec2.open strQuery,conn,0,-1
				If rec2.eof then
					strQuery = "INSERT into projectInvites(projectId,sharerId,shareeId,canRead,canWrite,accepted,denied,readOnly) values(" &_
					SQLClean(rec("id"),"N","S") & "," &_ 
					SQLClean(rec("userId"),"N","S") & "," &_
					SQLClean(gaRec("userAdded"),"N","S") & "," &_
					SQLClean("1","N","S") & "," &_
					SQLClean("0","N","S") & ",0,0,1)"
					'DEBUG
					connAdm.execute(strQuery)
					userAdded = gaRec("userAdded")
					response.write(strQuery&"<br/>")
					title = "Project Share Invitation"
					note = "User "&sharerName& " has invited you to share <a href=""show-project.asp?id="&rec("id")&""">"&projectName&"</a>"
					a = sendNotification(gaRec("userAdded"),title,note,8)
				End If
				rec2.close
				Set rec2 = nothing
			End if

			Set gaRec=server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT * FROM usersView WHERE roleNumber=1 AND companyId="&SQLClean(companyId,"N","S") & " AND id<>"&SQLClean(rec("userId"),"N","S")
			If userAdded <> "" Then
				strQuery = strQuery & " and id<>"&SQLClean(userAdded,"N","S")
			End if
			gaRec.open strQuery,connAdm,3,3
			Do While Not gaRec.eof
				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM projectInvites WHERE projectId="&SQLClean(rec("id"),"N","S")&" AND shareeId="&SQLClean(gaRec("id"),"N","S")
				rec2.open strQuery,conn,0,-1
				If rec2.eof then
					strQuery = "INSERT into projectInvites(projectId,sharerId,shareeId,canRead,canWrite,accepted,denied,readOnly) values(" &_
					SQLClean(rec("id"),"N","S") & "," &_ 
					SQLClean(rec("userId"),"N","S") & "," &_
					SQLClean(gaRec("id"),"N","S") & "," &_
					SQLClean("1","N","S") & "," &_
					SQLClean("0","N","S") & ",0,0,1)"
					'DEBUG
					connAdm.execute(strQuery)
					response.write(strQuery&"<br/>")

					title = "Project Share Invitation"
					note = "User "&sharerName& " has invited you to share <a href=""show-project.asp?id="&rec("id")&""">"&projectName&"</a>"
					a = sendNotification(gaRec("id"),title,note,8)
				End if
				gaRec.movenext
			loop
			'END AUTOSHARING

			rec.movenext
		Loop
		rec.close
		Set rec = nothing
		Call disconnectadm
		Call disconnect
	End If
%>
	<form action="shareProjectsToAdmins.asp" method="POST">
		<input type="submit" name="submitIt">
	</form>
<%
end if
%>