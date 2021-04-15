<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("regRoleNumber") <= 20 then
	cdId = request.querystring("cdId")
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM INFORMATION_SCHEMA.tables WHERE TABLE_NAME='inventoryLinks'"
	rec.open strQuery,jchemRegConn,0,-1
	If rec.eof Then
		response.end
	End if
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM inventoryLinks WHERE cdId="&SQLClean(cdId,"N","S")
	rec.open strQuery,jchemRegConn,0,-1
	If rec.eof Then
		response.end
	End if
	%>
	<table class="experimentsTable" style="width:40%;">
		<tr>
			<th>Name</th>
			<th>Barcode</th>
			<th>Amount</th>
		</tr>
	<%
	Do While Not rec.eof
		%>
			<tr>
				<td><%=rec("name")%></td>
				<td><a href="<%=mainAppPath%>/inventory2/index.asp?id=<%=rec("inventoryId")%>"><%=rec("barcode")%></a></td>
				<td><%=rec("amount")%></td>
			</tr>
		<%
		rec.moveNext
	Loop
	rec.close
	Set rec = nothing
	%>
	</table>
	<%
	Call disconnectJchemReg	
End if
%>