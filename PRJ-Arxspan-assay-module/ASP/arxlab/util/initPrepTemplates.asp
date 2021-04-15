<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->
<!-- #include file="../_inclds/misc/functions/fnc_initPrepTemplates.asp" -->
<%
if session("companyId") = "1" And 1=2 then
	call getconnectedadm
	Set companyRec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT * FROM companies"
	companyRec.open strQuery,connAdm,3,3
	Do While Not companyRec.eof
		initPrepTemplates(companyRec("id"))
		companyRec.movenext
	Loop
	companyRec.close
	Set companyRec = nothing
	call disconnectadm
end if
%>