<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
response.buffer = false
if session("email")="support@arxspan.com" then
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experiments"
	max = 20000
	counter = 0
	rec.open strQuery,conn,0,-1
	Do While Not rec.eof
		counter = counter + 1
		%>
		<img src="<%=mainAppPath%>/getProds.asp?experimentId=<%=rec("id")%>">
		<br/>
		<%
		If counter = max Then
			Exit do
		End If
		rec.movenext
	loop
	Call disconnect
end If
%>