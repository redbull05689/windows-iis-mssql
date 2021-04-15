<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "BROAD"
session("overrideDB")="BROAD"
%>
<script type="text/javascript">
	var state = "<%=request.querystring("state")%>";
	var redirectTo = '/SSO/google/authorize.asp?state=' + state;
	console.log('redirecting to: ' + redirectTo);
	window.location = redirectTo;
</script>