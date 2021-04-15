<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->

<%

userInputValue = request.form("userInputValue")

Call getconnected
Set nlRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT apiKey FROM apiKeys WHERE companyId="&SQLClean(session("companyId"),"N","S")
nlRec.open strQuery,connAdm,3,3
' Make sure the user owns the experiment that is being linked to
If Not nlRec.eof Then
	

	Select Case whichServer
	Case "DEV"
		regApiServerBaseUrl = "http://stage.arxspan.com" ' HTTPS HAS BEEN CHANGED TO HTTP BECAUSE OF CERTIFICATE ISSUES
	Case "MODEL"
		regApiServerBaseUrl = "https://model.arxspan.com"
	Case "BETA"
		regApiServerBaseUrl = "https://beta.arxspan.com"
	Case "PROD"
		regApiServerBaseUrl = "https://eln.arxspan.com"
	End Select

	URL = regApiServerBaseUrl&mainAppPath&"/apis/reg/getRegIdSuggestions/" 
	
	set jsonData = JSON.parse("{}")
	jsonData.set "apiKey", CStr(nlRec("apiKey"))
	jsonData.set "userInputValue", userInputValue

	jsonStringData = JSON.stringify(jsonData)

	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	'http.setOption 2, 13056
	http.open "POST",URL,True
	http.setRequestHeader "Content-Type","application/x-www-form-urlencoded" 
	http.setRequestHeader "Content-Length",Len(jsonStringData)
	' Give the typeahead 16 seconds to come back (or not)
	http.SetTimeouts 9000,9000,9000,9000
	http.send jsonStringData
	http.waitForResponse(60)
	
    responseText = http.responseText
Else
	responseText = "{""errors"": ""No API key found.""}"
End If
response.write responseText

%>