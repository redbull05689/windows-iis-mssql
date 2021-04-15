<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%session.abandon%>
<%
response.charset = "UTF-8"
response.codePage = 65001
session("companyId") = request.querystring("companyId")
If session("companyId") = "62" Then
	session("overrideDB")="BROAD"
End if
session("userId") = request.querystring("userId")
session("hasELN") = true
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
call getconnected
call getconnectedAdm
hideLoginNotification = true
loginUser(session("userId"))
response.write(getUsersICanSee())
call disconnectAdm
call disconnect
%>