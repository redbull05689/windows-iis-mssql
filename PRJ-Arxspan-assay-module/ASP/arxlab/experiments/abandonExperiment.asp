<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%witnessArea = true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_addSigners.asp"-->
<!-- #include file="../_inclds/backup_and_pdf/functions/fnc_savePDF.asp"-->
<!-- #include file="../_inclds/backup_and_pdf/functions/fnc_addSignature.asp"-->


<%

function getOtherPDFInfo(experimentId,experimentType,witnessName)
	'get additional pdf info for pythonD
	'these are items needed to draw header and footer options e.g. status, experimentName, ownerName, witnessName
	
	'get the correct table based on experiment type
	prefix = GetPrefix(experimentType)
	tableName = GetExperimentView(prefix)

	'select the experiment
	Set expRec = server.CreateObject("ADODB.recordSet")
	strQuery = "SELECT name, firstName, lastName, status FROM "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
	expRec.open strQuery,connAdm,0,-1
	'build python object
	str = ""
	'add experiment name
	str = str & ",'experimentName' : '" & pEscape(expRec("name")) & "'"

	'add header options
	If pdfHeaderOptions <> "" Then
		str = str & ",'headerOptions':"&pdfHeaderOptions
	Else
		str = str & ",'headerOptions':[]"
	End if

	'add footer options
	If pdfFooterOptions <> "" Then
		str = str & ",'footerOptions':"&pdfFooterOptions
	Else
		str = str & ",'footerOptions':[]"
	End If
	
	'add addtional footer options
	If pdfFooterOptionsRight <> "" Then
		str = str & ",'footerOptionsRight':"&pdfFooterOptionsRight
	Else
		str = str & ",'footerOptionsRight':[]"
	End If
	
	'add experiment ownerName, signer name, witness name and experiment status
	str = str & ",'ownerName':'"&pEscape(expRec("firstName")&" "&expRec("lastName"))&"'"
	str = str & ",'signerName':'"&pEscape(expRec("firstName")&" "&expRec("lastName"))&"'"
	str = str & ",'witnessName':'"&pEscape(witnessName)&"'"
	str = str & ",'experimentStatus':'"&pEscape(expRec("status"))&"'"
	expRec.close
	Set expRec = nothing
	getOtherPDFInfo = str
end function

function addWitnessSigAndMakePDF(experimentId, experimentType, newStatusId, oldRevisionNumber)

    Call getconnectedadm

    'update witness request to accepted
    strQuery = "UPDATE witnessRequests SET accepted=1,dateWitnessed=GETUTCDATE(),dateWitnessedServer=GETDATE() WHERE requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S") & " AND experimentTypeId="&SQLClean(experimentType,"N","S")
    connAdm.execute(strQuery)

	'build html for witness table
	signTable = "<table width='250'>"
	signTable = signTable & "<tr><td style='font-weight:bold;font-size:18px;' colspan='2'>Witness Information</td></tr>"
	signTable = signTable & "<tr><td style='font-weight:bold;'>Name</td><td>"&session("firstName") & " " & session("lastName")&"</td></tr>"
	signTable = signTable & "<tr><td style='font-weight:bold;'>User Id</td><td>"&session("userId")&"</td></tr>"
	signTable = signTable & "<tr><td style='font-weight:bold;'>Email</td><td>"&session("email")&"</td></tr>"
	signTable = signTable & "<tr><td style='font-weight:bold;'>Date Witnessed</td><td>"&theDate&"</td></tr>"
	signTable = signTable & "</table>"

	pythonD = "{'signTable' : '"&Replace(signTable,"'","\'")&"'"&getOtherPDFInfo(experimentId,experimentType,session("firstName") & " " & session("lastName"))&"}"
    
    abbrv = GetAbbreviation(experimentType)
    prefix = GetPrefix(experimentType)
    tableName = GetFullName(prefix, "experiments", true)

	'get information from database to send witness file to inbox and send the file
	Set uRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT userId, name FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S")
	uRec.open strQuery,connAdm,3,3
	userId = uRec("userId")
	experimentName = uRec("name")
	If (newStatusId = "6" or newStatusId = "11") and oldRevisionNumber <> "0" then
		'Create a record in the pdfProcQueue table for the witness report		
		strQuery = "INSERT INTO [pdfProcQueue] (serverName, companyId, userId, experimentId, revisionNumber, experimentType, fileType, jsonBODY, dateCreated, status) VALUES (" & SQLClean(whichServer,"T","S") & ", " & SQLClean(getCompanyIdByUser(userId),"N","S") & ", " &SQLClean(userId,"N","S") & ", " & SQLClean(experimentId,"N","S") & ", " & SQLClean(oldRevisionNumber,"N","S") & ", " & SQLClean(abbrv, "T", "S") &  ", " &	SQLClean("witness","T","S") & ", " &	SQLClean(pythonD,"T","S") & ", SYSDATETIME(), 'NEW')" 
		connAdm.execute(strQuery)
	End If
    uRec.close
end function 



' get form data into vars
experimentJSON = request.Form("hiddenExperimentJSON")
Set experimentJSON = JSON.parse(experimentJSON)
experimentType = experimentJSON.get("experimentType")
experimentId = experimentJSON.get("experimentId")
reason = experimentJSON.get("reason")
' check user login
%>
<!-- #include file="../_inclds/experiments/common/asp/signValidate.asp"-->
<%

' check if we are fully abandoning or pending 
abandonmentType = experimentJSON.get("abandonmentType")
if abandonmentType = "full" or abandonmentType = "witness" then 
    newStatusId = 11
else 
    newStatusId = 10
end if 

' set status accordingly
previousRevNum = duplicateAndChangeStatus(experimentType, experimentId, newStatusId, true)

' add signer for pdf
if previousRevNum <> "0" then
    if (abandonmentType = "witness") then 
        call addWitnessSigAndMakePDF(experimentId, experimentType, newStatusId, previousRevNum)
    else    
        call addSigners(experimentId, experimentType, previousRevNum + 1, session("userId"))
        call addSignature(experimentId, experimentType, previousRevNum + 1, session("userId"))
    end if 
    call addNoteToExperiment(experimentType,experimentId,"Experiment Not Pursued",reason,true)
end if

' get witness id
userId = experimentJSON.get("requesteeId")

' request witness and send notification
if userId > 0 then
    ' build experiment link notification for witness
    ' get global and session data
    elnWebsiteUrl = getCompanySpecificSingleAppConfigSetting("elnWebsiteUrl", session("companyId"))
    prefix = GetPrefix(experimentType)
    expPage = GetExperimentPage(prefix)
    title = "Experiment Not Pursued"
    notifMsg = "User "&session("firstName") & " " & session("lastName") & " has requested you as a witness of an experiment that is no longer Pursued. <a href='" & elnWebsiteUrl & mainAppPath & "/" & expPage & "?id=" & experimentId & "'>" & expName & "</a>"

    errorText = requestWitness(experimentType, experimentId, userId)
    if errorText = "" then
        ' make call to send notification to selected witness
        ' notification id 18 is "Experiment Abandon Request"
        call sendNotification(userId, title, notifMsg, 18)
    else 
        response.write errorText
        response.end
    end if
    
end if

' respond to ajax
if previousRevNum = "0" then
    response.write "Error"
else 
    response.write "Success"
end if 

%>