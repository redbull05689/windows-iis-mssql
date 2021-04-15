<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/database/functions/fnc_callStoredProcedure.asp"-->
<%
Function createExperiment(experimentType,notebookId,projectId,description,requestTypeId)
	'creates a new experiment in the specified notebook
	
	'get the name for the experiment
	nextName = getNextExperimentName(notebookId)
	
	Set args = JSON.parse("{}")
	Call addStoredProcedureArgument(args, "companyId", adBigInt, SQLClean(session("companyId"),"N","S"))
	Call addStoredProcedureArgument(args, "userId", adBigInt, SQLClean(session("userId"),"N","S"))
	Call addStoredProcedureArgument(args, "projectId", adBigInt, SQLClean(projectId,"N","N"))
	Call addStoredProcedureArgument(args, "experimentId", adBigInt, 0)
	Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
	Call addStoredProcedureArgument(args, "notebookId", adBigInt, SQLClean(notebookId,"N","S"))
	Call addStoredProcedureArgument(args, "statusId", adInteger, 1)
	Call addStoredProcedureArgument(args, "experimentName", adVarChar, SQLClean(nextName,"T-PROC","S"))
	Call addStoredProcedureArgument(args, "experimentDescription", adVarChar, SQLClean(description,"T-PROC","S"))
	Call addStoredProcedureArgument(args, "numSigFigs", adInteger, 0)
	Call addStoredProcedureArgument(args, "protocol", adLongVarChar, "")
	Call addStoredProcedureArgument(args, "summary", adLongVarChar, "")
	Call addStoredProcedureArgument(args, "conceptDescription", adLongVarChar, "")
	Call addStoredProcedureArgument(args, "userExperimentName", adVarChar, "")
	Call addStoredProcedureArgument(args, "beenExported", adTinyInt, 0)
	Call addStoredProcedureArgument(args, "preparation", adLongVarChar, "")
	Call addStoredProcedureArgument(args, "searchPreparation", adLongVarChar, "")
	Call addStoredProcedureArgument(args, "cdx", adLongVarChar, "")
	Call addStoredProcedureArgument(args, "reactionMolarity", adVarChar, "")
	Call addStoredProcedureArgument(args, "pressure", adVarChar, "")
	Call addStoredProcedureArgument(args, "temperature", adVarChar, "")
	Call addStoredProcedureArgument(args, "molData", adLongVarChar, "")
	Call addStoredProcedureArgument(args, "craisStatus", adInteger, 0)
	Call addStoredProcedureArgument(args, "resultSD", adLongVarChar, "")
	Call addStoredProcedureArgument(args, "visible", adTinyInt, 1)
	Call addStoredProcedureArgument(args, "requestId", adBigInt, SQLClean(0, "N", "S"))
	Call addStoredProcedureArgument(args, "requestRevisionNumber", adBigInt, SQLClean(0, "N", "S"))
	Call addStoredProcedureArgument(args, "requestTypeId", adBigInt, SQLClean(requestTypeId, "N", "S"))
	Call addStoredProcedureArgument(args, "mrvData", adLongVarWChar, "")
	
	Call getconnectedadm

	' Chemistry experiments have special processing.
	if experimentType = "1" then
		Call addStoredProcedureArgument(args, "numSigFigs", adInteger, 2)
		If session("companyId") = "4" Then
			Call addStoredProcedureArgument(args, "numSigFigs", adInteger, 4)
		End if
	End if

	createExperiment = callStoredProcedure("elnSaveExperiment", args, False)
End Function
%>