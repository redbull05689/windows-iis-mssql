<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../_inclds/escape_and_filter/functions/fnc_trimWhiteSpace.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
fillRegNumberGaps = checkBoolSettingForCompany("fillRegNumberGaps", session("companyId"))
ignoreRegGroupsWhenNumbering = checkBoolSettingForCompany("ignoreRegGroupsWhenNumbering", session("companyId"))
hideVirtualCompounds = checkBoolSettingForCompany("hideVirtualCompoundsDuringRegistration", session("companyId"))
hideRegIdFromRestrictedUsers = checkBoolSettingForCompany("hideRegIdFromRestrictedUsers", session("companyId"))
regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
regBatchNumberMode = getCompanySpecificSingleAppConfigSetting("regBatchNumberMode", session("companyId"))
regNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regIdDelimiter", session("companyId"))
regNumberLength = getCompanySpecificSingleAppConfigSetting("regIdNumberLength", session("companyId"))
regNumberLength = normalizeIntSetting(regNumberLength)
regNumberPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
regNumberMode = getCompanySpecificSingleAppConfigSetting("regNumberMode", session("companyId"))
regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
startingRegNumber = getCompanySpecificSingleAppConfigSetting("startingRegNumber", session("companyId"))
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))

whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
' This is actually a methane because the REST services don't allow empty structures to be imported
' but we check when we display and when we search and if the config does not contain a structure we ignore it.
noStructureMol = "Untitled Document-1"&vbcrlf&"  ChemDraw08021814242D"&vbcrlf&vbcrlf&"  1  0  0  0  0  0  0  0  0  0999 V2000"&vbcrlf&"    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0"&vbcrlf&"M  END"

Function groupIdHasStructure(groupId)
	groupIdHasStructure = False
	
	If IsNull(groupId) Or groupId = "0" Or groupId = 0 Then
		groupIdHasStructure = True
	Else
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT hasStructure FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
		rec.open strQuery,jchemRegConn,0,-1
		If Not rec.eof then
			If rec("hasStructure") = 1 Or rec("hasStructure") = "1" Then
				groupIdHasStructure = True
			End If
		End if
		rec.close
	End If
End Function

Function getGroupIdsThatHaveStructure
	Set groupIdList = JSON.parse("[]")
	groupIdList.Push(0)
	
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM groupCustomFields WHERE hasStructure=1"
	rec.open strQuery,jchemRegConn,0,-1
	Do While Not rec.eof
		groupIdList.Push(CInt(rec("id")))
		rec.movenext
	Loop
	rec.close
	getGroupIdsThatHaveStructure = JSON.stringify(groupIdList)
End Function

Function makeRegLink(groupPrefix,regNum,batchNum)
	If session("regRestrictedUser") And hideRegIdFromRestrictedUsers Then
		makeRegLink = "<i>Hidden</i>"
	Else
		If groupPrefix = "" Then
			groupPrefix = regNumberPrefix
		End if
		firstPart = groupPrefix
		secondPart = "<a href='"&regPath&"/showReg.asp?regNumber="&firstPart&regNumberDelimiter&regNum&"'>"&regNum&"</a>"
		Dim rec
		Set rec = server.CreateObject("ADODB.RecordSet")
		If batchNum = "" Then
			batchNum = padWithZeros(0,regBatchNumberLength)
		End if
		strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(groupPrefix&regNumberDelimiter&regNum&regBatchNumberDelimiter&batchNum,"T","S")
		rec.open strQuery,jchemRegConn,0,-1
		If Not rec.eof then
			secondPart = secondPart
		End if
		If batchNum <> padWithZeros(0,regBatchNumberLength) And batchNum <> "" Then
			thirdPart = "<a href='"&regPath&"/showBatch.asp?regNumber="&firstPart&regNumberDelimiter&regNum&regBatchNumberDelimiter&batchNum&"'>"&batchNum&"</a>"
		End If
		theLink = firstPart & regNumberDelimiter & secondPart
		If thirdPart <> "" Then
			theLink = theLink & regBatchNumberDelimiter & thirdPart
		End If
		makeRegLink = theLink
	End If
End function


