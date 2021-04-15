<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% Response.AddHeader "Access-Control-Allow-Origin", "*"%>
<!-- #include file="../../_inclds/globals.asp" -->
<!-- #include file="fnc_getElnApiServerName.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
appServerIP = getCompanySpecificSingleAppConfigSetting("appServerIp", session("companyId"))
Response.LCID = 2057
	serverName = "http://"&appServerIP&":5105/"
Sub asyncResponder
	If (http.readyState = 4) Then
		response.write(http.responseText)
		Set http = Nothing
	End If
End sub

If request.Form("abandon") = "true" Then
	session.abandon()
End If

set JSON = New JSONobject
set requestFormDataParsed = JSON.Parse(request.Form("data"))
requestFormDataParsed.Add "companyId", session("companyId")
requestFormDataParsed.Add "userId", session("userId")
requestFormDataWithExtras = requestFormDataParsed.Serialize()

wsBase = getElnApiServerName()
Set http = CreateObject("MSXML2.ServerXMLHTTP")
If request.Form("async") = "async" Then
	'response.write request.Form("verb") & " ... " & wsBase & " ... " & request.Form("url") & " ... " & "?data="&SERVER.URLEncode(requestFormDataWithExtras)
	http.open request.Form("verb"),wsBase&request.Form("url")&"?data="&SERVER.URLEncode(requestFormDataWithExtras),True
Else
	'response.write request.Form("verb") & " ... " & wsBase & " ... " & request.Form("url")
	http.open request.Form("verb"),wsBase&request.Form("url"),True
End If

http.setRequestHeader "Content-Type","text/plain;charset=UTF-8"
http.setRequestHeader "Content-Length",Len(requestFormDataWithExtras)
http.SetTimeouts 180000,180000,180000,180000

' ignore ssl cert errors
http.setOption 2, 13056
http.send requestFormDataWithExtras
http.waitForResponse(180)

response.write(http.responseText)
%>