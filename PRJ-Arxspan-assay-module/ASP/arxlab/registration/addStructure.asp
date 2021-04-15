<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%sectionId="reg"%>
<%subsectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="_inclds/fnc_sendProteinToSearchTool.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include file="../_inclds/projects/functions/fnc_manageProjectLinks.asp"-->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_trimWhiteSpace.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
hideSmallMolecule = checkBoolSettingForCompany("hideSmallMolecule", session("companyId"))
sectionId = "reg"
subSectionId = "add-structure"

regDefaultGroupId = getCompanySpecificSingleAppConfigSetting("defaultRegGroupId", session("companyId"))
If CStr(regDefaultGroupId) <> "" And request.querystring("groupId")="" Then 
	response.redirect("addStructure.asp?groupId="&regDefaultGroupId)
End if

hasRegSorting = checkBoolSettingForCompany("allowRegistrationSorting", session("companyId"))
hideVirtualCompounds = checkBoolSettingForCompany("hideVirtualCompoundsDuringRegistration", session("companyId"))
jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
regNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regIdDelimiter", session("companyId"))
regSaltMappingTable = getCompanySpecificSingleAppConfigSetting("regSaltMappingTable", session("companyId"))
regSaltSearchMode = getCompanySpecificSingleAppConfigSetting("regSaltSearchMode", session("companyId"))
regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
requireBatchForRegIntegration = checkBoolSettingForCompany("requireBatchForRegIntegration", session("companyId"))
projectFieldInReg = checkBoolSettingForCompany("useProjectFieldInReg", session("companyId"))
regRemoveExplicitLonelyHydrogen = checkBoolSettingForCompany("regRemoveExplicitLonelyHydrogen", session("companyId"))
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))

Function printIfSupport(printString, closeResponse)
	If session("email") = "support@arxspan.com" Then
		response.write(printString)

		If closeResponse Then
			response.End()
		End If
	End If
End Function

Function getIdFieldRegNumber(cdIds)
	getIdFieldRegNumber = ""
	Set idRec = server.CreateObject("ADODB.RecordSet")
	
	groupSql = ""
	If isGroup Then
		groupSql = " and groupId="&SQLClean(groupId,"N","S")
		strQuery = "SELECT * FROM groupCustomFieldFields WHERE (isIdentity=1 ) and groupId="&SQLClean(groupId,"N","S")
	Else
		strQuery = "SELECT * FROM customFields WHERE (isIdentity=1)"
	End if
	
	idRec.open strQuery,jchemRegConn,3,3
	If Not idRec.eof Or hasStructure then
		structureStrQuery = "SELECT cd_id,just_reg FROM "&regMoleculesTable&" WHERE just_batch="&SQLClean(padWithZeros(0,regBatchNumberLength),"T","S")&groupSql
		Do While Not idRec.eof
			value = trimWhiteSpace(request.Form(idRec("formName")))
			structureStrQuery = structureStrQuery & " AND CONVERT(VARCHAR(MAX), " & idRec("actualField") & " )="&SQLClean(value,"T","S")
			idRec.movenext
		Loop
		idRec.close
		Set idRec = Nothing
		If cdIds <> "" Then
			structureStrQuery = structureStrQuery & " AND cd_id in ("&cdIds&")"
		End If
		Set sRec = server.CreateObject("ADODB.RecordSet")
		sRec.open structureStrQuery,jchemRegConn,3,3
		If Not sRec.eof then
			getIdFieldRegNumber = sRec("just_reg")
		End if
		sRec.close
		Set sRec = nothing
	Else
		getIdFieldRegNumber = "0"
	End if
End function

Function getMatchingMoleculeCdIds()
	If Not hasStructure Then
		groupSql = ""
		If isGroup Then
			groupSql = " and groupId="&SQLClean(groupId,"N","S")
		End If
	
		Set idRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM groupCustomFieldFields WHERE (isIdentity=1)"&groupSql
		idRec.open strQuery,jchemRegConn,3,3
		structureStrQuery = "SELECT * FROM "&regMoleculesTable&" WHERE just_batch="&SQLClean(padWithZeros(0,regBatchNumberLength),"T","S")&groupSql
		Do While Not idRec.eof
			structureStrQuery = structureStrQuery & " AND CONVERT(VARCHAR(MAX), " & idRec("actualField")&")="&SQLClean(request.Form(idRec("formName")),"T","S")
			idRec.movenext
		Loop
		idRec.close
		Set idRec = Nothing
		retStr = ""
		Set sRec = server.CreateObject("ADODB.RecordSet")
		sRec.open structureStrQuery,jchemRegConn,3,3
		Do While Not sRec.eof
			retStr = retStr & sRec("cd_id")
			sRec.movenext
			If Not sRec.eof Then
				retStr = retStr & ","
			End if
		Loop
		sRec.close
		Set sRec = nothing
	Else
		Set searchParamJson = JSON.parse("{}")
		searchParamJson.Set "searchType", "DUPLICATE"
		
		' list of fields we want back
		fields = "[""cd_id""]"
		
		' additional conditions to impose on the query, beyond structure
		conditions = "{""just_batch"": {""$eq"":"& SQLClean(compoundBatchNumber,"T","S") & "}}"

		'TODO 2147483647 is just Java Max Int, need to do a better job of knowing what the number of results should be
		searchHitJson = CX_structureSearch(jChemRegDB,regMoleculesTable,aspJsonStringify(standardizedMol3000),conditions,JSON.stringify(searchParamJson),fields,2147483647,0)

		cdIdsStr = ""
		Set searchHits = JSON.parse(searchHitJson)
		If IsObject(searchHits) And searchHits.Exists("data") Then
			Set results = searchHits.Get("data")
			If IsObject(results) Then
				cleanResultsJson = cleanRelativeStereoHits(standardizedMol3000, "mol:V3", JSON.Stringify(results), jChemRegDB, regMoleculesTable)
				Set cleanResults = JSON.Parse(cleanResultsJson)
				numResults = cleanResults.Length
				recordNumber = 0
				
				Do While recordNumber < numResults
					Set thisResult = cleanResults.Get(recordNumber)
					thisCdId = thisResult.Get("cd_id")
					
					If cdIdsStr <> "" Then
						cdIdsStr = cdIdsStr & ","
					End If
					
					cdIdsStr = cdIdsStr & thisCdId
					recordNumber = recordNumber + 1
				Loop
			End If
		End If

		If cdIdsStr = "" Then
			cdIdsStr="0"
		End if
		
		Set sRec = server.CreateObject("ADODB.recordSet")
		structureStrQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE cd_id in ("&cdIdsStr&")"
		If isGroup Then
			structureStrQuery = structureStrQuery & " AND groupId="&SQLClean(groupId,"N","S")
		Else
			structureStrQuery = structureStrQuery & " AND (groupId=0 or groupId is null)"
		End If
		sRec.open structureStrQuery,jchemRegConn,3,3
		retStr = ""
		Do While Not sRec.eof
			retStr = retStr & sRec("cd_id")
			sRec.movenext
			If Not sRec.eof Then
				retStr = retStr & ","
			End if
		Loop
		sRec.close
		Set sRec = nothing
	End If
	getMatchingMoleculeCdIds = retStr
End Function 

Function arraySort(ArrayOfTerms)
	Dim a,j
	for a = UBound(ArrayOfTerms) - 1 To 0 Step -1
		for j= 0 to a
			if UCase(ArrayOfTerms(j))>UCase(ArrayOfTerms(j+1)) then
				temp=ArrayOfTerms(j+1)
				ArrayOfTerms(j+1)=ArrayOfTerms(j)
				ArrayOfTerms(j)=temp
			end if
		next
	Next
	arraySort = ArrayOfTerms
End function

Function removeEmptyElements(thisArray)
	dim newArray()
	dim counter, counterNew
	lastElement = UBound(thisArray)
	counter = 0
	counterNew = 0
	reDim newArray(lastElement)  
	Do Until (counter = lastElement)  
		thisValue = thisArray(counter)
		If thisValue <> "" Then
			newArray(counterNew) = thisArray(counter)
			counterNew = counterNew + 1
		End If
		counter = counter + 1
	Loop
	If counterNew>0 then
		ReDim preserve newArray(counterNew-1)
	End if
	removeEmptyElements = newArray
End Function

Function getSaltMatches(structureCdIds)
	getSaltMatches = ""
	structureCdIdList = Split(structureCdIds,",")
	For j = 0 To UBound(structureCdIdList)
		myStructureCdId = structureCdIdList(j)

		thisOneMatches = false
		completeMatch = True
		completeMatchWithMultiplicity = True

		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM "&regSaltMappingTable&" WHERE molid="&SQLClean(myStructureCdId,"N","S")

		rec.open strQuery,jchemRegConn,3,3
		recordCount = 0
		Do While Not rec.eof
			recordCount = recordCount + 1
			rec.movenext
		Loop
		numExistingSalts = recordCount
		rec.close
		Set rec = nothing

		numSalts = 0
		If lastSaltNumber <> "" then
			For i = 1 To Int(lastSaltNumber)
				If request.Form("salt_"&i&"_cdId") <> "0" and request.Form("salt_"&i&"_cdId") <> "" Then
					numSalts = numSalts + 1
					Set rec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * from "&regSaltMappingTable&" WHERE molid="&SQLClean(structureCdId,"N","S")&" AND saltid="&SQLClean(request.Form("salt_"&i&"_cdId"),"N","S")
					rec.open strQuery,jchemRegConn,3,3
					If rec.eof Then
						completeMatch = False
						completeMatchWithMultiplicity = False
					End If
					rec.close
					strQuery = strQuery & " AND multiplicity="&SQLClean(trimWhiteSpace(request.Form("salt_"&i&"_multiplicity")),"T","S")
					rec.open strQuery,jchemRegConn,3,3
					If rec.eof Then
						completeMatchWithMultiplicity = false
					End If
					rec.close
					Set rec = nothing
				End if
			Next
		End if
		If regSaltSearchMode = "ON" Then
			If numExistingSalts = numSalts And completeMatch Then
				thisOneMatches = True
			End if
		End if
		If regSaltSearchMode = "STRICT" Then
			If numExistingSalts = numSalts and completeMatchWithMultiplicity Then
				thisOneMatches = True
			End if
		End If
		If thisOneMatches Then
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM "&regMoleculesTable& " WHERE cd_id=" & SQLClean(myStructureCdId,"N","S")
			rec.open strQuery,jchemRegConn,3,3
			getSaltMatches = getSaltMatches & rec("cd_id") & ","
			rec.close
			Set rec = Nothing
		End if	
	Next
	If Len(getSaltMatches) > 1 then
		getSaltMatches = Left(getSaltMatches,Len(getSaltMatches)-1)
	End If
End function

