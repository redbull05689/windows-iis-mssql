<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<!-- #include file="../_inclds/globals.asp"-->

<%
idStr = CStr(request.form("ids"))
userIds = Split(idStr, "-")
userFilter = "AND a.id IN ({ids})"
userFilter = Replace(userFilter, "{ids}", Join(userIds, ","))
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DISTINCT " &_
	   "a.id, " &_
	   "a.fullName, " &_
       "a.enabled " &_
"FROM usersView a " &_
"WHERE a.companyId = {companyId} " &_
"AND a.email LIKE '%@{filterData}%' {userFilter} " &_
"AND a.email <> 'support@arxspan.com' " &_
"ORDER BY a.fullName"
strQuery = Replace(strQuery, "{companyId}", session("companyId"))
strQuery = Replace(strQuery, "{filterData}", session("opReportFilter"))
strQuery = Replace(strQuery, "{userFilter}", IIF(idStr = "", "", userFilter))
rec.open strQuery,conn,0,-1
Do While Not rec.eof
	userId = rec("id")
	userName = rec("fullName")
	enabled = rec("enabled")
	rec.movenext
    response.write(userId & ":" & userName & ":" & enabled & ",")
loop
rec.close
%>