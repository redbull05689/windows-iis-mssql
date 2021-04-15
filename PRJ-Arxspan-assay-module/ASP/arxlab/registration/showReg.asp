<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<script language="JScript" src="encodeStr.asp" runat="server"></script>
<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include file="_inclds/fnc_sendProteinToSearchTool.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%

Response.CodePage = 65001    
Response.CharSet = "utf-8"

' Role Number 1000 is "No Acesses". 30 is "restricted" 
if session("regRoleNumber") >= 30 then
	response.redirect(mainAppPath&"/static/errorMessage.asp?title=Sorry&message=You%20do%20not%20have%20access%20to%20this%20resource")
end if

Function printIfSupport(printString, closeResponse)
	If session("email") = "support@arxspan.com" Then
		response.write(printString)

		If closeResponse Then
			response.End()
		End If
	End If
End Function

Call getconnectedJchemReg
%>
<!-- #include file="_inclds/fnc_removeCdIdsFromFT.asp"-->
<%
isBatchForAdd = False
%>
<!-- #include file="_inclds/inventoryPopup.asp"-->

<%
wholeRegNumber = request.querystring("regNumber")
%>

<%
moleculeAddedText = "Molecule Added"
addAnotherStructureText = "ADD ANOTHER STRUCTURE"
addBatchText = "ADD BATCH"

hasRegSorting = checkBoolSettingForCompany("allowRegistrationSorting", session("companyId"))
jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
regSaltMappingTable = getCompanySpecificSingleAppConfigSetting("regSaltMappingTable", session("companyId"))
regSaltsView = getCompanySpecificSingleAppConfigSetting("regSaltMappingView", session("companyId"))
regSaltSearchMode = getCompanySpecificSingleAppConfigSetting("regSaltSearchMode", session("companyId"))
regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
projectFieldInReg = checkBoolSettingForCompany("useProjectFieldInReg", session("companyId"))
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
polymer = getCompanySpecificSingleAppConfigSetting("polymer", session("companyId"))
alsoUpdateAccMolsWhenEditingRegStructure = checkBoolSettingForCompany("updateAccMolsTableWhenEditingRegStructure", session("companyId"))

Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT cd_id,groupId,just_reg,projectId,reg_id FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(wholeRegNumber&regBatchNumberDelimiter&padWithZeros(0,regBatchNumberLength),"T","S")
rec.open strQuery,jchemRegConn,3,3
If rec.eof Then
	response.write("We are unable to loacate this Registration ID. Please contact support@arxspan.com")
	printIfSupport "<br>" & strQuery, False
	response.end()
End If
theRegId = rec("reg_id")
theCdId = rec("cd_id")
groupId = rec("groupId")
regNumber = rec("just_reg")
projectId = rec("projectId")
hasStructure = True
allowBatches = True
imageWidth = "300"
imageHeight = "300"

numZeroes = 0
compStr = regBatchNumberDelimiter
Do While numZeroes < CInt(regBatchNumberLength)
	compStr = compStr & "0"
	numZeroes = numZeroes + 1
Loop

batchZeroPos = InStrRev(theRegId, compStr)
If batchZeroPos = (Len(theRegId) - regBatchNumberLength) Then
	theRegId = Left(theRegId, batchZeroPos - 1)
End If

useSalts = False
If regSaltSearchMode <> "OFF" Then
	useSalts = True
End If

groupPrefix = ""

If Not IsNull(groupId) Then
	If groupId <> "0" then
		isGroup = True
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
		If session("regRestrictedGroups") <> "" Then
			strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
		End if
		rec2.open strQuery,jchemRegConn,3,3
		If Not rec2.eof Then
			If rec2("hasStructure") = 0 Then
				hasStructure = False
			End If
			If rec2("allowBatches") = 0 Then
				allowBatches = False
			End If
			If rec2("useSalts") <> 1 Then
				useSalts = False
			End If
			If columnExists(rec2,"imageWidth") Then
				If Not IsNull(rec2("imageWidth")) then
					imageWidth = rec2("imageWidth")
				End if
			End If
			If columnExists(rec2,"imageHeight") Then
				If Not IsNull(rec2("imageHeight")) then
					imageHeight = rec2("imageHeight")
				End if
			End if
			groupPrefix = rec2("groupPrefix")
		Else
			title = "Error"
			message = "Group does not exist or you are not authorized to access it."
			response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
		End if
	End if
End if
rec.close
Set rec = Nothing

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT distinct id, name FROM projects WHERE id in (SELECT projectId FROM linksProjectRegView where cd_id="&SQLClean(theCdId,"N","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")&") or id in ("&SQLClean(projectId,"N","S")&")"
rec.open strQuery,conn,3,3
Set projectJsonObj = JSON.Parse("[]")
Do While Not rec.eof
	Set projectObj = JSON.Parse("{}")
	projectObj.Set "id", CStr(rec("id"))
	projectObj.Set "name", CStr(rec("name"))
	projectJsonObj.Push(projectObj)
	rec.movenext
loop
rec.close
Set rec = Nothing

On Error Resume next
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM regTemplates WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND groupId="&SQLClean(groupId,"N","S")
If request.Form("addBatch") = "1" Then
	strQuery = strQuery & " AND batch=1"
else
	strQuery = strQuery & " AND compound=1"
End If
rec.open strQuery,conn,3,3
If Not rec.eof Then
	regHasTemplate = True
Else
	regHasTemplate = False
End if
If Err.number <> 0 Then
 regHasTemplate = true
End if
On Error goto 0
%>

<%
canViewPage = true
if Not (session("regRegistrar") Or session("regUser")) Then
	canViewPage = False
End If

If session("regRestrictedUser") Then
	canViewPage = False
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT projectId FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1"
	rec.open strQuery,conn,3,3
	projectString = "(0"
	If Not rec.eof Then
		projectString = projectString & ","
	End if
	Do While Not rec.eof
		projectString = projectString & rec("projectId")
		rec.movenext
		If Not rec.eof Then
			projectString = projectString & ","
		End if
	Loop
	projectString = projectString & ")"
	rec.close
	Set rec = Nothing
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM linksProjectRegView where cd_id="&SQLClean(theCdId,"N","S")& " AND (projectId in "&projectString&" OR parentProjectId in "&projectString&")"
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		canViewPage = True	
	End If
End If
%>

<%
If canDeleteStructureReg Then
	If request.Form("deleteStructureSubmitted") <> "" Then
		deleteStructureCdId = request.Form("deleteStructureCdId")

		Call getConnectedJchemReg
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE parent_cd_id="&SQLClean(deleteStructureCdId,"N","S")
		rec.open strQuery,jchemRegConn,3,3
		If Not rec.eof Then
			errorStr = "You must delete all batches before you can delete a compound."
		End If
		rec.close
		Set rec = Nothing

		If errorStr = "" Then
			
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(deleteStructureCdId,"N","S")
			rec.open strQuery,jchemRegConn,3,3
			cdIdStr = ""
			Do While Not rec.eof
				cdIdStr = cdIdStr & rec("cd_id")
				rec.movenext
				If Not rec.eof Then
					cdIdStr = cdIdStr & ","
				End if
			Loop
			rec.close
			Set rec = Nothing
			a = removeCdIdsFromFT(cdIdStr)
			cdIds = Split(cdIdStr,",")
			For i = 0 To UBound(cdIds)
				a = CX_removeStructure(jChemRegDB,regMoleculesTable,cdIds(i))
			Next
			response.redirect("search.asp")
		End if
		Call disconnectJchemReg

	End if
End If

