<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "FLEXION"
%>
<script type="text/javascript">
	window.location = '/SSO/okta/authorize.asp?state=LOGIN'
</script>
