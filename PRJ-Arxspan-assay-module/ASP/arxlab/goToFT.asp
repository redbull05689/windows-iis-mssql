<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp" -->
<!-- #include file="_inclds/experiments/common/functions/fnc_inventoryComms.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
disableFTLite = checkBoolSettingForCompany("disableFTLite", session("companyId"))
doRedirect = False
Call getconnectedadm
Set myConn = connAdm
lite = request.querystring("lite")
If disableFTLite Then
	lite = ""
End if
if session("userHasFT") and lite="" then
	If session("hasAssay") Or session("hasInv") Or session("hasReg") or session("hasOrdering") Then
		doRedirect = true
	End if
End if
If session("companyHasFTLiteAssay") And lite="assay" Then
	If session("hasAssay") And (session("assayRoleName")="Admin" Or session("assayRoleName")="Power User" Or session("assayRoleName")="User") Then
		doRedirect = True
	End if
End if

If session("companyHasFTLiteInventory") And lite="inventory" Then
	If session("hasInv") And (session("invRoleName")="Admin" Or session("invRoleName")="Power User" Or session("invRoleName")="User") Then
		doRedirect = True
	End if
End If
If session("companyHasFTLiteReg") And lite="reg" Then
	If session("hasReg") And (session("regRoleNumber") <> 1000) Then
		doRedirect = True
	End if
End if
If doRedirect Then
	phpConn = session("servicesConnectionId")

	If userOptions.exists("languageSelect") then
		If userOptions.Get("languageSelect")<>"" Then
			interfaceLanguage = userOptions.Get("languageSelect")
		else
			interfaceLanguage = "English"
		End if
	Else
		interfaceLanguage = "English"
	End if

	If whichServer = "PROD" Then
		If whichClient="BROAD" Then
			response.redirect("https://ft.arxspan.com/login.php?userId="&session("userId")&"&token="&phpConn&"&override=BROAD"&"&language="&interfaceLanguage&"&lite="&lite&"&jwt="&session("jwtToken"))		
		else
			response.redirect("https://ft.arxspan.com/login.php?userId="&session("userId")&"&token="&phpConn&"&language="&interfaceLanguage&"&lite="&lite&"&jwt="&session("jwtToken"))
		End if
	End If
	If whichServer = "MODEL" then 
		url = "https://ft2.arxspan.com/login.php?userId="&session("userId")&"&token="&phpConn&"&language="&interfaceLanguage&"&lite="&lite&"&jwt="&session("jwtToken")
	elseif whichServer="BETA" then
		url = "https://ftbeta.arxspan.com/login.php?userId="&session("userId")&"&token="&phpConn&"&language="&interfaceLanguage&"&lite="&lite&"&jwt="&session("jwtToken")
	elseif whichServer="DEV" then
		url = "https://FTDEV.arxspan.com/login.php?userId="&session("userId")&"&token="&phpConn&"&language="&interfaceLanguage&"&lite="&lite&"&jwt="&session("jwtToken")
	End If
	response.redirect(url)
End if
Call disconnectadm
%>