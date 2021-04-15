<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
theCdId = request.Form("cdId")
theProjectId = request.Form("projectId")
If theCdId <> "" And theProjectId <> "" Then
	call getconnectedAdm
	strQuery = "DELETE FROM linksProjectReg WHERE projectId=" & SQLClean(theProjectId,"N","S") & " AND cd_id=" & SQLClean(theCdId,"N","S")
	connAdm.execute(strQuery)
	call disconnectadm
	
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT projectId FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(theCdId,"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		If Not IsNull(rec("projectId")) Then
			If CStr(rec("projectId")) = CStr(theProjectId) Then
				strQuery = "UPDATE "&regMoleculesTable&" SET projectId=null WHERE cd_id="&SQLClean(theCdId,"N","S")
				jchemRegConn.execute(strQuery)
			End If
		End If
	End If
	Call disconnectJchemReg
End If
response.write("{""status"":""ok""}")
%>