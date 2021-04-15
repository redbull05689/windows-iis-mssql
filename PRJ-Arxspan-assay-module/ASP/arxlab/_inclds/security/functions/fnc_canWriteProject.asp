<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function canWriteProject(cProjectId,userId)
	'return true if user can write to project
	userId = CStr(userId)
	If session("role") = "Admin" Or session("role") = "Super Admin" Then
		If CStr(session("companyId")) = getProjectCompanyId(cProjectId)  Or session("companyId")="1"  then
			'if user is an admin then they can write to all projects in their company.
			'if they are an arxspan employee they can write to all projects nxq this is probably unecessary for
			'arxspan employees.
			canWriteProject = True
		End if
	else
		If cProjectId <> "" then
			canWriteProject = False
			Call getconnected
			Set crnRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT id FROM projects WHERE userId="&SQLClean(userId,"N","S") & " AND id="&SQLClean(cProjectId,"N","S")
			crnRec.open strQuery,conn,3,3
			If Not crnRec.eof Then
				'if user owns project then they can write to it
				canWriteProject = True
			Else
				crnRec.close
				'get the top level project id because that is where the permission are on 
				'the tabs are also project with a parentprojectid of the actual project
				strQuery = "SELECT parentProjectId FROM projects WHERE id="&SQLClean(cProjectId,"N","S")
				crnRec.open strQuery,conn,3,3
				If Not crnRec.eof Then
					ppId = crnRec("parentProjectId")
				Else 
					ppId = 0
				End If
				If IsNull(ppId) Then
					ppId = 0
				End if
				crnRec.close
				strQuery = "SELECT id FROM projectInvites WHERE (projectId="&SQLClean(cProjectId,"N","S") & " or projectId="&SQLClean(ppId,"N","S")&")AND shareeId=" & SQLClean(userId,"N","S") & " AND canWrite=1"
				crnRec.open strQuery,conn,3,3
				If Not crnRec.eof Then
					'if there is a write user share for the project then the user can write the project
					canWriteProject = True
				Else
					Set cgRec = server.CreateObject("ADODB.RecordSet")
					If IsNull(ppId) Or ppId = 0 then
						strQuery = "SELECT id FROM groupProjectPermView WHERE projectId="&SQLClean(cProjectId,"N","S") & " AND canWrite=1 and userId=" & SQLClean(userId,"N","S")
					Else
						strQuery = "SELECT id FROM groupProjectPermView WHERE projectId="&SQLClean(ppId,"N","S") & " AND canWrite=1 and userId=" & SQLClean(userId,"N","S")
					End If
					cgRec.open strQuery,conn,3,3
					If Not cgRec.eof Then
						'if the project is write shared with a group that the user is a member of the user can write the project
						canWriteProject = True
					End if
					cgRec.close
					Set cgRec = nothing
				End if
			End if
		Else
			canWriteProject = False
		End If
	End if
	If session("userId") = "2" Then
		'josh can write all projects nxq unnecessary probably
		canWriteProject = True
	End if
end Function
%>