<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function getServerBaseUrl()
	serverName = request.servervariables("SERVER_NAME")
	serverPort = request.servervariables("SERVER_PORT")
	getServerBaseUrl = "https://"&serverName&":"&serverPort
End Function
%>