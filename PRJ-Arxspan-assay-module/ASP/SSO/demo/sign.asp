<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "DEMO"
session("SSOPageKey") = request.querystring("key")
session.Save()
%>
<script type="text/javascript">
	var state = "<%=request.querystring("state")%>";
	var redirectTo = '/SSO/okta/authorize.asp?state=' + state;
	console.log('redirecting to: ' + redirectTo);
	window.location = redirectTo;
</script>