If canEditStructureReg Then
	If request.Form("editStructureSubmitted") <> "" Then
		If request.Form("editStructureMolData") = "" Then
			errorStr = "Please Enter A Structure"
		End if
		If errorStr = "" Then
			originalEditStructureStereo = request.Form("editStructureStereo")
			editStructureStereo = LCase(Trim(request.Form("editStructureStereo")))
			
			editStructureMolData = request.Form("editStructureMolData")
	
			inputMolDataJson = analyzeInputMol(editStructureMolData)
			Set inputMolData = JSON.Parse(inputMolDataJson)
			If IsObject(inputMolData) Then
				editStructureMolData = inputMolData.Get("structure")
				editStructureMolDataFormat = inputMolData.Get("molFormat")
			End If
			
			editStructureMolData = CX_standardize(editStructureMolData,editStructureMolDataFormat,defaultStandardizerConfig,"mol:V3")
			smilesWithSalts = CX_standardize(editStructureMolData,"mol:V3",defaultStandardizerConfig,"smiles")
			
			If editStructureStereo <> "" then
				Set d = JSON.parse("{}")
				d.Set "structure", editStructureMolData
				data = JSON.stringify(d)
				Set http = CreateObject("MSXML2.ServerXMLHTTP")
				http.setOption 2, 13056
				http.open "POST",chemAxonCipStereoUrl,True
				http.setRequestHeader "Content-Type","application/json" 
				http.setRequestHeader "Content-Length",Len(data)
				http.SetTimeouts 120000,120000,120000,120000
				http.send data
				http.waitForResponse(60)
				Set r = JSON.parse(http.responseText)
				numStereoCenters = 0
				numUndefinedStereoCenters = 0
				Set tetraHedral = r.Get("tetraHedral")
				For Each item In tetraHedral
					If JSON.stringify(item) <> "" Then
						For Each key In item.keys()
							If key = "chirality" Then
								val = item.Get(key)
								If val = "R/S" Or val = "S/R" Then
									numUndefinedStereoCenters = numUndefinedStereoCenters + 1
								End if
							End if
						next
						numStereoCenters = numStereoCenters + 1
					End if
				Next

    			regCountDoubleBondsForChirality = checkBoolSettingForCompany("countDoubleBondsForChiralityInReg", session("companyId"))
				If r.exists("doubleBond") And regCountDoubleBondsForChirality Then
					Set doubleBond = r.Get("doubleBond")
					For Each item In doubleBond
						If JSON.stringify(item) <> "" then
							numStereoCenters = numStereoCenters + 1
						End if
					Next
				End If

				If r.exists("doubleBond_new") And regCountDoubleBondsForChirality Then
					Set doubleBondNew = r.Get("doubleBond_new")
					For Each item In doubleBondNew
						If JSON.stringify(item) <> "" then
							numStereoCenters = numStereoCenters + 1
						End if
					next
				End If
				'response.write(JSON.stringify(tetraHedral)&"<br>")
				'response.write(JSON.stringify(doubleBond)&"<br>")
				'response.write("centers: "&numStereoCenters&"<br>")
				'response.write("undef centers: "&numUndefinedStereoCenters&"<br>")

				'check that there is more than one molecule if structure is chosen
				'done
				If editStructureStereo = "" Or editStructureStereo = "-1" Then
					regError = True
					errorText = errorText & "Please enter a value for stereochemistry. <br/>"
				End If
				If editStructureStereo = "mixture" Then
					If Not (ubound(Split(smilesWithSalts,".")) >0 or numUndefinedStereoCenters>0) then
						regError = True
						errorText = errorText & "Mixtures must contain either more than one structure or an undefined stereocenter. <br/>"
					End if
				End If
				
				'done
				If editStructureStereo = "chiral" Then
					If Not (numUndefinedStereoCenters=0 And numStereoCenters>0) then
						regError = True
						errorText = errorText & "Chiral structures must contain at least one stereocenter and have all stereocenters defined.  <br/>"
					End if
				End If

				If editStructureStereo = "racemic" Then
					If Not (numStereoCenters>0 And numUndefinedStereoCenters>0)  then
						regError = True
						errorText = errorText & "Racemic structures must contain at least one undefined stereocenter.  <br/>"
					End if
				End If

				If editStructureStereo = "relative" Then
					If Not (numStereoCenters>1 And numUndefinedStereoCenters=0)  then
						regError = True
						errorText = errorText & "Relative structures must contain more than one stereocenter and have all stereocenters defined.  <br/>"
					End if
				End If

				'done
				If editStructureStereo = "achiral" Then
					If Not (numStereoCenters=0) then
						regError = True
						errorText = errorText & "Achiral structures may not contain stereocenters.  <br/>"
					End if
				End If

				If editStructureStereo = "undefined" Then
					If Not (numStereoCenters>0 And numUndefinedStereoCenters>0)  then
						regError = True
						errorText = errorText & "Undefined structures must contain at least one undefined stereocenter.  <br/>"
					End if
				End If
				'//5115
			End if
			If errorText = "" then
				editStructureCdId = request.Form("editStructureCdId")
				
				Call getConnectedJchemReg
				Set rec = server.CreateObject("ADODB.RecordSet")
				groupStr = " AND groupId="&SQLClean(groupId,"N","S")
				If SQLClean(groupId,"N","S")=0 Then
					groupStr = " AND (groupId=0 or groupId is null)"
				End If
				strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE just_reg="&SQLClean(regNumber,"N","S")&groupStr
				rec.open strQuery,jchemRegConn,3,3
				cdIdStr = ""
				Do While Not rec.eof
					cdIdStr = cdIdStr & rec("cd_id")
					rec.movenext
					If Not rec.eof Then
						cdIdStr = cdIdStr & ","
					End if
				Loop
				rec.close
				Set rec = Nothing

				%><!-- #include file="_inclds/searchOptionsString.asp"--><%

				' list of fields we want back
				fields = "[""cd_id"",""just_reg""]"
				
				' additional conditions to impose on the query, beyond structure
				conditions = "{""just_reg"": {""$ne"":"& SQLClean(regNumber,"N","S") & "}}"

				Set searchParamJson = JSON.parse("{}")
				searchParamJson.Set "searchType", "DUPLICATE"
				
				'TODO 2147483647 is just Java Max Int, need to do a better job of knowing what the number of results should be
				searchHitJson = CX_structureSearch(jChemRegDB,regMoleculesTable,editStructureMolData,conditions,JSON.stringify(searchParamJson),fields,2147483647,0)
				
				dupe = False
				Set searchHits = JSON.parse(searchHitJson)
				If IsObject(searchHits) And searchHits.Exists("data") Then
					Set results = searchHits.Get("data")
					If IsObject(results) Then
						cleanResultsJson = cleanRelativeStereoHits(editStructureMolData, "", JSON.Stringify(results), jChemRegDB, regMoleculesTable)
						Set cleanResults = JSON.Parse(cleanResultsJson)
						numResults = cleanResults.Length
						If numResults = 1 Then
							Set thisResult = cleanResults.Get(0)
							thisRegId = thisResult.Get("just_reg")
							
							Set tRec2 = server.CreateObject("ADODB.RecordSet")
							strQuery = "SELECT just_reg FROM "&regMoleculesTable&" WHERE just_reg="&SQLClean(regNumber,"T","S")&" AND groupId="&SQLClean(groupId,"N","S")
							tRec2.open strQuery,jchemRegConn,3,3
							If Not tRec2.eof Then
								If thisRegId <> tRec2("just_reg") Then
									dupe = False					
								Else
									dupe = True
								End if
							else
								dupe = True
							End If
							tRec2.close
							set tRec2 = nothing
						End If
					End If
				End If
				
				If Not dupe Then
					strQuery = "UPDATE "&regMoleculesTable&" SET vc_1="&SQLClean(originalEditStructureStereo,"T","S")&" WHERE cd_id="&SQLClean(editStructureCdId,"N","S")
					jchemRegConn.execute(strQuery)
					cdIds = Split(cdIdStr,",")
					for Each cdid in CdIds
						Set aRec = server.CreateObject("ADODB.RecordSet")
						strQuery2 = "SELECT cd_timestamp FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(cdid,"N","S")
						aRec.open strQuery2,jchemRegConn,3,3
						dateCreated = aRec("cd_timestamp")
						aRec.close
						Set aRec = nothing
						a = CX_updateStructure(jChemRegDB,regMoleculesTable,editStructureMolData,cdid)
						newName = CX_convertStructure(editStructureMolData, "mol:V3", "name")
						strQuery2 = "UPDATE "&regMoleculesTable&" SET chemaxon_chemical_name="&SQLClean(newName,"T","S")&" WHERE cd_id="&SQLClean(cdid,"N","S")
						jchemRegConn.execute(strQuery2)
						strQuery2 = "UPDATE "&regMoleculesTable&" SET cd_timestamp="&SQLClean(dateCreated,"T","S")&" WHERE cd_id="&SQLClean(cdid,"N","S")
						'response.write(strQuery2)
						jchemRegConn.execute(strQuery2)
						dateFunction = "GETDATE()"
						strQuery2 = "UPDATE "&regMoleculesTable&" SET "&_
								"dateLastModified="&dateFunction &","&_
								"userLastModified="&SQLClean(session("firstName")&" "&session("lastName"),"T","S") & "," &_
								"userLastModifiedId="&SQLClean(session("userId"),"N","S") &_
								" WHERE cd_id="&SQLClean(cdid,"N","S")
						jchemRegConn.execute(strQuery2)
						strQuery2 = "INSERT INTO modLog(cd_id,userId,dateModified,userName) values("&_
								SQLClean(cdid,"N","S")&","&_
								SQLClean(session("userId"),"N","S")&","&_
								dateFunction & "," &_
								SQLClean(session("firstName")&" "&session("lastName"),"T","S") &")"
						jchemRegConn.execute(strQuery2)
						If alsoUpdateAccMolsWhenEditingRegStructure Then
							accMolsUpdateQuery = "UPDATE accMols SET structure='"&editStructureMolData&"', newStructure='"&editStructureMolData&"' WHERE cd_id="&SQLClean(cdid,"N","S")
							jchemRegConn.execute(accMolsUpdateQuery)
						End If
						If session("companyHasFT") Or session("companyHasFTLiteReg") then														
							a = sendProteinToSearchTool(cdid,true,false)
						End If
					Next
					response.redirect("showReg.asp?regNumber="&request.querystring("regNumber"))
				Else 
					response.write("cannot change this structure because there is a duplicate")
				End If
				Call disconnectJchemReg
			Else
				'response.write(errorText)
			End if
		End if
	End if
End if

