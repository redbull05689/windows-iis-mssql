<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
notebookId = request.Form("notebookId")
%>
<%If ((ownsNotebook(notebookId) And hasShareNotebookPermission(false)) Or canShareNotebook(notebookId)) then%>
<%
Call getconnectedadm
canRead = "0"
canWrite = "0"
canShare = "0"
canShareShare = "0"
If request.Form("canRead") = "on" And canReadNotebook(notebookId,session("userId")) Then
	canRead = "1"
End if
If request.Form("canWrite") = "on" AND canWriteNotebook(notebookId) Then
	canWrite = "1"
End if
If request.Form("canShare")= "on" Then
	canShare = "1"
End If
If request.Form("canShareShare") = "on" Then
	canShareShare = "1"
End if

If (canShare = "1" And Not canShareNotebook(notebookId)) Or (canShareShare = "1" And Not canShareShareNotebook(notebookId)) Then
	errorStr = "You do not have access to do this"
End if

If canRead = "0" And canWrite = "0" Then
	errorStr = "You must select an access option"
End if

If Not isNotebookVisible(notebookId) Then
	ErrorStr = "This notebook has been deleted"
End if

If Trim(request.Form("userIds")) = "" And Trim(request.Form("groupIds")) = "" Then
	errorStr = "You have not selected any users or groups to share this Notebook with."
End if

If canShare = "1" Then
	users = Split(request.Form("allUserIds"),",")
Else
	users = Split(request.Form("userIds"),",")
End if
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
			strQuery = "SELECT * FROM notebookInvites WHERE notebookId=" & SQLClean(notebookId,"N","S") &_
			" AND sharerId="&SQLClean(session("userId"),"N","S") &_
			" AND shareeId="&SQLClean(users(i),"N","S")
			rec2.open strQuery,connAdm,3,3
			
			If rec2.eof then
				strQuery = "INSERT into notebookInvites(notebookId,sharerId,shareeId,canRead,canWrite,canShare,canShareShare,accepted,denied) values(" &_
				SQLClean(request.Form("notebookId"),"N","S") & "," &_ 
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(users(i),"N","S") & "," &_
				SQLClean(canRead,"N","S") & "," &_
				SQLClean(canWrite,"N","S") & "," &_
				SQLClean(canShare,"N","S") & "," &_
				SQLClean(canShareShare,"N","S") &",0,0)"
				'DEBUG
				response.write("inserting invite into notebook invites where the user exists<br>")
				connAdm.execute(strQuery)

				Set nRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM notebooks WHERE id="&SQLClean(request.Form("notebookId"),"N","S")
				nRec.open strQuery,connAdm,3,3
				If Not nRec.eof Then
					notebookName = nRec("name")
				End if
				title = "Notebook Share Invitation"
				note = "User "&session("firstName") &" "& session("lastName")& " has invited you to share <a href="""&mainAppPath&"/show-notebook.asp?id="&request.Form("notebookId")&""">"&notebookName&"</a>"

				a = sendNotification(users(i),title,note,2)
				Call getconnected
				a = logAction(1,request.Form("notebookId"),"",4)
				Call disconnect
			End if
		End if
	Next
	If canShare <> "1" then
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
			strQuery = "SELECT * FROM groupNotebookInvites WHERE notebookId=" & SQLClean(notebookId,"N","S") &_
			" AND sharerId="&SQLClean(session("userId"),"N","S") &_
			" AND shareeId="&SQLClean(groups(i),"N","S")
			rec2.open strQuery,connAdm,3,3
			
			If rec2.eof then
				strQuery = "INSERT into groupNotebookInvites(notebookId,sharerId,shareeId,canRead,canWrite,canShare,canShareShare,accepted,denied,readOnly) values(" &_
				SQLClean(request.Form("notebookId"),"N","S") & "," &_ 
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(groups(i),"N","S") & "," &_
				SQLClean(canRead,"N","S") & "," &_
				SQLClean(canWrite,"N","S") & "," &_
				SQLClean(canShare,"N","S") & "," &_
				SQLClean(canShareShare,"N","S") & ",1,0,0)"
				'DEBUG
				response.write("inserting invite into notebook invites where the user exists<br>")
				connAdm.execute(strQuery)

				Set nRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM notebooks WHERE id="&SQLClean(request.Form("notebookId"),"N","S")
				nRec.open strQuery,connAdm,3,3
				If Not nRec.eof Then
					notebookName = nRec("name")
				End if
				title = "Notebook Share Invitation"
				note = "User "&session("firstName") &" "& session("lastName")& " has invited you to share <a href="""&mainAppPath&"/show-notebook.asp?id="&request.Form("notebookId")&""">"&notebookName&"</a>"
				Set rec4 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM groupMembers WHERE groupId="&SQLClean(groups(i),"N","S")
				rec4.open strQuery,connAdm,3,3
				Do While Not rec4.eof
					a = sendNotification(rec4("userId"),title,note,2)
					rec4.moveNext
				loop
				Call getconnected
				a = logAction(1,request.Form("notebookId"),"",4)
				Call disconnect
			End if
		End if
	Next
	End if
End if

If errorStr = "" Then
	errorStr = "success"
End if
%>

<%else
	errorStr = errorStr & "Not Authorized"
End if%>
<div id="resultsDiv"><%=errorStr%></div>