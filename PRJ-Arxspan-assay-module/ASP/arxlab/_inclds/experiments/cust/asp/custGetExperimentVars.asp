<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
requestId = Null
requestTypeId = request.querystring("r")

If request.querystring("id") <> "" then
	'See if we already have a requestTypeId and requestId in the database for this experiment. If so, use that.
	Call getconnected
	Set recz = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT requestId, requestTypeId, requestRevisionNumber FROM custExperiments WHERE id=" & SQLClean(request.querystring("id"),"N","S")
	recz.open strQuery,conn,3,3
	If Not recz.eof Then
		requestId = recz("requestId")
		requestTypeId = recz("requestTypeId")
		requestRevisionId = recz("requestRevisionNumber")
		session("SSOrequestId") = requestId
		session("SSOrequestRevisionId") = requestRevisionId
	End If
	recz.close
	Set recz = nothing

	If revisionId = "" then
		strQuery22 = "SELECT * FROM custExperimentsView WHERE id=" & SQLClean(request.querystring("id"),"N","S")
		currentRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
	Else
		strQuery22 = "SELECT * FROM custExperimentHistoryView WHERE experimentId=" & SQLClean(request.querystring("id"),"N","S") & " AND revisionNumber="&SQLClean(revisionId,"N","S")
	End If
	set	expRec = Server.CreateObject("ADODB.RecordSet")
	expRec.open strQuery22,conn,3,3
	experimentExists = False
	If Not expRec.eof Then
		If revisionId <> "" Then
			currentRevisionNumber = expRec("revisionNumber")
			requestRevisionNumber = expRec("requestRevisionNumber")
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
		statusId = expRec("statusId")
		experimentOwner = expRec("firstName") & " " & expRec("lastName")
		notebookName = expRec("notebookName")
		requestId = expRec("requestId")
		'5 - signed - closed, 6 - witnessed, 10 - pending abandonment, 11 - abandoned
		If statusId = 5 Or statusId = 6 or statusId = 10 Or statusId = 11 Then
			If session("justSaved")=True Then
				session("justSaved") = False
				response.redirect("dashboard.asp?id="&experimentId&"&experimentType=5&revisionNumber="&currentRevisionNumber)
			Else
				If session("redirectToSignedPDF") Then
					If request.querystring("expView") = "" then
						'If currentRevisionNumber <> 1 then
							response.redirect("signed.asp?id="&experimentId&"&experimentType=5&revisionNumber="&currentRevisionNumber)
						'End If
					End if
				End if
				If request.querystring("revisionId") = "" then
					response.redirect("cust-experiment.asp?id="&experimentId&"&revisionId="&currentRevisionNumber & "&expView=" & request.querystring("expView"))
				End if
			End If
		End If
		session("justSaved") = False
	End If
	expRec.close
	maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)

	latestStatusQuery = "SELECT statusId FROM custExperiments WHERE id=" & experimentId
    latestStatus = ""

    Set latestRec = server.CreateObject("ADODB.RecordSet")
    
    latestRec.open latestStatusQuery, connAdm, 3, 3
    if not latestRec.eof then
        latestStatus = latestRec("statusId")
    end if
	latestRec.close
End If
%>