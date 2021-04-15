<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
mainInvURL = getCompanySpecificSingleAppConfigSetting("mainInvUrlEndpoint", session("companyId"))
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))

Function bin(theIn)
	Dim i
	If IsNull(theIn) Then
		bin = ""
	Else
		tmp = ""
		For i = 1 TO Len(theIn)
			Char = Mid(theIn,i,1)
			Value = Asc(Char)
			IF (Value > 31) AND (Value < 128) Then
				Tmp = Tmp & Char
			Else
				tmp = tmp &"<>"
			End if
		Next
		theIn = tmp
		session("theIn") = theIn
		bin = CStr(theIn)

	End if
End Function

function sendProteinToSearchTool(theCdId,sendFile,abandon)
	regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
	Dim groupId
	If Not abandon then
		Call getconnectedadm
	End if
	Dim rec
	Dim rec2
	Dim i

	groupId = 0
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT groupId,just_reg,just_batch,reg_id,parent_cd_id FROM "&regMoleculesTable&" WHERE reg_id is not null AND cd_id="&SQLClean(theCdId,"N","S") 
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		groupId = rec("groupId")
		justReg = rec("just_reg")
		justBatch = rec("just_batch")
		regId = rec("reg_id")
		parentCdId = rec("parent_cd_id")
	End if
	rec.close
	Set rec = nothing
	
	cdIdIn = theCdId
	If Not IsNull(parentCdId) And parentCdId > 0 Then
		cdIdIn = cdIdIn & "," & parentCdId
	End If
	cdIdIn = "(" & cdIdIn & ")"

	projectName = ""
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT projectName FROM linksProjectRegView where cd_id in "& cdIdIn & " and companyId=" & SQLClean(session("companyId"),"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		projectName = rec("projectName")
	End If
	rec.close
	Set rec = nothing

	' if regId <> Null then
		groupName = ""
		hasStructure = True
		If IsNull(groupId) Or groupId = "0" Or groupId = 0 then
			groupName = "Small Molecule"
		Else
			isGroup = True
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT name, hasStructure FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
			rec2.open strQuery,jchemRegConn,3,3
			If Not rec2.eof Then
				groupName=rec2("name")
				If rec2("hasStructure") = 0 Then
					hasStructure = False
				End if
			End If
		End if
		
		isBatch = False
		If Replace(justBatch,"0","") <> "" Then
			isBatch = True
		End if

		parentRegNumber = ""
		wholeRegNumber = regId
		displayRegNumber = wholeRegNumber

		If isBatch Then
			parentRegNumber = Left(wholeRegNumber, len(wholeRegNumber) - (len(regBatchNumberDelimiter) + len(justBatch)))
		Else
			displayRegNumber = Left(wholeRegNumber, len(wholeRegNumber) - (len(regBatchNumberDelimiter) + len(justBatch)))
		End if

		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(theCdId,"N","S")
		rec.open strQuery,jchemRegConn,3,3

		Set rec2 =server.CreateObject("ADODB.RecordSet")
		If isBatch then
			If groupId<>0 Then
				strQuery = "SELECT * FROM groupCustomFieldFields WHERE showBatch=1 and groupId="&SQLClean(groupId,"N","S")
			else
				strQuery = "SELECT * FROM customFields WHERE showBatch=1"
			End If
		Else
			If groupId<>0 Then
				strQuery = "SELECT * FROM groupCustomFieldFields WHERE showCompound=1 and groupId="&SQLClean(groupId,"N","S")
			else
				strQuery = "SELECT * FROM customFields WHERE showCompound=1"
			End If
		End if
		rec2.open strQuery,jchemRegConn,3,3

		Dim aErr
		Set jsono = JSON.parse("{}")
		Set jsonDateFields = JSON.parse("[]")
		
		projectFieldInReg = checkBoolSettingForCompany("useProjectFieldInReg", session("companyId"))
		If projectFieldInReg then
			jsono.Set "Project",projectName
		end if
		jsono.Set "Group Name",groupName
		jsono.Set "User Created Reg",bin(rec("user_name"))
		jsono.Set "User Modified Reg",bin(rec("userLastModified"))
		jsono.Set "Date Created Reg",bin(rec("cd_timestamp"))
		jsonDateFields.push("Date Created Reg")
		jsono.Set "Date Modified Reg",bin(rec("dateLastModified"))
		jsono.Set "Status", "ACTIVE"
		if isBatch = true then
			jsono.Set "Parent Record", "No"
			jsono.Set "Batch Record", "Yes"
		else
			jsono.Set "Parent Record", "Yes"
			jsono.Set "Batch Record", "No"
		end if
		
		jsono.Set "Parent ID", Left(wholeRegNumber, len(wholeRegNumber) - (len(regBatchNumberDelimiter) + len(justBatch)))
		if rec("source") = "ELN" then
			jsono.Set "Registration Source", Trim(rec("experiment_name"))
		else
			jsono.Set "Registration Source", Trim(rec("source"))
		end if
		
		If isBatch Then
			jsono.Set "Batch ID", justBatch
		End if


			If sendFile Then
				If session("companyHasFT") then
					Set http = CreateObject("MSXML2.ServerXMLHTTP")
					http.setOption 2, 13056
					usersICanSee = "[" & getUsersICanSee() & "]"
					data = "{""connectionId"":"""&session("servicesConnectionId")&""",""usersICanSee"":"&usersICanSee&",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&"""}"
					http.open "POST",mainInvURL&"/elnConnection/",True
					http.setRequestHeader "Content-Type","text/plain"
					http.setRequestHeader "Content-Length",Len(data)
					http.SetTimeouts 5000,20000,20000,20000
					On Error Resume Next
					http.send data
					http.waitForResponse(60)
					aErr = Array(Err.Number, Err.Description)
					On Error GoTo 0
					If 0 = aErr(0) Then
						Set http = CreateObject("MSXML2.ServerXMLHTTP")
						http.setOption 2, 13056
						Set data2 = JSON.parse("{}")
						data2.Set "connectionId",session("servicesConnectionId")
						data2.Set "regId",displayRegNumber
						data2 = JSON.stringify(data2)
						http.open "POST",mainInvURL&"/linkReg/",True
						http.setRequestHeader "Content-Type","text/plain"
						http.setRequestHeader "Content-Length",Len(data2)
						http.SetTimeouts 180000,180000,180000,180000
						On Error Resume Next
						http.send data2
						http.waitForResponse(60)
					End If
				End if
			End if
			
		If hasStructure Then
			Set jcRec = server.CreateObject("ADODB.RecordSet")
			smilesQueryStr = "select cd_smiles from "&regMoleculesTable&" WHERE cd_id="&SQLClean(theCdId,"N","S")
			jcRec.open smilesQueryStr,jchemRegConn,3,3
			
			If Not jcRec.eof Then
				jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
				molData = ""
				displayMolJson = CX_getStructureByCdId(jChemRegDB,regMoleculesTable,theCdId,"mol:V3")
				Set displayMol = JSON.parse(displayMolJson)
				If IsObject(displayMol) And displayMol.Exists("structure") Then
					molData = displayMol.Get("structure")
				End If

				If molData <> "" Then
					smiles = CX_standardize(aspJsonStringify(molData),"mol:V3",defaultStandardizerConfig,"smiles")
					jsono.Set "Smiles", smiles

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
					If Not abandon then
						Call getconnectedadm
					End If
				End If
			End If
			jcRec.close
			Set jcRec = Nothing
			
			' Defaults, this will be overwritten if the customer has Inventory
			Set s = JSON.parse("{}")
			s.Set "cdxml",molData
			s.Set "molData",molData
			jsono.Set "Structure",s

			If session("hasInv") then
				Set http = CreateObject("MSXML2.ServerXMLHTTP")
				http.setOption 2, 13056
				usersICanSee = "[" & getUsersICanSee() & "]"
				data = "{""connectionId"":"""&session("servicesConnectionId")&""",""usersICanSee"":"&usersICanSee&",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&"""}"
				http.open "POST",mainInvURL&"/elnConnection/",True
				http.setRequestHeader "Content-Type","text/plain"
				http.setRequestHeader "Content-Length",Len(data)
				http.SetTimeouts 5000,20000,20000,20000
				On Error Resume Next
				http.send data
				http.waitForResponse(60)

				aErr = Array(Err.Number, Err.Description)
				On Error GoTo 0
				If 0 = aErr(0) Then
					Set http = CreateObject("MSXML2.ServerXMLHTTP")
					http.setOption 2, 13056
					Set data = JSON.parse("{}")
					data.Set "connectionId",session("servicesConnectionId")
					data.Set "structure",molData
					data = JSON.stringify(data)
					http.open "POST",mainInvURL&"/getSharedCdId/",True
					http.setRequestHeader "Content-Type","text/plain"
					http.setRequestHeader "Content-Length",Len(data)
					http.SetTimeouts 5000,20000,20000,20000
					On Error Resume Next
					http.send data
					http.waitForResponse(60)
					aErr = Array(Err.Number, Err.Description)
					On Error GoTo 0
					If 0 = aErr(0) Then
						a = http.responseText
						Set s = JSON.parse(a)
						s.Set "cdxml",molData
						s.Set "molData",molData
						jsono.Set "Structure",s
					End If
				End If
			End if
			
			hideChemicalNameFieldInReg = checkBoolSettingForCompany("hideChemicalNameFieldInReg", session("companyId"))
			if not hideChemicalNameFieldInReg then
				jsono.Set "Chemical Name",bin(rec("chemaxon_chemical_name"))
			end if
			jsono.Set "Chemical Formula",bin(rec("cd_formula"))
			' jsono.Set "Smiles",bin(rec("cd_smiles"))
			value = bin(rec("cd_molweight"))
			If IsNumeric(value) Then
				jsono.Set "Molecular Weight",CDbl(value)
			End If
			molWeightWithSalts = rec("cd_molweight")
			'smilesWithSalts = bin(rec("cd_smiles"))
			smilesWithSalts = smiles
			regSaltsView = getCompanySpecificSingleAppConfigSetting("regSaltMappingView", session("companyId"))
			regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
			Set saltRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT cd_molweight,cd_smiles,saltId, multiplicity FROM "&regSaltsView&" WHERE molId="&SQLClean(theCdId,"N","S")
			saltRec.open strQuery,jchemRegConn,3,3
			saltNames = ""
			saltCode = ""
			saltMulti = ""
			Do While Not saltRec.eof
				Set saltRec2 = server.CreateObject("ADODB.RecordSet")
				strQuery2 = "SELECT name, salt_code FROM "&regSaltsTable&" WHERE cd_id="&SQLClean(saltRec("saltId"),"N","S")
				saltRec2.open strQuery2,jchemRegConn,3,3
				' get the salt code from the salt table
				Do While Not saltRec2.eof
					saltNames = saltNames & bin(saltRec2("name")) & ", "
					saltCode = saltCode & bin(saltRec2("salt_code")) & ", "
					saltRec2.movenext
				loop
				saltMulti = saltMulti & bin(saltRec("multiplicity")) & ", "
				molWeightWithSalts = molWeightWithSalts + (saltRec("CD_MOLWEIGHT")*saltRec("MULTIPLICITY"))
				For i = 1 To saltRec("MULTIPLICITY")
					if Not IsNull(saltRec("cd_smiles")) then
						smilesWithSalts = smilesWithSalts & "." &Split(saltRec("cd_smiles")," ")(0)
					End if
				next
				saltRec.movenext
			Loop
			if saltNames <> "" then
				jsono.Set "Salt Name",bin(Mid(saltNames, 1, InStrRev(saltNames,",")-1))
			end if
			if saltCode <> "" then
				jsono.Set "Salt Code",bin(Mid(saltCode, 1, InStrRev(saltCode,",")-1))
			end if
			if saltMulti <> "" then
				jsono.Set "Salt Multiplicity",bin(Mid(saltMulti, 1, InStrRev(saltMulti,",")-1))
			end if

			saltRec.close
			Set saltRec = Nothing
			If IsNull(molWeightWithSalts) Then
				molWeightWithSalts = 0
			End if
			molWeightWithSalts = Round(molWeightWithSalts,2)
			jsono.Set "Smiles With Salts",bin(smilesWithSalts)
			jsono.Set "Molecular Weight With Salts",CDbl(bin(molWeightWithSalts))
			value = bin(rec("exact_mass"))
			If IsNumeric(value) Then
				jsono.Set "Exact Mass",CDbl(value)
			End if
		End if
		jsonDateFields.push("Date Modified Reg")

		Do While Not rec2.eof
			value = rec(CStr(rec2("actualField")))
			On Error Resume next
			If rec2("showBatchInput") = 0 then
				Set rec5 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT "&rec2("actualfield")&" FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(rec("parent_cd_id"),"N","S")
				rec5.open strQuery,jchemRegConn,0,-1
				If Not rec5.eof Then
					If Not IsNull(rec5(CStr(rec2("actualfield")))) then
						value = rec5(CStr(rec2("actualfield")))
					End if
				End If
				rec5.close
				Set rec5 = Nothing
			End If
			On Error goto 0
			If IsNull(value) Then
				value = ""
			Else
				CStr(value)
			End If
			fieldName = Replace(Trim(rec2("displayName")),".","")
			If rec2("dataType") = "drop_down" Or rec2("dataType") = "text" Or rec2("dataType") = "long_text" or rec2("dataType") = "read_only" Then
				jsono.Set fieldName,value
			End If
			If rec2("dataType") = "float" Then
				If IsNumeric(value) Then
					jsono.Set fieldName,CDbl(value)
				Else
					jsono.Set fieldName,value
				End if
			End If
			If rec2("dataType") = "int" Then
				If IsNumeric(value) Then
					jsono.Set fieldName,int(value)
				End if
			End If

			If rec2("dataType") = "multi_text" Then
				vals = Split(value,"###")
				Set L = JSON.parse("[]")
				For i = 0 To UBound(vals)
					L.push(vals(i))
				Next
				jsono.Set fieldName,L
			End If
			If rec2("dataType") = "multi_float" Then
				vals = Split(value,"###")
				Set L = JSON.parse("[]")
				For i = 0 To UBound(vals)
					If IsNumeric(vals(i)) Then
						L.push(CDbl(vals(i)))
					Else
						L.push(vals(i))
					End if
				Next
				jsono.Set fieldName,L
			End If
			If rec2("dataType") = "multi_int" Then
				vals = Split(value,"###")
				Set L = JSON.parse("[]")
				For i = 0 To UBound(vals)
					If IsNumeric(vals(i)) Then
						L.push(int(vals(i)))
					End if
				Next
				jsono.Set fieldName,L
			End If

			If rec2("dataType") = "date" Then
				If value<>"" Then
					jsono.Set fieldName,value
				End If
				jsonDateFields.push(CStr(rec2("displayName")))
			End if
			rec2.movenext
		Loop
		bin(rec("chemaxon_chemical_name"))
		jsono.Set "Registration Id",displayRegNumber
		jsono.Set "isBatch", isBatch
		If isBatch Then
			jsono.Set "parentRegNumber", parentRegNumber
		End If
		jsono.Set "_recordType","protein"
		jsono.Set "_applicationName","Registration"
		
		groupIdArg = groupId
		If IsNull(groupIdArg) Then
			groupIdArg = 0
		End If
		jsono.Set "_groupId",CInt(groupIdArg)

		For Each key in jsono.keys()
			If jsono.get(key) = "-1" Then
				jsono.Set key,""
			End if
		Next


		Set rec2 =server.CreateObject("ADODB.RecordSet")
		If isBatch then
			If groupId<>0 Then
				strQuery = "SELECT * FROM groupCustomFieldFields WHERE groupId="&SQLClean(groupId,"N","S")&" AND isLink=1"
			else
				strQuery = "SELECT * FROM customFields WHERE isLink=1"
			End If
		Else
			If groupId<>0 Then
				strQuery = "SELECT * FROM groupCustomFieldFields WHERE groupId="&SQLClean(groupId,"N","S")&" AND isLink=1"
			else
				strQuery = "SELECT * FROM customFields WHERE isLink=1"
			End If
		End if
		rec2.open strQuery,jchemRegConn,3,3
		Do While Not rec2.eof
			regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
			regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
			value = rec(CStr(rec2("actualField")))
			Set rec3 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(value,"T","S")&" OR reg_id="&SQLClean(value&regBatchNumberDelimiter&padWithZeros(0,regBatchNumberLength),"T","S")
			rec3.open strQuery,jchemRegConn,0,-1
			If Not rec3.eof Then
				Set otherJSON = sendProteinToSearchTool(CStr(rec3("cd_id")),false,false)
				Set D = otherJSON.Get("data")
				For Each key In D.keys()
					If Not jsono.exists(key) Then
						jsono.Set key,D.Get(key)
					End if
				next
			End If
			rec3.close
			Set rec3 = nothing
			rec2.movenext
		Loop
		rec2.close
		Set rec2 = nothing

		customerDataPublishUrl = ""
		Set urlRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT publishDataToCustomerUrl FROM companySettings where companyId="&SQLClean(session("companyId"),"N","S")
		urlRec.open strQuery,conn,3,3
		If Not urlRec.eof Then
			customerDataPublishUrl = urlRec("publishDataToCustomerUrl")
		End If
		urlRec.close
	
		apiKey = ""
		strQuery = "SELECT apiKey FROM apiKeys where companyId="&SQLClean(session("companyId"),"N","S")
		urlRec.open strQuery,conn,3,3
		If Not rec.eof Then
			apiKey = urlRec("apiKey")
		End If
		urlRec.close
		Set urlRec = Nothing
		
		If session("companyHasFT") then
			Set config = JSON.parse("{}")
			dbName = session("FTDB")
			config.Set "dbName",dbName
			config.Set "apiKey",apiKey
			config.Set "companyId",session("companyId")
			config.Set "updateFieldName","Registration Id"
			config.Set "updateFieldValue",displayRegNumber
			config.Set "dateFields",jsonDateFields
			config.Set "customerDataPublishUrl",customerDataPublishUrl

			Set jsonHolder = JSON.parse("{}")
			jsonHolder.Set "config",config
			jsonHolder.Set "data",jsono
		End If
		If session("companyHasFTLiteReg") And session("FTDBLiteReg")<>session("FTDB") Then
			Set config = JSON.parse("{}")
			dbName = session("FTDBLiteReg")
			config.Set "dbName",dbName
			config.Set "apiKey",apiKey
			config.Set "companyId",session("companyId")
			config.Set "updateFieldName","Registration Id"
			config.Set "updateFieldValue",displayRegNumber
			config.Set "dateFields",jsonDateFields
			config.Set "customerDataPublishUrl",customerDataPublishUrl

			Set jsonHolder2 = JSON.parse("{}")
			jsonHolder2.Set "config",config
			jsonHolder2.Set "data",jsono
		End if
		If sendFile then
			folderName = "inbox-ft"
			If whichClient="DEMO" And whichServer<>"PROD" Then
				'folderName = "inbox-dev"
			End If
			If session("companyHasFT") then		
				set fs=Server.CreateObject("Scripting.FileSystemObject")
				set tfile=fs.OpenTextFile("c:\"&folderName&"\"&groupId&"_"&justReg&"_"&getRandomString(16)&"_"&theCdId&".json",8,true,-1)
				tfile.WriteLine(JSON.stringify(jsonHolder))
				tfile.close
				set tfile=nothing
				set fs=Nothing
			End If
			If session("companyHasFTLiteReg") And session("FTDBLiteReg")<>session("FTDB") Then
				set fs=Server.CreateObject("Scripting.FileSystemObject")
				set tfile=fs.OpenTextFile("c:\"&folderName&"\"&groupId&"_"&justReg&"_"&getRandomString(16)&"_"&theCdId&"_lite.json",8,true,-1)
				tfile.WriteLine(JSON.stringify(jsonHolder2))
				tfile.close
				set tfile=nothing
				set fs=Nothing
			End if
		Else
			Set sendProteinToSearchTool = jsonHolder
		End If
		'FT-94
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE parent_cd_id="&SQLClean(theCdId,"N","S")
		rec.open strQuery,jchemRegConn,0,-1
		Do While Not rec.eof
			a = sendProteinToSearchTool(rec("cd_id"),sendFile,abandon)
			rec.movenext
		loop
		'sendProteinToSearchTool = "complete"
	' End if
end function
%>