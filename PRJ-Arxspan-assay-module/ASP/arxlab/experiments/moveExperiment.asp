<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
'moves an experiment

'get querystring parameters
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
newNotebookId = request.querystring("newNotebookId")

'in order to move an experiment the user must be an admin be able to view the experiment and be able to write to the destination notebook
If canViewExperiment(experimentType,experimentId,session("userId")) And canWriteNotebook(newNotebookId) and session("role") = "Admin" then
	Call getconnectedadm
	'change the notebook id for the experiment and the experiment history for the specified experiment type

	prefix = GetPrefix(ExperimentType)
	tableName = GetFullName(prefix, "experiments", true)
	experimentHistoryTable = GetFullName(prefix, "experiments_history", true)

	strQuery = "UPDATE " & tableName & " SET notebookId="&SQLClean(newNotebookId,"N","S")& " WHERE id="&SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE " & experimentHistoryTable & " SET notebookId="&SQLClean(newNotebookId,"N","S")& " WHERE experimentId="&SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "UPDATE allExperiments SET notebookId="&SQLClean(newNotebookId,"N","S")& " WHERE legacyId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & experimentType
	connAdm.execute(strQuery)
	strQuery = "UPDATE allExperiments_history SET notebookId="&SQLClean(newNotebookId,"N","S")& " WHERE legacyId="&SQLClean(experimentId,"N","S") & " AND experimentType=" & experimentType
	connAdm.execute(strQuery)

	'update the notebook id in the notebookindex
	strQuery = "UPDATE notebookIndex SET notebookId="&SQLClean(newNotebookId,"N","S") & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND typeId=" & SQLClean(experimentType,"N","S")
	connAdm.execute(strQuery)

	'make the latest updated notebook default
	usrTbl = getDefaultSingleAppConfigSetting("usersTable")
	If usrTbl <> "" Then
		nbuQuery = "UPDATE "&usrTbl&" SET defaultNotebookId="&SQLClean(newNotebookId,"N","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(nbuQuery)
	End If
	session("defaultNotebookId") = SQLClean(newNotebookId,"N","S")



	'redirect user to the destination notebook
	response.redirect(mainAppPath&"/show-notebook.asp?id="&newNotebookId)
Else
'not authorized error
%>
<p>You are not authorized to copy this experiment to this notebook</p>
<%
End if
%>