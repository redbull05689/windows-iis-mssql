<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->

<%isApiPage = true%>
<%
function getXMLTag(tagName,inString)
	instring = Replace(instring,vbcrlf,"$$$%%%^%^$%^$%^$%$%^45")
	instring = Replace(instring,vbcr,"$$$%%%^%^$%^$%^$%$%^45")
	instring = Replace(instring,vblf,"$$$%%%^%^$%^$%^$%$%^45")
	Set re = new RegExp
	re.IgnoreCase = true
	re.Global = true

	re.Pattern = "<"&tagName&">(.*?)</"&tagName&">"
	re.multiline = true
	Set Matches = re.execute(inString)
	If Matches.count > 0 Then
		m = Matches.Item(0).subMatches(0)
		m = Replace(m,"$$$%%%^%^$%^$%^$%$%^45",vbcrlf)
		getXMLTag = m
	else
		getXMLTag = "error"
	End If
	set re = nothing
end function

function removeTags(inString)
	'replaces all the tags in html with spaces
	'used to remove tags from cas scraping and also used to create a clean preparation text for search
	If isnull(inString) Then
		inString = ""
	End if
	Set RegEx = New regexp
	RegEx.Pattern = "<[^>]*>"
	RegEx.Global = True
	RegEx.IgnoreCase = True
	removeTags = RegEx.Replace(inString," ")
	Set RegEx = nothing
end Function


'https://restdemo.chemaxon.com/apidocs/
If whichServer = "PROD" Then
	URL = "http://10.10.10.40:8080/webservices/rest-v0/data/WUXI_LABNETWORK/table/casnumberlookup/search"
Else
	URL = "http://10.10.10.41:8080/webservices/rest-v0/data/WUXI_LABNETWORK/table/casnumberlookup/search"
End if
casId = request.querystring("casId")
casName = request.querystring("casName")
molData = request.querystring("molStr")
searchType = request.querystring("searchType")
molDataStr = "testmol" & "<br>" & molData

conditionStr = ""
searchOptStr = ""
str = ""

If (searchType = "subSearch") Then
	If Len(casId) > 0 Then
		conditionStr = """cas"":{""$contains"":"&casId&"}"
	End If
	
	If Len(casName) > 0 And Len(conditionStr) > 0 Then
		conditionStr = conditionStr + ", ""$and"":[{""traditional_name"":{""$contains"":"""&casName&"""}}]"
	ElseIf Len(casName) > 0 And Len(conditionStr) = 0 Then
		conditionStr = """traditional_name"":{""$contains"":"""&casName&"""}"
	End If
	
	If Len(molData) > 0 Then
		searchOptStr = """searchOptions"":{""searchType"": ""SUBSTRUCTURE"",""queryStructure"":""testmol<br>"&molData&"""}"
	End If
	
	If Len(conditionStr) > 0 Then
		str = """filter"": {""conditions"":{"&conditionStr&"} }"
	ElseIf Len(searchOptStr) > 0 And Len(str) > 0 Then
		str = str & ", " & searchOptStr
	ElseIf Len(searchOptStr) > 0 And Len(str) = 0 Then
		str = searchOptStr
	End If
Else
	If Len(casId) > 0 Then
		conditionStr = """cas"":{""$eq"":"&casId&"}"
	End If
	
	If Len(casName) > 0 And Len(conditionStr) > 0 Then
		conditionStr = conditionStr + ", ""$and"":[{""traditional_name"":{""$eq"":"""&casName&"""}}]"
	ElseIf Len(casName) > 0 And Len(conditionStr) = 0 Then
		conditionStr = """traditional_name"":{""$eq"":"""&casName&"""}"
	End If
	
	If Len(molData) > 0 Then
		searchOptStr = """searchOptions"":{""searchType"": ""FULL"", ""atomMatching"":{""isotopeMatching"": ""EXACT"", ""chargeMatching"": ""EXACT"", ""radicalMatching"":""EXACT""}, ""queryStructure"":""testmol<br>"&molData&"""}"
	End If
	
	If Len(conditionStr) > 0 Then
		str = """filter"": {""conditions"":{"&conditionStr&"} }"
	ElseIf Len(searchOptStr) > 0 And Len(str) > 0 Then
		str = str & ", " & searchOptStr
	ElseIf Len(searchOptStr) > 0 And Len(str) = 0 Then
		str = searchOptStr
	End If
End If

jsonStringData = "{""monitorId"":"""", "&str&" ,""paging"": { ""offset"": 0, ""limit"": 15 }, ""display"": {""include"": [""cd_id"", ""traditional_name"", ""cd_molweight"", ""cd_formula"", ""cdxml"", ""cas"", ""cd_structure""], ""parameters"": { ""cd_structure-display"": { ""include"": [""image"", ""structureData""], ""parameters"": { ""structureData"": ""mol:V3"" } } } } }"

Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.open "POST",URL,True
http.setRequestHeader "Content-Type","application/json" 
http.setRequestHeader "Content-Length",Len(jsonStringData)
http.SetTimeouts 120000,120000,120000,120000
http.send jsonStringData
http.waitForResponse(600)

resp = http.responseText
'Dim jRet
'set jRet = JSON.Parse(resp)
'response.write jRet
response.write resp

%>