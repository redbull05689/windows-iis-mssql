<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentId = request.querystring("id")
experimentType = request.querystring("type")

if canViewExperiment(experimentType,experimentId,session("userId")) then
	call getconnected
	set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT inventoryId, name, amount FROM inventoryLinks WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	rec.open strQuery,conn,3,3
	do while not rec.eof
		%>
			<a href="<%=mainAppPath%>/inventory2/index.asp?id=<%=rec("inventoryId")%>"><%=rec("name")%>&nbsp;<%=rec("amount")%></a><br/>
		<%
		rec.movenext
	loop
	rec.close
	set rec = nothing
	call disconnect
end If
%>