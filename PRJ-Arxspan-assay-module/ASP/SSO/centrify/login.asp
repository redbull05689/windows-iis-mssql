<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId="autolog"
isArxLoginScript = True
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<!-- #include file="../../arxlab/_inclds/misc/functions/fnc_getRandomString.asp"-->
<!-- #include file="ssoConfig.asp"-->
<div class="loginMediumContentBoxContent">		
	<form id="login-form"  method="GET" action="<%=session("baseAuthURL")%>/Openid" class="loginForm" style="margin:0;">
		<input type="hidden" name="client_id" value="<%=session("clientId")%>">
		<input type="hidden" name="response_type" value="code">
		<input type="hidden" name="scope" value="<%=session("scope")%>">
		<input type="hidden" name="redirect_uri" value="<%=session("redirectURI")%>">
		<input type="hidden" name="state" value="<%=session("state")%>">
	  <button class="loginButton" name="login-submit" id="login-submit" value="go" style='display:none;'>Sign In</button>
</form>
<script type='text/javascript'>
	document.getElementById("login-form").submit();
</script>
