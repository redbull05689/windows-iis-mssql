<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
'delete a registration link from an experiment
Call getconnectedadm
experimentType = request.Form("lExperimentType")
experimentId = request.Form("lExperimentId")
requestId = request.Form("delRequestId")

isCoAuthor = true

if experimentType = "5" then	
	isCoAuthor = checkCoAuthors(experimentId, experimentType, "")
end if

'request link can only be removed from experiment if the user is the owner of the experiment and the experiment is not closed
If (ownsExperiment(experimentType,experimentId,session("userId")) or isCoAuthor) And Not isExperimentClosed(experimentType,experimentId) then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM experimentRequests WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND requestId=" & SQLClean(requestId,"T","S")
	rec.open strQuery,connAdm,3,3
	'if link exists in the experimentRequests table
	If Not rec.eof Then
		strQuery = "DELETE FROM experimentRequests WHERE id="&SQLClean(rec("id"),"N","S")
		'delete from experimentRequests table
		connAdm.execute strQuery
	End If
	rec.close
	Set rec = nothing
End if
%>
<div id="resultsDiv">success</div>