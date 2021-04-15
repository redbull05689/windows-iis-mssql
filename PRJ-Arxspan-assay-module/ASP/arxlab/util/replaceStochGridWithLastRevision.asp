<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
if session("email") = "support@arxspan.com" And request.querystring("experimentId") <> "" And request.querystring("workingVersion") <> "" And request.querystring("brokenVersion") then
	experimentId = request.querystring("experimentId")
	workingRevision = request.querystring("workingRevision")
	moveToRevision = request.querystring("brokenVersion")

	call getconnectedAdm
	strQuery = "insert into reactants_history(name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,experimentType,objectTypeId,molData,solvent,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles,revisionId) select name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,experimentType,objectTypeId,molData,solvent,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles,"&moveToRevision&" from reactants_history where experimentId="&SQLClean(experimentId,"N","S")& " AND revisionId="&SQLClean(workingRevision,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE from reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "insert into reactants(name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,experimentType,objectTypeId,molData,solvent,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles) select name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,experimentType,objectTypeId,molData,solvent,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles from reactants_history where experimentId="&SQLClean(experimentId,"N","S")& " AND revisionId="&SQLClean(workingRevision,"N","S")
	connAdm.execute(strQuery)

	strQuery = "insert into reagents_history(name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,experimentType,objectTypeId,molData,solvent,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles,revisionId) select name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,experimentType,objectTypeId,molData,solvent,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles,"&moveToRevision&" from reagents_history where experimentId="&SQLClean(experimentId,"N","S")& " AND revisionId="&SQLClean(workingRevision,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE from reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "insert into reagents(name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,experimentType,objectTypeId,molData,solvent,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles) select name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,experimentType,objectTypeId,molData,solvent,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles from reagents_history where experimentId="&SQLClean(experimentId,"N","S")& " AND revisionId="&SQLClean(workingRevision,"N","S")
	connAdm.execute(strQuery)

	strQuery = "insert into products_history(name,dateExpires,regId,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass,experimentId,experimentType,objectTypeId,molData,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles,revisionId) select name,dateExpires,regId,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass,experimentId,experimentType,objectTypeId,molData,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles,"&moveToRevision&" from products_history where experimentId="&SQLClean(experimentId,"N","S")& " AND revisionId="&SQLClean(workingRevision,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE from products WHERE experimentId="&SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "insert into products(name,dateExpires,regId,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass,experimentId,experimentType,objectTypeId,molData,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles) select name,dateExpires,regId,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass,experimentId,experimentType,objectTypeId,molData,trivialName,userAdded,stepNumber,sortOrder,gridState,molData3000,cxsmiles from products_history where experimentId="&SQLClean(experimentId,"N","S")& " AND revisionId="&SQLClean(workingRevision,"N","S")
	connAdm.execute(strQuery)

	strQuery = "insert into solvents_history(name,ratio,volume,experimentId,experimentType,objectTypeId,trivialName,userAdded,stepNumber,supplier,reactionMolarity,moles,gridState,revisionId) select name,ratio,volume,experimentId,experimentType,objectTypeId,trivialName,userAdded,stepNumber,supplier,reactionMolarity,moles,gridState,"&moveToRevision&" from solvents_history where experimentId="&SQLClean(experimentId,"N","S")& " AND revisionId="&SQLClean(workingRevision,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE from solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "insert into solvents(name,ratio,volume,experimentId,experimentType,objectTypeId,trivialName,userAdded,stepNumber,supplier,reactionMolarity,moles,gridState) select name,ratio,volume,experimentId,experimentType,objectTypeId,trivialName,userAdded,stepNumber,supplier,reactionMolarity,moles,gridState from solvents_history where experimentId="&SQLClean(experimentId,"N","S")& " AND revisionId="&SQLClean(workingRevision,"N","S")
	connAdm.execute(strQuery)

	call disconnectadm
end If
%>


