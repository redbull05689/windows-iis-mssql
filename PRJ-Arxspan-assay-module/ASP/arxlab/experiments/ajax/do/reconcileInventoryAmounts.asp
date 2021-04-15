<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%Server.ScriptTimeout=108000%>
<%
'adds an inventory link to the inventory link table for the specified experiment
Call getconnected
experimentId = request.form("experimentId")
experimentType = request.form("experimentType")

If experimentId <> "" And experimentType <> "" Then
	If ownsExperiment(experimentType,experimentId,session("userId")) Then
		strQuery = "SELECT * FROM inventoryLinks WHERE experimentType="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")
		connAdm.execute(strQuery)
	End If
End If
%>