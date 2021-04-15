<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/database/functions/fnc_callStoredProcedure.asp"-->
<!-- #include file="../../chem/functions/fnc_copyChemistryData.asp"-->
<%
function duplicateAndChangeStatus(experimentType,experimentId,statusId,updateMolecules)
	'programtically save
	'make a new version of the history and a new record for the experiment and change the status of the new record
	'used mostly to update the experiment to the witnessed,signed and rejected states
	Dim revisionNumber
	call getconnectedadm
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "experiments", true)
	
	doIt = True
	If CStr(statusId) = "5" Or CStr(statusId) = "6" Then
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")&" AND statusId="&SQLClean(statusId,"N","S")
		rec.open strQuery,connAdm,0,-1
		If Not rec.eof Then
			doIt = False
		End if
	End If
	
	If doIt then
		'!!!!!!!!!!!!!!! CALL STORED PROCEDURE !!!!!!!!!!!!!!!!!!!!
		Set args = JSON.parse("{}")
		Call addStoredProcedureArgument(args, "experimentId", adBigInt, SQLClean(experimentId,"N","S"))
		Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
		Call addStoredProcedureArgument(args, "statusId", adInteger, SQLClean(statusId,"N","N"))
		oldRevisionNumber = callStoredProcedure("elnUpdateExperimentStatusNoDataChanged", args, False)
		revisionNumber = oldRevisionNumber + 1

		If experimentType="1" Then
			'if chemistry experiment

			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT userId, cdx, molData from experiments WHERE id="&SQLClean(experimentId,"N","S") & " ORDER by revisionNumber DESC"
			rec.open strQuery,connAdm,3,3
			If Not rec.eof Then
				'if experiment exists
				'experiment owner id
				userId = rec("userId")
				
				If CStr(statusId) <> "" then
					'ELN-1331 adding the last parameter - "0" because only saved changes will be moved to the new experiment
					Call copyChemistryData(rec("userId"), rec("userId"), experimentId, experimentId, revisionNumber, oldRevisionNumber, "0")
				End if
				
				Set rec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM experiment_steps WHERE experimentId="&SQLClean(experimentId,"N","S")
				rec.open strQuery,connAdm,3,3
				Do While Not rec.eof
					strQuery = "INSERT INTO experiment_stepsHistory(experimentId,revisionNumber,stepNumber,cdx) values(" &_
							SQLClean(experimentId,"N","S") & "," &_
							SQLClean(revisionNumber,"N","S") & "," &_
							SQLClean(rec("stepNumber"),"N","S") & "," &_
							SQLClean(rec("cdx"),"T","S") & ")"
					connAdm.execute(strQuery)
					rec.movenext
				loop

				Set attachmentRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
				attachmentRec.open strQuery,connadm,3,3
				'loop through all reactants
				Do While Not attachmentRec.eof
					'insert a new history record for the current revision with the current reactanr data (not creating a new record because nothing is going to change)
					strQuery = "INSERT into reactants_history(name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,"&_
								"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,revisionId,solvent,trivialName,smiles,fragmentId,userAdded,stepNumber,molData,molData3000,cxsmiles,craisClass,craisText,gridState,inventoryItems,sortOrder) values(" &_
								SQLClean(attachmentRec("name"),"T","S") & "," &_
								SQLClean(attachmentRec("updated"),"N","S") & "," &_
								SQLClean(attachmentRec("molecularFormula"),"T","S") & "," &_
								SQLClean(attachmentRec("molecularWeight"),"T","S") & "," &_
								SQLClean(attachmentRec("limit"),"N","S") & "," &_
								SQLClean(attachmentRec("equivalents"),"T","S") & "," &_
								SQLClean(attachmentRec("moles"),"T","S") & "," &_
								SQLClean(attachmentRec("sampleMass"),"T","S") & "," &_
								SQLClean(attachmentRec("volume"),"T","S") & "," &_
								SQLClean(attachmentRec("supplier"),"T","S") & "," &_
								SQLClean(attachmentRec("cas"),"T","S") & "," &_
								SQLClean(attachmentRec("compoundNumber"),"T","S") & "," &_
								SQLClean(attachmentRec("barcode"),"T","S") & "," &_
								SQLClean(attachmentRec("molarity"),"T","S") & "," &_
								SQLClean(attachmentRec("density"),"T","S") & "," &_
								SQLClean(attachmentRec("percentWT"),"T","S") & "," &_
								SQLClean(attachmentRec("formulaMass"),"T","S") & "," &_
								SQLClean(attachmentRec("reactantMass"),"T","S") & "," &_
								SQLClean(attachmentRec("loading"),"T","S") & "," &_
								SQLClean(attachmentRec("experimentId"),"N","S") & "," &_
								SQLClean(revisionNumber,"N","S")&","&_
								SQLClean(attachmentRec("solvent"),"T","S") & "," &_
								SQLClean(attachmentRec("trivialName"),"T","S") & "," &_
								SQLClean(attachmentRec("smiles"),"T","S") & "," &_
								SQLClean(attachmentRec("fragmentId"),"N","S") & "," &_
								SQLClean(attachmentRec("userAdded"),"N","S") & "," &_
								SQLClean(attachmentRec("stepNumber"),"N","S") & "," &_
								SQLClean(attachmentRec("molData"),"T","S") & "," &_
								SQLClean(attachmentRec("molData3000"),"T","S") & "," &_
								SQLClean(attachmentRec("cxsmiles"),"T","S") & "," &_
								SQLClean(attachmentRec("craisClass"),"T","S") & "," &_
								SQLClean(attachmentRec("craisText"),"T","S") & "," &_
								SQLClean(attachmentRec("gridState"),"T","S") & "," &_
								SQLClean(attachmentRec("inventoryItems"),"T","S") & "," &_
								SQLClean(attachmentRec("sortOrder"),"N","S") & ")"
					If attachmentRec("userAdded") = "1" Or updateMolecules then
						connadm.execute(strQuery)
					End if
					attachmentRec.movenext
				Loop
				attachmentRec.close

				strQuery = "SELECT * FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
				attachmentRec.open strQuery,connadm,3,3
				'loop through all the reagent data
				Do While Not attachmentRec.eof
					'insert a new history record for the current revision with the current reagent data (not creating a new record because nothing is going to change)
					strQuery = "INSERT into reagents_history(name,updated,molecularFormula,molecularWeight,limit,equivalents,moles,sampleMass,volume,supplier,cas,compoundNumber,"&_
								"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,revisionId,solvent,trivialName,smiles,fragmentId,userAdded,stepNumber,molData,molData3000,cxsmiles,craisClass,craisText,gridState,inventoryItems,sortOrder) values(" &_
								SQLClean(attachmentRec("name"),"T","S") & "," &_
								SQLClean(attachmentRec("updated"),"N","S") & "," &_
								SQLClean(attachmentRec("molecularFormula"),"T","S") & "," &_
								SQLClean(attachmentRec("molecularWeight"),"T","S") & "," &_
								SQLClean(attachmentRec("limit"),"N","S") & "," &_
								SQLClean(attachmentRec("equivalents"),"T","S") & "," &_
								SQLClean(attachmentRec("moles"),"T","S") & "," &_
								SQLClean(attachmentRec("sampleMass"),"T","S") & "," &_
								SQLClean(attachmentRec("volume"),"T","S") & "," &_
								SQLClean(attachmentRec("supplier"),"T","S") & "," &_
								SQLClean(attachmentRec("cas"),"T","S") & "," &_
								SQLClean(attachmentRec("compoundNumber"),"T","S") & "," &_
								SQLClean(attachmentRec("barcode"),"T","S") & "," &_
								SQLClean(attachmentRec("molarity"),"T","S") & "," &_
								SQLClean(attachmentRec("density"),"T","S") & "," &_
								SQLClean(attachmentRec("percentWT"),"T","S") & "," &_
								SQLClean(attachmentRec("formulaMass"),"T","S") & "," &_
								SQLClean(attachmentRec("reactantMass"),"T","S") & "," &_
								SQLClean(attachmentRec("loading"),"T","S") & "," &_
								SQLClean(attachmentRec("experimentId"),"N","S") & "," &_
								SQLClean(revisionNumber,"N","S")&","&_
								SQLClean(attachmentRec("solvent"),"T","S") & "," &_
								SQLClean(attachmentRec("trivialName"),"T","S") & "," &_
								SQLClean(attachmentRec("smiles"),"T","S") & "," &_
								SQLClean(attachmentRec("fragmentId"),"N","S") & "," &_
								SQLClean(attachmentRec("userAdded"),"N","S") & "," &_
								SQLClean(attachmentRec("stepNumber"),"N","S") & "," &_
								SQLClean(attachmentRec("molData"),"T","S") & "," &_
								SQLClean(attachmentRec("molData3000"),"T","S") & "," &_
								SQLClean(attachmentRec("cxsmiles"),"T","S") & "," &_
								SQLClean(attachmentRec("craisClass"),"T","S") & "," &_
								SQLClean(attachmentRec("craisText"),"T","S") & "," &_
								SQLClean(attachmentRec("gridState"),"T","S") & "," &_
								SQLClean(attachmentRec("inventoryItems"),"T","S") & "," &_
								SQLClean(attachmentRec("sortOrder"),"N","S") & ")"
					If attachmentRec("userAdded") = "1" Or updateMolecules then
						connadm.execute(strQuery)
					End if
					attachmentRec.movenext
				Loop
				attachmentRec.close

				strQuery = "SELECT * FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")
				attachmentRec.open strQuery,connadm,3,3
				'loop through all the product data
				Do While Not attachmentRec.eof
					'insert a new history record for the current revision with the current product data (not creating a new record because nothing is going to change)
					strQuery = "INSERT into products_history(name,dateExpires,regId,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,experimentId,measuredMass,revisionId,trivialName,smiles,fragmentId,userAdded,stepNumber,molData,molData3000,cxsmiles,craisClass,craisText,gridState,inventoryItems,sortOrder) values(" &_
								SQLClean(attachmentRec("name"),"T","S") & "," &_
								SQLClean(attachmentRec("dateExpires"),"T","S") & "," &_
								SQLClean(attachmentRec("regId"),"T","S") & "," &_
								SQLClean(attachmentRec("batch"),"T","S") & "," &_
								SQLClean(attachmentRec("molecularFormula"),"T","S") & "," &_
								SQLClean(attachmentRec("molecularWeight"),"T","S") & "," &_
								SQLClean(attachmentRec("actualMass"),"T","S") & "," &_
								SQLClean(attachmentRec("actualMoles"),"T","S") & "," &_
								SQLClean(attachmentRec("yield"),"T","S") & "," &_
								SQLClean(attachmentRec("purity"),"T","S") & "," &_
								SQLClean(attachmentRec("theoreticalMass"),"T","S") & "," &_
								SQLClean(attachmentRec("theoreticalMoles"),"T","S") & "," &_
								SQLClean(attachmentRec("equivalents"),"T","S") & "," &_
								SQLClean(attachmentRec("submittedAmount"),"T","S") & "," &_
								SQLClean(attachmentRec("barcode"),"T","S") & "," &_
								SQLClean(attachmentRec("compoundNumber"),"T","S") & "," &_
								SQLClean(attachmentRec("tempId"),"T","S") & "," &_
								SQLClean(attachmentRec("formulaMass"),"T","S") & "," &_
								SQLClean(attachmentRec("loading"),"T","S") & "," &_
								SQLClean(attachmentRec("experimentId"),"N","S") & "," &_
								SQLClean(attachmentRec("measuredMass"),"T","S") & "," &_
								SQLClean(revisionNumber,"N","S") & "," &_
								SQLClean(attachmentRec("trivialName"),"T","S") & "," &_
								SQLClean(attachmentRec("smiles"),"T","S") & "," &_
								SQLClean(attachmentRec("fragmentId"),"N","S") & "," &_
								SQLClean(attachmentRec("userAdded"),"N","S") & "," &_
								SQLClean(attachmentRec("stepNumber"),"N","S") & "," &_
								SQLClean(attachmentRec("molData"),"T","S") & "," &_
								SQLClean(attachmentRec("molData3000"),"T","S") & "," &_
								SQLClean(attachmentRec("cxsmiles"),"T","S") & "," &_
								SQLClean(attachmentRec("craisClass"),"T","S") & "," &_
								SQLClean(attachmentRec("craisText"),"T","S") & "," &_
								SQLClean(attachmentRec("gridState"),"T","S") & "," &_
								SQLClean(attachmentRec("inventoryItems"),"T","S") & "," &_
								SQLClean(attachmentRec("sortOrder"),"N","S") & ")"
					If attachmentRec("userAdded") = "1" Or updateMolecules then
						connadm.execute(strQuery)
					End if
					attachmentRec.movenext
				Loop
				attachmentRec.close
				strQuery = "SELECT * FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
				attachmentRec.open strQuery,connadm,3,3
				'loop through all the solvent data
				Do While Not attachmentRec.eof
						'insert a new history record for the current revision with the current solvent data (not creating a new record because nothing is going to change)
						strQuery = "INSERT into solvents_history(name,ratio,volume,supplier,reactionMolarity,moles,experimentId,revisionId,trivialName,smiles,fragmentId,userAdded,craisClass,craisText,gridState,inventoryItems,stepNumber) values(" &_
								SQLClean(attachmentRec("name"),"T","S") & "," &_
								SQLClean(attachmentRec("ratio"),"T","S") & "," &_
								SQLClean(attachmentRec("volume"),"T","S") & "," &_
								SQLClean(attachmentRec("supplier"),"T","S") & "," &_
								SQLClean(attachmentRec("reactionMolarity"),"T","S") & "," &_
								SQLClean(attachmentRec("moles"),"T","S") & "," &_
								SQLClean(attachmentRec("experimentId"),"N","S") & "," &_
								SQLClean(revisionNumber,"N","S") & "," &_
								SQLClean(attachmentRec("trivialName"),"T","S") & "," &_
								SQLClean(attachmentRec("smiles"),"T","S") & "," &_
								SQLClean(attachmentRec("fragmentId"),"N","S") & "," &_
								SQLClean(attachmentRec("userAdded"),"N","S") & "," &_
								SQLClean(attachmentRec("craisClass"),"T","S") & "," &_
								SQLClean(attachmentRec("craisText"),"T","S") & "," &_
								SQLClean(attachmentRec("gridState"),"T","S") & "," &_
								SQLClean(attachmentRec("inventoryItems"),"T","S") & "," &_
								SQLClean(attachmentRec("stepNumber"),"N","A") & ")"
						connadm.execute(strQuery)
					attachmentRec.movenext
				Loop
				attachmentRec.close
				Set attachmentRec = Nothing
			End if
		End If

		Set lRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM experimentLinks WHERE experimentType="&SQLClean(experimentType,"N","S") & " AND experimentId=" & SQLClean(experimentId,"N","S")
		lRec.open strQuery,connAdm,3,3
		Do While Not lRec.eof
			strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,comments,revisionNumber) values(" &_
			SQLClean(lRec("experimentType"),"N","S") & "," &_
			SQLClean(lRec("experimentId"),"N","S") & "," &_
			SQLClean(lRec("linkExperimentType"),"N","S") & "," &_
			SQLClean(lRec("linkExperimentId"),"N","S") & "," &_
			SQLClean(lRec("comments"),"T","S") & "," &_
			SQLClean(revisionNumber,"N","S") &")"
			connAdm.execute(strQuery)
			lRec.moveNext
		loop
		lRec.close
		Set lRec = Nothing
		
		Set lRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM experimentRegLinks WHERE experimentType="&SQLClean(experimentType,"N","S") & " and experimentId="&SQLClean(experimentId,"N","S")
		lRec.open strQuery,connAdm,3,3
		Do While Not lRec.eof
			strQuery = "INSERT into experimentRegLinks_history(experimentType,experimentId,regNumber,displayRegNumber,revisionNumber) values(" &_
			SQLClean(lRec("experimentType"),"N","S") & "," &_
			SQLClean(lRec("experimentId"),"N","S") & "," &_
			SQLClean(lRec("regNumber"),"T","S") & "," &_
			SQLClean(lRec("displayRegNumber"),"T","S") & "," &_
			SQLClean(revisionNumber,"N","S") &")"
			connAdm.execute(strQuery)
			lRec.movenext
		Loop
		lRec.close
		Set lRec = Nothing

		duplicateAndChangeStatus = oldRevisionNumber
	Else
		duplicateAndChangeStatus = "0"
	End If
End Function
%>