Function getFragmentWithIds(cdxml,theIds)
	a = Split(theIds," ")
	fragment = ""

	Set oXML = Server.CreateObject("MSXML2.DomDocument.4.0")
	oXML.LoadXML(cdxml)
	For Each oNode In oXML.SelectNodes("/CDXML/page")
		For Each subNode In oNode.SelectNodes("*")
			If subNode.nodeName = "fragment" Then
				thisFragmentId = subNode.getAttribute("id")
				foundAll = True
				numNs = subNode.getElementsByTagName("n").length
				For Each subSubNode In subNode.getElementsByTagName("n")
					foundIt = false
					For i = 0 To UBound(a)
						If subSubNode.getAttribute("id") = a(i) Then
							foundIt = true
						End if
					Next
					If Not foundIt Then
						foundAll = false
						Exit for
					End if
				next
				If foundAll And ubound(a) = numNs -1 Then
					getFragmentWithIds = subNode.xml
					Exit function
				End if
			End If
		Next
	Next
End function

Function mixtureToMols(cdxml)
	Set oXML = Server.CreateObject("MSXML2.DomDocument.4.0")
	oXML.LoadXML(cdxml)
	hasGroups = False
	For Each oNode In oXML.SelectNodes("/CDXML/page/bracketedgroup")
		hasGroups = true
		numNodes = oNode.getElementsByTagName("bracketedgroup").length
		Dim molArray
		ReDim molArray(numNodes*2-1)
		counter = 0
		For Each subNode In oNode.SelectNodes("*")
			If subNode.nodeName = "bracketedgroup" Then
				theIds = subNode.getAttribute("BracketedObjectIDs")
				molArray(counter) = getFragmentWithIds(cdxml,theIds)
				molArray(counter + 1) = subNode.getAttribute("RepeatCount")
			End If
			counter = counter + 2
		Next
	Next
	If hasGroups then
		mixtureToMols = molArray
	Else
		mixtureToMols = cdxml
	End if
End function

Function hasMultipleMols(cdxml)
	'QQQ this needs to be changed to 6.0, I think because of iis7
	'Set oXML = Server.CreateObject("MSXML2.DomDocument.6.0")
	Set oXML = Server.CreateObject("MSXML2.DomDocument.6.0")
	oXML.LoadXML(cdxml)
	hasGroups = False
	For Each oNode In oXML.SelectNodes("/CDXML/page/bracketedgroup")
		hasGroups = true
	Next
	If hasGroups then
		hasMultipleMols = true
	Else
		hasMultipleMols = false
	End if
End function

Function addToSaltTable(name,saltType,cdxml,saltCode)
	If IsNull(name) Then
		name = ""
	End If
	If IsNull(saltType) Then
		saltType = ""
	End If
	If IsNull(saltCode) Then
		saltCode = ""
	End If
	
	Select Case sourceId
		Case "1"
			source = "REGISTRATION"
		Case "2"
			source = "ELN"
		Case "3"
			source = "IMPORT"
	End select
	Set params = JSON.parse("{}")
	params.Set "name", CStr(name)
	params.Set "salt_code", CStr(saltCode)
	params.Set "salt_type", CStr(saltType)
	
	resp = CX_addStructure(jChemRegDB,regSaltsTable,cdxml,JSON.stringify(params))
	
	Set respObj = JSON.parse(resp)
	If IsObject(respObj) Then
		If respObj.Exists("cd_id") Then
			theCdId = Abs(respObj.Get("cd_id"))
			addToSaltTable = theCdId
		End If
	End If
End function

