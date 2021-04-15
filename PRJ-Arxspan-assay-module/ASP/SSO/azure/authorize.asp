<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
sectionId="autolog"
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<!-- #include file="../common-asp/commonFunctions.asp"-->
<!-- #include file="ssoConfig.asp"-->
<%
' Set up the data that we are going to send with the request
requestState = request.querystring("state")
If requestState = "" Then
	requestState = "LOGIN"
End If

Set stateData = JSON.parse("{}")
stateData.set "action", requestState
stateData.set "authCompanyId", authCompanyId
stateData.set "arxToken", getRandomString(128)
stateStr = Base64Encode(JSON.stringify(stateData))

' Get the clientId from the database
clientId = ""
oauthStr = getOAuthClientData(authCompanyId)
Set oauthJson = JSON.parse(oauthStr)
If isObject(oauthJson) Then
	clientId = oauthJson.get("clientId")
End If
%>

<% If clientId <> "" Then %>
	<form id="login-form"  method="GET" action="<%=baseAuthURL%>/authorize" class="loginForm" style="margin:0;">
		<input type="hidden" name="client_id" value="<%=clientId%>">
		<input type="hidden" name="response_type" value="code">
		<%If requestState <> "LOGIN" Then%>
		<input type="hidden" name="prompt" value="login">
		<%Else%>
		<input type="hidden" name="resource" value="https://graph.windows.net/">
		<%End If%>
		<input type="hidden" name="scope" value="<%=scope%>">
		<input type="hidden" name="redirect_uri" value="<%=redirectURI%>">
		<input type="hidden" name="state" value="<%=stateStr%>">
		<button class="loginButton" name="login-submit" id="login-submit" value="go" style='display:none;'>Sign In</button>
	</form>
	<script type='text/javascript'>
		document.getElementById("login-form").submit();
	</script>
<%
Else
	response.write("There was a problem processing your login. Please contact support@arxspan.com.")
	response.end()
End If
%>
