<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isApiPage = true%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
mainAssayUrl = getCompanySpecificSingleAppConfigSetting("assayEndpointUrl", session("companyId"))

whichClient_original = whichClient
companyId_original = session("companyId")
userId_original = session("userId")
servicesConnectionId_original = session("servicesConnectionId")

whichClient = "BROAD"
session("userId") = 1012

' 2/28/18 - JVA: Need to get the servicesConnectionId for the support user!
Call getconnectedadm
set xRec = server.createObject("ADODB.RecordSet")
strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(session("userId"),"N","S")
xRec.open strQuery,conn,3,3
session("servicesConnectionId") = xRec("servicesConnectionId")
Call disconnectadm

Set http = CreateObject("MSXML2.ServerXMLHTTP")
data = "{""connectionId"":"""&session("servicesConnectionId")&""",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&"""}"
'Set http = CreateObject("MSXML2.ServerXMLHTTP")
'http.setOption 2, 13056
http.open "POST",mainAssayURL&"/elnConnection/",True
http.setRequestHeader "Content-Type","text/plain"
http.setRequestHeader "Content-Length",Len(data)
http.SetTimeouts 120000,120000,120000,120000
http.send data
http.waitForResponse(60)
data = "{""connectionId"":"""&session("servicesConnectionId")&""",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&""",""projectCode"":"""&request.querystring("projectCode")&""",""assayCode"":"""&request.querystring("assayCode")&""",""protocolCode"":"""&request.querystring("protocolCode")&"""}"
http.open "POST",mainAssayURL&"/getCBIPNames/",True
http.setRequestHeader "Content-Type","text/plain"
http.setRequestHeader "Content-Length",Len(data)
http.SetTimeouts 120000,120000,120000,120000
http.send data
http.waitForResponse(60)
response.write(http.responseText)
Set http = nothing

' 12-6-17 Reset the session variables that were changed at the top of this file
whichClient = whichClient_original
session("userId") = userId_original
session("servicesConnectionId") = servicesConnectionId_original

%>