Function addToMolTable(parentId,multiplicity,name,userId,adminUserId,sourceId,userName,permanent,molTypeId,cdxml,experimentId,experimentType,revisionNumber,experimentName,dateCreated,customFields,reg_id,regNumber,batchNumber,groupId)
	addToMolTable = -1
	cdxml = getEmptyStructureIfNeeded(cdxml)
	
	Select Case sourceId
		Case "1"
			source = "REGISTRATION"
		Case "2"
			source = "ELN"
		Case "3"
			source = "IMPORT"
	End Select

	Set params = JSON.parse("{}")
	params.Set "name", name
	params.Set "user_id", session("userId")
	params.Set "admin_user_id", 0
	params.Set "source_id", sourceId
	params.Set "user_name", userName
	params.Set "mol_type_id", molTypeId
	params.Set "type_id", experimentType
	params.Set "source", source
	params.Set "experiment_name", experimentName
	params.Set "revision_number", revisionNumber
	params.Set "parent_cd_id", parentId
	params.Set "date_created_sortable", DateDiff("s", "01/01/1970 00:00:00", Now())
	params.Set "multiplicity", multiplicity
	params.Set "experiment_id", experimentId
	params.Set "reg_id", reg_id
	params.Set "just_batch", batchNumber
	params.Set "just_reg", regNumber

	If IsArray(customFields) Then
		For y = 0 To UBound(customFields)
			params.Set CStr(customFields(y,0)), trimWhiteSpace(customFields(y,1))
		next
	End If

	If sourceId = "3" Or (session("autoApproveReg") And Not hideVirtualCompounds) Then
		params.Set "status_id", 1
	End If
	If hideVirtualCompounds Then
		If Replace(batchNumber,"0","") = "" Then
			params.Set "status_id", 0
		Else
			params.Set "status_id", 1
		End if
	End if
	If session("autoApproveReg") Then
		params.Set "is_permanent", 1
	Else
		params.Set "is_permanent", permanent
	End if
	If dateCreated = "" then
		params.Set "date_created", Now()
	Else
		params.Set "date_created", dateCreated
	End if
	
	resp = CX_addStructure(jChemRegDB,regMoleculesTable,cdxml,JSON.stringify(params))

	Set respObj = JSON.parse(resp)
	If IsObject(respObj) Then
		If respObj.Exists("cd_id") Then
			theCdId = Abs(respObj.Get("cd_id"))

			If Not IsNull(groupId) Then
				strQuery = "update "&regMoleculesTable&" set groupId=" & SQLClean(groupId,"N","S") & " WHERE cd_id="&theCdId
				jchemRegConn.execute(strQuery)
			End If
			
			addToMolTable = theCdId
		End If
	End If
End function

Function makeCdxml(cdxml)
	colorTable = "<colortable><color r=""1"" g=""1"" b=""1""/><color r=""0"" g=""0"" b=""0""/><color r=""1"" g=""0"" b=""0""/><color r=""1"" g=""1"" b=""0""/><color r=""0"" g=""1"" b=""0""/><color r=""0"" g=""1"" b=""1""/><color r=""0"" g=""0"" b=""1""/><color r=""1"" g=""0"" b=""1""/></colortable><fonttable><font id=""3"" charset=""iso-8859-1"" name=""Arial""/></fonttable>"

	makeCdxml = "<?xml version=""1.0"" encoding=""UTF-8""?>"&vbcrlf&"<CDXML>"&vbcrlf&colorTable&"<page>"&cdxml&"</page></CDXML>"

End Function

Function padWithZeros(inString,strLen2)
	If Len(inString) < strLen2 Then
		For iwq = Len(inString) To strLen2 - 1
			inString = "0" & inString
		next
	End If
	padWithZeros = inString
End function

Function getNewBatchNumber(groupId,regNumber)
	Dim rec
	If groupId = 0 Then
		groupSQL = "(groupId=0 or groupId is null)"
	Else
		groupSQL = "groupId="&SQLClean(groupId,"N","S")
	End if
	If regBatchNumberMode = "SEQUENTIAL" Then
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cast(just_batch as int) as batchInt from "&regMoleculesTable&" WHERE just_reg=" &SQLClean(regNumber,"T","S")&" AND "&groupSQL&" order by batchInt DESC"
		rec.open strQuery,jchemRegConn,3,3
		If rec.eof Then
			batchNum = "1"
		Else
			If IsNull(rec("batchInt")) Then
				batchNum = "1"	
			Else
				batchNum = CStr(CInt(rec("batchInt"))+1)
			End If
		End If
		rec.close
		Set rec = nothing
	End If
	If regBatchNumberMode = "RANDOM" Then
		break = False
		Do While Not break
			batchNum = padWithZeros(getRandomNumber(regBatchNumberLength),regBatchNumberLength)
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * from "&regMoleculesTable&" WHERE just_batch=" &SQLClean(batchNum,"T","S")&" and just_reg=" &SQLClean(regNumber,"T","S")& " AND "&groupSQL
			rec.open strQuery,jchemRegConn,3,3
			If rec.eof Then
				break = true
			End If
			rec.close
			Set rec = Nothing
		loop
	End if
	getNewBatchNumber = padWithZeros(batchNum,regBatchNumberLength)
End function

Function getRandomNumber(numLen)
	Randomize
	theNum = round((Rnd * ((10 ^ numLen)-1))+1)
	If theNum > 0 Then
		theNum = theNum - 1
	End if
	
	'Get rid of decimals
	numStr = CStr(theNum)
	If InStr(numStr, ".") > 1 Then
		numStr = Mid(numStr, 1, InStr(numStr, ".") - 1)
	End If
	
	getRandomNumber = numStr
End function