Function getCustomMappings()
	Dim customMappings()
	Set rec = server.CreateObject("ADODB.RecordSet")
	If Not addBatch Then
		If isGroup Then
			strQuery = "SELECT * FROM groupCustomFieldFields WHERE (showCompoundInput=1 or requireCompound=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY id ASC"
		else
			strQuery = "SELECT * FROM customFields WHERE showCompoundInput=1 or requireCompound=1 ORDER BY id ASC"
		End if
	Else
		If isGroup Then
			strQuery = "SELECT * FROM groupCustomFieldFields WHERE (showBatchInput=1 or requireBatch=1 or isIdentity=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY id ASC"						
		else
			strQuery = "SELECT * FROM customFields WHERE showBatchInput=1 or requireBatch=1 ORDER BY id ASC"
		End if
	End if
	rec.open strQuery,jchemRegConn,3,3
	recordCount = 0
	Do While Not rec.eof
		recordCount = recordCount + 1
		rec.movenext
	Loop
	rec.close
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		ReDim customMappings(recordCount-1,1)
	Else
		ReDim customMappings(-1)
	End if
	counter = 0
	Do While Not rec.eof
		customMappings(counter,0) = rec("actualField")
		value = trimWhiteSpace(request.Form(rec("formName")))
		customMappings(counter,1) = value
		counter = counter + 1
		rec.movenext
	loop
	rec.close
	Set rec = Nothing
	getCustomMappings = customMappings
End Function

Function getOverrunLengthErrors()
	Dim fields
	Set rec = server.CreateObject("ADODB.RecordSet")
	If Not addBatch Then
		If isGroup Then
			strQuery = "SELECT * FROM groupCustomFieldFields WHERE (showCompoundInput=1 or requireCompound=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY id ASC"
		else
			strQuery = "SELECT * FROM customFields WHERE showCompoundInput=1 or requireCompound=1 ORDER BY id ASC"
		End if
	Else
		If isGroup Then
			strQuery = "SELECT * FROM groupCustomFieldFields WHERE (showBatchInput=1 or requireBatch=1 or isIdentity=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY id ASC"						
		else
			strQuery = "SELECT * FROM customFields WHERE showBatchInput=1 or requireBatch=1 ORDER BY id ASC"
		End if
	End if
	rec.open strQuery,jchemRegConn,0,-1
	Set fields = JSON.parse("[]")
	fieldLengthQuery = "SELECT "
	Do While Not rec.eof
		Set D = JSON.parse("{}")
		D.Set "actualField",CStr(rec("actualField"))
		D.Set "formName",CStr(rec("formName"))
		D.Set "displayName",CStr(rec("displayName"))
		fields.push(D)
		fieldLengthQuery = fieldLengthQuery & "COL_LENGTH('"&regMoleculesTable&"','"&rec("actualField")&"') as "&rec("actualField")
		rec.movenext
		If Not rec.eof Then
			fieldLengthQuery = fieldLengthQuery & ","
		End if
	Loop
	rec.close
	Set rec = Nothing

	If fieldLengthQuery = "SELECT " Then
		fieldLengthQuery = "SELECT * FROM "&regMoleculesTable&" WHERE 1=2"
	End if

	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open fieldLengthQuery,jchemRegConn,0,-1
	If Not rec.eof Then
		For Each key in fields.keys()
			Set item = fields.Get(key)
			fieldLength = rec(CStr(item.Get("actualField")))
			formVal = trimWhiteSpace(CStr(request.Form(item.get("formName"))))
			If InStr(item.Get("actualField"),"vc") > 0 Then
				If Not IsNull(fieldLength) then
					If Len(formVal) > fieldLength And fieldLength <> -1 Then
						'field length apparently is -1 when MAX is selected
						regError = True
						errorText = errorText & item.get("displayName")&" exceeded maximum length of "&fieldLength&" with length of "&Len(formVal)&".  <br/>"
						errorFields = errorFields & item.get("formName") &","
					End If
				End If
			End if
		next
	End If
	rec.close
	Set rec = Nothing
End function

if Not (session("regRegistrar") Or session("regUser")) Then
	response.redirect("logout.asp")
End If

cdIdForFT = ""
addBatch = false
moleculeAdded = false
moleculeWasAdded = false

If request.querystring("inFrame") = "true" Then
	inFrame = True
Else
	inFrame = false
End If

Set aff = JSON.parse("{}")

If request.querystring("fromReg") = "1" Then
	fromReg = True
	If request.querystring("numObjects") = "" Or Not isInteger(request.querystring("numObjects")) Then
		numObjects = 1
	Else
		numObjects = request.querystring("numObjects")
	End If
	Set aff = JSON.parse(request.querystring("autoFillFields"))
Else
	fromReg = false
End If

If request.querystring("isBio") = "1" Then
	isBio = true
Else
	isBio = false
End if

If request.querystring("sourceId") = "" Then
	sourceId = "1"
Else
	sourceId = request.querystring("sourceId")
End if

If experimentId = "" Then
	experimentId = request.Form("experimentId")
	experimentType = request.Form("experimentNumber")
	If experimentType = "" Then
		experimentType = request.Form("experimentType")
	End if
	revisionNumber = request.form("revisionNumber")
	regFieldId = request.form("regFieldId")
	molData = request.form("regMolData")
	regName = request.Form("regName")
	regExperimentName = request.Form("regExperimentName")
	regAmount = request.Form("regAmount")
	If regFieldId <> "" then
		regPrefix = Split(regFieldId,"_")(0)
	End if
End if
If experimentId = "" Then
	experimentId = request.querystring("experimentId")
	experimentType = request.querystring("experimentType")
	If experimentType = "" Then
		experimentType = request.querystring("experimentType")
	End If
	revisionNumber = request.querystring("revisionNumber")
	regExperimentName = request.querystring("regExperimentName")
	regAmount = request.querystring("regAmount")
	regFieldId = request.querystring("regFieldId")
	If regFieldId <> "" then
		regPrefix = Split(regFieldId,"_")(0)
	End if
End if

groupId = request.querystring("groupId")
groupCustomFieldName = "Molecule"
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT name FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
If session("regRestrictedGroups") <> "" Then
	strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
End if
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	groupCustomFieldName = rec("name")
End If
rec.close
Set rec = nothing
Call disconnectJchemReg

