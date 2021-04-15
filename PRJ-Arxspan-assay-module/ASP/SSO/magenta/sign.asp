<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "MAGENTA"
%>
<script type="text/javascript">
	var state = "<%=request.querystring("state")%>";
	var redirectTo = '/SSO/azure/authorize.asp?state=' + state;
	console.log('redirecting to: ' + redirectTo);
	window.location = redirectTo;
</script>