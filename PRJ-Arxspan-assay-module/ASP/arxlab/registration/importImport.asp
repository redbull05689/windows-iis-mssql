<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<%
server.scripttimeout = 60
response.buffer = false
%>
<%
sectionId = "reg"
subSectionId = "import"
subSubSectionId = "map-fields"
if Not session("regRegistrar") Then
	response.redirect("logout.asp")
End If
%>
<%
	fid = request.querystring("fid")
	filename = session("regUploadfilename")
	fullPath = session("regUploadFullPath")
%>
<%
useSalts = True
hasStructure = True
allowBatches = True
groupId = request.querystring("groupId")
If isInteger(request.querystring("groupId"))  And groupId <> "0" Then
	isGroup = True
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT useSalts, hasStructure, allowBatches, groupPrefix FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
	If session("regRestrictedGroups") <> "" Then
		strQuery = strQuery & " AND id NOT IN ("&session("regRestrictedGroups")&")"
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
		groupPrefix = rec("groupPrefix")
	Else
		title = "Error"
		message = "Group does not exist or you are not authorized to access it."
		response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
	End if
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg
Else
	isGroup = False
	groupId = 0
	groupPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
End if
%>
<%Call getconnectedJchemReg%>
<!-- #include file="_inclds/searchOptionsString.asp"-->
<%Call disconnectJchemReg%>

