<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%witnessArea = true%>
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->


<%
pdfFooterOptions = getCompanySpecificSingleAppConfigSetting("pdfFooterOptions", session("companyId"))
pdfHeaderOptions = getCompanySpecificSingleAppConfigSetting("pdfHeaderOptions", session("companyId"))
pdfFooterOptionsRight = getCompanySpecificSingleAppConfigSetting("pdfFooterOptionsRight", session("companyId"))
'witness experiment
experimentType = request.form("experimentType")
experimentId = request.form("experimentId")

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


Call getconnectedadm

prefix = GetPrefix(experimentType)
tableName = GetFullName(prefix, "experiments", true)
abbrv = GetAbbreviation(experimentType)
page = GetExperimentPage(prefix)

select case experimentType
	Case "1"
		logActionNum = 2
	Case "2"
		logActionNum = 3
	Case "3"
		logActionNum = 4
	Case "4"
		logActionNum = 3
	Case "5"
		logActionNum = 3
end select

'return error if verify checkbox was not checked
If request.Form("verify") <> "on" And request.Form("ssoWitnessVerify") <> "on" Then
	response.write("<div id='resultsDiv'>You must check ""Reviewed"" to continue.</div>")
	response.end
End if

usersTable = getDefaultSingleAppConfigSetting("usersTable")
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT requesterId FROM witnessRequestsView WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentTypeId=" & experimentType & " and requesteeId="&SQLClean(session("userId"),"N","S")
rec.open strQuery,connAdm,3,3
'make sure user has a valid witness request
If Not rec.eof Then
	requesterId = rec("requesterId")

	passedCredentialCheck = False
	If companyUsesSso() And session("isSsoUser") Then
		passedCredentialCheck = True
	Else
		usersTablePasswordField = getDefaultSingleAppConfigSetting("usersTablePasswordField")
		usersView = getDefaultSingleAppConfigSetting("usersView")
		'verify the witnessing user's email and password
		'pw_stuff
		strQuery = "SELECT id FROM "&usersView&" WHERE email="&SQLClean(request.Form("signEmail"),"T","S") & " AND "&usersTablePasswordField&"="&SQLClean(request.Form("password"),"PW","S") & " AND id="&SQLClean(CStr(session("userId")),"N","S")
		rec.close
		rec.open strQuery,connAdm,3,3

		If Not rec.eof Then
			passedCredentialCheck = True
		End If
	End If

	If passedCredentialCheck Then
		'if credentials are correct set status to witnessed status
		newStatusId = "6"
	Else
		'return error for incorrect credentials
		If session("companyId") <> "4" then
			response.write("<div id='resultsDiv'>Invalid email or password</div>")
		else
			response.write("<div id='resultsDiv'>Invalid email or employee id</div>")
		End if
		response.end		
	End If
Else
	'return error for witness request not existing
	response.write("<div id='resultsDiv'>You cannot witness this experiment because you have not been asked to.</div>")
	response.end					
End If
rec.close
Set rec = Nothing
'if there has been no error (we're here) then update the experiment
oldRevisionNumber = duplicateAndChangeStatus(experimentType,experimentId,newStatusId,true)
	'get the witness date
	If session("useGMT") Then
		set timeRec = server.createobject("ADODB.RecordSet")
		strQuery = "SELECT GETUTCDATE() as theDate"
		timeRec.open strQuery,connAdm,0,-1
		theDate = timeRec("theDate")&" (GMT)"
		timeRec.close
		set timeRec = Nothing
	Else
		theDate = Date() & " " & Time() &" (EST)"
	End If

	'build html for witness table
	signTable = "<table width='250'>"
	signTable = signTable & "<tr><td style='font-weight:bold;font-size:18px;' colspan='2'>Witness Information</td></tr>"
	signTable = signTable & "<tr><td style='font-weight:bold;'>Name</td><td>"&session("firstName") & " " & session("lastName")&"</td></tr>"
	signTable = signTable & "<tr><td style='font-weight:bold;'>User Id</td><td>"&session("userId")&"</td></tr>"
	signTable = signTable & "<tr><td style='font-weight:bold;'>Email</td><td>"&session("email")&"</td></tr>"
	signTable = signTable & "<tr><td style='font-weight:bold;'>Date Witnessed</td><td>"&theDate&"</td></tr>"
	signTable = signTable & "</table>"

	pythonD = "{'signTable' : '"&Replace(signTable,"'","\'")&"'"&getOtherPDFInfo(experimentId,experimentType,session("firstName") & " " & session("lastName"))&"}"

	'get information from database to send witness file to inbox and send the file
	Set uRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT userId, name FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S")
	uRec.open strQuery,connAdm,3,3
	userId = uRec("userId")
	experimentName = uRec("name")
	If newStatusId = "6" and oldRevisionNumber <> "0" then
		'Create a record in the pdfProcQueue table for the witness report		
		strQuery = "INSERT INTO [pdfProcQueue] (serverName, companyId, userId, experimentId, revisionNumber, experimentType, fileType, jsonBODY, dateCreated, status) VALUES (" & SQLClean(whichServer,"T","S") & ", " & SQLClean(getCompanyIdByUser(userId),"N","S") & ", " &SQLClean(userId,"N","S") & ", " & SQLClean(experimentId,"N","S") & ", " & SQLClean(oldRevisionNumber,"N","S") & ", " & SQLClean(abbrv, "T", "S") &  ", " &	SQLClean("witness","T","S") & ", " &	SQLClean(pythonD,"T","S") & ", SYSDATETIME(), 'NEW')" 
		connAdm.execute(strQuery)
	End If

'update witness request to accepted
strQuery = "UPDATE witnessRequests SET accepted=1,dateWitnessed=GETUTCDATE(),dateWitnessedServer=GETDATE() WHERE requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S") & " AND experimentTypeId="&SQLClean(experimentType,"N","S")
connAdm.execute(strQuery)

'send notification to requestor
title = "Experiment Witnessed"
note = "User "&session("firstName") &" "& session("lastName")& " has witnessed <a href="""&mainAppPath&"/"& page &"?id="&experimentId&""">"&experimentName&"</a>"

a = sendNotification(requesterId,title,note,9)
a = logAction(logActionNum, experimentId, "", 8)

set delRec = server.createobject("ADODB.RecordSet")
delQuery = "SELECT deleteCommentsOnWitness FROM companySettings WHERE companyId=" & session("companyId")
delRec.open delQuery,connAdm,0,-1
if not delRec.eof then
	delOnWitness = delRec("deleteCommentsOnWitness")
	delRec.close

	if delOnWitness = "1" then
		purgeQuery = "DELETE FROM experimentComments WHERE experimentId=" & experimentId & " AND experimentType=" & experimentType
		set purgeRec = server.createobject("ADODB.RecordSet")
		purgeRec.open purgeQuery,connAdm,0,-1
	end if
end if

response.write("{""status"":""success"",""experimentId"":""" & experimentId & """,""experimentType"":""" & experimentType & """,""revisionNumber"":""" & oldRevisionNumber & """}")
response.end()
%>