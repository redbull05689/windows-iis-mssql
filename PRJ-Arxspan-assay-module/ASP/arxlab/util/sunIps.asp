<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%response.buffer = false%>
<%server.scripttimeout = 300%>
<%If session("userId") = "2" then%>
<table>
<%
Call getconnectedlog
set rec = server.createobject("ADODB.RecordSet")
strQuery = "select distinct ip from prodLogsView WHERE companyId=16 and datediff(m,getDATE(),dateSubmitted) >-3 and email not like '%sunovion%'"
rec.open strQuery,connLog,3,3
Do While Not rec.eof
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT count(distinct email) as theCount from prodLogsView WHERE companyId=16 and ip="&SQLClean(rec("ip"),"T","S")
	'response.write(strQuery)
	rec2.open strQuery,connLog,3,3
	If rec2("theCount") > 1 then
		%><tr>
		<td><%=rec("ip")%></td>
		<td><%=rec2("theCount")%></td>
		</tr>
		<%
	End if
	rec2.close
	Set rec2 = Nothing
	rec.movenext
loop
%>
</table>
<%End if%>