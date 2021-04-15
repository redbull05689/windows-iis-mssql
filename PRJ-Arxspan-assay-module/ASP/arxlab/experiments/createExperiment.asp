<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->
<!-- #include file="../_inclds/notebooks/functions/fnc_getNextExperimentName.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_createExperiment.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_applyChemDrawStyles.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
chemAxonRootUrl = getCompanySpecificSingleAppConfigSetting("chemAxonEndpointUrl", session("companyId"))
blankCdxName = getCompanySpecificSingleAppConfigSetting("blankCdxName", session("companyId"))

'this is a non ajax script that creates an experiment and then redirects the user to the newly created experiment
'querystring is used for the create experiment buttons on the notebooks and the popup window from the new experiment button on the nav
'form parameters are used from the popup window from the next step button on the experiment

'collect querysrting variables
experimentType = request.querystring("experimentType")
notebookId = request.querystring("notebookId")
projectId = request.querystring("projectId")
description = request.querystring("description")
requestTypeId = request.querystring("r")

notebookPageLimit = getCompanySpecificSingleAppConfigSetting("notebookPageLimit", session("companyId"))
notebookPageLimit = normalizeIntSetting(notebookPageLimit)

If experimentType = "" Then
	'this means it is a post
	'get form params
	originalExperimentId = request.Form("originalExperimentId")
	originalExperimentType = request.Form("originalExperimentType")
	experimentType = request.form("newExperimentType")
	projectId = request.form("linkProjectId")
	description = request.form("newExperimentDescription")
	originalRevisionNumber = request.Form("originalRevisionNumber")
	requestTypeId = request.Form("nextStepRequestTypeId")
	'variable to set halfsise canvas for next step reaction
	half = False
	
	'set next step flag
	If request.Form("isNextStep") <> "" Then
		isNextStep = true
		notebookId = request.form("nextStepExperimentNotebookId")
	Else
		notebookId = request.form("newExperimentNotebookId")
	End If

	If experimentType = "1" Then
		'if we are making a chemistry experiment and the company has a chemistry template, use inventory to apply the template
		rxn = ""
		If isNextStep Then
			rxn = session("nextStepRxn")
			session("nextStepRxn") = ""
			half=True
		Else
			rxn = request.Form("rxn")
		End If
		
		If blankCdxName <> "blank.cdx" Then
			'if we don't have a services/inventory connection, get one
			templateRxn = applyStylesHalf(rxn, blankCdxName, "", half)
			If templateRxn <> "" Then
				rxn = templateRxn
			End If
		End If
		
		'prevent experiment from being created as a next step if the company has crais
		'and the crais check has not been passed
		' If session("hasCrais") And experimentType="1" Then
		' 	Call getconnected
		' 	Set rec = server.CreateObject("ADODB.RecordSet")
		' 	strQuery = "SELECT craisStatus FROM experiments WHERE id="&SQLClean(originalExperimentId,"N","S")
		' 	rec.open strQuery,conn,0,-1
		' 	If Not rec.eof Then
		' 		If rec("craisStatus")=3 Or rec("craisStatus")=0 Then
		' 			title = "General Error"
		' 			message = "Experiment cannot be continued without passing regulatory check."
		' 			response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
		' 		End if
		' 	End If
		' 	rec.close
		' 	Set rec = nothing
		' End if
	End if
End if

'return error if the user is trying to create a chemistry experiment an chemistry is not enabled
If experimentType = "1" then
	If Not session("hasChemistry") then
		title = "General Error"
		message = "Chemistry functionality is not enabled."
		response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
	End if
End if

'return error if the limit for the number of experiments has been reached in the destination notebook
passesLimitTest = true
If notebookPageLimit <> 0 Then
	If getNextExperimentNumber(notebookId, False) >= notebookPageLimit Then
		passesLimitTest = False
		title = "Create Experiment Error"
		message = "The maximum limit of " & notebookPageLimit & " pages for this notebook has been reached. Please create a new notebook."
		response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
	End if
End If

