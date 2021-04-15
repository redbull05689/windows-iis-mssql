<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "MAGENTA"
%>
<script type="text/javascript">
	window.location = '/SSO/azure/authorize.asp?state=LOGIN'
</script>
