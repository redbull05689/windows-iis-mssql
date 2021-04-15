<%
Function getExperimentsICanView
	Set canViewExps = JSON.parse("[]")
	Call getconnected

	procName = "elnGetVisibleExperiments"
	Set permRec = server.CreateObject("ADODB.RecordSet")

	strQuery = "EXEC dbo." & procName &_
			" @companyId=" & SQLClean(session("companyId"),"N","S") &_
			", @userId=" & SQLClean(session("userId"),"N","S")

	permRec.open strQuery,connNoTimeout,0,-1
	Do While Not permRec.eof
		canViewExps.Push CStr(permRec("uniqueId"))
		permRec.movenext
	Loop
	getExperimentsICanView = JSON.stringify(canViewExps)
End Function
%>