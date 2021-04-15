<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
'delete a registration link from an experiment
Call getconnectedadm
success = False
experimentType = request.Form("lExperimentType")
experimentId = request.Form("lExperimentId")
regNumber = request.Form("delRegNumber")

'registration link can only be removed from experiment if the user is the owner of the experiment and the experiment is not closed
If ownsExperiment(experimentType,experimentId,session("userId")) And Not isExperimentClosed(experimentType,experimentId) then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM experimentRegLinks WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND regNumber=" & SQLClean(regNumber,"T","S")
	rec.open strQuery,connAdm,3,3
	'if link exists in the experimentRegLinks table
	If Not rec.eof Then
		strQuery = "DELETE FROM experimentRegLinks WHERE id="&SQLClean(rec("id"),"N","S")
		'delete from experimentRegLinks table
		connAdm.execute strQuery
	End If
	rec.close
	strQuery = "SELECT id FROM experimentRegLinks_preSave WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND regNumber=" & SQLClean(regNumber,"T","S")
	rec.open strQuery,connAdm,3,3
	'if the link is in the presave table
	If Not rec.eof Then
		strQuery = "DELETE FROM experimentRegLinks_preSave WHERE id="&SQLClean(rec("id"),"N","S")
		'delete link from the presave table
		connAdm.execute strQuery
	End If
	rec.close
	Set rec = nothing
End if
%>
<div id="resultsDiv">success</div>