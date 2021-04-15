<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
hasCombi = checkBoolSettingForCompany("hasCombi", session("companyId"))
hasCombiPlate = checkBoolSettingForCompany("hasCombiPlate", session("companyId"))
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
mainInvURL = getCompanySpecificSingleAppConfigSetting("mainInvUrlEndpoint", session("companyId"))
'save chemistry experiment with marvin%>
<%Server.scriptTimeout = 6000%>
<%
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->
<!-- #include file="../_inclds/database/functions/fnc_callStoredProcedure.asp"-->
<!-- #include virtual="/arxlab/apis/eln/fnc_getElnApiServerName.asp"-->
<%
'get form JSON object (all form data is set in one JSON object with the form names as the keys)
experimentJSON = request.form("hiddenExperimentJSON")
Set experimentJSON = JSON.parse(experimentJSON)
experimentId = experimentJSON.get("experimentId")
experimentType = "1"
notebookId = experimentJSON.get("notebookId")

If session("requireProjectLink") Then
	'return error if no project is linked and project link is required
	%><!-- #include file="../_inclds/experiments/common/asp/requireProjectLink.asp"--><%
End if

Call getconnectedadmTrans
'start transaction
connAdmTrans.beginTrans

'if the hungsaveSerial is already in the ACK table don't continue
'because the experiment is already in the process of saving
hungSaveSerial = experimentJSON.get("hungSaveSerial")
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM serialsAck WHERE serial="&SQLClean(hungSaveSerial,"T","S")
rec.open strQuery,connAdmTrans,3,3
If Not rec.eof Then
	response.Status = "400 Bad Request"
End If
rec.close
Set rec = nothing

'insert hungSaveSerial into ACK table
connAdmTrans.execute("INSERT INTO serialsAck(serial) values("&SQLClean(hungSaveSerial,"T","S")&")")
If Not ownsExperiment("1",experimentId,session("userId")) Then
	response.redirect(mainAppPath&"/static/notAuthorized.asp")
End if

'prevent saving of previous revisions
If experimentJSON.get("thisRevisionNumber") <> "" then
	maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
	If CInt(maxRevisionNumber) <> CInt(experimentJSON.get("thisRevisionNumber"))Then
		response.Status = "403 There is a newer version of this experiment. Changes will not be saved."
	End if
End If

'return error if experiment description field is too long
If Len(experimentJSON.Get("e_details"))>2000 Then
		response.Status = "413 Experiment description field can contain a maximum of 2000 characters"
End If
'start combi
cdIds = Split(experimentJSON.get("combiFields"),",")
For i = 0 To UBound(cdIds)
	strQuery = "UPDATE combiSDMols SET field1="&SQLClean(experimentJSON.get("combiField_"&cdIds(i)),"T","S")&" WHERE cd_id="&SQLClean(cdIds(i),"N","S")
	connAdmTrans.execute(strQuery)
