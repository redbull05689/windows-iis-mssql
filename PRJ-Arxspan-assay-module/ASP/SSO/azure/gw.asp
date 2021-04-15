<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../common-asp/commonFunctions.asp"-->
<%
sectionId="autolog"
whiteListOverride = true
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<!-- #include file="../../arxlab/_inclds/misc/functions/fnc_ipsFromRange_local.asp"-->
<!-- #include file="ssoConfig.asp"-->
<%

authToken = ""
authError = False
code = request.querystring("code")
queryState = request.querystring("state")

If queryState <> "" Then
	queryState = decodeBase64(queryState)
End If

If code <> "" And queryState <> "" Then
	Set sessionState = JSON.parse(queryState)

	If IsObject(sessionState) Then
		' Get the oauth config info from the database
		clientId = ""
		clientSecret = ""
		
		authCompanyId = sessionState.get("authCompanyId")
		oauthStr = getOAuthClientData(authCompanyId)

		Set oauthJson = JSON.parse(oauthStr)			
		If isObject(oauthJson) Then
			clientId = oauthJson.get("clientId")
			clientSecret = oauthJson.get("clientSecret")
		End If
		
		If clientId <> "" And clientSecret <> "" Then
			formData =  "grant_type="&server.urlencode("authorization_code") &_
						"&code="&server.urlencode(code) &_
						"&redirect_uri="&server.urlencode(redirectURI) &_
						"&client_id="&server.urlencode(clientId) &_
						"&client_secret="&server.urlencode(clientSecret) &_
						"&resource="&server.urlencode("https://graph.windows.net/")
		
			set http = server.Createobject("MSXML2.ServerXMLHTTP")
			http.Open "POST", baseAuthURL&"/token",False
			http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"

			http.send formData
			jsonStr = http.responseText
			Set r = JSON.parse(jsonStr)
			jwtArr = Split(r.Get("id_token"),".")
			If UBound(jwtArr)<1 Then
				authError = true
			Else
				jwtStr = jwtArr(1)
				Do While Not Len(jwtStr) Mod 4 = 0
					jwtStr = jwtStr & "="
				loop
				jwtStr = decodeBase64(jwtStr)
				Set jwt = JSON.parse(jwtStr)
				
				atoke = r.Get("access_token")
				set http = server.Createobject("MSXML2.ServerXMLHTTP")
				http.Open "GET", "https://graph.windows.net/me?api-version=1.6",False
				http.setRequestHeader "Content-Type", "application/json"
				http.setRequestHeader "Authorization", "Bearer "&atoke
				http.send
				jsonStr = http.responseText
				Set uInfo = JSON.parse(jsonStr)
				email = uInfo.Get("userPrincipalName")
			End If
		End If
	Else
		authError = true
	End If
Else
	authError = true
End if

If Not authError then
	Call getconnected
	Call getconnectedadm
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM companies WHERE id="&SQLClean(sessionState.get("authCompanyId"),"N","S")&" AND (datediff(day,getdate(), expirationDate) > 0 or expirationDate is null or expirationDate='1/1/1900') and (disabled=0 or disabled is null)"
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM users WHERE enabled=1 AND (companyId="&SQLClean(sessionState.get("authCompanyId"),"N","S")&") AND email="&SQLClean(email,"T","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			ipBlocked = false
			Set rec3 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT ipRanges FROM usersView WHERE ipBlock=1 and ipBlockMe=1 and id="&SQLClean(rec("id"),"N","S")
			rec3.open strQuery,conn,3,3
			If Not rec3.eof Then
				ipBlocked = True
				ipStr = rec3("ipRanges")
				If ipStr <> "" Then
					ipStr = ipStr & ",100.0.175.27,8.20.189.20,108.7.43.41,8.20.189.16,8.20.189.168,8.20.189.170"
				Else
					ipStr = "100.0.175.27,8.20.189.20,8.20.189.168,8.20.189.170"
				End if
				ipArray = Split(ipsFromRange(ipStr),",")
				For q = 0 To UBound(ipArray)
					If ipArray(q) = request.servervariables("REMOTE_ADDR") Then
						ipBlocked = false
					End if
				Next
			End If
			rec3.close
			Set rec3 = Nothing

			If ipBlocked Then
				message = "There was an error logging you in. Please contact support@arxspan.com reference error REMOTE_ADDR."
				showError(message)
			Else
				redirectUrl = ""
				
				If sessionState.get("action") = "LOGIN" Then
					loginUser(rec("id"))
					checkEmailsMatch()
					session("authToken") = authToken
					redirectUrl = mainAppPath&"/dashboard.asp"
				ElseIf sessionState.get("action") = "SIGN" Then
					checkEmailsMatch()
					
					if session("ssoexperimenttype") = "5" then
					%>					
						<script type="text/javascript">
							var statusId = window.opener.statusId;
							
							if (statusId === undefined) {
								statusId = experimentStatusId
							}
							
							var requestId = window.opener.$("#requestId").val();
							var requestRev = window.opener.$("#requestRevisionId").val();
							if (statusId != 4 || statusId != 5) {
								window.opener.experimentSubmit(false,true,false, undefined, requestId, requestRev);
								window.close();
							} else {
								window.opener.addCoAuthorSignature();
							}						
						</script>
					<%
					else
					%>
					<script type="text/javascript">
						window.opener.experimentSubmit(false,true,false);
						window.close();
					</script>
					<%
					end if
					session("ssoSignJson") = ""
				ElseIf sessionState.get("action") = "WITNESS" Then
					checkEmailsMatch()
					%>
					<script type="text/javascript">
						window.opener.document.getElementById("ssoWitnessForm").submit();
						window.opener.document.location.href = window.opener.successfulWitnessRedirectURL;
						window.close();
					</script>
					<%
					session("ssoWitnessJson") = ""
				End If

				If redirectUrl <> "" Then
					response.redirect(redirectUrl)
				End If
			End if
		Else
			message = "There was an error logging you in.  You do not have an account.  Please contact support@arxspan.com"
			showError(message)
		End If
	Else
		message = "There was an error logging you in.  Please contact support@arxspan.com  Reference error: GUITAR." ' Just a random searchable word so the error message doesn't need to say "You guys forgot to pay"
		showError(message)
	end if
	rec.close
	Set rec = Nothing
Else
	if emailNotVerified then
		message = "There was an error logging you in.  Your email address has not been verified"
		showError(message)
	else
		message = "There was an error logging you in.  Please contact support@arxspan.com"
		showError(message)
	end if
End if

sub showError(str)
	response.write(str&"<br/>")
	If request.querystring("error") <> "" Then
		response.write(request.querystring("error")&"<br/>")
	End If
	If request.querystring("error_description") <> "" Then
		response.write(request.querystring("error_description")&"<br/>")
	End if
	response.end
End sub
%>