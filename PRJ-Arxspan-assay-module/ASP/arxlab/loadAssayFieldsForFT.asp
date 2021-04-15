<%
' Needs isApiPage=True so that FT can call this
isApiPage=True
%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/experiments/common/functions/fnc_fetchWorkflowData.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", request.querystring("companyId"))
disableFTLite = checkBoolSettingForCompany("disableFTLite", request.querystring("companyId"))
mainAssayUrl = getCompanySpecificSingleAppConfigSetting("assayEndpointUrl", request.querystring("companyId"))
mainInvURL = getCompanySpecificSingleAppConfigSetting("mainInvUrlEndpoint", request.querystring("companyId"))
hideSmallMolecule = checkBoolSettingForCompany("hideSmallMolecule", request.querystring("companyId"))
server.scriptTimeout=3600

response.buffer = false
response.charset = "UTF-8"
response.codePage = 65001
regEnabled=True


'If request.servervariables("REMOTE_ADDR") <> "8.20.189.21" then
'	response.redirect("/login.asp")
'End if

session("companyId") = request.querystring("companyId")
If session("companyId") = "62" Then
	session("overrideDB")="BROAD"
End if
session("userId") = request.querystring("userId")

%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
Select Case whichServer
	Case "DEV"
		Response.AddHeader "Access-Control-Allow-Origin", "https://ftdev.arxspan.com"
	Case "MODEL"
		Response.AddHeader "Access-Control-Allow-Origin", "https://ft2.arxspan.com"
	Case "BETA"
		Response.AddHeader "Access-Control-Allow-Origin", "https://ftbeta.arxspan.com"
	Case "PROD"
		Response.AddHeader "Access-Control-Allow-Origin", "https://ft.arxspan.com"
End select

call loginUser(request.querystring("userId"))

session("jwtToken") = request.querystring("jwt")

Function Konvert(strIn)
	newText = ""
	Dim i
	For i = 1 To Len(strIn)
		ch = Mid(strIn,i,1)
		co = ascw(ch)
		If co<0 Then
			co = co + 65536
		End if
		If co<128 Then
			newText = newText & ch
		Else
			newText = newText & "&#"&co&";"
		End if
	Next
	Konvert = newText
End Function

