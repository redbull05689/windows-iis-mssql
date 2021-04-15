<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "logout"
isArxLoginScript = True
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/security/functions/fnc_getServerBaseUrl.asp"-->
<%

companyId = session("companyId")
logoutUrl = getServerBaseUrl() & "/loggedout.asp"

' Check the cookies for a copmany logout redirect redirect URL
if request.Cookies("logoutRedirectUrl") <> "" Then
	logoutUrl = request.Cookies("logoutRedirectUrl")
end if

a = logAction(0,0,"",11)
%>
<html>
<head>
</head>
<body>
<%
session.Contents.RemoveAll()
session.Abandon()
session.Save()
%>
<meta http-equiv="refresh" content="1;url=<%=logoutUrl%>">
<script type="text/javascript">
window.location = "<%=logoutUrl%>"
</script>
</body>
</html>