<%
Set config = new LD
If request.Form("mapSubmit") <> "" Then
	Dim mappings()
	numMappings = 0
	numCustomMappings = 0
	For i = 1 To request.Form("numFields")
		If request.Form("regName_"&i) <> "" Then
			numMappings = numMappings + 1
			'response.write(request.Form("mfName_"&i)&"&nbsp;-&gt;&nbsp"&Split(request.Form("regName_"&i),"|||")(1)&"<br>")
		End If
		If request.Form("regName_"&i) <> "" Then
			If Split(request.Form("regName_"&i),"|||")(0) <> "chemical_name" And Split(request.Form("regName_"&i),"|||")(0) <> "name" And Split(request.Form("regName_"&i),"|||")(0) <> "user_name" And Split(request.Form("regName_"&i),"|||")(0) <> "date_created" Then
				numCustomMappings = numCustomMappings + 1
			End If
		End if
	Next
	ReDim mappings(numMappings -1,1)

	Set staticFieldMappings = new LD
    config.addPair "groupId", groupId
	
    Set fieldMappings = new LD
	fieldMappings.addPair "salt_codes", "salt_codes"
	fieldMappings.addPair "salt_multiplicities", "salt_multiplicities"
	
	Set appendFields = new LD
    Set dropDownValues = new LD
	Set fieldsWithDefaults = new LD

	counter = 0
	dropDownValues.mode = "D"
	fieldsWithDefaults.mode = "D"

	For i = 1 To request.Form("numFields")
		If request.Form("regName_"&i) <> "" Then
			mappings(counter,0) = request.Form("mfName_"&i)
			mappings(counter,1) = Split(request.Form("regName_"&i),"|||")(0)
			fieldMappings.addPair Split(request.Form("regName_"&i),"|||")(0), request.Form("mfName_"&i)
			If request.Form("defaultValueAdded_"&i) = "1" then
				fieldsWithDefaults.addPair request.Form("mfName_"&i),request.Form("defaultValue_"&i)
			End If
			If request.Form("appendData_"&i) = "on" then
				appendFields.addItem request.Form("mfName_"&i)
			End if

			Call getconnectedJchemReg
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT dropDownId, actualField FROM customFields WHERE actualField="&SQLClean(Split(request.Form("regName_"&i),"|||")(0),"T","S")&" AND (dropDownId>0 or dropDownId=-99)"
			rec.open strQuery,jchemRegConn,3,3
			If Not rec.eof Then
				dropDownId = rec("dropDownId")
				actualField = rec("actualField")
                If Not dropDownValues.keyExists(actualField) Then
                    Set dropDownSelections = new LD
					If dropDownId = -99 Then
						Call getconnected
						Set rec2 = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT firstName, lastName FROM "&usersTable&" WHERE enabled=1 and companyId="&session("companyId")&" ORDER BY firstName"
						rec2.open strQuery,Conn,3,3
						Do While Not rec2.eof
							dropDownSelections.addItem rec2("firstName")&" "&rec2("lastName")
							rec2.movenext
						Loop
						rec2.close
						Set rec2 = Nothing
						Call disconnect
					else
						Call getconnected
						Set rec2 = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT value FROM regDropDownOptions WHERE parentId="&SQLClean(dropDownId,"N","S")
						rec2.open strQuery,jchemRegConn,3,3
						Do While Not rec2.eof
							dropDownSelections.addItem rec2("value")
							rec2.movenext
						Loop
						rec2.close
						Set rec2 = nothing
						Call disconnect
					End if
					dropDownValues.addPair actualField, dropDownSelections
				End If
			End If
			rec.close
			Set rec = Nothing
			Call disconnectJchemReg
			counter = counter +1
		End if
	Next

	Call getconnectedJchemReg

	If request.Form("makeBatches") = "MAKE_BATCHES" then
		makeBatches = "MAKE_BATCHES"
	Else
		If request.Form("makeBatches") = "REPLACE_ON_KEY" Then
			makeBatches = "REPLACE_ON_KEY:"&request.Form("replaceKey")
		else
			makeBatches = "DONT_MAKE_BATCHES"
		End if
	End if

	fillRegNumberGaps = checkBoolSettingForCompany("fillRegNumberGaps", session("companyId"))
	regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
	regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
	regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
	regBatchNumberMode = getCompanySpecificSingleAppConfigSetting("regBatchNumberMode", session("companyId"))
	regNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regIdDelimiter", session("companyId"))
	regNumberLength = getCompanySpecificSingleAppConfigSetting("regIdNumberLength", session("companyId"))
	regNumberLength = normalizeIntSetting(regNumberLength)
	regNumberMode = getCompanySpecificSingleAppConfigSetting("regNumberMode", session("companyId"))
	startingRegNumber = getCompanySpecificSingleAppConfigSetting("startingRegNumber", session("companyId"))

	config.addPair "companyId",session("companyId")
	config.addPair "whichServer",RegDatabaseName
	config.addPair "makeBatches",makeBatches
	config.addPair "isDuplicates","NOT_DUPLICATES"
	config.addPair "server",RegDatabaseName
	config.addPair "dbServerIP",Replace(regDataBaseServerIP,"\","\\")
	config.addPair "userId",session("userId")
	config.addPair "userName",session("firstName")&" "&session("lastName")
	config.addPair "userEmail",session("email")
	config.addPair "regNumberPrefix",groupPrefix
	config.addPair "regNumberMode",regNumberMode
	config.addPair "fillRegNumberGaps", fillRegNumberGaps
	config.addPair "regNumberLength",regNumberLength
	config.addPair "startingRegNumber",startingRegNumber
	config.addPair "regBatchNumberMode",regBatchNumberMode
	config.addPair "regBatchNumberLength",regBatchNumberLength
	config.addPair "regBatchNumberDelimiter",regBatchNumberDelimiter
	config.addPair "regCountDoubleBondsForChirality",CStr(session("countDoubleBondsForChiralityInReg"))
	config.addPair "regNumberDelimiter",regNumberDelimiter
	config.addPair "fieldsWithDefaults",fieldsWithDefaults
	config.addPair "fieldMappings",fieldMappings
	config.addPair "dropDownValues",dropDownValues
	config.addPair "hasStructure",hasStructure
	config.addPair "appendFields",appendFields
	config.addPair "optionString",optionStr
	config.addPair "regMoleculesTable",regMoleculesTable
	config.addPair "regSaltsTable",regSaltsTable
	config.addPair "regRestrictedGroups",CStr(session("regRestrictedGroups"))
	If session("companyHasFT") Or session("companyHasFTLiteReg") then
		config.addPair "sendToFT",true
	Else
		config.addPair "sendToFT",false
	End if
	If groupId = "" Then
		config.addPair "groupId","0"
	else
		config.addPair "groupId",groupId
	End if
	config.addPair "groupPrefix",groupPrefix

	hideVirtualCompounds = checkBoolSettingForCompany("hideVirtualCompoundsDuringRegistration", session("companyId"))
	config.addPair "hideVirtualCompounds",hideVirtualCompounds

	Call getconnectedJchemReg

	Set idFieldsActual = new LD
	If Not hasStructure then
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT actualField FROM groupCustomFieldFields WHERE isIdentity=1 and groupId="&SQLClean(groupId,"N","S")
		rec.open strQuery,jchemRegConn,3,3
		Do While Not rec.eof
			idFieldsActual.addItem rec("actualField")
			rec.movenext
		Loop
		rec.close
		Set rec = nothing
	End if
	config.addPair "idFieldsActual",idFieldsActual

	Set uniqueFields = new LD
	Set uniqueFieldsActual = new LD
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup then
		strQuery = "SELECT displayName, actualField FROM groupCustomFieldFields WHERE enforceUnique=1 and groupId="&SQLClean(groupId,"N","S")
	Else
		strQuery = "SELECT displayName, actualField FROM customFields WHERE enforceUnique=1"
	End if
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		uniqueFields.addItem rec("displayName")
		uniqueFieldsActual.addItem rec("actualField")
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	config.addPair "uniqueFields",uniqueFields
	config.addPair "uniqueFieldsActual",uniqueFieldsActual

	'5115
	Set combinedFields = new LD
	config.addPair "combinedFields",combinedFields
	'/5115

	Set requiredCompoundFields = new LD
	Set requiredCompoundFieldsActual = new LD
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT displayName, actualField FROM groupCustomFieldFields WHERE requireCompound=1 and groupId="&SQLClean(groupId,"N","S")
	else
		strQuery = "SELECT displayName, actualField FROM customFields WHERE requireCompound=1"
	End if
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		requiredCompoundFields.addItem rec("displayName")
		requiredCompoundFieldsActual.addItem rec("actualField")
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	config.addPair "requiredCompoundFields",requiredCompoundFields
	config.addPair "requiredCompoundFieldsActual",requiredCompoundFieldsActual

	Set requiredBatchFields = new LD
	Set requiredBatchFieldsActual = new LD
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT displayName, actualField FROM groupCustomFieldFields WHERE requireBatch=1 and groupId="&SQLClean(groupId,"N","S")
	else
		strQuery = "SELECT displayName, actualField FROM customFields WHERE requireBatch=1"
	End if
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		requiredBatchFields.addItem rec("displayName")
		requiredBatchFieldsActual.addItem rec("actualField")
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	config.addPair "requiredBatchFields",requiredBatchFields
	config.addPair "requiredBatchFieldsActual",requiredBatchFieldsActual

	Set compoundFieldsActual = new LD
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT actualField FROM groupCustomFieldFields WHERE showCompound=1 and groupId="&SQLClean(groupId,"N","S")
	else
		strQuery = "SELECT actualField FROM customFields WHERE showCompound=1"
	End if
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		compoundFieldsActual.addItem rec("actualField")
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	config.addPair "compoundFieldsActual",compoundFieldsActual

	Set batchFieldsActual = new LD
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT actualField FROM groupCustomFieldFields WHERE showBatch=1 and groupId="&SQLClean(groupId,"N","S")
	else
		strQuery = "SELECT actualField FROM customFields WHERE showBatch=1"
	End if
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		batchFieldsActual.addItem rec("actualField")
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	config.addPair "batchFieldsActual",batchFieldsActual

	Set intFields = new LD
	Set intFieldsActual = new LD
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT displayName, actualField FROM groupCustomFieldFields WHERE (dataType='int' or dataType='multi_int') and groupId="&SQLClean(groupId,"N","S")
	else
		strQuery = "SELECT displayName, actualField FROM customFields WHERE (dataType='int' or dataType='multi_int')"
	End if
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		intFields.addItem rec("displayName")
		intFieldsActual.addItem rec("actualField")
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	config.addPair "intFields",intFields
	config.addPair "intFieldsActual",intFieldsActual

	Set floatFields = new LD
	Set floatFieldsActual = new LD
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT displayName, actualField FROM groupCustomFieldFields WHERE (dataType='float' or dataType='multi_float') and groupId="&SQLClean(groupId,"N","S")
	Else
		strQuery = "SELECT displayName, actualField FROM customFields WHERE (dataType='float' or dataType='multi_float')"
	End if
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		floatFields.addItem rec("displayName")
		floatFieldsActual.addItem rec("actualField")
		rec.movenext
	Loop
	rec.close
	Set rec = nothing
	config.addPair "floatFields",floatFields
	config.addPair "floatFieldsActual",floatFieldsActual

	Call disconnectJchemReg

	If request.Form("mapSubmit") <> "" then
		bulkRegEndpointUrl = getCompanySpecificSingleAppConfigSetting("bulkRegEndpointUrl", session("companyId"))

		Call getconnectedJchemReg
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT actualField FROM customFields WHERE formName='SD_Filename'"
		rec.open strQuery,jchemRegConn,3,3
		If Not rec.eof then
			getDateString = "GETDATE()"
			getDateString2 = "GETUTCDATE()"
			staticFieldMappings.addPair "source", request.form("originalFilename")
			staticFieldMappings.addPair rec("actualField"), request.form("originalFilename")
        
			strQuery = "INSERT INTO sdImports(userId,userName,sdFilename,dateCreated,dateCreatedUTC,needsPurification,outForAnalysis,analysisComplete,fid,groupId) output inserted.id as newId values("&_
						SQLClean(session("userId"),"N","S") &","&_
						SQLClean(session("firstName")&" "&session("lastName"),"T","S") &","&_
						SQLClean(Right(request.Form("originalFilename"),499),"T","S") &","&_
						""&getDateString&","&getDateString2&",0,0,0,"&SQLClean(fid,"T","S")&","&SQLClean(groupId,"N","S")&")"
			Set rs = jchemRegConn.execute(strQuery)
			sdId = rs("newId")
			Set rs = Nothing
		
			staticFieldMappings.addPair "arxspan_sd_source_id", sdId
			config.addPair "staticFieldMappings", staticFieldMappings
		
			' CALL REST SERVICE TO GET UPLOAD ID
			payload = "{""filePath"":"""&fullPath&""",""companyId"":"&session("companyId")&",""config"":"&Replace(Replace(config.serialize("js"),"True","true"),"False","false")&"}"
		
			Set http = CreateObject("MSXML2.ServerXMLHTTP")
			http.open "POST", bulkRegEndpointUrl&"/initUpload", True
			http.setRequestHeader "Content-Type", "application/json"
			http.setRequestHeader "Content-Length", Len(payload)
		
			http.SetTimeouts 180000,180000,180000,180000
			' ignore ssl cert errors
			http.setOption 2, 13056
			http.send payload
			http.waitForResponse(180)

			Set retVal = JSON.Parse(http.responseText)
			if retVal.Exists("status") and retVal.Get("status") = "success" and retVal.Exists("uploadId") Then
				uploadId = retVal.Get("uploadId")
				strQuery = "UPDATE sdImports SET newUploadId="&uploadId&" WHERE id="&sdId
				jchemRegConn.execute(strQuery)
			Else
				strQuery = "DELETE FROM sdImports WHERE id="&sdId
				jchemRegConn.execute(strQuery)
				Response.Status = "404 Upload Not Created"
				response.end()
			End If
		End if
		rec.close
		Set rec = Nothing
		Call disconnectJchemReg
	End If
	
	Set batchFieldsActual = Nothing
	Set compoundFieldsActual = Nothing
	Set requiredCompoundFields = Nothing
	Set requiredCompoundFieldsActual = Nothing
	Set requiredBatchFields = Nothing
	Set requiredBatchFieldsActual = Nothing
	Set intFields = Nothing
	Set intFieldsActual = Nothing
	Set floatFields = Nothing
	Set floatFieldsActual = Nothing
	Set uniqueFields = nothing
	Set uniqueFieldsActual = nothing
	Set combinedFields = nothing
	Set config = nothing

	response.redirect("importProgress.asp?fid="&fid&"&source="&request.querystring("source"))
End if
%>