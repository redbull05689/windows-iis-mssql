<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<!-- #include file="../_inclds/globals.asp"-->

<%
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DISTINCT " &_
	   "a.id, " &_
	   "a.name " &_
"FROM groups a " &_
"WHERE a.companyId = {companyId} "
strQuery = Replace(strQuery, "{companyId}", session("companyId"))
rec.open strQuery,conn,0,-1
Do While Not rec.eof
	gId = rec("id")
	name = rec("name")
	rec.movenext
    response.write(gId & ":" & name & ",")
loop
rec.close
%>