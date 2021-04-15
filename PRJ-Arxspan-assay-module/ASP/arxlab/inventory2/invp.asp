<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isApiPage = true%>
<%
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
Dim http

If request.Form("abandon") = "true" Then
	session.abandon()
End If

Sub objXML_onreadystatechange
	If (http.readyState = 4) Then
		response.write(http.responseText)
		Set http = Nothing
	End If
End sub

formUrl = request.Form("url")
If Right(s, 1) <> "/" Then
	formUrl = formUrl & "/"
End If

Set http = CreateObject("MSXML2.ServerXMLHTTP")
If request.Form("async") = "async" Then
	http.open request.Form("verb"),wsBase&formUrl&"?data="&SERVER.URLEncode(request.Form("data")),True
else
	http.open request.Form("verb"),wsBase&formUrl,True
End if

http.setRequestHeader "Content-Type","text/plain;charset=UTF-8"
http.setRequestHeader "Content-Length",Len(request.Form("data"))
http.SetTimeouts 180000,180000,180000,180000

' ignore ssl cert errors
http.setOption 2, 13056
http.send request.Form("data")
http.waitForResponse(60)

response.write(http.responseText)
%>