Next
'end combi
%>
<%
		Call getconnected
		
		'if chemdraw is changed set the experiment loading flag.  When python is done processing the chemistry it will clear this flag to let the
		'asp pages know that it can reload the page
		' If experimentJSON.get("chemDrawChanged") = "1" Then
		' 	strQuery = "INSERT into experimentLoading(experimentId,dateSubmitted,cleared) values("&SQLClean(experimentId,"N","S")&",GETDATE(),0)"
		' 	connAdm.execute(strQuery)
		' End if

		Set rs = Server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT statusId FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
		rs.open strQuery,conn,3,3
		'status id 3 is signed-open the system use to set the status to reopened when the previous 
		'status was 3
		If rs("statusId") = 3 then
			newStatusId = "2"
		else
			newStatusId = "2"
		End if
		experimentType = "1"
		%>
		<!-- #include file="../_inclds/experiments/common/asp/signValidate.asp"-->
		<%
		rs.close
		Set rs = Nothing

		'set new revision number
		Set rs = Server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S")
		rs.open strQuery,conn,3,3
		revisionNumber = rs.recordCount + 1
		rs.close
		Set rs = Nothing
		
		'!!!!!!!!!!!!!!! CALL STORED PROCEDURE !!!!!!!!!!!!!!!!!!!!
		Set args = JSON.parse("{}")
		Call addStoredProcedureArgument(args, "companyId", adBigInt, SQLClean(session("companyId"),"N","S"))
		Call addStoredProcedureArgument(args, "userId", adBigInt, SQLClean(session("userId"),"N","S"))
		Call addStoredProcedureArgument(args, "projectId", adBigInt, SQLClean(0,"N","N"))
		Call addStoredProcedureArgument(args, "experimentId", adBigInt, SQLClean(experimentId,"N","S"))
		Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
		Call addStoredProcedureArgument(args, "notebookId", adBigInt, SQLClean(notebookId,"N","N"))
		Call addStoredProcedureArgument(args, "statusId", adInteger, SQLClean(newStatusId,"N","N"))
		Call addStoredProcedureArgument(args, "experimentName", adVarChar, SQLClean(experimentJSON.get("e_name"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "experimentDescription", adVarChar, SQLClean(experimentJSON.get("e_details"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "numSigFigs", adInteger, SQLClean(experimentJSON.get("sigdigText"),"N","S"))
		Call addStoredProcedureArgument(args, "protocol", adLongVarChar, "")
		Call addStoredProcedureArgument(args, "summary", adLongVarChar, "")
		Call addStoredProcedureArgument(args, "conceptDescription", adLongVarChar, "")
		Call addStoredProcedureArgument(args, "userExperimentName", adVarChar, "")
		Call addStoredProcedureArgument(args, "beenExported", adTinyInt, 0)
		Call addStoredProcedureArgument(args, "preparation", adLongVarChar, SQLClean(experimentJSON.get("e_preparation"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "searchPreparation", adLongVarChar, SQLClean(cleanWhiteSpace(removeTags(experimentJSON.get("e_preparation"))),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "cdx", adLongVarChar, SQLClean(replace(replace(experimentJSON.get("cdxData"),"\\""","\"""),"&quot;",""""),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "reactionMolarity", adVarChar, SQLClean(experimentJSON.get("e_Molarity"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "pressure", adVarChar, SQLClean(experimentJSON.get("e_pressure"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "temperature", adVarChar, SQLClean(experimentJSON.get("e_temperature"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "molData", adLongVarChar, SQLClean(experimentJSON.get("molData"),"T-PROC","S"))
		Call addStoredProcedureArgument(args, "craisStatus", adInteger, 0)
		Call addStoredProcedureArgument(args, "resultSD", adLongVarChar, "")
		Call addStoredProcedureArgument(args, "visible", adTinyInt, 1)
		Call addStoredProcedureArgument(args, "mrvData", adLongVarWChar, SQLClean(experimentJSON.get("mrvData"),"T-PROC","S"))

		If session("canChangeExperimentNames") Then
			Call addStoredProcedureArgument(args, "userExperimentName", adVarChar, SQLClean(experimentJSON.get("e_userAddedName"),"T-PROC","S"))
		End If
		if experimentJSON.Get("chemDrawChanged") = "1" Then
			'if chemdraw has changed reset crais status to not done
			'because that means most likely there is at least one new molecule that will need to be checked
			'note: changes to chemdraw will not always be a chemical change.  This is a known issue and has not caused any issues so far
			Call addStoredProcedureArgument(args, "craisStatus", adInteger, SQLClean("0","N","S"))
		End If
		If hasCombi and hasCombiPlate then
			Call addStoredProcedureArgument(args, "resultSD", adLongVarChar, SQLClean(experimentJSON.get("resultSD"),"T-PROC","S"))
		End If
					
		confirmExperimentId = callStoredProcedure("elnSaveExperiment_marvin", args, True)
		a = logAction(2,experimentId,"",3)
		
		'delete all molecules.  they will be re-added from the form data/chemistry processing
		strQuery = "DELETE FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
		connAdmTrans.execute(strQuery)
		strQuery = "DELETE FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
		connAdmTrans.execute(strQuery)
		strQuery = "DELETE FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")
		connAdmTrans.execute(strQuery)
		strQuery = "DELETE FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
		connAdmTrans.execute(strQuery)

	'copy experiment links from current experiment links into the experiment links history
	Set lRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experimentLinks WHERE experimentType=1 and experimentId="&SQLClean(experimentId,"N","S")
	lRec.open strQuery,connAdmTrans,3,3
	Do While Not lRec.eof
		strQuery = "INSERT into experimentLinks_history(experimentType,experimentId,linkExperimentType,linkExperimentId,prev,next,comments,revisionNumber) values(" &_
		SQLClean(lRec("experimentType"),"N","S") & "," &_
		SQLClean(lRec("experimentId"),"N","S") & "," &_
		SQLClean(lRec("linkExperimentType"),"N","S") & "," &_
		SQLClean(lRec("linkExperimentId"),"N","S") & "," &_
		SQLClean(lRec("prev"),"N","S") & "," &_
		SQLClean(lRec("next"),"N","S") & "," &_
		SQLClean(lRec("comments"),"T","S") & "," &_
		SQLClean(revisionNumber,"N","S") &")"
		connAdmTrans.execute(strQuery)
		lRec.movenext
	Loop
	lRec.close
	Set lRec = Nothing

	'take reg links from presave table and put them in the current reg links table
	Set lRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experimentRegLinks_preSave WHERE experimentType=1 and experimentId="&SQLClean(experimentId,"N","S")
	lRec.open strQuery,connAdmTrans,3,3
	Do While Not lRec.eof
		strQuery = "INSERT into experimentRegLinks(experimentType,experimentId,regNumber,displayRegNumber) values(" &_
		SQLClean(lRec("experimentType"),"N","S") & "," &_
		SQLClean(lRec("experimentId"),"N","S") & "," &_
		SQLClean(lRec("regNumber"),"T","S") & "," &_
		SQLClean(lRec("displayRegNumber"),"T","S") & ")"
		connAdmTrans.execute(strQuery)
		lRec.movenext
	Loop
	lRec.close

	'copy reg links from current reg links table to experiment reg links history
	strQuery = "SELECT * FROM experimentRegLinks WHERE experimentType=1 and experimentId="&SQLClean(experimentId,"N","S")
	lRec.open strQuery,connAdmTrans,3,3
	Do While Not lRec.eof
		strQuery = "INSERT into experimentRegLinks_history(experimentType,experimentId,regNumber,displayRegNumber,revisionNumber,comments) values(" &_
		SQLClean(lRec("experimentType"),"N","S") & "," &_
		SQLClean(lRec("experimentId"),"N","S") & "," &_
		SQLClean(lRec("regNumber"),"T","S") & "," &_
		SQLClean(lRec("displayRegNumber"),"T","S") & "," &_
		SQLClean(revisionNumber,"N","S") & "," &_
		SQLClean(lRec("comments"),"T","S") &")"
		connAdmTrans.execute(strQuery)
		lRec.movenext
	Loop
	lRec.close
	Set lRec = Nothing

	'delete presave reg links
	connAdmTrans.execute("DELETE FROM experimentRegLinks_preSave WHERE experimentType=1 AND experimentId="&SQLClean(experimentId,"N","S"))

	%>
	<!-- #include file="../_inclds/experiments/common/asp/saveAttachments.asp"-->
	<!-- #include file="../_inclds/experiments/common/asp/saveNotes.asp"-->
	<!-- #include file="../_inclds/experiments/chem/asp/saveReactants.asp"-->
	<!-- #include file="../_inclds/experiments/chem/asp/saveReagents.asp"-->
	<!-- #include file="../_inclds/experiments/chem/asp/saveProducts.asp"-->
	<!-- #include file="../_inclds/experiments/chem/asp/saveSolvents.asp"-->
	<%

	'delete experiment draft
	strQuery = "DELETE FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	connAdmTrans.execute(strQuery)

	'commit the transaction, then start processing the chemistry
	connAdmTrans.commitTrans

	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * from experiments WHERE id="&SQLClean(experimentId,"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		cdxData = Replace(rec("cdx"),"\\""","\""")
	End If
	rec.close
	Set rec = Nothing

	'send mrvData to python with appropriate flag for whether or not the chemistry data has changed
		newFlag = ""
		If experimentJSON.get("chemDrawChanged") = "1" Then
			newFlag = "new"
		Else
			newFlag = "notnew"
		End If
		
		'Call the save method in elnAPI that calls the dispatch_marvin
		body = "company_id="+Server.URLEncode(session("companyId"))	
		body = body + "&user_id="+Server.URLEncode(session("userId"))	
		body = body + "&experiment_id="+Server.URLEncode(experimentId)	
		body = body + "&revision_number="+Server.URLEncode(revisionNumber)	
		body = body + "&draft_save=False"	
		body = body + "&mrvData="+Server.URLEncode(experimentJSON.get("mrvData"))	
		body = body + "&experimentJSON="+Server.URLEncode(JSON.stringify(experimentJSON))

		Set objXmlHttp = Server.CreateObject("MSXML2.ServerXMLHTTP")
		objXmlHttp.open "POST", getElnApiServerName() & "ChemDataMarvin/save", True
		objXmlHttp.SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"
		objXmlHttp.send body
		objXmlHttp.waitForResponse(60)
		'mrvData = objXmlHttp.responseText

		Set objXmlHttp = Nothing


		' set fs=Server.CreateObject("Scripting.FileSystemObject")
		' set tfile=fs.CreateTextFile("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(session("userId"))&"_"&session("userId")&"_"&experimentId&"_"&revisionNumber&"_"&Abs(session("hasCompoundTracking"))&"_"&newFlag&"_rxn.rxn",false,true)
		' tfile.WriteLine(Replace(Replace(Replace(cdxData,"\""",""""),"HeightPages=""1""","HeightPages=""5"""),"WidthPages=""1""","WidthPages=""5"""))
		' tfile.close
		' set tfile=nothing
		' set fs=Nothing
		' a = logAction(2,experimentId,"",25)

		if experimentJSON.get("chemDrawChanged") <> "1" Then
			'update revision numbers in jchem search table
			Call getconnectedJchem
			Set jRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM "&elnChemSearchTable&" WHERE experiment_id="&SQLClean(experimentId,"N","S")&" ORDER BY revision_number DESC"
			jRec.open strQuery,jchemConn,3,3
			If Not jRec.eof Then
				oldRevisionNumber = jRec("revision_number")
				strQuery = "UPDATE "&elnChemSearchTable& " SET revision_number="&SQLClean(revisionNumber,"N","S") & " WHERE experiment_id="&SQLClean(experimentId,"N","S")&" and revision_number="&SQLClean(oldRevisionNumber,"N","S")
				jchemConn.execute(strQuery)
			End if
			Call disconnectjchem
		End If

		'if the experiment is being signed and the chemdraw has changed wait for the chemistry to be processed before 
		'sending the file to dispatch to make the pdf
		counter = 0
		Set bRec = server.CreateObject("ADODB.RecordSet")
		Do While True And counter < 200
			counter = counter + 1
			sleep = 0.25
			strQuery = "WAITFOR DELAY '00:00:" & right(clng(sleep),2) & "'" 
			conn.Execute(strQuery)
			strQuery = "SELECT COUNT(*) as loadingCount FROM experimentLoading WHERE experimentId="&SQLClean(experimentId,"N","S")
			bRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
			If bRec("loadingCount") = 0 Then
				counter = 10000
			End If
			bRec.close
		Loop
		Set bRec = nothing

	'on signe if the company has inventory integration, reconcile with inventory
	If newStatusId="5" And session("hasInventoryIntegration") Then
		'get services connection id if it is not already in the session
		If session("servicesConnectionId") = "" Then
			session("servicesConnectionId") = session("userId")&getRandomString(16)
			'Call getconnectedadm
			strQuery = "UPDATE users SET servicesConnectionId="&SQLClean(session("servicesConnectionId"),"T","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
			connAdm.execute(strQuery)
			'Call disconnectadm
			data = "{""connectionId"":"""&session("servicesConnectionId")&""",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&"""}"
			Set http = CreateObject("MSXML2.ServerXMLHTTP")
			http.setOption 2, 13056
			http.open "POST",mainInvURL&"/elnConnection/",True
			http.setRequestHeader "Content-Type","text/plain"
			http.setRequestHeader "Content-Length",Len(data)
			http.SetTimeouts 120000,120000,120000,120000
			http.send data
			http.waitForResponse(60)
		End If
		tableNames = Split("reactants,reagents,products,solvents",",")
		'loope through all molecule tables
		For q = 0 To UBound(tableNames)
			tableName = tableNames(q)
			queryCols = "inventoryItems"
			If tableName <> "products" Then
				queryCols = queryCols & ",volume"
			End If
			If tableName = "reactants" Or tableName = "reagents" Then
				queryCols = queryCols & ",sampleMass"
			End If
			If tableName = "products" Then
				queryCols = queryCols & ",actualMass"
			End If
			
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT " & queryCols & " FROM "&tableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")
			rec.open strQuery,conn,0,-1
			'link for source in inventory audit trail
			theLink = mainAppPath&"/experiment.asp?id="&experimentId
			theLink = "<a href='"&theLink&"'>"&experimentJSON.get("e_name")&"</a>"
			Do While Not rec.eof
				'if there are inventory items associated with this molecule
				If rec("inventoryItems") <> "[]" And rec("inventoryItems") <> "" Then
					Set items = JSON.parse(join(array(rec("inventoryItems"))))
					For Each item In items
						'get inventory initial amount used
						If item.Get("id") <> "" then
							inventoryId = item.Get("id")
							originalAmount = item.Get("amount")
							For Each key In item.keys()
								If key = "isVolume" then
									isVolume = item.Get("isVolume")
								End if
							next
						End if
					Next
					'get new amount
					If tableName <> "products" Then
						If isVolume Then
							newAmount = rec("volume")
						Else
							If tableName <> "solvents" then
								newAmount = rec("sampleMass")
							End if
						End if
					Else
						newAmount = rec("actualMass")					
					End if
					If tableName = "products" Then
						x = newAmount
						newAmount = originalAmount
						originalAmount = x
					End If
					'change units to units inventory understands
					newAmount = Replace(newAmount,"�","u")
					If Not (tableName="solvents" And isVolume=False) then
						'send reconcile command to inventory
						data = "{""connectionId"":"""&session("servicesConnectionId")&""",""amount"":"""&newAmount&""",""originalAmount"":"""&originalAmount&""",""id"":"&inventoryId&",""theLink"":"""&theLink&"""}"
						Set http = CreateObject("MSXML2.ServerXMLHTTP")
						http.setOption 2, 13056
						http.open "POST",mainInvURL&"/reconcile/",True
						http.setRequestHeader "Content-Type","text/plain"
						http.setRequestHeader "Content-Length",Len(data)
						http.SetTimeouts 120000,120000,120000,120000
						http.send data
						http.waitForResponse(60)
					End if
				End if
				rec.movenext
			Loop
			rec.close
			Set rec = Nothing
		next
	End If
	'look for structures that have changed their chemistry
	If session("hasInventoryIntegration") And session("hasCompoundTracking") Then
		types = Split("reactant,reagent,solvent,product",",")
		For i = 0 To UBound(types)
			theType = types(i)
			Select Case theType
				Case "reactant"
					tableName = "reactants"
				Case "reagent"
					tableName = "reagents"
				Case "solvent"
					tableName = "solvents"
				Case "product"
					tableName = "products"
			End Select
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT trivialName FROM "&tableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")
			rec.open strQuery,conn,0,-1
			'loop through all molecule types
			Do While Not rec.eof
				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery2 = "SELECT id,inventoryId,inventoryName FROM inventoryMolLinks WHERE molName="&SQLClean(rec("trivialName"),"T","S")&" and cleared=0 ORDER BY id DESC"
				rec2.open strQuery2,conn,1,1
				'if there is more than one structure with the same label (chemistry has changed)
				If rec2.recordCount > 1 Then
					'send the old inventory id and the new inventory id along with the lable
					'to inventory.  Inventory will send out an email with details on the changed structure.
					newId = rec2("id")
					newInventoryId = rec2("inventoryId")
					newInventoryName = rec2("inventoryName")
					rec2.movenext
					oldId = rec2("id")
					oldInventoryId = rec2("inventoryId")
					oldInventoryName = rec2("inventoryName")
					connAdm.execute("UPDATE inventoryMolLinks SET cleared=1 WHERE molName="&SQLClean(rec("trivialName"),"T","S")&" AND id<>"&SQLClean(newId,"N","S"))
					data = "{""connectionId"":"""&session("servicesConnectionId")&""",""molName"":"""&rec("trivialName")&""",""type"":"""&theType&""",""newInventoryId"":"&newInventoryId&",""newInventoryName"":"""&newInventoryName&""",""oldInventoryId"":"&oldInventoryId&",""oldInventoryName"":"""&oldInventoryName&"""}"
					Set http = CreateObject("MSXML2.ServerXMLHTTP")
					http.setOption 2, 13056
					http.open "POST",mainInvURL&"/brokenChain/",True
					http.setRequestHeader "Content-Type","text/plain"
					http.setRequestHeader "Content-Length",Len(data)
					http.SetTimeouts 120000,120000,120000,120000
					http.send data
					http.waitForResponse(60)
				End if
				rec2.close
				Set rec2 = nothing
				rec.movenext
			Loop
			rec.close
			Set rec = nothing
		next
	End If

	'if experiment is signed send JSON object to inbox to make the PDF
	If newStatusId = "5" And experimentJSON.get("chemDrawChanged") <> "1" then
		a = savePDF("1",experimentId,revisionNumber,true,false,false)	
		a = logAction(2,experimentId,"",7)
	End if
	experimentType = "1"

	'send experiment saved notifications
	%><!-- #include file="../_inclds/experiments/common/asp/experimentSavedNotifications.asp"--><%

	'not sure about this the flag is used in chemJS_no_chemdraw on line 561
	If experimentJSON.get("chemDrawChanged") = "1" Then
		session("chemdrawWasChanged") = true
	Else
		session("chemdrawWasChanged") = false		
	End if

	If experimentId <> "" Then
		session("justSaved")=true
		Set d = JSON.parse("{}")
		d.Set "hungSaveSerial", hungSaveSerial
		d.Set "revisionNumber", (revisionNumber + 1)
		'd.Set "mrvData", mrvData
		data = JSON.stringify(d)
		Response.Status = "200"
		response.write(data)
	End if

%>