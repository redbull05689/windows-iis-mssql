<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If request.querystring("id") <> "" Then
	'if the experiment is saved or we are viewing the experiment from a readonly page(eg admin) then
	'we will get the data for the experiment(pressure,temp, preparation,cdx, etc) out of the database
	'The procucts,reactants and files are handled later in this script
	call getconnected
	If revisionId = "" then
		strQuery22 = "SELECT * FROM experimentView WHERE id=" & SQLClean(request.querystring("id"),"N","S")
		currentRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
	Else
		strQuery22 = "SELECT * FROM experimentHistoryView WHERE experimentId=" & SQLClean(request.querystring("id"),"N","S") & " AND revisionNumber="&SQLClean(revisionId,"N","S")
	End If
	set	expRec = Server.CreateObject("ADODB.RecordSet")
	expRec.open strQuery22,conn,3,3
	experimentExists = False
	If Not expRec.eof Then
		If revisionId <> "" Then
			currentRevisionNumber = expRec("revisionNumber")
		End If
		craisStatusId = 0
		If Not IsNull(expRec("craisStatus")) Then
			craisStatusId = expRec("craisStatus")
		End if
		experimentExists = True
		expUserId = expRec("userId")
		notebookId = expRec("notebookId")
		experimentName = Replace(expRec("name"),"''","'")
		'ELN-541
		If IsNull(expRec("userExperimentName")) Then
			userExperimentName = ""
		Else
			userExperimentName = Replace(expRec("userExperimentName"),"''","'")
		End If
		experimentDetails = expRec("details")
		If IsNull(experimentDetails) Then
			experimentDetails = ""
		End if
		prepText = expRec("preparation")
		reactionMolarity = expRec("reactionMolarity")
		pressure = expRec("pressure")
		temperature = expRec("temperature")
		cdxData = expRec("cdx")
		mrvData = expRec("mrvData")
		molData = expRec("molData")
		If IsNull(cdxData) Then
			cdxData = ""
		End if
		If IsNull(mrvData) Then
			mrvData = ""
		End if
		cdxData = Replace(cdxData,vbcrlf,"")
		mrvData = Replace(mrvData,vbcrlf,"")
		notebookId = expRec("notebookId")
		collection = expRec("name")
		statusId = expRec("statusId")
		experimentOwner = expRec("firstName") & " " & expRec("lastName")
		notebookName = expRec("notebookName")
		'5 - signed - closed, 6 - witnessed, 10 - pending abandonment, 11 - abandoned
		If statusId = 5 Or statusId = 6 or statusId = 10 Or statusId = 11 Then
			If session("justSaved") Then
				session("justSaved") = False
				response.redirect("dashboard.asp?id="&experimentId&"&experimentType=1&revisionNumber="&currentRevisionNumber)
			Else
				If session("redirectToSignedPDF") then
					If request.querystring("expView") = "" then
						response.redirect("signed.asp?id="&experimentId&"&experimentType=1&revisionNumber="&currentRevisionNumber)
					End if
				End if
				If request.querystring("revisionId") = "" then
					response.redirect(session("expPage")&"?id="&experimentId&"&revisionId="&currentRevisionNumber)
				End if
			End If
		End If
		session("justSaved") = False
	End If
	maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
End If
%>