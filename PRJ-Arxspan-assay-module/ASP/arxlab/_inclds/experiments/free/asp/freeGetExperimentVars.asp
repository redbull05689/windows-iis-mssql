<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If request.querystring("id") <> "" then
	'if the experiment is saved or we are viewing the experiment from a readonly page(eg admin) then
	'we will get the data for the experiment(pressure,temp, preparation,cdx, etc) out of the database
	'The procucts,reactants and files are handled later in this script
	call getconnected
	If revisionId = "" then
		strQuery22 = "SELECT * FROM freeExperimentsView WHERE id=" & SQLClean(request.querystring("id"),"N","S")
		currentRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
	Else
		strQuery22 = "SELECT * FROM freeExperimentHistoryView WHERE experimentId=" & SQLClean(request.querystring("id"),"N","S") & " AND revisionNumber="&SQLClean(revisionId,"N","S")
	End if
	set	expRec = Server.CreateObject("ADODB.RecordSet")
	expRec.open strQuery22,conn,3,3
	experimentExists = False
	If Not expRec.eof Then
		If revisionId <> "" Then
			currentRevisionNumber = expRec("revisionNumber")
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
		description = expRec("description")
		statusId = expRec("statusId")
		experimentOwner = expRec("firstName") & " " & expRec("lastName")
		notebookName = expRec("notebookName")
		'5 - signed - closed, 6 - witnessed, 10 - pending abandonment, 11 - abandoned
		If statusId = 5 Or statusId = 6 or statusId = 10 Or statusId = 11 Then
			If session("justSaved") Then
				session("justSaved") = False
				response.redirect("dashboard.asp?id="&experimentId&"&experimentType=3&revisionNumber="&currentRevisionNumber)
			Else
				If session("redirectToSignedPDF") Then
					If request.querystring("expView") = "" then
						'If currentRevisionNumber <> 1 then
							response.redirect("signed.asp?id="&experimentId&"&experimentType=3&revisionNumber="&currentRevisionNumber)
						'End if
					End if
				end if
				If request.querystring("revisionId") = "" then
					response.redirect("free-experiment.asp?id="&experimentId&"&revisionId="&currentRevisionNumber & "&expView=" & request.querystring("expView"))
				End if
			End If
		End If
		session("justSaved") = False
	End If
	maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
End If
%>