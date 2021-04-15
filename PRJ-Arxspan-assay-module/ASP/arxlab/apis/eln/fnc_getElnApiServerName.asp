<%
Function getElnApiServerName()
	serverName = ""
	If whichServer="DEV" Then
		serverName = "http://10.10.10.16:5105/"
	ElseIf whichServer="MODEL" Then
		serverName = "http://10.10.10.15:5105/"
	ElseIf whichServer="BETA" Then
		serverName = "http://10.10.10.12:5105/"
	ElseIf whichServer="PROD" Then
		serverName = "http://10.10.10.172:5105/"
	End If
	getElnApiServerName = serverName
End Function
%>