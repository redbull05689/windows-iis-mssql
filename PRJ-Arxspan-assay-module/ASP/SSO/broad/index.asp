<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
isArxLoginScript = True
session("authClient") = "BROAD"
session("overrideDB")="BROAD"
%>
<script type="text/javascript">
	window.location = '/SSO/google/authorize.asp?state=LOGIN'
</script>
