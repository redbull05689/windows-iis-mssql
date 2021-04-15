<%
set scriptShell = createobject("WScript.Shell")
whichServer = scriptShell.ExpandEnvironmentStrings("%WHICHSERVER%")
Set scriptShell = Nothing
%>
<%
	isApiPage = true
%>
<!-- #include file="__whichServer.asp"-->
<!-- #include virtual="/arxlab/inventory2/_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/misc/functions/fnc_ipsFromRange.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
appServerIP = getCompanySpecificSingleAppConfigSetting("appServerIp", session("companyId"))
Function getRegApiServerName()
	serverName = "http://"&appServerIP&":5101/"
	getRegApiServerName = serverName
End Function

Function getJSONval(tagName,inString)
	instring = Replace(instring,vbcrlf,"$$$%%%^%^$%^$%^$%$%^45")
	instring = Replace(instring,vbcr,"$$$%%%^%^$%^$%^$%$%^45")
	instring = Replace(instring,vblf,"$$$%%%^%^$%^$%^$%$%^45")
	Set re = new RegExp
	re.IgnoreCase = true
	re.Global = true

	re.Pattern = "[""']{1}"&tagName&"[""']{1}\s*:\s*[""']{1}(.*?)[""']{1}"
	re.multiline = true
	Set Matches = re.execute(inString)
	If Matches.count > 0 Then
		m = Matches.Item(0).subMatches(0)
		m = Replace(m,"$$$%%%^%^$%^$%^$%$%^45",vbcrlf)
		getJSONval = m
	Else
		getJSONval = False
	End If
	Set re = Nothing
End Function

' Helper function to short circuit this API call and return
' the specified error to the user.
function returnApiError(errorMsg)
	set errorJson = JSON.parse("{}")
	errorJson.set "status", "error"

	set errorList = JSON.parse("[]")
	errorList.push(errorMsg)
	errorJson.set "errors", errorList
	response.write JSON.stringify(errorJson)
	response.end
end function

' Helper function to retrieve companyId from the given apiKey.
function getCompanyIdFromApiKey(apiKey)
	companyId = -1

	call getConnectedAdm
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT companyId FROM apiKeys WHERE apiKey=" & SQLClean(apiKey,"T","S")	
	rec.open strQuery,connAdm,0,-1

	if not rec.eof then
		companyId = rec("companyId")
	end if
	set rec = nothing

	if companyId = -1 then
		returnApiError("Invalid API key provided.")
	end if

	getCompanyIdFromApiKey = companyId
end function

apiKey = getJSONval("apiKey",data)

If apiKey = False Then
	returnApiError("No API key provided")
End if

If Not validateApiKey(apiKey) Then
	returnApiError("Access Prohibited")
End if

%>