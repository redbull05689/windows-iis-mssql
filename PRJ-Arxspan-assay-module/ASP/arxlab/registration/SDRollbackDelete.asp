<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scriptTimeout = 60000%>
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_jchem.asp"-->
<!-- #include file="_inclds/fnc_sendProteinToSearchTool.asp"-->
<!-- #include file="_inclds/fnc_removeCdIdsFromFT.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
sectionId = "reg"
subSectionId = "sd-rollback"
if Not session("regRegistrar") Then
	response.redirect("logout.asp")
End If

rollbackId = request.querystring("id")

Call getconnectedJchemReg

If session("regRegistrar") And session("regRegistarRestricted") then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT 1 FROM sdImports WHERE id="&SQLClean(rollBackId,"N","S")&" AND userId="&SQLClean(session("userId"),"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If rec.eof Then
		rec.close
		Set rec = nothing
		Call disconnectJchemReg
		response.redirect("logout.asp")
	End If
	rec.close
	Set rec = nothing
End if

If CStr(session("rollbackId")) = CStr(rollBackId) And session("rollbackCdIds") <> "" Then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT sdFilename, outForAnalysis FROM sdImports WHERE id="&SQLClean(rollBackId,"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		sdFilename = rec("sdFilename")
		If CStr(rec("outForAnalysis")) = "1" Then
			outForAnalysis = True
		Else
			outForAnalysis = False
		End if
	End If
	rec.close
	Set rec = Nothing

	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT parent_cd_id FROM "&regMoleculesTable&" WHERE "&session("rollbackCdIdStr")&" AND just_batch='"&compoundBatchNumber&"'"
	rec.open strQuery,jchemRegConn,3,3
	parentCdIdStr = ""
	Do While Not rec.eof
		parentCdIdStr = parentCdIdStr & rec("parent_cd_id")
		rec.movenext
		If Not rec.eof Then
			parentCdIdStr = parentCdIdStr & ","
		End if
	Loop
	parentCdIds = Split(parentCdIdStr,",")
	rec.close
	Set rec = Nothing

	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT reg_id FROM "&regMoleculesTable&" WHERE "&session("rollbackCdIdStr")
	rec.open strQuery,jchemRegConn,3,3
	regIdStr = ""
	Do While Not rec.eof
		regIdStr = regIdStr & rec("reg_id")
		rec.movenext
		If Not rec.eof Then
			regIdStr = regIdStr & "<br/>"
		End if
	Loop
	rec.close
	Set rec = Nothing

	a = removeCdIdsFromFT(session("rollbackCdIds"))

	cdIds = Split(session("rollbackCdIds"),",")
	jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
	For i = 0 To UBound(cdIds)
		a = CX_removeStructure(jChemRegDB,regMoleculesTable,cdIds(i))
	Next

	messageString = "Rollback Successful. " & ubound(parentCdIds)+1 & " compounds removed and " & Ubound(cdIds)-ubound(parentCdIds) & " batches removed."
	session("rollbackId") = ""
	session("rollbackCdIds") = ""
Else
	messageString = "There was an error processing your request or you tried to rollback an empty set."
End if
Call disconnectJchemReg
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<div class="registrationPage">
<h1>Bulk Registration Log</h1>
<p><%=messageString%></p>
</div>
<!-- #include file="../_inclds/footer-tool.asp"-->