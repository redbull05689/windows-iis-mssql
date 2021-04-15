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
	<script src="/arxlab/jqfu/js/jquery-1.10.2.min.js"></script>
	<script type='text/javascript'>
		$(document).ready(function() {
			<%If requestState <> "LOGIN" Then%>
			$("#logoutFrame").load(function() {
			<%End If%>
				document.getElementById("login-form").submit();
			<%If requestState <> "LOGIN" Then%>
			});
			
			$("#logoutFrame").attr({
				src:"https://www.google.com/accounts/Logout"
			});
			<%End If%>
		});
	</script>

	<%
	' This iframe is to log the user out of Google. There isn't any other way to force a password re-prompt.
	%>
	<%If requestState <> "LOGIN" Then%>
	<iframe id="logoutFrame" frameborder="0"></iframe>
	<%End If%>

	<form id="login-form"  method="GET" action="<%=baseAuthURL%>auth" class="loginForm" style="margin:0;">
		<input type="hidden" name="client_id" value="<%=clientId%>">
		<input type="hidden" name="response_type" value="code">
		<input type="hidden" name="scope" value="<%=scope%>">
		<input type="hidden" name="redirect_uri" value="<%=redirectURI%>">
		<input type="hidden" name="state" value="<%=stateStr%>">
		<%If requestState <> "LOGIN" Then%>
		<input type="hidden" name="approval_prompt" value="force">
		<%End If%>
	  <button class="loginButton" name="login-submit" id="login-submit" value="go" style='display:none;'>Sign In</button>
	</form>
<%
Else
	response.write("There was a problem processing your login. Please contact support@arxspan.com.")
	response.end()
End If
%>
