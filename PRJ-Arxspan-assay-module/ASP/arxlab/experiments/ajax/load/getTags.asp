<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp" -->

<%
Call getConnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, displayText, disabled FROM keywords WHERE companyId="&SQLClean(session("companyId"),"N","S")&" ORDER BY id DESC"
rec.open strQuery,conn,3,3
Do While Not rec.eof
	%><option value="<%=rec("displayText")%>" tagid="<%=rec("id")%>" tagdisabled="<%=rec("disabled")%>"><%=rec("displayText")%></option><%
	rec.movenext
loop
Call disconnect
%>