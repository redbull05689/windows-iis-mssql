<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<%
Call getconnectedadm
success = False
experimentId = request.querystring("experimentId")
cdId = request.querystring("cdId")
If ownsExperiment("1",experimentId,session("userId")) then
	strQuery = "UPDATE combiSDMols SET visible=0 WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND cd_id="&SQLClean(cdId,"N","S")
	connAdm.execute(strQuery)
End if
%>
<div id="resultsDiv">success</div>