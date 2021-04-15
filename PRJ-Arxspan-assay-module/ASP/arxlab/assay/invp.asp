<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
Response.CodePage = 65001
Response.CharSet = "UTF-8"
%>
<!-- #include file="_inclds/globals.asp"-->
<%
'start inventory
'For Each sItem In Request.Form
'Response.Write(sItem)
'Response.Write(" - [" & Request.Form(sItem) & "]" & strLineBreak)
'Next
formUrl = request.Form("url")
If Right(s, 1) <> "/" Then
	formUrl = formUrl & "/"
End If
Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.open request.Form("verb"),wsBase&formUrl,True
http.setRequestHeader "Content-Type","application/json;charset=UTF-8"
http.setRequestHeader "Content-Length",Len(request.Form("data"))
http.SetTimeouts 120000,120000,120000,120000
If whichServer = "DEV" then
	http.setOption 2, 13056
End if
http.send request.Form("data")
http.waitForResponse(60)
response.write(http.responseText)
Set http = nothing
%>