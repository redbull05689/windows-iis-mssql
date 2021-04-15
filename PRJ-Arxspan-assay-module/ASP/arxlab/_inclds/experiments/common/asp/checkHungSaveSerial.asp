<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
cleanSerial = SQLClean(hungSaveSerial,"T","S")

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM serialsAck WHERE serial="&cleanSerial
rec.open strQuery,conn,3,3
If Not rec.eof Then
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery2 = "SELECT id,serial,revisionNumber FROM serialsAck WHERE serial="&cleanSerial&" AND revisionNumber IS NOT NULL"
	rec2.open strQuery2,conn,3,3

	If Not rec2.eof Then
		' serialsAck has the revision number indicating 
		' the experiment has been saved successfully
		revNum = rec2("revisionNumber")

		' this include generates a new hungSaveSerial
		%><!-- #include file="./getExperimentPermissions.asp"--><%

		Set d = JSON.parse("{}")
		d.Set "hungSaveSerial", hungSaveSerial
		d.Set "revisionNumber", revNum
		data = JSON.stringify(d)

		rec2.close
		Set rec2 = nothing
		response.Status = "200"
		response.write(data)
		response.end()
	Else
		rec2.close
		Set rec2 = nothing

		rec.close
		Set rec = nothing

		' Delay for 10 seconds so that the front end doesn't spin out.
		' This is useful for the scenario where the timeout is low and 
		' the user's connection is fast but the save actually takes a 
		' very long time. In the high latency scenario it's just a moot delay.
		Set rec3 = server.CreateObject("ADODB.RecordSet")
		strQuery3 = "WAITFOR DELAY '00:00:10'"
		rec3.open strQuery3,conn,3,3
		Set rec3 = nothing

		response.write("processing")
		response.end()
	End If
End if
rec.close
Set rec = nothing
%>
