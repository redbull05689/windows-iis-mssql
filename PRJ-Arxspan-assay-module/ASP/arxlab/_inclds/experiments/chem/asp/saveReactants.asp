<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
reactions = Split(experimentJSON.get("reactants"),",")
hasLimit = false
For i = 0 To UBound(reactions)
	If experimentJSON.get(reactions(i) & "_limit") = "CHECKED" Then
		hasLimit = true
	End if
next

' Check for limiting reagents too
reagents = Split(experimentJSON.get("reagents"),",")
For i = 0 To UBound(reagents)
	If experimentJSON.get(reagents(i) & "_limit") = "CHECKED" Then
		hasLimit = true
	End if
next

For i = 0 To UBound(reactions)
	molData = experimentJSON.get(reactions(i) & "_molData")
	molData3000 = experimentJSON.get(reactions(i) & "_molData3000")
	inchiKey = experimentJSON.get(reactions(i) & "_inchiKey")
	cxsmiles = experimentJSON.get(reactions(i) & "_cxsmiles")
	smiles = experimentJSON.get(reactions(i) & "_smiles")

	If experimentJSON.get(reactions(i) & "_limit") = "CHECKED" Then
		limit = "1"
	Else
		limit = "0"
	End If
	If Not hasLimit And i=0 Then
		limit = "1"
	End if
	If experimentJSON.get(reactions(i) & "_updated") = "CHECKED" Then
		updated = "1"
	Else
		updated = "0"
	End if	
	strQuery = "INSERT into reactants(name,updated,molecularFormula,molecularWeight,limit,equivalents,weightRatio,moles,sampleMass,volume,supplier,cas,compoundNumber,"&_
				"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,molData,molData3000,cxsmiles,inchiKey,smiles,hasChanged,fragmentId,productId,solvent,trivialName,userAdded,sortOrder,inventoryItems,craisClass,craisText,gridState) values(" &_
				SQLClean(experimentJSON.get(reactions(i) & "_name"),"T","S") & "," &_
				SQLClean(updated,"N","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_molecularFormula"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_molecularWeight"),"T","S") & "," &_
				SQLClean(limit,"N","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_equivalents"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_weightRatio"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_moles"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_sampleMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_volume"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_supplier"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_cas"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_compoundNumber"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_barcode"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_molarity"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_density"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_percentWT"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_formulaMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_reactantMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_loading"),"T","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean(molData,"T","S") & "," &_
				SQLClean(molData3000,"T","S") & "," &_
				SQLClean(cxsmiles,"T","S") & "," &_
				SQLClean(inchiKey,"T","S") & "," &_
				SQLClean(smiles,"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_hasChanged"),"N","S") &"," &_
				SQLClean(experimentJSON.get(reactions(i) & "_fragmentId"),"N","S") &"," &_
				SQLClean(experimentJSON.get(reactions(i) & "_productId"),"T","S") &"," &_
				SQLClean(experimentJSON.get(reactions(i) & "_solvent"),"T","S") &"," &_
				SQLClean(experimentJSON.get(reactions(i) & "_trivialName"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reactions(i) & "_userAdded"),"N","S")&","&_
				SQLClean(i+1,"N","S")& "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_inventoryItems"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reactions(i) & "_craisClass"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reactions(i) & "_craisText"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reactions(i) & "_UAStates"),"T","S") & ")"
	'If experimentJSON.get("chemDrawChanged") <> "1" Or experimentJSON.get(reactions(i) & "_userAdded") = "1" then
		connadmTrans.execute(strQuery)
	'End if
	'connadmTrans.execute("exec bingo.FlushOperations 'reactants';")

	strQuery = "INSERT into reactants_history(name,updated,molecularFormula,molecularWeight,limit,equivalents,weightRatio,moles,sampleMass,volume,supplier,cas,compoundNumber,"&_
				"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,revisionId,molData,molData3000,cxsmiles,inchiKey,smiles,fragmentId,productId,solvent,trivialName,userAdded,sortOrder,inventoryItems,craisClass,craisText,gridState) values(" &_
				SQLClean(experimentJSON.get(reactions(i) & "_name"),"T","S") & "," &_
				SQLClean(updated,"N","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_molecularFormula"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_molecularWeight"),"T","S") & "," &_
				SQLClean(limit,"N","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_equivalents"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_weightRatio"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_moles"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_sampleMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_volume"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_supplier"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_cas"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_compoundNumber"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_barcode"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_molarity"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_density"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_percentWT"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_formulaMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_reactantMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_loading"),"T","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean(revisionNumber,"N","S") & "," &_
				SQLClean(molData,"T","S") & "," &_
				SQLClean(molData3000,"T","S") & "," &_
				SQLClean(cxsmiles,"T","S") & "," &_
				SQLClean(inchiKey,"T","S") & "," &_
				SQLClean(smiles,"T","S") & "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_fragmentId"),"N","S") &"," &_
				SQLClean(experimentJSON.get(reactions(i) & "_productId"),"T","S") &"," &_
				SQLClean(experimentJSON.get(reactions(i) & "_solvent"),"T","S") &"," &_
				SQLClean(experimentJSON.get(reactions(i) & "_trivialName"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reactions(i) & "_userAdded"),"N","S")&","&_
				SQLClean(i+1,"N","S")& "," &_
				SQLClean(experimentJSON.get(reactions(i) & "_inventoryItems"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reactions(i) & "_craisClass"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reactions(i) & "_craisText"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reactions(i) & "_UAStates"),"T","S") & ")"
	'If experimentJSON.get("chemDrawChanged") <> "1" Or experimentJSON.get(reactions(i) & "_userAdded") = "1" then
		connadmTrans.execute(strQuery)
	'End if
Next
%>