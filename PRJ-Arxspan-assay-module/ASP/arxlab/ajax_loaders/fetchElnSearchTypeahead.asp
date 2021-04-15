<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->

<%
Call getconnected

procName = "elnSearchTypeahead"
query = request.form("userInputValue")
Set rec = server.CreateObject("ADODB.RecordSet")

strQuery = "EXEC dbo." & procName &_
		   " @companyId=" & SQLClean(session("companyId"),"N","S") &_
		   ", @userId=" & SQLClean(session("userId"),"N","S") &_
		   ", @genericSearch=" & SQLClean(query,"L","S")

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