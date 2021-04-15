<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
appServerIP = getCompanySpecificSingleAppConfigSetting("appServerIp", session("companyId"))
'this turns off authentication%>
<%isApiPage = true%>
<%
If request.querystring("clientId") = "3958c757805790cd7748d6f2c2ea" And request.querystring("clientSecret") = "f20a497996b3fe960a31" then
	'set override DB to Broad for PROD
	session("overrideDb") = "BROAD"
End if
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
whichClient_original = whichClient
overrideDb_original = session("overrideDb")
companyId_original = session("companyId")
userId_original = session("userId")
servicesConnectionId_original = session("servicesConnectionId")

'set settings
mainAssayURL = ""
clientId = "f08e00da4sdfsdfsdfsdfs4rwegdfgdfg234255423445"
clientSecret = "cf40a6cf9100a2dfgdfgdfgdfgdfgdfdfg827934"
Select Case whichServer
	case "MODEL"
		mainAssayURL = "http://"&appServerIP&":5100"
		clientId = "f08e00da43271d10c6e7d6f2c2ea"
		clientSecret = "cf40a6cf9100a2285835"
		whichClient = "BROAD"
		session("companyId") = "56"
		session("userId") = 1012
		session("servicesConnectionId") = session("userId")&getRandomString(16)
	Case "PROD"
		mainAssayURL = "http://"&appServerIP&":5100"
		clientId = "3958c757805790cd7748d6f2c2ea"
		clientSecret = "f20a497996b3fe960a31"
		whichClient = "BROAD"
		session("overrideDb") = "BROAD"
		session("companyId") = "62"
		session("userId") = 1390
		session("servicesConnectionId") = session("userId")&getRandomString(16)
End Select

'deny access if no approriate clientid and clientsecret pair have been provided
If Not (clientId=request.querystring("clientId") And clientSecret=request.querystring("clientSecret")) Then
	response.write("not authorized")
	response.end
End if

'get connection to platform and pass parameters through to platform /getCBIPNames endpoint
Call getconnectedadm
strQuery = "UPDATE users SET servicesConnectionId="&SQLClean(session("servicesConnectionId"),"T","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
connAdm.execute(strQuery)
Call disconnectadm
Set http = CreateObject("MSXML2.ServerXMLHTTP")
usersICanSee = getUsersICanSee()
data = "{""connectionId"":"""&session("servicesConnectionId")&""",""usersICanSee"":"" "&usersICanSee&" "",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&"""}"
'Set http = CreateObject("MSXML2.ServerXMLHTTP")
'http.setOption 2, 13056
http.open "POST",mainAssayURL&"/elnConnection/",True
http.setRequestHeader "Content-Type","text/plain"
http.setRequestHeader "Content-Length",Len(data)
http.SetTimeouts 120000,120000,120000,120000
http.send data
http.waitForResponse(60)
data = "{""connectionId"":"""&session("servicesConnectionId")&""",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&""",""projectCode"":"""&request.querystring("projectCode")&""",""assayCode"":"""&request.querystring("assayCode")&""",""protocolCode"":"""&request.querystring("protocolCode")&"""}"
http.open "POST",mainAssayURL&"/getCBIPNames",True
http.setRequestHeader "Content-Type","text/plain"
http.setRequestHeader "Content-Length",Len(data)
http.SetTimeouts 120000,120000,120000,120000
http.send data
http.waitForResponse(60)
response.contenttype="application/json"
response.addheader "contenttype","application/json"
rStr = http.responseText
If rStr = "[{}]" Then
	rStr = "[]"
End if
response.write(rStr)
Set http = nothing

' 12-6-17 Reset the session variables that were changed at the top of this file
whichClient = whichClient_original
session("overrideDb") = overrideDb_original
session("companyId") = companyId_original
session("userId") = userId_original
session("servicesConnectionId") = servicesConnectionId_original
%>