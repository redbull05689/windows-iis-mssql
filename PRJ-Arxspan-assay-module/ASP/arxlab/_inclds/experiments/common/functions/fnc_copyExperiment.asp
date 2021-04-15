<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../chem/functions/fnc_copyChemistryData.asp"-->
<%
function copyExperiment(experimentType,experimentId,revisionNumber,newNotebookId,copyAttachments,copyNotes)
	'copy an experiment accepts a revision number and a notebook id to copy the experiment into
	'copyies the provided revision of the experiment to the provided notetbook
	'you can copy an experiment so long as you can view it
	call getconnectedadm
	call getconnectedadmTrans
	if experimentType = "1" then
		'chemistry experiment
		histTable = "experiments_history"
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT userId from experiments WHERE id="&SQLClean(experimentId,"N","S")
		rec.open strQuery,connAdm,3,3
		If Not rec.eof Then
			'if experiment exists

			'get the name for the new experiment
			newName = getNextExperimentName(newNotebookId)

			If IsNull(revisionNumber) Or revisionNumber="" Then
				revisionNumber = getExperimentRevisionNumber("1",experimentId)
			End if

			userId = rec("userId")

			'insert into the experiments table the appropriate data from the experiment history table set dateUpdated and dateCreated to now
			strQuery = "INSERT into experiments (name, preparation, searchPreparation, statusId, cdx, notebookId, reactionMolarity, pressure, temperature, userId, dateSubmitted, dateUpdated, molData, xmlData, revisionNumber, visible, experimentType, objectTypeId, dateSubmittedServer, dateUpdatedServer, unsavedChanges, beenExported, sigdigs, details, softSigned, craisStatus, currLetter, resultSD, userExperimentName, checkedOut, mrvData) output inserted.id as newId SELECT name,preparation,searchPreparation,statusId,cdx,notebookId,reactionMolarity,pressure,temperature,userId,GETUTCDATE(),GETUTCDATE(),molData,xmlData,revisionNumber,visible,experimentType,objectTypeId,GETDATE(),GETDATE(),0,beenExported,sigdigs,details,softSigned,craisStatus,0,resultSD,userExperimentName,null,mrvData from experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLclean(revisionNumber,"N","S")
			session("testQuery") = strQuery
				
			Set rs = connAdm.execute(strQuery)
			'get the new experiment id
			newId = CStr(rs("newId"))

			'set the new experiments notebook id, name, user id(as yours),revision number(1),status(1,created),beenExported(0, no)
			'IDQ 9123: SQLClean() does not seem to work well for very large cdx or molData data. Work-around/optimize it by joining the table for direct update.
			strQuery = "UPDATE t SET " &_
							"notebookId="&SQLClean(newNotebookId,"T","S") & "," &_
							"name="&SQLClean(newName,"T","S") & "," &_
							"userId="&SQLClean(session("userId"),"N","S") & "," &_
							"revisionNumber=1," &_
							"statusId=1," &_
							"sigdigs=s.sigdigs," &_
							"cdx=s.cdx," &_
							"beenExported=0," &_
							"molData=s.molData," &_
							"craisStatus=0 " &_
						"FROM experiments t," &_
						" (SELECT cdx, molData, sigdigs FROM experiments WHERE id="&SQLClean(experimentId,"N","S") & ") s " &_
						" WHERE t.id="&SQLClean(newId,"N","S")
			connAdm.execute(strQuery)
			newExperimentId = newId

			' experiment_stepsHistory
			strQuery = "INSERT INTO experiment_stepsHistory(experimentId,revisionNumber,stepNumber,cdx) " &_
						"SELECT " & SQLClean(newExperimentId,"N","S") & ",1," & "stepNumber,cdx FROM experiment_steps WHERE experimentId="&SQLClean(experimentId,"N","S")
			connAdm.execute(strQuery)

			' experiment_steps
			strQuery = "INSERT INTO experiment_steps(experimentId,stepNumber,cdx) " &_
					"SELECT " & SQLClean(newExperimentId,"N","S") & ",stepNumber,cdx FROM experiment_steps WHERE experimentId="&SQLClean(experimentId,"N","S")
			connAdm.execute(strQuery)

			'set experiment history record for new experiment by copying current experiments appropriate history record to the new record for the new experiment
			strQuery = "INSERT INTO experiments_history (experimentId, name, preparation, searchPreparation, statusId, cdx, notebookId, reactionMolarity, pressure, temperature, userId, dateSubmitted, molData, xmlData, action, revisionNumber, visible, experimentType, objectTypeId, dateSubmittedServer, beenExported, sigdigs, details, softSigned, craisStatus, currLetter, resultSD, userExperimentName,mrvData) output inserted.id as newId SELECT id,name,preparation,searchPreparation,statusId,cdx,notebookId,reactionMolarity,pressure,temperature,userId,GETUTCDATE(),molData,xmlData,pressure as action,revisionNumber,visible,experimentType,objectTypeId,GETDATE(),beenExported,sigdigs,details,softSigned,craisStatus,0,resultSD,userExperimentName,mrvData from experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="& SQLClean(revisionNumber,"N","S")
			Set rs = connAdm.execute(strQuery)
			'get the id of the history record
			newId = CStr(rs("newId"))

			'update the history records data, notebook id, user Id(as yours),name,experimentId(new experiment Id),revisionNumber(1),statusId(1, created)
			strQuery = "UPDATE experiments_history SET "&_
						"notebookId="&SQLClean(newNotebookId,"T","S") &_
						",userId="&SQLClean(session("userId"),"N","S") &_
						",name="&SQLClean(newName,"T","S") &_
						",experimentId="&SQLClean(newExperimentId,"N","S") &_
						",revisionNumber="&SQLClean("1","N","S") &_
						",statusId="&SQLClean("1","N","S") &_
						" WHERE id="&SQLClean(newId,"N","S")
			connAdm.execute(strQuery)

			' insert the reactant data into the history record for the new experiment
			strQuery = "INSERT INTO reactants_history(name,updated,molecularFormula,molecularWeight,limit,equivalents,weightratio,moles,sampleMass,volume,supplier,cas,compoundNumber," &_
							"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,revisionId,solvent,trivialName,smiles,fragmentId,userAdded," &_
							"stepNumber,molData,molData3000,gridState,sortOrder) " &_
						"SELECT name,updated,molecularFormula,molecularWeight,limit,equivalents,weightratio,moles,sampleMass,volume,supplier,cas,compoundNumber," &_
							"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading," & SQLClean(newExperimentId,"N","S") & ",1,solvent,trivialName,'fromcopy',fragmentId,userAdded," &_
							"ISNULL(stepNumber,1),molData,molData3000,gridState,sortOrder " &_
						"FROM reactants_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
			connadm.execute(strQuery)

			'insert the reactant data into a new record for the new experiment
			strQuery = "INSERT INTO reactants(name,updated,molecularFormula,molecularWeight,limit,equivalents,weightratio,moles,sampleMass,volume,supplier,cas,compoundNumber," &_
							"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,solvent,trivialName,smiles,fragmentId,hasChanged,userAdded," &_
							"stepNumber,molData,molData3000,cxsmiles,gridState,sortOrder) " &_
						"SELECT name,updated,molecularFormula,molecularWeight,limit,equivalents,weightratio,moles,sampleMass,volume,supplier,cas,compoundNumber," &_
							"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading," & SQLClean(newExperimentId,"N","S") & ",solvent,trivialName,'fromcopy',fragmentId,0,userAdded," &_
							"ISNULL(stepNumber,1),molData,molData3000,cxsmiles,gridState,sortOrder " &_
						"FROM reactants_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
			connadm.execute(strQuery)

			'insert the reagent data into the history record of the new experiment
			strQuery = "INSERT INTO reagents_history(name,updated,molecularFormula,molecularWeight,limit,equivalents,weightratio,moles,sampleMass,volume,supplier,cas,compoundNumber," &_
							"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,revisionId,solvent,trivialName,smiles,fragmentId,userAdded," &_
							"stepNumber,molData,molData3000,gridState,sortOrder) " &_
						"SELECT name,updated,molecularFormula,molecularWeight,limit,equivalents,weightratio,moles,sampleMass,volume,supplier,cas,compoundNumber," &_
							"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading," & SQLClean(newExperimentId,"N","S") & ",1,solvent,trivialName,'fromcopy',fragmentId,userAdded," &_
							"ISNULL(stepNumber,1),molData,molData3000,gridState,sortOrder " &_
						"FROM reagents_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
			connadm.execute(strQuery)

			'insert the reagent data into a new record for the new experiment
			strQuery = "INSERT INTO reagents(name,updated,molecularFormula,molecularWeight,limit,equivalents,weightratio,moles,sampleMass,volume,supplier,cas,compoundNumber," &_
							"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading,experimentId,solvent,trivialName,smiles,fragmentId,hasChanged,userAdded," &_
							"stepNumber,molData,molData3000,cxsmiles,gridState,sortOrder) " &_
						"SELECT name,updated,molecularFormula,molecularWeight,limit,equivalents,weightratio,moles,sampleMass,volume,supplier,cas,compoundNumber," &_
							"barcode,molarity,density,percentWT,formulaMass,reactantMass,loading," & SQLClean(newExperimentId,"N","S") & ",solvent,trivialName,'fromcopy',fragmentId,0,userAdded," &_
							"ISNULL(stepNumber,1),molData,molData3000,cxsmiles,gridState,sortOrder " &_
						"FROM reagents_history WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND revisionId=" & SQLClean(revisionNumber,"N","S")
			connadm.execute(strQuery)

			'insert the product data into the history record for the new experiment
			strQuery = "INSERT INTO products_history(name,dateExpires,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass," &_
							"experimentId,revisionId,trivialName,smiles,fragmentId,userAdded,stepNumber,molData,molData3000,gridState,sortOrder) " &_
						"SELECT name,dateExpires,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass," &_
							SQLClean(newExperimentId,"N","S") & ",1,trivialName,'fromcopy',fragmentId,userAdded,ISNULL(stepNumber,1),molData,molData3000,gridState,sortOrder " &_
						"FROM products_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
			connadm.execute(strQuery)

			'insert the product data into a new record for the new experiment
			strQuery = "INSERT INTO products(name,dateExpires,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass," &_
							"experimentId,trivialName,smiles,fragmentId,hasChanged,userAdded,stepNumber,molData,molData3000,cxsmiles,gridState,sortOrder) " &_
						"SELECT name,dateExpires,batch,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,submittedAmount,barcode,compoundNumber,tempId,formulaMass,loading,measuredMass," &_
							SQLClean(newExperimentId,"N","S") & ",trivialName,'fromcopy',fragmentId,0,userAdded,ISNULL(stepNumber,1),molData,molData3000,cxsmiles,gridState,sortOrder " &_
						"FROM products_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
			connadm.execute(strQuery)

			'insert solvent data into the history record for the new experiment
			strQuery = "INSERT INTO solvents_history(name,ratio,volume,supplier,reactionMolarity,moles,experimentId,revisionId,trivialName,smiles,fragmentId,userAdded,gridState,stepNumber,volumes) " &_
						"SELECT name,ratio,volume,supplier,reactionMolarity,moles," & SQLClean(newExperimentId,"N","S") & ",1,trivialName,'fromcopy',fragmentId,userAdded,gridState,stepNumber,volumes " &_
						"FROM solvents_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
			connadm.execute(strQuery)

			'insert solvent data into new record for the new experiment
			strQuery = "INSERT INTO solvents(name,ratio,volume,supplier,reactionMolarity,moles,experimentId,trivialName,smiles,fragmentId,hasChanged,userAdded,gridState,stepNumber,volumes) " &_
						"SELECT name,ratio,volume,supplier,reactionMolarity,moles," & SQLClean(newExperimentId,"N","S") & ",trivialName,'fromcopy',fragmentId,0,userAdded,gridState,stepNumber,volumes " &_
						"FROM solvents_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionId="&SQLClean(revisionNumber,"N","S")
			connadm.execute(strQuery)
		End If

		rec.close
		Set rec = nothing

		'For Marvin we need to copy the fragment map or all the grid data gets lost
		strQuery = "INSERT INTO fragmentmap(atomUUID, fragmentId, experimentID) " &_
					"SELECT atomUUID,fragmentId," &	SQLClean(newExperimentId,"N","S") &_
					" FROM fragmentMap WHERE experimentId="&SQLClean(experimentId,"N","S")
		connadm.execute(strQuery)

		' We need to copy the chemData images from the old experiment into the new experiment's folder
		'ELN-1331 adding the last parameter - "0" because only saved changes will be moved to the new experiment
		Call copyChemistryData(userId, session("userId"), experimentId, newExperimentId, 1, revisionNumber, "1")
	else
		prefix = GetPrefix(experimentType)
		expTable = GetFullName(prefix, "experiments", true)
		histTable = GetFullName(prefix, "experiments_history", true)
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id from " & expTable & " WHERE id="&SQLClean(experimentId,"N","S") & " ORDER by revisionNumber DESC"
		rec.open strQuery,connAdm,3,3
		If Not rec.eof Then
			'if experiment exists

			'get the name for the new experiment
			newName = getNextExperimentName(newNotebookId)

			If IsNull(revisionNumber) Or revisionNumber="" Then
				revisionNumber = getExperimentRevisionNumber(experimentType, experimentId)
			End if

			'insert into the anal experiments table the appropriate data from the anal experiment history table set dateUpdated and dateCreated to now
			If experimentType = "3" then
				strQuery = "INSERT into " & expTable & " OUTPUT inserted.id AS newId SELECT notebookId,name,description,GETUTCDATE(),GETUTCDATE(),userId,revisionNumber,statusId,action,visible,experimentType,objectTypeId,GETDATE(),GETDATE(),0,beenExported,details,softSigned,userExperimentName from " & histTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S")
			ElseIf experimentType = "5" Then
				strQuery = "INSERT into " & expTable & " OUTPUT inserted.id AS newId SELECT notebookId,name,GETUTCDATE(),GETUTCDATE(),userId,revisionNumber,statusId,action,visible,experimentType,objectTypeId,GETDATE(),GETDATE(),0,beenExported,details,softSigned,userExperimentName,requestId,requestRevisionNumber,requestTypeId from " & histTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
			Else
				strQuery = "INSERT into " & expTable & " OUTPUT inserted.id AS newId SELECT notebookId,name,protocol,summary,GETUTCDATE(),GETUTCDATE(),userId,revisionNumber,statusId,action,visible,experimentType,objectTypeId,GETDATE(),GETDATE(),0,beenExported,details,softSigned,userExperimentName from " & histTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
			End If
			
			session("testQuery") = strQuery
			Set rs = connAdm.execute(strQuery)
			'get the new experiment id
			newId = CStr(rs("newId"))

			'set the new experiments notebook id, name, user id(as yours),revision number(1),status(1,created),beenExported(0, no)
			strQuery = "UPDATE " & expTable & " SET " &_
			"notebookId="&SQLClean(newNotebookId,"T","S") & "," &_
			"userId="&SQLClean(session("userId"),"N","S") & "," &_
			"name="&SQLClean(newName,"T","S") & "," &_
			"revisionNumber="&SQLClean("1","N","S") & "," &_
			"statusId="&SQLClean("1","N","S") & "," &_
			"action='created'," &_
			"beenExported="&SQLClean("0","N","S") &_
			" WHERE id="&SQLClean(newId,"N","S")
			connAdm.execute(strQuery)
			newExperimentId = newId

			'set experiment history record for new experiment by copying current experiments appropriate history record to the new record for the new experiment
			If experimentType = "3" then
				strQuery = "INSERT into " & histTable & " OUTPUT inserted.id AS newId SELECT notebookId,id,name,description,GETUTCDATE(),userId,revisionNumber,action,statusId,visible,experimentType,objectTypeId,GETDATE(),beenExported,details,softSigned,userExperimentName from " & histTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S")
			ElseIf experimentType = "5" Then
				strQuery = "INSERT into " & histTable & " OUTPUT inserted.id AS newId SELECT notebookId,id,name,GETUTCDATE(),userId,revisionNumber,action,statusId,visible,experimentType,objectTypeId,GETDATE(),beenExported,details,softSigned,userExperimentName,requestId,requestRevisionNumber,requestTypeId from " & histTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
			Else
				strQuery = "INSERT into " & histTable & " OUTPUT inserted.id AS newId SELECT notebookId,id,name,protocol,summary,GETUTCDATE(),userId,revisionNumber,action,statusId,visible,experimentType,objectTypeId,GETDATE(),beenExported,details,softSigned,userExperimentName from " & histTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
			End If
			
			Set rs = connAdm.execute(strQuery)
			'get the history records id
			newId = CStr(rs("newId"))

			'update the history records data, notebook id, user Id(as yours),name,experimentId(new experiment Id),revisionNumber(1),statusId(1, created)
			strQuery = "UPDATE " & histTable & " SET "&_
			"notebookId="&SQLClean(newNotebookId,"T","S") & "," &_
			"userId="&SQLClean(session("userId"),"N","S") & "," &_
			"name="&SQLClean(newName,"T","S") & "," &_
			"experimentId="&SQLClean(newExperimentId,"N","S") & "," &_
			"revisionNumber="&SQLClean("1","N","S") & "," &_
			"statusId="&SQLClean("1","N","S") &_
			" WHERE id="&SQLClean(newId,"N","S")
			connAdm.execute(strQuery)
		End if
		rec.close
		Set rec = nothing

	end if
	
	' Add to allExperiments
	strQuery = "INSERT INTO allExperiments (companyId, name, preparation, statusId, cdx, notebookId, reactionMolarity, pressure, temperature, userId, molData, xmlData, action, revisionNumber, visible, experimentType, objectTypeId, beenExported, sigdigs, details, softSigned, craisStatus, currLetter, resultSD, userExperimentName, description, protocol, summary, legacyId, {mrvData, }dateSubmitted, dateUpdated, dateSubmittedServer, dateUpdatedServer{reqTypeId1}) OUTPUT inserted.id AS globalId SELECT companyId, " &_
	SQLClean(newName, "T", "S") &_
	", preparation, 1, cdx, " &_
	SQLClean(newNotebookId, "N", "S") &_
	", reactionMolarity, pressure, temperature, " &_ 
	SQLClean(session("userId"),"N","S") &_ 
	", molData, xmlData, 'created', 1, visible, experimentType, objectTypeId, beenExported, sigdigs, details, softSigned, craisStatus, currLetter, resultSD, userExperimentName, description, protocol, summary, " &_
	SQLClean(newExperimentId, "N", "S") &_
	", {mrvData, }GETUTCDATE(),GETUTCDATE(),GETDATE(), GETDATE(){reqTypeId2} FROM allExperiments WHERE experimentType = " &_
	SQLClean(experimentType, "N", "S") & " AND legacyId = " & SQLClean(experimentId, "N", "S")
	
	' The mrvData column only exists on the Dev database currently so swap the two mrvReplace variables when it
	' exists in the other databases.
	'mrvReplace = "mrvData, "
	mrvReplace = ""
	strQuery = Replace(strQuery, "{mrvData, }", mrvReplace)
	
	reqTypeId = ""
	If experimentType = "5" Then
		reqTypeId = ", requestTypeId"
	end if

	strQuery = Replace(strQuery, "{reqTypeId1}", reqTypeId)
	strQuery = Replace(strQuery, "{reqTypeId2}", reqTypeId)

	Set rs = connAdm.execute(strQuery)
	globalId = CStr(rs("globalId"))

	' History table too
	strQuery = "INSERT INTO allExperiments_history (companyId, experimentId, name, preparation, statusId, cdx, notebookId, reactionMolarity, pressure, temperature, userId, molData, xmlData, action, revisionNumber, visible, experimentType, objectTypeId, beenExported, sigdigs, details, softSigned, craisStatus, currLetter, resultSD, userExperimentName, description, protocol, summary, legacyId, legacyHistoryId, {mrvData, }dateSubmitted, dateSubmittedServer, searchPreparation{reqTypeId1}) SELECT companyId, " &_
	SQLClean(globalId, "N", "S") & ", " &_
	SQLClean(newName, "T", "S") &_
	", preparation, statusId, cdx, " &_
	SQLClean(newNotebookId, "N", "S") &_
	", reactionMolarity, pressure, temperature, " &_
	SQLClean(session("userId"),"N","S") &_ 
	", molData, xmlData, action, 1, visible, experimentType, objectTypeId, beenExported, sigdigs, details, softSigned, craisStatus, currLetter, resultSD, userExperimentName, description, protocol, summary, legacyId, " &_
	newId &_
	", {mrvData, }GETUTCDATE(), GETDATE(), ''{reqTypeId2} FROM allExperiments WHERE experimentType = " &_
	SQLClean(experimentType, "N", "S") & " AND legacyId = " & SQLClean(newExperimentId, "N", "S")

	' See above.
	strQuery = Replace(strQuery, "{mrvData, }", mrvReplace)
	
	reqTypeId = ""
	If experimentType = "5" Then
		reqTypeId = ", requestTypeId"
	end if

	strQuery = Replace(strQuery, "{reqTypeId1}", reqTypeId)
	strQuery = Replace(strQuery, "{reqTypeId2}", reqTypeId)

	connAdm.execute(strQuery)

	'get appropriate attchment tables and note tables names for specified type of experiment
	prefix = GetPrefix(experimentType)
	attachmentsTable = GetFullName(prefix, "attachments", true)
	attachmentsHistoryTable = GetFullName(prefix, "attachments_history", true)
	notesTable = GetFullName(prefix, "notes", true)
	notesHistoryTable = GetFullName(prefix, "notes_history", true)

	' experiment links
	strQuery = "INSERT INTO linksProjectExperiments(experimentType,experimentId,projectId) " &_
				"SELECT experimentType," & SQLClean(newExperimentId,"N","S") & ",projectId " &_
				"FROM linksProjectExperiments WHERE experimentType="&SQLClean(experimentType,"N","S") & " AND experimentId=" & SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery)

	If copyAttachments then
		Set attachmentRec = server.CreateObject("ADODB.RecordSet")

		strQuery = "SELECT * FROM "&attachmentsHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
		attachmentRec.open strQuery,connadm,3,3
		
		'Copy all the folder details from folder attachments table for this experiment
		strQuery = "INSERT INTO attachmentFolders (folderName,experimentType,experimentId,fullPath,parentFolderId) " &_
					"SELECT folderName," & SQLClean(experimentType,"N","S") & "," & SQLClean(newExperimentId,"N","S") & ",fullpath,NULL " &_
					"FROM attachmentFolders WHERE experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(experimentId,"N","S")
		connAdm.execute(strQuery)
		
		'Update parent folder Id
		update = updateAttachmentParentFolderId(experimentType,newExperimentId)
		
		'loop through all attachments in the specified revision of the experiment
		Do While Not attachmentRec.eof
			folderId = ""
			If Not IsNull(attachmentRec("folderId")) Then
				If CLng(attachmentRec("folderId")) > 0 Then
					'Get the folder id and folder path in folder attachments table for the experiment
					Set fRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT folderName, fullPath FROM attachmentFolders WHERE id="& SQLClean(attachmentRec("folderId"),"N","S") &" AND experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(experimentId,"N","S")
					fRec.open strQuery,connAdm,3,3
					
					If not fRec.eof Then
						response.write (fRec("folderName") &" - "& fRec("fullPath") &"::")
						Set newfRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT id FROM attachmentFolders WHERE folderName="& SQLClean(fRec("folderName"),"T","S") &" AND fullPath="& SQLClean(fRec("fullPath"),"T","S") &" AND experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(newExperimentId,"N","S")
						newfRec.open strQuery,connAdm,3,3
						
						If not newfRec.eof Then
							folderId = newfRec("id")
						End If
					End If
				End If
			End If
						
			'insert attachment data into current record for new experiment, update dates to now
			strQuery = "INSERT INTO "&attachmentsTable&"(userId,experimentId,name,filename,actualFileName,description,filesize,searchText,getSearchTextError,sortOrder,folderId,totalBytes,revisionNumber,dateUploaded,dateUploadedServer) OUTPUT inserted.id AS newId values(" &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(newExperimentId,"N","S") & "," &_
			SQLClean(attachmentRec("name"),"T","S") & "," &_
			SQLClean(attachmentRec("filename"),"T","S") & "," &_
			SQLClean(attachmentRec("actualFileName"),"T","S") & "," &_
			SQLClean(attachmentRec("description"),"T","S") & "," &_
			SQLClean(attachmentRec("filesize"),"T","S")& "," &_
			SQLClean(attachmentRec("searchText"),"T","S") & "," &_
			SQLClean(attachmentRec("getSearchTextError"),"N","S")& "," &_
			SQLClean(attachmentRec("sortOrder"),"N","S")&"," &_
			SQLClean(folderId,"N","S")&"," &_
			SQLClean(attachmentRec("totalBytes"),"N","S")&",1,GETUTCDATE(),GETDATE())"
			'DEBUG
			'response.write("putting current attachments into history table<br>")
			Set rs = connadm.execute(strQuery)
			newAttachmentId = CStr(rs("newId"))
			rs.close
			Set rs = nothing

			'insert attachment data into the history record for the new experiment
			'set userId(your Id),experimentId(new experiment id),original revision number(1),revisionNumber(1), update dates to now
			strQuery = "INSERT INTO "&attachmentsHistoryTable&"(userId,experimentId,name,filename,actualFileName,description,revisionNumber,originalRevisionNumber,attachmentId,filesize,searchText,getSearchTextError,totalBytes,dateUploaded,dateUploadedServer,sortOrder,folderId) values(" &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(newExperimentId,"N","S") & "," &_
			SQLClean(attachmentRec("name"),"T","S") & "," &_
			SQLClean(attachmentRec("filename"),"T","S") & "," &_
			SQLClean(attachmentRec("actualFileName"),"T","S") & "," &_
			SQLClean(attachmentRec("description"),"T","S") & "," &_
			SQLClean("1","N","S") & "," &_ 
			SQLClean("1","N","S") & "," &_ 
			SQLClean(newAttachmentId,"N","S") & ","&_
			SQLClean(attachmentRec("filesize"),"T","S")&"," &_
			SQLClean(attachmentRec("searchText"),"T","S") & ","&_
			SQLClean(attachmentRec("getSearchTextError"),"N","S")&"," &_
			SQLClean(attachmentRec("totalBytes"),"N","S")&",GETUTCDATE(),GETDATE()," &_
			SQLClean(attachmentRec("sortOrder"),"N","S")&"," &_
			SQLClean(folderId,"N","S")&")"
			'DEBUG
			'response.write("putting current attachments into history tablezz<br>"&attachmentRec("searchText"))
			connadm.execute(strQuery)

			'insert into allExperimentFiles
			strQuery = "INSERT INTO allExperimentFiles (companyId, userId, experimentId, name, filename, actualFileName, description, revisionNumber, filesize, totalBytes,  getSearchTextError, experimentType, dateUploaded, dateUploadedServer, sortOrder, folderId, legacyId) OUTPUT inserted.id as attId VALUES (" &_
			SQLClean(session("companyId"), "N", "S") & ", " &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(globalId,"N","S") & "," &_
			SQLClean(attachmentRec("name"),"T","S") & "," &_
			SQLClean(attachmentRec("filename"),"T","S") & "," &_
			SQLClean(attachmentRec("actualFileName"),"T","S") & "," &_
			SQLClean(attachmentRec("description"),"T","S") & "," &_
			SQLClean("1","N","S") & "," &_ 
			SQLClean(attachmentRec("filesize"),"T","S")&"," &_
			SQLClean(attachmentRec("totalBytes"),"N","S") & "," &_
			SQLClean(attachmentRec("getSearchTextError"),"N","S")&"," &_
			SQLClean(experimentType, "N", "S") & ",GETUTCDATE(),GETDATE()," &_
			SQLClean(attachmentRec("sortOrder"),"N","S") & ","&_
			SQLClean(attachmentRec("folderId"),"N","S")&"," &_
			SQLClean(newAttachmentId, "N", "S") & ")"

			Set attRs = connadm.execute(strQuery)
			attId = CStr(attRs("attId"))
			attRs.close()
			Set attRs = nothing

			'insert into allExperimentFiles_history
			strQuery = "INSERT INTO allExperimentFiles_history (companyId, userId, experimentId, name, filename, actualFileName, description, revisionNumber, originalRevisionNumber, attachmentId, filesize, totalBytes, getSearchTextError, experimentType, dateUploaded, dateUploadedServer, sortOrder, folderId, legacyId) VALUES (" &_
			SQLClean(session("companyId"), "N", "S") & ", " &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(globalId,"N","S") & "," &_
			SQLClean(attachmentRec("name"),"T","S") & "," &_
			SQLClean(attachmentRec("filename"),"T","S") & "," &_
			SQLClean(attachmentRec("actualFileName"),"T","S") & "," &_
			SQLClean(attachmentRec("description"),"T","S") & "," &_
			SQLClean("1","N","S") & "," &_ 
			SQLClean("1","N","S") & "," &_ 
			SQLClean(newAttachmentId,"N","S") & ","&_
			SQLClean(attachmentRec("filesize"),"T","S")&"," &_
			SQLClean(attachmentRec("totalBytes"),"N","S") & "," &_
			SQLClean(attachmentRec("getSearchTextError"),"N","S")&"," &_
			SQLClean(experimentType, "N", "S") & ",GETUTCDATE(),GETDATE()," &_
			SQLClean(attachmentRec("sortOrder"),"N","S") & ","&_
			SQLClean(attachmentRec("folderId"),"N","S")&"," &_
			SQLClean(attId, "N", "S") & ")"
			
			connadm.execute(strQuery)

			' insert new attachment id to experimentContentSequence_history
			strQuery = "INSERT into experimentContentSequence_history (experimentType,experimentId,attachmentId,sortOrder,revisionNumber) " &_
						"SELECT " & SQLClean(experimentType,"N","S") & "," & SQLClean(newExperimentId,"N","S") & "," & SQLClean(newAttachmentId,"N","S") & ",sortOrder, 1 " &_
						"FROM experimentContentSequence_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType="&SQLClean(experimentType,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S") & " AND attachmentId="&SQLClean(attachmentRec("attachmentId"),"N","S")
			connAdm.execute(strQuery)

			' insert new attachment id to experimentContentSequence
			strQuery = "INSERT into experimentContentSequence (experimentType,experimentId,attachmentId,sortOrder) " &_
					"SELECT " & SQLClean(experimentType,"N","S") & "," & SQLClean(newExperimentId,"N","S") & "," & SQLClean(newAttachmentId,"N","S") & ",sortOrder " &_
					"FROM experimentContentSequence_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND experimentType="&SQLClean(experimentType,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S") & " AND attachmentId="&SQLClean(attachmentRec("attachmentId"),"N","S")
			connAdm.execute(strQuery)

			attachmentRec.movenext
		Loop
		attachmentRec.close
		Set attachmentRec = nothing

		' insert existing attachment id to experimentContentSequence_history
		strQuery = "INSERT into experimentContentSequence_history (experimentType,experimentId,experimentFieldName,attachmentId,sortOrder,revisionNumber) " &_
					"SELECT " & SQLClean(experimentType,"N","S") & "," & SQLClean(newExperimentId,"N","S") & ",experimentFieldName,attachmentId,sortOrder,1 " &_
					"FROM experimentContentSequence_history WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S") & " AND experimentFieldName IS NOT NULL"
		connAdm.execute(strQuery)

		' insert existing attachment id to experimentContentSequence
		strQuery = "INSERT into experimentContentSequence (experimentType,experimentId,experimentFieldName,attachmentId,sortOrder) " &_
				"SELECT " & SQLClean(experimentType,"N","S") & "," & SQLClean(newExperimentId,"N","S") & ",experimentFieldName,attachmentId,sortOrder " &_
				"FROM experimentContentSequence_history WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S") & " AND experimentFieldName IS NOT NULL"
		connAdm.execute(strQuery)
	End if

	'copy notes to new experiment
	If copyNotes then
		'insert note data into the history record for the new experiment
		'userId (your id), experiment ID (newExperimentId),revision Number (1),update dates to now
		strQuery = "INSERT INTO " & notesHistoryTable & "(userId,experimentId,name,note,revisionNumber,noteId,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer,readOnly) " &_
					"SELECT " & SQLClean(session("userId"),"N","S") & "," & SQLClean(newExperimentId,"N","S") & ",name,note,1,id,GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE(),readOnly " &_
					"FROM " & notesHistoryTable & " WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") & " AND readOnly=0"
		connAdm.execute(strQuery)

		'insert note data into current new experiment record
		'userId(your id), experimentId (newExperimentId),update dates to now
		strQuery = "INSERT INTO " & notesTable & "(userId,experimentId,name,note,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer,readOnly) " &_
				"SELECT " & SQLClean(session("userId"),"N","S") & "," & SQLClean(newExperimentId,"N","S") & ",name,note,GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE(),readOnly " &_
				"FROM " & notesHistoryTable & " WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") & " AND readOnly=0"
		connadm.execute(strQuery)

		'insert note data into allexperiments for new Experiment
		strQuery = "INSERT INTO allExperimentNotes (companyId,userId,experimentId,name,note,revisionNumber,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer,readOnly,experimentType,legacyId) " &_
					"SELECT " & SQLClean(session("companyId"),"N","S") & "," & SQLClean(session("userId"),"N","S") & "," & SQLClean(globalId,"N","S") & ",name,note,1,GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE(),readOnly," &_
						SQLClean(experimentType, "N", "S") & "," & SQLClean(newExperimentId,"N","S") &_
					" FROM " & notesHistoryTable & " WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") & " AND readOnly=0"
		connadm.execute(strQuery)

		'insert note data into all history for new Experiment
		strQuery = "INSERT INTO allExperimentNotes_history (companyId,userId,experimentId,name,note,revisionNumber,noteId,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer,readOnly,experimentType,legacyId) " &_
					"SELECT " & SQLClean(session("companyId"),"N","S") & "," & SQLClean(session("userId"),"N","S") & "," & SQLClean(globalId,"N","S") & ",name,note,1,id,GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE(),readOnly," &_
						SQLClean(experimentType, "N", "S") & "," & SQLClean(newExperimentId,"N","S") &_
					" FROM " & notesHistoryTable & " WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") & " AND readOnly=0"
		connadm.execute(strQuery)
	End if

	' add a link to the new experiment that links to the experiment being copied from
	strQuery = "INSERT into experimentLinks(experimentType,experimentId,linkExperimentType,linkExperimentId,comments) values(" &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(newExperimentId,"N","S") & "," &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean("The experiment this was copied from.","T","S") & ")"
	connAdm.execute(strQuery)

	' history table too...
	strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,revisionNumber,comments) values(" &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(newExperimentId,"N","S") & "," &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean("1","N","S") & "," &_
	SQLClean("The experiment this was copied from.","T","S") & ")"
	connAdm.execute(strQuery)

	' add a link to the experiment that's being copied
	strQuery = "INSERT into experimentLinks(experimentType,experimentId,linkExperimentType,linkExperimentId,comments) values(" &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(newExperimentId,"N","S") & "," &_
	SQLClean("A copy of this experiment.","T","S") & ")"
	connAdm.execute(strQuery)

	' history table too...
	strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,revisionNumber,comments) values(" &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(experimentId,"N","S") & "," &_
	SQLClean(experimentType,"N","S") & "," &_
	SQLClean(newExperimentId,"N","S") & "," &_
	SQLClean(revisionNumber,"N","S") & "," &_
	SQLClean("A copy of this experiment.","T","S") & ")"
	connAdm.execute(strQuery)

	'update the elasticIndexQueue
	strQuery = "INSERT INTO elasticIndexQueue (experimentId, experimentType, companyId, revisionNumber, dateCreated, status) VALUES (" & newExperimentId & "," & experimentType & "," & session("companyId") & ",1,GETDATE(),'NEW')"
	connAdm.execute(strQuery)
		
	'set the function value to the new experiment Id
	copyExperiment = CStr(newExperimentId)
end function
%>