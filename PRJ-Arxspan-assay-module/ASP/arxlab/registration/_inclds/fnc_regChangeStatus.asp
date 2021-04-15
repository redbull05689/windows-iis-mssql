<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
function regChangeStatusBatch(newStatus,cdId)
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	if CStr(regMoleculesTable) <> "" then
		Select Case newStatus
			Case "approve"
				perm = 1
				statusId = 1
			Case "delete"
				perm = 0
				statusId = 2
		End select
		strQuery = "UPDATE "&regMoleculesTable&" SET is_permanent="&SQLClean(perm,"N","S")&",status_id="&SQLClean(statusId,"N","S")&" WHERE cd_id="&SQLClean(cdId,"N","S")
		jchemRegConn.execute(strQuery)
	end if
End Function

function regChangeStatus(newStatus,cdId)
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	if CStr(regMoleculesTable) <> "" then
		Select Case newStatus
			Case "approve"
				perm = 1
				statusId = 1
				strQuery = "UPDATE "&regMoleculesTable&" SET is_permanent="&SQLClean(perm,"N","S")&",status_id="&SQLClean(statusId,"N","S")&" WHERE cd_id="&SQLClean(cdId,"N","S")
			Case "delete"
				perm = 0
				statusId = 2
				strQuery = "DELETE FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(cdId,"N","S")
		End select
		jchemRegConn.execute(strQuery)
	end if
End Function
%>