<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<%
experimentId = request.querystring("experimentId")
If canViewExperiment("1",experimentId,session("userId")) And session("role") = "Admin" then
	Call getconnected
	Call getconnectedadm
	
	oldRevisionNumber = duplicateAndChangeStatus("1",experimentId,"9",true)
	maxRevisionNumber = getExperimentRevisionNumber("1",experimentId)

	craisStatus = 4
	strQuery2 = "UPDATE experiments SET craisStatus="&SQLClean(craisStatus,"N","S")&" WHERE id="&SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery2)
	strQuery2 = "UPDATE experiments_history SET craisStatus="&SQLClean(craisStatus,"N","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND revisionNumber="&SQLClean(maxRevisionNumber,"N","S")
	connAdm.execute(strQuery2)
	Call disconnect
	Call disconnectadm
	response.redirect(mainAppPath&"/"&session("expPage")&"?id="&experimentId)
End if
%>