<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'save analysis experiment%>
<%Response.Buffer=False%>
<%Server.scriptTimeout = 6000%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->
<!-- #include virtual="/arxlab/_inclds/database/functions/fnc_callStoredProcedure.asp"-->
<%
'get form JSON object (all form data is set in one JSON object with the form names as the keys)
experimentJSON = request.form("hiddenExperimentJSON")
Set experimentJSON = JSON.parse(experimentJSON)

experimentId = experimentJSON.get("experimentId")
experimentType = "4"
notebookId = experimentJSON.get("notebookId")

If session("requireProjectLink") Then
	'return error if no project is linked and project link is required
	%><!-- #include file="../_inclds/experiments/common/asp/requireProjectLink.asp"--><%
End if

Call getconnectedadmTrans
'start transaction
connAdmTrans.beginTrans

'if the hungsaveSerial is already in the ACK table don't continue
'because the experiment is already in the process of saving
hungSaveSerial = experimentJSON.get("hungSaveSerial")

' if the hungsaveSerial is already in the ACK table don't continue
' because the experiment is already in the process of saving
' note that cleanSerial var is defined in this file
%><!-- #include file="../_inclds/experiments/common/asp/checkHungSaveSerial.asp"--><%

'insert hungSaveSerial into ACK table
connAdmTrans.execute("INSERT INTO serialsAck(serial) values("&SQLClean(hungSaveSerial,"T","S")&")")

'redirect to error if user does not own the experiment
If Not ownsExperiment("4",experimentId,session("userId")) Then
	response.Status = "500 Internal Server Error"
	response.redirect(mainAppPath&"/static/notAuthorized.asp")
End If

'prevent saving of previous revisions
If experimentJSON.get("thisRevisionNumber") <> "" then
	maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
	If CInt(maxRevisionNumber) <> CInt(experimentJSON.get("thisRevisionNumber"))Then
		response.Status = "403 There is a newer version of this experiment. Changes will not be saved."
		response.end()
	End if
