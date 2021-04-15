<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
projectId = request.Form("projectId")
%>
<%If ownsProject(projectId) Or isAdminUser(session("userId")) then%>
<%
Call getconnectedadm

canRead = "0"
canWrite = "0"
If request.Form("canRead") = "on" Then
	canRead = "1"
End if
If request.Form("canWrite") = "on" Then
	canWrite = "1"
End if

If canRead = "0" And canWrite = "0" Then
	errorStr = "You must select an access option"
End if

If Not isProjectVisible(projectId) Then
	ErrorStr = "This project has been deleted"
End if

If Trim(request.Form("userIds")) = "" And Trim(request.Form("groupIds")) = "" Then
	errorStr = "You have not selected any users or groups to share this Notebook with."
End if

users = Split(request.Form("userIds"),",")
groups = Split(request.Form("groupIds"),",")

If errorStr = "" Then
	For i = 0 To UBound(users)
		usersTable = getDefaultSingleAppConfigSetting("usersTable")
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM "&usersTable&" WHERE companyId="&SQLClean(session("companyId"),"N","S") & " AND id="&SQLClean(users(i),"N","S")
		rec2.open strQuery,connAdm,3,3
		userExists = False
		If Not rec2.eof Then
			userExists = true
		End If
		response.write(userExists)
		If userExists then
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM projectInvites WHERE projectId=" & SQLClean(projectId,"N","S") &_
			" AND sharerId="&SQLClean(session("userId"),"N","S") &_
			" AND shareeId="&SQLClean(users(i),"N","S")
			rec2.open strQuery,connAdm,3,3
			
			If rec2.eof then
				strQuery = "INSERT into projectInvites(projectId,sharerId,shareeId,canRead,canWrite,accepted,denied) values(" &_
				SQLClean(projectId,"N","S") & "," &_ 
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(users(i),"N","S") & "," &_
				SQLClean(canRead,"N","S") & "," &_
				SQLClean(canWrite,"N","S") & ",0,0)"
				'DEBUG
				response.write("inserting invite into project invites where the user exists<br>")
				connAdm.execute(strQuery)

				Set nRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM projects WHERE id="&SQLClean(projectId,"N","S")
				nRec.open strQuery,connAdm,3,3
				If Not nRec.eof Then
					projectName = nRec("name")
				End if
				title = "Project Share Invitation"
				note = "User "&session("firstName") &" "& session("lastName")& " has invited you to share <a href="""&mainAppPath&"/show-project.asp?id="&projectId&""">"&projectName&"</a>"

				a = sendNotification(users(i),title,note,8)
				Call getconnected
				'a = logAction(1,request.Form("notebookId"),"",4)
				Call disconnect
			End if
		End if
	Next
	For i = 0 To UBound(groups)
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM groups WHERE companyId="&SQLClean(session("companyId"),"N","S") & " AND id="&SQLClean(groups(i),"N","S")
		rec2.open strQuery,connAdm,3,3
		groupExists = False
		If Not rec2.eof Then
			groupExists = true
		End If
		response.write(groupExists)
		If groupExists then
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM groupProjectInvites WHERE projectId=" & SQLClean(projectId,"N","S") &_
			" AND sharerId="&SQLClean(session("userId"),"N","S") &_
			" AND shareeId="&SQLClean(groups(i),"N","S")
			rec2.open strQuery,connAdm,3,3
			
			If rec2.eof then
				strQuery = "INSERT into groupProjectInvites(projectId,sharerId,shareeId,canRead,canWrite,accepted,denied,readOnly) values(" &_
				SQLClean(projectId,"N","S") & "," &_ 
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(groups(i),"N","S") & "," &_
				SQLClean(canRead,"N","S") & "," &_
				SQLClean(canWrite,"N","S") & ",1,0,0)"
				'DEBUG
				response.write("inserting invite into project invites where the user exists<br>")
				connAdm.execute(strQuery)

				Set nRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM projects WHERE id="&SQLClean(projectId,"N","S")
				nRec.open strQuery,connAdm,3,3
				If Not nRec.eof Then
					projectName = nRec("name")
				End if
				title = "Project Share Invitation"
				note = "User "&session("firstName") &" "& session("lastName")& " has invited you to share <a href="""&mainAppPath&"/show-project.asp?id="&projectId&""">"&projectName&"</a>"
				Set rec4 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM groupMembers WHERE groupId="&SQLClean(groups(i),"N","S")
				rec4.open strQuery,connAdm,3,3
				Do While Not rec4.eof
					a = sendNotification(rec4("userId"),title,note,8)
					rec4.moveNext
				loop
				Call getconnected
				'a = logAction(1,request.Form("notebookId"),"",4)
				Call disconnect
			End if
		End if
	next	
End if

If errorStr = "" Then
	errorStr = "success"
End if
%>

<%else
	errorStr = "Not Authorized"
End if%>
<div id="resultsDiv"><%=errorStr%></div>