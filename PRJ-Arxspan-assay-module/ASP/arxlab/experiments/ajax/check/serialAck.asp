<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
'checks if serial number has been added to the database
'the serial number is inserted into the database as the first step in the save process
'this is to prevent experiments from double saving when a save request has to be resent because it was never received by the server
call getconnected
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT COUNT(*) as ackCount FROM serialsAck WITH(NOLOCK) WHERE serial="&SQLClean(request.querystring("serial"),"T","S")
rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
If rec("ackCount") <> 0 Then
	response.write("ack")
End if
rec.close
Set rec = nothing
%>