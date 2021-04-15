<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=True%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->


<%
If session("regUser") Then
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	Call getConnectedJchemReg
	strQuery = "UPDATE "&regMoleculesTable&" SET pickListJSON="&SQLClean(request.Form("pickListJSON"),"T","S")&" WHERE (pickListConfirmed is null or pickListConfirmed=0) and cd_id="&SQLClean(request.Form("theCdId"),"N","S")
	jchemRegConn.execute(strQuery)
	Call disconnectJchemReg
End if
%>