<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->

<%
Call getconnected

procName = "elnSearchVisibleExperimentsWithName"
query = request.form("userInputValue")
Set rec = server.CreateObject("ADODB.RecordSet")

strQuery = "EXEC dbo." & procName &_
		   " @top=" & "10000" &_
		   ", @companyId=" & SQLClean(session("companyId"),"N","S") &_
		   ", @userId=" & SQLClean(session("userId"),"N","S") &_
		   ", @experimentName  =" & SQLClean(query,"T","S")

'EXEC elnSearchVisibleExperimentsWithName 1529, 72, 'SVN'

'response.write strQuery
'response.end

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

