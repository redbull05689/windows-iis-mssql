<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "INTELLIA"
%>
<script type="text/javascript">
	window.location = '/SSO/okta/authorize.asp?state=LOGIN'
</script>
