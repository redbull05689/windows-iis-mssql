<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
reagents = Split(experimentJSON.get("reagents"),",")
For i = 0 To UBound(reagents)
	molData = experimentJSON.get(reagents(i) & "_molData")
	molData3000 = experimentJSON.get(reagents(i) & "_molData3000")
	inchiKey = experimentJSON.get(reagents(i) & "_inchiKey")
	cxsmiles = experimentJSON.get(reagents(i) & "_cxsmiles")
	smiles = experimentJSON.get(reagents(i) & "_smiles")

	If experimentJSON.get(reagents(i) & "_limit") = "CHECKED" Then
		limit = "1"
	Else
		limit = "0"
	End If
	If experimentJSON.get(reagents(i) & "_updated") = "CHECKED" Then
		updated = "1"
	Else
		updated = "0"
	End if	
	strQuery = "INSERT into reagents(name,updated,molecularFormula,molecularWeight,limit,equivalents,weightRatio,moles,sampleMass,volume,supplier,cas,compoundNumber,"&_
				"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,molData,molData3000,cxsmiles,inchiKey,smiles,hasChanged,fragmentId,productId,solvent,trivialName,userAdded,sortOrder,inventoryItems,craisClass,craisText,gridState) values(" &_
				SQLClean(experimentJSON.get(reagents(i) & "_name"),"T","S") & "," &_
				SQLClean(updated,"N","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_molecularFormula"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_molecularWeight"),"T","S") & "," &_
				SQLClean(limit,"N","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_equivalents"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_weightRatio"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_moles"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_sampleMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_volume"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_supplier"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_cas"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_compoundNumber"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_barcode"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_molarity"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_density"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_percentWT"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_formulaMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_reactantMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_loading"),"T","S") & "," &_
				SQLClean(experimentId,"N","S") & "," & _
				SQLClean(molData,"T","S") & "," &_
				SQLClean(molData3000,"T","S") & "," &_
				SQLClean(cxsmiles,"T","S") & "," &_
				SQLClean(inchiKey,"T","S") & "," &_
				SQLClean(smiles,"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_hasChanged"),"N","S") &"," &_
				SQLClean(experimentJSON.get(reagents(i) & "_fragmentId"),"N","S") &"," &_
				SQLClean(experimentJSON.get(reagents(i) & "_productId"),"T","S") &"," &_
				SQLClean(experimentJSON.get(reagents(i) & "_solvent"),"T","S") &"," &_
				SQLClean(experimentJSON.get(reagents(i) & "_trivialName"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reagents(i) & "_userAdded"),"N","S")&","&_
				SQLClean(i+1,"N","S")& "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_inventoryItems"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reagents(i) & "_craisClass"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reagents(i) & "_craisText"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reagents(i) & "_UAStates"),"T","S") & ")"
	'If experimentJSON.get("chemDrawChanged") <> "1" Or experimentJSON.get(reagents(i) & "_userAdded") = "1" then
		connadmTrans.execute(strQuery)
	'End if
	'connadmTrans.execute("exec bingo.FlushOperations 'reagents';")

	strQuery = "INSERT into reagents_history(name,updated,molecularFormula,molecularWeight,limit,equivalents,weightRatio,moles,sampleMass,volume,supplier,cas,compoundNumber,"&_
				"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,revisionId,molData,molData3000,cxsmiles,inchiKey,smiles,fragmentId,productId,solvent,trivialName,userAdded,sortOrder,inventoryItems,craisClass,craisText,gridState) values(" &_
				SQLClean(experimentJSON.get(reagents(i) & "_name"),"T","S") & "," &_
				SQLClean(updated,"N","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_molecularFormula"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_molecularWeight"),"T","S") & "," &_
				SQLClean(limit,"N","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_equivalents"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_weightRatio"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_moles"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_sampleMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_volume"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_supplier"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_cas"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_compoundNumber"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_barcode"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_molarity"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_density"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_percentWT"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_formulaMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_reactantMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_loading"),"T","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean(revisionNumber,"N","S") & "," &_
				SQLClean(molData,"T","S") & "," &_
				SQLClean(molData3000,"T","S") & "," &_
				SQLClean(cxsmiles,"T","S") & "," &_
				SQLClean(inchiKey,"T","S") & "," &_
				SQLClean(smiles,"T","S") & "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_fragmentId"),"N","S") &"," &_
				SQLClean(experimentJSON.get(reagents(i) & "_productId"),"T","S") &"," &_
				SQLClean(experimentJSON.get(reagents(i) & "_solvent"),"T","S") &"," &_
				SQLClean(experimentJSON.get(reagents(i) & "_trivialName"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reagents(i) & "_userAdded"),"N","S")&","&_
				SQLClean(i+1,"N","S")& "," &_
				SQLClean(experimentJSON.get(reagents(i) & "_inventoryItems"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reagents(i) & "_craisClass"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reagents(i) & "_craisText"),"T","S") & ","&_
				SQLClean(experimentJSON.get(reagents(i) & "_UAStates"),"T","S") & ")"
	'If experimentJSON.get("chemDrawChanged") <> "1" Or experimentJSON.get(reagents(i) & "_userAdded") = "1" then
		connadmTrans.execute(strQuery)
	'End if
Next
%>