<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->

<%
Response.CodePage = 65001
Response.CharSet = "UTF-8"
Call getconnected

procName = "elnsearchwritableprojectsforuser"
query = Server.HTMLEncode(request.form("userInputValue"))
Set rec = server.CreateObject("ADODB.RecordSet")

strQuery = "EXEC dbo." & procName &_
		   " @top=" & "99999999" &_
		   ", @userId=" & SQLClean(session("userId"),"N","S") &_
		   ", @projectName =" & SQLClean(query,"L","S")

rec.open strQuery,connNoTimeout,0,-1
Set rows = JSON.parse("[]")
Do While Not rec.eof
	Set row = JSON.parse("{}")
	For Each field In rec.fields
		row.set field.name, field.value
	Next
	rows.push row
	rec.movenext
Loop

response.write JSON.stringify(rows)

%>