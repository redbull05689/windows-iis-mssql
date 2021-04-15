<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include virtual="/arxlab/registration/_inclds/fnc_sendProteinToSearchTool.asp"-->
<%
function removeCdIdsFromFT(theCdIds)
	Dim rec,data,config,jsonHolder
	If theCdIds <> "" then
		
		'' get CustomerSettings that are required for this operation
		regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
		regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
		jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
		regSaltsView = getCompanySpecificSingleAppConfigSetting("regSaltMappingView", session("companyId"))
		regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
		projectFieldInReg = checkBoolSettingForCompany("useProjectFieldInReg", session("companyId"))
		hideChemicalNameFieldInReg = checkBoolSettingForCompany("hideChemicalNameFieldInReg", session("companyId"))

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
		If Not urlRec.eof Then
			apiKey = urlRec("apiKey")
		End If
		urlRec.close
		Set urlRec = Nothing		

		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cd_id,groupId,just_reg,just_batch,reg_id,parent_cd_id FROM "&regMoleculesTable&" WHERE cd_id in ("&SQLClean(theCdIds,"TP","S")&")"
		rec.open strQuery,jchemRegConn,0,-1
		Do While Not rec.eof
			justReg = rec("just_reg")
			justBatch = rec("just_batch")
			regId = rec("reg_id")
			parentCdId = rec("parent_cd_id")
			cdIdIn = rec("cd_id")

			If Not IsNull(parentCdId) And parentCdId > 0 Then
				cdIdIn = cdIdIn & "," & parentCdId
			End If
			cdIdIn = "(" & cdIdIn & ")"

			projectName = ""
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT projectName FROM linksProjectRegView where cd_id in "& cdIdIn & " and companyId=" & SQLClean(session("companyId"),"N","S")
			rec2.open strQuery,conn,3,3
			If Not rec2.eof Then
				projectName = rec2("projectName")
			End If
			rec2.close
			Set rec2 = nothing
	
			thisCdId = CStr(rec("cd_id"))
			wholeRegNumber = rec("reg_id")

			If Not IsNull(rec("groupId")) Then
				groupId = rec("groupId")
			End If
			
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
			
			Set data = JSON.parse("{}")
			Set config = JSON.parse("{}")
			Set jsonDateFields = JSON.parse("[]")
			'' IDQ 5616 Add additional Deletion data						
			'' get data about this specific reg object
			Set regDataRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(thisCdId,"N","S")
			regDataRec.open strQuery,jchemRegConn,3,3			
		
			If projectFieldInReg then
				data.Set "Project",projectName
			end if

			groupIdArg = groupId
			If IsNull(groupIdArg) Then
				groupIdArg = 0
			End If

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

			data.Set "Group Name",groupName
			data.Set "User Created Reg",bin(regDataRec("user_name"))
			data.Set "User Modified Reg",bin(regDataRec("userLastModified"))
			data.Set "Date Created Reg",bin(regDataRec("cd_timestamp"))
			jsonDateFields.push("Date Created Reg")
			data.Set "Date Modified Reg",bin(regDataRec("dateLastModified"))
			data.Set "Status", "DELETED"

			if isBatch = true then
				data.Set "Parent Record", "No"
				data.Set "Batch Record", "Yes"
			else
				data.Set "Parent Record", "Yes"
				data.Set "Batch Record", "No"
			end if				

			data.Set "Parent ID", Left(wholeRegNumber, len(wholeRegNumber) - (len(regBatchNumberDelimiter) + len(justBatch)))

			if regDataRec("source") = "ELN" then
				data.Set "Registration Source", Trim(regDataRec("experiment_name"))
			else
				data.Set "Registration Source", Trim(regDataRec("source"))
			end if
		
			If isBatch Then
				data.Set "Batch ID", justBatch
			End if

			If hasStructure Then
				molData = ""

				'' we need to make a jchem call to get molData and cdxml data about this reg item
				If regDataRec("cd_smiles") <> "" Then
										
					displayMolJson = CX_getStructureByCdId(jChemRegDB,regMoleculesTable,theCdId,"mol:V3")
					Set displayMol = JSON.parse(displayMolJson)
					If IsObject(displayMol) And displayMol.Exists("structure") Then
						molData = displayMol.Get("structure")
					End If

					'' make the jchem call to standardize if we have molData
					If molData <> "" Then
						smiles = CX_standardize(aspJsonStringify(molData),"mol:V3",defaultStandardizerConfig,"smiles")
						data.Set "Smiles", smiles

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

				Set s = JSON.parse("{}")
				s.Set "cdxml",molData
				s.Set "molData",molData
				data.Set "Structure",s

				molWeightWithSalts = regDataRec("cd_molweight")				
				smilesWithSalts = smiles						
			End If	

			jsonDateFields.push("Date Modified Reg")

			if not hideChemicalNameFieldInReg then
				data.Set "Chemical Name",bin(regDataRec("chemaxon_chemical_name"))
			end if

			data.Set "Chemical Formula",bin(regDataRec("cd_formula"))
			value = bin(regDataRec("cd_molweight"))
			If IsNumeric(value) Then
				data.Set "Molecular Weight",CDbl(value)
			End If

			'' if the company uses any salts in their reg system, we need to include salt name, salt code, etc.
			If regSaltsView <> "" And regSaltsTable <> "" Then
				molWeightWithSalts = regDataRec("cd_molweight")					
				smilesWithSalts = smiles					
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
					data.Set "Salt Name",bin(Mid(saltNames, 1, InStrRev(saltNames,",")-1))
				end if
				if saltCode <> "" then
					data.Set "Salt Code",bin(Mid(saltCode, 1, InStrRev(saltCode,",")-1))
				end if
				if saltMulti <> "" then
					data.Set "Salt Multiplicity",bin(Mid(saltMulti, 1, InStrRev(saltMulti,",")-1))
				end if
						
				Set saltRec = Nothing
				If IsNull(molWeightWithSalts) Then
					molWeightWithSalts = 0
				End if
				molWeightWithSalts = Round(molWeightWithSalts,2)
				data.Set "Smiles With Salts",bin(smilesWithSalts)
				data.Set "Molecular Weight With Salts",CDbl(bin(molWeightWithSalts))
				value = bin(regDataRec("exact_mass"))
				If IsNumeric(value) Then
					data.Set "Exact Mass",CDbl(value)
				End if
			End If
			
			'' we need to get any custom field data as well about the reg object
			Set customFieldsRec =server.CreateObject("ADODB.RecordSet")
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
			customFieldsRec.open strQuery,jchemRegConn,3,3

			'' Add any custom field reg data
			Do While Not customFieldsRec.eof
				value = regDataRec(CStr(customFieldsRec("actualField")))
				On Error Resume next
				If customFieldsRec("showBatchInput") = 0 then
					
					'' we need to look up the data from reg the parent
					Set rec5 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT "&customFieldsRec("actualfield")&" FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(regDataRec("parent_cd_id"),"N","S")
					rec5.open strQuery,jchemRegConn,0,-1
					If Not rec5.eof Then
						If Not IsNull(rec5(CStr(customFieldsRec("actualfield")))) then
							value = rec5(CStr(customFieldsRec("actualfield")))
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
				fieldName = Replace(Trim(customFieldsRec("displayName")),".","")
				If customFieldsRec("dataType") = "drop_down" Or customFieldsRec("dataType") = "text" Or customFieldsRec("dataType") = "long_text" or customFieldsRec("dataType") = "read_only" Then
					data.Set fieldName,value				
				ElseIf customFieldsRec("dataType") = "float" Then
					If IsNumeric(value) Then
						data.Set fieldName,CDbl(value)
					Else
						data.Set fieldName,value
					End if				
				ElseIf customFieldsRec("dataType") = "int" Then
					If IsNumeric(value) Then
						data.Set fieldName,int(value)
					End if
				ElseIf customFieldsRec("dataType") = "multi_text" Then
					vals = Split(value,"###")
					Set L = JSON.parse("[]")
					For i = 0 To UBound(vals)
						L.push(vals(i))
					Next
					data.Set fieldName,L
				ElseIf customFieldsRec("dataType") = "multi_float" Then
					vals = Split(value,"###")
					Set L = JSON.parse("[]")
					For i = 0 To UBound(vals)
						If IsNumeric(vals(i)) Then
							L.push(CDbl(vals(i)))
						Else
							L.push(vals(i))
						End if
					Next
					data.Set fieldName,L				
				ElseIf customFieldsRec("dataType") = "multi_int" Then
					vals = Split(value,"###")
					Set L = JSON.parse("[]")
					For i = 0 To UBound(vals)
						If IsNumeric(vals(i)) Then
							L.push(int(vals(i)))
						End if
					Next
					data.Set fieldName,L			
				ElseIf customFieldsRec("dataType") = "date" Then
					If value<>"" Then
						data.Set fieldName,value
					End If					
				End if
				customFieldsRec.movenext
			Loop	
			customFieldsRec.close
			Set customFieldsRec = nothing					

			data.Set "Registration Id",displayRegNumber
			data.Set "isBatch", isBatch

			If isBatch Then
				data.Set "parentRegNumber", parentRegNumber
			End If
			data.Set "_recordType","protein"
			data.Set "_applicationName","Registration"

			groupIdArg = groupId
			If IsNull(groupIdArg) Then
				groupIdArg = 0
			End If
			data.Set "_groupId",CInt(groupIdArg)

			For Each key in data.keys()
				If data.get(key) = "-1" Then
					data.Set key,""
				End if
			Next

			config.Set "apiKey",apiKey
			config.Set "companyId",session("companyId")
			config.Set "customerDataPublishUrl",customerDataPublishUrl
			config.Set "dbName",session("FTDB")
			config.Set "updateFieldName","Registration Id"
			config.Set "updateFieldValue",displayRegNumber
			config.Set "dateFields", jsonDateFields
			config.Set "action","delete"			
			
			Set jsonHolder = JSON.parse("{}")
			jsonHolder.Set "config",config
			jsonHolder.Set "data",data
			
			If session("companyHasFT") then		
				set fs=Server.CreateObject("Scripting.FileSystemObject")
				set tfile=fs.OpenTextFile("c:\inbox-ft\delete_"&groupId&"_"&justReg&"_"&getRandomString(16)&"_"&thisCdId&".json",8,true,-1)
				tfile.WriteLine(JSON.stringify(jsonHolder))
				tfile.close
				set tfile=nothing
				set fs=Nothing
			End If
			If session("companyHasFTLiteReg") And session("FTDBLiteReg")<>session("FTDB") Then
				jsonHolder.Get("config").Set "dbName",session("FTDBLiteReg")
				set fs=Server.CreateObject("Scripting.FileSystemObject")
				set tfile=fs.OpenTextFile("c:\inbox-ft\delete_"&groupId&"_"&justReg&"_"&getRandomString(16)&"_"&thisCdId&"_lite.json",8,true,-1)
				tfile.WriteLine(JSON.stringify(jsonHolder))
				tfile.close
				set tfile=nothing
				set fs=Nothing
			End if
			rec.movenext
		loop
		rec.close
		Set rec = nothing
	End If
End function
%>