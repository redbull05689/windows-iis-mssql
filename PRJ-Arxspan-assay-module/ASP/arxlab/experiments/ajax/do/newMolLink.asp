<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->

<%
'add inventory link for a molecule in the grid
experimentId = request.form("experimentId")
inventoryId = request.form("inventoryId")
inventoryName = request.form("inventoryName")
molName = request.form("molName") 'trivial name in grid
if ownsExperiment("1",experimentId,session("userId")) then
	call getconnectedadm
	strQuery = "INSERT into inventoryMolLinks(molName,inventoryName,inventoryId,cleared) values(" &_
			SQLClean(molName,"T","S") & "," &_
			SQLClean(inventoryName,"T","S") & "," &_
			SQLClean(inventoryId,"N","S") & ",0)"
	connAdm.execute(strQuery)
	call disconnectadm
end if
%>