If (session("regRegistrar") And Not session("regRegistrarRestricted")) Or session("canEditReg") then
	'	If request.Form("approveSubmit") <> "" Then
	'		call getconnectedJchemReg
	'			a = regChangeStatusBatch("approve",request.Form("cdId"))
	'		call disconnectJchemReg
	'	End If
	'	If request.Form("deleteSubmit") <> "" Then
	'		call getconnectedJchemReg
	'			a = regChangeStatusBatch("delete",request.Form("cdId"))
	'		call disconnectJchemReg
	'	End If

	If request.Form("editSubmit") <> "" Then
		call getconnectedJchemReg
		cdId = request.Form("cd_id")
		userCreated = request.Form("userCreated")
		dateCreated = request.Form("dateCreated")
		source = request.Form("source")
		chemicalName = request.Form("chemicalName")
		molecularFormula = request.Form("molecularFormula")
		molecularWeight = request.Form("molecularWeight")
		exactMass = request.Form("exactMass")
		smiles = request.Form("smiles")
		multiplicity = request.Form("Multiplicity")
		numSalts = request.Form("numSalts")
		existSaltNum = request.Form("existSaltNum")


		'5115 add recordUpdated
		updateQuery = "UPDATE "&regMoleculesTable&" SET "&_
					"chemical_name="&SQLClean(chemicalName,"T","S")&","&_
					"cd_formula="&SQLClean(molecularFormula,"T","S")&","&_
					"cd_smiles="&SQLClean(smiles,"T","S")&","&_
					"cd_molweight="&SQLClean(molecularWeight,"T","S")&","&_
					"exact_mass="&SQLClean(exactMass,"N","S")

		usersTable = getDefaultSingleAppConfigSetting("usersTable")
		Set rec = server.CreateObject("ADODB.RecordSet")
		If isGroup Then
			strQuery = "SELECT * FROM groupCustomFieldFields WHERE showCompound=1 and groupId="&SQLClean(groupId,"N","S")
		else
			strQuery = "SELECT * FROM customFields WHERE showCompound=1"
		End if
		rec.open strQuery,jChemRegConn,3,3
		Do While Not rec.eof
			If LCase(rec("formname")) = "stereochemistry" Then
				If LCase(Trim(request.Form("Stereochemistry"))) = "mixture" Or LCase(Trim(request.Form("Stereochemistry"))) = "chiral" Or LCase(Trim(request.Form("Stereochemistry"))) = "achiral" Or LCase(Trim(request.Form("Stereochemistry"))) = "relative" Or LCase(Trim(request.Form("Stereochemistry"))) = "racemic" Or LCase(Trim(request.Form("Stereochemistry"))) = "undefined" then
					Set d = JSON.parse("{}")
					thisMol = CX_cdIdSearch(jChemRegDB,regMoleculesTable,SQLClean(theCdId,"N","S"),"mol:V3")
					Set thisMolObj = JSON.parse(thisMol)
					If IsObject(thisMolObj) Then
						Set structureData = thisMolObj.Get("structureData")
						If IsObject(structureData) And structureData.Exists("structure") Then
							molData = structureData.Get("structure")
						End If
					End If
					molDataLines = Split(molData,vbcrlf)
					If UBound(molDataLines) = 0 Then
						molDataLines = Split(molData,vbcr)
					End If
					If UBound(molDataLines) = 0 Then
						molDataLines = Split(molData,vblf)
					End If
					If UBound(molDataLines) >= 3 Then
						If Not isInteger(Trim(Left(molDataLines(3),3))) Then
							molData = vbcr & molData
						End If
					End if
					d.Set "structure", molData
					data = JSON.stringify(d)
					Set http = CreateObject("MSXML2.ServerXMLHTTP")
					http.setOption 2, 13056
					http.open "POST",chemAxonCipStereoUrl,True
					http.setRequestHeader "Content-Type","application/json" 
					http.setRequestHeader "Content-Length",Len(data)
					http.SetTimeouts 120000,120000,120000,120000
					http.send data
					http.waitForResponse(60)
					Set r = JSON.parse(http.responseText)
					numStereoCenters = 0
					numUndefinedStereoCenters = 0
					Set tetraHedral = r.Get("tetraHedral")
					For Each item In tetraHedral
						If JSON.stringify(item) <> "" Then
							For Each key In item.keys()
								If key = "chirality" Then
									val = item.Get(key)
									If val = "R/S" Or val = "S/R" Then
										numUndefinedStereoCenters = numUndefinedStereoCenters + 1
									End if
								End if
							next
							numStereoCenters = numStereoCenters + 1
						End if
					Next
					Set doubleBond = r.Get("doubleBond")
					For Each item In doubleBond
						If JSON.stringify(item) <> "" then
							numStereoCenters = numStereoCenters + 1
						End if
					Next
					Set doubleBondNew = r.Get("doubleBond_new")
					For Each item In doubleBondNew
						If JSON.stringify(item) <> "" then
							numStereoCenters = numStereoCenters + 1
						End if
					next
					'response.write(JSON.stringify(tetraHedral)&"<br>")
					'response.write(JSON.stringify(doubleBond)&"<br>")
					'response.write("centers: "&numStereoCenters&"<br>")
					'response.write("undef centers: "&numUndefinedStereoCenters&"<br>")
				End if

				'check that there is more than one molecule if structure is chosen
				'done
				If LCase(Trim(request.Form("Stereochemistry"))) = "mixture" Then
					If Not (ubound(Split(smilesWithSalts,".")) >0 or numUndefinedStereoCenters>0) then
						regError = True
						errorText = errorText & "Mixtures must contain either more than one structure or an undefined stereocenter. <br/>"
					End if
				End If
				
				'done
				If LCase(Trim(request.Form("Stereochemistry"))) = "chiral" Then
					If Not (numUndefinedStereoCenters=0 And numStereoCenters>0) then
						regError = True
						errorText = errorText & "Chiral structures must contain at least one stereocenter and have all stereocenters defined.  <br/>"
					End if
				End If

				If LCase(Trim(request.Form("Stereochemistry"))) = "racemic" Then
					If Not (numStereoCenters>0 And numUndefinedStereoCenters>0)  then
						regError = True
						errorText = errorText & "Racemic structures must contain at least one undefined stereocenter.  <br/>"
					End if
				End If

				If LCase(Trim(request.Form("Stereochemistry"))) = "relative" Then
					If Not (numStereoCenters>1 And numUndefinedStereoCenters=0)  then
						regError = True
						errorText = errorText & "Relative structures must contain more than one stereocenter and have all stereocenters defined.  <br/>"
					End if
				End If

				'done
				If LCase(Trim(request.Form("Stereochemistry"))) = "achiral" Then
					If Not (numStereoCenters=0) then
						regError = True
						errorText = errorText & "Achiral structures may not contain stereocenters.  <br/>"
					End if
				End If

				If LCase(Trim(request.Form("Stereochemistry"))) = "undefined" Then
					If Not (numStereoCenters>0 And numUndefinedStereoCenters>0)  then
						regError = True
						errorText = errorText & "Undefined structures must contain at least one undefined stereocenter.  <br/>"
					End if
				End If
			End if
			If rec("dataType")="float" Or rec("dataType")="int" Or rec("dataType")="text" Or rec("dataType")="multi_float" Or rec("dataType")="multi_int" Or rec("dataType")="multi_text" Or rec("dataType")="file" then
				If rec("enforceUnique") Then
					Set uRec = server.CreateObject("ADODB.Recordset")
					strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE "&rec("actualField")&"="&SQLClean(Trim(request.Form(rec("formName"))),"T","S")&" AND cd_id <>'"&theCdId&"'"
					uRec.open strQuery,jchemRegConn,3,3
					isUnique = true
					If Not uRec.eof Then
						isUnique = False
						regError = True
						errorText = errorText & rec("displayName")&" does not contain a unique value.  <br/>"
					End If

					'If isUnique then
					'	updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(request.Form(rec("formName")),"T","S")
					'End if
				Else
					If Trim(request.Form(rec("formName"))) <> "" then
						If rec("dataType") = "int" Then
							If Not isInteger(Trim(request.Form(rec("formName")))) Then
								regError = True
								errorText = errorText & rec("displayName")&" must be an integer.  <br/>"
								errorFields = errorFields & rec("formName") &","
							End if
						End if

						If rec("dataType") = "float" Then
							If Not isNumber(Trim(request.Form(rec("formName")))) Then
								regError = True
								errorText = errorText & rec("displayName")&" must be an real number.  <br/>"
								errorFields = errorFields & rec("formName") &","
							End if
						End if

						If rec("dataType") = "multi_int" Then
							vals = Split(Trim(request.Form(rec("formName"))),"###")
							For i = 0 To UBound(vals)
								If Not isInteger(vals(i)) Then
									regError = True
									errorText = errorText & rec("displayName")&" item "&(i+1)&" must be an integer.  <br/>"
									errorFields = errorFields & rec("formName") &","
								End If
							next
						End if

						If rec("dataType") = "multi_float" Then
							vals = Split(Trim(request.Form(rec("formName"))),"###")
							For i = 0 To UBound(vals)
								If Not isNumber(vals(i)) Then
									regError = True
									errorText = errorText & rec("displayName")&" item "&(i+1)&" must be an real number.  <br/>"
									errorFields = errorFields & rec("formName") &","
								End if
							next
						End if
					End if
				End If
				If Not regError Then
					If rec("dataType")="text" then
						updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(Server.htmlEncode(encodeit(cstr(request.Form(rec("formName"))))),"T","S")
					else 
						updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(request.Form(rec("formName")),"T","S")
					End if
				End if
			End if
			If rec("dataType")="date" then
				updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(request.Form(rec("formName")),"T","S")
			End if
			If rec("dataType")="long_text" then
				updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(Server.htmlEncode(encodeit(cstr(request.Form(rec("formName"))))),"T","S")
			End if
			If rec("dataType")="drop_down" then
				foundIt = False
				If (request.Form(rec("formName"))="-1" And rec("requireCompound") = 0) And CInt(rec("dropDownId")) <> -99 Then
					foundIt = true
				End If
				theValue = request.Form(rec("formName"))
				If CInt(rec("dropDownId")) <> -99 then
					Set rec2 = server.CreateObject("ADODB.recordSet")
					strQuery = "SELECT * FROM regDropDownOptions WHERE parentId="&SQLClean(rec("dropDownId"),"N","S")&" ORDER BY value"
					rec2.open strQuery,jchemRegConn,3,3
					Do While Not rec2.eof
						If theValue=rec2("value") Then
							foundIt = true	
						End if
						rec2.movenext
					Loop
					rec2.close
					Set rec2 = nothing
				else
						Set rec2 = Server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT * FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id in("&getUsersICanSee()&")"
						rec2.open strQuery,conn,3,3
						Do While Not rec2.eof
							If theValue =rec2("firstName")&" " &rec2("lastName") Then
								foundIt = true
							End if
							rec2.movenext
						loop
				End if
				If Not foundIt Then
					If CInt(rec("dropDownId")) <> -99 then
						regError = True
						errorText = errorText & rec("displayName")&" is not a valid option.  <br/>"
					End if
				Else
					If Not (CInt(rec("dropDownId")) = -99 And request.Form(rec("formName"))="-1") then
						updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(request.Form(rec("formName")),"T","S")
					Else
						repsonse.write(rec("formName"))
					End if
				End if
			End if
		rec.movenext
		Loop
		rec.close
		Set rec = nothing


       i=1
       Do While request.Form("salt_"&i&"_cdId") <> "0" and request.Form("salt_"&i&"_cdId") <> "" and i < existSaltNum
        ' deleting salts
       if   request.Form("salt_"&i&"_deleteBtn") = "delete"    then 
            saltUpdateQuery = "DELETE FROM "&regSaltMappingTable&" WHERE id = "&SQLClean(request.Form("salt_"&i&"_Id"),"N","S")
        else 

            ' updating salts
         saltUpdateQuery = "UPDATE   "&regSaltMappingTable&" SET multiplicity="&SQLClean(Trim(request.Form("salt_"&i&"_multiplicity")),"N","S")&_
                            ",saltId="&SQLClean(request.Form("salt_"&i&"_cdId"),"N","S")&_
                            "WHERE id = "&SQLClean(request.Form("salt_"&i&"_Id"),"N","S")
         end if                           
         jchemRegConn.execute(saltUpdateQuery)
          i=i+1
          Loop

           i= existSaltNum+1
          Do While request.Form("salt_"&i&"_cdId") <> "0" and request.Form("salt_"&i&"_cdId") <> ""			
            ' inserting new salts
					saltQuery = "INSERT INTO "&regSaltMappingTable&"(saltId,molId,multiplicity) values("&_
							SQLClean(request.Form("salt_"&i&"_cdId"),"N","S")&","&_
							SQLClean(cdId ,"N","S")&","&_
							SQLClean(Trim(request.Form("salt_"&i&"_multiplicity")),"N","S")&")"
												
	                jchemRegConn.execute(saltQuery)
	                  i = i+1
          Loop		

		If Not regError Then
			updateQuery = updateQuery & " WHERE cd_id="&SQLClean(theCdId,"N","S")
			jchemRegConn.execute(updateQuery)
			dateFunction = "GETDATE()"
			dateFunction2 = "GETUTCDATE()"
			strQuery = "UPDATE "&regMoleculesTable&" SET "&_
					"dateLastModified="&dateFunction &","&_
					"dateLastModifiedUTC="&dateFunction2 &","&_
					"userLastModified="&SQLClean(session("firstName")&" "&session("lastName"),"T","S") & "," &_
					"userLastModifiedId="&SQLClean(session("userId"),"N","S") &_
					" WHERE cd_id="&SQLClean(theCdId,"N","S")
			jchemRegConn.execute(strQuery)
			strQuery = "INSERT INTO modLog(cd_id,userId,dateModified,dateModifiedUTC,userName) values("&_
					SQLClean(theCdId,"N","S")&","&_
					SQLClean(session("userId"),"N","S")&","&_
					dateFunction & "," &_
					dateFunction2 & "," &_
					SQLClean(session("firstName")&" "&session("lastName"),"T","S") &")"
			jchemRegConn.execute(strQuery)
			If session("companyHasFT") Or session("companyHasFTLiteReg") then
				Set http = CreateObject("MSXML2.ServerXMLHTTP")
				http.setOption 2, 13056
				a = sendProteinToSearchTool(theCdId,true,false)
			End if
		End if
	End If
	
