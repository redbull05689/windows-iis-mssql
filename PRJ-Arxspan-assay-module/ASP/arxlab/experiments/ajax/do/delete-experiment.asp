<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->

<%
'deletes an experiment by setting the visible flag of the experiment to 0

'if the user is not an admin of the user does not have canDelete permission
'there will be no way for them to have persmission to delete an experiment
If session("role") = "Admin" Or session("canDelete") Then
	experimentType = request.Form("experimentType")
	experimentId = request.Form("experimentId")
	errStr = ""
	'do error checking for users who do not own the specified experiment
	'users who do own the experiment will not get an error because they are implicitly the experiment owner and have
	'canDelete permission because of proceding if statement
	If Not ownsExperiment(experimentType,experimentId,session("userId")) Then
		'make sure user user has canDelete and is an admin or a super admin
		'redundant because of above, but safe
		If (session("roleNumber") <> "1" And session("roleNumber") <> "0") Or Not session("canDelete") then
			errStr = "You cannot delete this experiment"
		Else
			'make sure that the experiment belongs to the user's company
			Call getconnected
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT id FROM notebookIndexView WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND typeId="&SQLClean(experimentType,"N","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
			rec.open strQuery,conn,3,3
			If rec.eof Then
				errStr = "You cannot delete this experiment"
			End if
			Call disconnect
		End if
	End If

	If errStr = "" then
		Call getconnectedadm
		Call getconnected
		' determine the correct tables to update and set logAction params accordingly.
		prefix = GetPrefix(experimentType)
		expTable = GetFullName(prefix, "experiments", true)
		expHistTable = GetFullName(prefix, "experiments_history", true)
		' No idea what these two things are but they were the same across all experiment types.
		exText = ""
		actId = 2
		Select Case experimentType
			Case "1"
				exType = 2
			Case "2"
				exType = 3
			Case "3"
				exType = 4
			Case "4"
				exType = 3
		End Select

		'set the experiment and experiment history table visible flags to 0 for the specified experiment
		strQuery = "UPDATE " & expTable & " SET visible=0 WHERE id=" & SQLClean(experimentId,"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE " & expHistTable & " SET visible=0 WHERE id=" & SQLClean(experimentId,"N","S")
		connAdm.execute(strQuery)
		a = logAction(exType, experimentId, exText, actId)

		'update both allExperiments tables as well.
		strQuery = "UPDATE allExperiments SET visible=0 WHERE legacyId=" & SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S")
		connAdm.execute(strQuery)
		strQuery = "UPDATE allExperiments_History SET visible=0 WHERE legacyId=" & SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S")
		connAdm.execute(strQuery)

		'update the elasticIndexQueue
		strQuery = "INSERT INTO elasticIndexQueue (experimentId, experimentType, companyId, revisionNumber, dateCreated, status) SELECT DISTINCT legacyId, experimentType, companyId, (SELECT TOP 1 revisionNumber FROM allExperiments a WHERE a.legacyId = h.legacyId AND a.companyId = h.companyId AND a.experimentType = h.experimentType ORDER BY revisionNumber desc) as revisionNumber, GETDATE() as dateCreated, 'NEW' as status FROM allExperiments_history h WHERE h.visible = 0 AND h.legacyId = " & experimentId & " AND h.experimentType = " & experimentType
		connAdm.execute(strQuery)
		
		'update the notebook index visible flag to 0 for the specified experiment
		strQuery = "UPDATE notebookIndex set visible=0 WHERE typeId="&SQLClean(experimentType,"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S")
		connAdm.execute(strQuery)	
	End if

	If errStr = "" Then
		errStr = "success"
	End if
%>
<div id="resultsDiv"><%=errStr%></div>
<%else%>
<div id="resultsDiv">Not Authorized</div>
<%End if%>