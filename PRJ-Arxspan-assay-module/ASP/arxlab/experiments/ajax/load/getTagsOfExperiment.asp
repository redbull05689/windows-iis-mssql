<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp" -->

<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
if canViewExperiment(experimentType, experimentId, session("userId")) Then
	Call getConnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT userId, comment FROM experimentCommentsView WHERE experimentType="&SQLClean(experimentType,"N","S")& " AND experimentId="&SQLClean(experimentId,"N","S")& " AND comment LIKE '#%' ORDER BY id DESC"
	rec.open strQuery,conn,3,3
	Do While Not rec.eof
	%><option value="<%=rec("comment")%>" userid="<%=rec("userId")%>"><%=rec("comment")%></option><%
		rec.movenext
	loop
	Call disconnect
End If
%>