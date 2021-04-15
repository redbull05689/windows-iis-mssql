<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
mainInvURL = getCompanySpecificSingleAppConfigSetting("mainInvUrlEndpoint", session("companyId"))
regEnabled=True%>
<!-- #include file="../_inclds/globals.asp"-->

<%
If session("regUser") then
	usersICanSee = "[" & getUsersICanSee() & "]"
	data = "{""connectionId"":"""&session("servicesConnectionId")&""",""usersICanSee"":"&usersICanSee&",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&"""}"
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.setOption 2, 13056
	http.open "POST",mainInvURL&"/elnConnection/",True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(data)
	http.SetTimeouts 120000,120000,120000,120000
	http.send data
	http.waitForResponse(60)
	data = "{""connectionId"":"""&session("servicesConnectionId")&""",""registrationId"":"""&request.querystring("regNumber")&"""}"
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.setOption 2, 13056
	http.open "POST",mainInvURL&"/getInventoryContainersByRegId/",True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(data)
	http.SetTimeouts 120000,120000,120000,120000
	http.send data
	http.waitForResponse(60)
	response.write(http.responseText)
End if
%>