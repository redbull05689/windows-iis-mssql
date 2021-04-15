<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
regEnabled = true
%>
<%isAjax=true%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
call getconnected
id = request.querystring("id")
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT id FROM notifications WHERE id>"&SQLClean(id,"N","S")&" AND userId="&SQLClean(session("userId"),"N","S")& " AND dismissed=0 ORDER BY id ASC"
rec.open strQuery,conn,3,3
if not rec.eof then
	response.write(rec("id"))
end If
rec.close
Set rec = nothing
call disconnect
%>