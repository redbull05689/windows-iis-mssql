<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<%
If session("userId") = "2" then
	Call getconnectedadm
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM users"
	rec.open strQuery,connAdm,3,3
	Do While Not rec.eof
		userId = rec("id")
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM witnessRequests WHERE requesterId="&SQLClean(userId,"N","S")&" ORDER BY id desc"
		rec2.open strQuery,connAdm,3,3
		If Not rec2.eof Then
			lastWitnessId = rec2("requesteeId")
		Else
			lastWitnessId = null
		End If
		rec2.close
		Set rec2 = Nothing
		
		If Not IsNull(lastWitnessId) Then
			connAdm.execute("UPDATE users set defaultWitnessId="&SQLClean(lastWitnessId,"N","S") & " WHERE id="&SQLClean(userId,"N","S"))	
		End if
		rec.movenext
	Loop
	rec.close
	Set rec = nothing

	Call disconnectAdm
End if
%>