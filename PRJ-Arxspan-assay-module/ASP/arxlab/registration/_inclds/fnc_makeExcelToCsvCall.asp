<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function makeExcelToCsvCall(filename, fileExt, appName)
	data = "{""connectionId"":"""&session("servicesConnectionId")&""",""appName"": """ & appName & """,""newFileName"": """ + filename + """, ""fileExtension"": """ + fileExt + """}"
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.setOption 2, 13056

	urlhost = "dev"
	if whichServer = "MODEL" then
		urlhost = "model"
	elseif whichServer = "BETA" then
		urlhost = "beta"
	elseif whichServer = "PROD" then
		urlhost = "eln"
	end if

	http.open "POST", "https://" & urlhost & ".arxspan.com/excel2csv/api/values",True
	http.setRequestHeader "Content-Type","application/json"
	http.setRequestHeader "Content-Length", Len(data)
	http.setRequestHeader "Authorization", session("jwtToken")
	http.SetTimeouts 120000,120000,120000,120000
	http.send data
	http.waitForResponse(60)

	makeExcelToCsvCall = http.responseText
End Function
%>