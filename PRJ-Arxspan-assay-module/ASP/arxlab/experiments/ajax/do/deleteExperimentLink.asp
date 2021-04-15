<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
' Delete an experiment link from an experiment
Call getconnectedadm
success = False
experimentType = request.Form("lExperimentType")
experimentId = request.Form("lExperimentId")
linkExperimentType = request.Form("delLinkType")
linkExperimentId = request.Form("delLinkId")
' Link can only be removed by the experiment owner
If ownsExperiment(experimentType,experimentId,session("userId")) then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id, next, prev FROM experimentLinks WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND linkExperimentId=" & SQLClean(linkExperimentId,"N","S") & " AND linkExperimentType=" & SQLClean(linkExperimentType,"N","S")
	rec.open strQuery,connAdm,3,3
	'if the link exists in the experimentLinks table
	If Not rec.eof Then
		' Delete link from this experiment
		strQuery = "DELETE FROM experimentLinks WHERE id="&SQLClean(rec("id"),"N","S")
		connAdm.execute strQuery
		
		' Update the history table's dateRemoved column using GETDATE() for "this" experiment
		strQuery = "UPDATE experimentLinks_history SET dateRemoved=GETDATE() WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND linkExperimentId=" & SQLClean(linkExperimentId,"N","S") & " AND linkExperimentType=" & SQLClean(linkExperimentType,"N","S")
		connAdm.execute strQuery

		If rec("prev") = 1 or rec("next") = 1 Then ' The linked experiment is a "next/prev step" of this one - remove the "prev/next step" link from the linked experiment too
			strQuery = "DELETE FROM experimentLinks WHERE experimentId=" & SQLClean(linkExperimentId,"N","S") & " AND experimentType=" & SQLClean(linkExperimentType,"N","S") & " AND linkExperimentId=" & SQLClean(experimentId,"N","S") & " AND linkExperimentType=" & SQLClean(experimentType,"N","S")
			connAdm.execute strQuery

			' Update the history table's dateRemoved column using GETDATE() for the linked experiment
			strQuery = "UPDATE experimentLinks_history SET dateRemoved=GETDATE() WHERE experimentId=" & SQLClean(linkExperimentId,"N","S") & " AND experimentType=" & SQLClean(linkExperimentType,"N","S") & " AND linkExperimentId=" & SQLClean(experimentId,"N","S") & " AND linkExperimentType=" & SQLClean(experimentType,"N","S")
			connAdm.execute strQuery
		End If

	End If
	rec.close

	' Leaving in this code that deletes from the _preSave table just in case (3.2.16)
	strQuery = "SELECT id FROM experimentLinks_preSave WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND experimentType=" & SQLClean(experimentType,"N","S") & " AND linkExperimentId=" & SQLClean(linkExperimentId,"N","S") & " AND linkExperimentType=" & SQLClean(linkExperimentType,"N","S")
	rec.open strQuery,connAdm,3,3
	'if the link exists in the experimentLinks_preSave table
	If Not rec.eof Then
		strQuery = "DELETE FROM experimentLinks_preSave WHERE id="&SQLClean(rec("id"),"N","S")
		'delete the specified link from the experiment links presave table
		connAdm.execute strQuery
	End If
	rec.close
	Set rec = nothing
End if
%>
<div id="resultsDiv">success</div>