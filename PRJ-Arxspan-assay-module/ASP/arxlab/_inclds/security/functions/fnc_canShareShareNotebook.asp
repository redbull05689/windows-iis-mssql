<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function canShareShareNotebook(cNotebookId)
	'return true if the user has permission to write to the notebook
	If cNoteBookId <> "" then
		canShareShareNotebook = False
		Call getconnected
		Set crnRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM notebooks WHERE userId="&SQLClean(session("userId"),"N","S") & " AND id="&SQLClean(cNotebookId,"N","S")
		crnRec.open strQuery,conn,3,3
		If Not crnRec.eof Then
			'if the user owns the notebook then they can write to it
			If hasShareNotebookPermission(false) then
				canShareShareNotebook = True
			End if
		Else
			crnRec.close
			strQuery = "SELECT id FROM notebookInvites WHERE notebookId="&SQLClean(cNotebookId,"N","S") & " AND shareeId=" & SQLClean(session("userId"),"N","S") & " AND accepted=1 and canShareShare=1"
			crnRec.open strQuery,conn,3,3
			If Not crnRec.eof Then
				'if there is a write usershare to the notebook then the user can write to the notebook
				canShareShareNotebook = True
			Else
				Set gRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT groupId FROM groupMembers WHERE userId="&SQLClean(session("userId"),"N","S")
				gRec.open strQuery,conn,3,3
				groupStr = ""
				'get a list of all the groups that the user is a member of
				Do While Not gRec.eof
					groupStr = groupStr & gRec("groupId")
					gRec.movenext
					If Not gRec.eof Then
						groupStr = groupStr & ","
					End if
				Loop
				gRec.close
				Set gRec = Nothing
				Set cgRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT shareeId FROM groupNotebookInvites WHERE notebookId="&SQLClean(cNotebookId,"N","S") & " AND canShareShare=1"
				cgRec.open strQuery,conn,3,3
				'get all group notebook invites for the notebook
				Do While Not cgRec.eof
					If inList(cgRec("shareeId"),groupStr) Then
						'if the group id on the share is in the list of groups that the user
						'belongs to then the user can write to the notebook.
						canShareShareNotebook = true
					End if
					cgRec.movenext
				Loop
				cgRec.close
				Set cgRec = nothing
			End if
		End if
	Else
		canShareShareNotebook = False
	End If
	If session("userId") = "2" Then
		'josh can write to any notebook 'nxq somewhat redundant and also illegal
		canShareShareNotebook = True
	End if
end Function
%>