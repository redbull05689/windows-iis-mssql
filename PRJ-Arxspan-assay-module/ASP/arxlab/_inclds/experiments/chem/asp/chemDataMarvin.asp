<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
appServerIP = getCompanySpecificSingleAppConfigSetting("appServerIp", session("companyId"))

Response.CodePage = 65001
Response.CharSet = "UTF-8"

Dim objXmlHttp

if trim(request.form("molData")) <> "" then

	body = "molData="+Server.URLEncode(request.form("molData"))
	Set objXmlHttp = Server.CreateObject("MSXML2.ServerXMLHTTP")
	objXmlHttp.open "POST", "http://" & appServerIP & ":5105/ChemDataMarvin/molDetails", true
	objXmlHttp.SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"
	objXmlHttp.send body
	objXmlHttp.waitForResponse(60)

	response.status = objXmlHttp.status
	response.write objXmlHttp.responseText
	Set objXmlHttp = Nothing

ElseIf trim(request.form("mrvData")) <> "" then
	experimentid = request.form("experimentid")
	
	If canViewExperiment(1,experimentId,session("userId")) Then
		'Call the save method in elnAPI that calls the dispatch_marvin
		body = "company_id="+Server.URLEncode(session("companyId"))	
		body = body + "&user_id="+Server.URLEncode(session("userId"))	
		body = body + "&experiment_id="+Server.URLEncode(experimentId)	
		body = body + "&revision_number=-1"
		body = body + "&draft_save=True"	
		body = body + "&mrvData="+Server.URLEncode(request.form("mrvData"))	
		body = body + "&experimentJSON="+Server.URLEncode(request.form("experimentJSON"))	

		Set objXmlHttp = Server.CreateObject("MSXML2.ServerXMLHTTP")
		objXmlHttp.open "POST", "http://" & appServerIP & ":5105/ChemDataMarvin/save", false
		objXmlHttp.SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"
		objXmlHttp.send body
		objXmlHttp.waitForResponse(60)
		
		response.status = objXmlHttp.status
		response.write objXmlHttp.responseText

		Set objXmlHttp = Nothing
	end if
end if

%>