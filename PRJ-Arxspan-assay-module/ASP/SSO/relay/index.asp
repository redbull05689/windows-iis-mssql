<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
session("authClient") = "RELAY"
%>
<script type="text/javascript">
	window.location = '/SSO/centrify2/authorize.asp?state=LOGIN'
</script>