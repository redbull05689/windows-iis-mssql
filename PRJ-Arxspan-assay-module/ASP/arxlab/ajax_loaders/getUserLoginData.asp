<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
usersTable = getDefaultSingleAppConfigSetting("usersTable")
logTable = getDefaultSingleAppConfigSetting("logTableName")

' Get the user and people managed by this user if they're a manager
usersICanSee = getMyselfAndPeopleIManage()

' include the current user
sqlClauseUserId = ""
If usersICanSee = "" Then
	sqlClauseUserId =  "l.userId=" & SQLClean(session("userId"),"N","S")
Else
	sqlClauseUserId =  "l.userId in (" & session("userId") & "," & usersICanSee & ")"
End If

startDate = request.querystring("startDate")
endDate = request.querystring("endDate")

sqlClauseDateRange = ""
If startDate <> "" Then
	sqlClauseDateRange =  " AND l.dateSubmittedServer>=" & SQLClean(startDate,"D","S")
End If

If endDate <> "" Then
	sqlClauseDateRange = sqlClauseDateRange & " AND l.dateSubmittedServer< DATEADD(d, 1, " & SQLClean(endDate,"D","S") & ") "
End If

call getconnectedadm
Set uRec = Server.CreateObject("ADODB.RecordSet")

' Have SQL Server to return the user login data in JSON format directly
strQuery = "SELECT ROW_NUMBER() OVER(ORDER BY l.id DESC) AS RN, u.firstName + ' ' + u.lastName AS UN, "
strQuery = strQuery & "dateSubmitted as LT "

	
strQuery = strQuery & "FROM [LOGS].dbo." & logTable & " l WITH(NOLOCK) INNER JOIN " & usersTable &" u WITH(NOLOCK) ON l.userId = u.id "
If session("companyId") <> "1" Then
	strQuery = strQuery & "WHERE l. companyId=" & SQLClean(session("companyId"),"N","S") & " AND " & sqlClauseUserId & " AND l.actionId=10 " & sqlClauseDateRange
Else 
	strQuery = strQuery & "WHERE " & sqlClauseUserId & " AND l.actionId=10 " & sqlClauseDateRange
End If
strQuery = strQuery & " ORDER BY l.id DESC FOR JSON AUTO;"

uRec.open strQuery,conn, -1, 1

If Not uRec.eof Then
	Do While Not uRec.eof
		response.write uRec.Fields.Item(0)
		uRec.movenext
	Loop
Else
	Set rows = JSON.parse("[]")
	response.write JSON.stringify(rows)
End If
uRec.close
Set uRec = Nothing
%>	