<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
If session("companyId") <> "" Then
	usesSSO = getCompanySpecificSingleAppConfigSetting("usesSSO", session("companyId"))
	ssoFolderName = getCompanySpecificSingleAppConfigSetting("ssoFolderPathName", session("companyId"))
End If 

Function companyUsesSso()
	companyUsesSso = False
	If usesSSO And ssoFolderName <> "" Then
		companyUsesSso = True
	End If
End Function

Function checkPasswordChangeRequired()
	If session("mustChangePassword")=1 then
		if session("isSsoUser") or session("useGoogleSign") Or usesSSO or ssoFolderName <> "" Then
			session("mustChangePassword") = 0
		end if
	End If
End Function
%>