moleculeAddedText = groupCustomFieldName & " Added"
addAnotherStructureText = "ADD ANOTHER " & groupCustomFieldName
addBatchText = "ADD BATCH"
structureAlreadyExistsText = "Structure Already Exists."
hasIdFields = False
useSalts = True
hasStructure = True
allowBatchesOfBatches = False
allowBatches = True
If isInteger(groupId) And groupId <> "0" Then
	isGroup = True
	groupId = request.querystring("groupId")
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
	If session("regRestrictedGroups") <> "" Then
		strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
	End if
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		If rec("useSalts") = 0 Then
			useSalts = False
		End if	
		If rec("hasStructure") = 0 Then
			hasStructure = False
		End If
		If rec("allowBatches") = 0 Then
			allowBatches = False
		End if
		If rec("allowBatchesOfBatches") = 1 Then
			allowBatchesOfBatches = True
			regBatchNumberMode = "RANDOM"
		End if
		groupPrefix = rec("groupPrefix")
	Else
		title = "Error"
		message = "Group does not exist or you are not authorized to access it."
		response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
	End If
	rec.close()
	strQuery = "SELECT * FROM groupCustomFieldFields WHERE (isIdentity=1) AND groupId="&SQLClean(groupId,"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		hasIdFields = True
	End If
	rec.close
	Set rec = nothing
	Call disconnectJchemReg
Else
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM customFields WHERE (isIdentity=1)"
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		hasIdFields = True
	End If
	rec.close
	Set rec = nothing
	Call disconnectJchemReg
	isGroup = False
	groupId = 0
	groupPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
End If
batchRegPrefix = groupPrefix

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
End If
If Error.num <> 0 Then
 regHasTemplate = false
End if
On Error goto 0

If request.Form("addStructureSubmit") <> "" Then
	projectId = request.Form("linkProjectId")
	addBatchCdId = request.Form("addBatchCdId")
	call getconnectedJchemReg

	If request.Form("addBatch") = "1" Then
		addBatch = True
	End if
	
	If request.Form("moleculeWasAdded") = "1" Then
		moleculeWasAdded = True
	End if
	
	lastSaltNumber = request.Form("lastSaltNumber")
	validSalts = 0
	'set the number of salts accounting for possible gaps
	If lastSaltNumber <> "" then
		For i = 1 To CInt(lastSaltNumber)
			If request.Form("salt_"&i&"_cdId") <> "0" And request.Form("salt_"&i&"_cdId") <> "" Then
				validSalts = validSalts + 1
			End if
		next
	End if

	'standardize structure
	If hasStructure Then
		if request.Form("regMolData") <> "" then
			inputMol = request.Form("regMolData")
		else
			inputMol = request.Form("addStructureCdxmlData")
		end if
		
		origMol = inputMol
		inputMolFormat = "mol"
		
		inputMolDataJson = analyzeInputMol(inputMol)
		Set inputMolData = JSON.Parse(inputMolDataJson)
		If IsObject(inputMolData) Then
			inputMol = inputMolData.Get("structure")
			inputMolFormat = inputMolData.Get("molFormat")
		End If
		
		inputMol = CX_standardize(inputMol,inputMolFormat,defaultStandardizerConfig,"mol:V3")
		smilesWithSalts = CX_standardize(aspJsonStringify(inputMol),"mol:V3",defaultStandardizerConfig,"smiles")

		saltStripConfig = ""
		Set sRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cd_id,cd_smiles FROM "&regSaltsTable&" WHERE cd_smiles is not null"
		sRec.open strQuery,jchemRegConn,3,3
		If sRec.recordCount > 0 Then
			saltStripConfig = "<?xml version=""1.0"" encoding=""UTF-8"" ?>"&_
				"<StandardizerConfiguration Version=""0.1"">"&_
					"<Actions>"
			Do While Not sRec.eof
				saltStripConfig = saltStripConfig & "<Transformation ID="""&sRec("cd_id")&""" Structure="""&Split(sRec("cd_smiles")," ")(0)&">>"" Exact=""true""/>"
				sRec.movenext
			Loop
		
			If regRemoveExplicitLonelyHydrogen Then
				saltStripConfig = saltStripConfig & "<RemoveExplicitH ID=""RemoveExplicitH"" lonely=""true""/>"
			End If
			
			saltStripConfig = saltStripConfig & "</Actions></StandardizerConfiguration>"
			
		End If
		sRec.close
		Set sRec = nothing
		
		If saltStripConfig <> "" Then
			standardizedMol3000 = CX_standardize(aspJsonStringify(inputMol),"mol:V3",saltStripConfig,"mol:V3")
		Else
			standardizedMol3000 = inputMol
		End If

		smilesWithoutSalts = CX_standardize(aspJsonStringify(standardizedMol3000),"mol:V3",defaultStandardizerConfig,"smiles")

		If validSalts<>0 Then
			smilesWithSalts = smilesWithoutSalts
		Else
			validSalts = validSalts + UBound(Split(smilesWithSalts,".")) - UBound(Split(smilesWithoutSalts,"."))
		End if
	End if
	regError = False
	errorText = ""
	errorFields = ""

	'throw an error if there is no structure on a group that should have a structure
	If trimWhiteSpace(origMol) = "" And hasStructure Then
		regError = True
		errorText = errorText & "Please enter a structure.  <br/>"
	End If

	'make sure we don't have a project that has child tabs selected
	If projectId = "x" Then
		regError = true
		errorText = errorText & "This project has tabs. Please select the tab that you would like to link to."
	End if

	If LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "mixture" Or LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "chiral" Or LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "achiral" Or LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "relative" Or LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "racemic" Or LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "undefined"  Or LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "unknown, single compound" then
		Set d = JSON.parse("{}")
		d.Set "structure", standardizedMol3000
		data = JSON.stringify(d)
		Set http = CreateObject("MSXML2.ServerXMLHTTP")
		http.setOption 2, 13056
		http.open "POST",chemAxonCipStereoUrl,True
		http.setRequestHeader "Content-Type","application/json" 
		http.setRequestHeader "Content-Length",Len(data)
		http.SetTimeouts 120000,120000,120000,120000
		http.send data
		http.waitForResponse(60)
		
		jsonResponse = http.responseText
		If jsonResponse <> "" Then
			Set r = JSON.parse(http.responseText)
			numStereoCenters = 0
			numUndefinedStereoCenters = 0
			If r.exists("tetraHedral") Then
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
			End If

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
				Next
			End If
			'response.write(JSON.stringify(tetraHedral)&"<br>")
			'response.write(JSON.stringify(doubleBond)&"<br>")
			'response.write("centers: "&numStereoCenters&"<br>")
			'response.write("undef centers: "&numUndefinedStereoCenters&"<br>")
		End If
	End if

	'check that there is more than one molecule if structure is chosen
	'done
	If LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "mixture" Then
		If Not (ubound(Split(smilesWithSalts,".")) >0 or numUndefinedStereoCenters>0) then
			regError = True
			errorText = errorText & "Mixtures must contain either more than one structure or an undefined stereocenter. <br/>"
		End if
	End If
	
	'done
	If LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "chiral" Then
		If Not (numUndefinedStereoCenters=0 And numStereoCenters>0) then
			regError = True
			errorText = errorText & "Chiral structures must contain at least one stereocenter and have all stereocenters defined.  <br/>"
		End if
	End If

	If LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "racemic" Then
		If Not (numStereoCenters>0 And numUndefinedStereoCenters>0)  then
			regError = True
			errorText = errorText & "Racemic structures must contain at least one undefined stereocenter.  <br/>"
		End if
	End If

	If LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "relative" Then
		If Not (numStereoCenters>1 And numUndefinedStereoCenters=0)  then
			regError = True
			errorText = errorText & "Relative structures must contain more than one stereocenter and have all stereocenters defined.  <br/>"
		End if
	End If

	'done
	If LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "achiral" Then
		If Not (numStereoCenters=0) then
			regError = True
			errorText = errorText & "Achiral structures may not contain stereocenters.  <br/>"
		End if
	End If

	If LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "undefined" Or LCase(trimWhiteSpace(request.Form("Stereochemistry"))) = "unknown, single compound" Then
		If Not (numStereoCenters>0 And numUndefinedStereoCenters>0)  then
			regError = True
			errorText = errorText & "Undefined (Unknown, single compound) structures must contain at least one undefined stereocenter.  <br/>"
		End if
	End If
	'//5115
	
	' don't do form validation if we just added something (compound or batch)
	If Not moleculeWasAdded Then
	
		Set rec = server.CreateObject("ADODB.RecordSet")
		If Not addBatch Then
			'get the custom fields for a compound.  If we are in a group get the compound custom fields for that group
			If isGroup Then
				strQuery = "SELECT * FROM groupCustomFieldFields WHERE (showCompoundInput=1 or requireCompound=1 or dataType='int' or dataType='float') and groupId="&SQLClean(groupId,"N","S")
			else
				strQuery = "SELECT * FROM customFields WHERE showCompoundInput=1 or requireCompound=1 or dataType='int' or dataType='float'"
			End if
		Else
			'get the custom fields for a batch.  If we are in a group get the batch custom fields for that group
			If isGroup Then
				strQuery = "SELECT * FROM groupCustomFieldFields WHERE (showBatchInput=1 or requireBatch=1 or dataType='int' or dataType='float') and groupId="&SQLClean(groupId,"N","S")		
			else
				strQuery = "SELECT * FROM customFields WHERE showBatchInput=1 or requireBatch=1 or dataType='int' or dataType='float'"
			End if
		End If

		If hasRegSorting Then
			strQuery = strQuery & " ORDER BY sortOrder ASC, id ASC"
		Else
			strQuery = strQuery & " ORDER BY id ASC"
		End if
		
		'loop through all custom fields for error checking
		rec.open strQuery,jchemRegConn,3,3
		Do While Not rec.eof
			If rec("enforceUnique") And trimWhiteSpace(request.Form(rec("formName")))<>"" Then
				'if field is required to be unique, query to table to see if the value exists
				Set uRec = server.CreateObject("ADODB.RecordSet")
				If Not addBatch Then
					'qqq
					value = trimWhiteSpace(request.Form(rec("formName")))
					strQuery = "SELECT just_batch FROM "&regMoleculesTable&" WHERE cast(just_batch as INT)=0 and "&rec("actualField")&"="&SQLClean(value,"T","S")
					uRec.open strQuery,jchemRegConn,3,3
					If Not uRec.eof Then
						regError = True
						errorText = errorText & rec("displayName")&" does not contain a unique value.  <br/>"
					End If
				Else
					'qqq
					strQuery = "SELECT just_batch FROM "&regMoleculesTable&" WHERE cast(just_batch as INT)<>0 and "&rec("actualField")&"="&SQLClean(trimWhiteSpace(request.Form(rec("formName"))),"T","S")
					uRec.open strQuery,jchemRegConn,3,3
					If Not uRec.eof Then
						regError = True
						errorText = errorText & rec("displayName")&" does not contain a unique value.  <br/>"
					End If
				End If
				uRec.close
				Set uRec = nothing
			End If
			
			If (addBatch And rec("requireBatch") = 1) Or (Not addBatch And rec("requireCompound")=1) then
				'return error if field is required, but blank
				If trimWhiteSpace(request.Form(rec("formName"))) = "" Or trimWhiteSpace(request.Form(rec("formName"))) = "-1" Then
					regError = True
					errorText = errorText & rec("displayName")&" is required.  <br/>"
					errorFields = errorFields & rec("formName") &","
				End If
			End If

			If (addBatch And rec("showBatchInput") = 1 And (trimWhiteSpace(request.Form(rec("formName")))<>"" Or rec("requireBatch")=1)) Or (Not addBatch And rec("showCompoundInput")=1 And (trimWhiteSpace(request.Form(rec("formName")))<>"" Or rec("requireCompound")=1)) then
				If rec("dataType") = "int" Then
					If Not isInteger(trimWhiteSpace(request.Form(rec("formName")))) Then
						regError = True
						errorText = errorText & rec("displayName")&" must be an integer.  <br/>"
						errorFields = errorFields & rec("formName") &","
					End if
				End if

				If rec("dataType") = "float" Then
					If Not isNumber(trimWhiteSpace(request.Form(rec("formName")))) Then
						regError = True
						errorText = errorText & rec("displayName")&" must be an real number.  <br/>"
						errorFields = errorFields & rec("formName") &","
					End if
				End if

				If rec("dataType") = "multi_int" Then
					vals = Split(trimWhiteSpace(request.Form(rec("formName"))),"###")
					For i = 0 To UBound(vals)
						If Not isInteger(vals(i)) Then
							regError = True
							errorText = errorText & rec("displayName")&" item "&(i+1)&" must be an integer.  <br/>"
							errorFields = errorFields & rec("formName") &","
						End If
					next
				End if

				If rec("dataType") = "multi_float" Then
					vals = Split(trimWhiteSpace(request.Form(rec("formName"))),"###")
					For i = 0 To UBound(vals)
						If Not isNumber(vals(i)) Then
							regError = True
							errorText = errorText & rec("displayName")&" item "&(i+1)&" must be an real number.  <br/>"
							errorFields = errorFields & rec("formName") &","
						End if
					next
				End if

			end if
			
			rec.movenext
		loop
		rec.close
		Set rec = Nothing

	End If '(Not moleculeWasAdded)
	
	a = getOverrunLengthErrors()

	If Not regError then
		onlyStructureError = false
		If Not addBatch Or (addBatch And request.Form("addBatch")="1") Then
			'needs to loop through all parents if switching modes is desired
			Call getConnectedJchemReg
			%><!-- #include file="_inclds/searchOptionsString.asp"--><%

			If Not hasStructure Then
				If getIdFieldRegNumber("") <> "" then
					numResults = 1
				Else
					numResults = 0
				End if
			Else
				numResults = 0
				Set searchParamJson = JSON.parse("{}")
				searchParamJson.Set "searchType", "DUPLICATE"
				
				' list of fields we want back
				fields = "[""cd_id""]"
				
				' additional conditions to impose on the query, beyond structure
				conditions = "{""just_batch"": {""$eq"":"& SQLClean(compoundBatchNumber,"T","S") & "}}"

				'TODO 2147483647 is just Java Max Int, need to do a better job of knowing what the number of results should be
				searchHitJson = CX_structureSearch(jChemRegDB,regMoleculesTable,aspJsonStringify(standardizedMol3000),conditions,JSON.stringify(searchParamJson),fields,2147483647,0)

				cdIdsStr = ""
				Set searchHits = JSON.parse(searchHitJson)
				If IsObject(searchHits) And searchHits.Exists("data") Then
					Set results = searchHits.Get("data")
					If IsObject(results) Then
						cleanResultsJson = cleanRelativeStereoHits(standardizedMol3000, "mol:V3", JSON.Stringify(results), jChemRegDB, regMoleculesTable)
						Set cleanResults = JSON.Parse(cleanResultsJson)
						numResults = cleanResults.Length
					End If
				End If
			End if
			structureCdIds = ""
			If numResults > 0 Then
				structureCdIds = getMatchingMoleculeCdIds()
				If regSaltSearchMode <> "OFF" Then
					'get molecules that match so we can find the better match when taking the salts into consideration
					saltMatches = getSaltMatches(structureCdIds)
					If saltMatches <> "" then
						batchRegNumber = getIdFieldRegNumber(saltMatches)
					End if
					If batchRegNumber = "" Then
						batchRegNumber = getNewRegNumber(groupId)
					Else
						isMatch = True
					End If
				Else
					If Not hasStructure Then
						batchRegNumber = getIdFieldRegNumber("")
						If batchRegNumber = "0" Then
							batchRegNumber = getNewRegNumber(groupId)
						else
							isMatch = True
						End if
					else
						If structureCdIds <> "" then
							batchRegNumber = getIdFieldRegNumber(structureCdIds)
						End if
						If batchRegNumber <> "" then
							isMatch = True
						End if
					End if
				End if

				If isMatch then
					If Not regError And request.Form("addBatch") = "1" Then
						onlyStructureError = True
					End If
					If Not regError Then
						addBatch = True
					End if
					regError = True
					If errorText = "" Then
						If structureCdIds <> "" then
							Set bRec = server.CreateObject("ADODB.RecordSet")
							strQuery = "SELECT just_reg, reg_id FROM "&regMoleculesTable&" WHERE cd_id in("&SQLClean(parentCdId,"N","S")&")"
							bRec.open strQuery,jchemRegConn,3,3
							If Not bRec.eof Then
								batchRegNumber = bRec("just_reg")
								batchRegId = bRec("reg_id")
								If Len(batchRegId) > 3 Then
									batchRegId = Left(batchRegId, Len(batchRegId)-regBatchNumberLength-1)
								End If

								regNumPos = InStrRev(batchRegId, regBatchNumberDelimiter&batchRegNumber)
								If regNumPos > 0 Then
									batchRegPrefix = Left(batchRegId, regNumPos - 1)
								End If
							End if
						End If
						
						If allowBatches then
							errorText = errorText 
							If hideVirtualCompounds Then
								errorText = errorText & "Reg ID: "
							Else
								errorText = errorText & structureAlreadyExistsText&"  "
							End If
							errorText = errorText &makeRegLink(batchRegPrefix,batchRegNumber,"")&"<br/>"
						Else
							addBatch = False
							regError = True
							errorText = errorText & structureAlreadyExistsText&"  "&makeRegLink(batchRegPrefix,batchRegNumber,"")&"<br/>Adding batches is disabled for this type."
						End if
					End if
				End If
			End If
		End if


		If Not regError Or onlyStructureError Or (addBatch AND request.Form("addBatch")=1) Then
		If addBatch Then
			if addBatchCdId = "" then
				Set bRec = server.CreateObject("ADODB.RecordSet")
				filterQuery = "groupId="&SQLClean(groupId,"N","S")
				If groupId = 0 Or groupId = "0" Then
					filterQuery = "(groupId is null or " & filterQuery & ")"
				End If
				strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE just_reg="&SQLClean(batchRegNumber,"T","S") & " AND just_batch="&SQLClean(compoundBatchNumber,"T","S")&" and "&filterQuery
				bRec.open strQuery,jchemRegConn,3,3
				If Not bRec.eof Then
					parentCdId = bRec("cd_id")
				Else
					parentCdId = 0
				End If

			else
				parentCdId = addBatchCdId
			end if
			Set bRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT just_reg, reg_id FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(parentCdId,"N","S")
			bRec.open strQuery,jchemRegConn,3,3
			If Not bRec.eof Then
				batchRegNumber = bRec("just_reg")
				batchRegId = bRec("reg_id")
				If Len(batchRegId) > 3 Then
					batchRegId = Left(batchRegId, Len(batchRegId)-regBatchNumberLength-1)
				End If

				regNumPos = InStrRev(batchRegId, regBatchNumberDelimiter&batchRegNumber)
				If regNumPos > 0 Then
					batchRegPrefix = Left(batchRegId, regNumPos - 1)
				End If
			End if
		Else
			parentCdId = 0
		End if

		customMappings = getCustomMappings()

		If Not addBatch Then
			regNumber = getNewRegNumber(groupId)
			batchNumber = padWithZeros(0,regBatchNumberLength)
		Else
			regNumber = batchRegNumber
			batchNumber = getNewBatchNumber(groupId,batchRegNumber)
		End If

		If Not addBatch Then
			wholeRegNumber = groupPrefix&regNumberDelimiter&regNumber&regBatchNumberDelimiter&batchNumber
		Else
			wholeRegNumber = batchRegId&regBatchNumberDelimiter&batchNumber
		End If

		If fromReg Then
			itemStr = ""
			For w = 1 To CInt(numObjects)
				thisRegNumber = getNewRegNumber(groupId)
				If Not addBatch Then
					wholeRegNumber = groupPrefix&regNumberDelimiter&thisRegNumber&regBatchNumberDelimiter&batchNumber
				Else
					wholeRegNumber = batchRegId&regBatchNumberDelimiter&batchNumber
				End If
				If isBatch Then
					itemStr = itemStr & wholeRegNumber
				else
					itemStr = itemStr & groupPrefix&regNumberDelimiter&thisRegNumber
				End if
				If w<numObjects Then
					itemStr = itemStr & vbcrlf
				End if
				groupIdArg = groupId
				If groupIdArg = 0 Or groupIdArg = "0" Or groupIdArg = "" Then
					groupIdArg = Null
				End If
				experimentIdArg = request.Form("experimentId")
				If experimentIdArg = "" Then
					experimentIdArg = Null
				End If
				revisionNumberArg = request.Form("revisionNumber")
				If revisionNumberArg = "" Then
					revisionNumberArg = Null
				End If
				If standardizedMol3000 = "" And (Not IsNull(groupIdArg)) Then
					standardizedMol3000 = "Untitled Document-1"&vbcrlf&"  ChemDraw08021814242D"&vbcrlf&vbcrlf&"  1  0  0  0  0  0  0  0  0  0999 V2000"&vbcrlf&"    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0"&vbcrlf&"M  END"
				End If
				experimentType = request.Form("experimentType")
				regExperimentNameArg = request.Form("regExperimentName")

				newCdId = addToMolTable(parentCdId,"1","",session("userId"),session("userId"),sourceId,session("firstName")&" "&session("lastName"),"0","3",aspJsonStringify(standardizedMol3000),experimentIdArg,experimentTypeArg,revisionNumberArg,regExperimentNameArg,"",customMappings,wholeRegNumber,thisRegNumber,batchNumber,groupIdArg)

				pId = newCdId
				Set recPro = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(wholeRegNumber,"T","S")
				recPro.open strQuery,jchemRegconn,3,3
				If Not recPro.eof Then
					newCdId = recPro("cd_id")
					cdIdForFT = newCdId
				End If
				strQuery = "UPDATE "&regMoleculesTable&" SET dateCreatedUTC=GETUTCDATE() WHERE cd_id="&SQLClean(newCdId,"N","S")
				jchemRegConn.execute(strQuery)
			Next
			Set cfRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT actualField from customFields WHERE formName="&SQLClean(aff.Get("_regUpdateField"),"T","S")
			cfRec.open strQuery,jchemRegConn,0,-1
			If Not cfRec.eof Then
				actualField = cfRec("actualField")
				strQuery = "UPDATE "&regMoleculesTable&" SET "&actualField&"="&SQLClean(itemStr,"T","S")&" WHERE reg_id="&SQLClean(aff.Get("_regUpdateId"),"T","S")
				jchemRegConn.execute(strQuery)
			End If
			%>
			<script type="text/javascript" src="<%=mainAppPath%>/js/popups.js?<%=jsRev%>"></script>
			<script type="text/javascript">
				window.parent.hidePopup("regDiv")
				window.parent.showInventoryPopupBulkAddReg("<%=replace(itemStr,vbcrlf,",")%>")
				//window.parent.location = window.parent.location;
			</script>
			<%
			response.end
		else
			groupIdArg = groupId
			If groupIdArg = 0 Or groupIdArg = "0" Or groupIdArg = "" Then
				groupIdArg = Null
			End If
			experimentIdArg = request.Form("experimentId")
			If experimentIdArg = "" Then
				experimentIdArg = Null
			End If
			revisionNumberArg = request.Form("revisionNumber")
			If revisionNumberArg = "" Then
				revisionNumberArg = Null
			End If
			experimentTypeArg = request.Form("experimentType")
			If experimentTypeArg = "" Then
				experimentTypeArg = Null
			End If
			If standardizedMol3000 = "" And (Not IsNull(groupIdArg)) Then
				standardizedMol3000 = "Untitled Document-1"&vbcrlf&"  ChemDraw08021814242D"&vbcrlf&vbcrlf&"  1  0  0  0  0  0  0  0  0  0999 V2000"&vbcrlf&"    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0"&vbcrlf&"M  END"
			End If
			experimentType = request.Form("experimentType")
			regExperimentNameArg = request.Form("regExperimentName")

			newCdId = addToMolTable(parentCdId,"1","",session("userId"),session("userId"),sourceId,session("firstName")&" "&session("lastName"),"0","3",aspJsonStringify(standardizedMol3000),experimentIdArg,experimentTypeArg,revisionNumberArg,regExperimentNameArg,"",customMappings,wholeRegNumber,regNumber,batchNumber,groupIdArg)
			If Not IsNumeric(newCdid) Then
				pId = newCdId
				Set recPro = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(wholeRegNumber,"T","S")
				recPro.open strQuery,jchemRegconn,3,3
				If Not recPro.eof Then
					newCdId = recPro("cd_id")
				End If
			End if
			If hasStructure And newCdId > 0 then
				chemicalName = CX_convertStructure(aspJsonStringify(standardizedMol3000),"mol:V3","name")
				If chemicalName<>"error" then
					strQuery = "UPDATE "&regMoleculesTable&" SET chemaxon_chemical_name="&SQLClean(Replace(trimWhiteSpace(chemicalName),vbcrlf,""),"T","S")& " WHERE cd_id="&SQLClean(newCdId,"N","S")
					'response.write(strQuery)
					'response.end
					jchemRegConn.execute(strQuery)
				End If
			End if
			strQuery = "UPDATE "&regMoleculesTable&" SET dateCreatedUTC=GETUTCDATE() WHERE cd_id="&SQLClean(newCdId,"N","S")
			jchemRegConn.execute(strQuery)
			If hideVirtaulCompounds And addBatch Then
				strQuery = "UPDATE "&regMoleculesTable&" SET status_id=1 WHERE just_reg="&SQLClean(reg_number,"T","S")
				jchemRegConn.execute(strQuery)
			End if
			If Not addBatch Then
				If projectId <> "" Then
					Call getconnectedadm
					If Not hasStructure Then
						pId = newCdId
						Set recPro = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(wholeRegNumber,"T","S")
						recPro.open strQuery,jchemRegconn,3,3
						If Not recPro.eof Then
							newCdId = recPro("cd_id")
						End if
					End if
					If canWriteProject(projectId,session("userId")) Then
						a = addRegIdToProject(connAdm, newCdId,ProjectId,Null)
						On Error Resume next
						strQuery = "UPDATE "&regMoleculesTable&" SET projectId="&SQLClean(projectId,"N","S")&" WHERE cd_id="&SQLClean(newCdId,"N","S")
						jchemRegConn.execute(strQuery)
						On Error goto 0
					End If
					Call disconnectadm
				End if
			End If

			If session("companyHasFT") Or session("companyHasFTLiteReg") then
				pId = newCdId
				Set recPro = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(wholeRegNumber,"T","S")
				recPro.open strQuery,jchemRegconn,3,3
				If Not recPro.eof Then
					newCdId = recPro("cd_id")
					cdIdForFT = newCdId
				End if
				'a = sendProteinToSearchTool(newCdId,true,false)
			End If

			' Allow a custom field in Reg to auto-populate with Notebook Page information
			If addBatch Then
				If (session("companyId") = 19 AND whichServer = "PROD" AND experimentId <> "") OR (session("companyId") = 96 AND whichServer = "BETA" AND experimentId <> "") OR (session("companyId") = 28 AND whichServer = "DEV" AND experimentId <> "") Then
					' Get Experiment_name column from customFields
					Set recCF = server.CreateObject("ADODB.RecordSet")
					strQuerycf = "SELECT actualField FROM customFields WHERE formName = 'Experiment_Name'"
					recCF.open strQuerycf, jchemRegconn, 3, 3
					If Not recCF.eof Then
						actualField = recCF("actualField")
						strQueryEN = "UPDATE "&regMoleculesTable&" SET " & actualField & " = '" & regExperimentName & "' WHERE reg_id="&SQLClean(wholeRegNumber,"T","S")
						jchemRegConn.execute(strQueryEN)
					End if
				End if
			End if
		End if

		If lastSaltNumber <> "" then
			For i = 1 To CInt(lastSaltNumber)
				If request.Form("salt_"&i&"_cdId") <> "0" and request.Form("salt_"&i&"_cdId") <> "" Then
					call getconnectedJchemReg
					strQuery = "INSERT INTO "&regSaltMappingTable&"(saltId,molId,multiplicity) values("&_
								SQLClean(request.Form("salt_"&i&"_cdId"),"N","S")&","&_
								SQLClean(newCdId,"N","S")&","&_
								SQLClean(trimWhiteSpace(request.Form("salt_"&i&"_multiplicity")),"N","S")&")"
					jchemRegConn.execute(strQuery)
				End if
			next
		End if

		salts = Split(smilesWithSalts,".")		
		For i = 0 To UBound(salts)
			If salts(i) <> "" then
				
				' make a jchem call to verify the salt and get the cd_id of the salt
				Set params = JSON.parse("{}")
				params.Set "searchType", "DUPLICATE"
				searchHitJson = CX_structureSearch(jChemRegDB,regSaltsTable,salts(i),"",JSON.stringify(params),"[""cd_id""]",1,0)
				Set searchHits = JSON.parse(searchHitJson)				
				
				If IsObject(searchHits) And searchHits.Exists("data") Then					
					saltCdId = -1															
					Set results = searchHits.Get("data")
					' we should only get back one result
					If results.Length = 1 Then
						Set resultCdId = results.Get(0)
						
						If IsObject(resultCdId) And resultCdId.Exists("cd_id") Then
							saltCdId = resultCdId.Get("cd_id")
							
							If saltCdId > -1 Then									
								' Count how many times the salt is in the compound being registered
								multiplicity = 1
								For j = i+1 To UBound(salts)
									If salts(i) = salts(j) Then
										salts(j) = ""
										multiplicity = multiplicity + 1
									End if
								Next

								' Insert into saltMapping table the new compound and salt multiplicity
								strQuery = "INSERT INTO "&regSaltMappingTable&"(saltId,molId,multiplicity) values("&_
										SQLClean(saltCdId,"N","S")&","&_
										SQLClean(newCdId,"N","S")&","&_
										SQLClean(multiplicity,"N","S")&")"
								jchemRegConn.execute(strQuery)
								salts(i) = ""
							End If
						End If
					End If
				End If
			End if
		next
		If cdIdForFT <> "" Then
			a = sendProteinToSearchTool(cdIdForFT,true,false)
		End If
		
			moleculeAdded = True
			If batchRegNumber = "" then
				batchRegNumber = regNumber
			End If
			wholeRegNumberLink = makeRegLink(batchRegPrefix,batchRegNumber,batchNumber)
			regError = False
			regErrorText = ""

			If hasStructure Then
				jchemRegConn.execute(strQuery)
				On Error Resume next
				strQuery = "INSERT into cdxml(cd_id,inputMol) values("&SQLClean(newCdId,"N","S")&","&SQLClean(inputMol,"T","S")&")"
				jchemRegConn.execute(strQuery)
				On Error goto 0
			End If
		End if
	End if
Call disconnectJchemReg
End if
%>

<%If inframe then%>
<html>
<head>
<link href="<%=mainCSSPath%>/reg-styles.css?<%=jsRev%>" rel="stylesheet" type="text/css" media="screen">
<%else%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<%End if%>

<script src="/arxlab/jqfu/js/jquery-1.10.2.js?<%=jsRev%>"></script>
<style type="text/css">@import url(<%=mainAppPath%>/js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>
<script type="text/javascript" src="/arxlab/js/getFile2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/promisePolyfill.min.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<%
'qqq
'selectAutoComplete = "onFocus='ml_autocomplete.populate(event)' onKeyDown='ml_autocomplete.setSelection(event)' onkeypress='return ml_autocomplete.cancel(event)'"
%>
<script type="text/javascript">
hasMarvin = <%=LCase(CStr(session("useMarvin")))%>

function submitRegForm()
{
	return new Promise(function(resolve, reject) {
		var promises = [];
		promises.push(saveMultis());
		<%If hasStructure Then%>
		promises.push(setCdxmlData());
		<%End If%>
		
		if (typeof numSalts != 'undefined'){
			document.getElementById('lastSaltNumber').value = numSalts;
		}else{
			document.getElementById('lastSaltNumber').value = "";
		}
		Promise.all(promises).then(function() {
			resolve(true);
		});
	});
}

function setCdxmlData()
{
	return new Promise(function(resolve, reject) {
		getChemistryEditorChemicalStructure("addStructureCDX",false,"mol:V3").then(function(editorData){
			var pageCdxmlData = document.getElementById('addStructureCdxmlData').value;
			if(pageCdxmlData == ""){
			document.getElementById('addStructureCdxmlData').value = editorData;
			}
			resolve(true);
		});
	});
	
}
<%if request.Form("addStructureSubmit") = "" or validSalts = 0 then%>
	var numSalts = 1
<%else%>
	<%if lastSaltNumber <> "" then%>
		var numSalts = <%=lastSaltNumber%>
	<%end if%>	
<%end if%>


function addNewSalts()
{

		var newHTML = getFile("getNewSalt.asp?saltNumber="+(numSalts+1)+"&random="+Math.random())
		
		newDiv = document.createElement("div")
		newDiv.setAttribute('id',"salt_"+(numSalts+1)+"_container")
		newDiv.innerHTML = newHTML;
		document.getElementById("salt_"+numSalts+"_container").parentNode.insertBefore(newDiv,document.getElementById("salt_"+numSalts+"_container").nextSibling);
        document.getElementById("salt_"+(numSalts+1)+"_container").className += ' saltItemContainer';
		numSalts++;
}

</script>

<script type="text/javascript">
	function unrequireFields(fields)
	{
		for (i=0;i<fields.length ;i++ )
		{
			document.getElementById("label_required_"+fields[i]).style.display="none"
		}
	}
	function rerequireFields(fields)
	{
		for (i=0;i<fields.length ;i++ )
		{
			document.getElementById("label_required_"+fields[i]).style.display="inline"
		}
	}
</script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->

<%If inframe then%>
</head>
<body>
<%End if%>
<script type="text/javascript">
var lastLinkFieldId = ""
function showSearchPopup(){
	//show transparent black div that covers page.  frame is there to help with pesky elements that ignore z-index
	document.getElementById("searchFrame").src = document.getElementById("searchFrame").src;
	document.getElementById("blackDiv").style.position = "fixed"
	document.getElementById("blackDiv").style.height = document.body.clientHeight+"px";
	document.getElementById("blackDiv").style.display = "block";

	//not used
	divH = 340
	divW = 340

	//document.getElementById(popupId).style.height=document.getElementById(popupId).parentNode.parentNode.parentNode.offsetHeight+"px";

	t = ((document.documentElement.offsetHeight) / 2 - (divH/2))
	l = (document.documentElement.clientWidth) / 2 - (divW/2)

	//show popup
	document.getElementById("chemDrawWin").style.visibility = "hidden";
	document.getElementById("regSearchPopup").style.display = "block";
	document.getElementById("searchFrame").style.height="800px";
}
function hideSearchPopup(){
	document.getElementById("blackDiv").style.display="none";
	document.getElementById("regSearchPopup").style.display = "none";
	document.getElementById("chemDrawWin").style.visibility = "visible";
}
function regSelectLink(id){
	hideSearchPopup();
	var useShowReg = true;
	var batchSeparatorPos = id.lastIndexOf("<%=regBatchNumberDelimiter%>");
	if(batchSeparatorPos > 0 && (id.length - (batchSeparatorPos + 1) == <%=regBatchNumberLength%>)) {
		useShowReg = false;
	}
	
	if(useShowReg){
		regNumber = id.substr(0,batchSeparatorPos);
		scriptName = "showReg.asp";
	}else{
		regNumber = id;
		scriptName = "showBatch.asp";
	}
	document.getElementById(lastLinkFieldId).value = regNumber;
	theA = document.createElement("a");
	theImg = document.createElement("img");
	theImg.src = "<%=mainAppPath%>/images/link_arrow.gif";
	theImg.setAttribute("title","Link");
	theImg.setAttribute("border","0");
	theImg.style.border="none";
	theA.appendChild(theImg);
	theA.href = scriptName+"?regNumber="+regNumber;
	theA.style.marginLeft="5px";
	document.getElementById(lastLinkFieldId+"_s").parentNode.insertBefore(theA,document.getElementById(lastLinkFieldId+"_s"));
}

//
//
//
function clearBatchFields() {
	$('input[type="text"]').val('');
	$('textarea').val('');
	$('#addStructureForm select').prop("selectedIndex", 0)
	function resetFormElement(e) {
		e.wrap('<form>').closest('form').get(0).reset();
		e.unwrap();
		e.stopPropagation();
		e.preventDefault();
	}
	$('#addStructureForm input[type="file"]').each(function(){
		resetFormElement($(this));
	})
}
</script>
<div class="registrationPage sideBySideFields">
<div style="margin-left:-50px;width:920px;background-color:white;border:0px solid black;border-top:20px solid black;display:none;position:absolute;top:0;left:0px;z-index:101;" id="regSearchPopup" class="popupDiv">
<a href="javascript:void(0)" onClick="hideSearchPopup();return false;" style="position:absolute;right:0;top:0;margin-top:-19px;"><img border="0" width="18" height="18" src="<%=mainAppPath%>/images/close-x.gif" style="border:none;"></a>
<iframe id="searchFrame" style="border:none;" width="920" height="800" src="search.asp?inframe=true&fieldsToShow=<%=fieldsToShow%>"></iframe>
</div>
<%If Not inframe then%>
<h1><%=registerLabel%></h1>
<%End if%>

<%If regError And request.Form("fromAddBatchButton")="" then%>
<div class="regErrorDiv">
<%If addBatch And Not moleculeAdded then%>
	<%If request.Form("addBatch") <> "1" Or overrideRegError then%>
		<input type="hidden" name="firstError" id="firstError" value="<%=errorText%>">
	<%else%>
		<%=request.Form("firstError")%>
		<input type="hidden" name="firstError" id="firstError" value="<%=request.Form("firstError")%>">
	<%End if%>
<%End if%>
	<%=errorText%>
</div>
<%End if%>
<%If invErrorText <> "" then%>
<div class="regErrorDiv">
	<%=invErrorText%>
</div>
<%End if%>

<%If Not addBatch And Not moleculeAdded then%>
	<%
	If Not fromReg then
		call getconnectedJchemReg
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM groupCustomFields WHERE visible<>0"
		If session("regRestrictedGroups") <> "" Then
			strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
		End If
		strQuery = strQUery & " ORDER BY name ASC"
		rec.open strQuery,jchemRegConn,3,3
		wasBlank = False
		If Not rec.eof Then
			%>
			<div>
			<label class="control_label" for="whichGroup">Field Group</label>
			<div> 
			<select class="reg_dropdown" id="whichGroup" name="whichGroup" onchange="window.location='addStructure.asp?fromReg=<%=request.querystring("fromReg")%>&numObjects=<%=request.querystring("numObjects")%>&autoFillFields=<%=server.urlencode(request.querystring("autoFillFields"))%>&inFrame=<%=request.querystring("inFrame")%>&sourceId=<%=sourceId%>&groupId='+this.options[this.selectedIndex].value+'&isBio=<%=request.querystring("isBio")%>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=revisionNumber%>&regExperimentName=<%=regExperimentName%>&regFieldId=<%=regFieldId%>';">
				<%If not hideSmallMolecule then%><option value="0">Small Molecule</option><%End if%>
			<%
		Else
			wasBlank = true
		End if
		Do While Not rec.eof
			%>
			<option value="<%=rec("id")%>" <%If CStr(groupId)=CStr(rec("id")) then%>SELECTED<%End if%>><%=rec("name")%></option>
			<%
			rec.movenext
		Loop
		If Not wasBlank Then
			%></select></div></div><%
		End if
		rec.close
		Set rec = nothing
	End if
	%>
<%End if%>

<%If regHasTemplate then%>
<div id="regTemplateHolder"></div>
<%End if%>

<div id="addStructureContainer" style="<%If Not inframe then%>width:805px;<%End if%><%If regHasTemplate And session("companyId")="1" then%>display:none;<%End if%>">

<div class="objectBox" >
<%
chemDrawWinStyle = ""
If addBatch Or moleculeAdded Or Not hasStructure Then
	chemDrawWinStyle = "display:none;"		
Else
	If inFrame Then
		chemDrawWinStyle = "width:340px;"
	Else
		chemDrawWinStyle = "width:800px;"
	End If
End if
%>
<div id="chemDrawWin" class="chemDrawWin" style="<%=chemDrawWinStyle%>">
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<div id="addStructureAspChemBox">
</div>
<script type="text/javascript">
<%If session("useChemDrawForLiveEdit") Then%>
	useChemDrawForLiveEdit = true;
<%End If%>

var initialMolData = "";
<%If (request.Form("addStructureSubmit") = "" And inFrame) Or moleculeAdded then%>
	<%if molData <> "" then%>
		initialMolData = "<%=replace(aspJsonStringify(molData), "&quot;", "\""")%>";
	<%else%>
		try { initialMolData = window.parent.document.getElementById('<%=regPrefix%>_molData').value; } catch(e) { }
	<%end if%>
<%end if%>
<%If (request.Form("addStructureSubmit") <> "" And (regError Or request.Form("addBatch")="1")) Or moleculeAdded then%>
<%If Len(origMol) > 0 Then%>
	initialMolData = "<%=replace(aspJsonStringify(origMol), "&quot;", "\""")%>";
<%End If%>
<%End If%>
<%If addBatch or moleculeAdded Or Not hasStructure then%>
var readOnly = true;
<%else%>
var readOnly = false;
<%End If%>

var hasMarvin = <%=LCase(CStr(session("useMarvin")))%>

<%If Not inFrame then%>
    getChemistryEditorMarkup("addStructureCDX", "", initialMolData, 800, 300, readOnly).then(function (theHtml) {
        $("#addStructureAspChemBox").html(theHtml);
    });
<%else%>
    getChemistryEditorMarkup("addStructureCDX", "", initialMolData, 340, 300, true).then(function (theHtml) {
        $("#addStructureAspChemBox").html(theHtml);
    });
<%end if%>

function decodeHtml(html) {
    var txt = document.createElement("textarea");
    txt.innerHTML = html;
    return txt.value;
}

</script>
</div>
</div>
<br>
<%If moleculeAdded then
	Set bRec = server.CreateObject("ADODB.RecordSet")
	filterQuery = "groupId="&SQLClean(groupId,"N","S")
	If groupId = 0 Or groupId = "0" Then
		filterQuery = "(groupId is null or " & filterQuery & ")"
	End If
	strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE just_reg="&SQLClean(regNumber,"T","S") & " AND just_batch="&SQLClean(compoundBatchNumber,"T","S")&" and "&filterQuery
	bRec.open strQuery,jchemRegConn,3,3
	If Not bRec.eof Then
		parentCdId = bRec("cd_id")
	Else

	End If
%>
<div class="regSuccessDiv">
	<%If Not hideVirtualCompounds then%>
	<%=moleculeAddedText%>: <%=wholeRegNumberLink%>
	<%else%>
		<%If moleculeAdded And Not addBatch then%>
			Please Wait
		<%else%>
			<%=moleculeAddedText%>: <%=wholeRegNumberLink%>
		<%End if%>
	<%End if%>
</div>
<%End if%>
<%'qqq change all to molfile%>
<form action="addStructure.asp?fromReg=<%=request.querystring("fromReg")%>&numObjects=<%=request.querystring("numObjects")%>&autoFillFields=<%=server.urlencode(request.querystring("autoFillFields"))%>&inFrame=<%=request.querystring("inFrame")%>&sourceId=<%=sourceId%>&groupId=<%=groupId%>&isBio=<%=request.querystring("isBio")%>" method="post" id="addStructureForm">
<input type="hidden" name="addStructureSubmit" id="addStructureSubmit" value="0">

<%Call getconnectedJchemReg%>
<div <%If moleculeAdded then%>style="display:none;"<%End if%> class="regInfoDiv" <%If Not inFrame then%>style="width:800px;"<%End if%>>

<div id="fieldsDiv">
<div id="insideFieldsDiv">
<%
Set rec = server.CreateObject("ADODB.RecordSet")
If Not addBatch then
	If isGroup Then
		strQuery = "SELECT * FROM groupCustomFieldFields WHERE (showCompound=1 or requireCompound=1) and groupId="&SQLClean(groupId,"N","S")
	else
		strQuery = "SELECT * FROM customFields WHERE showCompoundInput=1 or requireCompound=1"
	End if
Else
	If isGroup Then
		strQuery = "SELECT * FROM groupCustomFieldFields WHERE (showBatchInput=1 or requireBatch=1) and groupId="&SQLClean(groupId,"N","S")
	else
		strQuery = "SELECT * FROM customFields WHERE showBatchInput=1 or requireBatch=1"
	End if
End If
If hasRegSorting Then
	strQuery = strQuery & " ORDER BY sortOrder ASC, id ASC"
Else
	strQuery = strQuery & " ORDER BY id ASC"
End if
rec.open strQuery,jchemRegConn,3,3
Do While Not rec.eof
	if rec("dataType") <> "read_only" then
		%><div><%
		If rec("dataType") = "long_text" Then
			extraCss = "vertical-align:top;"
		End if
	%>
		<label class="control_label<%If rec("dataType")="long_text" then%> control_label_textarea<%End if%>" for="<%=rec("formName")%>" <%If InStr(errorFields,rec("formName")) >0 And request.Form("fromAddBatchButton")="" then%> style="color:red;<%=extraCss%>"<%else%>style="<%=extraCss%>"<%End if%>><%=rec("displayName")%><%If addBatch then%><%If rec("requireBatch") =1 then%><span style="font-size:20px;<%If (hasNeedsPurificationWorkflow) And needsPurification then%>display:none;<%End if%>" id="label_required_<%=LCase(rec("formName"))%>"><span style="font-size:20px;">*</span></span><%End if%><%else%><%If rec("requireCompound") = 1 then%><span style="font-size:17px;<%=extraCss%>">*</span><%End if%><%End if%></label>
		<%Select Case rec("dataType")%>
		<%Case "drop_down"%>
		<div>
		<select class="reg_dropdown" name="<%=rec("formName")%>" id="<%=rec("formName")%>" <%If LCase(rec("formName")) = "needs_purification" And (hasNeedsPurificationWorkflow) then%> onChange="if(this.options[this.selectedIndex].value.toLowerCase() == 'true'){unrequireFields(['amount__mg_','bar_code'])}else{rerequireFields(['amount__mg_','bar_code'])}"<%End if%>>
		<option value="-1">--NONE--</option>
		<%If CInt(rec("dropDownId")) <> -99 then%>
			<%
			inAff = False
			For Each key In aff.keys()
				If key = rec("formName") Then
					inAff = True
				End if
			next
			If inAff And request.Form("addStructureSubmit") = "" Then
				selectedVal = aff.Get(rec("formName"))
			Else
				selectedVal = trimWhiteSpace(request.Form(rec("formName")))
			End If
			
			If request.Form("addStructureSubmit") = "" Or (isMatch And addBatch) Then
				regDefaultToSmallMolecule = checkBoolSettingForCompany("defaultToSmallMoleculesForRegistration", session("companyId"))
				If regDefaultToSmallMolecule And rec("formName") = "Compound_Type" And selectedVal="" Then
					selectedVal = "Small Molecule"
				End if
			End If

			Set rec2 = server.CreateObject("ADODB.recordSet")
			strQuery = "SELECT * FROM regDropDownOptions WHERE parentId="&SQLClean(rec("dropDownId"),"N","S")&" ORDER BY value"
			rec2.open strQuery,jchemRegConn,3,3
			Do While Not rec2.eof
				%>
				<option value="<%=rec2("value")%>" <%If selectedVal=rec2("value") then%>SELECTED<%End if%>><%=rec2("value")%></option>
				<%
				rec2.movenext
			Loop
			rec2.close
			Set rec2 = nothing
			%>
		<%else%>
			<%
				usersTable = getDefaultSingleAppConfigSetting("usersTable")
				Set rec2 = Server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM "&usersTable&" WHERE enabled=1 and companyId="&session("companyId")&" ORDER BY firstName"
				rec2.open strQuery,conn,3,3
				Do While Not rec2.eof
					If request.Form("addStructureSubmit") = "" Or (isMatch And addBatch) Then
						selectedVal = session("firstName")&" "&session("lastName")
					Else
						selectedVal = trimWhiteSpace(request.Form(rec("formName")))
					End If
					%>
						<option value="<%=rec2("firstName")&" "&rec2("lastName")%>" <%If selectedVal =rec2("firstName")&" " &rec2("lastName") then%> SELECTED<%End if%>><%=rec2("firstName")%>&nbsp;<%=rec2("lastName")%></option>
					<%
					rec2.movenext
				loop
			%>
		<%End if%>
		</select>
		</div>
		<%Case else%>
		<%If rec("isLink")=1 then%>
			<%
			inAff = False
			For Each key In aff.keys()
				If key = rec("formName") Then
					inAff = True
				End if
			next
			If inAff And request.Form("addStructureSubmit") = "" Then
				thisVal = aff.Get(rec("formName"))
			Else
				thisVal = trimWhiteSpace(request.Form(rec("formName")))
			End if
			%>
			<div>
			<input type="text" name="<%=rec("formName")%>" id="<%=rec("formName")%>" value="<%=thisVal%>" onclick="lastLinkFieldId=this.id;showSearchPopup();"><span id="<%=rec("formName")%>_s"></span>
			</div>
		<%else%>
			<%If rec("dataType")="long_text" then%>
				<div>
				<%
				value = trimWhiteSpace(request.Form(rec("formName")))
				%>
				<textarea class="reg_textarea" name="<%=rec("formName")%>" id="<%=rec("formName")%>" style="display:inline;width:300px;height:300px;"><%=value%></textarea>
				</div>
			<%else%>
				<%If rec("dataType")="file" then%>
					<div>
					<input type="hidden" name="<%=rec("formName")%>" id="<%=rec("formName")%>" value="<%=trimWhiteSpace(request.Form(rec("formName")))%>">
					<span id="<%=rec("formName")%>_fn">
					<%
					id = trimWhiteSpace(request.Form(rec("formName")))
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
					<%If inframe then%>
						<br/>
					<%End if%>
					<a href="<%If id="" then%>javascript:void(0);<%else%>getSourceFile.asp?id=<%=id%><%End if%>" id="<%=rec("formName")%>_download_button" class="littleButton" style="float:none;width:80px;display:inline;margin-left:10px;<%If id="" then%>display:none;<%End if%>">Download</a>

					<div id="<%=rec("formName")%>_img_holder" style="margin-left:15px;<%If id="" Or not canDisplayInBrowser(filename) then%>display:none;<%End if%>">
					<a href="javascript:void(0);" onclick="document.getElementById('<%=rec("formName")%>_img').style.display='block';document.getElementById('<%=rec("formName")%>_img_show').style.display='none';document.getElementById('<%=rec("formName")%>_img_hide').style.display='inline';" <%If id="" then%>style="display:none;"<%End if%> id="<%=rec("formName")%>_img_show">Show Image</a>
					<a href="javascript:void(0);" onclick="document.getElementById('<%=rec("formName")%>_img').style.display='none';document.getElementById('<%=rec("formName")%>_img_hide').style.display='none';document.getElementById('<%=rec("formName")%>_img_show').style.display='inline';" id="<%=rec("formName")%>_img_hide" <%If id<>"" then%>style="display:none;"<%End if%>>Hide Image</a>
					<img src="<%If id="" then%>javascript:false<%else%>getImage.asp?id=<%=id%><%End if%>" style="<%If inframe then%>width:200px;<%else%>width:800px;<%End if%>display:none;" id="<%=rec("formName")%>_img"/>
					</div>
					<iframe id="<%=rec("formName")%>_frame" name="<%=rec("formName")%>_frame" style="border:none;height:35px;width:300px;margin-left:15px;display:block;" src="upload-file_frame.asp?formName=<%=rec("formName")%>" scrolling="no"></iframe>
					</div>
				<%else%>
					<div>
						<%If rec("dataType")="date" then%>
							<%
								inAff = False
								For Each key In aff.keys()
									If key = rec("formName") Then
										inAff = True
									End if
								next
								If inAff And request.Form("addStructureSubmit") = "" Then
									thisVal = aff.Get(rec("formName"))
								Else
									thisVal = trimWhiteSpace(request.Form(rec("formName")))
								End if
							%>
							<input name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="text" value="<%=thisVal%>">
							<script type="text/javascript">
							//ifFormat    : "%m/%d/%Y %l:%M:%S %p",    // the date format
							Calendar.setup(
								{
								inputField  : "<%=rec("formName")%>",         // ID of the input field
								ifFormat    : "%m/%d/%Y",    // the date format
								showsTime   : true,
								timeFormat  : "12",
								electric    : false
								}
							);
							</script>
						<%else%>
							<%
							inAff = False
							For Each key In aff.keys()
								If key = rec("formName") Then
									inAff = True
								End if
							next
							If inAff And request.Form("addStructureSubmit") = "" Then
								thisVal = Replace(aff.Get(rec("formName")),"""","&quot;")
							Else
								thisVal = Replace(trimWhiteSpace(request.Form(rec("formName"))),"""","&quot;")
							End if
							%>
							<%If rec("dataType")="multi_int" or rec("dataType")="multi_float" Or rec("dataType")="multi_text" then%>
								<div class="multiHolder" id="<%=rec("formName")%>_holder">
									<input type="hidden" name="<%=rec("formName")%>" id="<%=rec("formName")%>" value="<%=thisVal%>">
								</div>
							<%else%>
								<input type="text" name="<%=rec("formName")%>" id="<%=rec("formName")%>" value="<%=thisVal%>">
							<%End if%>
						<%End if%>
					</div>
				<%End if%>
			<%End if%>
		<%End if%>
		<%End select%>
	</div><!--end div for field wrap-->
	<%
	end if
	rec.movenext
Loop
rec.close
Set rec = nothing
%>
<%
If Not addBatch And Not moleculeAdded Then
%>
	<%'5115 remove for H3%>
	<%If projectFieldInReg then%>
	<div>
	<%'//REG-371 Disable checking for project link%>
	<label class="control_label" for="linkProjectId">Project</label>
	<div><!-- #include file="../_inclds/selects/writeProjects.asp"--></div>
	</div>
	<%End if%>
<%
End if
%>
</div>
</div>
</div>

<%
If addBatch And hasIdFields Then
	'keep values for uniqueness without structure
	Set rec = server.CreateObject("ADODB.Recordset")
	If isGroup then
		strQuery = "SELECT * FROM groupCustomFieldFields WHERE (isIdentity=1) and groupId="&SQLClean(groupId,"N","S")
	Else
		strQuery = "SELECT * FROM customFields WHERE (isIdentity=1)"
	End If
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		If LCase(rec("formName")) <> "stereochemistry" then
			%>
			<input type="hidden" name="<%=rec("formName")%>" id="<%=rec("formName")%>" value="<%=trimWhiteSpace(request.Form(rec("formName")))%>">
			<%
		End if
		rec.movenext
	Loop
	rec.close
	Set rec = nothing
End if
%>
<input type="hidden" name="addStructureCdxmlData" id="addStructureCdxmlData" value="<%=Server.HTMLEncode(replace(origMol, """", "&quot;"))%>">
<input type="hidden" name="experimentId" id="experimentId" value="<%=experimentId%>">
<input type="hidden" name="experimentType" id="experimentType" value="<%=experimentType%>">
<input type="hidden" name="revisionNumber" id="revisionNumber" value="<%=revisionNumber%>">
<input type="hidden" name="regMolData" id="regMolData" value="<%=Server.HTMLEncode(replace(molData, """", "&quot;"))%>">
<input type="hidden" name="regName" id="regName" value="<%=regName%>">
<input type="hidden" name="regExperimentName" id="regExperimentName" value="<%=regExperimentName%>">
<input type="hidden" name="regAmount" id="regAmount" value="<%=regAmount%>">
<input type="hidden" name="regFieldId" id="regFieldId" value="<%=regFieldId%>">
<%
getAmountFieldFromReg = checkBoolSettingForCompany("populateAmountFieldUsingRegistration", session("companyId"))
If getAmountFieldFromReg Then
%>
<script type="text/javascript">
	window.onload =function(){
		v = document.getElementById("regAmount").value;
		amt = v.split(" ")[0];
		amtUnits = v.split(" ")[1];
		if(document.getElementById("Amount")){
			document.getElementById("Amount").value = amt;
			s = document.getElementById("Amount_Units");
			for(var i=0;i<s.options.length;i++){
				if(s.options[i].value.toLowerCase()==amtUnits.toLowerCase()){
					s.selectedIndex = i;
				}
			}
		}
	}
</script>
<%End if%>

<%If useSalts then%>
<div id="saltsDiv" <%If ((addBatch) and regSaltSearchMode <> "OFF" Or (Not addBatch And regSaltSearchMode="OFF")) Or moleculeAdded then%>style="display:none;"<%End if%>>

<a href="javascript:void(0);" onClick="addNewSalts()" class="newSalt" style="background-color: #1eb242;color:white; ">ADD SALT+</a>
	<div class="multiSaltDiv">
		<%If request.Form("addStructureSubmit") = "" Or validSalts = 0 then%>
		<div id="salt_1_container">
		<label for="salt_1_cdId">Salt</label>
		<select id="salt_1_cdId" name="salt_1_cdId" <%=selectAutoComplete%>>
		<option value="0">--- NONE ---</option>
		<%
		call getconnectedJchemReg
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cd_id,name FROM "&regSaltsTable& " WHERE 1=1 ORDER BY upper(name) ASC"
		'rec.open strQuery,jchemRegConn,0,1
		Set rec = jChemRegConn.execute(strQuery)
		Do While Not rec.eof
		%>
			<option value="<%=rec("cd_id")%>"><%=rec("name")%></option>
		<%
			rec.movenext
		Loop
		rec.close
		Set rec = nothing
		Call disconnectJchemReg
		%>
		</select>
		<label for="salt_1_multiplicity">Multiplicity</label>
		<input type="text" name="salt_1_multiplicity" id="salt_1_multiplicity" class="multiplicVal" value="1.0">
		</div>
		<%Else%>

			<%
			numStrippedSalts = 0
			salts = Split(smilesWithSalts,".")
			For i = 0 To UBound(salts)
				If salts(i) <> "" then
					Set sRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT cd_id FROM "&regSaltsTable&" WHERE cd_smiles="&SQLClean(salts(i),"T","S")
					sRec.open strQuery,jchemRegConn,3,3
					If Not sRec.eof Then
						multiplicity = 1
						For j = i+1 To UBound(salts)
							If salts(i) = salts(j) Then
								salts(j) = ""
								multiplicity = multiplicity + 1
							End if
						Next
						k = numStrippedSalts + 1
						%>
							<div id="salt_<%=k%>_container">
							<label for="salt_<%=k%>_cdId">Saltss</label>
							<select id="salt_<%=k%>_cdId" name="salt_<%=k%>_cdId" autocomplete="off">
							<option value="0">--- NONE ---</option>
							<%
							call getconnectedJchemReg
							Set rec = server.CreateObject("ADODB.RecordSet")
							strQuery = "SELECT cd_id,name,multiplicity FROM "&regSaltsTable& " WHERE 1=1 ORDER BY upper(name) ASC"
							rec.open strQuery,jchemRegConn,3,3
							Do While Not rec.eof
							%>
								<option value="<%=rec("cd_id")%>" <%If CStr(sRec("cd_id")) = CStr(rec("cd_id")) then%> SELECTED<%End if%>><%=rec("name")%></option>
							<%
								rec.movenext
							Loop
							rec.close
							Set rec = nothing
							Call disconnectJchemReg
							%>
							</select>
							<label for="salt_<%=k%>_multiplicity">Multiplicity</label>
							<input type="text" name="salt_<%=k%>_multiplicity" class="multiplicVal" id="salt_<%=k%>_multiplicity" value="<%=multiplicity%>">
							</div>
						<%
						salts(i) = ""
						numStrippedSalts = numStrippedSalts + 1
					End If
					sRec.close
					Set sRec = Nothing
				End if
			next
			%>
			<%For i = 1+numStrippedSalts To lastSaltNumber+numStrippedSalts%>
				<%If request.Form("salt_"&i&"_cdId") <> "0" And request.Form("salt_"&i&"_cdId") <> "" then%>
					<div id="salt_<%=i%>_container">
					<label for="salt_<%=i%>_cdId">Salt</label>
					<select id="salt_<%=i%>_cdId" name="salt_<%=i%>_cdId" <%=selectAutoComplete%>>
					<option value="0">--- NONE ---</option>
					<%
					call getconnectedJchemReg
					Set rec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT cd_id,name,multiplicity FROM "&regSaltsTable& " WHERE 1=1 ORDER BY upper(name) ASC"
					rec.open strQuery,jchemRegConn,3,3
					Do While Not rec.eof
					%>
						<option value="<%=rec("cd_id")%>" <%If CStr(request.Form("salt_"&i&"_cdId")) = CStr(rec("cd_id")) then%> SELECTED<%End if%>><%=rec("name")%></option>
					<%
						rec.movenext
					Loop
					rec.close
					Set rec = nothing
					Call disconnectJchemReg
					%>
					</select>
					<label for="salt_<%=i%>_multiplicity">Multiplicity</label>
					<input type="text" name="salt_<%=i%>_multiplicity" class="multiplicVal" id="salt_<%=i%>_multiplicity" value="<%=request.Form("salt_"&i&"_multiplicity")%>">
					</div>
				<%End if%>
			<%next%>
		<%End if%>
	</div>
</div>
<%End if%>
</div>
<div id="regAddBatchDiv">
<%If addBatch then%>
	<%If Not moleculeAdded then%>
		<input type="hidden" name="addBatch" id="addBatch" value="1">
		<input type="hidden" name="Stereochemistry" id="Stereochemistry" value="<%=request.Form("StereoChemistry")%>">
		<input type="hidden" name="addStructureSubmitButton" id="addStructureSubmitButton" value="SAVE">
		<input type="button" name="addStructureSubmitSave" id="addStructureSubmitSave" value="SAVE">
		<script type="text/javascript">
			$("#addStructureSubmitSave").click(function() {
					document.getElementById("addStructureSubmitSave").disabled=true;
					document.getElementById("addStructureSubmitSave").value="WAIT";
					document.getElementById("addStructureSubmit").value = "1";
					
					submitRegForm().then(function() {
						$("#addStructureForm").submit()
				});
			});
		</script>
		<%If inFrame then%>
			<input type="button" onClick="window.parent.hidePopup('regDiv');window.location='<%=mainAppPath%>/static/blank.html'" value="CANCEL">
			<script type="text/javascript">
				// Need to clear the pre-filled batch information because it's identical to the previous batch's info. Would prefer to clear it server-side but there's no good way to predict what is & isn't required for any given batch submission
				clearBatchFields();
			</script>
		<%else%>
			<input type="button" onClick="window.location.href=window.location.href" value="CANCEL">
			<script type="text/javascript">
				// Need to clear the pre-filled batch information because it's identical to the previous batch's info. Would prefer to clear it server-side but there's no good way to predict what is & isn't required for any given batch submission
				clearBatchFields();
			</script>
		<%End if%>
	<%else%>
		<%If Not inFrame then%>
			<input type="button" id="addAnotherStructureButton" value="<%=addAnotherStructureText%>">
			<script type="text/javascript">
				$("#addAnotherStructureButton").click(function() {
					document.getElementById("addAnotherStructureButton").disabled=true;
					document.getElementById("addAnotherStructureButton").value="WAIT";
					document.getElementById("addStructureSubmit").value = "1";
					window.location.href=window.location.href;
				});
			</script>
			<!--<input type="hidden" name="addBatch" id="addBatch" value="1">-->
			<input type="submit" id="addAnotherBatchButton" name="addAnotherBatchButton" value="<%=addBatchText%>">
			<script type="text/javascript">
				$("#addAnotherBatchButton").click(function() {
					document.getElementById("addAnotherBatchButton").disabled=true;
					document.getElementById("addAnotherBatchButton").value="WAIT";
					document.getElementById("addStructureSubmit").value = "1";
					$("#addStructureForm").submit();
				});
			</script>
		<%else%>
			
			<%If experimentType <> 1 then%>
				<%
				displayRegNumber = wholeRegNumber
				batchZeroPos = InStrRev(displayRegNumber, "-00")
				If batchZeroPos = (Len(displayRegNumber) - 2) Then
					displayRegNumber = Left(displayRegNumber, batchZeroPos - 1)
				End If
				Call getconnectedadm
				strQuery = "INSERT into experimentRegLinks_preSave(experimentId,experimentType,regNumber,displayRegNumber) values("&_
							SQLClean(experimentId,"N","S") & "," &_
							SQLClean(experimentType,"N","S") & "," &_
							SQLClean(wholeRegNumber,"T","S") & "," &_
							SQLClean(displayRegNumber,"T","S") & ")"
				connAdm.execute(strQuery)
				Call disconnectadm		
				%>
				<input type="button" id="addToExperimentButton" onClick="document.getElementById('addToExperimentButton').disabled=true;document.getElementById('addToExperimentButton').value='WAIT';window.parent.unsavedChanges=true;window.parent.getRegLinks();window.parent.hidePopup('regDiv');window.location='<%=mainAppPath%>/static/blank.html'" value="Add to Experiment">
			<%else%>						
				<%If session("hasInv") then%>
					<%If checkBoolSettingForCompany("addToInvAfterRegFromGrid", session("companyId")) then%>
						<input type="button" id="addToInvAfterReg" onClick="window.top.addRegIdToGridAndClose('<%=regFieldId%>', '<%=wholeRegNumber%>', $('#addToExperimentButton')); window.top.addToInvPopup('<%=Split(regFieldId,"_")(0)%>', '<%=wholeRegNumber%>');" value="Add to Inventory">
					<%End if%>
				<%End if%>
				<input type="button" id="addToExperimentButton" onClick="window.top.addRegIdToGridAndClose('<%=regFieldId%>', '<%=wholeRegNumber%>', $('#addToExperimentButton'))" value="Close">			
			<%End if%>
		<%End if%>
	<%End if%>
<%else%>
	<%If Not moleculeAdded then%>
		<input type="hidden" name="addBatch" id="addBatch" value="0">
		<input type="button" name="addStructureSubmitButton" id="addStructureSubmitButton" value="REGISTER">
		<script type="text/javascript">
			$("#addStructureSubmitButton").click(function() {
				document.getElementById("addStructureSubmitButton").disabled=true;
				document.getElementById("addStructureSubmitButton").value="WAIT";
				document.getElementById("addStructureSubmit").value = "1";
				submitRegForm().then(function() {
					$("#addStructureForm").submit()
				});
			});
		</script>
	<%else%>
		<%If Not inFrame then%>
			<%If hideVirtualCompounds then%>
				<input type="hidden" value="notNothing" name="addStructureSubmitNotNothing" id="addStructureSubmitNotNothing">
				<script type="text/javascript">
					$( window ).load(function() {
						document.getElementById("addStructureSubmit").value = "1";
						$("#addStructureForm").submit()
					});
				</script>
			<%else%>
				<input type="button" id="addAnotherStructureButton2" value="<%=addAnotherStructureText%>">
				<script type="text/javascript">
					$("#addAnotherStructureButton2").click(function() {
						document.getElementById("addAnotherStructureButton2").disabled=true;
						document.getElementById("addAnotherStructureButton2").value="WAIT";
						document.getElementById("addStructureSubmit").value = "1";
						window.location.href=window.location.href;
					});
				</script>
				<%If allowBatches then%>
				<input type="submit" name="addStructureSubmitAddBatch" id="addStructureSubmitAddBatch" value="<%=addBatchText%>">
				<script type="text/javascript">
					$("#addStructureSubmitAddBatch").click(function() {
						document.getElementById("addStructureSubmitAddBatch").disabled=true;
						document.getElementById("addStructureSubmitAddBatch").value="WAIT";
						document.getElementById("addStructureSubmit").value = "1";
						$("#addStructureForm").submit();
					});
				</script>
				<%End if%>
			<%End if%>
		<%else%>
			<%If requireBatchForRegIntegration then%>
			<input type="submit" name="addStructureSubmitRegBatch" id="addStructureSubmitRegBatch" value="<%=addBatchText%>">
			<script type="text/javascript">
				$("#addStructureSubmitRegBatch").click(function() {
					document.getElementById("addStructureSubmitRegBatch").disabled=true;
					document.getElementById("addStructureSubmitRegBatch").value="WAIT";
					document.getElementById("addStructureSubmit").value = "1";
					$("#addStructureForm").submit();
				});
			</script>
			<%else%>						
				<%If experimentType <> 1 then%>
					<%
					displayRegNumber = wholeRegNumber
					batchZeroPos = InStrRev(displayRegNumber, "-00")
					If batchZeroPos = (Len(displayRegNumber) - 2) Then
						displayRegNumber = Left(displayRegNumber, batchZeroPos - 1)
					End If
					Call getconnectedadm
					strQuery = "INSERT into experimentRegLinks_preSave(experimentId,experimentType,regNumber,displayRegNumber) values("&_
						SQLClean(experimentId,"N","S") & "," &_
						SQLClean(experimentType,"N","S") & "," &_
						SQLClean(wholeRegNumber,"T","S") & "," &_
						SQLClean(displayRegNumber,"T","S") & ")"
					connAdm.execute(strQuery)
					Call disconnectadm
					%>
					<input type="button" id="addToExperimentButton" onClick="document.getElementById('addToExperimentButton').disabled=true;document.getElementById('addToExperimentButton').value='WAIT';window.parent.unsavedChanges=true;window.parent.getRegLinks();window.parent.hidePopup('regDiv');window.location='<%=mainAppPath%>/static/blank.html'" value="Close">
				<%else%>												
					<%If session("hasInv") then%>
						<%If checkBoolSettingForCompany("addToInvAfterRegFromGrid", session("companyId")) then%>
						<input type="button" id="addToInvAfterReg" onClick="window.top.addRegIdToGridAndClose('<%=regFieldId%>', '<%=wholeRegNumber%>', $('#addToExperimentButton')); window.top.addToInvPopup('<%=Split(regFieldId,"_")(0)%>', '<%=wholeRegNumber%>');" value="Add to Invintory">
						<%End if%>
					<%End if%>
					<input type="button" id="addToExperimentButton" onClick="document.getElementById('addToExperimentButton').disabled=true;document.getElementById('addToExperimentButton').value='WAIT';window.parent.document.getElementById('<%=regFieldId%>').value='<%=wholeRegNumber%>';window.parent.experimentJSON['<%=regFieldId%>'] = '<%=wholeRegNumber%>';window.parent.unsavedChanges=false;	window.parent.experimentSubmit(false,false,false); window.parent.hidePopup('regDiv');" value="Close">
				<%End if%>
			<%End if%>
		<%End if%>		
	<%End if%>
<%End if%>
</div>

<%If moleculeAdded then%>
<input type="hidden" name="moleculeWasAdded" id="moleculeWasAdded" value="1">
<%End if%>
<input type="hidden" name="addBatchCdId" id="addBatchCdId" value="<%=request.Form("addBatchCdId")%>">
<input type="hidden" name="lastSaltNumber" id="lastSaltNumber" value="<%=lastSaltNumber%>">
<input type="hidden" name="fieldGroupNameText" id="fieldGroupNameText" value="">
</form>

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
			document.getElementById('regTemplateHolder').appendChild(div);
			$("#regTemplate [formName]").each(function(i,el){
				targetEl = document.getElementById(el.getAttribute("formname"));
				if(targetEl){
					$(el).append(targetEl);
				}
				//targetEl = $("#"+fd.fid+" > [formName='"+el.getAttribute("formName")+"_error']");
				//if(targetEl){
				//	$(el).append(targetEl);
				//}
			});
			//delayedRunJS(data,fd.fid);
		});
});
</script>
<%End if%>
<script type="text/javascript" src="js/multiText.js?<%=jsRev%>"></script>
<script type="text/javascript">
$(document).ready(function(){
	makeMultis();

<%
	' Calling clearBatchFields is needed here 
	' because the (multi) form field(s) aren't 
	' part of the form until makeMultis is called. 
%>
<%If addBatch and Not moleculeAdded then%>
	clearBatchFields();
<%End if%>	
});
</script>

<%If inframe then%>
</body>
</html>
<%else%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%End if%>