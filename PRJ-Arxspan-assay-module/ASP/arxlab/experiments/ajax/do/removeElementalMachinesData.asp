<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
'remove note from experiment
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
rowId = request.querystring("rowId")

'only the experiment owner can remove a note
If ownsExperiment(experimentType,experimentId,session("userId")) then
	Call getconnectedadm
	revisionNumber = 1 + getExperimentRevisionNumber(experimentType, experimentId)
	strQuery = "UPDATE elementalMachinesData SET visible=0, revisionDeleted="&SQLClean(revisionNumber,"N","S")&" WHERE id="&SQLClean(rowId,"N","S")&" and experimentId="&SQLClean(experimentId,"N","S")&" and experimentType="&SQLClean(experimentType,"N","S")
	connAdm.execute(strQuery)
	Call disconnectadm
End if
%>