<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If session("userId") <> "" And session("email") <> "" Then
Function canViewExperiment(experimentType,experimentId,userId)
	Dim notebookId
	'returns true if user can view experiment
	If experimentType <> "" then
		If ((session("roleNumber") < 1 And CStr(userId) = CStr(session("userId"))) Or session("userId")="2" Or session("role") = "Admin" Or session("role") = "Super Admin") And cstr(session("userId")) = CStr(userId) Then
			If CStr(session("companyId")) = getExperimentCompanyId(experimentType,experimentId)  Or session("companyId")="1"  then
				'if user is an admin then they can see all experiments in their company.
				'if they are an arxspan employee they can see all experiments
				canViewExperiment = True
			End If
		Else
			'select table for expeiments by experiment type
			prefix = GetPrefix(experimentType)
			experimentTable = GetFullName(prefix, "experiments", true)
			Set cveRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT userId, notebookId, statusId from "&experimentTable&" WHERE id="&SQLClean(experimentId,"N","S")
			cveRec.open strQuery, conn, 0, 1
			If Not cveRec.eof Then
				exUserId = CStr(cveRec("userId"))
				notebookId = CStr(cveRec("notebookId"))
				If exUserId = CStr(userId) Then
					'if user is the owner of the experiment then they can view it
					If canReadNotebook(notebookId,userId) Or (canWriteNotebook(notebookId) And CStr(session("userId")) = CStr(userId)) then
						canViewExperiment = True
					End if
				Else
					'if the user is not the owner of the experiment then the user can view the experiment if the user can read the experiment's notebook
					canViewExperiment = canReadNotebook(notebookId,userId)
				End if
			End if
			cveRec.close
			Set cveRec = Nothing
		End If
		If canViewExperiment = False Then
			Set cgRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT experimentId FROM projectExperimentPermView WHERE experimentId="&SQLClean(experimentId,"N","S")& " AND experimentType="&SQLClean(experimentType,"N","S")&" AND (shareeId=" & SQLClean(userId,"N","S") & " AND canRead=1) OR (experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")&" and groupCanRead=1 and groupShareeId IN (SELECT groupId FROM groupMembers WHERE userId="&SQLClean(userId,"N","S")&"))"
			cgRec.open strQuery,conn,0,1
			If Not cgRec.eof Then
				'nxq dont know if functional but the idea is inheriting permission from a project share
				canViewExperiment = True
			End If
			cgRec.close
			Set cgRec = nothing
		End If
		If canViewExperiment = False Then
			'if user cant view experiment other ways then check to inherit permissions from a project containing a link to this experiment
			canViewExperiment = canViewExperimentByProject(experimentType,experimentId,userId)
		End if
	else
		canViewExperiment = false
	End If
End Function
End If
%>