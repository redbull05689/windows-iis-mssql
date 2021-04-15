<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
call getconnected
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT TOP 1 id FROM notifications WHERE userId="&SQLClean(session("userId"),"N","S")& " ORDER BY id DESC"
rec.open strQuery,conn,3,3
if not rec.eof then
	response.write(rec("id"))
end If
rec.close
Set rec = nothing
call disconnect
%>