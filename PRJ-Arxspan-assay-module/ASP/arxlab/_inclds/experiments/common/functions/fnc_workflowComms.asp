<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../../security/functions/fnc_getServerBaseUrl.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
configServiceEndpointUrl = getCompanySpecificSingleAppConfigSetting("configServiceEndpointUrl", session("companyId"))

Function getCustomExperimentTypes()
	getCustomExperimentTypes = "[]"
	
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.setOption 2, 13056
	http.open "GET",configServiceEndpointUrl&"/requestTypes?isConfigPage=true&appName=ELN&includeDisabled=true",False
	http.setRequestHeader "Content-Type","application/json; charset=UTF-8"
	http.setRequestHeader "Authorization", session("jwtToken")
	http.SetTimeouts 120000,120000,120000,120000
	http.send

	set workflowParse = JSON.parse(http.responseText)
    getCustomExperimentTypes = workflowParse.Get("data")
End Function
%>
