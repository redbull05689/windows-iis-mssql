<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'returns the amount of time in seconds that a user has been inactive
'this is used to enable session timeouts
'when a user completes an action the lastActivityTime in their row in the users table is set to the current time.
'This allows us to get the inactivity time by subtracting NOW - lastActivityTime
'the lastActivity time is reset by a ajax call that looks once every 60 if there has been a keypress, mousemove, scroll, or click
retVal = 0
On Error Resume Next
usersTable = getDefaultSingleAppConfigSetting("usersTable")
call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DATEDIFF(second,lastActivityTime,GETUTCDATE()) as inactivityTime from "&usersTable&" WHERE id="&SQLClean(session("userId"),"N","S")
rec.open strQuery,conn,0,-1
If Not IsNull(rec("inactivityTime")) Then
	retVal = rec("inactivityTime")
End if
rec.close
Set rec = nothing
call disconnect
On Error Goto 0
response.write retVal
%>