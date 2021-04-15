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
			formData = ""
			formData = formData & "grant_type="&server.urlencode("authorization_code")
			formData = formData & "&code="&server.urlencode(code)
			formData = formData & "&redirect_uri="&server.urlencode(redirectURI)
			formData = formData & "&scope="&server.urlencode(scope)

			set http = server.Createobject("MSXML2.ServerXMLHTTP")
			http.Open "POST", baseAuthURL&"/oauth2/v1/token",False
			http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
			s =  Base64Encode(CStr(clientId)&":"&CStr(clientSecret))
			http.setRequestHeader "Authorization", "Basic "&s
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
				email = jwt.Get("email")
			End if
		Else
			authError = true
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
					' Sometimes the SSOPageKey is not set in the session as should, so we need to handle that situation
					' Note that this fix will not work in IE 11
					%>
					<script>
						ssoPageKey = "<%=session("SSOPageKey")%>";
						if (ssoPageKey == "") {
							ssoPageKey = window.opener.keyString;
						}
					</script>
					<%
					if session("ssoexperimenttype") = "5" then
					%>
						<script type="text/javascript">
							document.cookie = "ssoKey"+ssoPageKey+"=type5;path=/";
							window.close();
						</script>

					<%
					else
					%>
						<script type="text/javascript">
							document.cookie = "ssoKey"+ssoPageKey+"=sign;path=/";
							window.close();
						</script>
					<%
					end if
				ElseIf sessionState.get("action") = "WITNESS" Then
					checkEmailsMatch()
					%>
					<script type="text/javascript">
						ssoPageKey = "<%=session("SSOPageKey")%>";
						if (ssoPageKey == "") {
							ssoPageKey = window.opener.keyString;
						}
						document.cookie = "ssoKey"+ssoPageKey+"=witness;path=/";
						window.close();
					</script>
					<%
					session("ssoWitnessJson") = ""
				End If

				'Clear out the Session SSO state Data
				Session.Contents.Remove("ssostate")
				Session.Contents.Remove("ssoexperimentid")
				Session.Contents.Remove("ssoexperimenttype")
				Session.Contents.Remove("ssopagekey")
				Session.Contents.Remove("ssoredirecturl")
				Session.Contents.Remove("ssorequestid")
				Session.Contents.Remove("ssorequestrevisionid")

				If redirectUrl <> "" Then
					response.redirect(redirectUrl)
				End If
			End if
		Else
			message = "There was an error logging you in.  You do not have an account.  Please contact support@arxspan.com"
			showError(message)
		End If
		rec.close
		Set rec = Nothing
	Else
		message = "There was an error logging you in.  Please contact support@arxspan.com  Reference error: GUITAR." ' Just a random searchable word so the error message doesn't need to say "You guys forgot to pay"
		showError(message)
	end if
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