Function getAssayFieldsAndPerms()
	data = "{""connectionId"":"""&session("servicesConnectionId")&""",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&"""}"
	' Switching this to use the session variable instead of a whichServer variable because that wasn't defined when whichServer was imported.
	http.open "POST",mainAssayUrl&"/elnConnection/",True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(data)
	http.SetTimeouts 120000,120000,120000,120000
	http.send data
	http.waitForResponse(60)

	data = "{""connectionId"":"""&session("servicesConnectionId")&"""}"
	' Switching this to use the session variable instead of a whichServer variable because that wasn't defined when whichServer was imported.
	http.open "POST",mainAssayUrl&"/getFTKeys/",True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(data)
	http.SetTimeouts 120000,120000,120000,120000
	http.send data
	http.waitForResponse(60)

	Set getAssayFieldsAndPerms = JSON.parse(http.responseText)
End Function

Function getRegFields()
	Set fields = JSON.parse("[[""Date Created Reg"", ""Date Created Reg"", ""date"", ""Reg""],[""Date Modified Reg"", ""Date Modified Reg"", ""date"", ""Reg""],[""Group Name"", ""Group Name"", ""text"", ""Reg""],[""Project"", ""Project"", ""text"", ""Reg""],[""Registration Id"", ""Registration Id"", ""text"", ""Reg""],[""User Created Reg"", ""User Created Reg"", ""text"", ""Reg""],[""User Modified Reg"", ""User Modified Reg"", ""text"", ""Reg""]]")

	if not hideSmallMolecule then
		fields.push(JSON.parse("[""Chemical Formula"", ""Chemical Formula"", ""text"", ""Reg""]"))
		hideChemicalNameFieldInReg = checkBoolSettingForCompany("hideChemicalNameFieldInReg", session("companyId"))
		if not hideChemicalNameFieldInReg then
			fields.push(JSON.parse("[""Chemical Name"", ""Chemical Name"", ""text"", ""Reg""]"))
		end if
		fields.push(JSON.parse("[""Exact Mass"", ""Exact Mass"", ""number"", ""Reg""]"))
		fields.push(JSON.parse("[""Molecular Weight"", ""Molecular Weight"", ""number"", ""Reg""]"))
		fields.push(JSON.parse("[""Molecular Weight With Salts"", ""Molecular Weight With Salts"", ""number"", ""Reg""]"))
		fields.push(JSON.parse("[""Smiles"", ""Smiles"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Smiles With Salts"", ""Smiles With Salts"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Structure"", ""Structure"", ""chem"", ""Reg""]"))
		fields.push(JSON.parse("[""Parent Record"", ""Parent Record"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Batch Record"", ""Batch Record"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Parent ID"", ""Parent ID"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Batch ID"", ""Batch ID"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Salt Name"", ""Salt Name"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Salt Code"", ""Salt Code"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Salt Multiplicity"", ""Salt Multiplicity"", ""text"", ""Reg""]"))
		fields.push(JSON.parse("[""Registration Source"", ""Registration Source"", ""text"", ""Reg""]"))
	end if

	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT displayName, dataType FROM customFields ORDER by displayName"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		displayName = Konvert(Replace(Replace(rec("displayName"),"""","\"""),".",""))
		''displayName = Replace(displayName,"'","\'")
		If rec("dataType") = "drop_down" Or rec("dataType") = "text" Or rec("dataType") = "multi_text" Or rec("dataType") = "long_text" Then
			theType = "text"
		End if
		If rec("dataType") = "int" Or rec("dataType") = "float" Or rec("dataType") = "multi_int" Or rec("dataType") = "multi_float" Then
			theType = "number"
		End If
		If rec("dataType") = "date" Then
			theType = "date"
		End If

		if (hideSmallMolecule and displayName <> "Stereochemistry") or not hideSmallMolecule then
			fields.push(JSON.parse("["""&displayName&""","""&displayName&""","""&theType&""",""Reg""]"))
		end if
		rec.movenext
	loop
	Call disconnectJchemReg
	Set getRegFields = fields
End function

Function getInventoryFieldsAndPerms()
	usersICanSee = "[" & getUsersICanSee() & "]"
	data = "{""connectionId"":"""&session("servicesConnectionId")&""",""usersICanSee"":"&usersICanSee&",""userId"":"&session("userId")&",""whichClient"":"""&replace(whichClient,"""","\""")&"""}"
	' Switching this to use the session variable instead of a whichServer variable because that wasn't defined when whichServer was imported.
	http.open "POST",mainInvURL&"/elnConnection/",True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(data)
	http.SetTimeouts 120000,120000,120000,120000
	http.send data
	http.waitForResponse(60)

	data = "{""connectionId"":"""&session("servicesConnectionId")&"""}"
	' Switching this to use the session variable instead of a whichServer variable because that wasn't defined when whichServer was imported.
	http.open "POST",mainInvURL&"/getFTKeys/",True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(data)
	http.SetTimeouts 120000,120000,120000,120000
	http.send data
	http.waitForResponse(120)
	Set getInventoryFieldsAndPerms = JSON.parse(http.responseText)

End Function

Function getRequestTypeData(apiEndpoint, addRequestItemName)
	getRequestTypeData = "["

	apiEndpoint = apiEndpoint & "?includeDisabled=true"
	apiEndpoint = apiEndpoint &  "&appName=Configuration"
	apiEndpoint = apiEndpoint & "&intents="
	apiEndpoint = apiEndpoint & "&forcedGroupIds="
	apiEndpoint = apiEndpoint & "&AsOfDate="

	set requestTypes = JSON.parse(configGet(apiEndpoint))
	requestTypeLengths = requestTypes.length

	for each requestType in requestTypes

		if isObject(requestType) then
			displayName = requestType.get("displayName")

			if displayName <> "" then
				displayName = Server.HTMLEncode(displayName)
				if requestType.exists("fields") then
					set fields = requestType.get("fields")

					for each field in fields
						fieldName = Server.HTMLEncode(field.get("displayName"))
						dataTypeId = Replace(field.get("dataTypeId"),"""","\""")
						
						if fieldName <> "" then
							ftObj = "[""" & fieldName & """, """ & fieldName & """, """ & determineWorkflowDataType(dataTypeId) & """, """ & displayName & """],"
							if not instr(getRequestTypeData, ftObj) then
								getRequestTypeData = getRequestTypeData & ftObj
							end if
						end if
					next
				end if
				getRequestTypeData = getRequestTypeData & "[""assignedGroupName"", ""assignedGroupName"", ""Text"", """ & displayName & """],"
				getRequestTypeData = getRequestTypeData & "[""author"", ""author"", ""Text"", """ & displayName & """],"
				getRequestTypeData = getRequestTypeData & "[""requestId"", ""requestId"", ""Number"", """ & displayName & """],"
				
				' Always add in the request name field. Items are linked to specific requests.
				getRequestTypeData = getRequestTypeData & "[""requestName"", ""requestName"", ""Text"", """ & displayName & """],"

				' If we want to add the request item name field, then add it to the list.
				if addRequestItemName then
					getRequestTypeData = getRequestTypeData & "[""requestItemName"", ""requestItemName"", ""Text"", """ & displayName & """],"
				end if

			end if
		end if
	next

	if len(getRequestTypeData) > 1 then
		getRequestTypeData = Left(getRequestTypeData, len(getRequestTypeData) - 1)
	end if
	getRequestTypeData = getRequestTypeData & "]"
End Function

Function getRequestTypes()
	Set getRequestTypes = JSON.parse(getRequestTypeData("/requestTypes", false))
End Function

Function getRequestItemTypes()
	set getRequestItemTypes = JSON.parse(getRequestTypeData("/requestItemTypes", true))
End Function

Function determineWorkflowDataType(dataTypeId)
	determineWorkflowDataType = "text"
	if dataTypeId = "3" or dataTypeId = "4" then
		determineWorkflowDataType = "number"
	elseif dataTypeId = "7" then
		determineWorkflowDataType = "date"
	elseif dataTypeId = "8" then
		determineWorkflowDataType = "chem"
	elseif dataTypeId = "13" then
		determineWorkflowDataType = "notebook"
	elseif dataTypeId = "14" then
		determineWorkflowDataType = "project"
	elseif dataTypeId = "15" then
		determineWorkflowDataType = "experiment"
	end if
	determineWorkflowDataType = determineWorkflowDataType
End function

Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.setOption 2, 13056
Set permsFT = JSON.parse("[]")
Set fieldsFT = JSON.parse("[]")

doRedirect = False

Call getconnectedadm
lite = request.querystring("lite")
If disableFTLite Then
	lite = ""
End if

if session("userHasFT") and lite="" then
	If session("hasAssay") Or session("hasInv") Or session("hasReg") Or session("hasOrdering") Then
		doRedirect = true
	End if

	If session("hasAssay") Then
		If session("hasAssay") And (session("assayRoleName")="Admin" Or session("assayRoleName")="Power User" Or session("assayRoleName")="User") Then
			Set o = getAssayFieldsAndPerms()
			Set fields = o.Get("fields")
			Set perms = o.Get("perms")
			For Each key In fields.keys()
				fieldsFT.push(fields.Get(key))
			next
			permsFT.push(perms)
		End if
	End If

	If session("hasInv") Then
		If session("hasInv") And (session("invRoleName")="Admin" Or session("invRoleName")="Power User" Or session("invRoleName")="User" Or session("invRoleName")="Reader") Then
			Set o = getInventoryFieldsAndPerms()
			Set fields = o.Get("fields")
			Set perms = o.Get("perms")
			For Each key In fields.keys()
				fieldsFT.push(fields.Get(key))
			next
			permsFT.push(perms)
		End if
	End If

	If session("hasReg") Then
		If session("hasReg") And (session("regRoleNumber") < 30) Then
			Set fields = getRegFields()
			For Each key In fields.keys()
				fieldsFT.push(fields.Get(key))
			Next
			If session("regRestrictedGroups") <> "" Then
				Set perms = JSON.parse("{""_groupId"":{""$nin"":["&session("regRestrictedGroups")&"]}}")
			Else
				Set perms = JSON.parse("{}")
			End if
			permsFT.push(perms)
		End if
	End if

	If session("hasOrdering") then
		Set fields = getRequestTypes()
		For Each field In fields
			fieldsFT.push(field)
		Next

		Set tables = getRequestItemTypes()
		For Each table in tables
			fieldsFT.push(table)
		Next
		permsFt.push(JSON.parse("{}"))
		permsFt.push(JSON.parse("{}"))
		
	end if

	'If ordersFlag Then
	'end if
End if
If session("companyHasFTLiteAssay") And lite="assay" Then
	If session("hasAssay") And (session("assayRoleName")="Admin" Or session("assayRoleName")="Power User" Or session("assayRoleName")="User") Then
		Set o = getAssayFieldsAndPerms()
		Set fields = o.Get("fields")
		Set perms = o.Get("perms")
		For Each key In fields.keys()
			fieldsFT.push(fields.Get(key))
		next
		permsFT.push(perms)
		doRedirect = True
	End if
End if

If session("companyHasFTLiteInventory") And lite="inventory" Then
	If session("hasInv") And (session("invRoleName")="Admin" Or session("invRoleName")="Power User" Or session("invRoleName")="User") Then
		Set o = getInventoryFieldsAndPerms()
		Set fields = o.Get("fields")
		Set perms = o.Get("perms")
		For Each key In fields.keys()
			fieldsFT.push(fields.Get(key))
		next
		permsFT.push(perms)
		doRedirect = True
	End if
End If

If session("companyHasFTLiteReg") And lite="reg" Then
	If session("hasReg") And (session("regRoleNumber") < 30) Then
		Set fields = getRegFields()
		For Each key In fields.keys()
			fieldsFT.push(fields.Get(key))
		Next
		If session("regRestrictedGroups") <> "" Then
			Set perms = JSON.parse("{""_groupId"":{""$nin"":["&session("regRestrictedGroups")&"]}}")
		Else
			Set perms = JSON.parse("{}")
		End if
		permsFT.push(perms)
		doRedirect = True
	End if
End if

If doRedirect Then
Set http = nothing
	Set newPerms = JSON.parse("{}")
	newPerms.Set "$and",permsFT

	ftPermsStr = SQLClean(JSON.stringify(newPerms),"T","S")
	strQuery = "UPDATE users SET assayFields="&SQLClean(Replace(JSON.stringify(fieldsFT),"'","\'"),"T","S")&",ftPerms="&ftPermsStr&" WHERE id="&SQLClean(session("userId"),"N","S")
	Call getconnectedadm
	connAdm.execute(strQuery)
	If 0 <> Err.Number Then
		response.write("Error connecting to database. Error number: " & Err.Number & " Error description: " & Err.Description)
	End If
End if
Response.write("DONE. User ID:" & session("userId"))
Response.write("<\br>")
Response.end()
%>