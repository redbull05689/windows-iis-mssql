<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
solvents = Split(experimentJSON.get("solvents"),",")
For i = 0 To UBound(solvents)
	molData = experimentJSON.get(solvents(i) & "_molData")
	molData3000 = experimentJSON.get(solvents(i) & "_molData3000")
	inchiKey = experimentJSON.get(solvents(i) & "_inchiKey")
	cxsmiles = experimentJSON.get(solvents(i) & "_cxsmiles")
	smiles = experimentJSON.get(solvents(i) & "_smiles")

	strQuery = "INSERT into solvents(name,ratio,volume,supplier,reactionMolarity,moles,experimentId,molData,molData3000,cxsmiles,inchiKey,smiles,hasChanged,fragmentId,trivialName,userAdded,inventoryItems,craisClass,craisText,gridState,volumes) values(" &_
			SQLClean(experimentJSON.get(solvents(i) & "_name"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_ratio"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_volume"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_supplier"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_reactionMolarity"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_moles"),"T","S") & "," &_
			SQLClean(experimentId,"N","S") & "," &_
			SQLClean(molData,"T","S") & "," &_
			SQLClean(molData3000,"T","S") & "," &_
			SQLClean(cxsmiles,"T","S") & "," &_
			SQLClean(inchiKey,"T","S") & "," &_
			SQLClean(smiles,"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_hasChanged"),"N","S") &"," &_
			SQLClean(experimentJSON.get(solvents(i) & "_fragmentId"),"N","S") &"," &_
			SQLClean(experimentJSON.get(solvents(i) & "_trivialName"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_userAdded"),"N","S") & ","&_
			SQLClean(experimentJSON.get(solvents(i) & "_inventoryItems"),"T","S") & ","&_
			SQLClean(experimentJSON.get(solvents(i) & "_craisClass"),"T","S") & ","&_
			SQLClean(experimentJSON.get(solvents(i) & "_craisText"),"T","S") & ","&_
			SQLClean(experimentJSON.get(solvents(i) & "_UAStates"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_volumes"),"T","S") & ")"
	connadmTrans.execute(strQuery)

	strQuery = "INSERT into solvents_history(name,ratio,volume,supplier,reactionMolarity,moles,experimentId,revisionId,molData,molData3000,cxsmiles,inchiKey,smiles,fragmentId,trivialName,userAdded,inventoryItems,craisClass,craisText,gridState,volumes) values(" &_
			SQLClean(experimentJSON.get(solvents(i) & "_name"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_ratio"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_volume"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_supplier"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_reactionMolarity"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_moles"),"T","S") & "," &_
			SQLClean(experimentId,"N","S") & "," &_
			SQLClean(revisionNumber,"N","S") & "," &_
			SQLClean(molData,"T","S") & "," &_
			SQLClean(molData3000,"T","S") & "," &_
			SQLClean(cxsmiles,"T","S") & "," &_
			SQLClean(inchiKey,"T","S") & "," &_
			SQLClean(smiles,"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_fragmentId"),"N","S") &"," &_
			SQLClean(experimentJSON.get(solvents(i) & "_trivialName"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_userAdded"),"N","S") & ","&_
			SQLClean(experimentJSON.get(solvents(i) & "_inventoryItems"),"T","S") & ","&_
			SQLClean(experimentJSON.get(solvents(i) & "_craisClass"),"T","S") & ","&_
			SQLClean(experimentJSON.get(solvents(i) & "_craisText"),"T","S") & ","&_
			SQLClean(experimentJSON.get(solvents(i) & "_UAStates"),"T","S") & "," &_
			SQLClean(experimentJSON.get(solvents(i) & "_volumes"),"T","S") &")"
	connadmTrans.execute(strQuery)
Next
%>