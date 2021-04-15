<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp" -->
<%
newUserId = request.querystring("newUserId")
notebookId = request.querystring("notebookId")
If session("role") = "Admin" Then
	usersTable = getDefaultSingleAppConfigSetting("usersTable")
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM "&usersTable&" WHERE id="&SQLClean(newUserId,"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		newName = rec("firstName") &"&nbsp;"& rec("lastName")
		rec.close
		strQuery = "SELECT * FROM notebookView WHERE id="&SQLClean(notebookId,"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			notebookName = rec("name")
			Call getconnectedAdm
			strQuery = "UPDATE notebooks SET userId="&SQLClean(newUserId,"N","S")&" WHERE id="&SQLClean(notebookId,"N","S")
			connAdm.execute(strQuery)
			'strQuery = "UPDATE notebookIndex SET userId="&SQLClean(newUserId,"N","S")&" WHERE notebookId="&SQLClean(notebookId,"N","S")
			'connAdm.execute(strQuery)
			'response.write(newName)
			title = "Notebook Ownership Transfer"
			note = "User "&session("firstName") &" "& session("lastName")& " has transferred the notebook <a href="""&mainAppPath&"/show-notebook.asp?id="&notebookId&""">"&notebookName&"</a> to you"
			a = sendNotification(newUserId,title,note,10)
			If rec("userId") = session("userId") Then
				'if the user who is changing the ownership owned the notebook before give user read access
				strQuery = "INSERT into notebookInvites(notebookId,sharerId,shareeId,canRead,canWrite,accepted,denied) values(" &_
				SQLClean(notebookId,"N","S") & "," &_ 
				SQLClean(newUserId,"N","S") & "," &_
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean("1","N","S") & "," &_
				SQLClean("0","N","S") & ",0,0)"
				connAdm.execute(strQuery)

				Set nRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM notebooks WHERE id="&SQLClean(notebookId,"N","S")
				nRec.open strQuery,connAdm,3,3
				If Not nRec.eof Then
					notebookName = nRec("name")
				End if
				title = "Notebook Share Invitation"
				note = "User "&session("firstName") &" "& session("lastName")& " has invited you to share <a href="""&mainAppPath&"/show-notebook.asp?id="&notebookId&""">"&notebookName&"</a>"

				a = sendNotification(session("userId"),title,note,2)
			End If
			If CStr(newUserId) = CStr(session("userId")) Then
				'if transferring ownership to self, remove invitations
				strQuery = "DELETE FROM notebookInvites WHERE notebookId="&SQLClean(notebookId,"N","S")& " AND shareeId="&SQLClean(session("userId"),"N","S")
				connAdm.execute(strQuery)
			End If
			Call disconnectAdm
		End if
	End If
	rec.close
	Set rec = nothing
End if
%>