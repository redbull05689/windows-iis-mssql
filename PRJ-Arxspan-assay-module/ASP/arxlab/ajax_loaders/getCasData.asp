<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../js/jsonEncoder.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
chemAxonRootUrl = getCompanySpecificSingleAppConfigSetting("chemAxonEndpointUrl", session("companyId"))
If 1=2 then
	url = "http://www.chemspider.com/Search.asmx/AsyncSimpleSearchOrdered?query="&Server.urlencode(request.querystring("casId"))&"&orderBy=eRscCount&orderDirection=eDescending&token=4ab516fa-9cf8-4f0b-b725-4fb3c1f71a19"
    set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP") 
    xmlhttp.open "GET", url, True
    xmlhttp.send "" 
	xmlhttp.waitForResponse(60)
    html = xmlhttp.responseText
	set xmlhttp = nothing 
	rid = Trim(Replace(Replace(removeTags(html),vbcr,""),vblf,""))

	url = "http://www.chemspider.com/Search.asmx/GetAsyncSearchResult?rid="&rid&"&token=4ab516fa-9cf8-4f0b-b725-4fb3c1f71a19"
    set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP") 
    xmlhttp.open "GET", url, True 
    xmlhttp.send "" 
	xmlhttp.waitForResponse(60)
    html = xmlhttp.responseText
	set xmlhttp = nothing 
	csid = getXMLTag("int",html)

    url = "http://www.chemspider.com/Chemical-Structure."&csid&".html"
    set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP") 
    xmlhttp.open "GET", url, True 
    xmlhttp.send "" 
	xmlhttp.waitForResponse(60)
    html = xmlhttp.responseText
	html = Replace(html,vbcrlf,"")
	html = Replace(html,vbcr,"")
	html = Replace(html,vblf,"")
	html = Replace(html,vbtab,"")
	set xmlhttp = nothing 


	Set re = new RegExp
	re.IgnoreCase = true
	re.Global = false

	re.Pattern = "<h1 class=""h4"">(.*?)</h1>"
	re.multiline = true
	Set Matches = re.execute(html)
	If Matches.count > 0 Then
		name = Trim(removeTags(Matches.Item(0).Submatches(0)))
	End If
	re.Pattern = "Molecular Formula(.*?)</li>"
	re.multiline = true
	Set Matches = re.execute(html)
	If Matches.count > 0 then
		formula = Trim(Replace(removeTags(Matches.Item(0).Submatches(0))," ",""))
	End If
	're.Pattern = "Monoisotopic mass:(.*?)Da</li>"
	re.Pattern = "Average mass(.*?)Da</li>"
	re.multiline = true
	Set Matches = re.execute(html)
	If Matches.count > 0 then
		molecularWeight = Trim(removeTags(Matches.Item(0).Submatches(0)))
	End If
	
	If molecularWeight <> "" And formula <> "" And name <> "" Then
		response.write("['"&Replace(Trim(name),"'","\'")&"','"&Replace(Trim(molecularWeight),"'","\'")&"','"&Replace(Trim(formula),"'","\'")&"']")
	Else
		response.write("error")
	End if

	Set Matches = Nothing
	Set re = Nothing
ElseIf (request.querystring("casId") = "00100") Then
	'CAS DATA FROM NIST WEBSITE
	url = "http://webbook.nist.gov/cgi/cbook.cgi?ID="&request.querystring("casId")&"&Units=SI" 
    set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP") 
    xmlhttp.open "GET", url, true 
    xmlhttp.send "" 
	xmlhttp.waitForResponse(60)
    html = xmlhttp.responseText
	set xmlhttp = nothing 

	Set re = new RegExp
	re.IgnoreCase = true
	re.Global = false

	re.Pattern = "<h1 id=""Top"">(.*?)</h1>"
	re.multiline = True
	Set Matches = re.execute(html)
	If Matches.count > 0 Then
		name = removeTags(Matches.Item(0).Submatches(0))
	End If
	re.Pattern = "Formula.*?:</strong>(.*?)</li>"
	re.multiline = true
	Set Matches = re.execute(html)
	If Matches.count > 0 then
		formula = Replace(removeTags(Matches.Item(0).Submatches(0))," ","")
	End If
	re.Pattern = "Molecular weight.*?:</strong>(.*?)</li>"
	re.multiline = true
	Set Matches = re.execute(html)
		
	If Matches.count > 0 then
		molecularWeight = Replace(removeTags(Matches.Item(0).Submatches(0))," ","")
	End If
	
	'Get the structure 11/28/16
	re.Pattern = "This structure is also available as a <a href=(.*?)>2d Mol file</a>"
	re.multiline = true
	Set Matches = re.execute(html)
	
	If Matches.count > 0 then
		molDataURL = Replace(removeTags(Matches.Item(0).Submatches(0))," ","")
		
		url = "http://webbook.nist.gov"&Mid(molDataURL, 2, (Len(molDataURL)-2))
		'Get the id of the file from the URL string to replace
		fId = split(Mid(molDataURL, 2, (Len(molDataURL)-2)), "=")
		set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP") 
		xmlhttp.open "GET", url, True
		xmlhttp.send "" 
		xmlhttp.waitForResponse(60)
		cdxml = xmlhttp.responseText
		set xmlhttp = nothing 
		
		cdxml = getCDXTemplate(cdxml)
	Else
		cdxml = "ERROR"
	End If
	
	If molecularWeight <> "" And formula <> "" And name <> "" Then
		response.write("['"&Replace(Trim(name),"'","\'")&"','"&Replace(Trim(molecularWeight),"'","\'")&"','"&Replace(Trim(formula),"'","\'")&"','"&server.URLEncode(cdxml)&"','"&request.querystring("casId")&"']")
	Else
		response.write("error")
	End if

	Set Matches = Nothing
	Set re = nothing
	
