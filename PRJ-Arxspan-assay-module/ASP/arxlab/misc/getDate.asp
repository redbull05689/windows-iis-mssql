<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
call getconnected
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT GETUTCDATE() as theDate"
rec.open strQuery,conn,0,-1
response.write(rec("theDate")&" (GMT)")
rec.close
set rec = Nothing
call disconnect
%>