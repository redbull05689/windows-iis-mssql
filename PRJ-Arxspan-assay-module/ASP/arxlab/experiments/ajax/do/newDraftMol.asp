<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->

<%
'add a new molecule as a draft.  This happens when the molecule needs to be added to the
'stoch grid before the chemistry has been proccessed on the back end

'only the owner of the experiment can do this
If ownsExperiment("1",request.Form("experimentId"),session("userId")) Then
	Call getconnected
	Call getconnectedadm
	'get the table name from the type
	Select Case request.Form("type")
		Case "reactant"
			tableName = "reactants"
		Case "reagent"
			tableName = "reagents"
		Case "product"
			tableName = "products"
		Case "solvent"
			tableName = "solvents"
	End Select
	If tableName <> "" then
		experimentId = request.Form("experimentId")
		fragmentId = request.Form("fragmentId")
		isDraft = "1"
		'set has changed so that the backend converts to mol and gets name etc..
		hasChanged = "1"
		trivialName = request.Form("labelName")
		'get the next available number for the sorting
		set nrRec = server.createobject("ADODB.RecordSet")
		strQuery = "SELECT id FROM "&tableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")
		nrRec.open strQuery,conn,3,3
		sortOrder = nrRec.RecordCount + 1
		nrRec.close
		Set nrRec = Nothing
		strQuery = "IF NOT EXISTS (" &_
					"SELECT 1 FROM " & tableName & " " &_
					"WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND " &_
					"fragmentId=" & SQLClean(fragmentId,"N","S") & ") BEGIN " &_
					"INSERT into "&tableName&"(experimentId,fragmentId,isDraft,sortOrder,trivialName,hasChanged) values(" &_
					SQLClean(experimentId,"N","S") & "," &_
					SQLClean(fragmentId,"N","S") & "," &_
					SQLClean(isDraft,"N","S") & "," &_
					SQLClean(sortOrder,"N","S") & "," &_
					SQLClean(trivialName,"T","S") & "," &_
					SQLClean(hasChanged,"N","S") & ") END"
		'add molecule to database
		connAdm.execute(strQuery)
	End if
	Call disconnect
	Call disconnectadm
End if
%>