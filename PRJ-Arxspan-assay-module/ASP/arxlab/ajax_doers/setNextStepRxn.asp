<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_convertToCDXML.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_applyChemDrawStyles.asp"-->
<%
	'convert structure data to mol3000 data using chemdraw
	session("nextStepRxn") = ""

	xmlStr = convertToCDXML(CStr(request.Form("rxnFile")), None)
	
	If (Not IsNull(xmlStr)) And xmlStr <> "" Then

		templateName = getCompanySpecificSingleAppConfigSetting("blankCdxName", session("companyId"))
		

		xmlStr = applyStylesHalf(xmlStr, templateName, templateCdxml, false) 
		' save the real data if we think we got real data
		session("nextStepRxn") = xmlStr
	End If
	
	response.write("success")
%>