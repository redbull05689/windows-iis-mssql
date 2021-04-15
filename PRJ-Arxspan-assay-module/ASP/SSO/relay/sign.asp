<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "RELAY"
%>
<script type="text/javascript">
	var state = "<%=request.querystring("state")%>";
	var redirectTo = '/SSO/centrify2/authorize.asp?state=' + state;
	console.log('redirecting to: ' + redirectTo);
	window.location = redirectTo;
</script>