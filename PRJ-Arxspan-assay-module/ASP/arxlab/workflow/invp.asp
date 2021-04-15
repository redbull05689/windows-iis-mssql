<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
isApiPage = true
server.scriptTimeout=300
Response.CodePage = 65001
Response.CharSet = "UTF-8"
%>
<!-- #include file="_inclds/globals.asp"-->
<%
'start inventory
'For Each sItem In Request.Form
'Response.Write(sItem)
'Response.Write(" - [" & Request.Form(sItem) & "]" & strLineBreak)
'Response.write(request.servervariables("REMOTE_ADDR"))
'Next
'response.end()

If request.Form("abandon") = "true" Then
	session.abandon()
End If

contentType = "application/json"

if request.form("config") = "true" Then
	endpointUrl = getCompanySpecificSingleAppConfigSetting("configServiceEndpointUrl", session("companyId"))

	if request.form("adminService") = "true" Then
		endpointUrl = session("adminServiceEndpointUrl")
	end if

	if request.form("appService") = "true" Then
		endpointUrl =  getCompanySpecificSingleAppConfigSetting("appServiceEndpointUrl", session("companyId"))
	end if

	if request.form("notificationService") = "true" Then
		endpointUrl = getCompanySpecificSingleAppConfigSetting("notificationServiceEndpointUrl", session("companyId"))
	end if

	if request.form("linkService") = "true" then
		endpointUrl = getCompanySpecificSingleAppConfigSetting("linkServiceEndpointUrl", session("companyId"))
	end if  

end if

serialUUID = request.form("serialUUID")

call getconnected
if UCase(request.Form("verb")) <> "GET" then
	set serialRec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT COUNT(*) as ackCount FROM serialsAck WITH(NOLOCK) WHERE serial=" & SQLClean(serialUUID,"T","S")
	serialRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	If serialRec("ackCount") <> 0 Then
		'We have already seen this request, don't run it again
		response.write("{""result"":""error"", ""error"": ""repeat request""}")
		response.end()
	else
		Call getconnectedadm
		strInsert = "INSERT into serialsAck(serial) values("&SQLClean(serialUUID,"T","S")&");"
		Set rs = connAdm.execute(strInsert)
	End if
	serialRec.close
Set serialRec = nothing
end if

formData = request.Form("data")

Dim http
Set http = CreateObject("MSXML2.ServerXMLHTTP")
If request.Form("async") = "async" Then
	http.open request.Form("verb"),endpointUrl&request.Form("url")&"?data="&SERVER.URLEncode(formData),True
else
	http.open request.Form("verb"),endpointUrl&request.Form("url"),True
End if

http.setRequestHeader "Content-Type",contentType
http.setRequestHeader "Content-Length",Len(formData)

http.setRequestHeader "Authorization", session("jwtToken")
http.SetTimeouts 180000,180000,180000,180000

' ignore ssl cert errors
http.setOption 2, 13056
http.send formData

http.waitForResponse(180)

'write the response in 1mb chunks - I was getting a buffer overrun in cases where trying to return a lot of data
chunkId = 0
chunkSize = 1000000
responseLen = Len(http.responseText)

If responseLen >= chunkSize Then
	Do While chunkId * chunkSize < responseLen
		response.write(Mid(http.responseText, (chunkId * chunkSize) + 1, chunkSize))
		response.flush()
		chunkId = chunkId + 1
	Loop
Else
	response.write(http.responseText)
End If

response.end()
%>