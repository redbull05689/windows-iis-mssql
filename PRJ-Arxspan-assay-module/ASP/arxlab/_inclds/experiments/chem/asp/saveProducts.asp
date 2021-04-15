<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
products = Split(experimentJSON.get("products"),",")
For i = 0 To UBound(products)
	molData = experimentJSON.get(products(i) & "_molData")
	molData3000 = experimentJSON.get(products(i) & "_molData3000")
	inchiKey = experimentJSON.get(products(i) & "_inchiKey")
	cxsmiles = experimentJSON.get(products(i) & "_cxsmiles")
	smiles = experimentJSON.get(products(i) & "_smiles")

	strQuery = "INSERT into products(name,dateExpires,regId,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass,experimentId,molData,molData3000,cxsmiles,inchiKey,smiles,hasChanged,fragmentId,trivialName,userAdded,sortOrder,inventoryItems,craisClass,craisText,gridState) values(" &_
				SQLClean(experimentJSON.get(products(i) & "_name"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_dateExpires"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_regId"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_batch"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_molecularFormula"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_molecularWeight"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_actualMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_actualMoles"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_yield"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_purity"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_theoreticalMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_theoreticalMoles"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_equivalents"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_submittedAmount"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_barcode"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_compoundNumber"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_tempId"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_formulaMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_loading"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_measuredMass"),"T","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean(molData,"T","S") & "," &_
				SQLClean(molData3000,"T","S") & "," &_
				SQLClean(cxsmiles,"T","S") & "," &_
				SQLClean(inchiKey,"T","S") & "," &_
				SQLClean(smiles,"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_hasChanged"),"N","S") &"," &_
				SQLClean(experimentJSON.get(products(i) & "_fragmentId"),"N","S") &"," &_
				SQLClean(experimentJSON.get(products(i) & "_trivialName"),"T","S") & ","&_
				SQLClean(experimentJSON.get(products(i) & "_userAdded"),"N","S")&","&_
				SQLClean(i+1,"N","S")& "," &_
				SQLClean(experimentJSON.get(products(i) & "_inventoryItems"),"T","S") & ","&_
				SQLClean(experimentJSON.get(products(i) & "_craisClass"),"T","S") & ","&_
				SQLClean(experimentJSON.get(products(i) & "_craisText"),"T","S") & ","&_
				SQLClean(experimentJSON.get(products(i) & "_UAStates"),"T","S") & ")"
	'If experimentJSON.get("chemDrawChanged") <> "1" Or experimentJSON.get(products(i) & "_userAdded") = "1" then
		connadmTrans.execute(strQuery)
	'End if

	strQuery = "INSERT into products_history(name,dateExpires,regId,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass,experimentId,revisionId,molData,molData3000,cxsmiles,inchiKey,smiles,fragmentId,trivialName,userAdded,sortOrder,inventoryItems,craisClass,craisText,gridState) values(" &_
				SQLClean(experimentJSON.get(products(i) & "_name"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_dateExpires"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_regId"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_batch"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_molecularFormula"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_molecularWeight"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_actualMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_actualMoles"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_yield"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_purity"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_theoreticalMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_theoreticalMoles"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_equivalents"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_submittedAmount"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_barcode"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_compoundNumber"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_tempId"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_formulaMass"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_loading"),"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_measuredMass"),"T","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean(revisionNumber,"N","S") & "," &_
				SQLClean(molData,"T","S") & "," &_
				SQLClean(molData3000,"T","S") & "," &_
				SQLClean(cxsmiles,"T","S") & "," &_
				SQLClean(inchiKey,"T","S") & "," &_
				SQLClean(smiles,"T","S") & "," &_
				SQLClean(experimentJSON.get(products(i) & "_fragmentId"),"N","S") &"," &_
				SQLClean(experimentJSON.get(products(i) & "_trivialName"),"T","S") & ","&_
				SQLClean(experimentJSON.get(products(i) & "_userAdded"),"N","S")&","&_
				SQLClean(i+1,"N","S")& "," &_
				SQLClean(experimentJSON.get(products(i) & "_inventoryItems"),"T","S") & ","&_
				SQLClean(experimentJSON.get(products(i) & "_craisClass"),"T","S") & ","&_
				SQLClean(experimentJSON.get(products(i) & "_craisText"),"T","S") & ","&_
				SQLClean(experimentJSON.get(products(i) & "_UAStates"),"T","S") & ")"
	'If experimentJSON.get("chemDrawChanged") <> "1" Or experimentJSON.get(products(i) & "_userAdded") = "1" then
		connadmTrans.execute(strQuery)
	'End if
Next
%>