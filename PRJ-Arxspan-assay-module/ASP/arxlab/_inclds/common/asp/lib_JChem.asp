<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
chemAxonRootUrl = getCompanySpecificSingleAppConfigSetting("chemAxonEndpointUrl", session("companyId"))
Function getEmptyStructureIfNeeded(molData)
	blankMol = ""&vbcrlf&"  Arxspan"&vbcrlf&vbcrlf&"  0  0  0  0  0  0  0  0  0  0999 V2000"&vbcrlf&"M  END"&vbcrlf
	If IsNull(molData) Then
		molData = blankMol
	else	
		If molData = "" Then
			molData = blankMol
		End if
	End if
	getEmptyStructureIfNeeded = molData
End Function

Function CX_structureSearch(databaseName,tableName,queryMol,conditions,searchParamJson,fields,resultCount,beginIndex)
	conditionsString = ""
	If conditions <> "" Then
		conditionsString = conditionsString &_
		"""filter"": {" &_
			"""conditions"": {" &_
				"""$and"":[" & conditions & "]" &_
			"}" &_
		"},"
	End If
	
	' Set up some default values
	If searchParamJson = "" Then
		searchParamJson = "{}"
	End If
	Set searchParams = JSON.parse(searchParamJson)
	
	If Not searchParams.Exists("searchType") Then
		searchParams.Set "searchType", "SUBSTRUCTURE"
	End If
	
	If Not searchParams.Exists("tautomers") Then
		searchParams.Set "tautomers", "DEFAULT"
	End If
	
	If Not searchParams.Exists("similarityThreshold") Then
		searchParams.Set "similarityThreshold", 0.8
	End If
	
	If Not searchParams.Exists("absoluteStereo") Then
		searchParams.Set "absoluteStereo", "ALWAYS_ON"
	End If
	
	If Not searchParams.Exists("stereoSearchType") Then
		searchParams.Set "stereoSearchType", "ON"
	End If
	
	' Embed tautomer setting in proper JSON
	Set tautomerJson = JSON.parse("{}")
	tautomerJson.Set "tatuomerSearch", searchParams.Get("tautomers")
	searchParams.Set "tautomers", tautomerJson
	
	' Embed similarity setting in proper JSON
	Set similarityJson = JSON.parse("{}")
	similarityJson.Set "descriptor", "CFP"
	similarityJson.Set "threshold", searchParams.Get("similarityThreshold")
	searchParams.Set "similarity", similarityJson

	' Embed absoluteStereo setting in proper JSON
	Set stereoJson = JSON.parse("{}")
	stereoJson.Set "absoluteStereo", searchParams.Get("absoluteStereo")
	stereoJson.Set "stereoSearchType", searchParams.Get("stereoSearchType")
	searchParams.Set "stereoChemistry", stereoJson

	data = "{" &_
			"""searchOptions"": {" &_
			"""queryStructure"": """ & queryMol & """" &_
			",""searchType"": " & JSON.stringify(searchParams.Get("searchType")) &_
			",""similarity"": " & JSON.stringify(searchParams.Get("similarity")) &_
			",""stereoChemistry"": " & JSON.stringify(searchParams.Get("stereoChemistry")) &_
			",""tautomers"": " & JSON.stringify(searchParams.Get("tautomers")) &_
		"}," &_
		conditionsString &_
		"""display"": {" &_
			"""include"": "& fields &_
		"}," &_
		"""paging"": {" &_
			"""offset"": " & beginIndex & "," &_
			"""limit"": " & resultCount &_
		"}" &_
	"}"

	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName&"/search",true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	retStr = xmlhttp.responsetext
	
	CX_structureSearch = retStr
	Set xmlhttp = nothing
End Function

Function CX_cdIdSearch(databaseName, tableName, cdId, returnFormat)
	If returnFormat = "" Then
		returnFormat = "mol:V3"
	End If
	
	requestData = "{""include"":[""structureData""],""parameters"":{""structureData"":"""&returnFormat&"""}}"
	
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName&"/detail/"&cdId,true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send requestData
	xmlhttp.waitForResponse(60)
	retStr = xmlhttp.responsetext

	CX_cdIdSearch = retStr
	Set xmlhttp = nothing
End Function

Function CX_isReaction(databaseName,tableName,molData)
	CX_isReaction = False
    insertUrl = chemAxonRootUrl & "util/calculate/reactionAnalysis"
	data = "{""structure"":"""&molData&"""}"
	
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",insertUrl,true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	retStr = xmlhttp.responsetext

	Set retVal = JSON.parse(retStr)
	If isObject(retVal) Then
		If Not retVal.Exists("errorCode") Then
			CX_isReaction = True
		End If
	End If

	Set xmlhttp = nothing
End Function

Function CX_importStructure(databaseName,tableName,molData,additionalData)
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",chemAxonRootUrl&"monitor",true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	
	monitorId = xmlhttp.responsetext
    insertUrl = chemAxonRootUrl & "data/"&databaseName&"/table/"&tableName&"/operation"
	
    data = "{" &_
		"""monitorId"": " & monitorId & "," &_
		"""data"": [{""structure"":""" & molData & """"
			If additionalData <> "" Then
				data = data & ",""additionalData"":"&additionalData
			End If
	data = data & "}]}"
	
	xmlhttp.Open "POST",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName,true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	Set xmlhttp = nothing
	
	state = "ERROR"
	Set cxJsonObj = Nothing
	
	Do While True
		cxJsonStr = CX_getMonitorStatus(monitorId)
		Set cxJsonObj = JSON.parse(cxJsonStr)
		If Not IsObject(cxJsonObj) Then
			Exit Do
		Else
			If cxJsonObj.Exists("state") Then
				state = cxJsonObj.Get("state")
				If state = "FINISHED" Or state = "FAILED" Or state = "ERROR" Then
					Exit Do
				End If
			End If
		End If
	Loop

	Set retJson = JSON.parse("{}")
	If state = "FINISHED" And IsObject(cxJsonObj) Then
		If cxJsonObj.Exists("data") Then
			Set cxData = cxJsonObj.Get("data")
			If IsObject(cxData) And cxData.Exists("successful") Then
				If cxData.Get("successful") = 1 And cxData.Exists("first10") Then
					Set cxFirstTen = cxData.Get("first10")
					retJson.Set "cd_id", cxFirstTen.Get(0)
					retJson.Set "status", "SUCCESS"
				End If
			End If
		End If
	Else
		retJson.Set "cd_id", -1
		retJson.Set "status", "ERROR"
		retJson.Set "message", "There was an error processing your import."
	End If
	
	CX_importStructure = JSON.stringify(retJson)
End Function

Function CX_addStructure(databaseName,tableName,molData,additionalData)
	CX_addStructure = "{}"
    insertUrl = chemAxonRootUrl & "data/"&databaseName&"/table/"&tableName&"/operation"
    data = "{""operationType"":""INSERT"""&_
	       ",""structure"":""" & molData & """"
			If additionalData <> "" Then
				data = data & ",""additionalData"":"&additionalData
			End If
	data = data & "}"

	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",insertUrl,true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(180)
	retStr = xmlhttp.responsetext

	CX_addStructure = retStr
	Set xmlhttp = nothing
End Function

Function CX_getStructureByCdId(databaseName,tableName,cdId,format)
	CX_getStructureByCdId = "{}"
    insertUrl = chemAxonRootUrl & "data/"&databaseName&"/table/"&tableName&"/detail/" & cdId
    data = "{""include"": [""cd_id"",""structureData""], ""parameters"":{""structureData"":" & JSON.stringify(format) & "}}"

	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",insertUrl,true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	retStr = xmlhttp.responsetext
	
	Set responseJson = JSON.parse(retStr)
	If IsObject(responseJson) Then
		If responseJson.Exists("structureData") Then
			Set structureData = responseJson.Get("structureData")
			If IsObject(structureData) Then
				structureStr = ""
				If structureData.Exists("structure") Then
					structureStr = structureData.Get("structure")
					binary = False
				ElseIf structureData.Exists("binaryStructure") Then
					structureStr = structureData.Get("binaryStructure")
					binary = True
				End If
				
				If structureStr <> "" Then
					Set jsonRet = JSON.parse("{}")
					jsonRet.Set "structure", structureStr
					jsonRet.Set "isBinary", binary
					CX_getStructureByCdId = JSON.stringify(jsonRet)
					Set jsonRet = Nothing
				End If
			End If
		End If
	End If

	Set xmlhttp = nothing
End Function

' Fields (String) - JSON array of the fields you want back from JChem
Function CX_getFieldDataByCdId(databaseName,tableName,cdId,fields)
	CX_getFieldDataByCdId = "{}"

	set data = JSON.parse("{}")
	set filterObj = JSON.parse("{}")
	set conditionsObj = JSON.parse("{}")
	set andObj = JSON.parse("[]")
	set cdidObj = JSON.parse("{}")
	set eqObj1 = JSON.parse("{}")
	set companyIdObj = JSON.parse("{}")
	set eqObj2 = JSON.parse("{}")
	set displayObj = JSON.parse("{}")
	set pagingObj = JSON.parse("{}")

	pagingObj.Set "offset", 0
	pagingObj.Set "limit", 2147483647 ' Max Int
	data.Set "paging", pagingObj

	displayObj.Set "include", JSON.parse(fields)
	data.Set "display", displayObj

	eqObj1.set "$eq", cdid
	cdidObj.set "cd_id", eqObj1
	eqObj2.set "$eq", session("companyId")
	companyIdObj.set "company_id", eqObj2
	andObj.push cdidObj
	andObj.push companyIdObj

	conditionsObj.set "$and", andObj
	
	filterObj.set "conditions", conditionsObj

	data.set "filter", filterObj

	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName&"/search",true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send JSON.stringify(data)
	xmlhttp.waitForResponse(60)
	Set responseJson = JSON.parse(xmlhttp.responsetext)
	CX_getFieldDataByCdId = JSON.stringify(responseJson.get("data").get(0))
	Set xmlhttp = nothing
End Function

Function CX_removeStructure(databaseName, tableName, cdId)
	data = "{" &_
		"""operationType"": ""DELETE""," &_
		"""cd_id"": " & cdId &_
	"}"
	
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName&"/operation",true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	retStr = xmlhttp.responsetext
	
	CX_removeStructure = retStr
	Set xmlhttp = nothing
End Function

Function CX_updateStructure(databaseName, tableName, molData, cdId)
	data = "{" &_
		"""operationType"": ""UPDATE""," &_
		"""cd_id"": " & cdId &"," &_
		"""structure"": """ & molData & """" &_
	"}"
	
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName&"/operation",true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	retStr = xmlhttp.responsetext
	
	CX_updateStructure = retStr
	Set xmlhttp = nothing
End Function

Function CX_importSdFile(databaseName, tableName, sdToRegister, jsonMappingObj)

	'Only allowed values
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "GET",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName&"/headers/table",true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send ""
	xmlhttp.waitForResponse(60)
	
	responseJSON = xmlhttp.responsetext
	set responseJSONObj = JSON.parse(responseJSON)

	Set jsonMappingObjClean = JSON.parse("{}") ' Cleaned list of the allowed metadata
	Set jsonMappingObjTypes = JSON.parse("{}") ' Field Types, so we can check for numbers

	'compare the jsonMappingObj values, vs. the actual values in the table.
	' Make sure they exist, then use the case from the table.
	' This is to fix issues with case or missing metadata columns
	for each tableCol in responseJSONObj
		For Each key in jsonMappingObj.keys()
		
			foundKey = StrComp(jsonMappingObj.get(key), tableCol.get("name"), 1)
			If ((Not IsNull(foundKey)) And foundKey = 0) Then
				jsonMappingObjClean.Set key, tableCol.get("name")
				jsonMappingObjTypes.Set tableCol.get("name"), tableCol.get("type") ' Add the type so we can check for numbers
			end if
		next
	next

	CX_importSdFile = ""
	strLines = Split(sdToRegister, vbcrlf)
	
	sdFileStr = ""
	molMetaDataFlag = ""
	set mols = JSON.parse("[]")
	set numberTypes = server.CreateObject("System.Collections.ArrayList")
	numberTypes.add "DOUBLE"
	numberTypes.add "INTEGER"
	numberTypes.add "BIT"
	numberTypes.add "DECIMAL"
	numberTypes.add "NUMERIC"
	numberTypes.add "FLOAT"
	numberTypes.add "REAL"
	numberTypes.add "INT"
	numberTypes.add "BIGINT"
	numberTypes.add "SMALLINT"
	numberTypes.add "TINYINT"
	numberTypes.add "MONEY"
	numberTypes.add "SMALLMONEY"
	
	set molMetaData = JSON.parse("{}")
	foundMolEnd = False
	For Each line In strLines

		if len(molMetaDataFlag) > 0 Then
			' This line is metadata, save it
			' but first, make sure any numbers are actually numbers
			If numberTypes.contains(jsonMappingObjTypes.Get(molMetaDataFlag)) then
				cleanLine = ""
				' Loop the string, if each char isNumeric, add them to the output
				For ii = 1 to len(line)
					if (isNumeric(mid(line,ii,1)) = true or mid(line,ii,1) = ".") then
						cleanLine = cleanLine & mid(line,ii,1)
					end if
				Next
				molMetaData.set molMetaDataFlag, cleanLine
			Else
				molMetaData.set molMetaDataFlag, line
			End if			
			molMetaDataFlag = ""

		elseIf foundMolEnd Then
			For Each key in jsonMappingObjClean.keys()
				' Find the metadata
				findStr = ">  <" & key & ">"
				findStr2 = ">  <" & jsonMappingObjClean.Get(key) & ">"
				foundIt = StrComp(line, findStr,1)
				foundIt2 = StrComp(line, findStr2,1)
				If ((Not IsNull(foundIt)) And foundIt = 0) OR ((Not IsNull(foundIt2)) And foundIt2 = 0) Then
					molMetaData.set jsonMappingObjClean.Get(key), "" 
					molMetaDataFlag = jsonMappingObjClean.Get(key)
				End If
			Next
		End if
		
		'End of the object
		If Trim(line) = "$$$$" Then
			sdFileStr = sdFileStr & line

			set structureJSON = JSON.parse("{}")
			structureJSON.Set "structure", sdFileStr
			structureJSON.Set "additionalData", JSON.parse(JSON.stringify(molMetaData)) ' parse and stringify to force object copy

			' Add to the mols object
			mols.push structureJSON

			foundMolEnd = False
			sdFileStr = ""

			set molMetaData = JSON.parse("{}") ' Clear this out
		elseIf (Not foundMolEnd)  Then
			sdFileStr = sdFileStr & line & vbcrlf
		End If

		' End of the MOL data
		If Trim(line) = "M  END" Then
			foundMolEnd = True
		End If

	Next
	
	' Get a monitor ID (and return it)
	xmlhttp.Open "POST",chemAxonRootUrl&"monitor",true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	monitorId = xmlhttp.responsetext
	CX_importSdFile = monitorId

	' Use the monitor ID so we can track this request
	set jsonData = JSON.parse("{}")
	jsonData.set "monitorId", Replace(monitorId,"""","")
	' add each mol with metadata to the final object
	jsonData.set "data", mols

	' Uncomment to see what is actually sent to JChem
    'response.write("<h2> JSON: "& JSON.stringify(jsonData) & "</h2>")

	' Kick off the processing
	xmlhttp.Open "POST",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName,true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send JSON.stringify(jsonData)
	xmlhttp.waitForResponse(60)
	retStr2 = xmlhttp.responsetext
	Set xmlhttp = nothing
End Function

Function CX_getMonitorStatus(monitorId)
	CX_getMonitorStatus = "{""state"":""ERROR""}"
	monitorId = Replace(monitorId, """", "")
	
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "GET",chemAxonRootUrl&"monitor/"&monitorId,true
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	CX_getMonitorStatus = xmlhttp.responsetext
	Set xmlhttp = nothing
End Function

Function CX_removeStructures(databaseName,tableName,filter)
	CX_removeStructures = False
	conditionsString = """company_id"": {""$eq"":"& session("companyId") & "}"
	If filter <> "" Then
		conditionsString = conditionsString & filter
	End If

	data = "{" &_
		"""filter"": {" &_
			"""conditions"": {" &_
				conditionsString &_
			"}" &_
		"}," &_
		"""display"": {" &_
			"""include"": [""cd_id""]" &_
		"}," &_
		"""paging"": {" &_
			"""offset"": 0," &_
			"""limit"": 2000000000" &_
		"}" &_
	"}"
	
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",chemAxonRootUrl&"data/"&databaseName&"/table/"&tableName&"/search",true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)
	retStr = xmlhttp.responsetext
	Set xmlhttp = nothing
	
	Set retJson = JSON.parse(retStr)
	If IsObject(retJson) Then
		If retJson.Exists("data") Then
			Set jsonData = retJson.Get("data")
			theIndex = 0
			Do While theIndex < jsonData.Length
				Set dataElement = jsonData.Get(theIndex)
				If dataElement.Exists("cd_id") Then
					theCdId = dataElement.Get("cd_id")
					CX_removeStructure databaseName, tableName, theCdId
				End If
				theIndex = theIndex + 1
			Loop
			CX_removeStructures = True
		End If
	End If
End Function

Function CX_standardize(molData,inputFormat,config,outputFormat)
	If config <> "" Then
		molStructure = CX_convertStructure(molData, inputFormat, "mol:V3")
		data = "{""structure"": """ & aspJsonStringify(molStructure) & """,""parameters"":{""standardizerDefinition"": " & JSON.stringify(config) & "}}"
		
		set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
		xmlhttp.Open "POST",chemAxonStandardizerUrl,true
		xmlhttp.setRequestHeader "Content-Type", "application/json"
		xmlhttp.SetTimeouts 300000,300000,300000,300000
		xmlhttp.send data
		xmlhttp.waitForResponse(60)

		retStr = xmlhttp.responsetext
		retStr = aspJsonStringify(retStr)
		convertFrom = "mrv"
	Else
		retStr = molData
		convertFrom = inputFormat
	End If

	If convertFrom <> outputFormat Then
		CX_standardize = CX_convertStructure(retStr, convertFrom, outputFormat)
	Else
		CX_standardize = retStr
	End If
End Function

Function CX_getSvgByCdId(databaseName, tableName, cdId, width, height)
	structureJson = CX_getStructureByCdId(databaseName, tableName, cdId, "mol:V3")
	
	CX_getSvgByCdId = ""
	Set structureData = JSON.parse(structureJson)
	If IsObject(structureData) Then
		If structureData.exists("structure") Then
			CX_getSvgByCdId = CX_convertStructure(aspJsonStringify(structureData.get("structure")), "mol:V3", CX_getSvgParams(height, width))
		End If
	End If
End Function

Function CX_convertStructure(inputData, inputFormat, outputFormat)
	data = "{""structure"":"""&inputData&""",""inputFormat"":"&JSON.stringify(inputFormat)&",""parameters"":"&JSON.stringify(outputFormat)&"}"
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",chemAxonMolExportUrl,true
	xmlhttp.setRequestHeader "Content-Type", "application/json"
	xmlhttp.SetTimeouts 300000,300000,300000,300000
	xmlhttp.send data
	xmlhttp.waitForResponse(60)

	retStr = xmlhttp.responsetext
	Set retJson = JSON.parse(retStr)
	Set xmlhttp = nothing
	
	If IsObject(retJson) Then
		If retJson.Exists("structure") Then
			CX_convertStructure = retJson.Get("structure")
		End If
	End If
End Function

Function CX_getSvgParams(height, width)
	CX_getSvgParams = "svg:headless,nosource,transbg,absLabelVisible,maxscale28,marginSize2,cv_off,atsiz0.5,-a,w"&CStr(width)&",h"&CStr(height)
End Function
%>