<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "DEMO"
%>
<script type="text/javascript">
	window.location = '/SSO/okta/authorize.asp?state=LOGIN'
</script>
