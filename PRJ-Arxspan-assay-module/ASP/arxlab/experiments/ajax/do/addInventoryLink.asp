<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
'adds an inventory link to the inventory link table for the specified experiment
Call getconnectedadm
experimentId = request.form("experimentId")
experimentType = request.form("experimentType")
amount = request.form("amount")
collectionName = request.form("collectionName")
fieldName = request.form("fieldName")
name = request.form("name")
id = request.form("id")
fragmentId = request.form("fragmentId")

If experimentId <> "" And experimentType <> "" Then
	If ownsExperiment(experimentType,experimentId,session("userId")) Then
		strQuery = "INSERT into inventoryLinks(experimentId,experimentType,inventoryId,name,amount,mongoCollection,fieldName,fragmentId) values("&_
					SQLClean(experimentId,"N","S")&","&_
					SQLClean(experimentType,"N","S")&","&_
					SQLClean(id,"N","S")&","&_
					SQLClean(name,"T","S")&","&_
					SQLClean(amount,"T","S")&","&_
					SQLClean(collectionName,"T","S")&","&_
					SQLClean(fieldName,"T","S")&","&_
					SQLClean(fragmentId,"N","S")&")"
		connAdm.execute(strQuery)
	End If
End If
%>