<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
session("authClient") = "REVOLUTION"
%>
<script type="text/javascript">
	window.location = '/SSO/centrify/login.asp'
</script>