End if
%>
	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
<style type="text/css">@import url(<%=mainAppPath%>/js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.browser.dep.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.printElement.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>

<!-- #include file="_inclds/regTopRightFunctions.asp"-->
<div id="regWindow" class="registrationPage sideBySideFields compoundPage<%If Not hasStructure then%> noStructureCompoundPage<%End if%>">

<%
Set rec = server.CreateObject("ADODB.RecordSet")
If isGroup Then
	strQuery = "SELECT * FROM groupCustomFieldFields WHERE showCompound=1 and groupId="&SQLClean(groupId,"N","S")
else
	strQuery = "SELECT * FROM customFields WHERE showCompound=1"
End If
If hasRegSorting Then
	strQuery = strQuery & " ORDER BY sortOrder ASC, id ASC"
Else
	strQuery = strQuery & " ORDER BY id ASC"
End if

fieldsStr = "[""cd_id"",""cd_timestamp"",""userLastModified"",""dateLastModified"",""cd_formula"",""cd_smiles"",""cd_molweight"",""exact_mass"",""chemaxon_chemical_name"",""source"",""name"",""user_name"",""experiment_id"",""revision_number"",""experiment_name"",""is_permanent"",""status_id"",""type_id"",""dateCreatedUTC"",""dateLastModifiedUTC""]"
Set fieldsArr = JSON.parse(fieldsStr)

rec.open strQuery,jchemRegConn,3,3
Do While Not rec.eof
	fieldsArr.push CStr(rec("actualField"))
	rec.movenext
Loop

recNum = 0
queryFields = ""
Do While recNum < fieldsArr.length
	If queryFields <> "" Then
		queryFields = queryFields & ","
	End If
	
	queryFields = queryFields & fieldsArr.Get(recNum)
	recNum = recNum + 1
Loop

Set regRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT "&queryFields&" FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(theCdId,"N","S")
regRec.open strQuery,jchemRegConn,3,3

foundData = False
Set regJson = JSON.parse("{}")
If Not regRec.eof Then
	recNum = 0
	foundData = True
	Do While recNum < fieldsArr.length
		theVal = regRec(fieldsArr.Get(recNum))
		If IsNull(theVal) Then
			theVal = ""
		End If
		regJson.Set fieldsArr.Get(recNum), theVal
		recNum = recNum + 1
	Loop
End If

regRec.close
Set regRec = Nothing

If Not foundData Then
	response.write("Reg ID not found")
	response.end()
End If

parentCdid = regJson.Get(fieldsArr.Get(0))
dateCreated = regJson.Get(fieldsArr.Get(1))
userLastModified = regJson.Get(fieldsArr.Get(2))
dateLastModified = regJson.Get(fieldsArr.Get(3))
If hasStructure then
	molecularFormula = regJson.Get(fieldsArr.Get(4))
	If regJson.Get(fieldsArr.Get(5)) <> "" then
		smiles = CX_standardize(aspJsonStringify(Split(regJson.Get(fieldsArr.Get(5))," ")(0)),"smiles",defaultStandardizerConfig,"smiles")
	End If
	If regJson.Get(fieldsArr.Get(6)) <> "" then
		molWeight = Round(regJson.Get(fieldsArr.Get(6)),2)
	End If
	If regJson.Get(fieldsArr.Get(7)) <> "" then
		exactMass = Round(regJson.Get(fieldsArr.Get(7)),2)
	End if
	chemicalName = regJson.Get(fieldsArr.Get(8))
End if
source = regJson.Get(fieldsArr.Get(9))
name = regJson.Get(fieldsArr.Get(10))
userName = regJson.Get(fieldsArr.Get(11))
experimentId = regJson.Get(fieldsArr.Get(12))
revisionNumber = regJson.Get(fieldsArr.Get(13))
experimentName = regJson.Get(fieldsArr.Get(14))
perm = regJson.Get(fieldsArr.Get(15))
statusId = regJson.Get(fieldsArr.Get(16))
experimentType = regJson.Get(fieldsArr.Get(17))
dateCreatedUTC = regJson.Get(fieldsArr.Get(18))
dateLastModifiedUTC = regJson.Get(fieldsArr.Get(19))
lastIndex = 19
%>
<div class="showRegRecordContainer">
<%If hasStructure then%>
<%
If canEditStructureReg Then
	%>
	<%If errorStr <> "" then%>
		<script type="text/javascript">
			alert("<%=errorStr%>")
		</script>
	<%End if%>
	<br/>
	<br/>
	<script type="text/javascript">
		hasCopiedSelect = false;
		function copySelect(){
			if(!hasCopiedSelect){
				el = false;
				els = document.getElementById("regMetaData");
				els2 = els.getElementsByTagName("select");
				for(var i=0;i<els2.length;i++){
					if(els2[i].id=="Stereochemistry"){
						el = els2[i];
					}
				}
				if (el) {
					if (document.getElementById("stereoHolder")) {
						newNode = el.cloneNode(true);
						newNode.setAttribute("id", "editStructureStereo");
						newNode.setAttribute("name", "editStructureStereo");
						newNode.style.display = "block";
						newNode.options = el.options;
						document.getElementById("stereoHolder").appendChild(newNode);
					}
				}
			}
			hasCopiedSelect = true;
		}
    </script>
	<a href="javascript:void(0)" onclick="document.getElementById('editStructureDiv').style.display='block';copySelect();">Edit Structure</a>
		<div id="editStructureDiv" style="display:none;clear:both;">
		<h3>Edit Structure</h3>
		<form id="showRegForm" action="showReg.asp?regNumber=<%=request.querystring("regNumber")%>" method="POST" >
			<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
			<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
			<script type="text/javascript" src="<%=mainAppPath%>/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
			<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
			<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
			<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
			<script type="text/javascript">
				hasMarvin = <%=LCase(CStr(session("useMarvin"))) %>

				<%If session("useChemDrawForLiveEdit") Then%>
					useChemDrawForLiveEdit = true;
				<%End If%>
            </script>
			<div id="showRegAspChemBox">
			</div>
			<input type="hidden" name="editStructureCdId" id="editStructureCdId" value="<%=parentCdid%>">
			<input type="hidden" name="editStructureMolData" id="editStructureMolData" value="">
			<input type="hidden" name="editStructureStereo" id="editStructureStereo" value="">
			<input type="hidden" name="editStructureSubmitted" id="editStructureSubmitted" value="submitted">
			<br/>
			<input type="button" id="showRegFormSubmit" value="EDIT STRUCTURE">
		</form>
		<script>
			$('#showRegFormSubmit').click(function (evt) {
				getChemistryEditorChemicalStructure('editStructureCDX', false, 'mol:V3').then(function(data){
					document.getElementById('editStructureMolData').value=data;
					if (confirm('Are you sure that you wish to replace the structure data for this structure and all its batches?')){
						$('#showRegForm').submit();
					}
				})
			});
		</script>
		</div>
	<%
End If
%>
<%End if%>

<%
molWeightWithSalts = molWeight
smilesWithSalts = smiles
Set tRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE just_reg="&SQLClean(regNumber,"T","S")& " AND just_batch='"&compoundBatchNumber&"'"
tRec.open strQuery,jchemRegConn,3,3
If Not tRec.eof then
	batchCdid = tRec("cd_id")
Else
	batchCdid = -234234
End If
tRec.close
Set tRec = nothing
Set saltRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT cd_molweight,multiplicity,cd_smiles FROM "&regSaltsView&" WHERE molId="&SQLClean(theCdId,"N","S")
saltRec.open strQuery,jchemRegConn,3,3
Do While Not saltRec.eof
	molWeightWithSalts = molWeightWithSalts + (saltRec("CD_MOLWEIGHT")*saltRec("MULTIPLICITY"))
	For i = 1 To saltRec("MULTIPLICITY")
		smilesWithSalts = smilesWithSalts & "." &Split(saltRec("cd_smiles")," ")(0)
	next
	saltRec.movenext
Loop
saltRec.close
Set saltRec = nothing
molWeightWithSalts = Round(molWeightWithSalts,2)
%>

<%If regHasTemplate then%>
<div id="regTemplateHolder"></div>
<%End if%>

<div class="regMetaData" style="<%If regHasTemplate then%>display:block;<%End if%>position:relative;width:700px;" id="regMetaData">
<h1>Compound Number: <span id="regId_view" class="regFieldData"><%=theRegId%></span></h1>
<%If allowBatches then%>
<%addBatchRegNumber=regNumber%>
<!-- #include file="_inclds/regAddBatchButton.asp"-->
<%End if%>
<%If hasStructure then%>
<div id="chemicalImage" formname="structureImage" class="reg-chem-image" style="position:absolute;width:<%=imageWidth%>px;height:<%=imageHeight%>px;">
<%response.write(CX_getSvgByCdId(jChemRegDB, regMoleculesTable, regJson.Get("cd_id"), imageWidth, imageHeight))%>
</div>
<%End if%>
<form method="POST" action="showReg.asp?regNumber=<%=request.querystring("regNumber")%>" id="regForm" onsubmit="saveMultis();">

<div id="systemProperties" class="systemProperties" id="systemProperties_view" <%If hasStructure then%><%If imageWidth>300 then%>style="margin:<%=imageHeight + 40%>px 0 40px 0px;"<%else%>style="margin:0 0 200px 350px;"<%End if%><%End if%>>
	<h2>Properties</h2>
	<div class="item">
		<span class="regFieldName">User Created:</span>
		<span class="regFieldData" id="userCreated_view"><%=userName%></span>
		<input type="hidden" value="<%=parentCdid%>" name="cd_id" id="cd_id">
	</div>
	<div class="item">
		<span class="regFieldName">Date Created:</span>
		<span class="regFieldData" id="dateCreated_view"><%If session("useGMT") then%><%=dateCreatedUTC%><%else%><%=dateCreated%><%End if%></span>
	</div>
	<div class="item">
		<span class="regFieldName">User Modified:</span>
		<span class="regFieldData" id="userModified_view"><%=userLastModified%></span>
	</div>
	<div class="item">
		<span class="regFieldName">Date Modified:</span>
		<span class="regFieldData" id="dateModified_view"><%If session("useGMT") then%><%=dateLastModifiedUTC%><%else%><%=dateLastModified%><%End if%></span>
	</div>
	<%
	If projectFieldInReg And projectJsonObj.Length > 0 then
	%>
	<div class="item">
		<span class="regFieldName">Project List:</span>
		<table style="margin-left:35px;">
		<%
			For i = 0 To projectJsonObj.Length - 1
				Set theObj = projectJsonObj.Get(i)
				response.write("<tr>")
				response.write("<td style=""width:225px;"">"&theObj.Get("name")&"</td>")
				If (session("regRegistrar") And Not session("regRegistrarRestricted")) Or session("canEditReg") Then
					response.write("<td><button onclick=""removeProjectLink("&theCdId&","&theObj.Get("id")&");"">Delete</button></td>")
				Else
					response.write("<td></td>")
				End If
				response.write("</tr>")
			Next
		%>
		</table>
	</div>
	<%End if%>
</div>
<%If useSalts then%>
<%
Set saltRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM "&regSaltsView&" WHERE molId="&SQLClean(theCdId,"N","S")
saltRec.open strQuery,jchemRegConn,3,3
If saltRec.eof Then
	wasEmpty = True
End if
%>
<div id="saltsContainer" class="saltsContainer" <%If hasStructure then%>style="position:relative;left:350px;top:0px !important;margin-left:0;"<%End if%>>
<h2>Salts</h2>
<div id="addSaltsBtn" style="display: none">
<a href="javascript:void(0);" onClick="addNewSalts()" class="newSalt" style="background-color: #1eb242;color:white; ">ADD SALT+</a>
</div>
<%
numSalts = 0
Do While Not saltRec.eof
	numSalts = numSalts +1
	
%>
		<div id="salt_<% =numSalts %>_container"  class = "saltItemContainer">
		<% 'this id value should not be displayed, it is for sql updating %>
		<input type="text" name="salt_<% = numSalts%>_Id"  id="salt_<% = numSalts %>_Id"  value ="<%=saltRec("id")%>" style = "display: none">

        <div id="salt_<% =numSalts %>_display" >
        <div class="inline">
          <span class="regFieldName">Name:</span>
		  <span class="regFieldData" style="width: 100px;"><%=saltRec("name")%></span>
		</div>
		<div class="inline" >
			<span class="regFieldName">Multiplicity:</span>
			<span class="regFieldData" style="width: 100px;"><%=saltRec("multiplicity")%></span>
        </div>
        </div>

		<div id = "salt_<% =numSalts %>_edit" style="display:none";>
		<label for="salt_<% =numSalts %>_cdId" style="font-weight: bold; padding: 2px; margin: 2px;">Salt</label>
		<select id="salt_<% =numSalts %>_cdId" name="salt_<% =numSalts %>_cdId" <%=selectAutoComplete%>>
		<%
		call getconnectedJchemReg
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cd_id,name FROM "&regSaltsTable& " WHERE 1=1 ORDER BY upper(name) ASC"
		'rec.open strQuery,jchemRegConn,0,1
		Set rec = jChemRegConn.execute(strQuery)
		Do While Not rec.eof
			'show the selected value as the default value
		%>
			<option value="<%=rec("cd_id")%>"   
			  <% if   rec("cd_id") = saltRec("saltId")   then%>
                  selected="selected"
				<% end if %>
			  ><%=rec("name")%>	
			</option>
		<%
			rec.movenext
		Loop
		rec.close
		Set rec = nothing
		Call disconnectJchemReg
		%>
		</select>	
		<label for="salt_<% =numSalts %>_multiplicity">Multiplicity</label>
		<input type="text" name="salt_<% =numSalts %>_multiplicity" id="salt_<% =numSalts %>_multiplicity" class="multiplicVal" value= "<%=saltRec("multiplicity")%>" style="width: 80px">
		<input  type="checkbox" name="salt_<% =numSalts %>_deleteBtn" id="salt_<% =numSalts %>_deleteBtn" value = "delete">Delete<br>
		</div>
		</div>
<% 
	saltRec.movenext
Loop
saltRec.close
Set saltRec = nothing 
existSaltNum = numSalts 
 'this value should not be displayed, it is the number of salts before editing %>
<input type="text" name="existSaltNum" value= <% =numSalts %> style="display:none">
<%If wasEmpty then%>
	<div class="item" style="width:430px;">
		<div class="inline">
			<span class="regFieldData">No Salts</span>
		</div>
	</div>
<%End if%>
</div>
<%End if%>

<%If regError then%>
	<div style="color:red;padding-left:5px;"><%=errorText%></div>
<%End if%>
<div class="item">
	<span class="regFieldName">Registration Source:</span>
	<span class="regFieldData" id="regSource_view"><%=source%></span>
</div>
<%If hasStructure then%>
<%If Not polymer then%>
	<%
	hideChemicalNameFieldInReg = checkBoolSettingForCompany("hideChemicalNameFieldInReg", session("companyId"))
	if not hideChemicalNameFieldInReg then
	%>
		<div class="item">
			<span class="regFieldName">Chemical Name:</span>
			<span class="regFieldData" id="chemicalName_view"><%=chemicalName%></span>
			<input class="regFieldDataEdit" name="chemicalName" id="chemicalName" type="text" value="<%=chemicalName%>" style="display:none;">
		</div>
	<%End if%>
<%End if%>
<div class="item">
	<span class="regFieldName">Formula:</span>
	<span class="regFieldData" id="molecularFormula_view"><%=molecularFormula%></span>
	<input class="regFieldDataEdit" name="molecularFormula" id="molecularFormula" type="text" value="<%=molecularFormula%>" style="display:none;">
</div>

<%If Not polymer then%>
<div class="item">
	<span class="regFieldName">SMILES:</span>
	<span class="regFieldData" id="smiles_view"><%=smiles%></span>
	<input class="regFieldDataEdit" name="smiles" id="smiles" type="text" value="<%=smiles%>" style="display:none;">
</div>
<div class="item">
	<span class="regFieldName">SMILES (w/salts):</span>
	<span class="regFieldData" id="smilesWithSalts_view"><%=smilesWithSalts%></span>
	<input class="regFieldDataEdit" name="smilesWithSalts" id="smilesWithSalts" type="text" value="<%=smilesWithSalts%>" style="display:none;">
</div>
<div class="item">
	<span class="regFieldName">Molecular Weight:</span>
	<span class="regFieldData" id="molecularWeight_view"><%=molWeight%></span>
	<input class="regFieldDataEdit" name="molecularWeight" id="molecularWeight" type="text" value="<%=molWeight%>" style="display:none;">
</div>
<div class="item">
	<span class="regFieldName">Molecular Weight (w/salts):</span>
	<span class="regFieldData" id="molecularWeightWithSalts_view"><%=molWeightWithSalts%></span>
	<input class="regFieldDataEdit" name="molecularWeightWithSalts" id="molecularWeightWithSalts" type="text" value="<%=molWeightWithSalts%>" style="display:none;">
</div>
<div class="item">
	<span class="regFieldName">Exact Mass:</span>
	<span class="regFieldData" id="exactMass_view"><%=exactMass%></span>
	<input class="regFieldDataEdit" name="exactMass" id="exactMass" type="text" value="<%=exactMass%>" style="display:none;">
</div>
<%End if%>
<%End if%>

<%
Set rec = server.CreateObject("ADODB.RecordSet")
If isGroup Then
	strQuery = "SELECT * FROM groupCustomFieldFields WHERE showCompound=1 and groupId="&SQLClean(groupId,"N","S")
else
	strQuery = "SELECT * FROM customFields WHERE showCompound=1"
End If
If hasRegSorting Then
	strQuery = strQuery & " ORDER BY sortOrder ASC, id ASC"
Else
	strQuery = strQuery & " ORDER BY id ASC"
End if
 

rec.open strQuery,jChemRegConn,3,3
Do While Not rec.eof
	lastIndex = lastIndex + 1		
	theValue = regJson.Get(fieldsArr.Get(lastIndex))
	'data are read from xml, so cannot be unicoded directly
     theValue = Replace(theValue,"&amp;#","&#")
	originalValue = theValue
	theValue = Replace(theValue,Chr(10),"<br/>")
	theValue = Replace(theValue,Chr(13),"<br/>")
    hasLongTextIdFieldsReg = checkBoolSettingForCompany("canUseLongTextFieldsAsIdForReg", session("companyId"))
	If hasLongTextIdFieldsReg And rec("isIdentity") = 1 And rec("dataType") = "long_text" Then
		theValue = Replace(theValue,",","<br/>")
	End If
	theValue = Replace(theValue,"###","<br/>")
	If rec("formName") = "Stereochemistry" then
	%>
	<script type="text/javascript">
		if($("#editStructureStereo").length)
			$("#editStructureStereo").value = "<%=theValue%>";
	</script>
	<%
	End if
%>	
	<div class="item">
		<span class="regFieldName"><%=rec("displayName")%></span>
		<%If rec("dataType")="drop_down" And theValue = "-1" Then%>
			<span class="regFieldData"></span>	
		<%else%>
			<%If rec("isLink") = 1 then%>
				<%
				scriptName = "showReg.asp"
				If InStr(theValue, regBatchNumberDelimiter) <> 0 Then
					batchValueParts = Split(theValue,regBatchNumberDelimiter)											
					hightestIndex = UBound(batchValueParts)

					' if the users created a groupPrefix for a group containing another delimiter,
					' it would disrupt how we determine which link to show...so, we compensate here
					regNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regIdDelimiter", session("companyId"))
					If ((Len(groupPrefix) > 0) And (InStr(groupPrefix, regBatchNumberDelimiter) Or InStr(groupPrefix, regNumberDelimiter))) Then
						numberOfBatchNumberDelimiters = len(groupPrefix) - len(replace(groupPrefix, regBatchNumberDelimiter, ""))
						numberOfRegNumberDelimiters = 0

						If (regBatchNumberDelimiter <> regNumberDelimiter) Then
							numberOfRegNumberDelimiters = len(groupPrefix) - len(replace(groupPrefix, regNumberDelimiter, ""))
						End If

						hightestIndex = hightestIndex - (numberOfBatchNumberDelimiters + numberOfRegNumberDelimiters)
					End If

					If (regBatchNumberDelimiter <> regNumberDelimiter And hightestIndex = 1) Or (regBatchNumberDelimiter = regNumberDelimiter And hightestIndex = 2) Then
						scriptName = "showBatch.asp"
					End If
				End If
				%>
				<span class="regFieldData"><a href="<%=scriptName%>?regNumber=<%=theValue%>"><%=theValue%></a></span>
			<%else%>
				<%If rec("dataType") = "long_text" then%>
					<div class="regFieldData" style="padding-left:70px;" id="<%=rec("formName")%>_view"><%=theValue%></div>
				<%else%>
					<%If rec("dataType") <> "file" then%>
						<span class="regFieldData" id="<%=rec("formName")%>_view"><%=theValue%></span>
					<%End if%>
				<%End if%>
			<%End if%>
		<%End if%>
		<%If rec("dataType")="float" Or rec("dataType")="int" Or rec("dataType")="text" then%>		
			<input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="text" value="<%=theValue%>" style="display:none;">
		<%End if%>
		<%If rec("dataType")="multi_float" Or rec("dataType")="multi_int" Or rec("dataType")="multi_text" then%>		
			<div class="multiHolder regFieldDataEdit" id="<%=rec("formName")%>_holder" style="display:none;">
				<input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="hidden" value="<%=originalValue%>" style="display:none;">
			</div>
		<%End if%>
		<%If rec("dataType")="date" then%>		
			<input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="text" value="<%=theValue%>" style="display:none;">
			<script type="text/javascript">
			  Calendar.setup(
				{
				  inputField  : "<%=rec("formName")%>",         // ID of the input field
				  ifFormat    : "%m/%d/%Y %l:%M:%S %p",    // the date format
				  showsTime   : true,
				  timeFormat  : "12",
				  electric    : false
				}
			  );
			</script>
		<%End if%>
		<%If rec("dataType")="file" then%>
			<input type="hidden" name="<%=rec("formName")%>" id="<%=rec("formName")%>" value="<%=theValue%>">
			<span id="<%=rec("formName")%>_fn">
			<%
			id = theValue
			If id<>"" Then
				Set rec3 = server.CreateObject("ADODB.RecordSet") 
				strQuery = "SELECT * FROM fileAttachments WHERE id="&SQLClean(id,"N","S")
				rec3.open strQuery,jchemRegConn,3,3
				If Not rec3.eof Then
					filename = rec3("filename")
					%>
					<%=filename%>
					<%
				End if
				rec3.close
				Set rec3 = nothing
			End if
			%>
			</span>
			<div class="downloadButtonHolder"><a href="<%If id="" then%>javascript:void(0);<%else%>getSourceFile.asp?id=<%=id%><%End if%>" id="<%=rec("formName")%>_download_button" class="littleButton" style="float:none;width:80px;display:inline;margin-left:10px;<%If id="" then%>display:none;<%End if%>">Download</a></div>

			<div id="<%=rec("formName")%>_img_holder" style="margin-left:15px;<%If id="" Or not canDisplayInBrowser(filename) then%>display:none;<%End if%>">
			<a href="javascript:void(0);" onclick="document.getElementById('<%=rec("formName")%>_img').style.display='block';document.getElementById('<%=rec("formName")%>_img_show').style.display='none';document.getElementById('<%=rec("formName")%>_img_hide').style.display='inline';" <%If id="" then%>style="display:none;"<%End if%> id="<%=rec("formName")%>_img_show">Show Image</a>
			<a href="javascript:void(0);" onclick="document.getElementById('<%=rec("formName")%>_img').style.display='none';document.getElementById('<%=rec("formName")%>_img_hide').style.display='none';document.getElementById('<%=rec("formName")%>_img_show').style.display='inline';" id="<%=rec("formName")%>_img_hide" <%If id<>"" then%>style="display:none;"<%End if%>>Hide Image</a>
			<img src="<%If id="" then%>javascript:false<%else%>getImage.asp?id=<%=id%><%End if%>" style="<%If inframe then%>width:200px;<%else%>width:800px;<%End if%>display:none;" id="<%=rec("formName")%>_img"/>
			</div>
			<div style="margin-left:15px">
			<a href="javascript:void(0);" onclick="if (confirm('Are you sure you want to remove the File?')) {document.getElementById('<%=rec("formName")%>').value = '';document.getElementById('<%=rec("formName")%>_img_holder').style.display='none';document.getElementById('<%=rec("formName")%>_fn').style.display='none';document.getElementById('<%=rec("formName")%>_download_button').style.display='none';}" class="regFieldDataEdit" id="<%=rec("formName")%>_remove_img" <%If not isNull(theValue) then%>style="display:none;"<%End if%>>Remove File</a>
			</div>
			<iframe id="<%=rec("formName")%>_frame" name="<%=rec("formName")%>_frame" style="border:none;height:35px;width:300px;margin-left:15px;display:none;" src="upload-file_frame.asp?formName=<%=rec("formName")%>" scrolling="no" class="regFieldDataEdit"></iframe>
		<%End if%>
		<%If rec("dataType")="long_text" then%>
			<textarea class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" style="display:none;"><%=Replace(theValue,"<br/>",vbcrlf)%></textarea>
		<%End if%>
		<%If rec("dataType")="drop_down" then%>
			<%If CInt(rec("dropDownId")) <> -99 then%>
				<select class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" style="display:none;">
				<option value="-1">--SELECT--</option>
				<%
				Set rec2 = server.CreateObject("ADODB.recordSet")
				strQuery = "SELECT * FROM regDropDownOptions WHERE parentId="&SQLClean(rec("dropDownId"),"N","S")&" ORDER BY value"
				rec2.open strQuery,jchemRegConn,3,3
				Do While Not rec2.eof
					%>
					<option value="<%=rec2("value")%>" <%If Trim(theValue)=Trim(rec2("value")) then%>SELECTED<%End if%>><%=rec2("value")%></option>
					<%
					rec2.movenext
				Loop
				rec2.close
				Set rec2 = nothing
				%>
				</select>
			<%else%>
				<%
					Set rec2 = Server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id in("&getUsersICanSee()&")"
					rec2.open strQuery,conn,3,3
					foundScientist = False
					Do While Not rec2.eof
						If theValue =rec2("firstName")&" " &rec2("lastName")  Or theValue =rec2("lastName")&", " &rec2("firstName") Then
							foundScientist = True
						End if
						rec2.movenext
					Loop
					rec2.close
					If Not foundScientist And theValue <> "" Then
						%><input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="text" value="<%=theValue%>" style="display:none;"><%
					Else
						%>
						<select class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" style="display:none;">
						<option value="-1">--SELECT--</option>
						<%
						strQuery = "SELECT * FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id in("&getUsersICanSee()&")"
						rec2.open strQuery,conn,3,3
						Do While Not rec2.eof
							%>
								<option value="<%=rec2("firstName")&" "&rec2("lastName")%>" <%If theValue =rec2("firstName")&" " &rec2("lastName")  Or theValue =rec2("lastName")&", " &rec2("firstName") then%> SELECTED<%End if%>><%=rec2("firstName")%>&nbsp;<%=rec2("lastName")%></option>
							<%
							rec2.movenext
						loop
						%>
						</select>
						<%
					End if
				%>
			<%End if%>
		<%End if%>
	</div>
<%
	rec.movenext
Loop
rec.close
Set rec = nothing
%>

<%If (session("regRegistrar") And Not session("regRegistrarRestricted")) Or session("canEditReg") then%>
<input type="button" value="EDIT" onclick="toggleEdit()" id="editToggleButton">
<input type="submit" value="SAVE" name="editSubmit" id="editSubmit" style="display:none;">
<%End if%>
</form>
<%If canDeleteStructureReg then%>
	<form action="showReg.asp?regNumber=<%=request.querystring("regNumber")%>" method="POST" onsubmit="return confirm('Are you sure that you wish to delete this compound?');" style="margin:0px 0px 0px 0px;left:50px;bottom:0px;" id="regDeleteButton">
		<input type="hidden" name="deleteStructureCdId" id="deleteStructureCdId" value="<%=theCdid%>">
		<input type="hidden" name="deleteStructureSubmitted" id="deleteStructureSubmitted" value="submitted2">
		<input type="submit" value="DELETE">
	</form>
<%End if%>
</div>



<%If session("hasAccordInt") then%>
<div class="saltsContainer">
<%
If session("regRoleNumber") <= 15 then
	Set nbRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT notebookId FROM accMols WHERE cd_id="&SQLClean(parentCdId,"N","S")
	nbRec.open strQuery,jchemRegConn,3,3
	%>
		<%If Not nbRec.eof then%>
			<h2>Allowed Notebooks</h2>
		<%End if%>
	<%
    Set nbNameRec = Server.CreateObject("ADODB.RecordSet")
	Do While Not nbRec.eof
        nbNameQuery = "SELECT name FROM notebooks WHERE id="&nbRec("notebookId")
        nbNameRec.open nbNameQuery, conn,3,3
	%>
		<div class="item">
			<div class="inline">
				<span class="regFieldName">Notebook Name:</span>
				<span class="regFieldData"><%=nbNameRec("name")%></span>
			</div>
		</div>
	<%
        nbNameRec.close
		nbRec.movenext
	Loop
	nbRec.close
    Set nbRec = Nothing
	Set nbNameRec = nothing
End if
%>
</div>
<%End if%>
<%
'412015
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DISTINCT experimentId, experimentType, [name], details FROM experimentRegLinksView WHERE displayRegNumber="&SQLClean(wholeRegNumber,"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
rec.open strQuery,conn,0,-1
%>

<%If (Not IsNull(experimentId) And experimentId <> "") Or Not rec.eof then%>
  <table cellpadding="0" cellspacing="0" style="width:100%;">
	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
			<div class="tabs"><h2>ELN Links</h2></div>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<table class="caseTable" cellpadding="0" cellspacing="0" style="width:100%;">
				<tr>
					<td class="caseInnerTitle" valign="top" id="inventoryLinksTD">
					<%If (Not IsNull(experimentId) And experimentId <> "") then%>
						<%
						prefix = GetPrefix(experimentType)
						expPage = GetExperimentPage(prefix)
						%>
						<a href="<%=mainAppPath%>/<%=expPage%>?id=<%=experimentId%>" target="new"><%=experimentName%></a>
						<%
						Set rec2 = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT * FROM notebookIndexView WHERE details is not null and details <>'' and typeId="&SQLClean(experimentType,"N","S") & " and experimentId="&SQLClean(experimentId,"N","S")
						rec2.open strQuery,conn,0,-1
						If Not rec2.eof Then
							response.write("<p  class='linkDescription'>"&rec2("details")&"</p>")
						End if
						rec2.close
						Set rec2=nothing
						%>
						<%If Not rec.eof then%>
							<br/>
						<%End if%>
					<%End if%>
					<%If Not rec.eof then%>
						<%Do While Not rec.eof
							If Not (CStr(experimentId) = CStr(rec("experimentId")) And CStr(experimentType) = CStr(rec("experimentType"))) then
								prefix = GetPrefix(CStr(rec("experimentType")))
								expPage = GetExperimentPage(prefix)
							%>
								<a href="<%=mainAppPath%>/<%=expPage%>?id=<%=rec("experimentId")%>" target="new"><%=rec("name")%></a><br/>
								<%If Not IsNull(rec("details")) then%>
									<p class="linkDescription"><%=rec("details")%></p>
								<%End if%>
							<%End if%>
							<%rec.movenext%>	
						<%loop%>
					<%End if%>

					</td>
				</tr>
			</table>
		</td>
	</tr>
	</table>
<%End if%>
<%''/412015%>
<%fieldsStr = ""%>


<script type="text/javascript">
function loadInvLinks(){
	$.get("getInventoryLinks.asp?cdId=<%=theCdId%>&random="+Math.random())
		.done(function(data){
			if(data!=""){
				document.getElementById("inventoryLinksDiv").style.display = "block";
				document.getElementById("inventoryLinksTable").innerHTML = data;
			}
		})
}

function removeProjectLink(recCdId, recProjectId)
{
	$.ajax({
		url: "<%=mainAppPath%>/registration/services/removeProject.asp",
		async: true,
		type: "POST",
		dataType: "json",
		data: {
			"projectId":recProjectId,
			"cdId":recCdId
		},
		success: function(data)
		{
			console.log("Project removal succeeded.")
			location.reload();
		},
		error: function(error, textStatus, errorThrown)
		{
			swal("There was an error removing the project from this record.");
		},
		always: function()
		{
		}
	});
}

$(document).ready(function() {
	loadInvLinks();

	// Copy the current structure to the editor
	if (document.getElementById("showRegAspChemBox")) {
		molData = "";
        if (document.getElementById("regMolData")) {
            molData = document.getElementById("regMolData").value;
		}

		if (molData == "") {
            getChemistryEditorMarkup("editStructureCDX", "", "", 300, 300, false).then(function (theHtml) {
                $("#showRegAspChemBox").html(theHtml);
            });
		}
		else {
			// 5301: Convert to CDXML format to avoid the cdxml confirmation popup on saving the editting structure.
			convertToCDXML(molData).then(function (cdxml) {
				var data = cdxml;
                if (cdxml == undefined || cdxml == "") {
					// fall back to molData if the conversion failed.
					data = molData;
                }
                getChemistryEditorMarkup("editStructureCDX", "", data, 300, 300, false).then(function (theHtml) {
					$("#showRegAspChemBox").html(theHtml);
				});
			});
		}
	}
});

<% If IsNull(numSalts)  Or  IsEmpty(numSalts) Then 
       numSalts = 0
    End If %>

numSalts = <%= numSalts %>;

existSaltNum = numSalts;




function addNewSalts()
{
        
        if (numSalts != 0)
        {
		var newHTML = getFile("getNewSalt.asp?saltNumber="+(numSalts+1)+"&random="+Math.random())
		newDiv = document.createElement("div")
		newDiv.setAttribute('id',"salt_"+(numSalts+1)+"_container")
		newDiv.innerHTML = newHTML;
		document.getElementById("salt_"+numSalts+"_container").parentNode.insertBefore(newDiv,document.getElementById("salt_"+numSalts+"_container").nextSibling);
        document.getElementById("salt_"+(numSalts+1)+"_container").className += ' saltItemContainer';
		numSalts++;
	    }
	    else
	    {
	    numSalts = 1;
	    var newHTML = getFile("getNewSalt.asp?saltNumber="+numSalts+"&random="+Math.random())
		newDiv = document.createElement("div")
		newDiv.setAttribute('id',"salt_"+numSalts+"_container")
		newDiv.innerHTML = newHTML;
		document.getElementById("saltsContainer").append(newDiv);
        document.getElementById("salt_"+numSalts+"_container").className += ' saltItemContainer';
	    }
}

function toggleEdit()
{

		 
		spans = document.getElementsByClassName("regFieldData")
		boxes = document.getElementsByClassName("regFieldDataEdit")
		var spanExcludes = ["regId_view", "userCreated_view", "dateCreated_view", "userModified_view", "dateModified_view"];

		if (boxes[0].style.display == "none")
		{
			// show edit dashboard
		    for(i =1;i<existSaltNum+1;i++)
           {
		     	document.getElementById("salt_"+i+"_display").style.display ="none"
		     	document.getElementById("salt_"+i+"_edit").style.display ="inline"
		     	
		    }
			for (i=0;i<spans.length ;i++ )
			{
				if (!spanExcludes.includes(spans[i].id)){
					spans[i].style.display = "none"
				}
			}
			for (i=0;i<boxes.length ;i++ )
			{
				if(boxes[i].tagName=="SPAN"){
					boxes[i].style.display = "inline-block"
				}else{
					boxes[i].style.display = "inline"
				}
			}
		    if (document.getElementById("addSaltsBtn") != null){
		    	document.getElementById("addSaltsBtn").style.display = "inline"
		    }
            
			document.getElementById("editSubmit").style.display = "inline"
			document.getElementById("editToggleButton").value = "CANCEL"
		}

		else
		{

			// delete the extra divs of salt when people click cancel
             for(i = existSaltNum+1;i<numSalts+1;i++)
             {
             	document.getElementById("salt_"+i+"_container").remove();

             }
              // show display
			 for(i =1;i<existSaltNum+1;i++)
            {
		     	document.getElementById("salt_"+i+"_display").style.display ="inline"
		     	document.getElementById("salt_"+i+"_edit").style.display ="none"
		     	
		    }
			for (i=0;i<spans.length ;i++ )
			{
				spans[i].style.display = "inline-block"
			}
			for (i=0;i<boxes.length ;i++ )
			{
				boxes[i].style.display = "none"
			}
			numSalts = existSaltNum
			if (document.getElementById("addSaltsBtn") != null){
		    	document.getElementById("addSaltsBtn").style.display = "none"
		    }
			document.getElementById("editSubmit").style.display = "none"
			document.getElementById("editToggleButton").value = "EDIT"
			
		}
}
</script>
<script>
  function resizeIframe(obj) {
    obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
  }
</script>

<div id="inventoryLinksDiv" style="display:none;">
	<h1>Inventory Links</h1>
	<div id="inventoryLinksTable">

	</div>
	<br/>
</div>

<iframe src="javascript:void(0);" width="860" id="batchTableFrame" onload="resizeIframe(this)" style="border:none;<%If Not allowBatches then%>display:none;<%End if%>" border="0"></iframe>

</div>

<%If regHasTemplate then%>
<%
If request.Form("addBatch") = "1" Then
	extra = "&addBatch=1"
else
	extra = "&addBatch=0"
End if
%>


<script type="text/javascript">
$(document).ready(function(){
	$.get("getTemplate.asp?groupId=<%=groupId%><%=extra%>&random="+Math.random())
		.done(function(data){
			div = document.createElement("div");
			div.innerHTML = data;
			div.setAttribute("id","regTemplate")
			regForm = document.getElementById("regForm");
			theForm = document.createElement("form");
			theForm.setAttribute("method",regForm.getAttribute("method"))
			theForm.setAttribute("action",regForm.getAttribute("action"))
			theForm.appendChild(div);
			document.getElementById('regTemplateHolder').appendChild(theForm);
			$("#regTemplate [formName]").each(function(i,el){
				targetEl = document.getElementById(el.getAttribute("formname")+"_view");
				if(targetEl){
					$(el).append(targetEl);
				}
				targetEl = document.getElementById(el.getAttribute("formname"));
				if(targetEl){
					$(el).append(targetEl);
				}
				//targetEl = $("#"+fd.fid+" > [formName='"+el.getAttribute("formName")+"_error']");
				//if(targetEl){
				//	$(el).append(targetEl);
				//}
			});
			delayedRunJS(data);
			 $(".item").css('margin-top',0);
			window.setTimeout(function(){
			try{
				a = tableFieldsToShow;
			}catch(err){
				tableFieldsToShow = "molecule,just_batch,cd_molweight,user_name,cd_timestamp,source";
				tableLinkField = "just_batch";
			}
			document.getElementById("batchTableFrame").src="batchTable.asp?cdId=<%=theCdId%>&regNumber=<%=theRegId%>&fieldsToShow="+tableFieldsToShow+"&tableLinkField="+tableLinkField;window.setTimeout(function(){templateIframeLoad();},500)},500)
		});
});



</script>
<%else%>
<script type="text/javascript">
	document.getElementById("batchTableFrame").src="batchTable.asp?cdId=<%=theCdId%>&regNumber=<%=theRegId%>&groupId=<%=groupId%>"
</script>
<%End if%>
<script type="text/javascript" src="js/multiText.js?<%=jsRev%>"></script>
<script type="text/javascript">
$(document).ready(function(){
	makeMultis();
});
</script>
<%
thisMol = CX_cdIdSearch(jChemRegDB,regMoleculesTable,SQLClean(theCdId,"N","S"),"mol:V3")
Set thisMolObj = JSON.parse(thisMol)
If IsObject(thisMolObj) Then
	If thisMolObj.Exists("structureData") Then
		Set structureData = thisMolObj.Get("structureData")
		If IsObject(structureData) And structureData.Exists("structure") Then
			molDataForAdd = structureData.Get("structure")
		End If
	End If
End If
%>
<%
'<input type="hidden" id="molDataForAdd" value="<'=molDataForAdd>">
'<input type="hidden" id="cdIdForAdd" value="<'=theCdid>">
'<a href="javascript:void(0);" onclick="showInventoryPopupAddReg()">Add Inventory Containers</a>
%>

<!-- #include file="../_inclds/common/html/submitFrame.asp"-->

	<!-- #include file="../_inclds/footer-tool.asp"-->