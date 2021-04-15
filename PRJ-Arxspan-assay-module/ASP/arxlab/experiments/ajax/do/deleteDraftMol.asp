<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->

<%
'delete molecule draft JSON object from database
experimentId = request.Form("experimentId")
prefix = request.Form("prefix")&"_"
theType = request.Form("type")

'only the experiment owner may delete a molecule draft
If ownsExperiment("1",experimentId,session("userId")) Then
	Call getconnected
	Call getconnectedadm
	Select Case theType
		Case "r"
			tableName = "reactants"
		Case "rg"
			tableName = "reagents"
		Case "p"
			tableName = "products"
		Case "s"
			tableName = "solvents"
	End Select
	If tableName <> "" Then
		strQuery = "DELETE FROM "&tableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND fragmentId="&SQLClean(request.Form("fragmentId"),"N","S")
		'delete the molecule from the appropriate table
		connAdm.execute(strQuery)
		'go through the experiment draft and delete all draft data refering to the specified molecule
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT experimentJSON FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean("1","N","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof then
			Set experimentJSON = JSON.parse(rec("experimentJSON"))
			For Each key In experimentJSON.keys()
				If Mid(key,1,Len(prefix)) = prefix Then
					experimentJSON.purge(key)
				End if
			Next
			experimentJSON.Set "molUpdate","1"
			strQuery = "UPDATE experimentDrafts SET experimentJSON="&SQLClean(JSON.stringify(experimentJSON),"T","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType=1"
			connAdm.execute(strQuery)
		End if
		rec.close
		Set rec = Nothing
	End if
	Call disconnect
	Call disconnectadm
End if
%>