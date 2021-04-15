<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%

' Helper function to consolidate all of the reg API calls from the ASP.
' This function starts by instantiating cfg data in the session, then
' building a JSON string and POSTing that to the given API endpoint.
function makeRegApiCall(endpoint, data)
    regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
    regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
    regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
    ' Building a JSON string here instead of doing the sensible thing and using
    ' a JSON object because those are serialized differently and the Python can't
    ' handle the JSON object for some reason.
    postData = "{""companyId"": """ & session("companyId") & """, ""whichServer"":"""&whichServer&""",""regBatchNumberLength"":"&regBatchNumberLength&",""regDataBaseServerIP"":"""& aspJsonStringify(regDataBaseServerIp)&""",""regDB"":"""&regDataBaseName&""",""regMoleculesTable"":"""&regMoleculesTable&""",""request"":"&data&"}"
    Set http = CreateObject("MSXML2.ServerXMLHTTP")
    http.open "POST", getRegApiServerName() & endpoint, True
    http.setRequestHeader "Content-Type","application/json"
    http.setRequestHeader "Content-Length",Len(postData)
    http.SetTimeouts 120000,120000,120000,120000
    http.send postData
    http.waitForResponse(60)
    makeRegApiCall = http.responseText
end function

%>