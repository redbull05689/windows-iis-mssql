<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function canReadNotebook(cNotebookId,userId)
	canReadNotebook = False
	'return true if user can view the notebook
	userId = CStr(userId)
	If (session("role") = "Admin" Or session("role") = "Super Admin") And CStr(session("userId")) = userId Then
		If CStr(session("companyId")) = getNotebookCompanyId(cNotebookId) Or session("companyId")="1" then
			'if you are an admin you can read any notebook in your company. or if you are a member of arxspan you can see any experiment
			canReadNotebook = True
		End If
	else
		If cNotebookId <> "" then
			canReadNotebook = False
			Call getconnected
			Set crnRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT id FROM notebooks WHERE userId="&SQLClean(userId,"N","S") & " AND id="&SQLClean(cNotebookId,"N","S")
			crnRec.open strQuery,conn,3,3
			If Not crnRec.eof Then
				'if you own the notebook the user read it
				canReadNotebook = True
			Else
				crnRec.close
				strQuery = "SELECT id FROM notebookInvites WHERE notebookId="&SQLClean(cNotebookId,"N","S") & " AND shareeId=" & SQLClean(userId,"N","S") & " AND accepted=1 and canRead=1"
				crnRec.open strQuery,conn,3,3
				If Not crnRec.eof Then
					'if you have accepted a read invitation to this notebook than you 
					'the user read the notebook
					canReadNotebook = True
				Else
					Set cgRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT id FROM groupPermView WHERE notebookId="&SQLClean(cNotebookId,"N","S") & " AND canRead=1 and userId=" & SQLClean(userId,"N","S")
					cgRec.open strQuery,conn,3,3
					If Not cgRec.eof Then
						'if the notebook is readshared with a group that you are a member of
						'the user can read the notebook
						canReadNotebook = True
					Else
						Set cgRec2 = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT id FROM notebookView WHERE id="&SQLClean(cNotebookId,"N","S") & " AND managerId="&SQLClean(userId,"N","S")
						cgRec2.open strQuery,conn,3,3
						If Not cgRec2.eof Then
							canReadNotebook = True
						End If
						cgRec2.close
						Set cgRec2 = nothing
					End if
					cgRec.close
					Set cgRec = nothing
				End if
			End If
			'if the notebook cannot be read by other means see if the notebook is linked to 
			'a project that the user has access to
			If canReadNotebook = False Then
				canReadNotebook = canReadNotebookByProject(cNotebookId,userId)
			End if
		Else
			'if notebook was not provided return false
			canReadNotebook = False
		End If
	End if
end Function
%>