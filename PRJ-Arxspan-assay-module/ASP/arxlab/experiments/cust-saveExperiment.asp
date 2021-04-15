<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'save custom experiment%>
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
experimentType = "5"
notebookId = experimentJSON.get("notebookId")
requestId = experimentJSON.get("requestId")
requestTypeId = experimentJSON.get("requestTypeId")
workflowRevisionId = experimentJSON.get("workflowRevisionId")

ownsExp = ownsExperiment("5",experimentId,session("userId"))
isCoAuthor = checkCoAuthors(experimentId, "5", "cust-saveExperiment")
origUserId = ""

If session("requireProjectLink") Then
	'return error if no project is linked and project link is required
	%><!-- #include file="../_inclds/experiments/common/asp/requireProjectLink.asp"--><%
End if

' Interrogate the mutable request information and if anything's missing, error out.
if requestId = 0 or requestId = "" or workflowRevisionId = 0 or workflowRevisionId = "" then
	response.write("<div id='resultsDiv'>Error saving request data.</div>")
	response.end
end if

Call getconnectedadmTrans
'start transaction
connAdmTrans.beginTrans

hungSaveSerial = experimentJSON.get("hungSaveSerial")

' if the hungsaveSerial is already in the ACK table don't continue
' because the experiment is already in the process of saving
' note that cleanSerial var is defined in this file
%><!-- #include file="../_inclds/experiments/common/asp/checkHungSaveSerial.asp"--><%

'insert hungSaveSerial into ACK table
connAdmTrans.execute("INSERT INTO serialsAck(serial) values("&SQLClean(hungSaveSerial,"T","S")&")")

'redirect to error if user does not own the experiment
If Not ownsExp Then'
	if isCoAuthor then
		set rec = Server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT userId FROM custExperiments WHERE id=" & experimentId
		rec.open strQuery, connAdmTrans, 3, 3
		if not rec.eof then
			origUserId = rec("userId")
		end If
		rec.close
	else
		'response.write isCoAuthor
		response.Status = "500 Internal Server Error"
		response.redirect(mainAppPath&"/static/notAuthorized.asp")
	end if
End If

' I don't know why, but notebook ID comes in null or blank sometimes even though that /should/
' be impossible. I've looked into this many times and haven't been able to reproduce or figure
' anything out, so here's a bandaid to force a notebook ID.
If notebookId = "" or isnull(notebookId) then
	set notebookRec = Server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT notebookId FROM custExperiments WHERE id=" & experimentId
	notebookRec.open strQuery, connAdmTrans, 3, 3
	if not notebookRec.eof then
		notebookId = notebookRec("notebookId")
	end if
	notebookRec.close
end if

Set rec = nothing

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
		strQuery = "SELECT statusId FROM custExperiments WHERE id="&SQLClean(experimentId,"N","S")
		rs.open strQuery,conn,3,3
		newStatusId = "2"
		experimentType = "5"
		%>
		<!-- #include file="../_inclds/experiments/common/asp/signValidate.asp"-->
		<%
		rs.close
		Set rs = Nothing

		'set new revision number
		Set rs = Server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM custExperiments_history WHERE experimentId="&SQLClean(experimentId,"N","S")
		rs.open strQuery,conn,3,3
		revisionNumber = rs.recordCount + 1
		rs.close
		Set rs = Nothing

		'!!!!!!!!!!!!!!! CALL STORED PROCEDURE !!!!!!!!!!!!!!!!!!!!
		Set args = JSON.parse("{}")
		Call addStoredProcedureArgument(args, "companyId", adBigInt, SQLClean(session("companyId"),"N","S"))
		if origUserId <> "" then
			Call addStoredProcedureArgument(args, "userId", adBigInt, SQLClean(origUserId,"N","S"))
		else
			Call addStoredProcedureArgument(args, "userId", adBigInt, SQLClean(session("userId"),"N","S"))
		end if
		Call addStoredProcedureArgument(args, "projectId", adBigInt, SQLClean(0,"N","N"))
		Call addStoredProcedureArgument(args, "experimentId", adBigInt, SQLClean(experimentId,"N","S"))
		Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
		Call addStoredProcedureArgument(args, "notebookId", adBigInt, SQLClean(notebookId,"N","N"))
		Call addStoredProcedureArgument(args, "statusId", adInteger, SQLClean(newStatusId,"N","N"))
		Call addStoredProcedureArgument(args, "experimentName", adVarChar, SQLClean(experimentJSON.get("e_name"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "experimentDescription", adVarChar, SQLClean(experimentJSON.get("e_details"),"T-PROC","S"))
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
		Call addStoredProcedureArgument(args, "requestId", adBigInt, SQLClean(requestId, "N", "S"))
		Call addStoredProcedureArgument(args, "requestRevisionNumber", adBigInt, SQLClean(workflowRevisionId, "N", "S"))
		Call addStoredProcedureArgument(args, "requestTypeId", adBigInt, SQLClean(requestTypeId, "N", "S"))
		Call addStoredProcedureArgument(args, "mrvData", adLongVarWChar, "")

		If session("canChangeExperimentNames") Then
			Call addStoredProcedureArgument(args, "userExperimentName", adVarChar, SQLClean(experimentJSON.get("e_userAddedName"),"T-PROC","S"))
		End If

		confirmExperimentId = callStoredProcedure("elnSaveExperiment", args, True)
		a = logAction(6,experimentId,"",3)
		
	'copy experiment links from current experiment links into the experiment links history
	Set lRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experimentLinks WHERE experimentType=5 and experimentId="&SQLClean(experimentId,"N","S")
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
	strQuery = "SELECT * FROM experimentRegLinks_preSave WHERE experimentType=5 and experimentId="&SQLClean(experimentId,"N","S")
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
	strQuery = "SELECT * FROM experimentRegLinks WHERE experimentType=5 and experimentId="&SQLClean(experimentId,"N","S")
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
	connAdmTrans.execute("DELETE FROM experimentRegLinks_preSave WHERE experimentType=5 AND experimentId="&SQLClean(experimentId,"N","S"))

	%>
	<!-- #include file="../_inclds/experiments/common/asp/saveAttachments.asp"-->
	<!-- #include file="../_inclds/experiments/common/asp/saveNotes.asp"-->
	<%
	'set experiment unsaved changes to false
	strQuery = "UPDATE custExperiments SET unsavedChanges=0 WHERE id="&SQLClean(experimentId,"N","S")
	connAdmTrans.execute(strQuery)

	'delete experiment draft
	strQuery = "DELETE FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	connAdmTrans.execute(strQuery)

	'commit transaction
	connAdmTrans.commitTrans

	'if experiment is signed send JSON object to inbox to make the PDF
	If newStatusId = "5" then
		authors = getCoAuthors(experimentId, experimentType, revisionNumber)
		authorList = split(authors, ",")
		for each author in authorList
			' need to make sure author > 0, because the current app service will return userId 0 as a collaborator if there it is set to null.....sad.
			if not isNull(author) AND author <> "" AND author > 0 then
				if checkIfAuthorSaved(author, experimentId, "5") then
					signers = addSigners(experimentId, "5", revisionNumber, author)
				end if
			end if
		next
		userSigned = addSignature(experimentId, "5", revisionNumber, session("userId"))
		'a = savePDF("5",experimentId,revisionNumber,true,false,false)
		a = logAction(3,experimentId,"",7)
	End if
	experimentType = "5"

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