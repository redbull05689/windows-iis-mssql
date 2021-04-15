<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->
<%
Call getconnectedadm
experimentId = request.querystring("experimentId")
requesteeId = request.querystring("requesteeId")
experimentType = request.querystring("experimentType")
errorStr = requestWitness(experimentType,experimentId,requesteeId)
title = "Witness Request"
Set rec = server.CreateObject("ADODB.RecordSet")
prefix = GetPrefix(experimentType)
tableName = GetFullName(prefix, "experiments", true)
strQuery = "SELECT name FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S")
page = GetExperimentPage(prefix)
rec.open strQuery,conn,3,3
If Not rec.eof Then
	experimentName = rec("name")
End if
note = "The user "&session("firstName") & " " & session("lastName") & " has requested that you witness <a href=""" & page & "?id="&experimentId&""">"&experimentName&"</a>"

a = sendNotification(requesteeId,title,note,7)
Call disconnectadm
%>