Function getNewRegNumber(groupId)
	Dim rec
	If groupId = 0 Then
		groupSQL = "(groupId=0 or groupId is null)"
	Else
		groupSQL = "groupId="&SQLClean(groupId,"N","S")
	End If
	'hack to keep numbers all part of the same sequence
	If regNumberMode = "SEQUENTIAL" Then
		Set rec = server.CreateObject("ADODB.RecordSet")
		If fillRegNumberGaps Then
			strQuery = "select top 1 l.regNo - 1 as regInt " &_
					   "from ( " &_
					   "SELECT TOP 9999 ones.n + 10*tens.n + 100*hundreds.n + 1000*thousands.n as regNo " &_
					   "FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9)) ones(n), " &_
							"(VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) tens(n), " &_
							"(VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) hundreds(n), " &_
							"(VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) thousands(n) " &_
					   "ORDER BY 1) as l " &_
					   "left outer join (select distinct cast(just_reg as int) as regNo from " & regMoleculesTable & ") as r on l.regNo = r.regNo " &_
					   "where r.regNo is null"
		Elseif IgnoreRegGroupsWhenNumbering then
			strQuery = "SELECT TOP 1 cast(just_reg as int) as regInt from "&regMoleculesTable&" WHERE just_batch="&SQLClean(padWithZeros(0,regBatchNumberLength),"T","S")&" order by regInt DESC"
		else
			strQuery = "SELECT TOP 1 cast(just_reg as int) as regInt from "&regMoleculesTable&" WHERE just_batch="&SQLClean(padWithZeros(0,regBatchNumberLength),"T","S")&" AND "&groupSQL&" order by regInt DESC"
		End If
		
		rec.open strQuery,jchemRegConn,3,3
		If rec.eof Then
			regNum = startingRegNumber
		Else
			If IsNull(rec("regInt")) Then
				regNum = startingRegNumber	
			Else
				regNum = CStr(CLng(rec("regInt"))+1)
			End If
		End If
		rec.close
		Set rec = nothing
	End If
	If regNumberMode = "RANDOM" Then
		break = False
		Do While Not break
			regNum = padWithZeros(getRandomNumber(regNumberLength),regNumberLength)
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * from "&regMoleculesTable&" WHERE just_reg=" &SQLClean(regNum,"T","S")&" AND "&groupSQL
			rec.open strQuery,jchemRegConn,3,3
			If rec.eof Then
				break = true
			End If
			rec.close
			Set rec = Nothing
		loop
	End If
	getNewRegNumber = padWithZeros(regNum,regNumberLength)
End function

Function setChiralFlag(molData,flag)
	setChiralFlag = molData
	
	lines = split(molData,vbcrlf)
	If UBound(lines) = 0 Then
		lines = split(molData,vblf)
	End If
	If UBound(lines) = 0 Then
		lines = split(molData,vbcr)
	End If

	countLine = lines(5)
	startNewCountLine = Mid(countLine,1,Len(countLine)-1)
	If flag then
		lines(5) = startNewCountLine & "  1"
	Else
		lines(5) = startNewCountLine & "  0"
	End if
	setChiralFlag = Join(lines,vbcrlf)
End function

Function analyzeInputMol(theIncomingMol)
	theIncomingMol = HTMLDecode(theIncomingMol)
	myInputMolFormat = getFileFormat(theIncomingMol)
	
	Set retVal = JSON.Parse("{}")
	retVal.Set "structure", aspJsonStringify(theIncomingMol)
	retVal.Set "molFormat", myInputMolFormat
	analyzeInputMol = JSON.stringify(retVal)
End Function

