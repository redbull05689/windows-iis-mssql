<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
call getConnectedAdm

set rec = server.createobject("ADODb.RecordSet")
strQuery = "SELECT id FROM exports WHERE userId="&SQLClean(session("userId"),"N","S") & " AND status=1 or status=2"
rec.open strQuery,conn,3,3
if not rec.eof then
	connAdm.execute("UPDATE exports SET status=2 WHERE id="&SQLClean(rec("id"),"N","S"))
	response.write("success")
Else
	response.write(strQuery)
end if

call disconnectAdm
%>