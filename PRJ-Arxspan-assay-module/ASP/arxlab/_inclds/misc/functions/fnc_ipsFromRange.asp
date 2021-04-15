<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function validateApiKey(apiKey)
    Set validateApiKey_d = JSON.parse("{}")
	validateApiKey_d.Set "ipAddress", CStr(request.servervariables("REMOTE_ADDR"))
	validateApiKey_d.Set "apiKey", apiKey
	validateApiKey_data = JSON.stringify(validateApiKey_d)
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	' ignore ssl cert errors
	http.setOption 2, 13056
    postUrl = getInvIp() & "/ipInRange/"
	http.open "POST",postUrl,True
	http.setRequestHeader "Content-Type","application/json"
	http.setRequestHeader "Content-Length",Len(validateApiKey_data)
	http.SetTimeouts 120000,120000,120000,120000	
	http.send validateApiKey_data
	http.waitForResponse(60)
	Set responseParsed = JSON.parse(http.responseText)
	validateApiKey = responseParsed.result = "success"
    if validateApiKey then
        companyId = responseParsed.companyId
        session("companyId") = companyId
	end if
end function
%>