'experiment can be created if the user has write access to the destination notebook, the notebook is not full, and the notebook has not been deleted
If canWriteNotebook(notebookId) And isNotebookVisible(notebookId) And passesLimitTest then
	'create the new experiment and get the new wxperiment id. log experiment creation.
	'also generate the link for the new experiment
	
	Select Case experimentType
		Case "1"
			logActionId = 2
		Case "2"
			logActionId = 3
		Case "3"
			logActionId = 4
		Case "4"
			logActionId = 4
		Case "5"
			logActionId = 4
	End Select
	
	prefix = GetPrefix(experimentType)
	page = GetExperimentPage(prefix)
	experimentId = createExperiment(experimentType,notebookId,projectId,description,requestTypeId)
	page = page & "?id=" & experimentId
	if requestTypeId <> "" then
		page = page & "&r=" & requestTypeId
	end if
	a = logAction(logActionId,experimentId,"",1)
	page = mainAppPath & "/" & page

	'make the latest updated notebook default
	usrTbl = getDefaultSingleAppConfigSetting("usersTable")
	If usrTbl <> "" Then
		nbuQuery = "UPDATE "&usrTbl&" SET defaultNotebookId="&SQLClean(notebookId,"N","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(nbuQuery)
	End If
	session("defaultNotebookId") = SQLClean(notebookId,"N","S")

	

	'attach experiment to project if project id has been supplied
	If projectId <> "" Then

		'======================================================
		''make sure user has write access to project
		'If canWriteProject(projectId,session("userId")) then
		'	Call getconnectedAdm
		'	Set tRec = server.CreateObject("ADODB.RecordSet")
		'	strQuery = "SELECT * FROM linksProjectExperiments WHERE experimentType="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")& " AND projectId="&SQLClean(projectId,"N","S")
		'	tRec.open strQuery,connAdm,3,3
		'	If tRec.eof Then
		'		'insert link to experiment into project if the experiment is not already linked to the project
		'		strQuery = "INSERT into linksProjectExperiments(experimentType,experimentId,projectId) values(" &_
		'		SQLClean(experimentType,"N","S") & "," &_
		'		SQLClean(experimentId,"N","S") & "," &_
		'		SQLClean(projectId,"N","S") & ")"
		'		connAdm.execute(strQuery)
		'	End If
		'	tRec.close
		'	Set tRec = Nothing
		'	Call disconnectadm
		'End If
		'======================================================
		
		'''10/11/2016 - fix similar to ELN-604
		Call getConnectedAdm
		errorText = addExperimentToProject(connAdm, experimentType, experimentId, projectId, null, null)
		Call disconnectAdm
		If errorText = "" Then
			response.write("success")
		Else 
			response.write(errorText)
		End If 
		
	End If

	'if this is a next step we need to create the backlinks for the next step
	'if this is a next step and chemistry we need to send a file to the inbox for chemistry processing
	If isNextStep = True then
		Call getconnectedadm
		If originalExperimentType = "1" and experimentType = "1" then
			'!!!!!!!!!!!!!!! CALL STORED PROCEDURE !!!!!!!!!!!!!!!!!!!!
			Set args = JSON.parse("{}")
			Call addStoredProcedureArgument(args, "experimentId", adBigInt, SQLClean(experimentId,"N","S"))
			Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
			Call addStoredProcedureArgument(args, "cdx", adLongVarChar, SQLClean(replace(rxn,"\\""","\"""),"T-PROC","S"))
			Call addStoredProcedureArgument(args, "statusId", adInteger, SQLClean(2,"N","N"))
			revisionNumber = callStoredProcedure("elnUpdateExperimentCdx", args, True)
		
			'insert into experiment loading so we can determine when Python is done processing
			strQuery = "INSERT into chemDrawProcQueue(serverName, companyId, userId, experimentId, experimentType, revisionNumber, compoundTracking, dataType, processingInstruction, previousStepExperimentId, previousStepExperimentType, previousStepRevisionNumber, dateAdded, status) " &_ 
			" OUTPUT inserted.id AS queueId values("&SQLClean(whichServer,"T","S")&","&SQLClean(session("companyId"),"N","S")&","&SQLClean(session("userId"),"N","S")&","&SQLClean(experimentId,"N","S")&","&SQLClean(1,"N","S")&","&SQLClean(revisionNumber,"N","S")&","&Abs(session("hasCompoundTracking"))&",'cdxml','new'," &_ 
			SQLClean(originalExperimentId,"N","S")&","&SQLClean(originalExperimentType,"N","S")&","&SQLClean(originalRevisionNumber,"N","S")&",GETDATE(),'NEW')"
			Set rs = connAdm.execute(strQuery)
			'get the id of the queue entry
			queueId = CStr(rs("queueId"))

			'wait up to 30 seconds for the processing to complete
			counter = 0
			Do While True And counter < 30
				counter = counter + 1
				sleep = 1
				strQuery = "WAITFOR DELAY '00:00:" & right(clng(sleep),2) & "'" 
				connAdm.Execute strQuery,,129 
				Set bRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT status FROM chemDrawProcQueue WHERE id="&SQLClean(queueId,"N","S")
				bRec.open strQuery,connAdm,3,3
				If bRec.eof Then
					'break
					counter = 10000
				ElseIf bRec("status") = "readyForDisplay" Or bRec("status") = "complete" Then
					'break
					counter = 10000
				End If
				bRec.close
				Set bRec = nothing
			Loop

			' If marvin, make the marvin data file
			If session("useMarvin") Then
				body = "{""structure"": """ + SQLClean(replace(rxn,"""","\"""),"JSON","S") + """,""parameters"": ""mrv""}"

				Set objXmlHttp = Server.CreateObject("Microsoft.XMLHTTP")
				objXmlHttp.open "POST", chemAxonRootUrl & "util/calculate/molExport", false
				objXmlHttp.SetRequestHeader "Content-Type", "application/json"		
				objXmlHttp.send body

				retStr = objXmlHttp.responsetext
				Set responseJson = JSON.parse(retStr)
				If IsObject(responseJson) Then
					If responseJson.Exists("structure") Then
						mrvData = responseJson.Get("structure")
						
						strQuery = "UPDATE experiments SET mrvData = '" &_
						SQLClean(mrvData,"T-PROC","S") & "' WHERE id = " &SQLClean(experimentId,"N","S")
						connAdm.execute(strQuery)
					end if
				end if
			End If
		End if
		'link old experiment to new experiment as previous
		strQuery = "INSERT into experimentLinks(experimentType,experimentId,linkExperimentType,linkExperimentId,prev) values(" &_
		SQLClean(experimentType,"N","S") & "," &_
		SQLClean(experimentId,"N","S") & "," &_
		SQLClean(originalExperimentType,"N","S") & "," &_
		SQLClean(originalExperimentId,"N","S") &",1)"
		connAdm.execute(strQuery)
		strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,prev,revisionNumber) values(" &_
		SQLClean(experimentType,"N","S") & "," &_
		SQLClean(experimentId,"N","S") & "," &_
		SQLClean(originalExperimentType,"N","S") & "," &_
		SQLClean(originalExperimentId,"N","S") &",1,1)"
		connAdm.execute(strQuery)

		'link new experiment to old experiment as next
		strQuery = "INSERT into experimentLinks(experimentType,experimentId,linkExperimentType,linkExperimentId,next) values(" &_
		SQLClean(originalExperimentType,"N","S") & "," &_
		SQLClean(originalExperimentId,"N","S") & "," &_
		SQLClean(experimentType,"N","S") & "," &_
		SQLClean(experimentId,"N","S") &",1)"
		connAdm.execute(strQuery)
		strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,next,revisionNumber) values(" &_
		SQLClean(originalExperimentType,"N","S") & "," &_
		SQLClean(originalExperimentId,"N","S") & "," &_
		SQLClean(experimentType,"N","S") & "," &_
		SQLClean(experimentId,"N","S") &",1,"&_
		SQLClean(revisionNumber,"N","S") & ")"
		connAdm.execute(strQuery)

		Call disconnectadm
	End If
	response.redirect(page)
Else
'return authorization error
%>
<p>You are not authorized to create an experiment in this notebook.</p>
<%
End if
%>