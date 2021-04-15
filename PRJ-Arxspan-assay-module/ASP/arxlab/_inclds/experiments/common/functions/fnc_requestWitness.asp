<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function requestWitness(experimentType,experimentId,requesteeId)
	'insert a witness request into the witness request table
	''Call getconnectedadm
	userExists = False
	'check whether requester user exists
	If request.Form("userId") <> "-1" Then
		usersTable = getDefaultSingleAppConfigSetting("usersTable")
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM "&usersTable&" WHERE id="&SQLClean(requesteeId,"N","S")
		rec.open strQuery,connAdm,3,3
		If Not rec.eof Then
			userExists = True
		End If
		rec.close
		Set rec = nothing
	End if

	errorStr = ""

	If Not userExists Then
		ErrorStr = "Please select a Witness"
	End if

	If errorStr = "" then
		'check if a witness request for this user already exists
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT accepted, denied FROM witnessRequests WHERE experimentId=" & SQLClean(experimentId,"N","S") &_
		" AND experimentTypeId="&SQLClean(experimentType,"N","S") &_
		" AND requesterId="&SQLClean(session("userId"),"N","S") &_
		" AND requesteeId="&SQLClean(requesteeId,"N","S")
		rec2.open strQuery,connAdm,3,3
		If Not rec2.eof Then
			If rec2("accepted") = 0 And rec2("denied") = 0 then
				errorStr = "You have already sent a request to this user."
			Else
				If rec2("denied") = 1 Then
					errorStr = "This user has denied your request to witness this experiment"
				End If
				If rec2("accepted") = 1 Then
					errorStr = "This user has already witnessed this experiment"
				End If			
			End if
		End if
		rec2.close
		Set rec2 = nothing
		'if the requester is the owner and the requester exists and the requestee has not already been sent a request then
		'insert the request
		If errorStr = "" then
			strQuery = "INSERT into witnessRequests(experimentId,experimentTypeId,requesterId,requesteeId,accepted,denied,dateSubmitted,dateSubmittedServer) values(" &_
			SQLClean(experimentId,"N","S") & "," &_ 
			SQLClean(experimentType,"N","S") & "," &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(requesteeId,"N","S") & ",0,0,GETUTCDATE(),GETDATE())"
			'DEBUG
			'response.write("inserting witness request<br>")
			connAdm.execute(strQuery)
		End if
	End if

	'return the error string if an error string is returned the app opens an alert box with the error
	requestWitness = errorStr
End Function 
%>