' Uses Regexs to determine the chem data file type
function getFileFormat(fileData)
    fileType = ""
    
    ' Set up a ton of regexes, one for each case.
    set mrvRegExp = new RegExp
    mrvRegExp.global = true
    mrvRegExp.pattern = "^<cml>"
    set rxnRegExp = new RegExp
    rxnRegExp.global = true
    rxnRegExp.pattern = "\$RXN"
    set molRegExp = new RegExp
    molRegExp.global = true
    molRegExp.pattern = "\$MOL"
    set mrv2RegExp = new RegExp
    mrv2RegExp.global = true
    mrv2RegExp.pattern = "ChemAxon file format v\d\d"
    set rxnv3RegExp = new RegExp
    rxnv3RegExp.global = true
    rxnv3RegExp.pattern = "\$RXN V3000"
    set sdfRegExp = new RegExp
    sdfRegExp.global = true
    sdfRegExp.pattern = "V[23]000[^$]*\$\$\$\$"
    set molv3RegExp = new RegExp
    molv3RegExp.global = true
    molv3RegExp.pattern = "\s*0\s+0\s+0\s+0\s+0\s+999\sV3000"
    set cdxmlRegExp = new RegExp
    cdxmlRegExp.global = true
    cdxmlRegExp.pattern = "<CDXML"
    set b64cdxRegExp = new RegExp
    b64cdxRegExp.global = true
    b64cdxRegExp.pattern = "ChemDraw \d\d"
    set b64cdx2RegExp = new RegExp
    b64cdx2RegExp.global = true
    b64cdx2RegExp.pattern = "^Vmp"
    set mol2RegExp = new RegExp
    mol2RegExp.global = true
    mol2RegExp.pattern = "^\s*\d+\s*\d+\s*\d+\s*\d+\s*\d+\s*\d+\s*\d+\s*V2000"
    if mrvRegExp.test(fileData) then
        fileType = "mrv"
    elseif rxnRegExp.test(fileData) then
        fileType = "rxn"
    elseif molRegExp.test(fileData) then
        fileType = "mol"
    elseif mrv2RegExp.test(fileData) then
        fileType = "mrv"
    elseif rxnv3RegExp.test(fileData) then
        fileType = "rxn:V3"
    elseif sdfRegExp.test(fileData) then
        fileType = "sdf"
    elseif molv3RegExp.test(fileData) then
        fileType = "mol:V3"
    elseif cdxmlRegExp.test(fileData) then
        fileType = "cdxml"
    elseif b64cdxRegExp.test(fileData) then
        fileType = "base64:cdx"
    elseif b64cdx2RegExp.test(fileData) then
        fileType = "base64:cdx"
    elseif mol2RegExp.test(fileData) then
        fileType = "mol"
    end if
    getFileFormat = fileType
End Function

Function cleanRelativeStereoHits(theQueryStructureIn, structureFormat, resultsJson, whichDb, whichTable)
	theReturnValue = ""
	theQueryStructure = theQueryStructureIn
	inputMolDataJson = analyzeInputMol(theQueryStructure)
		
	Set inputMolData = JSON.Parse(inputMolDataJson)
	If IsObject(inputMolData) Then
		theQueryStructure = inputMolData.Get("structure")
		theQueryStructureFormat = inputMolData.Get("molFormat")
	End If

	theQueryStructure = CX_standardize(theQueryStructure,structureFormat,stereoStandardizerConfig,"mol:V3")
	If whichClient = "SUNOVION" Or whichClient = "CARDURION" Then
		theQueryStructure = setChiralFlag(theQueryStructure, False)
	End If
	theQueryStructure = CX_standardize(theQueryStructure,structureFormat,stereoStandardizerConfig,"cxsmiles:+u")

	Set myResults = JSON.Parse(resultsJson)
	Set myResultCdIds = JSON.Parse("{}")

	If IsObject(myResults) Then
		numResults = myResults.Length
		
		''''''''''''''''''''' If we get 2 results on the DUPLICATE search, we need to check the mol files to see if they share an OR center that's hitting the duplicate filter ''''''''''''''''
		For i = 0 To numResults - 1
			Set thisResult = myResults.Get(i)
			resultCdId = thisResult.Get("cd_id")

			If Not myResultCdIds.Exists(resultCdId) Then
				myResultCdIds.Set resultCdId, True
				resultMolFile = CX_cdIdSearch(whichDb, whichTable, resultCdId, "mol:V3")
				Set resMol = JSON.parse(resultMolFile)
				If IsObject(resMol) And resMol.Exists("structureData") Then
					Set structureData = resMol.Get("structureData")
					If IsObject(structureData) And structureData.Exists("structure") Then
						targetMolFile = structureData.Get("structure")
						If whichClient = "SUNOVION" Or whichClient = "CARDURION" Then
							targetMolFile = setChiralFlag(targetMolFile, False)
						End If
						targetMolFile = CX_standardize(aspJsonStringify(targetMolFile),"mol:V3",stereoStandardizerConfig,"cxsmiles:+u")
						If theQueryStructure = targetMolFile Then
							If Len(theReturnValue) > 0 Then
								theReturnValue = theReturnValue & ","
							End If
							theReturnValue = theReturnValue & JSON.stringify(thisResult)
						End If
					End If
				End If
			End If
		Next
	End If
	
	theReturnValue = "[" & theReturnValue & "]"
	cleanRelativeStereoHits = theReturnValue
End Function
%>