Else
	'https://restdemo.chemaxon.com/apidocs/
	URL = chemAxonRootUrl & "data/" & elnChemJsonSearchDataBaseName & "/table/casnumberlookup/search"
	casId = request.querystring("casId")
	casCdId = request.querystring("casCdId")
	casName = request.querystring("casName")
	searchType = request.querystring("searchType")
				
	conditionStr = ""
	searchOptStr = ""
	Set respJson = JSON.parse("{}")
	Set dataArray = JSON.parse("[]")
	str = ""
	
	bufferStr = ""
	operatorStr = " = "
	getConnectedCasDb
	
	If searchType = "subSearch" Then
		bufferStr = "%"
		operatorStr = " like "
	End If
	
	strWhere = ""
	pageNumber = 1
	
	If casCdId <> "" Then
		strWhere = "cd_id" & operatorStr & "'" & bufferStr & casCdId & bufferStr & "' "
	Else
		If casId <> "" Then
			strWhere = "cas" & operatorStr & "'" & bufferStr & casId & bufferStr & "' "
		End If
		If casName <> "" Then
			If strWhere <> "" Then
				If searchType <> "AND" Then
					strWhere = strWhere & "OR "
				Else
					strWhere = strWhere & "AND "
				End If
			End If
			strWhere = "traditional_name" & operatorStr & "'" & bufferStr & casName & bufferStr & "' "
		End If
	End If
	
	strQuery = "SELECT  cd_id, traditional_name, cdxml, cas, cd_molweight, cd_formula "
	strQuery = strQuery & "FROM (SELECT ROW_NUMBER() OVER (ORDER BY cd_molweight) AS RowNum, * FROM casNumberLookup WHERE "
	strQuery = strQuery & strWhere
	strQuery = strQuery & ") AS RowConstrainedResult WHERE RowNum >= "
	strQuery = strQuery & CStr((15 * pageNumber) - 15) & "AND RowNum < " & CStr(15 * pageNumber) & " "
	strQuery = strQuery & "ORDER BY RowNum"
	
	count = 0
	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open strQuery,casDbConn,adOpenStatic,adLockReadOnly
	Do While Not rec.eof
		If searchType = "subSearch" Then
			' Get the structure image
			conditionStr = """cd_id"":{""$eq"":" & rec("cd_id") & "}"
			searchOptStr = """searchOptions"":{""searchType"": ""FULL""}"
			
			If Len(conditionStr) > 0 Then
				str = """filter"": {""conditions"":{"&conditionStr&"} }"
			ElseIf Len(searchOptStr) > 0 And Len(str) > 0 Then
				str = str & ", " & searchOptStr
			ElseIf Len(searchOptStr) > 0 And Len(str) = 0 Then
				str = searchOptStr
			End If
		
			jsonStringData = "{""monitorId"":"""", "&str&" ,""paging"": { ""offset"": 0, ""limit"": 1 }, ""display"": {""include"": [""cd_id"", ""cd_structure""]}}"
			
			Set http = CreateObject("MSXML2.ServerXMLHTTP")
			http.open "POST",URL,True
			http.setRequestHeader "Content-Type","application/json" 
			http.setRequestHeader "Content-Length",Len(jsonStringData)
			http.SetTimeouts 120000,120000,120000,120000
			http.send jsonStringData
			http.waitForResponse(60)

			responseText = http.responseText
			If responseText <> "" Then
				Set img = JSON.Parse(http.responseText)
			End If
		End If
		
		Set dataItem = JSON.parse("{}")
		dataItem.Set "cd_formula", pEscape(rec("cd_formula"))
		dataItem.Set "traditional_name", pEscape(rec("traditional_name"))
		dataItem.Set "cd_molweight", pEscape(rec("cd_molweight"))
		dataItem.Set "cas", pEscape(rec("cas"))
		dataItem.Set "cdxml", pEscape(rec("cdxml"))
	
		If isObject(img) Then
			If img.exists("data") Then
				dataItem.Set "structureData", pEscape(img.get("data"))			
			End If
		End If

		count = count + 1
		rec.movenext

		dataArray.push dataItem

	Loop

	respJson.Set "data", dataArray
	respJson.Set "currentSize", CStr(count)
	
	rec.close
	Set rec = Nothing
	disconnectCasDb
	
	response.write JSON.stringify(respJson)
End if
%>