End If

		Call getconnected


		Set rs = Server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT statusId FROM analExperiments WHERE id="&SQLClean(experimentId,"N","S")
		rs.open strQuery,conn,3,3
		newStatusId = "2"
		experimentType = "4"
		%>
		<!-- #include file="../_inclds/experiments/common/asp/signValidate.asp"-->
		<%
		rs.close
		Set rs = Nothing

		'set new revision number
		Set rs = Server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM analExperiments_history WHERE experimentId="&SQLClean(experimentId,"N","S")
		rs.open strQuery,conn,3,3
		revisionNumber = rs.recordCount + 1
		rs.close
		Set rs = Nothing

		'!!!!!!!!!!!!!!! CALL STORED PROCEDURE !!!!!!!!!!!!!!!!!!!!
		Set args = JSON.parse("{}")
		Call addStoredProcedureArgument(args, "companyId", adBigInt, SQLClean(session("companyId"),"N","S"))
		Call addStoredProcedureArgument(args, "userId", adBigInt, SQLClean(session("userId"),"N","S"))
		Call addStoredProcedureArgument(args, "projectId", adBigInt, SQLClean(0,"N","N"))
		Call addStoredProcedureArgument(args, "experimentId", adBigInt, SQLClean(experimentId,"N","S"))
		Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
		Call addStoredProcedureArgument(args, "notebookId", adBigInt, SQLClean(notebookId,"N","N"))
		Call addStoredProcedureArgument(args, "statusId", adInteger, SQLClean(newStatusId,"N","N"))
		Call addStoredProcedureArgument(args, "experimentName", adVarChar, SQLClean(experimentJSON.get("e_name"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "experimentDescription", adVarChar, SQLClean(experimentJSON.get("e_details"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "numSigFigs", adInteger, 0)
		Call addStoredProcedureArgument(args, "protocol", adLongVarChar, SQLClean(experimentJSON.get("e_protocol"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "summary", adLongVarChar, SQLClean(experimentJSON.get("e_summary"),"T-PROC","S"))
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
		Call addStoredProcedureArgument(args, "requestId", adBigInt, SQLClean(requestId, "N", "S"))
		Call addStoredProcedureArgument(args, "requestRevisionNumber", adBigInt, SQLClean(workflowRevisionId, "N", "S"))
		Call addStoredProcedureArgument(args, "requestTypeId", adBigInt, SQLClean(requestTypeId, "N", "S"))
		Call addStoredProcedureArgument(args, "mrvData", adLongVarWChar, "")

		If session("canChangeExperimentNames") Then
			Call addStoredProcedureArgument(args, "userExperimentName", adVarChar, SQLClean(experimentJSON.get("e_userAddedName"),"T-PROC","S"))
		End If

		confirmExperimentId = callStoredProcedure("elnSaveExperiment", args, True)
		a = logAction(6,experimentId,"",3)
		
		'!!!!!!!!!!!!!!! BEGIN ----- REPLACED BY STORED PROCEDURE !!!!!!!!!!!!!!!!!!!!
		
		''update experiment table data for experiment
		'strQuery = "UPDATE analExperiments SET " &_
		'			"statusId="&SQLClean(newStatusId,"T","S") & "," &_
		'			"details="&SQLClean(experimentJSON.get("e_details"),"T","S") & "," &_
		'			"protocol="&SQLClean(experimentJSON.get("e_protocol"),"T","S") & "," &_
		'			"summary="&SQLClean(experimentJSON.get("e_summary"),"T","S") & "," &_
		'			"revisionNumber="&SQLClean(revisionNumber,"N","S") & ","
		'			If session("canChangeExperimentNames") Then
		'				strQuery = strQuery & "userExperimentName="&SQLClean(experimentJSON.get("e_userAddedName"),"T","S") & ","
		'			End if
		'			strQuery = strQuery & "dateUpdated=GETUTCDATE(),dateUpdatedServer=GETDATE(),beenExported=0 WHERE id=" & SQLClean(experimentId,"N","S")
		'Set rs = connAdmTrans.execute(strQuery)
		
		''transfer updated experiment row ro history table
		'Set rec = server.CreateObject("ADODB.RecordSet")
		'strQuery = "SELECT * from analExperiments WHERE id="&SQLClean(experimentId,"N","S")
		'rec.open strQuery,connAdmTrans,3,3
		'If Not rec.eof Then
		'	strQuery = "SET NOCOUNT ON;INSERT into analExperiments_history(notebookId,name,details,experimentId,statusId,protocol,summary,userId,dateSubmitted,dateSubmittedServer,action,userExperimentName,revisionNumber) values(" &_
		'				SQLClean(rec("notebookId"),"N","S") & "," &_
		'				SQLClean(rec("name"),"T","S") & "," &_
		'				SQLClean(rec("details"),"T","S") & "," &_
		'				SQLClean(experimentId,"N","S") & "," &_
		'				SQLClean(newStatusId,"N","S") & "," &_
		'				SQLClean(rec("protocol"),"T","S") & "," &_
		'				SQLClean(rec("summary"),"T","S") & "," &_
		'				SQLClean(rec("userId"),"N","S") & ",GETUTCDATE(),GETDATE()," &_
		'				SQLClean("saved","T","S")& "," &_
		'				SQLClean(rec("userExperimentName"),"T","S") & "," &_
		'				SQLClean(revisionNumber,"N","S") & ");SELECT @@IDENTITY AS newId"
		'	Set rs = connAdmTrans.execute(strQuery)
		'	revisionId = CStr(rs("newId"))
		'	rs.close
		'	Set rs = Nothing

		'	'log experiment save
		'	a = logAction(6,experimentId,"",3)
		'End If
		'rec.close
		'Set rec = nothing
		'!!!!!!!!!!!!!!! END ----- REPLACED BY STORED PROCEDURE !!!!!!!!!!!!!!!!!!!!

	'copy experiment links from current experiment links into the experiment links history
	Set lRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experimentLinks WHERE experimentType=4 and experimentId="&SQLClean(experimentId,"N","S")
	lRec.open strQuery,connAdmTrans,3,3
	Do While Not lRec.eof
		strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,prev,next,comments,revisionNumber) values(" &_
		SQLClean(lRec("experimentType"),"N","S") & "," &_
		SQLClean(lRec("experimentId"),"N","S") & "," &_
		SQLClean(lRec("linkExperimentType"),"N","S") & "," &_
		SQLClean(lRec("linkExperimentId"),"N","S") & "," &_
		SQLClean(lRec("prev"),"N","S") & "," &_
		SQLClean(lRec("next"),"N","S") & "," &_
		SQLClean(lRec("comments"),"T","S") & "," &_
		SQLClean(revisionNumber,"N","S") &")"
		connAdmTrans.execute(strQuery)
		lRec.movenext
	Loop
	lRec.close
	Set lRec = Nothing

	'take reg links from presave table and put them in the current reg links table
	Set lRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experimentRegLinks_preSave WHERE experimentType=4 and experimentId="&SQLClean(experimentId,"N","S")
	lRec.open strQuery,connAdmTrans,3,3
	Do While Not lRec.eof
		strQuery = "INSERT into experimentRegLinks(experimentType,experimentId,regNumber,displayRegNumber) values(" &_
		SQLClean(lRec("experimentType"),"N","S") & "," &_
		SQLClean(lRec("experimentId"),"N","S") & "," &_
		SQLClean(lRec("regNumber"),"T","S") & "," &_
		SQLClean(lRec("displayRegNumber"),"T","S") & ")"
		connAdmTrans.execute(strQuery)
		lRec.movenext
	Loop
	lRec.close

	'copy reg links from current reg links table to experiment reg links history
	strQuery = "SELECT * FROM experimentRegLinks WHERE experimentType=4 and experimentId="&SQLClean(experimentId,"N","S")
	lRec.open strQuery,connAdmTrans,3,3
	Do While Not lRec.eof
		strQuery = "INSERT into experimentRegLinks_history(experimentType,experimentId,regNumber,displayRegNumber,revisionNumber,comments) values(" &_
		SQLClean(lRec("experimentType"),"N","S") & "," &_
		SQLClean(lRec("experimentId"),"N","S") & "," &_
		SQLClean(lRec("regNumber"),"T","S") & "," &_
		SQLClean(lRec("displayRegNumber"),"T","S") & "," &_
		SQLClean(revisionNumber,"N","S") & "," &_
		SQLClean(lRec("comments"),"T","S") &")"
		connAdmTrans.execute(strQuery)
		lRec.movenext
	Loop
	lRec.close
	Set lRec = Nothing

	'delete presave reg links
	connAdmTrans.execute("DELETE FROM experimentRegLinks_preSave WHERE experimentType=4 AND experimentId="&SQLClean(experimentId,"N","S"))

	%>
	<!-- #include file="../_inclds/experiments/common/asp/saveAttachments.asp"-->
	<!-- #include file="../_inclds/experiments/common/asp/saveNotes.asp"-->
	<%
	'set experiment unsaved changes to false
	strQuery = "UPDATE analExperiments SET unsavedChanges=0 WHERE id="&SQLClean(experimentId,"N","S")
	connAdmTrans.execute(strQuery)

	'delete experiment draft
	strQuery = "DELETE FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	connAdmTrans.execute(strQuery)

	'commit transaction
	connAdmTrans.commitTrans

	'if experiment is signed send JSON object to inbox to make the PDF
	If newStatusId = "5" then
		a = savePDF("4",experimentId,revisionNumber,true,false,false)
		a = logAction(3,experimentId,"",7)
	End if
	experimentType = "4"

	'send experiment saved notifications
	%><!-- #include file="../_inclds/experiments/common/asp/experimentSavedNotifications.asp"--><%

	If experimentId <> "" Then
		session("justSaved")=true
		%>
			<!-- #include file="../_inclds/experiments/common/asp/getExperimentPermissions.asp"-->
		<%
		Set d = JSON.parse("{}")
		d.Set "hungSaveSerial", hungSaveSerial
		d.Set "revisionNumber", revisionNumber
		data = JSON.stringify(d)
		
		%><!-- #include file="../_inclds/experiments/common/asp/updateHungSaveSerial.asp"--><%

		Response.Status = "200"
		response.write(data)
	else
		Response.Status = "500 Internal Server Error"
		response.write("ERROR")
	End if
	response.end
%>