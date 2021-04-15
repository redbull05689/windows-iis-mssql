<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
formUrl = request.Form("url")
If Right(s, 1) <> "/" Then
	formUrl = formUrl & "/"
End If

Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.open request.Form("verb"),formUrl,True
http.setRequestHeader "Content-Type","application/json"
http.setRequestHeader "Authorization", session("jwtToken")
http.setRequestHeader "Content-Length",Len(request.Form("data"))
http.send request.Form("data")
http.waitForResponse(60)
response.write(http.responseText)
Set http = nothing
%>